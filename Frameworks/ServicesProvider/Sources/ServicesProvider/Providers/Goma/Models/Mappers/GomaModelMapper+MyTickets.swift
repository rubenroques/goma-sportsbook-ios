//
//  GomaModelMapper+MyTickets.swift
//
//
//  Created by André Lascas on 22/01/2024.
//

import Foundation
import SharedModels

extension GomaModelMapper {
    
    static func bettingHistory(fromMyTicketsResponse myTicketsResponse: GomaModels.MyTicketsResponse) -> BettingHistory {
        let bets = myTicketsResponse.data.map({
            Self.bet(fromMyTicket: $0)
        })
        let bettingHistory = BettingHistory(bets: bets)
        return bettingHistory
    }
    
    static func bet(fromMyTicket myTicket: GomaModels.MyTicket) -> Bet {
        
        let betState = Self.betState(fromMyTicketStatus: myTicket.status)
        
        let selections = myTicket.selections.map({
            Self.betSelection(fromMyTicketSelection: $0)
        })
        
        var betDate = Date()
        let dateString = myTicket.createdAt ?? ""

        // Attempt to parse the string into a Date object
        if let date = self.parseDateString(dateString: dateString) {
            betDate = date
        } else {
            print("Unable to parse the date string from my ticket bet.")
        }
                
        return Bet(identifier: "\(myTicket.id)",
                   type: myTicket.type,
                   state: betState,
                   result: .notSpecified,
                   globalState: betState,
                   stake: myTicket.stake,
                   totalOdd: myTicket.odds,
                   currency: "EUR",
                   selections: selections,
                   potentialReturn: myTicket.possibleWinnings,
                   date: betDate,
                   freebet: false,
                   shareId: myTicket.shareId)
    }
    
    /// Maps a Goma MyTicketSelection to the unified BetSelection model
    /// - Parameter myTicketSelection: The source Goma ticket selection
    /// - Returns: A unified BetSelection instance
    static func betSelection(fromMyTicketSelection myTicketSelection: GomaModels.MyTicketSelection) -> BetSelection {
        // Map bet state from ticket status
        let betState = Self.betState(fromMyTicketStatus: myTicketSelection.status)
        
        // Map country from region, defaulting to empty string if no region
        let country = Country(isoCode: myTicketSelection.event.region?.isoCode ?? "")
        
        // Convert scores to string representation
        var homeScore: String? = nil
        var awayScore: String? = nil
        
        if let betHomeScore = myTicketSelection.event.homeScore {
            homeScore = "\(betHomeScore)"
        }
        
        if let betAwayScore = myTicketSelection.event.awayScore {
            awayScore = "\(betAwayScore)"
        }
        
        // Map sport type using the existing helper
        let mappedSportType = Self.sportType(fromSport: myTicketSelection.event.sport)
        
        // Create event name by combining home and away team names
        let eventName = "\(myTicketSelection.event.homeTeam) x \(myTicketSelection.event.awayTeam)"
        
        return BetSelection(
            // Core properties
            identifier: "\(myTicketSelection.id)",
            state: betState,
            result: .notSpecified,
            globalState: betState,
            eventName: eventName,
            homeTeamName: myTicketSelection.event.homeTeam,
            awayTeamName: myTicketSelection.event.awayTeam,
            marketName: myTicketSelection.outcome.market.name,
            outcomeName: myTicketSelection.outcome.name,
            odd: .decimal(odd: myTicketSelection.odd),
            
            // Score properties
            homeResult: homeScore,
            awayResult: awayScore,
            
            // Event properties
            eventId: "\(myTicketSelection.sportEventId)",
            eventDate: myTicketSelection.event.dateTime,
            country: country,
            
            // Sport properties
            sportType: mappedSportType,
            tournamentName: myTicketSelection.event.competition?.name ?? "",
            
            // Market and outcome IDs
            marketId: "\(myTicketSelection.outcome.market.id)",
            outcomeId: "\(myTicketSelection.outcome.id)",
            
            // Team logo properties
            homeLogoUrl: myTicketSelection.event.homeLogoUrl,
            awayLogoUrl: myTicketSelection.event.awayLogoUrl
        )
    }
    
    static func betState(fromMyTicketStatus myTicketStatus: GomaModels.MyTicketStatus) -> BetState {
        
        switch myTicketStatus {
        case .pending:
            return .opened
        case .won:
            return .won
        case .lost:
            return .lost
        case .push:
            return .void
        case .undefined:
            return .undefined
        }
    }
    
    static func betResult(fromMyTicketResult myTicketResult: GomaModels.MyTicketResult) -> BetResult {
        switch myTicketResult {
        case .pending:
            return .pending
        case .won:
            return .won
        case .lost:
            return .lost
        case .push:
            return .void
        case .undefined:
            return .notSpecified
        }
    }
    
    static func betQRCode(fromMyTicketQRCode myTicketQRCode: GomaModels.MyTicketQRCode) -> BetQRCode {
        
        let betQRCode = BetQRCode(qrCode: myTicketQRCode.qrCode,
                                  expirationDate: myTicketQRCode.expirationDate, message: myTicketQRCode.message)
        
        return betQRCode
    }
}
