//
//  WalletViewModel.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 2/13/23.
//

import Combine
import Foundation

class WalletsViewModel {
	// MARK: - Public Properties

	@Published
	public var walletsList: [WalletInfoViewModel]!

	// MARK: - Private Properties

	private var walletAPIClient = WalletAPIMockClient()
	private var cancellables = Set<AnyCancellable>()

	// MARK: - Initializers

	init() {
		getWallets()
	}

	// MARK: - Public Methods

	public func updateSelectedWallet(with selectedWallet: WalletInfoViewModel) {
		for index in 0 ..< walletsList.count {
			if walletsList[index].id == selectedWallet.id {
				walletsList[index].isSelected(true)
			} else {
				walletsList[index].isSelected(false)
			}
		}
		walletsList = walletsList
		saveWalletsInUserDefaults(walletsList)
	}

	public func editWallet(id: String, newName: String?, newImage: String?, newColor: String?) {
		guard let walletIndex = walletsList.firstIndex(where: { $0.id == id })
		else { fatalError("No wallet found with this ID") }
		let editedWalletModel = WalletInfoModel(
			id: id,
			name: newName ?? walletsList[walletIndex].name,
			address: walletsList[walletIndex].address,
			profileImage: newImage ?? walletsList[walletIndex].profileImage,
			profileColor: newColor ?? walletsList[walletIndex].profileColor,
			balance: walletsList[walletIndex].walletInfoModel.balance,
			isSelected: walletsList[walletIndex].isSelected
		)
		let editedWalletViewModel = WalletInfoViewModel(walletInfoModel: editedWalletModel)
		walletsList[walletIndex] = editedWalletViewModel
		saveWalletsInUserDefaults(walletsList)
	}

	// MARK: - Private Methods

	private func getWallets() {
		// Request to get wallets
		let walletsModel = getWalletsFromUserDefaults()
		walletsList = walletsModel.compactMap { WalletInfoViewModel(walletInfoModel: $0) }
	}

	public func getWalletsFromUserDefaults() -> [WalletInfoModel] {
		guard let encodedWallets = UserDefaults.standard.data(forKey: "wallets") else {
			fatalError("No wallet found in user defaults")
		}
		do {
			return try JSONDecoder().decode([WalletInfoModel].self, from: encodedWallets)
		} catch {
			fatalError(error.localizedDescription)
		}
	}

	private func saveWalletsInUserDefaults(_ wallets: [WalletInfoViewModel]) {
		let walletsModel = wallets.compactMap { $0.walletInfoModel }
		do {
			let encodedWallets = try JSONEncoder().encode(walletsModel)
			UserDefaults.standard.set(encodedWallets, forKey: "wallets")
		} catch {
			fatalError(error.localizedDescription)
		}
	}
}
