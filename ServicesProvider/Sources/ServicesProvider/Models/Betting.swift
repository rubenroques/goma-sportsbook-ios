//
//  Betting.swift
//  
//
//  Created by Ruben Roques on 16/11/2022.
//

import Foundation
import SharedModels

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
    public var freebet: Bool
    public var partialCashoutReturn: Double?
    public var partialCashoutStake: Double?
    public var betslipId: Int?
    public var cashbackReturn: Double?
    public var freebetReturn: Double?
    public var potentialCashbackReturn: Double?
    public var potentialFreebetReturn: Double?
}

public struct BetSelection: Codable {
    public var identifier: String
    public var state: BetState
    public var result: BetResult
    public var globalState: BetState
    public var eventName: String
    public var homeTeamName: String?
    public var awayTeamName: String?
    public var marketName: String
    public var outcomeName: String
    public var odd: OddFormat
    
    public var homeResult: String?
    public var awayResult: String?

    public var eventId: String
    public var eventDate: Date?
    public var country: Country?
    public var sportTypeName: String
    public var tournamentName: String

    init(identifier: String,
         state: BetState,
         result: BetResult,
         globalState: BetState,
         eventName: String,
         homeTeamName: String?,
         awayTeamName: String?,
         marketName: String,
         outcomeName: String,
         odd: OddFormat,
         homeResult: String?,
         awayResult: String?,
         eventId: String,
         eventDate: Date?,
         country: Country?,
         sportTypeName: String,
         tournamentName: String) {
        self.identifier = identifier
        self.state = state
        self.result = result
        self.globalState = globalState
        self.eventName = eventName
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.marketName = marketName
        self.outcomeName = outcomeName
        self.odd = odd
        self.homeResult = homeResult
        self.awayResult = awayResult
        self.eventId = eventId
        self.eventDate = eventDate
        self.country = country
        self.sportTypeName = sportTypeName
        self.tournamentName = tournamentName
    }
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
    case cashedOut
    case void
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
    public var totalOdd: Double
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

public enum BetslipOddChangeSetting: String, Codable, Equatable, Hashable {
    case none
    // case any
    case higher
}
    
public enum OddFormat: Codable, Equatable, Hashable {
    case fraction(numerator: Int, denominator: Int)
    case decimal(odd: Double)

    var fractionOdd: (numerator: Int, denominator: Int)? {
        switch self {
        case .fraction(let numerator, let denominator):
            return (numerator: numerator, denominator: denominator)
        case .decimal:
            return nil
        }
    }

    var decimalOdd: Double {
        switch self {
        case .fraction(let numerator, let denominator):
            let decimal = (Double(numerator)/Double(denominator)) + 1.0
            if decimal.isNaN {
                return decimal
            }
            else {
                return decimal
            }
        case .decimal(let odd):
            return odd
        }
    }

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
    public var sportIdCode: String?

    public init(identifier: String,
                eventName: String,
                homeTeamName: String,
                awayTeamName: String,
                marketName: String,
                outcomeName: String,
                odd: OddFormat,
                stake: Double,
                sportIdCode: String?) {
        
        self.identifier = identifier
        self.eventName = eventName
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.marketName = marketName
        self.outcomeName = outcomeName
        self.odd = odd
        self.stake = stake
        self.sportIdCode = sportIdCode
    }

}

public struct PlacedBetsResponse: Codable {

    public var identifier: String
    public var bets: [PlacedBetEntry]
    public var requiredConfirmation: Bool
    public var totalStake: Double

    public init(identifier: String, 
                bets: [PlacedBetEntry],
                requiredConfirmation: Bool = false,
                totalStake: Double) {
        self.identifier = identifier
        self.bets = bets
        self.requiredConfirmation = false
        self.totalStake = totalStake
    }

}

public struct NoReply: Codable {
    
}

public struct PlacedBetEntry: Codable {

    public var identifier: String
    public var potentialReturn: Double
    public var placeStake: Double
    public var totalStake: Double
    public var betLegs: [PlacedBetLeg]

    enum CodingKeys: String, CodingKey {
        case identifier = "idFOBet"
        case betLegs = "betLegs"
        case potentialReturn = "potentialReturn"
        case placeStake = "placeStake"
        case totalStake = "totalStake"
    }

    public init(identifier: String, potentialReturn: Double, placeStake: Double, totalStake: Double, betLegs: [PlacedBetLeg]) {
        self.identifier = identifier
        self.potentialReturn = potentialReturn
        self.placeStake = placeStake
        self.totalStake = totalStake
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

public struct BetslipSettings: Codable {

    public var oddChange: BetslipOddChangeSetting

    public init(oddChange: BetslipOddChangeSetting) {
        self.oddChange = oddChange
    }
    
}
