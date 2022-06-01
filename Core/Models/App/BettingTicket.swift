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
    var statusId: String

    var matchDescription: String
    var marketDescription: String
    var outcomeDescription: String

    var isOpen: Bool {
        return self.isAvailable && ((self.statusId ?? "") == "1" )
    }

    static func == (lhs: BettingTicket, rhs: BettingTicket) -> Bool {
        return lhs.bettingId == rhs.bettingId
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
                  value: outcome.bettingOffer.value,
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
                  value: outcome.bettingOffer.value,
                  isAvailable: outcome.bettingOffer.isAvailable,
                  statusId: "1",
                  matchDescription: matchDescription,
                  marketDescription: marketDescription,
                  outcomeDescription: outcomeDescription)
    }

//    init(betHistoryEntrySelection: BetHistoryEntrySelection) {
//
//        let matchDescription =  [betHistoryEntrySelection.homeParticipantName, betHistoryEntrySelection.awayParticipantName]
//            .compactMap({ $0 })
//            .joined(separator: " x ")
//
//        let matchDescription = matchDescription
//        let marketDescription = betHistoryEntrySelection.marketName ?? ""
//        let outcomeDescription = betHistoryEntrySelection.betName ?? ""
//
//
//        self.init(id: betHistoryEntrySelection.id,
//                  outcomeId: betHistoryEntrySelection.outcomeId,
//                  marketId: betHistoryEntrySelection.eventId,
//                  matchId: <#T##String#>,
//                  value: 0.0,
//                  isAvailable: true,
//                  statusId: "1",
//                  matchDescription: <#T##String#>,
//                  marketDescription: <#T##String#>,
//                  outcomeDescription: <#T##String#>)
//    }

}
