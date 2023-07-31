//
//  SwapPriceRequestModel.swift
//  Pino-iOS
//
//  Created by Sobhan Eskandari on 7/29/23.
//

import Foundation

struct SwapPriceRequestModel {
    
    var srcToken: String
    let srcDecimals: Int?
    let destToken: String
    let destDecimals: Int?
    let amount: String
    let side: SwapSide
    let networkID: Int?
    
    public static let paraSwapETHID: String = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"
    public static let oneInchETHID: String = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"
    public static let zeroXETHID: String = "ETH"
    public static let pinoETHID: String = "0x0000000000000000000000000000000000000000"
    
    // Initializer for ParaSwap
    init(srcToken: String, srcDecimals: Int, destToken: String, destDecimals: Int, amount: String, side: SwapSide) {
        self.srcToken = srcToken
        self.srcDecimals = srcDecimals
        self.destToken = destToken
        self.destDecimals = destDecimals
        self.amount = amount
        self.side = side
        self.networkID = 1
    }
    
    // Initliazer for 1Inch and 0x
    init(srcToken: String, destToken: String, amount: String, side: SwapSide) {
        self.srcToken = srcToken
        self.srcDecimals = nil
        self.destToken = destToken
        self.destDecimals = nil
        self.amount = amount
        self.side = side
        self.networkID = nil
    }
    
    public var paraSwapURLParams: HTTPParameters {
        [
            "srcToken": srcToken,
            "srcDecimals": srcDecimals!,
            "destToken": destToken,
            "destDecimals": destDecimals!,
            "amount": amount,
            "side": side.rawValue,
            "network": networkID!,
        ]
    }
    
    public var OneInchSwapURLParams: HTTPParameters {
        [
            "src": srcToken,
            "dst": destToken,
            "amount": amount,
            "includeProtocols": "false",
            "includeTokensInfo": "false",
            "includeGas": "true",
        ]
    }
    
    public var ZeroXSwapURLParams: HTTPParameters {
        var params = [
            "sellToken": srcToken,
            "buyToken": destToken,
        ] as HTTPParameters
        if side == .sell {
            params["sellAmount"] = amount
        } else {
            params["buyAmount"] = amount
        }
        return params
    }
}
