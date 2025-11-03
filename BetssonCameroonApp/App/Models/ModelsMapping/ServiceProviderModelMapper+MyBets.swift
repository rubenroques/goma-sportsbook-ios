//
//  ServiceProviderModelMapper+MyBets.swift
//  BetssonCameroonApp
//
//  Created by Assistant on 28/08/2025.
//

import Foundation
import ServicesProvider

extension ServiceProviderModelMapper {
    
    // MARK: - MyBettingHistory Mapping
    
    static func myBettingHistory(_ servicesProviderHistory: ServicesProvider.BettingHistory) -> MyBettingHistory {
        print("[MAPPER_DEBUG] 🔄 ServiceProviderModelMapper: Converting \(servicesProviderHistory.bets.count) ServicesProvider bets")
        let mappedBets = servicesProviderHistory.bets.map { myBet($0) }
        print("[MAPPER_DEBUG] ✅ ServiceProviderModelMapper: Converted to \(mappedBets.count) MyBet objects")
        return MyBettingHistory(bets: mappedBets)
    }
    
    // MARK: - MyBet Mapping
    
    static func myBet(_ servicesProviderBet: ServicesProvider.Bet) -> MyBet {
        // Map bet state and result
        let mappedState = myBetState(servicesProviderBet.state)
        let mappedResult = myBetResult(servicesProviderBet.result)
        let mappedGlobalState = myBetState(servicesProviderBet.globalState)
        
        // Map selections
        let mappedSelections = servicesProviderBet.selections.map { myBetSelection($0) }
        
        // Default currency to EUR if not available (as per existing app logic)
        let currency = "EUR" // ServicesProvider Bet doesn't have currency field, hardcoding as per current implementation
        
        return MyBet(
            identifier: servicesProviderBet.identifier,
            type: servicesProviderBet.type,
            state: mappedState,
            result: mappedResult,
            globalState: mappedGlobalState,
            stake: servicesProviderBet.stake,
            totalOdd: servicesProviderBet.totalOdd,
            potentialReturn: servicesProviderBet.potentialReturn,
            totalReturn: servicesProviderBet.totalReturn,
            currency: currency,
            selections: mappedSelections,
            date: servicesProviderBet.date,
            freebet: servicesProviderBet.freebet,
            partialCashoutReturn: servicesProviderBet.partialCashoutReturn,
            partialCashoutStake: servicesProviderBet.partialCashoutStake,
            ticketCode: servicesProviderBet.ticketCode
        )
    }
    
    // MARK: - MyBetSelection Mapping
    
    static func myBetSelection(_ servicesProviderSelection: ServicesProvider.BetSelection) -> MyBetSelection {
        // Map bet state and result
        let mappedState = myBetState(servicesProviderSelection.state)
        let mappedResult = myBetResult(servicesProviderSelection.result)
        let mappedGlobalState = myBetState(servicesProviderSelection.globalState)
        
        // Map sport using existing sports mapper
        let mappedSport: Sport? = {
            // ServicesProvider.BetSelection uses SportType, convert to app's Sport
            let serviceProviderSportType = servicesProviderSelection.sportType
            return sport(fromServiceProviderSportType: serviceProviderSportType)
        }()
        
        // Map country using existing country mapper
        let mappedCountry: Country? = {
            guard let serviceProviderCountry = servicesProviderSelection.country else { return nil }
            return country(fromServiceProviderCountry: serviceProviderCountry)
        }()
        
        // Map odd format - ServicesProvider uses OddFormat from SharedModels, app has its own OddFormat
        let mappedOdd: OddFormat = {
            switch servicesProviderSelection.odd {
            case .decimal(let odd):
                return .decimal(odd: odd)
            case .fraction(let numerator, let denominator):
                return .fraction(numerator: numerator, denominator: denominator)
            }
        }()
        
        return MyBetSelection(
            identifier: servicesProviderSelection.identifier,
            state: mappedState,
            result: mappedResult,
            globalState: mappedGlobalState,
            eventName: servicesProviderSelection.eventName,
            homeTeamName: servicesProviderSelection.homeTeamName,
            awayTeamName: servicesProviderSelection.awayTeamName,
            eventDate: servicesProviderSelection.eventDate,
            tournamentName: servicesProviderSelection.tournamentName,
            sport: mappedSport,
            marketName: servicesProviderSelection.marketName,
            outcomeName: servicesProviderSelection.outcomeName,
            odd: mappedOdd,
            marketId: servicesProviderSelection.marketId,
            outcomeId: servicesProviderSelection.outcomeId,
            homeResult: servicesProviderSelection.homeResult,
            awayResult: servicesProviderSelection.awayResult,
            eventId: servicesProviderSelection.eventId,
            country: mappedCountry
        )
    }
    
    // MARK: - MyBetState Mapping
    
    static func myBetState(_ servicesProviderState: ServicesProvider.BetState) -> MyBetState {
        switch servicesProviderState {
        case .opened:
            return .opened
        case .closed:
            return .closed
        case .settled:
            return .settled
        case .cancelled:
            return .cancelled
        case .attempted:
            return .attempted
        case .won:
            return .won
        case .lost:
            return .lost
        case .cashedOut:
            return .cashedOut
        case .void:
            return .void
        case .undefined:
            return .undefined
        }
    }
    
    // MARK: - MyBetResult Mapping
    
    static func myBetResult(_ servicesProviderResult: ServicesProvider.BetResult) -> MyBetResult {
        switch servicesProviderResult {
        case .won:
            return .won
        case .lost:
            return .lost
        case .drawn:
            return .drawn
        case .open:
            return .open
        case .void:
            return .void
        case .pending:
            return .pending
        case .notSpecified:
            return .notSpecified
        }
    }
}