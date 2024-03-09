//
//  SyncWalletViewModel.swift
//  Pino-iOS
//
//  Created by Amir hossein kazemi seresht on 1/1/24.
//

import Foundation
import PromiseKit

struct SyncWalletViewModel {
	// MARK: - Public Properties

	public let titleAnimationName = "SyncWallet"
	public let titleText = "Synchronizing..."
	public let descriptionText = "We are syncing your wallet data. This may take a few minutes."
	public let exploreTitleText = "Do you want to explore Pino in the meantime?"
	public let explorePinoButtonText = "Explore Pino"
	public var loadingTime: TimeInterval = 15

	public static var isSyncFinished: Bool {
		let syncFinishTime = UserDefaultsManager<Date>(userDefaultKey: .syncFinishTime).getValue()!
		if Date.now > syncFinishTime {
			return true
		} else {
			return false
		}
	}

	// MARK: - Initializers
}
