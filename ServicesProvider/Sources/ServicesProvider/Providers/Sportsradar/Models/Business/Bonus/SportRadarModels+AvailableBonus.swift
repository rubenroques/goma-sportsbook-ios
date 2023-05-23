//
//  SportRadarModels+AvailableBonus.swift
//  
//
//  Created by André Lascas on 24/03/2023.
//

import Foundation

extension SportRadarModels {

    struct AvailableBonus: Codable {
        var id: String
        var bonusPlanId: Int
        var name: String
        var description: String?
        var type: String
        var amount: Double
        var triggerDate: String
        var expiryDate: String
        var wagerRequirement: Double?
        var imageUrl: String?

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

}
