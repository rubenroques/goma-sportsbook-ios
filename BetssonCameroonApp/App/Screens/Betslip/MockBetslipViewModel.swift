import Foundation
import Combine
import UIKit
import GomaUI

/// Mock implementation of BetslipViewModelProtocol for testing and previews
public final class MockBetslipViewModel: BetslipViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetslipData, Never>
    
    // Child view models
    public let headerViewModel: BetslipHeaderViewModelProtocol
    public let betInfoSubmissionViewModel: BetInfoSubmissionViewModelProtocol
    
    public var dataPublisher: AnyPublisher<BetslipData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: BetslipData {
        dataSubject.value
    }
    
    // MARK: - Initialization
    public init(
        isEnabled: Bool = true,
        hasTickets: Bool = false,
        ticketCount: Int = 0
    ) {
        let initialData = BetslipData(
            isEnabled: isEnabled,
            hasTickets: hasTickets,
            ticketCount: ticketCount
        )
        self.dataSubject = CurrentValueSubject(initialData)
        
        // Initialize child view models
        self.headerViewModel = MockBetslipHeaderViewModel.notLoggedInMock()
        self.betInfoSubmissionViewModel = MockBetInfoSubmissionViewModel.defaultMock()
        
        // Update initial state based on parameters
        if hasTickets {
            updateHeaderToLoggedInState()
        }
    }
    
    // MARK: - Protocol Methods
    public func setEnabled(_ isEnabled: Bool) {
        let newData = BetslipData(
            isEnabled: isEnabled,
            hasTickets: currentData.hasTickets,
            ticketCount: currentData.ticketCount
        )
        dataSubject.send(newData)
        
        // Update child view models
        betInfoSubmissionViewModel.setEnabled(isEnabled)
    }
    
    public func updateTickets(hasTickets: Bool, count: Int) {
        let newData = BetslipData(
            isEnabled: currentData.isEnabled,
            hasTickets: hasTickets,
            ticketCount: count
        )
        dataSubject.send(newData)
        
        // Update child view models based on ticket state
        if hasTickets {
            updateHeaderToLoggedInState()
        } else {
            updateHeaderToNotLoggedInState()
        }
        
        betInfoSubmissionViewModel.setEnabled(hasTickets)
    }
    
    public func onHeaderCloseTapped() {
        // Mock implementation - in real app this would signal to close the betslip
        print("MockBetslipViewModel: Header close tapped")
    }
    
    public func onHeaderJoinNowTapped() {
        // Mock implementation - in real app this would signal to show registration
        print("MockBetslipViewModel: Header join now tapped")
    }
    
    public func onHeaderLogInTapped() {
        // Mock implementation - in real app this would signal to show login
        print("MockBetslipViewModel: Header log in tapped")
    }
    
    public func onPlaceBetTapped() {
        // Mock implementation - in real app this would submit the bet
        print("MockBetslipViewModel: Place bet tapped")
    }
    
    // MARK: - Private Methods
    private func updateHeaderToLoggedInState() {
        let loggedInState = BetslipHeaderState.loggedIn(balance: "XAF 25,000")
        headerViewModel.updateState(loggedInState)
    }
    
    private func updateHeaderToNotLoggedInState() {
        let notLoggedInState = BetslipHeaderState.notLoggedIn
        headerViewModel.updateState(notLoggedInState)
    }
}

// MARK: - Factory Methods
public extension MockBetslipViewModel {
    
    /// Creates a mock view model for default state (no tickets)
    static func defaultMock() -> MockBetslipViewModel {
        MockBetslipViewModel()
    }
    
    /// Creates a mock view model with tickets
    static func withTicketsMock() -> MockBetslipViewModel {
        MockBetslipViewModel(
            hasTickets: true,
            ticketCount: 2
        )
    }
    
    /// Creates a mock view model for disabled state
    static func disabledMock() -> MockBetslipViewModel {
        MockBetslipViewModel(
            isEnabled: false
        )
    }
} 