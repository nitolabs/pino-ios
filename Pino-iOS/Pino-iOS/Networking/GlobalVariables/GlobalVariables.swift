//
//  GlobalVariables.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 6/28/23.
//

import Combine
import Foundation
import PromiseKit

class GlobalVariables {
	// MARK: - Public Shared Accessor

	public static let shared = GlobalVariables()

	// MARK: - Public Properties

	@Published
    public var ethGasFee: GasInfo!
	@Published
	public var manageAssetsList: [AssetViewModel]?
	@Published
	public var selectedManageAssetsList: [AssetViewModel]?

	// MARK: - Private Properties

	private var cancellables = Set<AnyCancellable>()
	private var internetConnectivity = InternetConnectivity()

	// MARK: - Private Initializer

	private init() {
		fetchSharedInfoPeriodically { [self] in
			fetchSharedInfo().catch { error in
				#warning("Toast view is temporarily removed")
//				Toast.default(
//					title: GlobalErrors.connectionFailed.message,
//					subtitle: GlobalToastTitles.tryAgainToastTitle.message,
//					style: .error
//				)
//				.show(haptic: .warning)
			}
		}
		$manageAssetsList.sink { assets in
			guard var assets else { return }
			assets.sort { asset1, asset2 in
				asset1.holdAmountInDollor > asset2.holdAmountInDollor
			}
			self.selectedManageAssetsList = assets.filter { $0.isSelected }
		}.store(in: &cancellables)
	}

	public func fetchSharedInfo() -> Promise<Void> {
		print("== SENDING REQUEST ==")
		return firstly {
			getManageAssetLists()
		}.get { assets in
			self.manageAssetsList = assets
		}.then { assets in
			self.calculateEthGasFee()
		}
	}

	// MARK: - Private Methods

	private func isNetConnected() -> AnyPublisher<Bool, Error> {
		internetConnectivity.$isConnected.tryCompactMap { $0 }.eraseToAnyPublisher()
	}

	private func fetchSharedInfoPeriodically(completion: @escaping () -> Void) {
		Timer.publish(every: 11, on: .main, in: .common)
			.autoconnect()
			.sink { [self] seconds in
				isNetConnected().sink { _ in
				} receiveValue: { isConnected in
					if isConnected {
						completion()
					} else {
						#warning("Toast view is temporarily removed")
//						Toast.default(
//							title: GlobalErrors.connectionFailed.message,
//							subtitle: GlobalToastTitles.tryAgainToastTitle.message,
//							style: .error
//						)
//						.show(haptic: .warning)
					}
				}.store(in: &cancellables)
			}
			.store(in: &cancellables)
	}

	private func calculateEthGasFee() -> Promise<Void> {
		Web3Core.shared.calculateEthGasFee().done { gasInfo in
			GlobalVariables.shared.ethGasFee = gasInfo
		}
	}

	private func getManageAssetLists() -> Promise<[AssetViewModel]> {
		AssetManagerViewModel.shared.getAssetsList()
	}
}

// MARK: - GlobalVariales + Error

extension GlobalVariables {
	private enum GlobalErrors: LocalizedError {
		case connectionFailed
		case failedToFetchInfo

		var message: String {
			switch self {
			case .connectionFailed:
				return "No Internet Connection!"
			case .failedToFetchInfo:
				return "Failed to fetch info!"
			}
		}
	}
}
