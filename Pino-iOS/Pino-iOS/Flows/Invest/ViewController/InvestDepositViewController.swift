//
//  InvestDepositViewController.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 8/23/23.
//

import PromiseKit
import UIKit
import Web3_Utility

class InvestDepositViewController: UIViewController {
	// MARK: Private Properties

	private var investVM: InvestViewModelProtocol!
	private var investView: InvestDepositView!
	private var web3 = Web3Core.shared
	private let walletManager = PinoWalletManager()
	private var onDepositConfirm: (SendTransactionStatus) -> Void

	// MARK: Initializers

	init(investVM: InvestViewModelProtocol, onDepositConfirm: @escaping (SendTransactionStatus) -> Void) {
		self.investVM = investVM
		self.onDepositConfirm = onDepositConfirm
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func loadView() {
		setupView()
		setupNavigationBar()
	}

	override func viewDidAppear(_ animated: Bool) {
		investView.amountTextfield.becomeFirstResponder()
	}

	// MARK: - Private Methods

	private func setupView() {
		investView = InvestDepositView(
			investVM: investVM,
			nextButtonTapped: {
				self.proceedInvestFlow()
			}
		)
		view = investView

		if let depositVM = investVM as? InvestDepositViewModel {
			depositVM.checkOpenPosition().catch { error in
				self.showErrorToast(error)
			}
		}
	}

	private func setupNavigationBar() {
		// Setup appreance for navigation bar
		setupPrimaryColorNavigationBar()
		// Setup title view
		setNavigationTitle(investVM.pageTitle)
		// Setup close button
		if navigationController!.viewControllers.count <= 1 {
			navigationItem.leftBarButtonItem = UIBarButtonItem(
				image: UIImage(systemName: "multiply"),
				style: .plain,
				target: self,
				action: #selector(closePage)
			)
		}
		navigationController?.navigationBar.tintColor = .Pino.white
	}

	@objc
	private func closePage() {
		dismiss(animated: true)
	}

	private func proceedInvestFlow() {
		// First Step of Invest
		// Check If Permit has access to Token
		getTokenAddress().done { tokenAddress in
			if tokenAddress == GlobalVariables.shared.manageAssetsList?.first(where: { $0.isEth })?.id {
				self.openConfirmationPage()
				return
			}
			self.checkAllowance(of: tokenAddress)
		}.catch { error in
			self.showErrorToast(error)
		}
	}

	private func checkAllowance(of tokenAddress: String) {
		firstly {
			try web3.getAllowanceOf(
				contractAddress: tokenAddress,
				spenderAddress: Web3Core.Constants.permitAddress,
				ownerAddress: walletManager.currentAccount.eip55Address
			)
		}.done { [self] allowanceAmount in
			let destTokenDecimal = investVM.selectedToken.decimal
			let destTokenAmount = Utilities.parseToBigUInt(investVM.tokenAmount, decimals: destTokenDecimal)
			if allowanceAmount == 0 || allowanceAmount < destTokenAmount! {
				// NOT ALLOWED
				openTokenApprovePage(tokenID: tokenAddress)
			} else {
				// ALLOWED
				openConfirmationPage()
			}
		}.catch { error in
			print(error)
		}
	}

	private func openTokenApprovePage(tokenID: String) {
		investView.stopLoading()
		let approveVC = ApproveContractViewController(
			approveContractID: tokenID,
			showConfirmVC: {
				self.openConfirmationPage()
			},
			approveType: investVM.approveType
		)
		let approveNavigationVC = UINavigationController(rootViewController: approveVC)
		present(approveNavigationVC, animated: true)
	}

	private func openConfirmationPage() {
		investView.stopLoading()
		let investConfirmationVC = InvestConfirmationViewController(
			confirmationVM: investVM.investConfirmationVM,
			onConfirm: onDepositConfirm
		)
		navigationController?.pushViewController(investConfirmationVC, animated: true)
	}

	private func getTokenAddress() -> Promise<String> {
		if let withdrawVM = investVM as? WithdrawViewModel {
			return withdrawVM.getTokenPositionID()
		} else {
			let tokenAddress = investVM.selectedToken.id.lowercased()
			return Promise.value(tokenAddress)
		}
	}

	private func showErrorToast(_ error: Error) {
		if let error = error as? APIError {
			Toast.default(title: error.toastMessage, style: .error).show()
		}
	}
}
