//
//  WheelEligibility.swift
//  ServicesProvider
//
//  Created by André Lascas on 30/04/2025.
//

import Foundation

public struct WheelStatusResponse: Codable {
    public let status: String
    public let message: String?
    public let data: WheelEligibility?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
        case data = "data"
    }
}

public struct WheelEligibility: Codable {
    public let productCode: String
    public let gameTransId: String
    public let winBoosts: [WheelStatus]
    
    enum CodingKeys: String, CodingKey {
        case productCode = "productCode"
        case gameTransId = "gameTranId"
        case winBoosts = "winBoosts"
    }
}

public struct WheelStatus: Codable {
    public let winBoostId: String?
    public let gameTransId: String?
    public let status: String
    public let message: String?
    public let configuration: WheelConfiguration?
    
    enum CodingKeys: String, CodingKey {
        case winBoostId = "winBoostId"
        case gameTransId = "gameTranId"
        case status = "status"
        case message = "message"
        case configuration = "configuration"
    }
}

public struct WheelConfiguration: Codable {
    public var id: String
    public var title: String
    public var tiers: [WheelTier]
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case tiers = "tiers"
    }
}

public struct WheelTier: Codable {
    public var name: String
    public var chance: Double
    public var boostMultiplier: Double
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case chance = "chance"
        case boostMultiplier = "boostMultiplier"
    }
}

public struct WheelOptInData: Codable {
    public let status: String
    public let winBoostId: String?
    public let gameTranId: String?
    public let awardedTier: WheelAwardedTier?

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case winBoostId = "winBoostId"
        case gameTranId = "gameTranId"
        case awardedTier = "awardedTier"
    }
}

public struct WheelAwardedTier: Codable {
    public let configurationId: String?
    public let name: String
    public let boostMultiplier: Double
    
    enum CodingKeys: String, CodingKey {
        case configurationId = "configurationId"
        case name = "name"
        case boostMultiplier = "boostMultiplier"
    }
}

public struct GrantedWinBoostsResponse: Codable {
    public let status: String
    public let message: String?
    public let data: [GrantedWinBoosts]?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
        case data = "data"
    }
}

public struct GrantedWinBoosts: Codable {
    public let gameTranId: String
    public let winBoosts: [GrantedWinBoostInfo]
    
    enum CodingKeys: String, CodingKey {
        case gameTranId = "gameTranId"
        case winBoosts = "winBoosts"
    }
}

public struct GrantedWinBoostInfo: Codable {
    public let winBoostId: String
    public let gameTranId: String
    public let status: String
    public let awardedTier: WheelAwardedTier?
    public let boostAmount: Double?
    
    enum CodingKeys: String, CodingKey {
        case winBoostId = "winBoostId"
        case gameTranId = "gameTranId"
        case status = "status"
        case awardedTier = "awardedTier"
        case boostAmount = "boostAmount"
    }
}
