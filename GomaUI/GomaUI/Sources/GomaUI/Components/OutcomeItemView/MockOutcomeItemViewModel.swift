import Combine
import UIKit

/// Mock implementation of `OutcomeItemViewModelProtocol` for testing.
final public class MockOutcomeItemViewModel: OutcomeItemViewModelProtocol {

    // MARK: - Publishers
    private let outcomeDataSubject: CurrentValueSubject<OutcomeItemData, Never>
    private let oddsChangeEventSubject: PassthroughSubject<OutcomeItemOddsChangeEvent, Never>

    // MARK: - Internal Properties
    internal var cancellables = Set<AnyCancellable>()

    public var oddsChangeEventPublisher: AnyPublisher<OutcomeItemOddsChangeEvent, Never> {
        return oddsChangeEventSubject.eraseToAnyPublisher()
    }

    // Individual publishers for granular updates
    public var titlePublisher: AnyPublisher<String, Never> {
        return outcomeDataSubject.map(\.title).eraseToAnyPublisher()
    }

    public var valuePublisher: AnyPublisher<String, Never> {
        return outcomeDataSubject.map(\.value).eraseToAnyPublisher()
    }

    public var isSelectedPublisher: AnyPublisher<Bool, Never> {
        return outcomeDataSubject.map(\.isSelected).eraseToAnyPublisher()
    }

    public var isDisabledPublisher: AnyPublisher<Bool, Never> {
        return outcomeDataSubject.map(\.isDisabled).eraseToAnyPublisher()
    }
    
    public var displayStatePublisher: AnyPublisher<OutcomeDisplayState, Never> {
        return outcomeDataSubject.map(\.displayState).eraseToAnyPublisher()
    }

    // MARK: - Initialization
    public init(outcomeData: OutcomeItemData) {
        self.outcomeDataSubject = CurrentValueSubject(outcomeData)
        self.oddsChangeEventSubject = PassthroughSubject()
    }

    // MARK: - OutcomeItemViewModelProtocol
    public func toggleSelection() -> Bool {
        let currentData = outcomeDataSubject.value
        
        // Only allow toggling if in normal state
        guard case .normal(let isSelected, let isBoosted) = currentData.displayState else {
            return false // Can't select loading/locked/unavailable states
        }
        
        let newSelectionState = !isSelected
        let newData = currentData.withSelection(newSelectionState)
        outcomeDataSubject.send(newData)
        
        return newSelectionState
    }

    public func updateValue(_ newValue: String) {
        let currentData = outcomeDataSubject.value
        
        // Only emit if the value actually changed
        guard newValue != currentData.value else { return }
        
        // Update data with new value using withUpdatedOdds factory method
        let newData = currentData.withUpdatedOdds(newValue)
        outcomeDataSubject.send(newData)

        // Emit odds change event for animation
        let changeEvent = OutcomeItemOddsChangeEvent(
            outcomeId: currentData.id,
            oldValue: currentData.value,
            newValue: newValue,
            direction: newData.oddsChangeDirection
        )
        oddsChangeEventSubject.send(changeEvent)
    }

    public func updateValue(_ newValue: String, changeDirection: OddsChangeDirection) {
        let currentData = outcomeDataSubject.value
        
        // Update data with new value and specified direction
        let newData = OutcomeItemData(
            id: currentData.id,
            title: currentData.title,
            value: newValue,
            oddsChangeDirection: changeDirection,
            displayState: currentData.displayState,
            previousValue: currentData.value,
            changeTimestamp: Date()
        )
        outcomeDataSubject.send(newData)

        // Emit odds change event for animation if direction is not none
        if changeDirection != .none {
            let changeEvent = OutcomeItemOddsChangeEvent(
                outcomeId: currentData.id,
                oldValue: currentData.value,
                newValue: newValue,
                direction: changeDirection
            )
            oddsChangeEventSubject.send(changeEvent)
        }
    }

    public func setSelected(_ selected: Bool) {
        let currentData = outcomeDataSubject.value
        let newData = currentData.withSelection(selected)
        outcomeDataSubject.send(newData)
    }

    public func setDisabled(_ disabled: Bool) {
        let currentData = outcomeDataSubject.value
        let newDisplayState: OutcomeDisplayState = disabled ? .unavailable : .normal(isSelected: false, isBoosted: false)
        let newData = currentData.withDisplayState(newDisplayState)
        outcomeDataSubject.send(newData)
    }
    
    // MARK: - New State Actions
    public func setDisplayState(_ state: OutcomeDisplayState) {
        let currentData = outcomeDataSubject.value
        let newData = currentData.withDisplayState(state)
        outcomeDataSubject.send(newData)
    }
    
    public func setLoading(_ loading: Bool) {
        let currentData = outcomeDataSubject.value
        let newDisplayState: OutcomeDisplayState = loading ? .loading : .normal(isSelected: false, isBoosted: false)
        let newData = currentData.withDisplayState(newDisplayState)
        outcomeDataSubject.send(newData)
    }
    
    public func setLocked(_ locked: Bool) {
        let currentData = outcomeDataSubject.value
        let newDisplayState: OutcomeDisplayState = locked ? .locked : .normal(isSelected: false, isBoosted: false)
        let newData = currentData.withDisplayState(newDisplayState)
        outcomeDataSubject.send(newData)
    }
    
    public func setUnavailable(_ unavailable: Bool) {
        let currentData = outcomeDataSubject.value
        let newDisplayState: OutcomeDisplayState = unavailable ? .unavailable : .normal(isSelected: false, isBoosted: false)
        let newData = currentData.withDisplayState(newDisplayState)
        outcomeDataSubject.send(newData)
    }
    
    public func setBoosted(_ boosted: Bool) {
        let currentData = outcomeDataSubject.value
        let newData = currentData.withBoost(boosted)
        outcomeDataSubject.send(newData)
    }

    public func clearOddsChangeIndicator() {
        let currentData = outcomeDataSubject.value
        let newData = currentData.withClearedOddsChange()
        outcomeDataSubject.send(newData)
    }
    
    // MARK: - Helper Methods
    private func calculateOddsChangeDirection(from oldValue: String, to newValue: String) -> OddsChangeDirection {
        guard let oldDecimal = Double(oldValue),
              let newDecimal = Double(newValue),
              oldDecimal != newDecimal else {
            return .none
        }

        return newDecimal > oldDecimal ? .up : .down
    }
}

// MARK: - Mock Factory
extension MockOutcomeItemViewModel {

    /// Home outcome (selected)
    public static var homeOutcome: MockOutcomeItemViewModel {
        let outcomeData = OutcomeItemData(
            id: "home",
            title: "Home",
            value: "1.85",
            displayState: .normal(isSelected: true, isBoosted: false)
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }

    /// Draw outcome (unselected)
    public static var drawOutcome: MockOutcomeItemViewModel {
        let outcomeData = OutcomeItemData(
            id: "draw",
            title: "Draw",
            value: "3.55",
            displayState: .normal(isSelected: false, isBoosted: false)
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }

    /// Away outcome (unselected)
    public static var awayOutcome: MockOutcomeItemViewModel {
        let outcomeData = OutcomeItemData(
            id: "away",
            title: "Away",
            value: "4.20",
            displayState: .normal(isSelected: false, isBoosted: false)
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }

    /// Over outcome with odds increase
    public static var overOutcomeUp: MockOutcomeItemViewModel {
        let outcomeData = OutcomeItemData(
            id: "over_2_5",
            title: "Over 2.5",
            value: "1.95",
            oddsChangeDirection: .up,
            displayState: .normal(isSelected: false, isBoosted: false)
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }

    /// Under outcome with odds decrease
    public static var underOutcomeDown: MockOutcomeItemViewModel {
        let outcomeData = OutcomeItemData(
            id: "under_2_5",
            title: "Under 2.5",
            value: "1.80",
            oddsChangeDirection: .down,
            displayState: .normal(isSelected: false, isBoosted: false)
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }

    /// Disabled outcome (now unavailable)
    public static var disabledOutcome: MockOutcomeItemViewModel {
        let outcomeData = OutcomeItemData(
            id: "disabled",
            title: "Disabled",
            value: "2.50",
            displayState: .unavailable
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }

    /// Custom outcome factory
    public static func customOutcome(id: String,
                                   title: String,
                                   value: String,
                                   oddsChangeDirection: OddsChangeDirection = .none,
                                   isSelected: Bool = false,
                                   isDisabled: Bool = false,
                                   displayState: OutcomeDisplayState? = nil) -> MockOutcomeItemViewModel {
        let outcomeData = OutcomeItemData(
            id: id,
            title: title,
            value: value,
            oddsChangeDirection: oddsChangeDirection,
            displayState: displayState,
            isSelected: isSelected,
            isDisabled: isDisabled
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }
    
    // MARK: - New State Factories
    
    /// Loading outcome
    public static var loadingOutcome: MockOutcomeItemViewModel {
        let outcomeData = OutcomeItemData(
            id: "loading",
            title: "Loading",
            value: "",
            displayState: .loading
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }
    
    /// Locked outcome
    public static var lockedOutcome: MockOutcomeItemViewModel {
        let outcomeData = OutcomeItemData(
            id: "locked",
            title: "Locked",
            value: "",
            displayState: .locked
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }
    
    /// Unavailable outcome
    public static var unavailableOutcome: MockOutcomeItemViewModel {
        let outcomeData = OutcomeItemData(
            id: "unavailable",
            title: "Unavailable",
            value: "-",
            displayState: .unavailable
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }
    
    /// Boosted outcome (selected)
    public static var boostedOutcomeSelected: MockOutcomeItemViewModel {
        let outcomeData = OutcomeItemData(
            id: "boosted_selected",
            title: "Home",
            value: "2.20",
            displayState: .normal(isSelected: true, isBoosted: true)
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }
    
    /// Boosted outcome (unselected)
    public static var boostedOutcome: MockOutcomeItemViewModel {
        let outcomeData = OutcomeItemData(
            id: "boosted",
            title: "Home",
            value: "2.20",
            displayState: .normal(isSelected: false, isBoosted: true)
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }
}
