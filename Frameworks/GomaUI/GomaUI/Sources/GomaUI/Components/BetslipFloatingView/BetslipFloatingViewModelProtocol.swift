import Foundation
import UIKit
import Combine

// MARK: - Data Models

/// Represents the state of the betslip floating view
public enum BetslipFloatingState: Equatable {
    case noTickets
    case withTickets(selectionCount: Int, odds: String, winBoostPercentage: String?, totalEligibleCount: Int, nextTierPercentage: String?)
}

/// Data model for the betslip floating view
public struct BetslipFloatingData: Equatable {
    public let state: BetslipFloatingState
    public let isEnabled: Bool
    
    public init(state: BetslipFloatingState, isEnabled: Bool = true) {
        self.state = state
        self.isEnabled = isEnabled
    }
}

// MARK: - View Model Protocol

/// Protocol defining the interface for BetslipFloatingView ViewModels
public protocol BetslipFloatingViewModelProtocol {
    /// Publisher for the betslip floating data
    var dataPublisher: AnyPublisher<BetslipFloatingData, Never> { get }
    
    /// Current data (for immediate access)
    var currentData: BetslipFloatingData { get }
    
    /// Update the betslip state
    func updateState(_ state: BetslipFloatingState)
    
    /// Set the enabled state
    func setEnabled(_ isEnabled: Bool)
    
    /// Callback closure for tap on the betslip button
    var onBetslipTapped: (() -> Void)? { get set }
}
