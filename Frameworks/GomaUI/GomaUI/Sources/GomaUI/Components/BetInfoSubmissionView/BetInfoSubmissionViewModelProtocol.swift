import Foundation
import UIKit
import Combine

/// Data model for the bet info submission view
public struct BetInfoSubmissionData: Equatable {
    public let potentialWinnings: String
    public let winBonus: String
    public let payout: String
    public let amount: String
    public let placeBetAmount: String
    public let isEnabled: Bool
    
    public init(
        potentialWinnings: String = "XAF 0",
        winBonus: String = "XAF 0",
        payout: String = "XAF 0",
        amount: String = "",
        placeBetAmount: String = "Place Bet XAF 0",
        isEnabled: Bool = true
    ) {
        self.potentialWinnings = potentialWinnings
        self.winBonus = winBonus
        self.payout = payout
        self.amount = amount
        self.placeBetAmount = placeBetAmount
        self.isEnabled = isEnabled
    }
}

/// Protocol defining the interface for BetInfoSubmissionView ViewModels
public protocol BetInfoSubmissionViewModelProtocol {
    /// Publisher for the bet info submission data
    var dataPublisher: AnyPublisher<BetInfoSubmissionData, Never> { get }
    
    /// Current data (for immediate access)
    var currentData: BetInfoSubmissionData { get }
    
    /// Child view models
    var potentialWinningsRowViewModel: BetSummaryRowViewModelProtocol { get }
    var winBonusRowViewModel: BetSummaryRowViewModelProtocol { get }
    var payoutRowViewModel: BetSummaryRowViewModelProtocol { get }
    var amount100ButtonViewModel: QuickAddButtonViewModelProtocol { get }
    var amount250ButtonViewModel: QuickAddButtonViewModelProtocol { get }
    var amount500ButtonViewModel: QuickAddButtonViewModelProtocol { get }
    var amountTextFieldViewModel: BorderedTextFieldViewModelProtocol { get }
    var placeBetButtonViewModel: ButtonViewModelProtocol { get }
    
    /// Update potential winnings
    func updatePotentialWinnings(_ amount: String)
    
    /// Update win bonus
    func updateWinBonus(_ amount: String)
    
    /// Update payout
    func updatePayout(_ amount: String)
    
    /// Update amount
    func updateAmount(_ amount: String)
    
    /// Update place bet amount
    func updatePlaceBetAmount(_ amount: String)
    
    /// Set the enabled state
    func setEnabled(_ isEnabled: Bool)
    
    /// Handle quick add button tap
    func onQuickAddTapped(_ amount: Int)
    
    /// Callback closure for place bet button tap
    var onPlaceBetTapped: (() -> Void)? { get set }
    
    /// Handle amount text field change
    func onAmountChanged(_ amount: String)
    
    /// Callbacks
    var amountChanged: (() -> Void)? { get set }
}
