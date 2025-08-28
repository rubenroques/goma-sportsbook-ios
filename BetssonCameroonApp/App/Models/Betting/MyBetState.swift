
import Foundation

enum MyBetState: String, Codable, Equatable, Hashable, CaseIterable {
    case opened
    case closed
    case settled
    case cancelled
    case attempted
    case won
    case lost
    case cashedOut
    case void
    case undefined
    
    // MARK: - Display Properties
    
    var displayName: String {
        switch self {
        case .opened:
            return "Open"
        case .closed:
            return "Closed"
        case .settled:
            return "Settled"
        case .cancelled:
            return "Cancelled"
        case .attempted:
            return "Attempted"
        case .won:
            return "Won"
        case .lost:
            return "Lost"
        case .cashedOut:
            return "Cashed Out"
        case .void:
            return "Void"
        case .undefined:
            return "Undefined"
        }
    }
    
    var isActive: Bool {
        return self == .opened
    }
    
    var isFinished: Bool {
        switch self {
        case .won, .lost, .settled, .cancelled, .cashedOut, .void:
            return true
        case .opened, .closed, .attempted, .undefined:
            return false
        }
    }
}
