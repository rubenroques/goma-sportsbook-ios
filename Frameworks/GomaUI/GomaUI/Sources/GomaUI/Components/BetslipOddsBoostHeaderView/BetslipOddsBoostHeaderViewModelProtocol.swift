import Foundation
import UIKit
import Combine

// MARK: - Data Models

/// Represents the odds boost header state data
/// Note: Component is only shown when odds boost is available - ViewController manages visibility
public struct BetslipOddsBoostHeaderState: Equatable {
    public let selectionCount: Int           // Current selections in betslip
    public let totalEligibleCount: Int       // Selections needed for boost
    public let nextTierPercentage: String?   // Next boost tier (e.g., "5%")
    public let currentBoostPercentage: String? // Current boost if max reached

    public init(
        selectionCount: Int,
        totalEligibleCount: Int,
        nextTierPercentage: String?,
        currentBoostPercentage: String?
    ) {
        self.selectionCount = selectionCount
        self.totalEligibleCount = totalEligibleCount
        self.nextTierPercentage = nextTierPercentage
        self.currentBoostPercentage = currentBoostPercentage
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
