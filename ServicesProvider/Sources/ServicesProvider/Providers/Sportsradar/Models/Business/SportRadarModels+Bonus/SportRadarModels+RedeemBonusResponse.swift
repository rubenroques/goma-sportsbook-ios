//
//  SportRadarModels+RedeemBonusResponse.swift
//  
//
//  Created by André Lascas on 17/03/2023.
//

import Foundation

extension SportRadarModels {
    struct RedeemBonusResponse: Codable {
        var status: String
        var message: String?
        var bonus: RedeemBonus?


        enum CodingKeys: String, CodingKey {
            case status = "status"
            case message = "message"
            case bonus = "bonus"
        }
    }

}

