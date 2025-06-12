import Combine
import UIKit

/// Mock implementation of `OutcomeItemViewModelProtocol` for testing.
final public class MockOutcomeItemViewModel: OutcomeItemViewModelProtocol {

    // MARK: - Publishers
    private let displayStateSubject: CurrentValueSubject<OutcomeItemDisplayState, Never>
    private let oddsChangeEventSubject: PassthroughSubject<OutcomeItemOddsChangeEvent, Never>

    // MARK: - Internal Properties
    internal var cancellables = Set<AnyCancellable>()

    public var displayStatePublisher: AnyPublisher<OutcomeItemDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }

    public var oddsChangeEventPublisher: AnyPublisher<OutcomeItemOddsChangeEvent, Never> {
        return oddsChangeEventSubject.eraseToAnyPublisher()
    }

    // Individual publishers for granular updates
    public var titlePublisher: AnyPublisher<String, Never> {
        return displayStateSubject
            .map { $0.outcomeData.title }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public var valuePublisher: AnyPublisher<String, Never> {
        return displayStateSubject
            .map { $0.outcomeData.value }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public var isSelectedPublisher: AnyPublisher<Bool, Never> {
        return displayStateSubject
            .map { $0.outcomeData.isSelected }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public var isDisabledPublisher: AnyPublisher<Bool, Never> {
        return displayStateSubject
            .map { $0.outcomeData.isDisabled }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    // MARK: - Initialization
    public init(outcomeData: OutcomeItemData) {
        let initialState = OutcomeItemDisplayState(outcomeData: outcomeData)
        self.displayStateSubject = CurrentValueSubject(initialState)
        self.oddsChangeEventSubject = PassthroughSubject()
    }

    // MARK: - OutcomeItemViewModelProtocol
    public func toggleSelection() -> Bool {
        let currentData = displayStateSubject.value.outcomeData
        let newSelectionState = !currentData.isSelected

        let updatedData = OutcomeItemData(
            id: currentData.id,
            title: currentData.title,
            value: currentData.value,
            oddsChangeDirection: currentData.oddsChangeDirection,
            isSelected: newSelectionState,
            isDisabled: currentData.isDisabled,
            previousValue: currentData.previousValue,
            changeTimestamp: currentData.changeTimestamp
        )

        let updatedState = OutcomeItemDisplayState(outcomeData: updatedData)
        displayStateSubject.send(updatedState)

        return newSelectionState
    }

    public func updateValue(_ newValue: String) {
        let currentData = displayStateSubject.value.outcomeData

        // Create updated outcome with automatic direction calculation
        let updatedData = currentData.withUpdatedOdds(newValue)

        // Only emit if the value actually changed
        guard updatedData.value != currentData.value else { return }

        let updatedState = OutcomeItemDisplayState(outcomeData: updatedData)
        displayStateSubject.send(updatedState)

        // Emit odds change event for animation
        let changeEvent = OutcomeItemOddsChangeEvent(
            outcomeId: currentData.id,
            oldValue: currentData.value,
            newValue: newValue,
            direction: updatedData.oddsChangeDirection
        )
        oddsChangeEventSubject.send(changeEvent)
    }

    public func updateValue(_ newValue: String, changeDirection: OddsChangeDirection) {
        let currentData = displayStateSubject.value.outcomeData

        let updatedData = OutcomeItemData(
            id: currentData.id,
            title: currentData.title,
            value: newValue,
            oddsChangeDirection: changeDirection,
            isSelected: currentData.isSelected,
            isDisabled: currentData.isDisabled,
            previousValue: currentData.value,
            changeTimestamp: Date()
        )

        let updatedState = OutcomeItemDisplayState(outcomeData: updatedData)
        displayStateSubject.send(updatedState)

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
        let currentData = displayStateSubject.value.outcomeData

        let updatedData = OutcomeItemData(
            id: currentData.id,
            title: currentData.title,
            value: currentData.value,
            oddsChangeDirection: currentData.oddsChangeDirection,
            isSelected: selected,
            isDisabled: currentData.isDisabled,
            previousValue: currentData.previousValue,
            changeTimestamp: currentData.changeTimestamp
        )

        let updatedState = OutcomeItemDisplayState(outcomeData: updatedData)
        displayStateSubject.send(updatedState)
    }

    public func setDisabled(_ disabled: Bool) {
        let currentData = displayStateSubject.value.outcomeData

        let updatedData = OutcomeItemData(
            id: currentData.id,
            title: currentData.title,
            value: currentData.value,
            oddsChangeDirection: currentData.oddsChangeDirection,
            isSelected: currentData.isSelected,
            isDisabled: disabled,
            previousValue: currentData.previousValue,
            changeTimestamp: currentData.changeTimestamp
        )

        let updatedState = OutcomeItemDisplayState(outcomeData: updatedData)
        displayStateSubject.send(updatedState)
    }

    public func clearOddsChangeIndicator() {
        let currentData = displayStateSubject.value.outcomeData
        let clearedData = currentData.withClearedOddsChange()

        let updatedState = OutcomeItemDisplayState(outcomeData: clearedData)
        displayStateSubject.send(updatedState)
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
            oddsChangeDirection: .none,
            isSelected: true,
            isDisabled: false
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }

    /// Draw outcome (unselected)
    public static var drawOutcome: MockOutcomeItemViewModel {
        let outcomeData = OutcomeItemData(
            id: "draw",
            title: "Draw",
            value: "3.55",
            oddsChangeDirection: .none,
            isSelected: false,
            isDisabled: false
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }

    /// Away outcome (unselected)
    public static var awayOutcome: MockOutcomeItemViewModel {
        let outcomeData = OutcomeItemData(
            id: "away",
            title: "Away",
            value: "4.20",
            oddsChangeDirection: .none,
            isSelected: false,
            isDisabled: false
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
            isSelected: false,
            isDisabled: false
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
            isSelected: false,
            isDisabled: false
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }

    /// Disabled outcome
    public static var disabledOutcome: MockOutcomeItemViewModel {
        let outcomeData = OutcomeItemData(
            id: "disabled",
            title: "Disabled",
            value: "2.50",
            oddsChangeDirection: .none,
            isSelected: false,
            isDisabled: true
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }

    /// Custom outcome factory
    public static func customOutcome(id: String,
                                   title: String,
                                   value: String,
                                   oddsChangeDirection: OddsChangeDirection = .none,
                                   isSelected: Bool = false,
                                   isDisabled: Bool = false) -> MockOutcomeItemViewModel {
        let outcomeData = OutcomeItemData(
            id: id,
            title: title,
            value: value,
            oddsChangeDirection: oddsChangeDirection,
            isSelected: isSelected,
            isDisabled: isDisabled
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }
}
