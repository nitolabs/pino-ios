//
//  CoinInfoViewModel.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 2/17/23.
//

import Combine
import Foundation
import Network

class CoinInfoViewModel {
	// MARK: - Public Properties

	public let homeVM: HomepageViewModel
	public let selectedAsset: AssetViewModel

	@Published
	public var coinPortfolio: CoinPortfolioViewModel!
	@Published
	public var coinHistoryList: [CoinHistoryViewModel]!

	public let requestFailedErrorToastMessage = "Couldn't refresh coin data"
	public let connectionErrorToastMessage = "No internet connection"
	public let infoActionSheetTitle = "Price impact"
	public let infoActionSheetDescription =
		"The difference between the market price and the estimated price based on your order size."
	public let websiteTitle = "Website"
	public let priceTitle = "Price"
	public let contractAddressTitle = "Contract address"
	public let protocolTitle = "Protocol"
	public let positionTitle = "Position"
	public let assetTitle = "Asset"
	public let recentHistoryTitle = "Recent history"
	public let tooltipIconName = "info"
	public let positionAssetTitle = "Position asset"
	public let priceSepratorText = "|"
	public let noUserAmountInDollarText = "--"
	public let unverifiedAssetIcon = "unverified_asset"
	public let noAssetPriceText = "-"
	public let unavailableRecentHistoryText = "The history are only available for verified assets!"
	public let unavailableRecentHistoryIconName = "gray_error_alert"

	#warning("this text is for testing and should be removed")
	public let positionAssetInfoText = """
	This asset represents your DAI collateral
	 position in the Compound Protocol. Note that
	 transferring this asset to another address will
	 fully transfer your position to the new
	 address.
	"""

	// MARK: - Private Properties

	private var assetsAPIClient = AssetsAPIMockClient()
	private var cancellables = Set<AnyCancellable>()

	// MARK: - Inintializers

	init(homeVM: HomepageViewModel, selectedAsset: AssetViewModel) {
		self.homeVM = homeVM
		self.selectedAsset = selectedAsset
		getCoinPortfolio()
		getHistoryList()
	}

	// MARK: - public Methods

	public func refreshCoinInfoData(completion: @escaping (APIError?) -> Void) {
		coinPortfolio.showSkeletonLoading = true
		getHistoryList()
		homeVM.getHomeData(completion: { _ in
			completion(nil)
		})
	}

	// MARK: - private Methods

	private func getCoinPortfolio() {
		coinPortfolio = CoinPortfolioViewModel(coinPortfolioModel: selectedAsset.assetModel)
	}

	private func getHistoryList() {
		assetsAPIClient.coinHistory().sink { completed in
			switch completed {
			case .finished:
				print("Coin history received successfully")
			case let .failure(error):
				print(error)
			}
		} receiveValue: { [weak self] coinHistoryModelList in
			self?.coinHistoryList = coinHistoryModelList.compactMap { CoinHistoryViewModel(coinHistoryModel: $0) }
			#warning(
				"this line is for testing because these two publishers were pinned to each other and their value should be changed together"
			)
			self?.coinHistoryList.removeLast()
		}.store(in: &cancellables)
	}
}
