import Combine
import UIKit

// MARK: - Data Models
public struct MarketOutcomeData: Equatable, Hashable {
    public let id: String
    public let bettingOfferId: String?
    public let title: String
    public let completeName: String?
    public let value: String
    public let oddsChangeDirection: OddsChangeDirection
    public let isSelected: Bool
    public let isDisabled: Bool

    // For odds change tracking
    public let previousValue: String?
    public let changeTimestamp: Date?

    public init(id: String,
                bettingOfferId: String?,
                title: String,
                completeName: String? = nil,
                value: String,
                oddsChangeDirection: OddsChangeDirection = .none,
                isSelected: Bool = false,
                isDisabled: Bool = false,
                previousValue: String? = nil,
                changeTimestamp: Date? = nil) {
        self.id = id
        self.bettingOfferId = bettingOfferId
        self.title = title
        self.completeName = completeName
        self.value = value
        self.oddsChangeDirection = oddsChangeDirection
        self.isSelected = isSelected
        self.isDisabled = isDisabled
        self.previousValue = previousValue
        self.changeTimestamp = changeTimestamp
    }

    /// Creates a new instance with updated odds value and automatic direction calculation
    public func withUpdatedOdds(_ newValue: String) -> MarketOutcomeData {
        let direction = calculateOddsChangeDirection(from: self.value, to: newValue)
        return MarketOutcomeData(
            id: self.id,
            bettingOfferId: self.bettingOfferId,
            title: self.title,
            completeName: self.completeName,
            value: newValue,
            oddsChangeDirection: direction,
            isSelected: self.isSelected,
            isDisabled: self.isDisabled,
            previousValue: self.value,
            changeTimestamp: Date()
        )
    }

    /// Creates a new instance with cleared odds change direction
    public func withClearedOddsChange() -> MarketOutcomeData {
        return MarketOutcomeData(
            id: self.id,
            bettingOfferId: self.bettingOfferId,
            title: self.title,
            completeName: self.completeName,
            value: self.value,
            oddsChangeDirection: .none,
            isSelected: self.isSelected,
            isDisabled: self.isDisabled,
            previousValue: self.previousValue,
            changeTimestamp: self.changeTimestamp
        )
    }

    private func calculateOddsChangeDirection(from oldValue: String, to newValue: String) -> OddsChangeDirection {
        guard let oldDecimal = Double(oldValue),
              let newDecimal = Double(newValue),
              oldDecimal != newDecimal else {
            return .none
        }

        return newDecimal > oldDecimal ? .up : .down
    }
}

// MARK: - Odds Change Event
public struct OddsChangeEvent: Equatable {
    public let outcomeType: OutcomeType
    public let oldValue: String
    public let newValue: String
    public let direction: OddsChangeDirection
    public let timestamp: Date

    public init(outcomeType: OutcomeType,
                oldValue: String,
                newValue: String,
                direction: OddsChangeDirection,
                timestamp: Date = Date()) {
        self.outcomeType = outcomeType
        self.oldValue = oldValue
        self.newValue = newValue
        self.direction = direction
        self.timestamp = timestamp
    }
}

// MARK: - Enums
public enum OddsChangeDirection: Equatable {
    case up
    case down
    case none
}

public enum MarketDisplayMode: Equatable, Hashable {
    case triple  // Three-way market (left, middle, right)
    case double  // Two-way market (left, right only)
    case single  // Single non-interactive placeholder (for empty markets)
    case suspended(text: String)
    case seeAll(text: String)

    /// Convenience computed property to get display text for suspended/seeAll modes
    public var displayText: String? {
        switch self {
        case .suspended(let text):
            return text
        case .seeAll(let text):
            return text
        case .triple, .double, .single:
            return nil
        }
    }
}

public enum OutcomeType: Equatable {
    case left
    case middle
    case right
}

// MARK: - Display State
public struct MarketOutcomesLineDisplayState: Equatable {
    public let displayMode: MarketDisplayMode
    public let leftOutcome: MarketOutcomeData?
    public let middleOutcome: MarketOutcomeData?
    public let rightOutcome: MarketOutcomeData?

    public init(displayMode: MarketDisplayMode = .triple,
                leftOutcome: MarketOutcomeData? = nil,
                middleOutcome: MarketOutcomeData? = nil,
                rightOutcome: MarketOutcomeData? = nil) {
        self.displayMode = displayMode
        self.leftOutcome = leftOutcome
        self.middleOutcome = middleOutcome
        self.rightOutcome = rightOutcome
    }
}

// MARK: - Selection Change Event
/// Event emitted when a child OutcomeItemViewModel's selection changes via user tap.
/// Includes OutcomeType so the View knows which position was affected.
/// This is the proper MVVM pattern: Parent VM observes children, re-publishes for its View.
public struct MarketOutcomeSelectionEvent: Equatable {
    public let outcomeId: String
    public let bettingOfferId: String?
    public let outcomeType: OutcomeType
    public let isSelected: Bool
    public let timestamp: Date

    public init(outcomeId: String,
                bettingOfferId: String?,
                outcomeType: OutcomeType,
                isSelected: Bool,
                timestamp: Date = Date()) {
        self.outcomeId = outcomeId
        self.bettingOfferId = bettingOfferId
        self.outcomeType = outcomeType
        self.isSelected = isSelected
        self.timestamp = timestamp
    }
}

// MARK: - View Model Protocol
public protocol MarketOutcomesLineViewModelProtocol {
    // MARK: - Publishers

    /// Main state publisher for all market data
    var marketStateSubject: CurrentValueSubject<MarketOutcomesLineDisplayState, Never> { get }
    var marketStatePublisher: AnyPublisher<MarketOutcomesLineDisplayState, Never> { get }

    /// Odds change events for animation triggers
    var oddsChangeEventPublisher: AnyPublisher<OddsChangeEvent, Never> { get }

    /// Selection change events from child OutcomeItemViewModels.
    /// View observes this to notify external callbacks (Coordinator/BetslipService).
    /// This is the proper MVVM pattern - parent VM re-publishes child events for its View.
    var outcomeSelectionDidChangePublisher: AnyPublisher<MarketOutcomeSelectionEvent, Never> { get }

    // MARK: - State Mutations (called by external systems)

    /// Sets outcome as selected from external source (e.g., betslip sync)
    func setOutcomeSelected(type: OutcomeType)

    /// Sets outcome as deselected from external source (e.g., betslip sync)
    func setOutcomeDeselected(type: OutcomeType)

    /// Updates odds value with automatic direction calculation
    func updateOddsValue(type: OutcomeType, newValue: String)

    /// Updates odds value with manual direction specification (for testing)
    func updateOddsValue(type: OutcomeType, value: String, changeDirection: OddsChangeDirection)

    /// Sets the display mode
    func setDisplayMode(_ mode: MarketDisplayMode)

    /// Clears odds change indicator after animation completes
    func clearOddsChangeIndicator(type: OutcomeType)

    /// Creates child ViewModel for a given outcome type
    func createOutcomeViewModel(for outcomeType: OutcomeType) -> OutcomeItemViewModelProtocol?

    /// Synchronizes selection states from external source (e.g., betslip)
    func updateSelectionStates(selectedOfferIds: Set<String>)
}
