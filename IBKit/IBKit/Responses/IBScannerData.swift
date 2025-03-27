//
//  IBScannerData.swift
//  IBKit
//
//  Created by Mike Holman on 10/01/2025.
//

import Foundation

/// https://www.interactivebrokers.com/campus/ibkr-api-page/twsapi-doc/#receive-scanner-subscription
public struct IBScannerData: IBResponse, IBIndexedEvent {
    
    public var requestID: Int
    
    public var rank: Int
    
    public var contractDetails: IBContractDetails
    
    public var distance: String // IB internal use only
    
    public var benchmark: String // IB internal use only
    
    public var projection: String // IB internal use only
    
    public var legStr: String
    
    public init(from decoder: IBDecoder) throws {
        var container = try decoder.unkeyedContainer()
        requestID = try container.decode(Int.self)
        rank = try container.decode(Int.self)
        contractDetails = try container.decode(IBContractDetails.self)
        distance = try container.decode(String.self)
        benchmark = try container.decode(String.self)
        projection = try container.decode(String.self)
        legStr = try container.decode(String.self)
    }
    
}
