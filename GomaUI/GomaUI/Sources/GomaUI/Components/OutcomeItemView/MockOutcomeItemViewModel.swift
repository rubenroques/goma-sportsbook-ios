import Combine
import UIKit

/// Mock implementation of `OutcomeItemViewModelProtocol` for testing.
final public class MockOutcomeItemViewModel: OutcomeItemViewModelProtocol {

    // MARK: - Publishers
    private let titleSubject: CurrentValueSubject<String, Never>
    private let valueSubject: CurrentValueSubject<String, Never>
    private let isSelectedSubject: CurrentValueSubject<Bool, Never>
    private let isDisabledSubject: CurrentValueSubject<Bool, Never>
    private let oddsChangeEventSubject: PassthroughSubject<OutcomeItemOddsChangeEvent, Never>

    // MARK: - Internal Properties
    internal var cancellables = Set<AnyCancellable>()

    public var oddsChangeEventPublisher: AnyPublisher<OutcomeItemOddsChangeEvent, Never> {
        return oddsChangeEventSubject.eraseToAnyPublisher()
    }

    // Individual publishers for granular updates
    public var titlePublisher: AnyPublisher<String, Never> {
        return titleSubject.eraseToAnyPublisher()
    }

    public var valuePublisher: AnyPublisher<String, Never> {
        return valueSubject.eraseToAnyPublisher()
    }

    public var isSelectedPublisher: AnyPublisher<Bool, Never> {
        return isSelectedSubject.eraseToAnyPublisher()
    }

    public var isDisabledPublisher: AnyPublisher<Bool, Never> {
        return isDisabledSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization
    public init(outcomeData: OutcomeItemData) {
        self.titleSubject = CurrentValueSubject(outcomeData.title)
        self.valueSubject = CurrentValueSubject(outcomeData.value)
        self.isSelectedSubject = CurrentValueSubject(outcomeData.isSelected)
        self.isDisabledSubject = CurrentValueSubject(outcomeData.isDisabled)
        self.oddsChangeEventSubject = PassthroughSubject()
    }

    // MARK: - OutcomeItemViewModelProtocol
    public func toggleSelection() -> Bool {
        let newSelectionState = !isSelectedSubject.value
        isSelectedSubject.send(newSelectionState)
        return newSelectionState
    }

    public func updateValue(_ newValue: String) {
        let currentValue = valueSubject.value
        
        // Only emit if the value actually changed
        guard newValue != currentValue else { return }
        
        // Calculate odds change direction
        let direction = calculateOddsChangeDirection(from: currentValue, to: newValue)
        
        // Update value
        valueSubject.send(newValue)

        // Emit odds change event for animation
        let changeEvent = OutcomeItemOddsChangeEvent(
            outcomeId: titleSubject.value, // Using title as ID for mock
            oldValue: currentValue,
            newValue: newValue,
            direction: direction
        )
        oddsChangeEventSubject.send(changeEvent)
    }

    public func updateValue(_ newValue: String, changeDirection: OddsChangeDirection) {
        let currentValue = valueSubject.value
        
        // Update value
        valueSubject.send(newValue)

        // Emit odds change event for animation if direction is not none
        if changeDirection != .none {
            let changeEvent = OutcomeItemOddsChangeEvent(
                outcomeId: titleSubject.value, // Using title as ID for mock
                oldValue: currentValue,
                newValue: newValue,
                direction: changeDirection
            )
            oddsChangeEventSubject.send(changeEvent)
        }
    }

    public func setSelected(_ selected: Bool) {
        isSelectedSubject.send(selected)
    }

    public func setDisabled(_ disabled: Bool) {
        isDisabledSubject.send(disabled)
    }

    public func clearOddsChangeIndicator() {
        // No longer needed - odds change direction is handled by animation events only
        // Individual publishers don't track change direction state
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
