//
//  SwapViewModel.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 7/3/23.
//

import Foundation

class SwapViewModel {
	// MARK: - Public Properties

	@Published
	public var selectedProtocol: SwapProtocolModel

	public let continueButtonTitle = "Swap"
	public let insufficientAmountButtonTitle = "Insufficient amount"
	public let switchIcon = "switch_swap"

	public var fromToken: SwapTokenViewModel
	public var toToken: SwapTokenViewModel

	public var swapFeeVM: SwapFeeViewModel

	// MARK: - Initializers

	init(fromToken: AssetViewModel, toToken: AssetViewModel) {
		self.selectedProtocol = .bestRate
		self.fromToken = SwapTokenViewModel(selectedToken: fromToken)
		self.toToken = SwapTokenViewModel(selectedToken: toToken)
		self.swapFeeVM = SwapFeeViewModel()

		self.fromToken.amountUpdated = { amount in
			self.recalculateTokensAmount(amount: amount)
		}
		self.toToken.amountUpdated = { amount in
			self.recalculateTokensAmount(amount: amount)
		}
		getFeeInfo()
	}

	// MARK: - Private Methods

	private func recalculateTokensAmount(amount: String? = nil) {
		if toToken.isEditing {
			toToken.calculateDollarAmount(amount ?? toToken.tokenAmount)
			fromToken.calculateTokenAmount(decimalDollarAmount: toToken.decimalDollarAmount)
			fromToken.swapDelegate.swapAmountCalculating()
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
				self.fromToken.swapDelegate.swapAmountDidCalculate()
			}
		} else if fromToken.isEditing {
			fromToken.calculateDollarAmount(amount ?? fromToken.tokenAmount)
			toToken.calculateTokenAmount(decimalDollarAmount: fromToken.decimalDollarAmount)
			toToken.swapDelegate.swapAmountCalculating()
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
				self.toToken.swapDelegate.swapAmountDidCalculate()
			}
		}
		updateCalculatedAmount()
		getFeeInfo()
	}

	private func updateCalculatedAmount() {
		if let fromTokenAmount = fromToken.formattedTokenAmount, let toTokenAmount = toToken.formattedTokenAmount {
			swapFeeVM.calculatedAmount = "\(fromTokenAmount) = \(toTokenAmount)"
		} else {
			swapFeeVM.calculatedAmount = nil
		}
	}

	private func getFeeInfo() {
		swapFeeVM.fee = nil
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
			if self.selectedProtocol == .bestRate {
				self.showBestProviderFeeInfo()
			} else {
				self.showPriceImpactFeeInfo()
			}
			self.swapFeeVM.fee = self.getfee()
		}
	}

	// MARK: - Public Methods

	public func changeSelectedToken(_ token: SwapTokenViewModel, to newToken: AssetViewModel) {
		if !fromToken.isEditing, !toToken.isEditing {
			token.isEditing = true
		}
		token.selectedToken = newToken
		recalculateTokensAmount()
		token.swapDelegate.selectedTokenDidChange()
	}

	public func switchTokens() {
		let selectedFromToken = fromToken.selectedToken
		fromToken.selectedToken = toToken.selectedToken
		toToken.selectedToken = selectedFromToken

		let fromTokenAmount = fromToken.tokenAmount
		fromToken.tokenAmount = toToken.tokenAmount
		toToken.tokenAmount = fromTokenAmount

		recalculateTokensAmount()

		fromToken.swapDelegate.selectedTokenDidChange()
		toToken.swapDelegate.selectedTokenDidChange()
	}

	public func changeSwapProtocol(to swapProtocol: SwapProtocolModel) {
		selectedProtocol = swapProtocol
		if swapProtocol == .bestRate {
			swapFeeVM.swapProviderVM = getBestProvider()
		}
		getFeeInfo()
	}

	public func changeSwapProvider(to swapProvider: SwapProviderViewModel) {
		swapFeeVM.swapProviderVM = swapProvider
		getFeeInfo()
	}

	// MARK: - Private Methods

	private func showBestProviderFeeInfo() {
		let saveAmount = getSaveAmount()
		swapFeeVM.saveAmount = saveAmount
		swapFeeVM.feeTag = getFeeTag(saveAmount: saveAmount)
		swapFeeVM.priceImpact = nil
		if swapFeeVM.swapProviderVM == nil {
			swapFeeVM.swapProviderVM = getBestProvider()
		}
	}

	private func showPriceImpactFeeInfo() {
		let priceImpact = getPriceImpact()
		swapFeeVM.priceImpact = priceImpact
		swapFeeVM.feeTag = getFeeTag(priceImpact: priceImpact)
		swapFeeVM.swapProviderVM = nil
		swapFeeVM.saveAmount = nil
	}

	#warning("These values are temporary and must be replaced with network data")

	private func getBestProvider() -> SwapProviderViewModel {
		SwapProviderViewModel(provider: .oneInch, swapAmount: "")
	}

	private func getfee() -> String {
		"0.001"
	}

	private func getSaveAmount() -> String {
		"1"
	}

	private func getPriceImpact() -> String {
		"2"
	}

	private func getFeeTag(saveAmount: String) -> SwapFeeViewModel.FeeTag {
		if let saveAmountDecimalNumber = Decimal(string: saveAmount), saveAmountDecimalNumber > 0 {
			return .save("$\(saveAmount) \(swapFeeVM.celebrateEmoji)")
		} else {
			return .none
		}
	}

	private func getFeeTag(priceImpact: String) -> SwapFeeViewModel.FeeTag {
		if let priceImpactDecimalNumber = Decimal(string: priceImpact), priceImpactDecimalNumber > 1 {
			return .highImpact
		} else {
			return .none
		}
	}
}
