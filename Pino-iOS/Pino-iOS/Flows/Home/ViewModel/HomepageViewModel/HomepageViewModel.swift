//
//  HomepageViewModel.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 12/19/22.
//

import Combine
import CoreData
import Foundation
import Hyperconnectivity
import Network
import PromiseKit

class HomepageViewModel {
	// MARK: - Public Properties

	@Published
	public var walletInfo: AccountInfoViewModel!
	@Published
	public var walletBalance: WalletBalanceViewModel?
	@Published
	public var positionAssetsList: [AssetViewModel]?
	@Published
	public var securityMode = false

	public let copyToastMessage = "Copied!"
	public let sendButtonTitle = "Send"
	public let receiveButtonTitle = "Receive"
	public let sendButtonImage = "arrow_up"
	public let receiveButtonImage = "arrow_down"
	public let showBalanceButtonTitle = "Show balance"
	public let showBalanceButtonImage = "eye"

	// MARK: Internal Properties

	internal var internetConnectivity = InternetConnectivity()
	internal var cancellables = Set<AnyCancellable>()
	var subscriptions = Set<AnyCancellable>()
    private var assetManager = AssetManager()

	// MARK: - Initializers

	init() {
        assetManager.checkDefaultAssetsAdded()
        assetManager.getSelectedAssetsFromCoreData()
		getWalletInfo()
		setupBindings()
	}

	// MARK: Private Methods

	private func switchSecurityMode(_ isOn: Bool) {
		if let walletBalance {
			walletBalance.switchSecurityMode(isOn)
		}
        for asset in GlobalVariables.shared.selectedManageAssetsList {
            asset.switchSecurityMode(isOn)
        }
		if let positionAssetsList {
			for asset in positionAssetsList {
				asset.switchSecurityMode(isOn)
			}
		}
		positionAssetsList = positionAssetsList
	}

	private func setupBindings() {
		$securityMode.sink { [weak self] securityMode in
			guard let self = self else { return }
			self.switchSecurityMode(securityMode)
		}.store(in: &cancellables)

		GlobalVariables.shared.$manageAssetsList.sink { assets in
			guard let assets else { return }
            self.getWalletBalance(assets: assets)
		}.store(in: &cancellables)

	}
}
