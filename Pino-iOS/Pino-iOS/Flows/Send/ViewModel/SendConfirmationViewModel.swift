//
//  SendConfirmationViewModel.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 6/17/23.
//

import Foundation

struct SendConfirmationViewModel {
	// MARK: - Private Properties

	private let selectedToken: AssetViewModel
	private let selectedWallet: AccountInfoViewModel
	private let sendAmount: String
	private let sendAmountInDollar: String?

	// MARK: - Public Properties

	public let recipientAddress: String

	public var tokenImage: URL {
		selectedToken.image
	}

	public var customAssetImage: String {
		selectedToken.customAssetImage
	}

	public var formattedSendAmount: String {
		"\(sendAmount) \(selectedToken.symbol)"
	}

	public var formattedSendAmountInDollar: String? {
		"$\(sendAmount)"
	}

	public var selectedWalletImage: String {
		selectedWallet.profileImage
	}

	public var selectedWalletName: String {
		selectedWallet.name
	}

	public var fee: String {
		"$0.3 / 0.00021 \(selectedToken.symbol)"
	}

	public var selectedWalletTitle = "From"
	public var recipientAddressTitle = "To"
	public var feeTitle = "Fee"

	init(
		selectedToken: AssetViewModel,
		selectedWallet: AccountInfoViewModel,
		recipientAddress: String,
		sendAmount: String,
		sendAmountInDollar: String?
	) {
		self.selectedToken = selectedToken
		self.selectedWallet = selectedWallet
		self.sendAmount = sendAmount
		self.sendAmountInDollar = sendAmountInDollar
		self.recipientAddress = recipientAddress
	}
}
