//
//  MockDataFactory.swift
//  Sportsbook
//
//  Created by Ruben Roques on 26/07/2025.
//
//
// swiftlint:disable function_parameter_count

import Foundation
import ServicesProvider

#if DEBUG

class MockDataFactory {
    
    // MARK: - BetHistoryEntry Creation
    
    static func createMockBetHistoryEntry() -> BetHistoryEntry {
        let mockSelections = [
            createMockBetHistoryEntrySelection(
                outcomeId: "1001",
                sportName: "Football",
                eventName: "Manchester United vs Liverpool",
                homeParticipantName: "Manchester United",
                awayParticipantName: "Liverpool",
                marketName: "1X2",
                betName: "1",
                priceValue: 2.50,
                status: .settled,
                result: .won
            ),
            createMockBetHistoryEntrySelection(
                outcomeId: "1002",
                sportName: "Football",
                eventName: "Barcelona vs Real Madrid",
                homeParticipantName: "Barcelona",
                awayParticipantName: "Real Madrid",
                marketName: "Total Goals",
                betName: "Over 2.5",
                priceValue: 1.85,
                status: .settled,
                result: .won
            ),
            createMockBetHistoryEntrySelection(
                outcomeId: "1003",
                sportName: "Football",
                eventName: "Bayern Munich vs Borussia Dortmund",
                homeParticipantName: "Bayern Munich",
                awayParticipantName: "Borussia Dortmund",
                marketName: "Both Teams to Score",
                betName: "Yes",
                priceValue: 1.65,
                status: .settled,
                result: .won
            )
        ]
        
        return BetHistoryEntry(
            betId: "MOCK123456789",
            selections: mockSelections,
            type: "multiple",
            systemBetType: nil,
            amount: 25.0,
            totalBetAmount: 25.0,
            freeBetAmount: nil,
            bonusBetAmount: nil,
            currency: "EUR",
            maxWinning: 189.06,
            totalPriceValue: 7.5625, // 2.50 * 1.85 * 1.65
            overallBetReturns: 189.06,
            numberOfSelections: 3,
            status: "WON",
            placedDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
            settledDate: Calendar.current.date(byAdding: .hour, value: -6, to: Date()),
            freeBet: false,
            partialCashoutReturn: nil,
            partialCashoutStake: nil,
            betShareToken: "mock_share_token_12345",
            betslipId: 98765,
            cashbackReturn: nil,
            freebetReturn: nil,
            potentialCashbackReturn: nil,
            potentialFreebetReturn: nil
        )
    }
    
    static func createMockSingleBetHistoryEntry() -> BetHistoryEntry {
        let mockSelection = createMockBetHistoryEntrySelection(
            outcomeId: "2001",
            sportName: "Tennis",
            eventName: "Novak Djokovic vs Rafael Nadal",
            homeParticipantName: "Novak Djokovic",
            awayParticipantName: "Rafael Nadal",
            marketName: "Match Winner",
            betName: "Novak Djokovic",
            priceValue: 1.95,
            status: .opened,
            result: .open
        )
        
        return BetHistoryEntry(
            betId: "SINGLE789012",
            selections: [mockSelection],
            type: "single",
            systemBetType: nil,
            amount: 50.0,
            totalBetAmount: 50.0,
            freeBetAmount: nil,
            bonusBetAmount: nil,
            currency: "EUR",
            maxWinning: 97.50,
            totalPriceValue: 1.95,
            overallBetReturns: nil,
            numberOfSelections: 1,
            status: "OPENED",
            placedDate: Calendar.current.date(byAdding: .hour, value: -3, to: Date()),
            settledDate: nil,
            freeBet: false,
            partialCashoutReturn: nil,
            partialCashoutStake: nil,
            betShareToken: "mock_single_token_67890",
            betslipId: 54321,
            cashbackReturn: nil,
            freebetReturn: nil,
            potentialCashbackReturn: nil,
            potentialFreebetReturn: nil
        )
    }
    
    // MARK: - Open Bet Variations
    
    static func createMockOpenFootballMultiple() -> BetHistoryEntry {
        let mockSelections = [
            createMockBetHistoryEntrySelection(
                outcomeId: "3001",
                sportName: "Football",
                eventName: "Chelsea vs Arsenal",
                homeParticipantName: "Chelsea",
                awayParticipantName: "Arsenal",
                marketName: "1X2",
                betName: "1",
                priceValue: 2.10,
                status: .opened,
                result: .open
            ),
            createMockBetHistoryEntrySelection(
                outcomeId: "3002",
                sportName: "Football", 
                eventName: "Tottenham vs Manchester City",
                homeParticipantName: "Tottenham",
                awayParticipantName: "Manchester City",
                marketName: "Both Teams to Score",
                betName: "Yes",
                priceValue: 1.70,
                status: .opened,
                result: .open
            )
        ]
        
        return BetHistoryEntry(
            betId: "OPEN_MULTI_001",
            selections: mockSelections,
            type: "multiple",
            systemBetType: nil,
            amount: 20.0,
            totalBetAmount: 20.0,
            freeBetAmount: nil,
            bonusBetAmount: nil,
            currency: "EUR",
            maxWinning: 71.40, // 20 * 2.10 * 1.70
            totalPriceValue: 3.57,
            overallBetReturns: nil,
            numberOfSelections: 2,
            status: "OPENED",
            placedDate: Calendar.current.date(byAdding: .minute, value: -45, to: Date()),
            settledDate: nil,
            freeBet: false,
            partialCashoutReturn: nil,
            partialCashoutStake: nil,
            betShareToken: "open_multi_token_001",
            betslipId: 11111,
            cashbackReturn: nil,
            freebetReturn: nil,
            potentialCashbackReturn: nil,
            potentialFreebetReturn: nil
        )
    }
    
    static func createMockOpenBasketballSingle() -> BetHistoryEntry {
        let mockSelection = createMockBetHistoryEntrySelection(
            outcomeId: "4001",
            sportName: "Basketball",
            eventName: "Lakers vs Warriors",
            homeParticipantName: "Los Angeles Lakers",
            awayParticipantName: "Golden State Warriors",
            marketName: "Point Spread",
            betName: "Lakers -5.5",
            priceValue: 1.91,
            status: .opened,
            result: .open
        )
        
        return BetHistoryEntry(
            betId: "OPEN_BASKET_001",
            selections: [mockSelection],
            type: "single",
            systemBetType: nil,
            amount: 100.0,
            totalBetAmount: 100.0,
            freeBetAmount: nil,
            bonusBetAmount: nil,
            currency: "EUR",
            maxWinning: 191.0,
            totalPriceValue: 1.91,
            overallBetReturns: nil,
            numberOfSelections: 1,
            status: "OPENED",
            placedDate: Calendar.current.date(byAdding: .minute, value: -30, to: Date()),
            settledDate: nil,
            freeBet: false,
            partialCashoutReturn: nil,
            partialCashoutStake: nil,
            betShareToken: "open_basket_token_001",
            betslipId: 22222,
            cashbackReturn: nil,
            freebetReturn: nil,
            potentialCashbackReturn: nil,
            potentialFreebetReturn: nil
        )
    }
    
    static func createMockOpenSystemBet() -> BetHistoryEntry {
        let mockSelections = [
            createMockBetHistoryEntrySelection(
                outcomeId: "5001",
                sportName: "Football",
                eventName: "PSG vs Lyon",
                homeParticipantName: "Paris Saint-Germain",
                awayParticipantName: "Olympique Lyon",
                marketName: "Total Goals",
                betName: "Over 2.5",
                priceValue: 1.80,
                status: .opened,
                result: .open
            ),
            createMockBetHistoryEntrySelection(
                outcomeId: "5002",
                sportName: "Football",
                eventName: "Monaco vs Nice",
                homeParticipantName: "AS Monaco",
                awayParticipantName: "OGC Nice",
                marketName: "1X2",
                betName: "1",
                priceValue: 2.20,
                status: .opened,
                result: .open
            ),
            createMockBetHistoryEntrySelection(
                outcomeId: "5003",
                sportName: "Football",
                eventName: "Marseille vs Lille",
                homeParticipantName: "Olympique Marseille",
                awayParticipantName: "LOSC Lille",
                marketName: "Both Teams to Score",
                betName: "No",
                priceValue: 2.50,
                status: .opened,
                result: .open
            )
        ]
        
        return BetHistoryEntry(
            betId: "SYS_OPEN_001",
            selections: mockSelections,
            type: "system",
            systemBetType: "2/3",
            amount: 30.0,
            totalBetAmount: 90.0, // 3 combinations of 30 each
            freeBetAmount: nil,
            bonusBetAmount: nil,
            currency: "EUR",
            maxWinning: 445.50, // Complex system calculation
            totalPriceValue: nil, // System bets don't have single total price
            overallBetReturns: nil,
            numberOfSelections: 3,
            status: "OPENED", 
            placedDate: Calendar.current.date(byAdding: .hour, value: -1, to: Date()),
            settledDate: nil,
            freeBet: false,
            partialCashoutReturn: nil,
            partialCashoutStake: nil,
            betShareToken: "sys_open_token_001",
            betslipId: 33333,
            cashbackReturn: nil,
            freebetReturn: nil,
            potentialCashbackReturn: nil,
            potentialFreebetReturn: nil
        )
    }
    
    // MARK: - BetHistoryEntrySelection Creation
    
    static func createMockBetHistoryEntrySelection(
        outcomeId: String,
        sportName: String,
        eventName: String,
        homeParticipantName: String,
        awayParticipantName: String,
        marketName: String,
        betName: String,
        priceValue: Double,
        status: BetSelectionStatus,
        result: BetSelectionResult
    ) -> BetHistoryEntrySelection {
        
        return BetHistoryEntrySelection(
            outcomeId: outcomeId,
            status: status,
            result: result,
            priceValue: priceValue,
            sportId: "1",
            sportName: sportName,
            venueId: "venue_001",
            venueName: "Stadium Mock",
            tournamentId: "tournament_001",
            tournamentName: "Premier League",
            eventId: "event_\(outcomeId)",
            eventStatusId: "1",
            eventName: eventName,
            eventResult: status == .settled ? "2-1" : nil,
            eventDate: Calendar.current.date(byAdding: .hour, value: -1, to: Date()),
            bettingTypeId: "betting_type_001",
            bettingTypeName: marketName,
            bettingTypeEventPartId: "1",
            bettingTypeEventPartName: "Full Time",
            homeParticipantName: homeParticipantName,
            awayParticipantName: awayParticipantName,
            homeParticipantScore: status == .settled ? "2" : nil,
            awayParticipantScore: status == .settled ? "1" : nil,
            marketName: marketName,
            betName: betName
        )
    }
    
    // MARK: - GrantedWinBoostInfo Creation
    
    static func createMockGrantedWinBoostInfo() -> GrantedWinBoostInfo {
        let awardedTier = WheelAwardedTier(
            configurationId: "tier_config_1",
            name: "Bronze Boost",
            boostMultiplier: 1.15
        )
        
        return GrantedWinBoostInfo(
            winBoostId: "mock_boost_123",
            gameTranId: "mock_game_trans_456",
            status: "granted",
            awardedTier: awardedTier,
            boostAmount: 15.0
        )
    }
    
    // MARK: - Helper Methods
    
    static func createMockCountryCodes() -> [String] {
        return ["GB", "ES", "FR", "DE", "IT"]
    }
    
    static func createMockMyTicketCellViewModel(with betHistoryEntry: BetHistoryEntry) -> MyTicketCellViewModel {
        return MyTicketCellViewModel(ticket: betHistoryEntry, allowedCashback: true)
    }
}

#endif

// swiftlint: enable function_parameter_count
