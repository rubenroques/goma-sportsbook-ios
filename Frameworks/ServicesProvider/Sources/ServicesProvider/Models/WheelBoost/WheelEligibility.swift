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
    
    public init(status: String, message: String?, data: WheelEligibility?) {
        self.status = status
        self.message = message
        self.data = data
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
    
    public init(productCode: String, gameTransId: String, winBoosts: [WheelStatus]) {
        self.productCode = productCode
        self.gameTransId = gameTransId
        self.winBoosts = winBoosts
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
    
    public init(winBoostId: String?, gameTransId: String?, status: String, message: String?, configuration: WheelConfiguration?) {
        self.winBoostId = winBoostId
        self.gameTransId = gameTransId
        self.status = status
        self.message = message
        self.configuration = configuration
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
    
    public init(id: String, title: String, tiers: [WheelTier]) {
        self.id = id
        self.title = title
        self.tiers = tiers
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
    
    public init(name: String, chance: Double, boostMultiplier: Double) {
        self.name = name
        self.chance = chance
        self.boostMultiplier = boostMultiplier
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
    
    public init(status: String, winBoostId: String?, gameTranId: String?, awardedTier: WheelAwardedTier?) {
        self.status = status
        self.winBoostId = winBoostId
        self.gameTranId = gameTranId
        self.awardedTier = awardedTier
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
    
    public init(configurationId: String?, name: String, boostMultiplier: Double) {
        self.configurationId = configurationId
        self.name = name
        self.boostMultiplier = boostMultiplier
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
    
    public init(status: String, message: String?, data: [GrantedWinBoosts]?) {
        self.status = status
        self.message = message
        self.data = data
    }
}

public struct GrantedWinBoosts: Codable {
    public let gameTranId: String
    public let winBoosts: [GrantedWinBoostInfo]
    
    enum CodingKeys: String, CodingKey {
        case gameTranId = "gameTranId"
        case winBoosts = "winBoosts"
    }
    
    public init(gameTranId: String, winBoosts: [GrantedWinBoostInfo]) {
        self.gameTranId = gameTranId
        self.winBoosts = winBoosts
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
    
    public init(winBoostId: String, gameTranId: String, status: String, awardedTier: WheelAwardedTier?, boostAmount: Double?) {
        self.winBoostId = winBoostId
        self.gameTranId = gameTranId
        self.status = status
        self.awardedTier = awardedTier
        self.boostAmount = boostAmount
    }
    
}
