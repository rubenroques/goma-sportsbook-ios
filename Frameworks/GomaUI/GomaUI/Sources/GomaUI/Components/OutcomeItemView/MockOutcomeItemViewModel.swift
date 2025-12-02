import Combine
import UIKit


/// Mock implementation of `OutcomeItemViewModelProtocol` for testing.
final public class MockOutcomeItemViewModel: OutcomeItemViewModelProtocol {

    // MARK: - Subjects
    public let outcomeDataSubject: CurrentValueSubject<OutcomeItemData, Never>
    private let oddsChangeEventSubject: PassthroughSubject<OutcomeItemOddsChangeEvent, Never>
    private let selectionDidChangeSubject: PassthroughSubject<OutcomeSelectionChangeEvent, Never>

    // MARK: - Internal Properties
    internal var cancellables = Set<AnyCancellable>()

    // MARK: - Publishers

    public var oddsChangeEventPublisher: AnyPublisher<OutcomeItemOddsChangeEvent, Never> {
        return oddsChangeEventSubject.eraseToAnyPublisher()
    }

    /// Publisher for selection changes triggered by user interaction.
    /// Parent ViewModels should observe this instead of calling toggleSelection().
    public var selectionDidChangePublisher: AnyPublisher<OutcomeSelectionChangeEvent, Never> {
        return selectionDidChangeSubject.eraseToAnyPublisher()
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
        self.selectionDidChangeSubject = PassthroughSubject()
    }

    // MARK: - User Actions (called by View)

    /// Called by the View when user taps the outcome.
    /// This is the single entry point for user-initiated selection changes.
    /// It toggles the selection and publishes the change for parent observation.
    public func userDidTapOutcome() {
        let currentData = outcomeDataSubject.value

        // Only allow toggling if in normal state
        guard currentData.displayState.canBeSelected else {
            return // Can't select loading/locked/unavailable states
        }

        let newSelected = !currentData.isSelected
        let newData = currentData.withSelection(newSelected)
        outcomeDataSubject.send(newData)

        // Publish selection change event for parent ViewModels to observe
        let event = OutcomeSelectionChangeEvent(
            outcomeId: currentData.id,
            bettingOfferId: currentData.bettingOfferId,
            isSelected: newSelected,
            timestamp: Date()
        )
        selectionDidChangeSubject.send(event)
    }

    // MARK: - State Mutations

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
            bettingOfferId: currentData.bettingOfferId,
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
        print("[BETSLIP_SYNC] MockOutcomeItemViewModel: setSelected(\(selected)) called for outcome '\(currentData.title)' (ID: \(currentData.id), offerID: \(currentData.bettingOfferId ?? "nil")) - current: \(currentData.isSelected)")
        let newData = currentData.withSelection(selected)
        outcomeDataSubject.send(newData)
        print("[BETSLIP_SYNC] MockOutcomeItemViewModel: Published new state with isSelected=\(selected)")
    }

    public func setDisabled(_ disabled: Bool) {
        let currentData = outcomeDataSubject.value
        let newDisplayState: OutcomeDisplayState = disabled ? .unavailable : .normal(isSelected: false, isBoosted: false)
        let newData = currentData.withDisplayState(newDisplayState)
        outcomeDataSubject.send(newData)
    }
    
    // MARK: - Unified State Action
    public func setDisplayState(_ state: OutcomeDisplayState) {
        let currentData = outcomeDataSubject.value
        let newData = currentData.withDisplayState(state)
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
            bettingOfferId: nil,
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
            bettingOfferId: nil,
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
            bettingOfferId: nil,
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
            bettingOfferId: nil,
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
            bettingOfferId: nil,
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
            bettingOfferId: nil,
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
            bettingOfferId: nil,
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
            bettingOfferId: nil,
            title: LocalizationProvider.string("loading_payment_form"),
            value: "",
            displayState: .loading
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }
    
    /// Locked outcome
    public static var lockedOutcome: MockOutcomeItemViewModel {
        let outcomeData = OutcomeItemData(
            id: "locked",
            bettingOfferId: nil,
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
            bettingOfferId: nil,
            title: LocalizationProvider.string("unavailable"),
            value: "-",
            displayState: .unavailable
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }
    
    /// Boosted outcome (selected)
    public static var boostedOutcomeSelected: MockOutcomeItemViewModel {
        let outcomeData = OutcomeItemData(
            id: "boosted_selected",
            bettingOfferId: nil,
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
            bettingOfferId: nil,
            title: "Home",
            value: "2.20",
            displayState: .normal(isSelected: false, isBoosted: true)
        )
        return MockOutcomeItemViewModel(outcomeData: outcomeData)
    }
}
