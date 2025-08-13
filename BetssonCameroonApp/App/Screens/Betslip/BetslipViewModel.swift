import Foundation
import Combine
import GomaUI

/// Production implementation of BetslipViewModelProtocol
public final class BetslipViewModel: BetslipViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetslipData, Never>
    private var cancellables = Set<AnyCancellable>()
    
    // Child view models
    public var headerViewModel: BetslipHeaderViewModelProtocol
    public var emptyStateViewModel: EmptyStateActionViewModelProtocol
    public var betInfoSubmissionViewModel: BetInfoSubmissionViewModelProtocol
    
    // Callback closures for coordinator communication
    public var onHeaderCloseTapped: (() -> Void)?
    public var onHeaderJoinNowTapped: (() -> Void)?
    public var onHeaderLogInTapped: (() -> Void)?
    public var onEmptyStateActionTapped: (() -> Void)?
    public var onPlaceBetTapped: (() -> Void)?
    
    public var dataPublisher: AnyPublisher<BetslipData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: BetslipData {
        dataSubject.value
    }
    
    // MARK: - Initialization
    public init() {
        let initialData = BetslipData(isEnabled: true)
        self.dataSubject = CurrentValueSubject(initialData)
        
        // Initialize child view models
        self.headerViewModel = MockBetslipHeaderViewModel.notLoggedInMock()
        self.emptyStateViewModel = MockEmptyStateActionViewModel.loggedOutMock()
        self.betInfoSubmissionViewModel = MockBetInfoSubmissionViewModel.defaultMock()
        
        // Wire up child view model callbacks
        setupChildViewModelCallbacks()
        
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Subscribe to betslip changes
        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tickets in
                
                self?.updateTickets(tickets)
            }
            .store(in: &cancellables)
        
        Env.userSessionStore.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] userProfile in
                
                if userProfile != nil {
                    self?.updateToLoggedInState()
                }
                else {
                    self?.updateToLoggedOutState()
                }
            })
            .store(in: &cancellables)
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
    
    private func updateToLoggedInState() {
        let loggedInState = BetslipHeaderState.loggedIn(balance: "XAF 25,000")
        headerViewModel.updateState(loggedInState)
        
        emptyStateViewModel.updateState(.loggedIn)
    }
    
    private func updateToLoggedOutState() {
        let notLoggedInState = BetslipHeaderState.notLoggedIn
        headerViewModel.updateState(notLoggedInState)
        
        emptyStateViewModel.updateState(.loggedOut)

    }
} 
