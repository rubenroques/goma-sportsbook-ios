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
    public var selections: [BetSelection]
    public var potentialReturn: Double
}

public struct BetSelection: Codable {
    public var identifier: String
    public var state: BetState
    public var result: BetResult
    public var eventName: String
    public var homeTeamName: String
    public var awayTeamName: String
    public var marketName: String
    public var outcomeName: String
}

public enum BetResult: String, Codable {
    case won
    case lost
    case drawn
    case open
    case void
    case notSpecified
}

public enum BetState: String, Codable {
    case opened
    case closed
    case settled
    case cancelled
    case attempted
    case undefined
}

public struct BetTicketStake: Codable {
    var stake: Double
}

public enum BetGrouppingType: String, Codable {
    case single = "S"
    case multiple
    case system
}

public struct BetType: Codable {

    public var name: String
    public var type: BetGrouppingType
    public var code: String
    public var numberOfBets: Int
    public var potencialReturn: Double
    public var totalStake: Double?

}

public struct BetslipPotentialReturn: Codable {
    public var potentialReturn: Double
    public var totalStake: Double
    public var numberOfBets: Int
    public var betType: BetGrouppingType
}

public struct BetslipState: Codable {
    public var tickets: [BetTicketSelection]
    public var stakes: [String: Double]
    public var betType: BetGrouppingType

    public init(tickets: [BetTicketSelection], stakes: [String : Double], betType: BetGrouppingType) {
        self.tickets = tickets
        self.stakes = stakes
        self.betType = betType
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

public struct PlacedBetResponse: Codable {
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
