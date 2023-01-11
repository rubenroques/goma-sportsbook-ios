//
//  ServiceProviderModelMapper+Betting.swift
//  Sportsbook
//
//  Created by Ruben Roques on 05/12/2022.
//

import Foundation
import ServicesProvider

extension ServiceProviderModelMapper {

    static func bettingHistory(fromServiceProviderBettingHistory bettingHistory: ServicesProvider.BettingHistory) -> BetHistoryResponse {
        let betList = bettingHistory.bets.map(Self.betHistoryEntry(fromServiceProviderBet:))
        return BetHistoryResponse(betList: betList)
    }

    static func betHistoryEntry(fromServiceProviderBet bet: ServicesProvider.Bet) -> BetHistoryEntry {
        let selections = bet.selections.map(Self.betHistoryEntrySelection(fromServiceProviderBetSelection:))
        return BetHistoryEntry(betId: bet.identifier,
                        selections: selections,
                        type: bet.type,
                        systemBetType: nil,
                        amount: nil,
                        totalBetAmount: bet.stake,
                        freeBetAmount: nil,
                        bonusBetAmount: nil,
                        currency: nil,
                        maxWinning: bet.potentialReturn,
                        totalPriceValue: bet.totalOdd,
                        overallBetReturns: nil,
                        numberOfSelections: selections.count,
                        status: bet.state.rawValue,
                        placedDate: bet.date,
                        settledDate: nil,
                        freeBet: nil,
                        betShareToken: nil)
    }

    static func betHistoryEntrySelection(fromServiceProviderBetSelection betSelection: ServicesProvider.BetSelection) -> BetHistoryEntrySelection {

        let status: BetSelectionStatus
        switch betSelection.state {
        case .opened: status = .opened
        case .closed: status = .closed
        case .settled: status = .settled
        case .cancelled: status = .cancelled
        case .attempted: status = .undefined
        case .undefined: status = .undefined
        }

        let result: BetSelectionResult
        switch betSelection.result {
        case .open: result = .open
        case .won: result = .won
        case .lost: result = .lost
        case .drawn: result = .drawn
        case .notSpecified: result = .undefined
        case .void: result = .undefined
        case .pending: result = .undefined
        }

        var decimalOdd: Double
        switch betSelection.odd {
        case .fraction(let numerator, let denominator):
            decimalOdd = (Double(numerator)/Double(denominator)) + 1.0
        case .european(let odd):
            decimalOdd = odd
        }


        let betHistoryEntrySelection = BetHistoryEntrySelection(outcomeId: betSelection.identifier,
                                                                status: status,
                                                                result: result,
                                                                priceValue: decimalOdd,
                                                                sportId: nil,
                                                                sportName: nil,
                                                                venueId: nil,
                                                                venueName: nil,
                                                                tournamentId: nil,
                                                                tournamentName: nil,
                                                                eventId: nil,
                                                                eventStatusId: nil,
                                                                eventName: betSelection.eventName,
                                                                eventResult: nil,
                                                                eventDate: nil,
                                                                bettingTypeId: nil,
                                                                bettingTypeName: nil,
                                                                bettingTypeEventPartId: nil,
                                                                bettingTypeEventPartName: nil,
                                                                homeParticipantName: betSelection.homeTeamName,
                                                                awayParticipantName: betSelection.awayTeamName,
                                                                marketName: betSelection.marketName,
                                                                betName: betSelection.outcomeName)

        return betHistoryEntrySelection
    }

}
