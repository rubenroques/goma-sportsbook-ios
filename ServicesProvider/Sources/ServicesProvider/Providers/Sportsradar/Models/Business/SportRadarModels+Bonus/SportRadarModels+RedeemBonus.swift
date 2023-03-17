//
//  SportRadarModels+RedeemBonus.swift
//  
//
//  Created by André Lascas on 17/03/2023.
//

import Foundation

extension SportRadarModels {
    struct RedeemBonus: Codable {
        var id: Int
        var name: String
        var status: String
        var triggerDate: String
        var expiryDate: String
        var amount: String
        var wagerRequired: String
        var amountWagered: String

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "bonusPlanName"
            case status = "status"
            case triggerDate = "triggerDate"
            case expiryDate = "expiryDate"
            case amount = "amount"
            case wagerRequired = "wagerRequirement"
            case amountWagered = "amountWagered"
        }
    }

}
