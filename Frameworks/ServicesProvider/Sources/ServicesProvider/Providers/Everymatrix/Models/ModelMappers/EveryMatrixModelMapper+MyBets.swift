//
//  EveryMatrixModelMapper+MyBets.swift
//  ServicesProvider
//
//  Created by Assistant on 29/08/2025.
//

import Foundation
import SharedModels

extension EveryMatrixModelMapper {
    
    static func bettingHistory(fromBets bets: [EveryMatrix.Bet]) -> BettingHistory {
        let mappedBets = bets.compactMap { bet(fromEveryMatrixBet: $0) }
        return BettingHistory(bets: mappedBets)
    }
    
    static func bet(fromEveryMatrixBet everyMatrixBet: EveryMatrix.Bet) -> Bet? {
        guard let betId = everyMatrixBet.id,
              let status = everyMatrixBet.status,
              let amount = everyMatrixBet.amount,
              let dateString = everyMatrixBet.placedDate else {
            print("[EveryMatrixModelMapper] ❌ Failed to map bet - missing required fields")
            return nil
        }
        
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: dateString) ?? Date()
        
        let betState = Self.betState(fromStatus: status)
        let betResult = Self.betResult(fromStatus: everyMatrixBet.betSettlementStatus ?? status)
        
        let selections = everyMatrixBet.selections?.compactMap { 
            Self.betSelection(fromEveryMatrixSelection: $0) 
        } ?? []
        
        return Bet(
            identifier: betId,
            type: everyMatrixBet.type ?? "SINGLE",
            state: betState,
            result: betResult,
            globalState: betState,
            stake: amount,
            totalOdd: everyMatrixBet.totalPriceValue ?? 1.0,
            selections: selections,
            potentialReturn: everyMatrixBet.maxWinning,
            totalReturn: everyMatrixBet.potentialNetReturns,
            date: date,
            freebet: everyMatrixBet.freeBet ?? false,
            partialCashoutReturn: everyMatrixBet.overallCashoutAmount,
            partialCashoutStake: everyMatrixBet.betRemainingStake,
            ticketCode: everyMatrixBet.ticketCode
        )
    }
    
    static func betSelection(fromEveryMatrixSelection selection: EveryMatrix.BetSelection) -> BetSelection? {
        guard let selectionId = selection.id ?? selection.outcomeId,
              let eventName = selection.eventName,
              let marketName = selection.marketName,
              let outcomeName = selection.betName else {
            print("[EveryMatrixModelMapper] ❌ Failed to map selection - missing required fields")
            return nil
        }
        
        // Parse eventDate if available
        var eventDate: Date?
        if let dateString = selection.eventDate {
            let formatter = ISO8601DateFormatter()
            eventDate = formatter.date(from: dateString)
        }
        
        // Map sport type using sportId and sportName from API
        let sportType: SportType = {
            let id = selection.sportId ?? "1" // Default to football ID if missing
            let name = selection.sportName ?? "Football" // Default to football name if missing
            return SportType(id: id, name: name)
        }()
        
        let betState = Self.betState(fromStatus: selection.status ?? "PENDING")
        let betResult = Self.betResult(fromStatus: selection.status ?? "PENDING")
        
        return BetSelection(
            identifier: selectionId,
            state: betState,
            result: betResult,
            globalState: betState,
            eventName: eventName,
            homeTeamName: selection.homeParticipantName,
            awayTeamName: selection.awayParticipantName,
            marketName: marketName,
            outcomeName: outcomeName,
            odd: .decimal(odd: selection.priceValue ?? 1.0),
            homeResult: nil, // Not available in current API response
            awayResult: nil, // Not available in current API response
            eventId: selection.eventId ?? selectionId,
            eventDate: eventDate,
            country: nil, // Country mapping would need venue/location data
            sportType: sportType,
            tournamentName: selection.tournamentName ?? "",
            marketId: selection.bettingTypeId,
            outcomeId: selection.outcomeId,
            homeLogoUrl: selection.homeParticipantLogoUrl,
            awayLogoUrl: selection.awayParticipantLogoUrl
        )
    }
    
    static func betState(fromStatus status: String) -> BetState {
        switch status.uppercased() {
        case "OPEN", "PENDING":
            return .opened
        case "WON":
            return .won
        case "LOST":
            return .lost
        case "CASHED_OUT":
            return .cashedOut
        case "VOID":
            return .void
        case "CANCELLED":
            return .cancelled
        case "SETTLED":
            return .settled
        default:
            return .undefined
        }
    }
    
    static func betResult(fromStatus status: String) -> BetResult {
        switch status.uppercased() {
        case "WON":
            return .won
        case "LOST":
            return .lost
        case "VOID":
            return .void
        case "OPEN", "PENDING":
            return .pending
        case "SETTLED":
            return .open
        default:
            return .notSpecified
        }
    }
}