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
    public var actionUrl: String?

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
    
    public init(
        id: String,
        bonusPlanId: Int,
        name: String,
        description: String? = nil,
        type: String,
        amount: Double,
        triggerDate: Date? = nil,
        expiryDate: Date? = nil,
        wagerRequirement: Double? = nil,
        imageUrl: String? = nil,
        actionUrl: String? = nil
    ) {
        self.id = id
        self.bonusPlanId = bonusPlanId
        self.name = name
        self.description = description
        self.type = type
        self.amount = amount
        self.triggerDate = triggerDate
        self.expiryDate = expiryDate
        self.wagerRequirement = wagerRequirement
        self.imageUrl = imageUrl
        self.actionUrl = actionUrl
    }
}
