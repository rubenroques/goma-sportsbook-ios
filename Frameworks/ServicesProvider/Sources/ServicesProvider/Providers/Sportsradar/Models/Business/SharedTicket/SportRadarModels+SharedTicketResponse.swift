//
//  SportRadarModels+SharedTicketResponse.swift
//  
//
//  Created by André Lascas on 21/04/2023.
//

import Foundation

extension SportRadarModels {

    struct SharedTicketResponse: Codable {

        var bets: [SharedBet]
        var totalStake: Double
        var betId: Double

        enum CodingKeys: String, CodingKey {
            case bets = "bets"
            case totalStake = "totalStake"
            case betId = "idFOBetSlip"
        }
    }

}
