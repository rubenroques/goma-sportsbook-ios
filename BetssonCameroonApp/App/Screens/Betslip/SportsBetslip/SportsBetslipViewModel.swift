//
//  SportsBetslipViewModel.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import Combine
import GomaUI

public final class SportsBetslipViewModel: SportsBetslipViewModelProtocol {
    
    // MARK: - Properties
    private let ticketsSubject = CurrentValueSubject<[BettingTicket], Never>([])
    private var cancellables = Set<AnyCancellable>()
    private var environment: Environment
    
    // MARK: - Child View Models
    public var bookingCodeButtonViewModel: ButtonIconViewModelProtocol
    public var clearBetslipButtonViewModel: ButtonIconViewModelProtocol
    public var emptyStateViewModel: EmptyStateActionViewModelProtocol
    public var betInfoSubmissionViewModel: BetInfoSubmissionViewModelProtocol
    public var oddsAcceptanceViewModel: OddsAcceptanceViewModelProtocol
    public var codeInputViewModel: CodeInputViewModelProtocol
    public var loginButtonViewModel: ButtonViewModelProtocol
    
    // MARK: - Publishers
    public var ticketsPublisher: AnyPublisher<[BettingTicket], Never> {
        return ticketsSubject.eraseToAnyPublisher()
    }
    
    public var currentTickets: [BettingTicket] {
        return ticketsSubject.value
    }
    
    public var isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    
    public var betslipLoggedState: ((BetslipLoggedState) -> Void)?
    public var showPlacedBetState: ((BetPlacedState) -> Void)?
    public var showLoginScreen: (() -> Void)?
    
    // MARK: - Initialization
    init(environment: Environment) {
        self.environment = environment
        // Initialize child view models
        self.bookingCodeButtonViewModel = MockButtonIconViewModel(
            title: "Booking Code",
            icon: "doc.text",
            layoutType: .iconLeft
        )
        
        self.clearBetslipButtonViewModel = MockButtonIconViewModel(
            title: "Clear Betslip",
            icon: "trash_icon",
            layoutType: .iconLeft
        )
        
        self.emptyStateViewModel = MockEmptyStateActionViewModel(state: .loggedOut, title: "You need at least 1 selection\nin your betslip to place a bet", actionButtonTitle: "Log in to bet", image: "empty_betslip_icon")
        
        // Initialize with default currency, will be updated when user profile is available
        let currency = environment.userSessionStore.userWalletPublisher.value?.currency ?? "XAF"
        self.betInfoSubmissionViewModel = MockBetInfoSubmissionViewModel(currency: currency)
        self.oddsAcceptanceViewModel = MockOddsAcceptanceViewModel.acceptedMock()
        self.codeInputViewModel = MockCodeInputViewModel()
        
        
        self.loginButtonViewModel = MockButtonViewModel(buttonData:
                                                            ButtonData(id: "login", title: "Login", style: .solidBackground)
        )
        
        // Setup real data subscription
        setupPublishers()
    }
    
    // MARK: - Public Methods
    public func removeTicket(_ ticket: BettingTicket) {
        environment.betslipManager.removeBettingTicket(ticket)
    }
    
    public func clearAllTickets() {
        environment.betslipManager.clearAllBettingTickets()
    }
    
    // MARK: - Private Methods
    private func setupPublishers() {
        // Subscribe to real betslip data from the manager
        environment.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tickets in
                self?.ticketsSubject.send(tickets)
                // Recalculate potential winnings when tickets change
                self?.calculatePotentialWinnings()
            }
            .store(in: &cancellables)
        
        environment.userSessionStore.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                if userProfile != nil {
                    self?.emptyStateViewModel.updateState(.loggedIn)
                } else {
                    self?.emptyStateViewModel.updateState(.loggedOut)
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(environment.betslipManager.bettingTicketsPublisher, environment.userSessionStore.userProfilePublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] tickets, userProfile in
                
                if userProfile == nil {
                    if tickets.isEmpty {
                        self?.betslipLoggedState?(.noTicketsLoggedOut)
                    }
                    else {
                        self?.betslipLoggedState?(.ticketsLoggedOut)
                    }
                }
                else {
                    if tickets.isEmpty {
                        self?.betslipLoggedState?(.noTicketsLoggedIn)
                    }
                    else {
                        self?.betslipLoggedState?(.ticketsLoggedIn)
                    }
                }
                
            })
            .store(in: &cancellables)
        
        betInfoSubmissionViewModel.onPlaceBetTapped = { [weak self] in
            self?.placeBet()
        }
        
        betInfoSubmissionViewModel.amountChanged = { [weak self] in
            self?.calculatePotentialWinnings()
        }
        
        
        loginButtonViewModel.onButtonTapped = { [weak self] in
            self?.showLoginScreen?()
        }
    }
    
    private func placeBet() {
        
        let stake = convertToDouble(betInfoSubmissionViewModel.currentData.amount)
        
        let oddsValidationType = oddsAcceptanceViewModel.currentData.state == .accepted ? "ACCEPT_ANY" : "ACCEPT_HIGHER"
        
        // Show loading state
        self.isLoadingSubject.send(true)
        
        environment.betslipManager.placeBet(withStake: stake, useFreebetBalance: false, oddsValidationType: oddsValidationType)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                // Hide loading state
                switch completion {
                case .finished:
                    print("PLACE BET DONE!")
                case .failure(let error):
                    print("PLACE BET ERROR: \(error)")
                    self?.showPlacedBetState?(.error(message: "Bet couldn't be placed. Please try again later!"))
                }
                
                self?.isLoadingSubject.send(false)
                
            }, receiveValue: { [weak self] betPlacedDetails in
                
                print("PLACE BET SUCCESS: \(betPlacedDetails)")
                self?.showPlacedBetState?(.success)

            })
            .store(in: &cancellables)
    }
    
    private func calculatePotentialWinnings() {
        // Get the current amount from the bet info submission view model
        let amountString = betInfoSubmissionViewModel.currentData.amount
        guard let amount = Double(amountString), amount > 0 else {
            // If no amount or invalid amount, set potential winnings to 0
            let currency = betInfoSubmissionViewModel.currentData.currency
            betInfoSubmissionViewModel.updatePotentialWinnings("\(currency) 0")
            return
        }
        
        // Calculate total odds by multiplying each odd value sequentially
        var totalOdds = 1.0
        for ticket in currentTickets {
            totalOdds *= ticket.decimalOdd
        }
        
        // Calculate potential winnings: amount * total odds
        let potentialWinnings = amount * totalOdds
        
        // Get the currency from the bet info submission view model
        let currency = betInfoSubmissionViewModel.currentData.currency
        
        // Format the potential winnings with the correct currency
        let formattedWinnings = String(format: "%@ %.2f", currency, potentialWinnings)
        
        // Update the potential winnings in the bet info submission view model
        betInfoSubmissionViewModel.updatePotentialWinnings(formattedWinnings)
        
        print("Calculated potential winnings: \(formattedWinnings) (Amount: \(amount) × Total Odds: \(totalOdds))")
    }
    
    func convertToDouble(_ string: String) -> Double {
        // Remove any whitespace
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        
        guard !trimmed.isEmpty else { return 0.0 }
        
        let normalizedString = trimmed.replacingOccurrences(of: ",", with: ".")
        
        return Double(normalizedString) ?? 0.0
    }
}

public enum BetslipLoggedState {
    case noTicketsLoggedOut
    case ticketsLoggedOut
    case noTicketsLoggedIn
    case ticketsLoggedIn
}

public enum BetPlacedState {
    case success
    case error(message: String)
}
