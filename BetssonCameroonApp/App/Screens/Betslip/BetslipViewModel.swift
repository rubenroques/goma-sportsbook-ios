import Foundation
import Combine
import GomaUI

/// Production implementation of BetslipViewModelProtocol
public final class BetslipViewModel: BetslipViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetslipData, Never>
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Child View Models
    public var headerViewModel: BetslipHeaderViewModelProtocol
    public var emptyStateViewModel: EmptyStateActionViewModelProtocol
    public var betInfoSubmissionViewModel: BetInfoSubmissionViewModelProtocol
    public var bookingCodeButtonViewModel: ButtonIconViewModelProtocol
    public var clearBetslipButtonViewModel: ButtonIconViewModelProtocol
    
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
        self.dataSubject = CurrentValueSubject(BetslipData(isEnabled: true))
        
        // Initialize child view models
        self.headerViewModel = MockBetslipHeaderViewModel.notLoggedInMock()
        self.emptyStateViewModel = MockEmptyStateActionViewModel.loggedOutMock()
        self.betInfoSubmissionViewModel = MockBetInfoSubmissionViewModel.defaultMock()
        self.bookingCodeButtonViewModel = MockButtonIconViewModel.bookingCodeMock()
        self.clearBetslipButtonViewModel = MockButtonIconViewModel.clearBetslipMock()
        
        // Setup child view model callbacks
        setupChildViewModelCallbacks()
        
        // Setup bindings
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
                } else {
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
    
    public func removeTicket(_ ticket: BettingTicket) {
        Env.betslipManager.removeBettingTicket(ticket)
    }
    
    public func clearAllTickets() {
        // Clear all tickets from the betslip manager
        Env.betslipManager.clearAllBettingTickets()
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
            let amount = Double(self?.betInfoSubmissionViewModel.currentData.amount ?? "") ?? 0.0
            self?.placeBet(withAmount: amount)
            self?.onPlaceBetTapped?()
        }
    }
    
    private func placeBet(withAmount amount: Double) {
        
        Env.betslipManager.placeMultipleBet(withStake: amount, useFreebetBalance: false)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    var message = ""
                    switch error {
                    case .betPlacementDetailedError(let detailedMessage):
                        message = detailedMessage
                    default:
                        message = localized("error_placing_bet")
                    }
                    
                    print("Bet placed error: \(message)")
                default: ()
                }
            }, receiveValue: { [weak self] betPlacedDetails in
                
                print("BETSLIP VM PLACE BET: \(betPlacedDetails)")
                
                Env.userSessionStore.refreshUserWallet()
            })
            .store(in: &cancellables)
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
    
    private func updateHeaderToLoggedInState() {
        let loggedInState = BetslipHeaderState.loggedIn(balance: "XAF 25,000")
        headerViewModel.updateState(loggedInState)
        emptyStateViewModel.updateState(.loggedIn)
    }
    
    private func updateHeaderToNotLoggedInState() {
        let notLoggedInState = BetslipHeaderState.notLoggedIn
        headerViewModel.updateState(notLoggedInState)
        emptyStateViewModel.updateState(.loggedOut)
    }
} 
