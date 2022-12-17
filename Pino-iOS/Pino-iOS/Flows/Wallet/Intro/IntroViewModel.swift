//
//  IntroViewModel.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 12/11/22.
//
// swiftlint: disable trailing_comma

struct IntroViewModel {
	// MARK: Public Properties

	public var contentList: [IntroModel]!
	public let createButtonTitle = "Create new wallet"
	public let importButtonTitle = "I already have a wallet"

	// MARK: Initializers

	init() {
		setupIntroContentList()
	}

	// MARK: - Private Methods

	private mutating func setupIntroContentList() {
		contentList = [
			IntroModel(
				image: "",
				title: "DeFi Hub",
				description: "Invest, borrow, and swap from top DeFi protocols smoothly."
			),
			IntroModel(
				image: "",
				title: "DeFi Hub",
				description: "Invest, borrow, and swap from top DeFi protocols smoothly."
			),
			IntroModel(
				image: "",
				title: "DeFi Hub",
				description: "Invest, borrow, and swap from top DeFi protocols smoothly."
			),
		]
	}
}
