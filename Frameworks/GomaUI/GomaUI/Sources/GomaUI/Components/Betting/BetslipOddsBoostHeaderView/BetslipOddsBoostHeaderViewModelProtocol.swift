import Foundation
import UIKit
import Combine

// MARK: - Data Models

/// Represents the odds boost header state data
/// Note: Component is only shown when odds boost is available - ViewController manages visibility
public struct BetslipOddsBoostHeaderState: Equatable {
    public let selectionCount: Int           // Current selections in betslip
    public let totalEligibleCount: Int       // Selections needed for boost
    public let minOdds: String?              // Minimum odds requirement (e.g., "1.1")

    /// Pre-assembled heading text ready to display
    /// ViewModel handles all localization and decision logic
    /// Examples: "Max win boost activated! (40%)", "Get 15% win boost", "Win boost available"
    public let headingText: String

    /// Pre-assembled description text ready to display
    /// ViewModel handles all localization and decision logic
    /// Examples: "by adding 2 more legs to your betslip (1.10 min odds).", "All qualifying events added"
    public let descriptionText: String

    public init(
        selectionCount: Int,
        totalEligibleCount: Int,
        minOdds: String?,
        headingText: String,
        descriptionText: String
    ) {
        self.selectionCount = selectionCount
        self.totalEligibleCount = totalEligibleCount
        self.minOdds = minOdds
        self.headingText = headingText
        self.descriptionText = descriptionText
    }
}

/// Data model for the odds boost header
public struct BetslipOddsBoostHeaderData: Equatable {
    public let state: BetslipOddsBoostHeaderState
    public let isEnabled: Bool

    public init(state: BetslipOddsBoostHeaderState, isEnabled: Bool = true) {
        self.state = state
        self.isEnabled = isEnabled
    }
}

// MARK: - View Model Protocol

/// Protocol defining the interface for BetslipOddsBoostHeaderView ViewModels
public protocol BetslipOddsBoostHeaderViewModelProtocol {
    /// Publisher for the odds boost header data
    var dataPublisher: AnyPublisher<BetslipOddsBoostHeaderData, Never> { get }

    /// Current data (for immediate access)
    var currentData: BetslipOddsBoostHeaderData { get }

    /// Update the header state
    func updateState(_ state: BetslipOddsBoostHeaderState)

    /// Set the enabled state
    func setEnabled(_ isEnabled: Bool)

    /// Callback closure for tap on the header
    var onHeaderTapped: (() -> Void)? { get set }
}
