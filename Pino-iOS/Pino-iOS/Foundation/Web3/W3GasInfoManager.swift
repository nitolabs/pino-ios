//
//  W3GasInfoManager.swift
//  Pino-iOS
//
//  Created by Sobhan Eskandari on 8/19/23.
//

import BigInt
import Foundation
import PromiseKit
import Web3
import Web3ContractABI

public struct W3GasInfoManager {
	// MARK: - Initilizer

	public init(web3: Web3) {
		self.web3 = web3
	}

	// MARK: - Private Properties

	private let web3: Web3!
	private var transactionManager: W3TransactionManager {
		.init(web3: web3)
	}

	private var gasInfoManager: W3GasInfoManager {
		.init(web3: web3)
	}

	private var walletManager = PinoWalletManager()
	private let pinoProxyAdd = Web3Core.Constants.pinoProxyAddress

	// MARK: - Public Methods

	public func calculateGasOf(
		method: ABIMethodWrite,
		solInvoc: SolidityInvocation,
		contractAddress: EthereumAddress
	) -> Promise<GasInfo> {
		Promise<GasInfo>() { seal in
			let myPrivateKey = try EthereumPrivateKey(hexPrivateKey: walletManager.currentAccountPrivateKey.string)

			firstly {
				web3.eth.gasPrice()
			}.then { gasPrice in
				web3.eth.getTransactionCount(address: myPrivateKey.address, block: .latest).map { ($0, gasPrice) }
			}.then { nonce, gasPrice in
				try transactionManager.createTransactionFor(
					contract: solInvoc,
					nonce: nonce,
					gasPrice: gasPrice,
					gasLimit: nil
				).promise.map { ($0, nonce, gasPrice) }
			}.then { transaction, nonce, gasPrice in

				web3.eth.estimateGas(call: .init(
					from: transaction.from,
					to: transaction.to!,
					gas: gasPrice, value: nil, data: transaction.data
				)).map { ($0, nonce, gasPrice) }

			}.done { gasLimit, nonce, gasPrice in
				let gasInfo =
                GasInfo(gasPrice: gasPrice.quantity,
                        gasLimit: BigNumber(unSignedNumber: try! BigUInt(gasLimit), decimal: 0))
				seal.fulfill(gasInfo)
			}.catch { error in
				seal.reject(error)
			}
		}
	}

	public func calculateEthGasFee() -> Promise<GasInfo> {
		Promise<GasInfo>() { seal in
			attempt(maximumRetryCount: 3) { [self] in
				web3.eth.gasPrice()
			}.done { gasPrice in
				let gasLimit = BigNumber(number: Web3Core.Constants.ethGasLimit, decimal: 0)
				let gasInfo = GasInfo(gasPrice: gasPrice.quantity, gasLimit: gasLimit)
                print(gasPrice)
                print(gasLimit)
				seal.fulfill(gasInfo)
			}.catch { error in
				seal.reject(error)
			}
		}
	}

	public func calculateSendERCGasFee(
		recipient: String,
		amount: BigUInt,
		tokenContractAddress: String
	) -> Promise<GasInfo> {
		Promise<GasInfo>() { seal in
			firstly {
				let contract = try Web3Core.getContractOfToken(address: tokenContractAddress, abi: .erc, web3: web3)
				let solInvocation = contract[ABIMethodWrite.transfer.rawValue]!(recipient.eip55Address!, amount)
				return gasInfoManager.calculateGasOf(
					method: .transfer,
					solInvoc: solInvocation,
					contractAddress: contract.address!
				)
			}.done { trxGasInfo in
				seal.fulfill(trxGasInfo)
			}.catch { error in
				seal.reject(error)
			}
		}
	}
}
