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
            ),
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
            ),
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
            ),
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
            ),
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
            ),
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
            ),
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
    
    // MARK: - Bet Placement Mock Data
    
    static func createMockBetPlacedDetails(scenario: BetPlacementScenario = .singleFootball) -> BetPlacedDetails {
        let response = createMockBetslipPlaceBetResponse(scenario: scenario)
        return BetPlacedDetails(response: response)
    }
    
    static func createMockBetslipPlaceBetResponse(scenario: BetPlacementScenario = .singleFootball) -> BetslipPlaceBetResponse {
        switch scenario {
        case .singleFootball:
            return createSingleFootballBetResponse()
        case .multipleBasketball:
            return createMultipleBasketballBetResponse()
        case .systemBet:
            return createSystemBetResponse()
        case .withCashback:
            return createBetWithCashbackResponse()
        case .usedCashback:
            return createBetUsedCashbackResponse()
        case .spinWheelEligible:
            return createSpinWheelEligibleBetResponse()
        }
    }
    
    static func createMockBettingTickets(scenario: BetPlacementScenario = .singleFootball) -> [BettingTicket] {
        switch scenario {
        case .singleFootball:
            return [createSingleFootballBettingTicket()]
        case .multipleBasketball:
            return createMultipleBasketballBettingTickets()
        case .systemBet:
            return createSystemBettingTickets()
        case .withCashback, .usedCashback:
            return [createCashbackBettingTicket()]
        case .spinWheelEligible:
            return [createSpinWheelEligibleBettingTicket()]
        }
    }
    
    // MARK: - Private Bet Response Creators
    
    private static func createSingleFootballBetResponse() -> BetslipPlaceBetResponse {
        var response = BetslipPlaceBetResponse()
        response.betId = "MOCK_SINGLE_123.0"
        response.betSucceed = true
        response.errorCode = nil
        response.errorMessage = nil
        response.totalPriceValue = 2.15
        response.oddsValidationType = "ACCEPTED"
        response.maxWinningNetto = nil
        response.totalStakeTax = nil
        response.basePossibleProfit = nil
        response.amount = 50.0
        response.maxWinningTax = nil
        response.terminalType = nil
        response.freeBetAmount = nil
        response.minStake = nil
        response.numberOfSelections = 1
        response.bonusBetAmount = nil
        response.maxStake = nil
        response.type = "S"
        response.totalStakeNetto = nil
        response.eachWay = false
        response.baseWinning = nil
        response.possibleProfit = nil
        response.freeBet = false
        response.maxWinning = 107.50
        response.selections = [
            BetslipPlaceEntry(
                id: "OFFER_001",
                outcomeId: "OUTCOME_001",
                eventId: "EVENT_001",
                priceValue: 2.15
            )
        ]
        response.betslipId = "12345"
        return response
    }
    
    private static func createMultipleBasketballBetResponse() -> BetslipPlaceBetResponse {
        var response = BetslipPlaceBetResponse()
        response.betId = "MOCK_MULTI_456.0"
        response.betSucceed = true
        response.errorCode = nil
        response.errorMessage = nil
        response.totalPriceValue = 4.18 // 1.90 * 2.20
        response.oddsValidationType = "ACCEPTED"
        response.maxWinningNetto = nil
        response.totalStakeTax = nil
        response.basePossibleProfit = nil
        response.amount = 30.0
        response.maxWinningTax = nil
        response.terminalType = nil
        response.freeBetAmount = nil
        response.minStake = nil
        response.numberOfSelections = 2
        response.bonusBetAmount = nil
        response.maxStake = nil
        response.type = "A"
        response.totalStakeNetto = nil
        response.eachWay = false
        response.baseWinning = nil
        response.possibleProfit = nil
        response.freeBet = false
        response.maxWinning = 125.40
        response.selections = [
            BetslipPlaceEntry(
                id: "OFFER_002",
                outcomeId: "OUTCOME_002",
                eventId: "EVENT_002",
                priceValue: 1.90
            ),
            BetslipPlaceEntry(
                id: "OFFER_003",
                outcomeId: "OUTCOME_003",
                eventId: "EVENT_003",
                priceValue: 2.20
            )
        ]
        response.betslipId = "23456"
        return response
    }
    
    private static func createSystemBetResponse() -> BetslipPlaceBetResponse {
        var response = BetslipPlaceBetResponse()
        response.betId = "MOCK_SYS_789.0"
        response.betSucceed = true
        response.errorCode = nil
        response.errorMessage = nil
        response.totalPriceValue = nil // Systems don't have single total price
        response.oddsValidationType = "ACCEPTED"
        response.maxWinningNetto = nil
        response.totalStakeTax = nil
        response.basePossibleProfit = nil
        response.amount = 90.0 // 3 combinations of 30 each
        response.maxWinningTax = nil
        response.terminalType = nil
        response.freeBetAmount = nil
        response.minStake = nil
        response.numberOfSelections = 3
        response.bonusBetAmount = nil
        response.maxStake = nil
        response.type = "SYSTEM"
        response.totalStakeNetto = nil
        response.eachWay = false
        response.baseWinning = nil
        response.possibleProfit = nil
        response.freeBet = false
        response.maxWinning = 445.50
        response.selections = [
            BetslipPlaceEntry(
                id: "OFFER_004",
                outcomeId: "OUTCOME_004",
                eventId: "EVENT_004",
                priceValue: 1.80
            ),
            BetslipPlaceEntry(
                id: "OFFER_005",
                outcomeId: "OUTCOME_005",
                eventId: "EVENT_005",
                priceValue: 2.20
            ),
            BetslipPlaceEntry(
                id: "OFFER_006",
                outcomeId: "OUTCOME_006",
                eventId: "EVENT_006",
                priceValue: 2.50
            )
        ]
        response.betslipId = "34567"
        return response
    }
    
    private static func createBetWithCashbackResponse() -> BetslipPlaceBetResponse {
        var response = BetslipPlaceBetResponse()
        response.betId = "MOCK_CASH_101.0"
        response.betSucceed = true
        response.errorCode = nil
        response.errorMessage = nil
        response.totalPriceValue = 2.85
        response.oddsValidationType = "ACCEPTED"
        response.maxWinningNetto = nil
        response.totalStakeTax = nil
        response.basePossibleProfit = nil
        response.amount = 40.0
        response.maxWinningTax = nil
        response.terminalType = nil
        response.freeBetAmount = nil
        response.minStake = nil
        response.numberOfSelections = 1
        response.bonusBetAmount = nil
        response.maxStake = nil
        response.type = "S"
        response.totalStakeNetto = nil
        response.eachWay = false
        response.baseWinning = nil
        response.possibleProfit = nil
        response.freeBet = false
        response.maxWinning = 114.0
        response.selections = [
            BetslipPlaceEntry(
                id: "OFFER_CASH_001",
                outcomeId: "OUTCOME_CASH_001",
                eventId: "EVENT_CASH_001",
                priceValue: 2.85
            )
        ]
        response.betslipId = "45678"
        return response
    }
    
    private static func createBetUsedCashbackResponse() -> BetslipPlaceBetResponse {
        var response = BetslipPlaceBetResponse()
        response.betId = "MOCK_USED_CASH_202.0"
        response.betSucceed = true
        response.errorCode = nil
        response.errorMessage = nil
        response.totalPriceValue = 1.95
        response.oddsValidationType = "ACCEPTED"
        response.maxWinningNetto = nil
        response.totalStakeTax = nil
        response.basePossibleProfit = nil
        response.amount = 25.0
        response.maxWinningTax = nil
        response.terminalType = nil
        response.freeBetAmount = nil
        response.minStake = nil
        response.numberOfSelections = 1
        response.bonusBetAmount = nil
        response.maxStake = nil
        response.type = "S"
        response.totalStakeNetto = nil
        response.eachWay = false
        response.baseWinning = nil
        response.possibleProfit = nil
        response.freeBet = false
        response.maxWinning = 48.75
        response.selections = [
            BetslipPlaceEntry(
                id: "OFFER_USED_CASH_001",
                outcomeId: "OUTCOME_USED_CASH_001",
                eventId: "EVENT_USED_CASH_001",
                priceValue: 1.95
            )
        ]
        response.betslipId = "56789"
        return response
    }
    
    private static func createSpinWheelEligibleBetResponse() -> BetslipPlaceBetResponse {
        var response = BetslipPlaceBetResponse()
        response.betId = "MOCK_WHEEL_303.0"
        response.betSucceed = true
        response.errorCode = nil
        response.errorMessage = nil
        response.totalPriceValue = 3.50
        response.oddsValidationType = "ACCEPTED"
        response.maxWinningNetto = nil
        response.totalStakeTax = nil
        response.basePossibleProfit = nil
        response.amount = 100.0
        response.maxWinningTax = nil
        response.terminalType = nil
        response.freeBetAmount = nil
        response.minStake = nil
        response.numberOfSelections = 1
        response.bonusBetAmount = nil
        response.maxStake = nil
        response.type = "S"
        response.totalStakeNetto = nil
        response.eachWay = false
        response.baseWinning = nil
        response.possibleProfit = nil
        response.freeBet = false
        response.maxWinning = 350.0
        response.selections = [
            BetslipPlaceEntry(
                id: "OFFER_WHEEL_001",
                outcomeId: "OUTCOME_WHEEL_001",
                eventId: "EVENT_WHEEL_001",
                priceValue: 3.50
            )
        ]
        response.betslipId = "67890"
        return response
    }
    
    // MARK: - Private Betting Ticket Creators
    
    private static func createSingleFootballBettingTicket() -> BettingTicket {
        return BettingTicket(
            id: "OFFER_001",
            outcomeId: "OUTCOME_001",
            marketId: "MARKET_001",
            matchId: "EVENT_001",
            decimalOdd: 2.15,
            isAvailable: true,
            matchDescription: "Manchester United vs Liverpool",
            marketDescription: "1X2",
            outcomeDescription: "Manchester United",
            homeParticipantName: "Manchester United",
            awayParticipantName: "Liverpool",
            sportIdCode: "1",
            competition: "Premier League",
            date: Calendar.current.date(byAdding: .hour, value: 2, to: Date())
        )
    }
    
    private static func createMultipleBasketballBettingTickets() -> [BettingTicket] {
        return [
            BettingTicket(
                id: "OFFER_002",
                outcomeId: "OUTCOME_002",
                marketId: "MARKET_002",
                matchId: "EVENT_002",
                decimalOdd: 1.90,
                isAvailable: true,
                matchDescription: "Lakers vs Warriors",
                marketDescription: "Point Spread",
                outcomeDescription: "Lakers -5.5",
                homeParticipantName: "Los Angeles Lakers",
                awayParticipantName: "Golden State Warriors",
                sportIdCode: "2",
                competition: "NBA",
                date: Calendar.current.date(byAdding: .hour, value: 4, to: Date())
            ),
            BettingTicket(
                id: "OFFER_003",
                outcomeId: "OUTCOME_003",
                marketId: "MARKET_003",
                matchId: "EVENT_003",
                decimalOdd: 2.20,
                isAvailable: true,
                matchDescription: "Celtics vs Heat",
                marketDescription: "Total Points",
                outcomeDescription: "Over 220.5",
                homeParticipantName: "Boston Celtics", 
                awayParticipantName: "Miami Heat",
                sportIdCode: "2",
                competition: "NBA",
                date: Calendar.current.date(byAdding: .hour, value: 6, to: Date())
            )
        ]
    }
    
    private static func createSystemBettingTickets() -> [BettingTicket] {
        return [
            BettingTicket(
                id: "OFFER_004",
                outcomeId: "OUTCOME_004",
                marketId: "MARKET_004",
                matchId: "EVENT_004",
                decimalOdd: 1.80,
                isAvailable: true,
                matchDescription: "PSG vs Lyon",
                marketDescription: "Total Goals",
                outcomeDescription: "Over 2.5",
                homeParticipantName: "Paris Saint-Germain",
                awayParticipantName: "Olympique Lyon",
                sportIdCode: "1",
                competition: "Ligue 1",
                date: Calendar.current.date(byAdding: .hour, value: 3, to: Date())
            ),
            BettingTicket(
                id: "OFFER_005",
                outcomeId: "OUTCOME_005",
                marketId: "MARKET_005",
                matchId: "EVENT_005",
                decimalOdd: 2.20,
                isAvailable: true,
                matchDescription: "Monaco vs Nice",
                marketDescription: "1X2",
                outcomeDescription: "Monaco",
                homeParticipantName: "AS Monaco",
                awayParticipantName: "OGC Nice",
                sportIdCode: "1",
                competition: "Ligue 1",
                date: Calendar.current.date(byAdding: .hour, value: 5, to: Date())
            ),
            BettingTicket(
                id: "OFFER_006",
                outcomeId: "OUTCOME_006",
                marketId: "MARKET_006",
                matchId: "EVENT_006",
                decimalOdd: 2.50,
                isAvailable: true,
                matchDescription: "Marseille vs Lille",
                marketDescription: "Both Teams to Score",
                outcomeDescription: "No",
                homeParticipantName: "Olympique Marseille",
                awayParticipantName: "LOSC Lille",
                sportIdCode: "1",
                competition: "Ligue 1",
                date: Calendar.current.date(byAdding: .hour, value: 7, to: Date())
            )
        ]
    }
    
    private static func createCashbackBettingTicket() -> BettingTicket {
        return BettingTicket(
            id: "OFFER_CASH_001",
            outcomeId: "OUTCOME_CASH_001",
            marketId: "MARKET_CASH_001",
            matchId: "EVENT_CASH_001",
            decimalOdd: 2.85,
            isAvailable: true,
            matchDescription: "Djokovic vs Nadal",
            marketDescription: "Match Winner",
            outcomeDescription: "Novak Djokovic",
            homeParticipantName: "Novak Djokovic",
            awayParticipantName: "Rafael Nadal",
            sportIdCode: "3",
            competition: "ATP Masters",
            date: Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        )
    }
    
    private static func createSpinWheelEligibleBettingTicket() -> BettingTicket {
        return BettingTicket(
            id: "OFFER_WHEEL_001",
            outcomeId: "OUTCOME_WHEEL_001",
            marketId: "MARKET_WHEEL_001",
            matchId: "EVENT_WHEEL_001",
            decimalOdd: 3.50,
            isAvailable: true,
            matchDescription: "Real Madrid vs Barcelona",
            marketDescription: "1X2",
            outcomeDescription: "Real Madrid",
            homeParticipantName: "Real Madrid",
            awayParticipantName: "FC Barcelona",
            sportIdCode: "1",
            competition: "El Clasico",
            date: Calendar.current.date(byAdding: .hour, value: 8, to: Date())
        )
    }
}

enum BetPlacementScenario {
    case singleFootball
    case multipleBasketball
    case systemBet
    case withCashback
    case usedCashback
    case spinWheelEligible
}


#endif

// swiftlint: enable function_parameter_count
