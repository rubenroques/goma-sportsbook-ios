//
//  File.swift
//  
//
//  Created by Ruben Roques on 14/11/2022.
//

import Foundation

extension SportRadarModels {
    
    enum BetOutcome: String, CaseIterable {
        case won = "Won"
        case lost = "Lost"
        case drawn = "Drawn"
        case open = "Open"
        case void = "Void"
        case notSpecified = "NotSpecified"
    }
    
    enum BetState: String, CaseIterable {
        case attempted = "Attempted"
        case opened = "Opened"
        case closed = "Closed"
        case settled = "Settled"
        case cancelled = "Cancelled"
        case allStates = "AllStates"
        case undefined = "Undefined"
    }
    
    struct BettingHistory: Codable {
        var bets: [Bet]
    }

    struct Bet: Codable {
        
        var identifier: String
        var eventName: String
        var homeTeamName: String
        var awayTeamName: String
        var sportTypeName: String
        
        var marketName: String
        var outcomeName: String
        
        var potentialReturn: Double
        
        enum CodingKeys: String, CodingKey {
            case identifier = "idFOBet"
            case eventName
            case homeTeamName = "participantHome"
            case awayTeamName = "participantAway"
            case sportTypeName = "idFOSportType"
            case marketName
            case outcomeName = "selectionName"
            case potentialReturn
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.Bet.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.Bet.CodingKeys.self)
            let identifierInt = try container.decode(Double.self, forKey: SportRadarModels.Bet.CodingKeys.identifier)
            self.identifier = String(identifierInt)
            self.eventName = try container.decode(String.self, forKey: SportRadarModels.Bet.CodingKeys.eventName)
            self.homeTeamName = try container.decode(String.self, forKey: SportRadarModels.Bet.CodingKeys.homeTeamName)
            self.awayTeamName = try container.decode(String.self, forKey: SportRadarModels.Bet.CodingKeys.awayTeamName)
            self.sportTypeName = try container.decode(String.self, forKey: SportRadarModels.Bet.CodingKeys.sportTypeName)
            self.marketName = try container.decode(String.self, forKey: SportRadarModels.Bet.CodingKeys.marketName)
            self.outcomeName = try container.decode(String.self, forKey: SportRadarModels.Bet.CodingKeys.outcomeName)
            self.potentialReturn = try container.decode(Double.self, forKey: SportRadarModels.Bet.CodingKeys.potentialReturn)
        }

    }

    struct BetSlip: Codable {
        var tickets: [BetTicket]
    }
    
    struct BetTicket: Codable {
        var selections: [BetTicketSelection]
        var betTypeCode: String
        var placeStake: String
        var winStake: String
        var pool: Bool
        
        enum CodingKeys: String, CodingKey {
            case selections = "betLegs"
            case betTypeCode = "idFOBetType"
            case placeStake = "placeStake"
            case winStake = "winStake"
            case pool = "pool"
        }
        
    }
    
    struct BetTicketSelection: Codable {
        var identifier: String
        var eachWayReduction: String
        var eachWayPlaceTerms: String
        var idFOPriceType: String
        var isTrap: String
        var priceUp: String
        var priceDown: String
        
        enum CodingKeys: String, CodingKey {
            case identifier = "idFOSelection"
            case eachWayReduction = "eachWayReduction"
            case eachWayPlaceTerms = "eachWayPlaceTerms"
            case idFOPriceType = "idFOPriceType"
            case isTrap = "isTrap"
            case priceUp = "priceUp"
            case priceDown = "priceDown"
        }
    }

    struct BetSlipStateResponse: Codable {
        var tickets: [BetTicket]
    }
    
}
