import Combine
import UIKit

// MARK: - Display State Enum
public enum OutcomeDisplayState: Hashable {
    case loading
    case locked
    case unavailable  // Covers both disabled and no-market cases
    case normal(isSelected: Bool, isBoosted: Bool)
    
    public var isSelected: Bool {
        switch self {
        case .normal(let selected, _):
            return selected
        case .loading, .locked, .unavailable:
            return false
        }
    }
    
    public var canBeSelected: Bool {
        switch self {
        case .normal:
            return true
        case .loading, .locked, .unavailable:
            return false
        }
    }
    
    public var isBoosted: Bool {
        switch self {
        case .normal(_, let boosted):
            return boosted
        case .loading, .locked, .unavailable:
            return false
        }
    }
    
    public var isDisabled: Bool {
        switch self {
        case .unavailable:
            return true
        case .loading, .locked, .normal:
            return false
        }
    }
}

// MARK: - Data Models
public struct OutcomeItemData: Equatable, Hashable {
    public let id: String
    public let title: String
    public let value: String
    public let oddsChangeDirection: OddsChangeDirection
    public let displayState: OutcomeDisplayState

    // For odds change tracking
    public let previousValue: String?
    public let changeTimestamp: Date?
    
    // Computed properties for backward compatibility
    public var isSelected: Bool { displayState.isSelected }
    public var isDisabled: Bool { displayState.isDisabled }

    public init(id: String,
                title: String,
                value: String,
                oddsChangeDirection: OddsChangeDirection = .none,
                displayState: OutcomeDisplayState? = nil,
                isSelected: Bool = false,
                isDisabled: Bool = false,
                previousValue: String? = nil,
                changeTimestamp: Date? = nil) {
        self.id = id
        self.title = title
        self.value = value
        self.oddsChangeDirection = oddsChangeDirection
        self.previousValue = previousValue
        self.changeTimestamp = changeTimestamp
        
        // Determine display state - prioritize explicit displayState, then legacy parameters
        if let displayState = displayState {
            self.displayState = displayState
        } else if isDisabled {
            self.displayState = .unavailable
        } else {
            self.displayState = .normal(isSelected: isSelected, isBoosted: false)
        }
    }

    /// Creates a new instance with updated odds value and automatic direction calculation
    public func withUpdatedOdds(_ newValue: String) -> OutcomeItemData {
        let direction = calculateOddsChangeDirection(from: self.value, to: newValue)
        return OutcomeItemData(
            id: self.id,
            title: self.title,
            value: newValue,
            oddsChangeDirection: direction,
            displayState: self.displayState,
            previousValue: self.value,
            changeTimestamp: Date()
        )
    }

    /// Creates a new instance with cleared odds change direction
    public func withClearedOddsChange() -> OutcomeItemData {
        return OutcomeItemData(
            id: self.id,
            title: self.title,
            value: self.value,
            oddsChangeDirection: .none,
            displayState: self.displayState,
            previousValue: self.previousValue,
            changeTimestamp: self.changeTimestamp
        )
    }
    
    /// Creates a new instance with updated display state
    public func withDisplayState(_ newDisplayState: OutcomeDisplayState) -> OutcomeItemData {
        return OutcomeItemData(
            id: self.id,
            title: self.title,
            value: self.value,
            oddsChangeDirection: self.oddsChangeDirection,
            displayState: newDisplayState,
            previousValue: self.previousValue,
            changeTimestamp: self.changeTimestamp
        )
    }
    
    /// Creates a new instance with updated selection state (convenience method)
    public func withSelection(_ selected: Bool) -> OutcomeItemData {
        let newDisplayState: OutcomeDisplayState
        switch self.displayState {
        case .normal(_, let isBoosted):
            newDisplayState = .normal(isSelected: selected, isBoosted: isBoosted)
        default:
            // Can't select non-normal states
            newDisplayState = self.displayState
        }
        return withDisplayState(newDisplayState)
    }
    
    /// Creates a new instance with updated boost state (convenience method)
    public func withBoost(_ boosted: Bool) -> OutcomeItemData {
        let newDisplayState: OutcomeDisplayState
        switch self.displayState {
        case .normal(let isSelected, _):
            newDisplayState = .normal(isSelected: isSelected, isBoosted: boosted)
        default:
            // Can't boost non-normal states
            newDisplayState = self.displayState
        }
        return withDisplayState(newDisplayState)
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

// MARK: - Display State
public struct OutcomeItemDisplayState: Equatable {
    public let outcomeData: OutcomeItemData

    public init(outcomeData: OutcomeItemData) {
        self.outcomeData = outcomeData
    }
}

// MARK: - Odds Change Event
public struct OutcomeItemOddsChangeEvent: Equatable {
    public let outcomeId: String
    public let oldValue: String
    public let newValue: String
    public let direction: OddsChangeDirection
    public let timestamp: Date

    public init(outcomeId: String,
                oldValue: String,
                newValue: String,
                direction: OddsChangeDirection,
                timestamp: Date = Date()) {
        self.outcomeId = outcomeId
        self.oldValue = oldValue
        self.newValue = newValue
        self.direction = direction
        self.timestamp = timestamp
    }
}

// MARK: - View Model Protocol
public protocol OutcomeItemViewModelProtocol {
    // Publishers
    var oddsChangeEventPublisher: AnyPublisher<OutcomeItemOddsChangeEvent, Never> { get }
    var outcomeDataSubject: CurrentValueSubject<OutcomeItemData, Never> { get }

    // Individual publishers for granular updates (backward compatibility)
    var titlePublisher: AnyPublisher<String, Never> { get }
    var valuePublisher: AnyPublisher<String, Never> { get }
    var isSelectedPublisher: AnyPublisher<Bool, Never> { get }
    var isDisabledPublisher: AnyPublisher<Bool, Never> { get }
    
    // New unified state publisher
    var displayStatePublisher: AnyPublisher<OutcomeDisplayState, Never> { get }

    // Actions
    func toggleSelection() -> Bool
    func updateValue(_ newValue: String)
    func updateValue(_ newValue: String, changeDirection: OddsChangeDirection)
    func setSelected(_ selected: Bool)
    func setDisabled(_ disabled: Bool)
    func clearOddsChangeIndicator()
    
    // Unified state action
    func setDisplayState(_ state: OutcomeDisplayState)
} 
