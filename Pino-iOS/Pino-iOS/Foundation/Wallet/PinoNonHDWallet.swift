//
//  PinoNonHDWallet.swift
//  Pino-iOS
//
//  Created by Sobhan Eskandari on 4/25/23.
//

import Foundation
import WalletCore
import Web3Core

protocol PinoNonHDWalletType: PinoWallet {
	mutating func importAccount(privateKey: String) -> Result<Account, WalletOperationError>
}

public struct PinoNonHDWallet: PinoNonHDWalletType {
	// MARK: - Private Properties

	private var secureEnclave = SecureEnclave()

	// MARK: - Public Properties

	public var accounts: [Account] {
		getAllAccounts()
	}

	// MARK: - Public Methods

	public mutating func importAccount(privateKey: String) -> Result<Account, WalletOperationError> {
		do {
			let keyData = Data(hexString: privateKey)!
			var account = try Account(privateKeyData: keyData)
			guard !accountExist(account: account) else { return .success(account) }
			account.isActiveAccount = true
			let keyCipherData = secureEnclave.encrypt(
				plainData: keyData,
				withPublicKeyLabel: KeychainManager.privateKey.getKey(account.eip55Address)
			)
			if !KeychainManager.privateKey.setValue(
				value: keyCipherData,
				key: KeychainManager.privateKey.getKey(account.eip55Address)
			) {
				return .failure(.wallet(.importAccountFailed))
			}
			return .success(account)
		} catch {
			return .failure(.wallet(.importAccountFailed))
		}
	}
}
