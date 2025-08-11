import Foundation
import Combine
import GomaUI

/// Production implementation of BetslipViewModelProtocol
public final class BetslipViewModel: BetslipViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetslipData, Never>
    private var cancellables = Set<AnyCancellable>()
    
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
    public init() {
        
        let initialData = BetslipData(
            isEnabled: true,
            hasTickets: false,
            ticketCount: 0
        )
        self.dataSubject = CurrentValueSubject(initialData)
        
        // Initialize child view models
        self.headerViewModel = MockBetslipHeaderViewModel.notLoggedInMock()
        self.betInfoSubmissionViewModel = MockBetInfoSubmissionViewModel.defaultMock()
        
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Subscribe to betslip changes
        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tickets in
                let hasTickets = !tickets.isEmpty
                let count = tickets.count
                self?.updateTickets(hasTickets: hasTickets, count: count)
            }
            .store(in: &cancellables)
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
        // In a real implementation, this would signal to close the betslip
        // This would typically be handled by the coordinator
        print("BetslipViewModel: Header close tapped")
    }
    
    public func onHeaderJoinNowTapped() {
        // In a real implementation, this would signal to show registration
        // This would typically be handled by the coordinator
        print("BetslipViewModel: Header join now tapped")
    }
    
    public func onHeaderLogInTapped() {
        // In a real implementation, this would signal to show login
        // This would typically be handled by the coordinator
        print("BetslipViewModel: Header log in tapped")
    }
    
    public func onPlaceBetTapped() {
        // In a real implementation, this would submit the bet
        // This would typically be handled by the coordinator
        print("BetslipViewModel: Place bet tapped")
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
