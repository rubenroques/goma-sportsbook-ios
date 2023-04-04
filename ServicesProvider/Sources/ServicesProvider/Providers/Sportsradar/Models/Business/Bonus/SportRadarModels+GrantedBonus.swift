//
//  SportRadarModels+GrantedBonus.swift
//  
//
//  Created by André Lascas on 16/03/2023.
//

import Foundation

extension SportRadarModels {

    struct GrantedBonus: Codable {
        var id: Int
        var name: String
        var status: String
        var amount: String
        var triggerDate: String
        var expiryDate: String
        var wagerRequirement: String?
        var amountWagered: String?

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "bonusPlanName"
            case status = "status"
            case amount = "amount"
            case triggerDate = "triggerDate"
            case expiryDate = "expiryDate"
            case wagerRequirement = "wagerRequirement"
            case amountWagered = "amountWagered"
        }
    }
}
