//
//  SwapViewController.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 12/17/22.
//

import Combine
import PromiseKit
import UIKit
import Web3_Utility

class SwapViewController: UIViewController {
	// MARK: - Private Properties

	private var assets: [AssetViewModel]?
	private var swapVM: SwapViewModel!
	private var swapView: SwapView!
	private var web3 = Web3Core.shared
	private let protocolChangeButton = UIButton()
	private let pageTitleLabel = UILabel()
	private let walletManager = PinoWalletManager()
	private let swapLoadingView = SwapLoadingView()

	private var cancellables = Set<AnyCancellable>()

	// MARK: - View Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func loadView() {
		setupView()
		setupStyle()
		setupNavigationBar()
	}

	override func viewWillAppear(_ animated: Bool) {
		if GlobalVariables.shared.manageAssetsList == nil {
			swapLoadingView.showSkeletonView()
		}
	}

	// MARK: - Private Methods

	private func setupView() {
		view = swapLoadingView
		GlobalVariables.shared.$manageAssetsList.compactMap { $0 }.sink { assetList in
			if self.assets == nil {
				self.setupViewModel(assetList: assetList)
				self.swapView = SwapView(
					swapVM: self.swapVM,
					fromTokenChange: {
						self.selectAssetForFromToken()
					},
					toTokeChange: {
						self.selectAssetForToToken()
					},
					swapProtocolChange: {
						self.openSelectProtocolPage()
					},
					providerChange: {
						self.openProvidersPage()
					},
					nextButtonTapped: {
						self.proceedSwapFlow()
					}
				)
				self.view = self.swapView
				self.setupBinding()
			} else {
				self.updateSelectedToken(assetList: assetList)
			}
			self.assets = assetList
		}.store(in: &cancellables)
	}

	private func setupViewModel(assetList: [AssetViewModel]) {
		let ethToken = assetList.first(where: { $0.isEth })!
		let usdcToken = assetList.first(where: { $0.symbol == "USDC" })!
		swapVM = SwapViewModel(fromToken: ethToken, toToken: usdcToken)
	}

	private func updateSelectedToken(assetList: [AssetViewModel]) {
		guard let selectedToken = assetList.first(where: { $0.id == self.swapVM.fromToken.selectedToken.id })
		else { return }
		swapVM.fromToken.selectedToken = selectedToken
	}

	private func setupStyle() {
		pageTitleLabel.text = "Swap"
		pageTitleLabel.textColor = .Pino.white
		pageTitleLabel.font = .PinoStyle.semiboldBody

		protocolChangeButton.setImage(UIImage(named: "chevron_down"), for: .normal)
		protocolChangeButton.setTitleColor(.Pino.white, for: .normal)
		protocolChangeButton.tintColor = .Pino.white
		protocolChangeButton.setConfiguraton(font: .PinoStyle.semiboldBody!, imagePadding: 3, imagePlacement: .trailing)

		protocolChangeButton.addAction(UIAction(handler: { _ in
			self.openSelectProtocolPage()
		}), for: .touchUpInside)
	}

	private func setupBinding() {
		swapVM.$selectedProtocol.sink { selectedProtocol in
			self.protocolChangeButton.setTitle(selectedProtocol.name, for: .normal)
		}.store(in: &cancellables)

		swapView.$keyboardIsOpen.sink { keyboardIsOpen in
			if keyboardIsOpen {
				self.swapView.closeFeeCard()
			} else {
				self.swapView.openFeeCard()
			}
		}.store(in: &cancellables)
	}

	private func setupNavigationBar() {
		setupPrimaryColorNavigationBar()
		// show navbar protocol button in small devices
		if DeviceHelper.shared.size == .normal {
			navigationItem.titleView = pageTitleLabel
		} else {
			navigationItem.titleView = protocolChangeButton
		}
	}

	private func showProtocolCard() {
		// show and hide protocol card in normal size devices
		if DeviceHelper.shared.size == .normal {
			showPageTitleInNavbar()
			swapView.showProtocolView()
		}
	}

	private func hideProtocolCard() {
		// show and hide protocol card in normal size devices
		if DeviceHelper.shared.size == .normal {
			showProtocolButtonInNavbar()
			swapView.hideProtocolView()
		}
	}

	private func showProtocolButtonInNavbar() {
		navigationItem.titleView = protocolChangeButton
	}

	private func showPageTitleInNavbar() {
		navigationItem.titleView = pageTitleLabel
	}

	private func openSelectProtocolPage() {
		let swapProtocolVC = SelectSwapProtocolViewController { selectedProtocol in
			self.swapVM.changeSwapProtocol(to: selectedProtocol)
		}
		let swapProtocolNavigationVC = UINavigationController(rootViewController: swapProtocolVC)
		present(swapProtocolNavigationVC, animated: true)
	}

	private func selectAssetForFromToken() {
		var filteredAssets = assets!.filter { $0.isSelected && !$0.holdAmount.isZero && $0.isVerified }
		// To prevent swapping same tokens
		filteredAssets.removeAll(where: { $0.id == swapVM.toToken.selectedToken.id })
		openSelectAssetPage(assets: filteredAssets) { selectedToken in
			self.swapVM.changeSelectedToken(self.swapVM.fromToken, to: selectedToken)
		}
	}

	private func selectAssetForToToken() {
		var filteredAssets = assets!.filter { $0.isVerified }
		// To prevent swapping same tokens
		filteredAssets.removeAll(where: { $0.id == swapVM.fromToken.selectedToken.id })
		openSelectAssetPage(assets: filteredAssets) { selectedToken in
			self.swapVM.changeSelectedToken(self.swapVM.toToken, to: selectedToken)
		}
	}

	private func openSelectAssetPage(assets: [AssetViewModel], assetChanged: @escaping (AssetViewModel) -> Void) {
		let selectAssetVC = SelectAssetToSendViewController(assets: assets)
		selectAssetVC.changeAssetFromEnterAmountPage = { selectedAsset in
			assetChanged(selectedAsset)
		}
		let selectAssetNavigationController = UINavigationController(rootViewController: selectAssetVC)
		present(selectAssetNavigationController, animated: true)
	}

	private func openProvidersPage() {
		guard let bestProvider = swapVM.bestProvider else { return }
		let providersVC = SwapProvidersViewcontroller(
			providers: swapVM.providers,
			bestProvider: bestProvider,
			selectedProvider: swapVM.swapFeeVM.swapProviderVM
		) { provider in
			self.swapVM.changeSwapProvider(to: provider)
		}
		present(providersVC, animated: true)
	}

	private func proceedSwapFlow() {
		// First Step of Swap
		// Check If Permit has access to Token
		if swapVM.fromToken.selectedToken.isEth {
			openConfirmationPage()
			return
		}
		firstly {
			try web3.getAllowanceOf(
				contractAddress: swapVM.fromToken.selectedToken.id.lowercased(),
				spenderAddress: Web3Core.Constants.permitAddress,
				ownerAddress: walletManager.currentAccount.eip55Address
			)
		}.done { [self] allowanceAmount in
			let destTokenDecimal = swapVM.fromToken.selectedToken.decimal
			let destTokenAmount = Utilities.parseToBigUInt(swapVM.fromToken.tokenAmount!, decimals: destTokenDecimal)
			if allowanceAmount == 0 || allowanceAmount < destTokenAmount! {
				// NOT ALLOWED
				openTokenApprovePage()
			} else {
				// ALLOWED
				openConfirmationPage()
			}
		}.catch { error in
			print(error)
		}
	}

	private func openTokenApprovePage() {
		let swapConfirmationVM = SwapConfirmationViewModel(
			fromToken: swapVM.fromToken,
			toToken: swapVM.toToken,
			selectedProtocol: swapVM.selectedProtocol,
			selectedProvider: swapVM.swapFeeVM.swapProviderVM,
			swapRate: swapVM.swapFeeVM.calculatedAmount!
		)
		let approveVC = ApproveContractViewController(
			approveContractID: swapConfirmationVM.fromToken.selectedToken.id,
			showConfirmVC: {
				self.openConfirmationPage()
			}
		)
		let confirmationNavigationVC = UINavigationController(rootViewController: approveVC)
		present(confirmationNavigationVC, animated: true)
	}

	private func openConfirmationPage() {
		swapVM.getSwapSide { _, srcToken, destToken in
			let swapConfirmationVM = SwapConfirmationViewModel(
				fromToken: srcToken,
				toToken: destToken,
				selectedProtocol: swapVM.selectedProtocol,
				selectedProvider: swapVM.swapFeeVM.swapProviderVM,
				swapRate: swapVM.swapFeeVM.calculatedAmount!
			)
			let confirmationVC = SwapConfirmationViewController(swapConfirmationVM: swapConfirmationVM)
			let confirmationNavigationVC = UINavigationController(rootViewController: confirmationVC)
			present(confirmationNavigationVC, animated: true)
		}
	}
}
