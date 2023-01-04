//
//  File.swift
//  
//
//  Created by Ruben Roques on 14/11/2022.
//

import Foundation

extension SportRadarModels {
    
    enum BetResult: String, CaseIterable, Codable {
        case won = "Won"
        case lost = "Lost"
        case drawn = "Drawn"
        case open = "Open"
        case void = "Void"
        case notSpecified = "NotSpecified"
    }
    
    enum BetState: String, CaseIterable, Codable {
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
        var state: BetState
        var result: BetResult
        var marketName: String
        var outcomeName: String
        
        var potentialReturn: Double
        
        enum CodingKeys: String, CodingKey {
            case identifier = "idFOBet"
            case eventName
            case homeTeamName = "participantHome"
            case awayTeamName = "participantAway"
            case sportTypeName = "idFOSportType"
            case state = "betLegStatus"
            case result = "betResult"
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

            let stateString = try container.decode(String.self, forKey: SportRadarModels.Bet.CodingKeys.state)
            self.state = BetState(rawValue: stateString) ?? .undefined

            let resultString = try container.decode(String.self, forKey: SportRadarModels.Bet.CodingKeys.result)
            self.result = BetResult(rawValue: resultString) ?? .notSpecified
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
        var potentialReturn: Double?
        var pool: Bool
        
        enum CodingKeys: String, CodingKey {
            case selections = "betLegs"
            case betTypeCode = "idFOBetType"
            case placeStake = "placeStake"
            case winStake = "winStake"
            case potentialReturn = "potentialReturn"
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

    struct BetslipPotentialReturnResponse: Codable {

        var potentialReturn: Double
        var totalStake: Double
        var numberOfBets: Int

        enum CodingKeys: String, CodingKey {
            case numberOfBets = "unitCount"
            case potentialReturn = "potentialReturn"
            case totalStake = "totalStake"
        }
        
    }

    struct BetType: Codable {

        var typeCode: String
        var typeName: String
        var potencialReturn: Double
        var totalStake: Double
        var numberOfIndividualBets: Int

        enum CodingKeys: String, CodingKey {
            case numberOfIndividualBets = "unitCount"
            case typeCode = "idFOBetType"
            case typeName = "name"
            case potencialReturn = "potentialReturn"
            case totalStake = "totalStake"
        }
        
    }

    struct BetSlipStateResponse: Codable {
        var tickets: [BetTicket]
    }

    struct PlacedBetResponse: Codable {
        var identifier: String
        var responseCode: String
        var bets: [PlacedBetEntry]

        enum CodingKeys: String, CodingKey {
            case identifier = "idFOBetSlip"
            case bets = "bets"
            case status = "status"
            case responseCode = "state"
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.PlacedBetResponse.CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)

            let identifierInt = try container.decode(Int.self, forKey: .identifier)
            self.identifier = "\(identifierInt)"
            self.bets = try container.decode([SportRadarModels.PlacedBetEntry].self, forKey: .bets)

            let statusContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .status)
            let statusCodeInt = (try? statusContainer?.decodeIfPresent(Int.self, forKey: .responseCode)) ?? 0
            self.responseCode = "\(statusCodeInt)"
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.identifier, forKey: CodingKeys.identifier)
            try container.encode(self.bets, forKey: CodingKeys.bets)
            try container.encode(self.responseCode, forKey: CodingKeys.responseCode)
        }
        
    }

    struct PlacedBetEntry: Codable {
        var identifier: String
        var potentialReturn: Double
        var placeStake: Double
        var betLegs: [PlacedBetLeg]

        enum CodingKeys: String, CodingKey {
            case identifier = "idFoBet"
            case betLegs = "betLegs"
            case potentialReturn = "potentialReturn"
            case placeStake = "placeStake"
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.PlacedBetEntry.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.PlacedBetEntry.CodingKeys.self)
            let identifierDouble = try container.decode(Double.self, forKey: SportRadarModels.PlacedBetEntry.CodingKeys.identifier)
            self.identifier = String(format: "%.2f", identifierDouble)

            self.betLegs = try container.decode([SportRadarModels.PlacedBetLeg].self, forKey: SportRadarModels.PlacedBetEntry.CodingKeys.betLegs)
            self.potentialReturn = try container.decode(Double.self, forKey: SportRadarModels.PlacedBetEntry.CodingKeys.potentialReturn)
            self.placeStake = try container.decode(Double.self, forKey: SportRadarModels.PlacedBetEntry.CodingKeys.placeStake)
        }
    }

    struct PlacedBetLeg: Codable {
        var identifier: String
        var priceType: String

        var odd: Double {
            let priceNumerator = Double(self.priceNumerator)
            let priceDenominator = Double(self.priceDenominator)
            return (priceNumerator/priceDenominator) + 1.0
        }

        var priceNumerator: Int
        var priceDenominator: Int

        enum CodingKeys: String, CodingKey {
            case identifier = "idFOSelection"
            case priceNumerator = "priceUp"
            case priceDenominator = "priceDown"
            case priceType = "idFOPriceType"
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.PlacedBetLeg.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.PlacedBetLeg.CodingKeys.self)

            let identifierDouble = try container.decode(Double.self, forKey: SportRadarModels.PlacedBetLeg.CodingKeys.identifier)
            self.identifier = String(format: "%.1f", identifierDouble)

            self.priceNumerator = try container.decode(Int.self, forKey: SportRadarModels.PlacedBetLeg.CodingKeys.priceNumerator)
            self.priceDenominator = try container.decode(Int.self, forKey: SportRadarModels.PlacedBetLeg.CodingKeys.priceDenominator)
            self.priceType = try container.decode(String.self, forKey: SportRadarModels.PlacedBetLeg.CodingKeys.priceType)
        }

    }

}
