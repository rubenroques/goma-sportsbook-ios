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
    
    // MARK: - Child View Models
    var headerViewModel: BetslipHeaderViewModelProtocol { get }
    var betslipTypeSelectorViewModel: BetslipTypeSelectorViewModelProtocol { get }
    var sportsBetslipViewModel: SportsBetslipViewModelProtocol { get }
    var virtualBetslipViewModel: VirtualBetslipViewModelProtocol { get }
    
    /// Set the enabled state
    func setEnabled(_ isEnabled: Bool)
    
    /// Callback closures for coordinator communication
    var onHeaderCloseTapped: (() -> Void)? { get set }
    var onHeaderJoinNowTapped: (() -> Void)? { get set }
    var onHeaderLogInTapped: (() -> Void)? { get set }
    var onEmptyStateActionTapped: (() -> Void)? { get set }
    var onPlaceBetTapped: ((BetPlacedState) -> Void)? { get set }
} 
