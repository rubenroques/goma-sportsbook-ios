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

/// Represents a bet in the system
/// This struct is a merged version of both Sportsbook and Multibet implementations
public struct Bet: Codable, Equatable, Hashable {

    // Core properties - present in both implementations
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

    // Cashout related properties - present in both implementations
    public var partialCashoutReturn: Double?
    public var partialCashoutStake: Double?

    // Betslip identifier - present in both implementations
    public var betslipId: Int?

    // Return calculation properties - present in both implementations
    public var cashbackReturn: Double?
    public var freebetReturn: Double?
    public var potentialCashbackReturn: Double?
    public var potentialFreebetReturn: Double?

    // MARK: - Properties specific to Multibet
    // Unique identifier for sharing bets
    // Note: This property was only present in Multibet implementation
    public var shareId: String?

    // MARK: - EveryMatrix specific properties
    // Ticket code for customer reference
    public var ticketCode: String?

    public init(
        identifier: String,
        type: String,
        state: BetState,
        result: BetResult,
        globalState: BetState,
        stake: Double,
        totalOdd: Double,
        selections: [BetSelection],
        potentialReturn: Double? = nil,
        totalReturn: Double? = nil,
        date: Date,
        freebet: Bool,
        partialCashoutReturn: Double? = nil,
        partialCashoutStake: Double? = nil,
        betslipId: Int? = nil,
        cashbackReturn: Double? = nil,
        freebetReturn: Double? = nil,
        potentialCashbackReturn: Double? = nil,
        potentialFreebetReturn: Double? = nil,
        shareId: String? = nil,
        ticketCode: String? = nil
    ) {
        self.identifier = identifier
        self.type = type
        self.state = state
        self.result = result
        self.globalState = globalState
        self.stake = stake
        self.totalOdd = totalOdd
        self.selections = selections
        self.potentialReturn = potentialReturn
        self.totalReturn = totalReturn
        self.date = date
        self.freebet = freebet
        self.partialCashoutReturn = partialCashoutReturn
        self.partialCashoutStake = partialCashoutStake
        self.betslipId = betslipId
        self.cashbackReturn = cashbackReturn
        self.freebetReturn = freebetReturn
        self.potentialCashbackReturn = potentialCashbackReturn
        self.potentialFreebetReturn = potentialFreebetReturn
        self.shareId = shareId
        self.ticketCode = ticketCode
    }
}

/// Represents a selection within a bet
/// This struct is a merged version of both Sportsbook and Multibet implementations
public struct BetSelection: Codable, Equatable, Hashable {
    // MARK: - Core Properties (present in both implementations)
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

    // MARK: - Score Properties (present in both implementations)
    public var homeResult: String?
    public var awayResult: String?

    // MARK: - Event Properties (present in both implementations)
    public var eventId: String
    public var eventDate: Date?
    public var country: Country?
    public var tournamentName: String

    // MARK: - Sport Properties (implementation differences)
    /// Sport type information
    /// Note: Sportsbook uses String, Multibet uses SportType enum
    /// Migration: When converting from Sportsbook, use SportType(fromString:) to convert
    public var sportType: SportType

    // MARK: - Market and Outcome Properties (Multibet specific)
    /// Unique identifier for the market
    /// Note: Only present in Multibet implementation
    public var marketId: String?

    /// Unique identifier for the outcome
    /// Note: Only present in Multibet implementation
    public var outcomeId: String?

    // MARK: - Team Logo Properties (Multibet specific)
    /// URL for the home team's logo
    /// Note: Only present in Multibet implementation
    public var homeLogoUrl: String?

    /// URL for the away team's logo
    /// Note: Only present in Multibet implementation
    public var awayLogoUrl: String?

    public init(
        identifier: String,
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
        sportType: SportType,
        tournamentName: String,
        marketId: String? = nil,
        outcomeId: String? = nil,
        homeLogoUrl: String? = nil,
        awayLogoUrl: String? = nil
    ) {
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
        self.sportType = sportType
        self.tournamentName = tournamentName
        self.marketId = marketId
        self.outcomeId = outcomeId
        self.homeLogoUrl = homeLogoUrl
        self.awayLogoUrl = awayLogoUrl
    }
}

public enum BetResult: String, Codable, Equatable, Hashable {
    case won
    case lost
    case drawn
    case open
    case void
    case pending
    case notSpecified
}

public enum BetState: String, Codable, Equatable, Hashable {
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
public enum BetGroupingType: Codable, Equatable, Hashable {
    case single(identifier: String)
    case multiple(identifier: String)
    case system(identifier: String, name: String, numberOfBets: Int)

    var identifier: String {
        switch self {
        case .single(let identifier):
            return identifier
        case .multiple(let identifier):
            return identifier
        case .system(let identifier, _, _):
            return identifier
        }
    }
}

public struct BetType: Codable, Equatable, Hashable {
    public var name: String
    public var grouping: BetGroupingType
    public var code: String
    public var numberOfBets: Int
    public var potencialReturn: Double
    public var totalStake: Double?
}

public struct BetslipPotentialReturn: Codable, Equatable, Hashable {
    public var potentialReturn: Double
    public var totalStake: Double
    public var numberOfBets: Int
    public var totalOdd: Double
}

public struct BetBuilderPotentialReturn: Codable, Equatable, Hashable {
    public var potentialReturn: Double
    public var calculatedOdds: Double
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

public struct BetTicketSelection: Codable, Equatable, Hashable {

    public var identifier: String
    public var eventName: String
    public var homeTeamName: String
    public var awayTeamName: String
    public var marketName: String
    public var outcomeName: String
    public var odd: OddFormat
    public var stake: Double

    public var sportIdCode: String?
    public var eventId: String?
    public var marketId: String?
    public var outcomeId: String?

    public init(identifier: String,
                eventName: String,
                homeTeamName: String,
                awayTeamName: String,
                marketName: String,
                outcomeName: String,
                odd: OddFormat,
                stake: Double,
                sportIdCode: String?,
                eventId: String? = nil,
                marketId: String? = nil,
                outcomeId: String? = nil) {

        self.identifier = identifier
        self.eventName = eventName
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.marketName = marketName
        self.outcomeName = outcomeName
        self.odd = odd
        self.stake = stake
        self.sportIdCode = sportIdCode
        self.eventId = eventId
        self.marketId = marketId
        self.outcomeId = outcomeId
    }

}

public struct PlacedBetsResponse: Codable, Equatable, Hashable {

    public var identifier: String

    public var bets: [PlacedBetEntry]
    public var detailedBets: [Bet]? // Contain all the details of the bet and event/outcome

    public var requiredConfirmation: Bool
    public var totalStake: Double

    public init(identifier: String,
                bets: [PlacedBetEntry],
                detailedBets: [Bet]?,
                requiredConfirmation: Bool = false,
                totalStake: Double) {

        self.identifier = identifier
        self.bets = bets
        self.detailedBets = detailedBets
        self.requiredConfirmation = requiredConfirmation
        self.totalStake = totalStake
    }

}

public struct NoReply: Codable {

}

public struct PlacedBetEntry: Codable, Equatable, Hashable {

    public var identifier: String
    public var potentialReturn: Double
    public var totalStake: Double
    public var betLegs: [PlacedBetLeg]
    public var type: String?

    enum CodingKeys: String, CodingKey {
        case identifier = "idFOBet"
        case betLegs = "betLegs"
        case potentialReturn = "potentialReturn"
        case totalStake = "totalStake"
        case type = "idfoBetType"
    }

    public init(identifier: String, potentialReturn: Double, totalStake: Double, betLegs: [PlacedBetLeg], type: String?) {
        self.identifier = identifier
        self.potentialReturn = potentialReturn
        self.totalStake = totalStake
        self.betLegs = betLegs
        self.type = type
    }
}

public struct PlacedBetLeg: Codable, Equatable, Hashable {
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

    public var oddChangeLegacy: BetslipOddChangeSetting?
    public var oddChangeRunningOrPreMatch: BetslipOddChangeSetting?

    public init(oddChangeLegacy: BetslipOddChangeSetting?, oddChangeRunningOrPreMatch: BetslipOddChangeSetting?) {
        self.oddChangeLegacy = oddChangeLegacy
        self.oddChangeRunningOrPreMatch = oddChangeRunningOrPreMatch
    }

}
