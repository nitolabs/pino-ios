//
//  EnterSendAddressViewModel.swift
//  Pino-iOS
//
//  Created by Amir hossein kazemi seresht on 6/15/23.
//
import Foundation

class EnterSendAddressViewModel {
	// MARK: - Closures

	public var didValidateSendAddress: (ValidationStatus) -> Void = { _ in }

	// MARK: - Public Properties

	public let enterAddressPlaceholder = "Enter address"
	public let pageTitlePreFix = "Send"
	public let nextButtonTitle = "Next"
	public let qrCodeIconName = "qr_code_scanner"
	public var sendAmountVM: EnterSendAmountViewModel
	public var selectedWallet: AccountInfoViewModel!
	public var recipientAddress: String?
	public var addressInputType: AddressInputType = .regularAddress

	public var sendAddressQrCodeScannerTitle: String {
		"Scan address to send \(sendAmountVM.selectedToken.symbol)"
	}

	public enum ValidationStatus: Equatable {
		case error(ValidationError)
		case success
		case normal
	}

	public enum ValidationError: Error {
		case addressNotValid
		case sameAddress

		public var description: String {
			switch self {
			case .addressNotValid:
				return "Invalid address"
			case .sameAddress:
				return "It's your account!"
			}
		}
	}

	// MARK: - Private Properties

	private let pinoWalletManager = PinoWalletManager()

	// MARK: - Initializers

	init(sendAmountVM: EnterSendAmountViewModel) {
		self.sendAmountVM = sendAmountVM
		getSelectedWallet()
	}

	// MARK: - Private Methods

	private func getSelectedWallet() {
		let currentWallet = CoreDataManager().getAllWalletAccounts().first(where: { $0.isSelected })
		selectedWallet = AccountInfoViewModel(walletAccountInfoModel: currentWallet)
	}

	private func validateRegularAddress(_ address: String) {
		if address.isEmpty {
			recipientAddress = nil
			didValidateSendAddress(.normal)
			return
		}
		if address == pinoWalletManager.currentAccount.eip55Address {
			recipientAddress = nil
			didValidateSendAddress(.error(.sameAddress))
			return
		}
		if address.validateETHContractAddress() {
			recipientAddress = address
			didValidateSendAddress(.success)
		} else {
			recipientAddress = nil
			didValidateSendAddress(.error(.addressNotValid))
		}
	}

	private func getENSAddress(_ ensId: String) {
		// The request to get ENS address will implement later
		addressInputType = .regularAddress
		didValidateSendAddress(.error(.addressNotValid))
	}

	// MARK: - Public Methods

	public func validateSendAddress(address: String) {
		if address.isENSAddress() {
			getENSAddress(address)
		} else {
			addressInputType = .regularAddress
			validateRegularAddress(address)
		}
	}

	public func selectUserWallet(_ account: AccountInfoViewModel) {
		addressInputType = .userNameWithAddress
		recipientAddress = account.address
		validateRegularAddress(account.address)
	}
}

enum AddressInputType {
	case regularAddress
	case ensWithAddress
	case userNameWithAddress
}
