import Foundation
import UIKit
import Combine
import GomaUI

/// Mock implementation of BetslipViewModelProtocol for testing and previews
public final class MockBetslipViewModel: BetslipViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetslipData, Never>
    
    // MARK: - Child View Models
    public var headerViewModel: BetslipHeaderViewModelProtocol
    public var emptyStateViewModel: EmptyStateActionViewModelProtocol
    public var betInfoSubmissionViewModel: BetInfoSubmissionViewModelProtocol
    public var bookingCodeButtonViewModel: ButtonIconViewModelProtocol
    public var clearBetslipButtonViewModel: ButtonIconViewModelProtocol
    public var betslipTypeSelectorViewModel: BetslipTypeSelectorViewModelProtocol
    
    // Callback closures for coordinator communication
    public var onHeaderCloseTapped: (() -> Void)?
    public var onHeaderJoinNowTapped: (() -> Void)?
    public var onHeaderLogInTapped: (() -> Void)?
    public var onEmptyStateActionTapped: (() -> Void)?
    public var onPlaceBetTapped: (() -> Void)?
    
    // MARK: - Publishers
    public var dataPublisher: AnyPublisher<BetslipData, Never> {
        return dataSubject.eraseToAnyPublisher()
    }
    
    public var ticketsPublisher: AnyPublisher<[BettingTicket], Never> {
        return dataSubject.map { $0.tickets }.eraseToAnyPublisher()
    }
    
    public var currentData: BetslipData {
        dataSubject.value
    }
    
    // MARK: - Initialization
    public init() {
        self.dataSubject = CurrentValueSubject(BetslipData(isEnabled: true))
        
        // Initialize child view models
        self.headerViewModel = MockBetslipHeaderViewModel.notLoggedInMock()
        self.emptyStateViewModel = MockEmptyStateActionViewModel.loggedOutMock()
        self.betInfoSubmissionViewModel = MockBetInfoSubmissionViewModel.defaultMock()
        self.bookingCodeButtonViewModel = MockButtonIconViewModel.bookingCodeMock()
        self.clearBetslipButtonViewModel = MockButtonIconViewModel.clearBetslipMock()
        self.betslipTypeSelectorViewModel = MockBetslipTypeSelectorViewModel.defaultMock()
        
        // Setup child view model callbacks
        setupChildViewModelCallbacks()
    }
    
    // MARK: - Protocol Methods
    public func setEnabled(_ isEnabled: Bool) {
        let newData = BetslipData(
            isEnabled: isEnabled,
            tickets: currentData.tickets
        )
        dataSubject.send(newData)
        
        // Update child view models
        emptyStateViewModel.setEnabled(isEnabled)
        betInfoSubmissionViewModel.setEnabled(isEnabled)
    }
    
    public func updateTickets(_ tickets: [BettingTicket]) {
        let newData = BetslipData(
            isEnabled: currentData.isEnabled,
            tickets: tickets
        )
        dataSubject.send(newData)
    }
    
    public func removeTicket(_ ticket: BettingTicket) {
        var updatedTickets = currentData.tickets
        updatedTickets.removeAll { $0.id == ticket.id }
        
        if updatedTickets.isEmpty {
            updateHeaderToNotLoggedInState()
        }
        
        dataSubject.send(BetslipData(
            isEnabled: currentData.isEnabled,
            tickets: updatedTickets
        ))
    }
    
    public func clearAllTickets() {
        dataSubject.send(BetslipData(
            isEnabled: currentData.isEnabled,
            tickets: []
        ))
        updateHeaderToNotLoggedInState()
    }
    
    // MARK: - Private Methods
    private func setupChildViewModelCallbacks() {
        // Wire header view model callbacks to our callbacks
        headerViewModel.onCloseTapped = { [weak self] in
            self?.onHeaderCloseTapped?()
        }
        
        headerViewModel.onJoinNowTapped = { [weak self] in
            self?.onHeaderJoinNowTapped?()
        }
        
        headerViewModel.onLogInTapped = { [weak self] in
            self?.onHeaderLogInTapped?()
        }
        
        // Wire empty state view model callbacks to our callbacks
        emptyStateViewModel.onActionButtonTapped = { [weak self] in
            self?.onEmptyStateActionTapped?()
        }
        
        // Wire bet info submission view model callbacks to our callbacks
        betInfoSubmissionViewModel.onPlaceBetTapped = { [weak self] in
            self?.onPlaceBetTapped?()
        }
    }
    
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
    
} 
