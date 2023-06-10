//
//  AddCustomAssetViewModel.swift
//  Pino-iOS
//
//  Created by Amir hossein kazemi seresht on 2/13/23.
//

import BigInt
import Foundation
import Web3Core
import web3swift

class AddCustomAssetViewModel {
	// MARK: - Public Enums

	public enum ContractValidationStatus: Equatable {
		case clear
		case pasteFromClipboard(String)
		case pending
		case error(FailedToValidateCustomAssetStatus)
		case success
	}

	#warning("These values are for testing and should be changed")
	public enum ValidateTextFieldDelay: Double {
		case small = 0.2
		case none = 0.0
	}

	public enum FailedToValidateCustomAssetStatus: Error {
		case notValid
		case networkError
		case notValidFromServer
		case unavailableNode
		case unknownError
		case notValidSmartContractAddress
		case alreadyAdded

		public var description: String {
			switch self {
			case .notValid:
				return "Address is not an ETH valid address"
			case .networkError:
				return "No internet connection, try again later"
			case .notValidFromServer:
				return "Custom asset is not valid"
			case .unavailableNode:
				return "Cant access to the network, try again later"
			case .unknownError:
				return "Unknown error happend, try again later"
			case .notValidSmartContractAddress:
				return "Address is not a valid smart contract address"
			case .alreadyAdded:
				return "Token is already added"
			}
		}
	}

	// MARK: - Closures

	public var changeViewStatusClosure: ((ContractValidationStatus) -> Void)!

	// MARK: - Public Properties

	public var customAssetVM: CustomAssetViewModel?

	public let addCustomAssetButtonTitle = "Add"
	public let addcustomAssetPageTitle = "Add custom asset"
	public let addCustomAssetPageBackButtonIcon = "dissmiss"
	public let addCustomAssetTextfieldPlaceholder = "Enter contract address"
	public let addCustomAssetTextfieldError = "This is an error!"
	public let addCustomAssetTextfieldIcon = "qr_code_scanner"

	public var customAssetNameInfo: CustomAssetInfoViewModel
	public var customAssetUserBalanceInfo: CustomAssetInfoViewModel
	public var customAssetSymbolInfo: CustomAssetInfoViewModel
	public var customAssetDecimalInfo: CustomAssetInfoViewModel
	public var userAddress: String
	public var userTokens: [Detail]

	// MARK: - Private Properties

	private let erc20AbiString = """
	[{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"decimals","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]
	"""
	private var getCustomAssetInfoRequestWork: DispatchWorkItem!
	private var web3: Web3!
	private var readNodeContractKey = "0"
	private var userAddressStaticCode = "0x"

	private let coredataManager = CoreDataManager()

	// MARK: - Initializers

	init(useraddress: String, userTokens: [Detail]) {
		self.userAddress = useraddress
		self.userTokens = userTokens
		#warning("this aletsTexts are for testing")
		self
			.customAssetNameInfo =
			CustomAssetInfoViewModel(customAssetInfo: CustomAssetInfoModel(title: "Name", alertText: "Sample Text"))
		self
			.customAssetUserBalanceInfo =
			CustomAssetInfoViewModel(customAssetInfo: CustomAssetInfoModel(
				title: "Your balance",
				alertText: "Sample Text"
			))
		self
			.customAssetSymbolInfo =
			CustomAssetInfoViewModel(customAssetInfo: CustomAssetInfoModel(title: "Symbol", alertText: "Sample Text"))
		self
			.customAssetDecimalInfo =
			CustomAssetInfoViewModel(customAssetInfo: CustomAssetInfoModel(
				title: "Decimal",
				alertText: "Sample Text"
			))
	}

	// MARK: - Public Methods

	public func validateContractAddressFromClipboard(clipboardText: String) {
		if clipboardText.isEmpty {
			return
		}
		if clipboardText.validateETHContractAddress() {
			changeViewStatusClosure(.pasteFromClipboard(clipboardText))
		}
	}

	public func validateContractAddressBeforeRequest(textFieldText: String, delay: ValidateTextFieldDelay) {
		if textFieldText.isEmpty {
			changeViewStatusClosure(.clear)
			return
		}

		if textFieldText.validateETHContractAddress() {
			let lowercasedTextFieldText = textFieldText.lowercased()
			let foundToken = userTokens.first(where: { $0.id.lowercased() == lowercasedTextFieldText })
			if foundToken != nil {
				changeViewStatusClosure(.error(.alreadyAdded))
				return
			} else {
				changeViewStatusClosure(.pending)
				DispatchQueue.main.asyncAfter(deadline: .now() + delay.rawValue) { [weak self] in
					Task {
						self?
							.changeViewStatusClosure(
								await self?
									.getCustomAssetInfo(contractAddress: textFieldText) ?? .error(.unknownError)
							)
					}
				}
			}
		} else {
			changeViewStatusClosure(.error(.notValid))
		}
	}

	public func saveCustomTokenToCoredata() -> CustomAsset? {
		guard let customAssetVM else { return nil }
		if coredataManager.getAllCustomAssets().contains(where: { $0.id == customAssetVM.contractAddress }) {
			return nil
		} else {
			let customAssetModel = coredataManager.addNewCustomAsset(
				id: customAssetVM.contractAddress,
				symbol: customAssetVM.symbol,
				name: customAssetVM.name
			)
			return customAssetModel
		}
	}

	// MARK: - Private Methods

	private func getCustomAssetInfo(contractAddress: String) async -> ContractValidationStatus {
		do {
			web3 =
				try await Web3(provider: Web3HttpProvider(url: AssetsEndpoint.currentETHProvider!, network: .Mainnet))
		} catch {
			return .error(.unavailableNode)
		}

		let validateIsSmartContractStatus = await validateIsSmartContract(contractAddress: contractAddress)

		if validateIsSmartContractStatus == .success {
			return await validateIsERC20Token(contractAddress: contractAddress)
		} else {
			return validateIsSmartContractStatus
		}
	}

	private func validateIsSmartContract(contractAddress: String) async -> ContractValidationStatus {
		let nodeRequest: APIRequest = .getCode(contractAddress, .latest)
		var nodeResponse: APIResponse<String>!
		do {
			nodeResponse = try await APIRequest.sendRequest(with: web3.provider, for: nodeRequest)
		} catch {
			return .error(.unavailableNode)
		}
		if nodeResponse.result == userAddressStaticCode {
			return .error(.notValidSmartContractAddress)
		} else {
			return .success
		}
	}

	private func validateIsERC20Token(contractAddress: String) async -> ContractValidationStatus {
		let contract = web3.contract(erc20AbiString, at: EthereumAddress(from: contractAddress))

		let readBalanceOfOpParameters = [userAddress]

		let readTokenNameOp = contract?.createReadOperation("name")
		let readTokenSymbolOp = contract?.createReadOperation("symbol")
		let readTokenBalanceOfOp = contract?.createReadOperation("balanceOf", parameters: readBalanceOfOpParameters)
		let readTokenDecimalsOp = contract?.createReadOperation("decimals")

		do {
			guard let tokenName = try await readTokenNameOp?.callContractMethod()[readNodeContractKey] as? String else {
				return .error(.notValidFromServer)
			}
			guard let tokenSymbol = try await readTokenSymbolOp?.callContractMethod()[readNodeContractKey] as? String
			else {
				return .error(.notValidFromServer)
			}
			guard let tokenBalanceOf = try await readTokenBalanceOfOp?.callContractMethod()[readNodeContractKey] else {
				return .error(.notValidFromServer)
			}

			guard let tokenDecimals = try await readTokenDecimalsOp?
				.callContractMethod()[readNodeContractKey] as? BigUInt else {
				return .error(.notValidFromServer)
			}

			customAssetVM = CustomAssetViewModel(customAsset: CustomAssetModel(
				id: contractAddress,
				name: tokenName,
				symbol: tokenSymbol,
				balance: tokenBalanceOf,
				decimal: tokenDecimals
			))
			return .success
		} catch {
			return .error(.unknownError)
		}
	}
}
