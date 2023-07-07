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
                        totalPriceValue: selections.count > 1 ? bet.totalOdd : selections.first?.priceValue,
                        overallBetReturns: nil,
                        numberOfSelections: selections.count,
                        status: bet.globalState.rawValue,
                        placedDate: bet.date,
                        settledDate: nil,
                        freeBet: bet.freebet,
                        partialCashoutReturn: bet.partialCashoutReturn,
                        partialCashoutStake: bet.partialCashoutStake,
                        betShareToken: nil,
                        betslipId: bet.betslipId)
    }

    static func betHistoryEntrySelection(fromServiceProviderBetSelection betSelection: ServicesProvider.BetSelection) -> BetHistoryEntrySelection {

        let status: BetSelectionStatus
        switch betSelection.state {
        case .opened: status = .opened
        case .closed: status = .closed
        case .settled: status = .settled
        case .cancelled: status = .cancelled
        case .attempted: status = .undefined
        case .won: status = .won
        case .lost: status = .lost
        case .cashedOut: status = .cashedOut
        case .undefined: status = .undefined
        }

        // betResult is global, betLegStatus is the selection real result
        let result: BetSelectionResult
        switch betSelection.state {
        case .opened: result = .open
        case .won: result = .won
        case .lost: result = .lost
        default: result = .undefined
        }
//        let result: BetSelectionResult
//        switch betSelection.result {
//        case .open: result = .open
//        case .won: result = .won
//        case .lost: result = .lost
//        case .drawn: result = .drawn
//        case .notSpecified: result = .undefined
//        case .void: result = .undefined
//        case .pending: result = .undefined
//        }

        var decimalOdd: Double
        switch betSelection.odd {
        case .fraction(let numerator, let denominator):
            decimalOdd = (Double(numerator)/Double(denominator)) + 1.0
        case .decimal(let odd):
            decimalOdd = odd
        }

        let betHistoryEntrySelection = BetHistoryEntrySelection(outcomeId: betSelection.identifier,
                                                                status: status,
                                                                result: result,
                                                                priceValue: decimalOdd,
                                                                sportId: nil,
                                                                sportName: betSelection.sportTypeName,
                                                                venueId: nil,
                                                                venueName: betSelection.country?.iso2Code,
                                                                tournamentId: nil,
                                                                tournamentName: betSelection.tournamentName,
                                                                eventId: betSelection.eventId,
                                                                eventStatusId: nil,
                                                                eventName: betSelection.eventName,
                                                                eventResult: nil,
                                                                eventDate: betSelection.eventDate,
                                                                bettingTypeId: nil,
                                                                bettingTypeName: nil,
                                                                bettingTypeEventPartId: nil,
                                                                bettingTypeEventPartName: nil,
                                                                homeParticipantName: betSelection.homeTeamName,
                                                                awayParticipantName: betSelection.awayTeamName,
                                                                homeParticipantScore: betSelection.homeResult,
                                                                awayParticipantScore: betSelection.awayResult,
                                                                marketName: betSelection.marketName,
                                                                betName: betSelection.outcomeName)

        return betHistoryEntrySelection
    }

    static func transactionHistory(fromServiceProviderTransactionDetail transactionDetail: ServicesProvider.TransactionDetail) -> TransactionHistory {

        var valueType = TransactionValueType.neutral

        let transactionType = Self.stringFromTransactionType(transactionType: transactionDetail.type)

        if transactionDetail.amount < 0.0 {
            valueType = .loss
        }
        else if transactionDetail.amount > 0.0 {
            valueType = .won
        }
        else {
            valueType = .neutral
        }

        return TransactionHistory(transactionID: "\(transactionDetail.id)",
                                                           time: transactionDetail.dateTime,
                                  type: transactionType ?? "",
                                                           valueType: valueType,
                                                           debit: DebitCredit(currency: transactionDetail.currency,
                                                                              amount: transactionDetail.amount,
                                                                              name: "Debit"),
                                                           credit: DebitCredit(currency: transactionDetail.currency,
                                                                               amount: transactionDetail.amount,
                                                                               name: "Credit"),
                                                           fees: [],
                                                           status: nil,
                                                           transactionReference: nil,
                                                           id: "\(transactionDetail.gameTranId ?? "")",
                                                           isRallbackAllowed: nil,
                                                           paymentId: transactionDetail.paymentId)
    }

    static func stringFromTransactionType(transactionType: TransactionType?) -> String? {

        switch transactionType {
        case .deposit: return localized("deposit")
        case .withdrawal: return localized("withdrawal")
        case .bonusCredited: return localized("bonus_credit")
        case .bonusExpired: return localized("bonus_expired")
        case .bonusReleased: return localized("bonus_released")
        case .depositCancel: return localized("deposit_cancel")
        case .withdrawalCancel: return localized("withdrawal_cancel")
        case .betPlaced: return localized("bet_placed")
        case .betSettled: return localized("bet_settled")
        case .cashOut: return localized("cashout")
        case .refund: return localized("refund")
        case .productBonus: return localized("product_bonus")
        case .manualAdjustment: return localized("man_adjust")
        case .withdrawalReject: return localized("withdrawal_reject")
        case .automatedWithdrawalThreshold: return localized("automated_withdrawal_threshold")
        case .automatedWithdrawal: return localized("automated_withdrawal")
        default: return nil
        }
    }
}
