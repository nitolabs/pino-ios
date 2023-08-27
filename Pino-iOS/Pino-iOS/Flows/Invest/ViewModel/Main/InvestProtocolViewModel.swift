//
//  InvestProtocolViewModel.swift
//  Pino-iOS
//
//  Created by Mohi Raoufi on 8/14/23.
//

import Foundation

public enum InvestProtocolViewModel: String, DexSystemModelProtocol {
	case uniswap = "uniswap"
	case compound = "compound"
	case aave = "aave"
	case balancer = "balancer"

	public var name: String {
		switch self {
		case .uniswap:
			return "Uniswap"
		case .compound:
			return "Compound"
		case .aave:
			return "Aave"
		case .balancer:
			return "Balancer"
		}
	}

	public var image: String {
		switch self {
		case .uniswap:
			return "uniswap_protocol"
		case .compound:
			return "compound"
		case .aave:
			return "aave"
		case .balancer:
			return "balancer_protocol"
		}
	}

	public var description: String {
		switch self {
		case .uniswap:
			return "uniswap.org"
		case .compound:
			return "compound.finance"
		case .aave:
			return "aave.com"
		case .balancer:
			return "balancer.fi"
		}
	}

	public var type: String {
		rawValue
	}

	public init(type: String) {
		self.init(rawValue: type)!
	}
}
