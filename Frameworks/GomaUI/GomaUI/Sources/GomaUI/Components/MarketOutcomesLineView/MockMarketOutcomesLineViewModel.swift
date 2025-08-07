import Combine
import UIKit

/// Mock implementation of `MarketOutcomesLineViewModelProtocol` for testing.
final public class MockMarketOutcomesLineViewModel: MarketOutcomesLineViewModelProtocol {

    // MARK: - Publishers
    public let marketStateSubject: CurrentValueSubject<MarketOutcomesLineDisplayState, Never>
    private let oddsChangeEventSubject: PassthroughSubject<OddsChangeEvent, Never>

    public var marketStatePublisher: AnyPublisher<MarketOutcomesLineDisplayState, Never> {
        return marketStateSubject.eraseToAnyPublisher()
    }

    public var oddsChangeEventPublisher: AnyPublisher<OddsChangeEvent, Never> {
        return oddsChangeEventSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization
    public init(displayMode: MarketDisplayMode = .triple,
                leftOutcome: MarketOutcomeData? = nil,
                middleOutcome: MarketOutcomeData? = nil,
                rightOutcome: MarketOutcomeData? = nil) {

        let initialState = MarketOutcomesLineDisplayState(
            displayMode: displayMode,
            leftOutcome: leftOutcome,
            middleOutcome: middleOutcome,
            rightOutcome: rightOutcome
        )

        self.marketStateSubject = CurrentValueSubject(initialState)
        self.oddsChangeEventSubject = PassthroughSubject()
    }

    // MARK: - MarketOutcomesLineViewModelProtocol
    public func toggleOutcome(type: OutcomeType) -> Bool {
        let currentState = marketStateSubject.value
        guard let currentOutcome = getOutcome(from: currentState, type: type) else { return false }

        let newSelectionState = !currentOutcome.isSelected
        let updatedState = updateOutcomeSelection(in: currentState, type: type, isSelected: newSelectionState)
        marketStateSubject.send(updatedState)

        return newSelectionState
    }

    // MARK: - Enhanced Odds Update (Primary Method)
    public func updateOddsValue(type: OutcomeType, newValue: String) {
        let currentState = marketStateSubject.value
        guard let currentOutcome = getOutcome(from: currentState, type: type) else { return }

        // Create updated outcome with automatic direction calculation
        let updatedOutcome = currentOutcome.withUpdatedOdds(newValue)

        // Only emit if the value actually changed
        guard updatedOutcome.value != currentOutcome.value else { return }

        // Update the state
        let updatedState = updateOutcome(in: currentState, type: type, outcome: updatedOutcome)
        marketStateSubject.send(updatedState)

        // Emit odds change event for animation
        let changeEvent = OddsChangeEvent(
            outcomeType: type,
            oldValue: currentOutcome.value,
            newValue: newValue,
            direction: updatedOutcome.oddsChangeDirection
        )
        oddsChangeEventSubject.send(changeEvent)
    }

    // MARK: - Legacy Method (for testing/manual control)
    public func updateOddsValue(type: OutcomeType, value: String, changeDirection: OddsChangeDirection) {
        let currentState = marketStateSubject.value
        guard let currentOutcome = getOutcome(from: currentState, type: type) else { return }

        let updatedOutcome = MarketOutcomeData(
            id: currentOutcome.id,
            title: currentOutcome.title,
            value: value,
            oddsChangeDirection: changeDirection,
            isSelected: currentOutcome.isSelected,
            isDisabled: currentOutcome.isDisabled,
            previousValue: currentOutcome.value,
            changeTimestamp: Date()
        )

        let updatedState = updateOutcome(in: currentState, type: type, outcome: updatedOutcome)
        marketStateSubject.send(updatedState)

        // Emit odds change event for animation if direction is not none
        if changeDirection != .none {
            let changeEvent = OddsChangeEvent(
                outcomeType: type,
                oldValue: currentOutcome.value,
                newValue: value,
                direction: changeDirection
            )
            oddsChangeEventSubject.send(changeEvent)
        }
    }

    public func clearOddsChangeIndicator(type: OutcomeType) {
        let currentState = marketStateSubject.value
        guard let currentOutcome = getOutcome(from: currentState, type: type) else { return }

        let clearedOutcome = currentOutcome.withClearedOddsChange()
        let updatedState = updateOutcome(in: currentState, type: type, outcome: clearedOutcome)
        marketStateSubject.send(updatedState)
    }

    public func setDisplayMode(_ mode: MarketDisplayMode) {
        let currentState = marketStateSubject.value
        let updatedState = MarketOutcomesLineDisplayState(
            displayMode: mode,
            leftOutcome: currentState.leftOutcome,
            middleOutcome: currentState.middleOutcome,
            rightOutcome: currentState.rightOutcome
        )
        marketStateSubject.send(updatedState)
    }

    // MARK: - Child ViewModel Creation
    public func createOutcomeViewModel(for outcomeType: OutcomeType) -> OutcomeItemViewModelProtocol? {
        let currentState = marketStateSubject.value
        guard let outcomeData = getOutcome(from: currentState, type: outcomeType) else { return nil }

        // Convert MarketOutcomeData to OutcomeItemData
        let outcomeItemData = OutcomeItemData(
            id: outcomeData.id,
            title: outcomeData.title,
            value: outcomeData.value,
            oddsChangeDirection: outcomeData.oddsChangeDirection,
            isSelected: outcomeData.isSelected,
            isDisabled: outcomeData.isDisabled,
            previousValue: outcomeData.previousValue,
            changeTimestamp: outcomeData.changeTimestamp
        )

        // Create and return a new child view model
        let childViewModel = MockOutcomeItemViewModel(outcomeData: outcomeItemData)

        // Set up binding to forward odds change events from parent to child
        oddsChangeEventPublisher
            .filter { $0.outcomeType == outcomeType }
            .sink { [weak childViewModel] event in
                childViewModel?.updateValue(event.newValue, changeDirection: event.direction)
            }
            .store(in: &childViewModel.cancellables)

        // Set up binding to sync selection state from parent to child
        marketStatePublisher
            .compactMap { [weak self] state in
                self?.getOutcome(from: state, type: outcomeType)
            }
            .removeDuplicates()
            .sink { [weak childViewModel] outcomeData in
                childViewModel?.setSelected(outcomeData.isSelected)
                childViewModel?.setDisabled(outcomeData.isDisabled)
            }
            .store(in: &childViewModel.cancellables)

        return childViewModel
    }

    // MARK: - Helper Methods
    private func getOutcome(from state: MarketOutcomesLineDisplayState, type: OutcomeType) -> MarketOutcomeData? {
        switch type {
        case .left: return state.leftOutcome
        case .middle: return state.middleOutcome
        case .right: return state.rightOutcome
        }
    }

    private func updateOutcome(in state: MarketOutcomesLineDisplayState, type: OutcomeType, outcome: MarketOutcomeData) -> MarketOutcomesLineDisplayState {
        switch type {
        case .left:
            return MarketOutcomesLineDisplayState(
                displayMode: state.displayMode,
                leftOutcome: outcome,
                middleOutcome: state.middleOutcome,
                rightOutcome: state.rightOutcome
            )
        case .middle:
            return MarketOutcomesLineDisplayState(
                displayMode: state.displayMode,
                leftOutcome: state.leftOutcome,
                middleOutcome: outcome,
                rightOutcome: state.rightOutcome
            )
        case .right:
            return MarketOutcomesLineDisplayState(
                displayMode: state.displayMode,
                leftOutcome: state.leftOutcome,
                middleOutcome: state.middleOutcome,
                rightOutcome: outcome
            )
        }
    }

    private func updateOutcomeSelection(in state: MarketOutcomesLineDisplayState, type: OutcomeType, isSelected: Bool) -> MarketOutcomesLineDisplayState {
        guard let currentOutcome = getOutcome(from: state, type: type) else { return state }

        let updatedOutcome = MarketOutcomeData(
            id: currentOutcome.id,
            title: currentOutcome.title,
            value: currentOutcome.value,
            oddsChangeDirection: currentOutcome.oddsChangeDirection,
            isSelected: isSelected,
            isDisabled: currentOutcome.isDisabled,
            previousValue: currentOutcome.previousValue,
            changeTimestamp: currentOutcome.changeTimestamp
        )

        return updateOutcome(in: state, type: type, outcome: updatedOutcome)
    }
}

// MARK: - Mock Factory
extension MockMarketOutcomesLineViewModel {

    /// Three-way market (1X2) - typical football match
    public static var threeWayMarket: MockMarketOutcomesLineViewModel {
        return MockMarketOutcomesLineViewModel(
            displayMode: .triple,
            leftOutcome: MarketOutcomeData(
                id: "home",
                title: "Home",
                value: "1.85",
                oddsChangeDirection: .none,
                isSelected: false,
                isDisabled: false
            ),
            middleOutcome: MarketOutcomeData(
                id: "draw",
                title: "Draw",
                value: "3.55",
                oddsChangeDirection: .none,
                isSelected: false,
                isDisabled: false
            ),
            rightOutcome: MarketOutcomeData(
                id: "away",
                title: "Away",
                value: "4.20",
                oddsChangeDirection: .none,
                isSelected: false,
                isDisabled: false
            )
        )
    }

    /// Two-way market (Over/Under)
    public static var twoWayMarket: MockMarketOutcomesLineViewModel {
        return MockMarketOutcomesLineViewModel(
            displayMode: .double,
            leftOutcome: MarketOutcomeData(
                id: "under",
                title: "Under 2.5",
                value: "1.95",
                oddsChangeDirection: .none,
                isSelected: false,
                isDisabled: false
            ),
            middleOutcome: nil,
            rightOutcome: MarketOutcomeData(
                id: "over",
                title: "Over 2.5",
                value: "1.85",
                oddsChangeDirection: .none,
                isSelected: false,
                isDisabled: false
            )
        )
    }

    /// Market with selected outcome
    public static var selectedOutcome: MockMarketOutcomesLineViewModel {
        return MockMarketOutcomesLineViewModel(
            displayMode: .triple,
            leftOutcome: MarketOutcomeData(
                id: "home",
                title: "Home",
                value: "1.85",
                oddsChangeDirection: .none,
                isSelected: true,
                isDisabled: false
            ),
            middleOutcome: MarketOutcomeData(
                id: "draw",
                title: "Draw",
                value: "3.55",
                oddsChangeDirection: .none,
                isSelected: false,
                isDisabled: false
            ),
            rightOutcome: MarketOutcomeData(
                id: "away",
                title: "Away",
                value: "4.20",
                oddsChangeDirection: .none,
                isSelected: false,
                isDisabled: false
            )
        )
    }

    /// Market with odds changes
    public static var oddsChanges: MockMarketOutcomesLineViewModel {
        return MockMarketOutcomesLineViewModel(
            displayMode: .triple,
            leftOutcome: MarketOutcomeData(
                id: "home",
                title: "Home",
                value: "1.90",
                oddsChangeDirection: .up,
                isSelected: false,
                isDisabled: false
            ),
            middleOutcome: MarketOutcomeData(
                id: "draw",
                title: "Draw",
                value: "3.55",
                oddsChangeDirection: .none,
                isSelected: false,
                isDisabled: false
            ),
            rightOutcome: MarketOutcomeData(
                id: "away",
                title: "Away",
                value: "4.10",
                oddsChangeDirection: .down,
                isSelected: false,
                isDisabled: false
            )
        )
    }

    /// Market with disabled outcome
    public static var disabledOutcome: MockMarketOutcomesLineViewModel {
        return MockMarketOutcomesLineViewModel(
            displayMode: .triple,
            leftOutcome: MarketOutcomeData(
                id: "home",
                title: "Home",
                value: "1.85",
                oddsChangeDirection: .none,
                isSelected: false,
                isDisabled: true
            ),
            middleOutcome: MarketOutcomeData(
                id: "draw",
                title: "Draw",
                value: "3.55",
                oddsChangeDirection: .none,
                isSelected: false,
                isDisabled: false
            ),
            rightOutcome: MarketOutcomeData(
                id: "away",
                title: "Away",
                value: "4.20",
                oddsChangeDirection: .none,
                isSelected: false,
                isDisabled: false
            )
        )
    }

    /// Suspended market
    public static var suspendedMarket: MockMarketOutcomesLineViewModel {
        return MockMarketOutcomesLineViewModel(
            displayMode: .suspended(text: "Market Suspended")
        )
    }

    /// See all markets state
    public static var seeAllMarket: MockMarketOutcomesLineViewModel {
        return MockMarketOutcomesLineViewModel(
            displayMode: .seeAll(text: "See All Markets")
        )
    }

    /// Double chance market
    public static var doubleChanceMarket: MockMarketOutcomesLineViewModel {
        return MockMarketOutcomesLineViewModel(
            displayMode: .triple,
            leftOutcome: MarketOutcomeData(
                id: "1x",
                title: "1X",
                value: "1.25",
                oddsChangeDirection: .none,
                isSelected: false,
                isDisabled: false
            ),
            middleOutcome: MarketOutcomeData(
                id: "12",
                title: "12",
                value: "1.15",
                oddsChangeDirection: .none,
                isSelected: false,
                isDisabled: false
            ),
            rightOutcome: MarketOutcomeData(
                id: "x2",
                title: "X2",
                value: "2.10",
                oddsChangeDirection: .none,
                isSelected: false,
                isDisabled: false
            )
        )
    }

    /// Asian handicap market
    public static var asianHandicapMarket: MockMarketOutcomesLineViewModel {
        return MockMarketOutcomesLineViewModel(
            displayMode: .double,
            leftOutcome: MarketOutcomeData(
                id: "home_handicap",
                title: "Home -1.5",
                value: "2.15",
                oddsChangeDirection: .none,
                isSelected: false,
                isDisabled: false
            ),
            middleOutcome: nil,
            rightOutcome: MarketOutcomeData(
                id: "away_handicap",
                title: "Away +1.5",
                value: "1.75",
                oddsChangeDirection: .none,
                isSelected: false,
                isDisabled: false
            )
        )
    }

    /// Custom market factory
    public static func customMarket(
        displayMode: MarketDisplayMode = .triple,
        leftOutcome: MarketOutcomeData? = nil,
        middleOutcome: MarketOutcomeData? = nil,
        rightOutcome: MarketOutcomeData? = nil
    ) -> MockMarketOutcomesLineViewModel {
        return MockMarketOutcomesLineViewModel(
            displayMode: displayMode,
            leftOutcome: leftOutcome,
            middleOutcome: middleOutcome,
            rightOutcome: rightOutcome
        )
    }
}
