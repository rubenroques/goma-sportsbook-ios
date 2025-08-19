//
//  MockSportsBetslipViewModel.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import Combine
import GomaUI

public final class MockSportsBetslipViewModel: SportsBetslipViewModelProtocol {
    
    // MARK: - Properties
    private let ticketsSubject = CurrentValueSubject<[BettingTicket], Never>([])
    private var cancellables = Set<AnyCancellable>()
    
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
    public init() {
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
        self.betInfoSubmissionViewModel = MockBetInfoSubmissionViewModel()
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
        // Remove ticket from the real betslip manager
        Env.betslipManager.removeBettingTicket(ticket)
    }
    
    public func clearAllTickets() {
        // Clear all tickets from the real betslip manager
        Env.betslipManager.clearAllBettingTickets()
    }
    
    // MARK: - Private Methods
    private func setupPublishers() {
        // Subscribe to real betslip data from the manager
        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tickets in
                self?.ticketsSubject.send(tickets)
                // Recalculate potential winnings when tickets change
                self?.calculatePotentialWinnings()
            }
            .store(in: &cancellables)
        
        Env.userSessionStore.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                if userProfile != nil {
                    self?.emptyStateViewModel.updateState(.loggedIn)
                } else {
                    self?.emptyStateViewModel.updateState(.loggedOut)
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(Env.betslipManager.bettingTicketsPublisher, Env.userSessionStore.userProfilePublisher)
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
        
        let stake = Double(betInfoSubmissionViewModel.currentData.amount) ?? 0.0
        
        // Show loading state
        self.isLoadingSubject.send(true)
        
        Env.betslipManager.placeMultipleBet(withStake: stake, useFreebetBalance: false)
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
            betInfoSubmissionViewModel.updatePotentialWinnings("XAF 0")
            return
        }
        
        // Calculate total odds by multiplying each odd value sequentially
        var totalOdds = 1.0
        for ticket in currentTickets {
            totalOdds *= ticket.decimalOdd
        }
        
        // Calculate potential winnings: amount * total odds
        let potentialWinnings = amount * totalOdds
        
        // Format the potential winnings with currency
        let formattedWinnings = String(format: "XAF %.2f", potentialWinnings)
        
        // Update the potential winnings in the bet info submission view model
        betInfoSubmissionViewModel.updatePotentialWinnings(formattedWinnings)
        
        print("Calculated potential winnings: \(formattedWinnings) (Amount: \(amount) × Total Odds: \(totalOdds))")
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
