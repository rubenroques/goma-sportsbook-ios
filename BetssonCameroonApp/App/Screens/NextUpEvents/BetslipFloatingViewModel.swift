//
//  BetslipFloatingViewModel.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 06/08/2025.
//

import Foundation
import Combine
import GomaUI
import ServicesProvider

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
        // Combine all three publishers for synchronized state updates
        Publishers.CombineLatest3(
            Env.betslipManager.bettingTicketsPublisher,
            Env.betslipManager.oddsBoostStairsPublisher,
            Env.betslipManager.bettingOptionsPublisher
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (tickets, oddsBoostState, bettingOptions) in
            guard let self = self else { return }
            self.oddsBoostState = oddsBoostState
            self.updateBetslipState(with: tickets, bettingOptions: bettingOptions)
        }
        .store(in: &cancellables)
    }
    
    private func updateBetslipState(with tickets: [BettingTicket], bettingOptions: LoadableContent<UnifiedBettingOptions>) {
        if tickets.isEmpty {
            updateState(.noTickets)
        } else {
            // CRITICAL: Use API's eligibleEventIds.count for selection count
            // This correctly handles duplicate events (multiple selections from same event)
            let eligibleEventsCount = oddsBoostState?.eligibleEventIds.count ?? tickets.count
            
            // Get current displayed odds to avoid flickering to 0 while loading
            let currentDisplayedOdds: Double = {
                if case .withTickets(_, let oddsString, _, _, _) = currentData.state {
                    return Double(oddsString) ?? 0.0
                }
                return 0.0
            }()
            
            // Calculate odds: use API odds with priority order (matching SportsBetslipViewModel)
            let totalOdds: Double
            if case .loaded(let options) = bettingOptions {
                // Determine invalid state
                let isInvalid = !options.forbiddenCombinations.isEmpty || options.totalOdds == nil || options.totalOdds == 0.0
                
                if let firstBetbuilder = options.betBuilders.first, let betBuilderOdds = firstBetbuilder.betBuilderOdds {
                    // Priority 1: Use betBuilder odds if present
                    totalOdds = betBuilderOdds
                } else if isInvalid {
                    // Priority 2: Set to 0 if invalid or forbidden
                    totalOdds = 0.0
                } else if let apiOdds = options.totalOdds {
                    // Priority 3: Use regular totalOdds
                    totalOdds = apiOdds
                } else {
                    // Priority 4: Fallback to 0
                    totalOdds = 0.0
                }
            } else if case .failed = bettingOptions {
                totalOdds = 0.0
            } else {
                // While loading or idle, preserve current odds to avoid flickering
                totalOdds = currentDisplayedOdds
            }

            // Extract real odds boost data from API response
            let (winBoostPercentage, totalEligibleCount, nextTierPercentage) = extractOddsBoostData()

            let state = BetslipFloatingState.withTickets(
                selectionCount: eligibleEventsCount,  // From API, not betslip tickets
                odds: formatOdds(totalOdds),
                winBoostPercentage: winBoostPercentage,
                totalEligibleCount: totalEligibleCount,
                nextTierPercentage: nextTierPercentage
            )

            updateState(state)
        }
    }
    
    private func formatOdds(_ odds: Double) -> String {
        return String(format: "%.2f", odds)
    }

    /// Extracts odds boost UI data from current state
    /// - Returns: Tuple of (currentTierPercentage, totalEligibleCount, nextTierPercentage) for UI display
    private func extractOddsBoostData() -> (String?, Int, String?) {
        guard let oddsBoostState = self.oddsBoostState else {
            // No odds boost available (not logged in, no bonus configured, or API error)
            return (nil, 0, nil)
        }

        // Extract current tier percentage for display in win boost capsule
        let currentPercentage: String? = oddsBoostState.currentTier.map { tier in
            return "\(Int(tier.percentage * 100))%"
        }

        // Extract next tier data for progress bar and call-to-action
        // If nextTier is nil, user has reached max tier - use currentTier to show all segments filled
        let totalEligibleCount: Int = oddsBoostState.nextTier?.minSelections
            ?? oddsBoostState.currentTier?.minSelections
            ?? 0
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
