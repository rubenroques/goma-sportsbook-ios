import Foundation
import Combine
import UIKit

/// Mock implementation of `TicketSelectionViewModelProtocol` for testing.
final public class MockTicketSelectionViewModel: TicketSelectionViewModelProtocol {
    
    // MARK: - Properties
    private let ticketDataSubject: CurrentValueSubject<TicketSelectionData, Never>
    public var ticketDataPublisher: AnyPublisher<TicketSelectionData, Never> {
        return ticketDataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Callback
    public var onTicketTapped: (() -> Void)?
    
    // MARK: - Initialization
    public init(ticketData: TicketSelectionData) {
        self.ticketDataSubject = CurrentValueSubject(ticketData)
    }
    
    // MARK: - TicketSelectionViewModelProtocol
    public func handleTicketTap() {
        let currentData = ticketDataSubject.value
        print("Ticket tapped: \(currentData.id)")
        
        // Call the callback if set
        onTicketTapped?()
    }
    
    public func updateTicketData(_ ticketData: TicketSelectionData) {
        ticketDataSubject.send(ticketData)
    }
    
    public func toggleLiveState() {
        let currentData = ticketDataSubject.value
        let updatedData = TicketSelectionData(
            id: currentData.id,
            competitionName: currentData.competitionName,
            homeTeamName: currentData.homeTeamName,
            awayTeamName: currentData.awayTeamName,
            homeScore: currentData.homeScore,
            awayScore: currentData.awayScore,
            matchDate: currentData.matchDate,
            isLive: !currentData.isLive,
            sportIcon: currentData.sportIcon,
            countryFlag: currentData.countryFlag,
            marketName: currentData.marketName,
            selectionName: currentData.selectionName,
            oddsValue: currentData.oddsValue
        )
        ticketDataSubject.send(updatedData)
    }
}

// MARK: - Mock Factory
extension MockTicketSelectionViewModel {
    
    // MARK: - PreLive State Examples
    public static var preLiveMock: MockTicketSelectionViewModel {
        let ticketData = TicketSelectionData(
            id: "match_prelive_1",
            competitionName: "Premier League",
            homeTeamName: "Manchester United",
            awayTeamName: "Liverpool",
            homeScore: 0,
            awayScore: 0,
            matchDate: "Today, 20:00",
            isLive: false,
            sportIcon: "soccerball",
            countryFlag: "flag.fill",
            marketName: "Match Winner",
            selectionName: "Home Win",
            oddsValue: "2.50"
        )
        return MockTicketSelectionViewModel(ticketData: ticketData)
    }
    
    public static var preLiveChampionsLeagueMock: MockTicketSelectionViewModel {
        let ticketData = TicketSelectionData(
            id: "match_prelive_2",
            competitionName: "UEFA Champions League",
            homeTeamName: "Real Madrid",
            awayTeamName: "Bayern Munich",
            homeScore: 0,
            awayScore: 0,
            matchDate: "Tomorrow, 21:00",
            isLive: false,
            sportIcon: "soccerball",
            countryFlag: "flag.fill"
        )
        return MockTicketSelectionViewModel(ticketData: ticketData)
    }
    
    // MARK: - Live State Examples
    public static var liveMock: MockTicketSelectionViewModel {
        let ticketData = TicketSelectionData(
            id: "match_live_1",
            competitionName: "La Liga",
            homeTeamName: "Barcelona",
            awayTeamName: "Atletico Madrid",
            homeScore: 2,
            awayScore: 1,
            matchDate: "Live",
            isLive: true,
            sportIcon: "soccerball",
            countryFlag: "flag.fill",
            marketName: "Total Goals",
            selectionName: "Over 2.5",
            oddsValue: "1.85"
        )
        return MockTicketSelectionViewModel(ticketData: ticketData)
    }
    
    public static var liveDrawMock: MockTicketSelectionViewModel {
        let ticketData = TicketSelectionData(
            id: "match_live_2",
            competitionName: "Bundesliga",
            homeTeamName: "Bayern Munich",
            awayTeamName: "Borussia Dortmund",
            homeScore: 1,
            awayScore: 1,
            matchDate: "Live",
            isLive: true,
            sportIcon: "soccerball",
            countryFlag: "flag.fill"
        )
        return MockTicketSelectionViewModel(ticketData: ticketData)
    }
    
    public static var liveHighScoreMock: MockTicketSelectionViewModel {
        let ticketData = TicketSelectionData(
            id: "match_live_3",
            competitionName: "Serie A",
            homeTeamName: "Juventus",
            awayTeamName: "AC Milan",
            homeScore: 3,
            awayScore: 2,
            matchDate: "Live",
            isLive: true,
            sportIcon: "soccerball",
            countryFlag: "flag.fill"
        )
        return MockTicketSelectionViewModel(ticketData: ticketData)
    }
    
    // MARK: - Edge Cases
    public static var longTeamNamesMock: MockTicketSelectionViewModel {
        let ticketData = TicketSelectionData(
            id: "match_long_names",
            competitionName: "Very Long Competition Name That Might Overflow",
            homeTeamName: "Very Long Home Team Name That Might Cause Layout Issues",
            awayTeamName: "Very Long Away Team Name That Might Cause Layout Issues",
            homeScore: 0,
            awayScore: 0,
            matchDate: "Today, 20:00",
            isLive: false,
            sportIcon: "soccerball",
            countryFlag: "flag.fill"
        )
        return MockTicketSelectionViewModel(ticketData: ticketData)
    }
    
    public static var noIconsMock: MockTicketSelectionViewModel {
        let ticketData = TicketSelectionData(
            id: "match_no_icons",
            competitionName: "Premier League",
            homeTeamName: "Arsenal",
            awayTeamName: "Chelsea",
            homeScore: 0,
            awayScore: 0,
            matchDate: "Today, 20:00",
            isLive: false,
            sportIcon: nil,
            countryFlag: nil
        )
        return MockTicketSelectionViewModel(ticketData: ticketData)
    }
} 
