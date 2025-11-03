import Foundation
import Combine
import UIKit

/// Mock implementation of BetslipTicketViewModelProtocol for testing and previews
public final class MockBetslipTicketViewModel: BetslipTicketViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetslipTicketData, Never>
    
    public var dataPublisher: AnyPublisher<BetslipTicketData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: BetslipTicketData {
        dataSubject.value
    }
    
    // MARK: - Initialization
    public init(leagueName: String = "Premier League", startDate: String = "17 June, 11:00", homeTeam: String = "Manchester United", awayTeam: String = "Glasgow Rangers", selectedTeam: String = "Manchester United", oddsValue: String = "6.50", oddsChangeState: OddsChangeState = .none, isEnabled: Bool = true, bettingOfferId: String? = nil, disabledMessage: String? = nil) {
        let initialData = BetslipTicketData(leagueName: leagueName, startDate: startDate, homeTeam: homeTeam, awayTeam: awayTeam, selectedTeam: selectedTeam, oddsValue: oddsValue, oddsChangeState: oddsChangeState, isEnabled: isEnabled, bettingOfferId: bettingOfferId, disabledMessage: disabledMessage)
        self.dataSubject = CurrentValueSubject(initialData)
    }
    
    // MARK: - Protocol Methods
    public func updateLeagueName(_ leagueName: String) {
        let newData = BetslipTicketData(leagueName: leagueName, startDate: currentData.startDate, homeTeam: currentData.homeTeam, awayTeam: currentData.awayTeam, selectedTeam: currentData.selectedTeam, oddsValue: currentData.oddsValue, oddsChangeState: currentData.oddsChangeState, isEnabled: currentData.isEnabled, bettingOfferId: currentData.bettingOfferId, disabledMessage: currentData.disabledMessage)
        dataSubject.send(newData)
    }
    
    public func updateStartDate(_ startDate: String) {
        let newData = BetslipTicketData(leagueName: currentData.leagueName, startDate: startDate, homeTeam: currentData.homeTeam, awayTeam: currentData.awayTeam, selectedTeam: currentData.selectedTeam, oddsValue: currentData.oddsValue, oddsChangeState: currentData.oddsChangeState, isEnabled: currentData.isEnabled, bettingOfferId: currentData.bettingOfferId, disabledMessage: currentData.disabledMessage)
        dataSubject.send(newData)
    }
    
    public func updateHomeTeam(_ homeTeam: String) {
        let newData = BetslipTicketData(leagueName: currentData.leagueName, startDate: currentData.startDate, homeTeam: homeTeam, awayTeam: currentData.awayTeam, selectedTeam: currentData.selectedTeam, oddsValue: currentData.oddsValue, oddsChangeState: currentData.oddsChangeState, isEnabled: currentData.isEnabled, bettingOfferId: currentData.bettingOfferId, disabledMessage: currentData.disabledMessage)
        dataSubject.send(newData)
    }
    
    public func updateAwayTeam(_ awayTeam: String) {
        let newData = BetslipTicketData(leagueName: currentData.leagueName, startDate: currentData.startDate, homeTeam: currentData.homeTeam, awayTeam: awayTeam, selectedTeam: currentData.selectedTeam, oddsValue: currentData.oddsValue, oddsChangeState: currentData.oddsChangeState, isEnabled: currentData.isEnabled, bettingOfferId: currentData.bettingOfferId, disabledMessage: currentData.disabledMessage)
        dataSubject.send(newData)
    }
    
    public func updateSelectedTeam(_ selectedTeam: String) {
        let newData = BetslipTicketData(leagueName: currentData.leagueName, startDate: currentData.startDate, homeTeam: currentData.homeTeam, awayTeam: currentData.awayTeam, selectedTeam: selectedTeam, oddsValue: currentData.oddsValue, oddsChangeState: currentData.oddsChangeState, isEnabled: currentData.isEnabled, bettingOfferId: currentData.bettingOfferId, disabledMessage: currentData.disabledMessage)
        dataSubject.send(newData)
    }
    
    public func updateOddsValue(_ oddsValue: String) {
        let newData = BetslipTicketData(leagueName: currentData.leagueName, startDate: currentData.startDate, homeTeam: currentData.homeTeam, awayTeam: currentData.awayTeam, selectedTeam: currentData.selectedTeam, oddsValue: oddsValue, oddsChangeState: currentData.oddsChangeState, isEnabled: currentData.isEnabled, bettingOfferId: currentData.bettingOfferId, disabledMessage: currentData.disabledMessage)
        dataSubject.send(newData)
    }
    
    public func updateOddsChangeState(_ state: OddsChangeState) {
        let newData = BetslipTicketData(
            leagueName: currentData.leagueName,
            startDate: currentData.startDate,
            homeTeam: currentData.homeTeam,
            awayTeam: currentData.awayTeam,
            selectedTeam: currentData.selectedTeam,
            oddsValue: currentData.oddsValue,
            oddsChangeState: state,
            isEnabled: currentData.isEnabled,
            bettingOfferId: currentData.bettingOfferId,
            disabledMessage: currentData.disabledMessage
        )
        dataSubject.send(newData)
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        let newData = BetslipTicketData(leagueName: currentData.leagueName, startDate: currentData.startDate, homeTeam: currentData.homeTeam, awayTeam: currentData.awayTeam, selectedTeam: currentData.selectedTeam, oddsValue: currentData.oddsValue, oddsChangeState: currentData.oddsChangeState, isEnabled: isEnabled, bettingOfferId: currentData.bettingOfferId, disabledMessage: currentData.disabledMessage)
        dataSubject.send(newData)
    }
    
    // Callback closures
    public var onCloseTapped: (() -> Void)?
}

// MARK: - Factory Methods
public extension MockBetslipTicketViewModel {
    
    /// Creates a mock view model for skeleton/placeholder state
    static func skeletonMock() -> MockBetslipTicketViewModel {
        MockBetslipTicketViewModel(
            leagueName: "League",
            startDate: "--:--",
            homeTeam: "Home Team",
            awayTeam: "Away Team",
            selectedTeam: "--",
            oddsValue: "-.--",
            oddsChangeState: .none
        )
    }
    
    /// Creates a mock view model for typical use
    static func typicalMock() -> MockBetslipTicketViewModel {
        return MockBetslipTicketViewModel(
            leagueName: "Premier League",
            startDate: "17 June, 11:00",
            homeTeam: "Manchester United",
            awayTeam: "Glasgow Rangers",
            selectedTeam: "Manchester United",
            oddsValue: "6.50"
        )
    }
    
    /// Creates a mock view model with increased odds
    static func increasedOddsMock() -> MockBetslipTicketViewModel {
        return MockBetslipTicketViewModel(
            leagueName: "Premier League",
            startDate: "17 June, 11:00",
            homeTeam: "Manchester United",
            awayTeam: "Glasgow Rangers",
            selectedTeam: "Manchester United",
            oddsValue: "7.20",
            oddsChangeState: .increased
        )
    }
    
    /// Creates a mock view model with decreased odds
    static func decreasedOddsMock() -> MockBetslipTicketViewModel {
        return MockBetslipTicketViewModel(
            leagueName: "Premier League",
            startDate: "17 June, 11:00",
            homeTeam: "Manchester United",
            awayTeam: "Glasgow Rangers",
            selectedTeam: "Manchester United",
            oddsValue: "5.80",
            oddsChangeState: .decreased
        )
    }
    
    /// Creates a mock view model for disabled state
    static func disabledMock() -> MockBetslipTicketViewModel {
        return MockBetslipTicketViewModel(
            leagueName: "Premier League",
            startDate: "17 June, 11:00",
            homeTeam: "Manchester United",
            awayTeam: "Glasgow Rangers",
            selectedTeam: "Manchester United",
            oddsValue: "6.50",
            oddsChangeState: .none,
            isEnabled: false,
            disabledMessage: "Forbidden selection"
        )
    }
} 
