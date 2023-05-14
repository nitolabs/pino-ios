//
//  HomepageViewModel.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 12/19/22.
//

import Combine
import CoreData
import Foundation
import Network

class HomepageViewModel {
	// MARK: - Public Properties

	@Published
	public var walletInfo: WalletInfoViewModel!
	@Published
	public var walletBalance: WalletBalanceViewModel!
	@Published
	public var assetsList: [AssetViewModel]?
	@Published
	public var positionAssetsList: [AssetViewModel]!
	@Published
	public var securityMode = false
	@Published
	public var manageAssetsList: [AssetViewModel]?
	public var selectedAssets = [SelectedAsset]()
	@Published
	public var assetsModelList: [AssetProtocol]!

	public let copyToastMessage = "Copied!"
	public let connectionErrorToastMessage = "No internet connection"
	public let requestFailedErrorToastMessage = "Couldn't refresh home data"
	public let sendButtonTitle = "Send"
	public let receiveButtonTitle = "Receive"
	public let sendButtonImage = "arrow_up"
	public let receiveButtonImage = "arrow_down"

	// MARK: Internal Properties

	internal var cancellables = Set<AnyCancellable>()

	internal var walletAPIClient = WalletAPIMockClient()
	internal var accountingAPIClient = AccountingAPIClient()

	let coreDataStack = AppDelegate.sharedAppDelegate.coreDataStack
	let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext

	// MARK: - Initializers

	init() {
		getSelectedAssetsFromCoreData()
		getWalletInfo()
		getWalletBalance()
		getAssetsList()
		getPositionAssetsList()
		setupBindings()
	}

	// MARK: - Public Methods

	#warning("This function must be rafctored based on GCD")
	public func refreshHomeData(completion: @escaping (HomeRefreshError?) -> Void) {
		// This is temporary and must be replaced with network request
		let monitor = NWPathMonitor()
		monitor.pathUpdateHandler = { [weak self] path in
			if path.status == .satisfied {
				self?.getWalletBalance()
				self?.getAssetsList()
				self?.getPositionAssetsList()
				completion(nil)
				monitor.cancel()
			} else {
				completion(.networkConnection)
				monitor.cancel()
			}
		}
		monitor.start(queue: DispatchQueue.main)
	}

	// MARK: Private Methods

	private func setupBindings() {
		$securityMode.sink { [weak self] securityMode in
			guard let self = self else { return }
			if securityMode {
				self.enableSecurityMode()
			} else {
				self.disableSecurityMode()
			}
		}.store(in: &cancellables)

		$manageAssetsList.sink { assets in
			guard let assets else { return }
			self.assetsList = assets.filter { $0.isSelected }
		}.store(in: &cancellables)
	}
}
