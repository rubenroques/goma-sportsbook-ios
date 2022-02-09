//
//  BettingTicket.swift
//  Sportsbook
//
//  Created by Ruben Roques on 02/11/2021.
//

import Foundation

struct BettingTicket: Hashable {

    var id: String

    var bettingId: String {
        return id
    }
    var outcomeId: String
    var marketId: String
    var matchId: String
    var value: Double
    
    var isAvailable: Bool

    var matchDescription: String
    var marketDescription: String
    var outcomeDescription: String
    
    static func == (lhs: BettingTicket, rhs: BettingTicket) -> Bool {
        return lhs.bettingId == rhs.bettingId
    }

}
