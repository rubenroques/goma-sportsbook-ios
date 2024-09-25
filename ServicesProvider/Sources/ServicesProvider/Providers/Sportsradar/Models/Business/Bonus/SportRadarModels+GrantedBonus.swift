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
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.GrantedBonus.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.GrantedBonus.CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: SportRadarModels.GrantedBonus.CodingKeys.id)
            self.name = try container.decode(String.self, forKey: SportRadarModels.GrantedBonus.CodingKeys.name)
            self.status = try container.decode(String.self, forKey: SportRadarModels.GrantedBonus.CodingKeys.status)
            self.amount = try container.decode(String.self, forKey: SportRadarModels.GrantedBonus.CodingKeys.amount)
            self.triggerDate = try container.decode(String.self, forKey: SportRadarModels.GrantedBonus.CodingKeys.triggerDate)
            self.expiryDate = try container.decode(String.self, forKey: SportRadarModels.GrantedBonus.CodingKeys.expiryDate)
            self.wagerRequirement = try container.decodeIfPresent(String.self, forKey: SportRadarModels.GrantedBonus.CodingKeys.wagerRequirement)
            self.amountWagered = try container.decodeIfPresent(String.self, forKey: SportRadarModels.GrantedBonus.CodingKeys.amountWagered)
        }
    }
}
