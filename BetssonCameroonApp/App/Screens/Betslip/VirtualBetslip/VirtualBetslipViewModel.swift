//
//  VirtualBetslipViewModel.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import Combine
import GomaUI

public final class VirtualBetslipViewModel: VirtualBetslipViewModelProtocol {
    
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
    
    // MARK: - Publishers
    public var ticketsPublisher: AnyPublisher<[BettingTicket], Never> {
        return ticketsSubject.eraseToAnyPublisher()
    }
    
    public var currentTickets: [BettingTicket] {
        return ticketsSubject.value
    }
    
    // MARK: - Initialization
    init(environment: Environment) {
        self.environment = environment
        
        // Initialize child view models
        self.bookingCodeButtonViewModel = MockButtonIconViewModel(
            title: localized("booking_code"),
            icon: "doc.text",
            layoutType: .iconLeft
        )
        
        self.clearBetslipButtonViewModel = MockButtonIconViewModel(
            title: localized("clear_betslip"),
            icon: "trash",
            layoutType: .iconLeft
        )
        
        self.emptyStateViewModel = MockEmptyStateActionViewModel.loggedOutMock()
        let currency = Env.userSessionStore.userWalletPublisher.value?.currency ?? "XAF"
        self.betInfoSubmissionViewModel = MockBetInfoSubmissionViewModel(currency: currency)
        self.oddsAcceptanceViewModel = MockOddsAcceptanceViewModel.acceptedMock()
        
        // Setup initial mock data
        setupPublishers()
    }
    
    // MARK: - Public Methods
    public func removeTicket(_ ticket: BettingTicket) {
        // Remove ticket from the real betslip manager
        environment.betslipManager.removeBettingTicket(ticket)
    }
    
    public func clearAllTickets() {
        // Clear all tickets from the real betslip manager
        environment.betslipManager.clearAllBettingTickets()
    }
    
    // MARK: - Private Methods
    private func setupPublishers() {
        
        // TODO: Check which tickets will be used here
//        Env.betslipManager.bettingTicketsPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] tickets in
//                self?.ticketsSubject.send(tickets)
//            }
//            .store(in: &cancellables)
        
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
    }
} 
