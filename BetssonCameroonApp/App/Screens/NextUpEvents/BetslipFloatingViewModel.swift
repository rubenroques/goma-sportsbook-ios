//
//  BetslipFloatingViewModel.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 06/08/2025.
//

import Foundation
import Combine
import GomaUI

/// Production implementation of BetslipFloatingViewModelProtocol
final class BetslipFloatingViewModel: BetslipFloatingViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetslipFloatingData, Never>
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Dependencies
    private let betslipManager: BetslipManager
    
    // MARK: - Protocol Conformance
    public var dataPublisher: AnyPublisher<BetslipFloatingData, Never> {
        return dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: BetslipFloatingData {
        return dataSubject.value
    }
    
    // MARK: - Initialization
    public init(betslipManager: BetslipManager = Env.betslipManager) {
        self.betslipManager = betslipManager
        let initialData = BetslipFloatingData(state: .noTickets, isEnabled: true)
        self.dataSubject = CurrentValueSubject(initialData)
        
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Subscribe to betting tickets changes
        betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tickets in
                self?.updateBetslipState(with: tickets)
            }
            .store(in: &cancellables)
    }
    
    private func updateBetslipState(with tickets: [BettingTicket]) {
        if tickets.isEmpty {
            updateState(.noTickets)
        } else {
            let selectionCount = tickets.count
            let totalOdds = calculateTotalOdds(from: tickets)
            let winBoostPercentage = calculateWinBoostPercentage(for: selectionCount)
            let totalEligibleCount = 6 // Standard requirement for win boost
            
            let state = BetslipFloatingState.withTickets(
                selectionCount: selectionCount,
                odds: formatOdds(totalOdds),
                winBoostPercentage: winBoostPercentage,
                totalEligibleCount: totalEligibleCount
            )
            
            updateState(state)
        }
    }
    
    private func calculateTotalOdds(from tickets: [BettingTicket]) -> Double {
        return tickets.reduce(1.0) { total, ticket in
            total * ticket.decimalOdd
        }
    }
    
    private func formatOdds(_ odds: Double) -> String {
        return String(format: "%.2f", odds)
    }
    
    private func calculateWinBoostPercentage(for selectionCount: Int) -> String? {
        // Win boost is available when user has 6 or more selections
        if selectionCount >= 6 {
            return "11%" // Standard win boost percentage
        }
        return nil
    }
    
    // MARK: - Protocol Methods
    public func updateState(_ state: BetslipFloatingState) {
        let newData = BetslipFloatingData(state: state, isEnabled: currentData.isEnabled)
        dataSubject.send(newData)
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        let newData = BetslipFloatingData(state: currentData.state, isEnabled: isEnabled)
        dataSubject.send(newData)
    }
    
    public func onBetslipTapped() {
        // Handle betslip tap - this could navigate to betslip screen
        // For now, just print a message
        print("Betslip tapped - should navigate to betslip screen")
        
        // TODO: Implement navigation to betslip screen
        // This could be done by:
        // 1. Using a closure passed from the coordinator
        // 2. Using a notification
        // 3. Using a router service
    }
}
