import Foundation
import Combine
import UIKit

/// Data model for the bet info submission view
public struct BetInfoSubmissionData: Equatable {
    public let potentialWinnings: String
    public let winBonus: String
    public let payout: String
    public let amount: String
    public let placeBetAmount: String
    public let isEnabled: Bool
    
    public init(potentialWinnings: String = "XAF 0.00", 
                winBonus: String = "-XAF 0.00", 
                payout: String = "XAF 0.00", 
                amount: String = "", 
                placeBetAmount: String = "XAF 0", 
                isEnabled: Bool = false) {
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
    
    /// Handle place bet button tap
    func onPlaceBetTapped()
    
    /// Handle amount text field change
    func onAmountChanged(_ amount: String)
} 