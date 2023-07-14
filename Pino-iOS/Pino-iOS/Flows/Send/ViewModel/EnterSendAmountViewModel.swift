//
//  EnterSendAmountViewModel.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 6/11/23.
//

import BigInt
import Foundation

class EnterSendAmountViewModel {
	// MARK: - Public Properties

	public var isDollarEnabled: Bool
	public let maxTitle = "Max: "
	public let dollarIcon = "dollar_icon"
	public let continueButtonTitle = "Next"
	public let dollarSign = "$"
	public let insufficientAmountButtonTitle = "Insufficient amount"
	public var selectedTokenChanged: (() -> Void)?
	public var textFieldPlaceHolder = "0"

	public var selectedToken: AssetViewModel {
		didSet {
			updateTokenMaxAmount()
			if let selectedTokenChanged {
				selectedTokenChanged()
			}
		}
	}

	public var maxHoldAmount: BigNumber!
	public var maxAmountInDollar: BigNumber!
	public var tokenAmount = "0"
	public var dollarAmount = "0"

	public var formattedMaxHoldAmount: String {
		"\(maxHoldAmount.sevenDigitFormat) \(selectedToken.symbol)"
	}

	public var formattedMaxAmountInDollar: String {
        maxAmountInDollar.priceFormat.currencyFormatting
	}

	public var formattedAmount: String {
		if isDollarEnabled {
            return "\(tokenAmount.tokenFormatting(token: selectedToken.symbol))"
		} else {
            return dollarAmount.currencyFormatting
		}
	}

	// MARK: - Initializers

	init(selectedToken: AssetViewModel, isDollarEnabled: Bool = false) {
		self.selectedToken = selectedToken
		self.isDollarEnabled = isDollarEnabled
		updateTokenMaxAmount()
	}

	// MARK: - Public Methods

	public func calculateAmount(_ amount: String) {
		if isDollarEnabled {
			convertDollarAmountToTokenValue(amount: amount)
		} else {
			convertEnteredAmountToDollar(amount: amount)
		}
	}

	public func checkIfBalanceIsEnough(amount: String, amountStatus: (AmountStatus) -> Void) {
		if amount == .emptyString {
			amountStatus(.isZero)
        } else if BigNumber(numberWithDecimal: amount).isZero {
			amountStatus(.isZero)
		} else {
			var decimalMaxAmount: BigNumber
			var enteredAmmount: BigNumber
			if isDollarEnabled {
				decimalMaxAmount = maxAmountInDollar
				enteredAmmount = BigNumber(numberWithDecimal: dollarAmount)
			} else {
				decimalMaxAmount = maxHoldAmount
				enteredAmmount = BigNumber(numberWithDecimal: tokenAmount)
			}
			if enteredAmmount > decimalMaxAmount {
				amountStatus(.isNotEnough)
			} else {
				amountStatus(.isEnough)
			}
		}
	}

	public func updateEthMaxAmount(
		gasFee: BigNumber = GlobalVariables.shared.ethGasFee.fee,
		gasFeeInDollar: BigNumber = GlobalVariables.shared.ethGasFee.feeInDollar
	) {
		let estimatedAmount = selectedToken.holdAmount - gasFee
		maxHoldAmount = estimatedAmount

		let estimatedAmountInDollar = selectedToken.holdAmountInDollor - gasFeeInDollar
		maxAmountInDollar = estimatedAmountInDollar
	}

	// MARK: - Private Methods

	private func updateTokenMaxAmount() {
		if selectedToken.isEth {
			updateEthMaxAmount()
		} else {
			maxHoldAmount = selectedToken.holdAmount
			maxAmountInDollar = selectedToken.holdAmountInDollor
		}
	}

	private func convertEnteredAmountToDollar(amount: String) {
		let decimalBigNum = BigNumber(numberWithDecimal: amount)
		let price = selectedToken.price

		let amountInDollarDecimalValue = BigNumber(
			number: decimalBigNum.number * price.number,
			decimal: decimalBigNum.decimal + 6
		)
		dollarAmount = amountInDollarDecimalValue.priceFormat
		tokenAmount = amount
	}

	private func convertDollarAmountToTokenValue(amount: String) {
		let decimalBigNum = BigNumber(numberWithDecimal: amount)
		let priceAmount = decimalBigNum.number * BigInt(10).power(6 + selectedToken.decimal - decimalBigNum.decimal)
		let price = selectedToken.price

		let tokenAmountDecimalValue = priceAmount.quotientAndRemainder(dividingBy: price.number)
		tokenAmount = BigNumber(number: tokenAmountDecimalValue.quotient, decimal: selectedToken.decimal)
			.sevenDigitFormat
		dollarAmount = amount
	}
}
