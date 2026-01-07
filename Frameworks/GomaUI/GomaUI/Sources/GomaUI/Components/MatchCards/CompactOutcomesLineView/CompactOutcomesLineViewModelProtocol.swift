import UIKit
import Combine

// MARK: - Display Mode

/// Display mode for compact outcomes line
public enum CompactOutcomesDisplayMode: Equatable, Hashable {
    /// Two outcomes (e.g., Over/Under, Tennis 1/2)
    case double

    /// Three outcomes (e.g., Football 1/X/2)
    case triple
}

// MARK: - Display State

/// Display state for CompactOutcomesLineView
public struct CompactOutcomesLineDisplayState: Equatable, Hashable {
    public let displayMode: CompactOutcomesDisplayMode
    public let leftOutcome: OutcomeItemData?
    public let middleOutcome: OutcomeItemData?
    public let rightOutcome: OutcomeItemData?

    public init(
        displayMode: CompactOutcomesDisplayMode,
        leftOutcome: OutcomeItemData?,
        middleOutcome: OutcomeItemData? = nil,
        rightOutcome: OutcomeItemData?
    ) {
        self.displayMode = displayMode
        self.leftOutcome = leftOutcome
        self.middleOutcome = displayMode == .triple ? middleOutcome : nil
        self.rightOutcome = rightOutcome
    }

    /// Convenience initializer for 2-way markets
    public static func twoWay(
        left: OutcomeItemData,
        right: OutcomeItemData
    ) -> CompactOutcomesLineDisplayState {
        CompactOutcomesLineDisplayState(
            displayMode: .double,
            leftOutcome: left,
            rightOutcome: right
        )
    }

    /// Convenience initializer for 3-way markets
    public static func threeWay(
        left: OutcomeItemData,
        middle: OutcomeItemData,
        right: OutcomeItemData
    ) -> CompactOutcomesLineDisplayState {
        CompactOutcomesLineDisplayState(
            displayMode: .triple,
            leftOutcome: left,
            middleOutcome: middle,
            rightOutcome: right
        )
    }
}

// MARK: - Selection Event

/// Event emitted when a child OutcomeItemViewModel's selection changes via user tap.
public struct CompactOutcomeSelectionEvent: Equatable {
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

// MARK: - Protocol

/// Protocol defining the interface for CompactOutcomesLineView ViewModels
public protocol CompactOutcomesLineViewModelProtocol: AnyObject {
    /// Publisher for the display state
    var displayStatePublisher: AnyPublisher<CompactOutcomesLineDisplayState, Never> { get }

    /// Current display state (for synchronous access)
    var currentDisplayState: CompactOutcomesLineDisplayState { get }

    /// Child view model publishers for individual outcomes
    var leftOutcomeViewModelPublisher: AnyPublisher<OutcomeItemViewModelProtocol?, Never> { get }
    var middleOutcomeViewModelPublisher: AnyPublisher<OutcomeItemViewModelProtocol?, Never> { get }
    var rightOutcomeViewModelPublisher: AnyPublisher<OutcomeItemViewModelProtocol?, Never> { get }

    /// Current child view models (for synchronous access)
    var currentLeftOutcomeViewModel: OutcomeItemViewModelProtocol? { get }
    var currentMiddleOutcomeViewModel: OutcomeItemViewModelProtocol? { get }
    var currentRightOutcomeViewModel: OutcomeItemViewModelProtocol? { get }

    /// Publisher for selection changes from child OutcomeItemViewModels.
    /// View observes this to notify external callbacks (proper MVVM pattern).
    var outcomeSelectionDidChangePublisher: AnyPublisher<CompactOutcomeSelectionEvent, Never> { get }

    /// Handle outcome selection (called by ViewModel internally, not View)
    func onOutcomeSelected(outcomeId: String, outcomeType: OutcomeType)

    /// Handle outcome deselection (called by ViewModel internally, not View)
    func onOutcomeDeselected(outcomeId: String, outcomeType: OutcomeType)

    /// Set outcome selected state programmatically
    func setOutcomeSelected(outcomeType: OutcomeType)

    /// Set outcome deselected state programmatically
    func setOutcomeDeselected(outcomeType: OutcomeType)
}
