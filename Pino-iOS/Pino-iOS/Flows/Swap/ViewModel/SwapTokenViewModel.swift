//
//  SwapTokenViewModel.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 7/3/23.
//

import Foundation

class SwapTokenViewModel {
	// MARK: - Public Properties

	public var swapDelegate: SwapDelegate!

	public let maxTitle = "Max: "
	public let avgSign = "≈"
	public var amountUpdated: ((String) -> Void)!
	public var textFieldPlaceHolder = "0"
	public var isEditing = false
	public var selectedToken: AssetViewModel
	@Published
	public var tokenAmount: String?
	public var dollarAmount: String?
	public var decimalDollarAmount: BigNumber?

	public var maxHoldAmount: String {
		selectedToken.amount
	}

	// MARK: - Initializers

	init(selectedToken: AssetViewModel) {
		self.selectedToken = selectedToken
	}

	// MARK: - Public Methods

	public func calculateDollarAmount(_ amount: String?) {
		if let amount, amount != .emptyString {
			tokenAmount = amount
			let price = selectedToken.price
			decimalDollarAmount = BigNumber(numberWithDecimal: amount) * price
			dollarAmount = decimalDollarAmount?.priceFormat
		} else {
			tokenAmount = nil
			decimalDollarAmount = nil
			dollarAmount = nil
		}
	}

	public func calculateTokenAmount(decimalDollarAmount: BigNumber?) {
		self.decimalDollarAmount = decimalDollarAmount
		dollarAmount = decimalDollarAmount?.priceFormat
		tokenAmount = convertDollarAmountToTokenAmount(dollarAmount: decimalDollarAmount)
	}

	public func checkBalanceStatus() -> AmountStatus {
		if let amount = tokenAmount, !BigNumber(numberWithDecimal: amount).isZero {
			let maxAmount = selectedToken.holdAmount
			let enteredAmount = BigNumber(numberWithDecimal: amount)
			if enteredAmount > maxAmount {
				return .isNotEnough
			} else {
				return .isEnough
			}
		} else {
			return .isZero
		}
	}

	// MARK: - Private Methods

	private func convertDollarAmountToTokenAmount(dollarAmount: BigNumber?) -> String? {
		if let dollarAmount {
			let tokenPrice = selectedToken.price
			let tokenAmount = dollarAmount / tokenPrice
			return tokenAmount?.sevenDigitFormat
		} else {
			return nil
		}
	}
}
