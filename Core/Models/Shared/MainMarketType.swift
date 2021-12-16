//
//  MainMarketsType.swift
//  ShowcaseProd
//
//  Created by Teresa on 15/11/2021.
//

import Foundation

enum MainMarketType: String {
    
    case homeDrawAway = "69"
    case doubleChance = "9"
    case overUnder = "47"
    case bothTeamsToScore = "76"
    case drawNoBet = "112"
    case oddEven = "35"

    init?(id: String) {
        switch id {
        case "69": self = .homeDrawAway
        case "9": self = .doubleChance
        case "47": self = .overUnder
        case "76": self = .bothTeamsToScore
        case "112": self = .drawNoBet
        case "35": self = .oddEven
        default: return nil
        }
    }
    
    var marketId: RawValue {
        rawValue
    }
    
    var marketName: String {
        switch self {
        case .homeDrawAway:
            return "Home Draw Away"
        case .doubleChance:
            return "Double Chance"
        case .overUnder:
            return "Over/Under"
        case .bothTeamsToScore:
            return "Both Teams To Score"
        case .drawNoBet:
            return "Draw No Bet"
        case .oddEven:
            return "Odd/Even"
        }
    }

}
