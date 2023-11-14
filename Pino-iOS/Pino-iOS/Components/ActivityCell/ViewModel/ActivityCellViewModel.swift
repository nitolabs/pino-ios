//
//  CoinHistoryViewModel.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 2/17/23.
//

import Foundation

struct ActivityCellViewModel: ActivityCellViewModelProtocol {
	// MARK: - Private Properties

	private let swapIcon = "swap"
	private let sendIcon = "send"
	private let receiveIcon = "receive"
	private let collateralIcon = "collateral"
	private let decreaseCollateral = "uncollateral"
	private let repaidIcon = "repaid"
	private let investIcon = "invest"
	private let withdrawIcon = "withdraw"
	private let borrowIcon = "borrow_transaction"
	private let approveIcon = "approve"

	private let currentAddress = PinoWalletManager().currentAccount.eip55Address

	// MARK: - Internal Properties

	internal var activityType: ActivityType {
		ActivityType(rawValue: activityModel.type)!
	}

	internal var uiType: ActivityUIType {
		switch activityType {
		case .transfer:
			if isSendTransaction() {
				return .send
			}
			return .receive
		case .transfer_from:
			if isSendTransaction() {
				return .send
			}
			return .receive
		case .swap:
			return .swap
		case .create_investment, .increase_investment:
			return .invest
		case .create_withdraw_investment:
			if isWithdrawTransaction {
				return .withdraw_investment
			}
			return .invest
		case .decrease_investment, .withdraw_investment:
			return .withdraw_investment
		case .borrow:
			return .borrow
		case .repay, .repay_behalf:
			return .repay
		case .increase_collateral, .create_collateral:
			return .collateral
		case .decrease_collateral, .remove_collateral:
			return .withdraw_collateral
		case .enable_collateral:
			return .enable_collateral
		case .disable_collateral:
			return .disable_collateral
		case .approve:
			return .approve
		}
	}

	// MARK: - Public Properties

	public var activityModel: ActivityModelProtocol
	public var swapDetailsVM: SwapActivityDetailsViewModel? {
		didSet {
			setValues()
		}
	}

	public var transferDetailsVM: TransferActivityDetailsViewModel? {
		didSet {
			setValues()
		}
	}

	public var borrowDetailsVM: BorrowActivityDetailsViewModel? {
		didSet {
			setValues()
		}
	}

	public var repayDetailsVM: RepayActivityDetailsViewModel? {
		didSet {
			setValues()
		}
	}

	public var withdrawInvestmentDetailsVM: WithdrawInvestmentActivityDetailsViewModel? {
		didSet {
			setValues()
		}
	}

	public var investDetailsVM: InvestActivityDetailsViewModel? {
		didSet {
			setValues()
		}
	}

	public var withdrawCollateralDetailsVM: WithdrawCollateralActivityDetailsViewModel? {
		didSet {
			setValues()
		}
	}

	public var collateralDetailsVM: CollateralActivityDetailsViewModel? {
		didSet {
			setValues()
		}
	}

	public var collateralStatusDetailsVM: CollateralStatusActivityDetailsViewModel? {
		didSet {
			setValues()
		}
	}

	public var approveDetailsVM: ApproveActivityDetailsViewModel? {
		didSet {
			setValues()
		}
	}

	public var activityMoreInfo: String!

	public var blockTime: String {
		activityModel.blockTime
	}

	public var isWithdrawTransaction: Bool {
		if let investActivity = activityModel as? ActivityInvestModel {
			if currentAddress.lowercased() == investActivity.fromAddress.lowercased() {
				return true
			} else {
				return false
			}
		} else {
			return false
		}
	}

	public var status: ActivityCellStatus {
		#warning("this section is mock and we should refactor this section")
		guard activityModel.failed != nil else {
			return .pending
		}
		if activityModel.failed! {
			return .failed
		} else {
			return .success
		}
	}

	public var icon: String!

	public var title: String!

	public var defaultActivityModel: ActivityModelProtocol {
		activityModel
	}

	// MARK: - Initializers

	init(activityModel: ActivityModelProtocol) {
		self.activityModel = activityModel
	}

	// MARK: - Private Methods

	private func isSendTransaction() -> Bool {
		if let transferActivity = activityModel as? ActivityTransferModel {
			if currentAddress.lowercased() == transferActivity.detail.from.lowercased() {
				return true
			} else {
				return false
			}
		} else {
			return false
		}
	}

	private mutating func setValues() {
		switch uiType {
		case .swap:
			// set cell title
			title = "Swap \(swapDetailsVM!.fromTokenSymbol) → \(swapDetailsVM!.toTokenSymbol)"
			// set cell moreInfo
			activityMoreInfo = swapDetailsVM!.activityProtocol.capitalized
			// set cell icon
			icon = swapIcon
		case .send:
			// set cell title
			title =
				"Send \(transferDetailsVM!.transferTokenAmount.sevenDigitFormat) \(transferDetailsVM!.tokenSymbol)"
			// set cell moreInfo
			activityMoreInfo =
				"To: \(transferDetailsVM!.userToAccountInfo?.name ?? activityModel.toAddress.addressFromStartFormatting())"
			// set cell icon
			icon = sendIcon
		case .receive:
			// set cell title
			title =
				"Receive \(transferDetailsVM!.transferTokenAmount.sevenDigitFormat) \(transferDetailsVM!.tokenSymbol)"
			// set cell moreInfo
			activityMoreInfo =
				"From: \(transferDetailsVM!.userFromAccountInfo?.name ?? activityModel.fromAddress.addressFromStartFormatting())"
			// set cell icon
			icon = receiveIcon
		case .borrow:
			// set cell title
			title =
				"Borrow \(borrowDetailsVM!.tokenAmount.sevenDigitFormat) \(borrowDetailsVM!.tokenSymbol)"
			// set cell moreInfo
			activityMoreInfo = borrowDetailsVM!.activityProtocol.capitalized
			// set cell icon
			icon = borrowIcon
		case .repay:
			// set cell title
			title =
				"Repaid \(repayDetailsVM!.tokenAmount.sevenDigitFormat) \(repayDetailsVM!.tokenSymbol)"
			// set cell moreInfo
			activityMoreInfo = repayDetailsVM!.activityProtocol.capitalized
			// set cell icon
			icon = repaidIcon
		case .withdraw_investment:
			// set cell title
			title =
				"Withdraw \(withdrawInvestmentDetailsVM!.tokenAmount.sevenDigitFormat) \(withdrawInvestmentDetailsVM!.tokenSymbol)"
			// set cell moreInfo
			activityMoreInfo = withdrawInvestmentDetailsVM!.activityProtocol.capitalized
			// set cell icon
			icon = withdrawIcon
		case .invest:
			// set cell title
			title =
				"Invested \(investDetailsVM!.tokenAmount.sevenDigitFormat) \(investDetailsVM!.tokenSymbol)"
			// set cell moreInfo
			activityMoreInfo = investDetailsVM!.activityProtocol.capitalized
			// set cell icon
			icon = investIcon
		case .collateral:
			// set cell title
			title =
				"Collateralized \(collateralDetailsVM!.tokenAmount.sevenDigitFormat) \(collateralDetailsVM!.tokenSymbol)"
			// set cell moreInfo
			activityMoreInfo = collateralDetailsVM!.activityProtocol.capitalized
			// set cell icon
			icon = collateralIcon
		case .withdraw_collateral:
			// set cell title
			title =
				"Uncollateralized \(withdrawCollateralDetailsVM!.tokenAmount.sevenDigitFormat) \(withdrawCollateralDetailsVM!.tokenSymbol)"
			// set cell moreInfo
			activityMoreInfo = withdrawCollateralDetailsVM!.activityProtocol.capitalized
			// set cell icon
			icon = decreaseCollateral
		case .enable_collateral:
			// set cell title
			title =
				"Enable \(collateralStatusDetailsVM!.tokenSymbol) to collateralized"
			// set cell moreInfo
			activityMoreInfo = collateralStatusDetailsVM!.activityProtocol.capitalized
			// set cell icon
			#warning("this should change")
			icon = approveIcon
		case .disable_collateral:
			// set cell title
			title =
				"Disable \(collateralStatusDetailsVM!.tokenSymbol) to collateralized"
			// set cell moreInfo
			activityMoreInfo = collateralStatusDetailsVM!.activityProtocol.capitalized
			// set cell icon
			#warning("this should change")
			icon = approveIcon
		case .approve:
			// set cell title
			title =
				"Approve \(approveDetailsVM!.tokenSymbol)"
			// set cell moreInfo
			activityMoreInfo = "Permit 2"
			// set cell icon
			icon = approveIcon
		}
	}
}
