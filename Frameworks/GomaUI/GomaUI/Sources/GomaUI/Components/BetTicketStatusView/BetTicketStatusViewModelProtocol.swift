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
    
    public init(status: BetTicketStatus) {
        self.status = status
    }
}

/// Protocol defining the interface for BetTicketStatusView ViewModels
public protocol BetTicketStatusViewModelProtocol {
    /// Publisher for the bet ticket status data
    var dataPublisher: AnyPublisher<BetTicketStatusData, Never> { get }

}
