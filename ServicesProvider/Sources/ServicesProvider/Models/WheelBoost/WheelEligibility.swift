//
//  WheelEligibility.swift
//  ServicesProvider
//
//  Created by André Lascas on 30/04/2025.
//

import Foundation

public struct WheelStatusResponse: Codable {
    let status: String
    let message: String?
    let data: WheelEligibility?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
        case data = "data"
    }
}

public struct WheelEligibility: Codable {
    let productCode: String
    let gameTransId: String
    let winBoosts: [WheelStatus]
    
    enum CodingKeys: String, CodingKey {
        case productCode = "productCode"
        case gameTransId = "gameTranId"
        case winBoosts = "winBoosts"
    }
}

public struct WheelStatus: Codable {
    let gameTransId: String?
    let status: String
    let message: String?
    let configuration: WheelConfiguration?
    
    enum CodingKeys: String, CodingKey {
        case gameTransId = "gameTranId"
        case status = "status"
        case message = "message"
        case configuration = "configuration"
    }
}

public struct WheelConfiguration: Codable {
    var id: String
    var title: String
    var tiers: [WheelTier]
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case tiers = "tiers"
    }
}

public struct WheelTier: Codable {
    var name: String
    var chance: Double
    var boostMultiplier: Double
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case chance = "chance"
        case boostMultiplier = "boostMultiplier"
    }
}

public struct WheelOptInResponse: Codable {
    let status: String
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
    }
}
