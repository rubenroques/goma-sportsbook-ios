//
//  BettingTicket.swift
//  Sportsbook
//
//  Created by Ruben Roques on 02/11/2021.
//

import Foundation


struct BettingTicket: Hashable, Codable {

    var id: String

    var bettingId: String {
        return id
    }
    var outcomeId: String
    var marketId: String
    var matchId: String

    var isAvailable: Bool
    var statusId: String

    var matchDescription: String
    var marketDescription: String
    var outcomeDescription: String

    var isOpen: Bool {
        return self.isAvailable && ((self.statusId ?? "") == "1" )
    }

    var odd: OddFormat

    var decimalOdd: Double {
        switch self.odd {
        case .fraction(let numerator, let denominator):
            return (Double(numerator)/Double(denominator)) + 1.0
        case .decimal(let odd):
            return odd
        }
    }

    var fractionalOdd: (numerator: Int, denominator: Int) {
        switch self.odd {
        case .fraction(let numerator, let denominator):
            return (numerator, denominator)
        case .decimal(let odd):
            let rational = OddConverter.rationalApproximation(originalValue: odd)
            return (rational.num, rational.den)
        }
    }

    static func == (lhs: BettingTicket, rhs: BettingTicket) -> Bool {
        return lhs.bettingId == rhs.bettingId
    }

    init(id: String,
         outcomeId: String,
         marketId: String,
         matchId: String,
         isAvailable: Bool,
         statusId: String,
         matchDescription: String,
         marketDescription: String,
         outcomeDescription: String,
         odd: OddFormat) {

        self.id = id
        self.outcomeId = outcomeId
        self.marketId = marketId
        self.matchId = matchId
        self.isAvailable = isAvailable
        self.statusId = statusId
        self.matchDescription = matchDescription
        self.marketDescription = marketDescription
        self.outcomeDescription = outcomeDescription
        self.odd = odd
    }

    init(id: String,
         outcomeId: String,
         marketId: String,
         matchId: String,
         decimalOdd: Double,
         isAvailable: Bool,
         statusId: String,
         matchDescription: String,
         marketDescription: String,
         outcomeDescription: String) {

        self.id = id
        self.outcomeId = outcomeId
        self.marketId = marketId
        self.matchId = matchId
        self.isAvailable = isAvailable
        self.statusId = statusId
        self.matchDescription = matchDescription
        self.marketDescription = marketDescription
        self.outcomeDescription = outcomeDescription
        self.odd = OddFormat.decimal(odd: decimalOdd)
    }

}

extension BettingTicket {
    init(match: Match, market: Market, outcome: Outcome) {
        let matchDescription = "\(match.homeParticipant.name) x \(match.awayParticipant.name)"
        let marketDescription = market.name
        let outcomeDescription = outcome.translatedName

        self.init(id: outcome.bettingOffer.id,
                  outcomeId: outcome.id,
                  marketId: market.id,
                  matchId: match.id,
                  decimalOdd: outcome.bettingOffer.decimalOdd,
                  isAvailable: outcome.bettingOffer.isAvailable,
                  statusId: "1",
                  matchDescription: matchDescription,
                  marketDescription: marketDescription,
                  outcomeDescription: outcomeDescription)
    }

    init(match: Match, marketId: String, outcome: Outcome) {
        let marketName = outcome.marketName ?? ""
        let matchDescription =  marketName.isNotEmpty ? "\(outcome.translatedName), \(marketName)" : "\(outcome.translatedName)"
        let marketDescription = outcome.marketName ?? ""
        let outcomeDescription = outcome.translatedName

        self.init(id: outcome.bettingOffer.id,
                  outcomeId: outcome.id,
                  marketId: marketId,
                  matchId: match.id,
                  decimalOdd: outcome.bettingOffer.decimalOdd,
                  isAvailable: outcome.bettingOffer.isAvailable,
                  statusId: "1",
                  matchDescription: matchDescription,
                  marketDescription: marketDescription,
                  outcomeDescription: outcomeDescription)
    }

}
