//
//  BorrowableAssetViewModel.swift
//  Pino-iOS
//
//  Created by Amir hossein kazemi seresht on 8/24/23.
//

import Foundation

struct BorrowableAssetViewModel: AssetsBoardProtocol {
	// MARK: - Private Properties

	private var borrowableTokenModel: BorrowableTokenDetailsModel

	// MARK: - Public Properties

	public var assetName: String {
		foundTokenInManageAssetTokens.symbol
	}

	public var assetImage: URL {
		foundTokenInManageAssetTokens.image
	}

	public var APYAmount: BigNumber {
		borrowableTokenModel.apy.bigNumber
	}

	public var formattedAPYAmount: String {
		"%\(APYAmount.percentFormat)"
	}

	public var volatilityType: AssetVolatilityType {
		AssetVolatilityType(change24h: APYAmount)
	}

	public var foundTokenInManageAssetTokens: AssetViewModel {
		(GlobalVariables.shared.manageAssetsList?.first(where: { $0.id == borrowableTokenModel.tokenID }))!
	}

	// MARK: - Initializers

	init(borrowableTokenModel: BorrowableTokenDetailsModel) {
		self.borrowableTokenModel = borrowableTokenModel
	}
}
