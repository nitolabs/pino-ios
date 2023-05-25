// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let balanceModel = try? JSONDecoder().decode(BalanceModel.self, from: jsonData)

import Foundation

// MARK: - BalanceModelElement

struct BalanceAssetModel: Codable, AssetProtocol {
	let id, amount: String
	let isVerified: Bool
	let detail: Detail?

	enum CodingKeys: String, CodingKey {
		case id
		case amount
		case isVerified = "is_verified"
		case detail
	}
}

// MARK: - Detail

public struct Detail: Codable {
	let id, symbol, name, logo: String
	let decimals: Int
	let change24H, changePercentage, price: String

	enum CodingKeys: String, CodingKey {
		case id
		case symbol
		case name
		case logo
		case decimals
		case change24H = "change_24h"
		case changePercentage = "change_percentage"
		case price
	}
}

typealias BalanceModel = [BalanceAssetModel]
