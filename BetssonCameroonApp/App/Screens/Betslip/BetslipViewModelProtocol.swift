import Foundation
import Combine
import GomaUI

/// Data model for the betslip view
public struct BetslipData: Equatable {
    public let isEnabled: Bool
    public let hasTickets: Bool
    public let ticketCount: Int
    
    public init(
        isEnabled: Bool = true,
        hasTickets: Bool = false,
        ticketCount: Int = 0
    ) {
        self.isEnabled = isEnabled
        self.hasTickets = hasTickets
        self.ticketCount = ticketCount
    }
}

/// Protocol defining the interface for BetslipViewController ViewModels
public protocol BetslipViewModelProtocol {
    /// Publisher for the betslip data
    var dataPublisher: AnyPublisher<BetslipData, Never> { get }
    
    /// Current data (for immediate access)
    var currentData: BetslipData { get }
    
    /// Child view models
    var headerViewModel: BetslipHeaderViewModelProtocol { get }
    var betInfoSubmissionViewModel: BetInfoSubmissionViewModelProtocol { get }
    
    /// Set the enabled state
    func setEnabled(_ isEnabled: Bool)
    
    /// Update ticket information
    func updateTickets(hasTickets: Bool, count: Int)
    
    /// Handle header close action
    func onHeaderCloseTapped()
    
    /// Handle header join now action
    func onHeaderJoinNowTapped()
    
    /// Handle header log in action
    func onHeaderLogInTapped()
    
    /// Handle place bet action
    func onPlaceBetTapped()
} 