//
//  GlobalVariables.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 6/28/23.
//

import Foundation
import PromiseKit
import Combine

class GlobalVariables {
    
    // MARK: - Public Accessor

	public static let shared = GlobalVariables()

    // MARK: - Public Properties

	@Published
	public var ethGasFee = (fee: BigNumber(number: "0", decimal: 0), feeInDollar: BigNumber(number: "0", decimal: 0))
    @Published
    public var tokens: [Detail]?

    // MARK: - Private Properties
    private var accountingAPIClient = AccountingAPIClient()
    private var ctsAPIclient = CTSAPIClient()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Private Initializer

	private init() {}
    
    
    // MARK: - Private Methods

    private func calculateEthGasFee(ethPrice: BigNumber) -> Promise<String> {
        Promise<String> { seal in
            _ = Web3Core.shared.calculateEthGasFee(ethPrice: ethPrice).done { fee, feeInDollar in
                GlobalVariables.shared.ethGasFee = (fee, feeInDollar)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    private func getAssetsList(completion: @escaping (Result<[AssetViewModel], APIError>) -> Void) {
        if let tokens {
            accountingAPIClient.userBalance()
                .sink { completed in
                    switch completed {
                    case .finished:
                        print("Assets received successfully")
                    case let .failure(error):
                        completion(.failure(error))
                    }
                } receiveValue: { assets in
                    self.manageAssetsList = self.getManageAsset(tokens: tokens, userAssets: assets)
                    completion(.success(self.manageAssetsList!))
                }.store(in: &cancellables)
        } else {
            getTokens { result in
                switch result {
                case .success:
                    self.getAssetsList(completion: completion)
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func getTokens(completion: @escaping (Result<[Detail], APIError>) -> Void) {
        ctsAPIclient.tokens().sink { completed in
            switch completed {
            case .finished:
                print("tokens received successfully")
            case let .failure(error):
                completion(.failure(error))
            }
        } receiveValue: { tokens in
            let customAssets = self.getCustomAssets()
            self.tokens = tokens + customAssets
            completion(.success(self.tokens!))
        }.store(in: &cancellables)
    }
    
}
