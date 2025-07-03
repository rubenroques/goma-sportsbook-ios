import Combine
import UIKit

// MARK: - Data Models
public struct MarketOutcomeData: Equatable, Hashable {
    public let id: String
    public let title: String
    public let value: String
    public let oddsChangeDirection: OddsChangeDirection
    public let isSelected: Bool
    public let isDisabled: Bool

    // For odds change tracking
    public let previousValue: String?
    public let changeTimestamp: Date?

    public init(id: String,
                title: String,
                value: String,
                oddsChangeDirection: OddsChangeDirection = .none,
                isSelected: Bool = false,
                isDisabled: Bool = false,
                previousValue: String? = nil,
                changeTimestamp: Date? = nil) {
        self.id = id
        self.title = title
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
            title: self.title,
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
            title: self.title,
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
    case suspended(text: String)
    case seeAll(text: String)

    /// Convenience computed property to get display text for suspended/seeAll modes
    public var displayText: String? {
        switch self {
        case .suspended(let text):
            return text
        case .seeAll(let text):
            return text
        case .triple, .double:
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

// MARK: - View Model Protocol
public protocol MarketOutcomesLineViewModelProtocol {
    // Single state publisher for all market data
    var marketStatePublisher: AnyPublisher<MarketOutcomesLineDisplayState, Never> { get }

    // Odds change events for animation triggers (separate for performance)
    var oddsChangeEventPublisher: AnyPublisher<OddsChangeEvent, Never> { get }

    // Actions
    func toggleOutcome(type: OutcomeType) -> Bool

    // Enhanced odds update with automatic direction calculation
    func updateOddsValue(type: OutcomeType, newValue: String)

    // Legacy method for manual direction specification (for testing)
    func updateOddsValue(type: OutcomeType, value: String, changeDirection: OddsChangeDirection)

    func setDisplayMode(_ mode: MarketDisplayMode)

    // Clear odds change indicators (called after animation completes)
    func clearOddsChangeIndicator(type: OutcomeType)

    // Child ViewModel creation - following MVVM pattern where parent creates children
    func createOutcomeViewModel(for outcomeType: OutcomeType) -> OutcomeItemViewModelProtocol?
}
