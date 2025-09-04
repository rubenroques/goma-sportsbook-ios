//
//  AvailableBonus.swift
//  
//
//  Created by André Lascas on 24/03/2023.
//

import Foundation

public struct AvailableBonus: Codable {
    public var id: String
    public var bonusPlanId: Int
    public var name: String
    public var description: String?
    public var type: String
    public var amount: Double
    public var triggerDate: Date?
    public var expiryDate: Date?
    public var wagerRequirement: Double?
    public var imageUrl: String?
    public var additionalAwards: [AdditionalAward]?

    enum CodingKeys: String, CodingKey {
        case id = "optInId"
        case bonusPlanId = "bonusPlanId"
        case name = "bonusPlanName"
        case description = "description"
        case type = "bonusPlanType"
        case amount = "bonusAmount"
        case triggerDate = "startDate"
        case expiryDate = "endDate"
        case wagerRequirement = "wagerReq"
        case imageUrl = "imageUrl"
    }
}

public struct AdditionalAward: Codable {
    public var type: String
    public var product: String
    public var amount: Double
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case product = "product"
        case amount = "amount"
    }
}
