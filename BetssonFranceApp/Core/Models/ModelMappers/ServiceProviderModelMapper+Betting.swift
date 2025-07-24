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
                               status: bet.globalState.rawValue,
                               placedDate: bet.date,
                               settledDate: nil,
                               freeBet: bet.freebet,
                               partialCashoutReturn: bet.partialCashoutReturn,
                               partialCashoutStake: bet.partialCashoutStake,
                               betShareToken: bet.shareId,
                               betslipId: bet.betslipId,
                               cashbackReturn: bet.cashbackReturn,
                               freebetReturn: bet.freebetReturn,
                               potentialCashbackReturn: bet.potentialCashbackReturn,
                               potentialFreebetReturn: bet.potentialFreebetReturn)
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
        case .void: status = .void
        case .undefined: status = .undefined
        }
        
        // betResult is global, betLegStatus is the selection real result
        let result: BetSelectionResult
        switch betSelection.state {
        case .opened: result = .open
        case .won: result = .won
        case .lost: result = .lost
        case .void: result = .void
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
                                                                sportId: betSelection.sportType.iconId,
                                                                sportName: betSelection.sportType.name,
                                                                venueId: betSelection.country?.iso2Code,
                                                                venueName: betSelection.country?.name,
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
        
        var transactionType = Self.stringFromTransactionType(transactionType: transactionDetail.type)
        
        if transactionDetail.type == .withdrawal && transactionDetail.reference != nil {
            transactionType = Self.stringFromTransactionType(transactionType: .automatedWithdrawal)
        }
        
        if transactionDetail.amount < 0.0 {
            valueType = .loss
        }
        else if transactionDetail.amount > 0.0 {
            valueType = .won
        }
        else {
            valueType = .neutral
        }
        
        if let reference = transactionDetail.reference ?? transactionDetail.escrowType {
            switch reference.lowercased() {
            case "esc_review", "esc_an_win", "esc_aml":
                transactionType = localized("administrative_costs")
                valueType = .neutral
            case "esc_rg_def":
                transactionType = localized("automated_withdrawal_threshold")
            default:
                break
            }
        }

        return TransactionHistory(transactionID: "\(transactionDetail.id)",
                                  date: transactionDetail.date,
                                  type: transactionType ?? "",
                                  transactionType: transactionDetail.type,
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
                                  paymentId: transactionDetail.paymentId,
                                  reference: transactionDetail.reference,
                                  escrowTranType: transactionDetail.escrowTranType,
                                  escrowTranSubType: transactionDetail.escrowTranSubType,
                                  escrowType: transactionDetail.escrowType)
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
        case .depositReturned:
            return localized("deposit_refunded")
        default: return nil
        }
    }

    static func betPlacedDetailsArray(fromPlacedBetsResponse placedBetsResponse: PlacedBetsResponse) -> [BetPlacedDetails] {
        let betPlacedDetailsArray: [BetPlacedDetails] = placedBetsResponse.bets.map { (placedBetEntry: PlacedBetEntry) -> BetPlacedDetails in
            let totalPriceValue = placedBetEntry.betLegs.map(\.odd).reduce(1.0, *)
            let response = BetslipPlaceBetResponse(betId: placedBetEntry.identifier,
                                                   betSucceed: true,
                                                   totalPriceValue: totalPriceValue,
                                                   maxWinning: placedBetEntry.potentialReturn)
            return BetPlacedDetails(response: response)
        }
        return betPlacedDetailsArray
    }
    
    static func betlipPlacedEntry(fromPlacedBetLeg placedBetleg: ServicesProvider.PlacedBetLeg) -> BetslipPlaceEntry {
        
        return BetslipPlaceEntry(id: placedBetleg.identifier, outcomeId: nil, eventId: nil, priceValue: nil)
    }
    
    static func betHistoryEntrySelection(fromBettingTicket bettingTicket: BettingTicket) -> BetHistoryEntrySelection {
        
        return BetHistoryEntrySelection(outcomeId: bettingTicket.outcomeId,
                                        status: .opened,
                                        result: .open,
                                        priceValue: bettingTicket.decimalOdd,
                                        sportId: bettingTicket.sport?.id,
                                        sportName: bettingTicket.sport?.alphaId,
                                        venueId: bettingTicket.venue?.id,
                                        venueName: bettingTicket.venue?.isoCode,
                                        tournamentId: nil,
                                        tournamentName: bettingTicket.competition,
                                        eventId: bettingTicket.matchId,
                                        eventStatusId: nil,
                                        eventName: bettingTicket.matchDescription,
                                        eventResult: nil,
                                        eventDate: bettingTicket.date,
                                        bettingTypeId: bettingTicket.id,
                                        bettingTypeName: nil,
                                        bettingTypeEventPartId: nil,
                                        bettingTypeEventPartName: nil,
                                        homeParticipantName: bettingTicket.homeParticipantName,
                                        awayParticipantName: bettingTicket.awayParticipantName,
                                        homeParticipantScore: nil,
                                        awayParticipantScore: nil,
                                        marketName: bettingTicket.marketDescription,
                                        betName: bettingTicket.outcomeDescription)
    }
    
    static func bettingTicket(fromBetHistoryEntry betHistoryEntry: BetHistoryEntry) -> [BettingTicket] {
        guard let selections = betHistoryEntry.selections else { return [] }
        
        var tickets: [BettingTicket] = []
        
        for selection in selections {
        
            let matchDescription = "\(selection.homeParticipantName ?? "") x \(selection.awayParticipantName ?? "")"
            let marketDescription = selection.marketName ?? ""
            let outcomeDescription = selection.betName ?? ""
            
            tickets.append(
                BettingTicket(id: selection.outcomeId,
                              outcomeId: selection.outcomeId,
                              marketId: selection.bettingTypeId ?? "",
                              matchId: selection.eventId ?? "",
                              decimalOdd: selection.priceValue ?? 1.0,
                              isAvailable: true,
                              matchDescription: matchDescription,
                              marketDescription: marketDescription,
                              outcomeDescription: outcomeDescription,
                              homeParticipantName: selection.homeParticipantName,
                              awayParticipantName: selection.awayParticipantName,
                              sportIdCode: selection.sportId)

            )
            
        }
        
        return tickets
        
    }
}
