import Combine
import UIKit

// MARK: - Data Models
public struct OutcomeItemData: Equatable, Hashable {
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
    public func withUpdatedOdds(_ newValue: String) -> OutcomeItemData {
        let direction = calculateOddsChangeDirection(from: self.value, to: newValue)
        return OutcomeItemData(
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
    public func withClearedOddsChange() -> OutcomeItemData {
        return OutcomeItemData(
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
    var displayStatePublisher: AnyPublisher<OutcomeItemDisplayState, Never> { get }
    var oddsChangeEventPublisher: AnyPublisher<OutcomeItemOddsChangeEvent, Never> { get }

    // Individual publishers for granular updates
    var titlePublisher: AnyPublisher<String, Never> { get }
    var valuePublisher: AnyPublisher<String, Never> { get }
    var isSelectedPublisher: AnyPublisher<Bool, Never> { get }
    var isDisabledPublisher: AnyPublisher<Bool, Never> { get }

    // Actions
    func toggleSelection() -> Bool
    func updateValue(_ newValue: String)
    func updateValue(_ newValue: String, changeDirection: OddsChangeDirection)
    func setSelected(_ selected: Bool)
    func setDisabled(_ disabled: Bool)
    func clearOddsChangeIndicator()
} 
