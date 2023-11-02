//
//  Web3ABI.swift
//  Pino-iOS
//
//  Created by Sobhan Eskandari on 6/14/23.
//

import Foundation

public enum Web3ABI {
	case erc
	case swap
	case invest
	case borrowERCAave
	case borrowETHAave
	case borrowCTokenCompound
	case aaveProxy

	public var abi: Data {
		switch self {
		case .erc:
			return Web3ABI.erc20AbiString.data(using: .utf8)!
		case .swap:
			return Web3ABI.swapAbiString.data(using: .utf8)!
		case .invest:
			return Web3ABI.investAbiString.data(using: .utf8)!
		case .borrowERCAave:
			return Web3ABI.borrowERCAaveAbiString.data(using: .utf8)!
		case .borrowETHAave:
			return Web3ABI.borrowETHAaveAbiString.data(using: .utf8)!
		case .borrowCTokenCompound:
			return Web3ABI.borrowCompoundCTokenAbiString.data(using: .utf8)!
		case .aaveProxy:
			return Web3ABI.aaveProxyAbiString.data(using: .utf8)!
		}
	}

	private static var erc20AbiString: String {
		ABIReader(fileName: "ERC20ABIJson")
	}

	private static var swapAbiString: String {
		ABIReader(fileName: "SwapABIJson")
	}

	private static var borrowERCAaveAbiString: String {
		ABIReader(fileName: "BorrowERCAaveABIJson")
	}

	private static var borrowETHAaveAbiString: String {
		ABIReader(fileName: "BorrowETHAaveABIJson")
	}

	private static var borrowCompoundCTokenAbiString: String {
		ABIReader(fileName: "BorrowCompoundCTokenABIJson")
	}

	private static var aaveProxyAbiString: String {
		ABIReader(fileName: "AaveProxyABIJson")
	}

	private static var investAbiString: String {
		let path = Bundle.main.path(forResource: "InvestABIJson", ofType: "json")!
		let abiJsonString = try! String(contentsOfFile: path, encoding: .utf8)
		return abiJsonString
	}
}

public enum ABIMethodCall: String {
	case decimal = "decimals"
	case balance = "balanceOf"
	case name
	case symbol
	case allowance
	case approve
}

public enum ABIMethodWrite: String {
	case approve
	case approveToken
	case transfer
	case permitTransferFrom
	case sweepToken
	case unwrapWETH9
	case wrapETH
	case multicall
	case swapZeroX
	case swapParaSwap
	case swapOneInch
	case daiToSDai
	case sDaiToDai
	case borrow
	case borrowETH
	case depositV3
}

fileprivate func ABIReader(fileName: String) -> String {
	let path = Bundle.main.path(forResource: fileName, ofType: "json")!
	let abiString = try! String(contentsOfFile: path, encoding: .utf8)
	return abiString
}
