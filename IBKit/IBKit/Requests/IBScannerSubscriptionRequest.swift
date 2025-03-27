//
//  IBScannerSubscriptionRequest.swift
//  IBKit
//
//  Created by Mike Holman on 10/01/2025.
//

import Foundation

public struct IBScannerSubscription: IBEncodable {
    public let numberOfRows: Int = -1
    public let instrument: String
    public let locationCode: String
    public let scanCode: String
    public let abovePrice: Double
    public let belowPrice: Double
    public let aboveVolume: Int
    public let averageOptionVolumeAbove: Int
    public let marketCapAbove: Double
    public let marketCapBelow: Double
    public let moodyRatingAbove: String
    public let moodyRatingBelow: String
    public let spRatingAbove: String
    public let spRatingBelow: String
    public let maturityDateAbove: String
    public let maturityDateBelow: String
    public let couponRateAbove: Double
    public let couponRateBelow: Double
    public let excludeConvertible: Int
    public let scannerSettingPairs: String
    public let stockTypeFilter: String
    
    public func encode(to encoder: IBEncoder) throws {
        
        guard let serverVersion = encoder.serverVersion else {
            throw IBClientError.encodingError("Server value expected")
        }

        var container = encoder.unkeyedContainer()
        
        try container.encode(numberOfRows)
        try container.encode(instrument)
        try container.encode(locationCode)
        try container.encode(scanCode)
        try container.encode(abovePrice)
        try container.encode(belowPrice)
        try container.encode(aboveVolume)
        try container.encode(marketCapAbove)
        try container.encode(marketCapBelow)
        try container.encode(moodyRatingAbove)
        try container.encode(moodyRatingBelow)
        try container.encode(spRatingAbove)
        try container.encode(spRatingBelow)
        try container.encode(maturityDateAbove)
        try container.encode(maturityDateBelow)
        try container.encode(couponRateAbove)
        try container.encode(couponRateBelow)
        try container.encode(excludeConvertible)
        try container.encode(averageOptionVolumeAbove)
        try container.encode(scannerSettingPairs)
        try container.encode(stockTypeFilter)
    }
}


/// https://www.interactivebrokers.com/campus/ibkr-api-page/twsapi-doc/#request-scanner-subscription
public struct IBScannerSubscriptionRequest: IBIndexedRequest, Hashable, Equatable {
    public let version: Int = 4
    public var requestID: Int
    public var type: IBRequestType = .scannerSubscription
    public var subscription: IBScannerSubscription
    public var scannerSubscriptionOptions: [String] = [] // for IB internal use only
    public var scannerSubscriptionFilterOptions: String

    public init(requestID: Int, subscription: String, scannerSubscriptionFilterOptions: String) {
        self.requestID = requestID
        self.subscription = IBScannerSubscription(instrument: "STK", locationCode: "STK.US.MAJOR", scanCode: "HOT_BY_VOLUME", abovePrice: Double.greatestFiniteMagnitude, belowPrice: Double.greatestFiniteMagnitude, aboveVolume: Int.max, averageOptionVolumeAbove: Int.max, marketCapAbove: Double.greatestFiniteMagnitude, marketCapBelow: Double.greatestFiniteMagnitude, moodyRatingAbove: "", moodyRatingBelow: "", spRatingAbove: "", spRatingBelow: "", maturityDateAbove: "", maturityDateBelow: "", couponRateAbove: Double.greatestFiniteMagnitude, couponRateBelow: Double.greatestFiniteMagnitude, excludeConvertible: Int.max, scannerSettingPairs: "", stockTypeFilter: "")
        self.scannerSubscriptionFilterOptions = scannerSubscriptionFilterOptions
    }

    
    public func encode(to encoder: IBEncoder) throws {
        
        guard let serverVersion = encoder.serverVersion else {
            throw IBClientError.encodingError("Server value expected")
        }

        var container = encoder.unkeyedContainer()
        
        try container.encode(type)
        try container.encode(requestID)
        try container.encode(version)
        try container.encode(subscription)
        encoder.wrapNil()
        try container.encode(scannerSubscriptionFilterOptions)
    }
    
}

/// https://www.interactivebrokers.com/campus/ibkr-api-page/twsapi-doc/#cancel-scanner-subscription
public struct IBScannerCancellationRequest: IBIndexedRequest{
    public let version: Int = 2
    public let type: IBRequestType = .cancelScannerSubscription
    public var requestID: Int
    
    public init(requestID: Int) {
        self.requestID = requestID
    }
    
    public func encode(to encoder: IBEncoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(type)
        try container.encode(version)
        try container.encode(requestID)
    }
}

