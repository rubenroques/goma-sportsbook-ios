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

    // MARK: - State
    private var oddsBoostState: OddsBoostStairsState?

    // MARK: - Callback closures
    public var onBetslipTapped: (() -> Void)?
    
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
        // Combine both publishers to automatically sync tickets and odds boost data
        Publishers.CombineLatest(
            Env.betslipManager.bettingTicketsPublisher,
            Env.betslipManager.oddsBoostStairsPublisher
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (tickets, oddsBoostState) in
            self?.oddsBoostState = oddsBoostState
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

            // Extract real odds boost data from API response
            let (winBoostPercentage, totalEligibleCount, nextTierPercentage) = extractOddsBoostData(
                selectionCount: selectionCount
            )

            let state = BetslipFloatingState.withTickets(
                selectionCount: selectionCount,
                odds: formatOdds(totalOdds),
                winBoostPercentage: winBoostPercentage,
                totalEligibleCount: totalEligibleCount,
                nextTierPercentage: nextTierPercentage
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

    /// Extracts odds boost UI data from current state
    /// - Parameter selectionCount: Current number of selections in betslip
    /// - Returns: Tuple of (currentTierPercentage, totalEligibleCount, nextTierPercentage) for UI display
    private func extractOddsBoostData(selectionCount: Int) -> (String?, Int, String?) {
        guard let oddsBoostState = self.oddsBoostState else {
            // No odds boost available (not logged in, no bonus configured, or API error)
            return (nil, 0, nil)
        }

        // Extract current tier percentage for display in win boost capsule
        let currentPercentage: String? = oddsBoostState.currentTier.map { tier in
            return "\(Int(tier.percentage * 100))%"
        }

        // Extract next tier data for progress bar and call-to-action
        // If nextTier is nil, user has reached max tier, use 0/nil to hide progress
        let totalEligibleCount: Int = oddsBoostState.nextTier?.minSelections ?? 0
        let nextTierPercentage: String? = oddsBoostState.nextTier.map { tier in
            return "\(Int(tier.percentage * 100))%"
        }

        return (currentPercentage, totalEligibleCount, nextTierPercentage)
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
}
