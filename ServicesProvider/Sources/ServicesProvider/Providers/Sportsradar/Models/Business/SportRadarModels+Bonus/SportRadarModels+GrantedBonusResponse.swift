//
//  SportRadarModels+GrantedBonusResponse.swift
//  
//
//  Created by André Lascas on 16/03/2023.
//

import Foundation

extension SportRadarModels {

    struct GrantedBonusResponse: Codable {
        var status: String
        var bonuses: [GrantedBonus]

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case bonuses = "bonuses"
        }
    }
}
