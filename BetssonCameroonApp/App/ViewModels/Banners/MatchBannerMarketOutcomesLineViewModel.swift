//
//  MatchBannerMarketOutcomesLineViewModel.swift
//  BetssonCameroonApp
//
//  Created on 26/09/2025.
//

import GomaUI
import ServicesProvider
import Combine
import UIKit

/// Production implementation of MarketOutcomesLineViewModel specifically for MatchBannerView
/// Handles selection state synchronization with BetslipManager
final class MatchBannerMarketOutcomesLineViewModel: MarketOutcomesLineViewModelProtocol {

    // MARK: - Subjects
    public let marketStateSubject: CurrentValueSubject<MarketOutcomesLineDisplayState, Never>
    private let oddsChangeEventSubject: PassthroughSubject<OddsChangeEvent, Never>
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Child ViewModels
    private var outcomeViewModels: [OutcomeType: OutcomeItemViewModel] = [:]

    // MARK: - Data
    private let match: Match
    private let market: Market

    // MARK: - Protocol Conformance
    public var marketStatePublisher: AnyPublisher<MarketOutcomesLineDisplayState, Never> {
        marketStateSubject.eraseToAnyPublisher()
    }

    public var oddsChangeEventPublisher: AnyPublisher<OddsChangeEvent, Never> {
        oddsChangeEventSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization
    init(match: Match, market: Market) {
        self.match = match
        self.market = market

        // Create initial display state with correct selection state from BetslipManager
        let initialDisplayState = Self.createInitialDisplayState(from: match, market: market)

        self.marketStateSubject = CurrentValueSubject(initialDisplayState)
        self.oddsChangeEventSubject = PassthroughSubject()

        // Create outcome view models with correct selection state
        createOutcomeViewModels(from: initialDisplayState)

        // Subscribe to betslip changes to update selection state
        setupBetslipSubscription()
    }

    // MARK: - Public Methods
    public func toggleOutcome(type: OutcomeType) -> Bool {
        guard let outcomeViewModel = outcomeViewModels[type] else {
            return false
        }

        return outcomeViewModel.toggleSelection()
    }

    public func setOutcomeSelected(type: OutcomeType) {
        guard let outcomeViewModel = outcomeViewModels[type] else { return }
        outcomeViewModel.setSelected(true)
    }

    public func setOutcomeDeselected(type: OutcomeType) {
        guard let outcomeViewModel = outcomeViewModels[type] else { return }
        outcomeViewModel.setSelected(false)
    }

    public func updateOddsValue(type: OutcomeType, newValue: String) {
        guard let outcomeViewModel = outcomeViewModels[type] else { return }
        outcomeViewModel.updateOddsValue(newValue)
    }

    public func createOutcomeViewModel(for type: OutcomeType) -> OutcomeItemViewModelProtocol? {
        return outcomeViewModels[type]
    }

    public func updateSelectionStates(selectedOfferIds: Set<String>) {
        let currentState = marketStateSubject.value

        // Update left outcome selection
        if let leftOutcome = currentState.leftOutcome,
           let bettingOfferId = leftOutcome.bettingOfferId {
            let shouldBeSelected = selectedOfferIds.contains(bettingOfferId)
            if leftOutcome.isSelected != shouldBeSelected {
                outcomeViewModels[.left]?.setSelected(shouldBeSelected)
            }
        }

        // Update middle outcome selection
        if let middleOutcome = currentState.middleOutcome,
           let bettingOfferId = middleOutcome.bettingOfferId {
            let shouldBeSelected = selectedOfferIds.contains(bettingOfferId)
            if middleOutcome.isSelected != shouldBeSelected {
                outcomeViewModels[.middle]?.setSelected(shouldBeSelected)
            }
        }

        // Update right outcome selection
        if let rightOutcome = currentState.rightOutcome,
           let bettingOfferId = rightOutcome.bettingOfferId {
            let shouldBeSelected = selectedOfferIds.contains(bettingOfferId)
            if rightOutcome.isSelected != shouldBeSelected {
                outcomeViewModels[.right]?.setSelected(shouldBeSelected)
            }
        }
    }

    // MARK: - Private Methods
    private func createOutcomeViewModels(from displayState: MarketOutcomesLineDisplayState) {
        outcomeViewModels.removeAll()

        // Create left outcome
        if let leftOutcome = displayState.leftOutcome {
            let outcomeItemData = convertToOutcomeItemData(leftOutcome)
            let viewModel = OutcomeItemViewModel(outcomeId: leftOutcome.id, initialOutcomeData: outcomeItemData)
            outcomeViewModels[.left] = viewModel
        }

        // Create middle outcome
        if let middleOutcome = displayState.middleOutcome {
            let outcomeItemData = convertToOutcomeItemData(middleOutcome)
            let viewModel = OutcomeItemViewModel(outcomeId: middleOutcome.id, initialOutcomeData: outcomeItemData)
            outcomeViewModels[.middle] = viewModel
        }

        // Create right outcome
        if let rightOutcome = displayState.rightOutcome {
            let outcomeItemData = convertToOutcomeItemData(rightOutcome)
            let viewModel = OutcomeItemViewModel(outcomeId: rightOutcome.id, initialOutcomeData: outcomeItemData)
            outcomeViewModels[.right] = viewModel
        }
    }

    private func setupBetslipSubscription() {
        print("[BETSLIP_SYNC] MatchBannerMarketOutcomesLineViewModel: Setting up betslip subscription")
        // Subscribe to betslip changes to update selection state
        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bettingTickets in
                print("[BETSLIP_SYNC] MatchBannerMarketOutcomesLineViewModel: Betslip changed - \(bettingTickets.count) tickets")
                self?.updateSelectionState(based: bettingTickets)
            }
            .store(in: &cancellables)
    }

    private func updateSelectionState(based bettingTickets: [BettingTicket]) {
        let currentState = marketStateSubject.value

        // Check each outcome to see if it's in the betslip
        let leftSelected = isOutcomeInBetslip(currentState.leftOutcome, bettingTickets: bettingTickets)
        let middleSelected = isOutcomeInBetslip(currentState.middleOutcome, bettingTickets: bettingTickets)
        let rightSelected = isOutcomeInBetslip(currentState.rightOutcome, bettingTickets: bettingTickets)

        print("[BETSLIP_SYNC] MatchBannerMarketOutcomesLineViewModel: Selection states from betslip - left: \(leftSelected), middle: \(middleSelected), right: \(rightSelected)")
        print("[BETSLIP_SYNC] MatchBannerMarketOutcomesLineViewModel: Selection states in parent state - left: \(currentState.leftOutcome?.isSelected ?? false), middle: \(currentState.middleOutcome?.isSelected ?? false), right: \(currentState.rightOutcome?.isSelected ?? false)")

        // ALWAYS update child ViewModels to match betslip state (don't rely on parent state)
        if let leftOutcome = currentState.leftOutcome {
            print("[BETSLIP_SYNC] MatchBannerMarketOutcomesLineViewModel: Setting LEFT outcome '\(leftOutcome.title)' to \(leftSelected)")
            outcomeViewModels[.left]?.setSelected(leftSelected)
        }

        if let middleOutcome = currentState.middleOutcome {
            print("[BETSLIP_SYNC] MatchBannerMarketOutcomesLineViewModel: Setting MIDDLE outcome '\(middleOutcome.title)' to \(middleSelected)")
            outcomeViewModels[.middle]?.setSelected(middleSelected)
        }

        if let rightOutcome = currentState.rightOutcome {
            print("[BETSLIP_SYNC] MatchBannerMarketOutcomesLineViewModel: Setting RIGHT outcome '\(rightOutcome.title)' to \(rightSelected)")
            outcomeViewModels[.right]?.setSelected(rightSelected)
        }
    }

    private func isOutcomeInBetslip(_ outcome: MarketOutcomeData?, bettingTickets: [BettingTicket]) -> Bool {
        guard let outcome = outcome else { return false }

        // Check if the betting offer ID is in the betslip
        return bettingTickets.contains { ticket in
            ticket.id == outcome.bettingOfferId
        }
    }

    // MARK: - Static Factory Methods
    private static func createInitialDisplayState(from match: Match, market: Market) -> MarketOutcomesLineDisplayState {
        let outcomes = market.outcomes

        // Determine display mode based on number of outcomes
        let displayMode: MarketDisplayMode
        if outcomes.count == 2 {
            displayMode = .double
        } else if outcomes.count >= 3 {
            displayMode = .triple
        } else {
            displayMode = .triple // Single outcome - use triple with only left outcome
        }

        // Create outcome data with correct selection state from BetslipManager
        let leftOutcome = outcomes.count > 0 ? createOutcomeData(from: outcomes[0]) : nil
        let middleOutcome = outcomes.count > 2 ? createOutcomeData(from: outcomes[1]) : nil
        let rightOutcome = outcomes.count > 1 ? createOutcomeData(from: outcomes[outcomes.count >= 3 ? 2 : 1]) : nil

        return MarketOutcomesLineDisplayState(
            displayMode: displayMode,
            leftOutcome: leftOutcome,
            middleOutcome: middleOutcome,
            rightOutcome: rightOutcome
        )
    }

    private static func createOutcomeData(from outcome: Outcome) -> MarketOutcomeData {
        // Check if this outcome is already in the betslip
        let isSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

        return MarketOutcomeData(
            id: outcome.id,
            bettingOfferId: outcome.bettingOffer.id,
            title: outcome.translatedName,
            value: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd),
            oddsChangeDirection: .none,
            isSelected: isSelected, // Set correct initial selection state
            isDisabled: !outcome.bettingOffer.isAvailable
        )
    }

    // MARK: - Protocol Requirements
    public func updateOddsValue(type: OutcomeType, value: String, changeDirection: OddsChangeDirection) {
        // Legacy method - delegate to the automatic method
        updateOddsValue(type: type, newValue: value)
    }

    public func clearOddsChangeIndicator(type: OutcomeType) {
        guard let outcomeViewModel = outcomeViewModels[type] else { return }
        outcomeViewModel.clearOddsChangeIndicator()
    }

    public func setDisplayMode(_ mode: MarketDisplayMode) {
        let currentState = marketStateSubject.value
        let newState = MarketOutcomesLineDisplayState(
            displayMode: mode,
            leftOutcome: currentState.leftOutcome,
            middleOutcome: currentState.middleOutcome,
            rightOutcome: currentState.rightOutcome
        )
        marketStateSubject.send(newState)
    }

    // MARK: - Helper Methods
    private func convertToOutcomeItemData(_ marketOutcome: MarketOutcomeData) -> OutcomeItemData {
        let displayState = OutcomeDisplayState.normal(isSelected: marketOutcome.isSelected, isBoosted: false)

        return OutcomeItemData(
            id: marketOutcome.id,
            bettingOfferId: marketOutcome.bettingOfferId,
            title: marketOutcome.title,
            value: marketOutcome.value,
            oddsChangeDirection: marketOutcome.oddsChangeDirection,
            displayState: displayState,
            previousValue: marketOutcome.previousValue,
            changeTimestamp: marketOutcome.changeTimestamp
        )
    }
}
