//
//  SportRadarModels+SharedBets.swift
//  
//
//  Created by André Lascas on 21/04/2023.
//

import Foundation

extension SportRadarModels {

    struct SharedBet: Codable {

        var betSelections: [SharedBetSelection]
        var winStake: Double
        var potentialReturn: Double
        var totalStake: Double

        enum CodingKeys: String, CodingKey {
            case betSelections = "betLegs"
            case winStake = "winStake"
            case potentialReturn = "potentialReturn"
            case totalStake = "totalStake"
        }
    }

}
