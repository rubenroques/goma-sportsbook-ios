import Foundation
import Combine

/// State enum for bet ticket status
public enum BetTicketStatus: Equatable {
    case won
    case lost
    case draw
}

/// Data model for bet ticket status information
public struct BetTicketStatusData: Equatable {
    public let status: BetTicketStatus
    public let isVisible: Bool
    
    public init(
        status: BetTicketStatus,
        isVisible: Bool = true
    ) {
        self.status = status
        self.isVisible = isVisible
    }
}

/// Protocol defining the interface for BetTicketStatusView ViewModels
public protocol BetTicketStatusViewModelProtocol {
    /// Publisher for the bet ticket status data
    var dataPublisher: AnyPublisher<BetTicketStatusData, Never> { get }
    
    /// Set visibility state
    func setVisible(_ isVisible: Bool)
}
