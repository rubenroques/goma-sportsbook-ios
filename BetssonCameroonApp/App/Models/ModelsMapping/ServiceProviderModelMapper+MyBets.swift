//
//  ServiceProviderModelMapper+MyBets.swift
//  BetssonCameroonApp
//
//  Created on 28/08/2025.
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

        // Use currency from ServicesProvider.Bet (now includes currency field from API)
        let currency = servicesProviderBet.currency

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
            marketTypeId: servicesProviderSelection.marketName,
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
    
    // MARK: - MyBet from BetPlacedDetails Conversion
    
    /// Converts BetPlacedDetails and BettingTickets to MyBet
    /// Uses the first betPlacedDetails entry and matches it with bettingTickets to create selections
    static func myBet(from betPlacedDetails: [BetPlacedDetails], bettingTickets: [BettingTicket]) -> MyBet? {
        guard let firstBetDetail = betPlacedDetails.first else {
            print("[MAPPER] ❌ No bet placed details available")
            return nil
        }
        
        let response = firstBetDetail.response
        
        guard let betId = response.betId else {
            print("[MAPPER] ❌ No bet ID in response")
            return nil
        }
        
        // Extract bet information from response
        let stake = response.amount ?? 0.0
        let totalOdd = response.totalPriceValue ?? 1.0
        let potentialReturn = response.maxWinning
        let betType = response.type ?? "SINGLE"
        let date = Date() // Use current date since we don't have placedDate in BetslipPlaceBetResponse
        
        // Create selections by matching bettingTickets with response selections
        let selections: [MyBetSelection] = {
            guard let responseSelections = response.selections else {
                // Fallback: create from bettingTickets only
                return bettingTickets.map { ticket in
                    myBetSelection(from: ticket, priceValue: nil)
                }
            }
            
            // Match response selections with betting tickets
            return responseSelections.compactMap { responseSelection in
                // Find matching ticket by identifier
                let matchingTicket = bettingTickets.first { ticket in
                    ticket.id == responseSelection.id
                }
                
                if let ticket = matchingTicket {
                    return myBetSelection(from: ticket, priceValue: responseSelection.priceValue)
                } else {
                    // Create minimal selection from response only
                    return myBetSelection(from: responseSelection)
                }
            }
        }()
        
        return MyBet(
            identifier: betId,
            type: betType,
            state: .opened,
            result: .notSpecified,
            globalState: .opened,
            stake: stake,
            totalOdd: totalOdd,
            potentialReturn: potentialReturn,
            totalReturn: nil,
            currency: "XAF", // Default currency, could be extracted if available
            selections: selections,
            date: date,
            freebet: response.freeBet ?? false,
            partialCashoutReturn: nil,
            partialCashoutStake: nil,
            ticketCode: response.betslipId
        )
    }
    
    /// Creates MyBetSelection from BettingTicket
    private static func myBetSelection(from ticket: BettingTicket, priceValue: Double?) -> MyBetSelection {
        // Use priceValue from response if available, otherwise use ticket odd
        let odd: OddFormat
        if let priceValue = priceValue {
            odd = .decimal(odd: priceValue)
        } else {
            odd = ticket.odd
        }
        
        return MyBetSelection(
            identifier: ticket.id,
            state: .opened,
            result: .notSpecified,
            globalState: .opened,
            eventName: ticket.matchDescription,
            homeTeamName: ticket.homeParticipantName,
            awayTeamName: ticket.awayParticipantName,
            eventDate: ticket.date,
            tournamentName: ticket.competition ?? "",
            sport: ticket.sport,
            marketName: ticket.marketDescription,
            outcomeName: ticket.outcomeDescription,
            odd: odd,
            marketId: ticket.marketId,
            marketTypeId: ticket.marketTypeId,
            outcomeId: ticket.outcomeId,
            homeResult: nil,
            awayResult: nil,
            eventId: ticket.matchId,
            country: nil
        )
    }
    
    /// Creates minimal MyBetSelection from BetslipPlaceEntry (when ticket data is not available)
    private static func myBetSelection(from entry: BetslipPlaceEntry) -> MyBetSelection? {
        guard let priceValue = entry.priceValue else {
            return nil
        }
        
        return MyBetSelection(
            identifier: entry.id,
            state: .opened,
            result: .notSpecified,
            globalState: .opened,
            eventName: "Unknown Event",
            homeTeamName: nil,
            awayTeamName: nil,
            eventDate: nil,
            tournamentName: "",
            sport: nil,
            marketName: "Unknown Market",
            outcomeName: "Unknown Outcome",
            odd: .decimal(odd: priceValue),
            marketId: nil,
            marketTypeId: nil,
            outcomeId: entry.outcomeId,
            homeResult: nil,
            awayResult: nil,
            eventId: entry.eventId ?? entry.id,
            country: nil
        )
    }
}
