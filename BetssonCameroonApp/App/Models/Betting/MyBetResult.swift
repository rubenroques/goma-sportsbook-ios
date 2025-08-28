
import Foundation

enum MyBetResult: String, Codable, Equatable, Hashable, CaseIterable {
    case won
    case lost
    case drawn
    case open
    case void
    case pending
    case notSpecified
    
    // MARK: - Display Properties
    
    var displayName: String {
        switch self {
        case .won:
            return "Won"
        case .lost:
            return "Lost"
        case .drawn:
            return "Draw"
        case .open:
            return "Open"
        case .void:
            return "Void"
        case .pending:
            return "Pending"
        case .notSpecified:
            return "Not Specified"
        }
    }
    
    var isPositive: Bool {
        return self == .won
    }
    
    var isNegative: Bool {
        return self == .lost
    }
    
    var isPending: Bool {
        switch self {
        case .open, .pending:
            return true
        case .won, .lost, .drawn, .void, .notSpecified:
            return false
        }
    }
}
