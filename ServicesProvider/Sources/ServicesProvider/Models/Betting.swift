//
//  Betting.swift
//  
//
//  Created by Ruben Roques on 16/11/2022.
//

import Foundation

public struct BettingHistory: Codable {
    public var bets: [Bet]
}

public struct Bet: Codable {
    public var identifier: String
    public var type: String
    public var state: BetState
    public var result: BetResult
    public var globalState: BetState
    public var stake: Double
    public var totalOdd: Double
    public var selections: [BetSelection]
    public var potentialReturn: Double?
    public var totalReturn: Double?
    public var date: Date
}

public struct BetSelection: Codable {
    public var identifier: String
    public var state: BetState
    public var result: BetResult
    public var globalState: BetState
    public var eventName: String
    public var homeTeamName: String
    public var awayTeamName: String
    public var marketName: String
    public var outcomeName: String
    public var odd: OddFormat
}

public enum BetResult: String, Codable {
    case won
    case lost
    case drawn
    case open
    case void
    case pending
    case notSpecified
}

public enum BetState: String, Codable {
    case opened
    case closed
    case settled
    case cancelled
    case attempted
    case won
    case lost
    case undefined
}

//public struct BetTicketStake: Codable {
//    var stake: Double
//}

public enum BetGroupingType: Codable {
    case single(identifier: String)
    case multiple(identifier: String)
    case system(identifier: String, name: String)

    var identifier: String {
        switch self {
        case .single(let identifier):
            return identifier
        case .multiple(let identifier):
            return identifier
        case .system(let identifier, _):
            return identifier
        }
    }
}

public struct BetType: Codable {
    public var name: String
    public var grouping: BetGroupingType
    public var code: String
    public var numberOfBets: Int
    public var potencialReturn: Double
    public var totalStake: Double?
}

public struct BetslipPotentialReturn: Codable {
    public var potentialReturn: Double
    public var totalStake: Double
    public var numberOfBets: Int
}

public struct BetTicket: Codable {
    public var tickets: [BetTicketSelection]
    public var globalStake: Double?
    public var betGroupingType: BetGroupingType

    public init(tickets: [BetTicketSelection], stake: Double?, betGroupingType: BetGroupingType) {
        self.tickets = tickets
        self.globalStake = stake
        self.betGroupingType = betGroupingType
    }
}

public enum OddFormat: Codable {
    case fraction(numerator: Int, denominator: Int)
    case european(odd: Double)
}

public struct BetTicketSelection: Codable {

    public var identifier: String
    public var eventName: String
    public var homeTeamName: String
    public var awayTeamName: String
    public var marketName: String
    public var outcomeName: String
    public var odd: OddFormat

    public var stake: Double

    public init(identifier: String,
                eventName: String,
                homeTeamName: String,
                awayTeamName: String,
                marketName: String,
                outcomeName: String,
                odd: OddFormat,
                stake: Double) {
        
        self.identifier = identifier
        self.eventName = eventName
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.marketName = marketName
        self.outcomeName = outcomeName
        self.odd = odd
        self.stake = stake
    }

}

public struct PlacedBetsResponse: Codable {
    public var identifier: String
    public var responseCode: String
    public var succeed: Bool
    public var bets: [PlacedBetEntry]

    enum CodingKeys: String, CodingKey {
        case identifier = "idFOBetSlip"
        case responseCode = "state"
        case bets = "bets"
        case succeed = "succeed"
    }

    public init(identifier: String, responseCode: String, succeed: Bool, bets: [PlacedBetEntry]) {
        self.identifier = identifier
        self.bets = bets
        self.succeed = succeed
        self.responseCode = responseCode
    }
}

public struct PlacedBetEntry: Codable {

    public var identifier: String
    public var potentialReturn: Double
    public var placeStake: Double
    public var betLegs: [PlacedBetLeg]

    enum CodingKeys: String, CodingKey {
        case identifier = "idFOBet"
        case betLegs = "betLegs"
        case potentialReturn = "potentialReturn"
        case placeStake = "placeStake"
    }

    public init(identifier: String, potentialReturn: Double, placeStake: Double, betLegs: [PlacedBetLeg]) {
        self.identifier = identifier
        self.potentialReturn = potentialReturn
        self.placeStake = placeStake
        self.betLegs = betLegs
    }
}

public struct PlacedBetLeg: Codable {
    public var identifier: String
    public var priceType: String

    public var odd: Double {
        let priceNumerator = Double(self.priceNumerator)
        let priceDenominator = Double(self.priceDenominator)
        return (priceNumerator/priceDenominator) + 1.0
    }

    private var priceNumerator: Int
    private var priceDenominator: Int

    enum CodingKeys: String, CodingKey {
        case identifier = "idFOSelection"
        case priceNumerator = "priceUp"
        case priceDenominator = "priceDown"
        case priceType = "idFOPriceType"
    }

    public init(identifier: String, priceType: String, priceNumerator: Int, priceDenominator: Int) {
        self.identifier = identifier
        self.priceType = priceType
        self.priceNumerator = priceNumerator
        self.priceDenominator = priceDenominator
    }

}
