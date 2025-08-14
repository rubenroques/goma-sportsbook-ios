import Foundation
import Combine
import GomaUI

/// Data model for the betslip view
public struct BetslipData: Equatable {
    public let isEnabled: Bool
    public let tickets: [BettingTicket]
    
    public init(
        isEnabled: Bool = true,
        tickets: [BettingTicket] = []
    ) {
        self.isEnabled = isEnabled
        self.tickets = tickets
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
    var emptyStateViewModel: EmptyStateActionViewModelProtocol { get }
    var betInfoSubmissionViewModel: BetInfoSubmissionViewModelProtocol { get }
    var bookingCodeButtonViewModel: ButtonIconViewModelProtocol { get set }
    var clearBetslipButtonViewModel: ButtonIconViewModelProtocol { get set }
    
    /// Set the enabled state
    func setEnabled(_ isEnabled: Bool)
    
    /// Update tickets with actual ticket data
    func updateTickets(_ tickets: [BettingTicket])
    
    /// Remove a specific ticket
    func removeTicket(_ ticket: BettingTicket)
    
    /// Clear all tickets from the betslip
    func clearAllTickets()
    
    /// Callback closures for coordinator communication
    var onHeaderCloseTapped: (() -> Void)? { get set }
    var onHeaderJoinNowTapped: (() -> Void)? { get set }
    var onHeaderLogInTapped: (() -> Void)? { get set }
    var onEmptyStateActionTapped: (() -> Void)? { get set }
    var onPlaceBetTapped: (() -> Void)? { get set }
} 
