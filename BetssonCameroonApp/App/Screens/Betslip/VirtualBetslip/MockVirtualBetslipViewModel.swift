//
//  MockVirtualBetslipViewModel.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import Combine
import GomaUI

public final class MockVirtualBetslipViewModel: VirtualBetslipViewModelProtocol {
    
    // MARK: - Properties
    private let ticketsSubject = CurrentValueSubject<[BettingTicket], Never>([])
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Child View Models
    public var bookingCodeButtonViewModel: ButtonIconViewModelProtocol
    public var clearBetslipButtonViewModel: ButtonIconViewModelProtocol
    public var emptyStateViewModel: EmptyStateActionViewModelProtocol
    public var betInfoSubmissionViewModel: BetInfoSubmissionViewModelProtocol
    
    // MARK: - Publishers
    public var ticketsPublisher: AnyPublisher<[BettingTicket], Never> {
        return ticketsSubject.eraseToAnyPublisher()
    }
    
    public var currentTickets: [BettingTicket] {
        return ticketsSubject.value
    }
    
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
            icon: "trash",
            layoutType: .iconLeft
        )
        
        self.emptyStateViewModel = MockEmptyStateActionViewModel.loggedOutMock()
        self.betInfoSubmissionViewModel = MockBetInfoSubmissionViewModel()
        
        // Setup initial mock data
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
        
        // TODO: Check which tickets will be used here
//        Env.betslipManager.bettingTicketsPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] tickets in
//                self?.ticketsSubject.send(tickets)
//            }
//            .store(in: &cancellables)
        
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
    }
} 
