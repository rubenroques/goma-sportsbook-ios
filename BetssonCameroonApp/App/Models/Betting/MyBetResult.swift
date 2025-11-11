
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
            return localized("won")
        case .lost:
            return localized("lost")
        case .drawn:
            return localized("draw")
        case .open:
            return localized("open")
        case .void:
            return localized("void")
        case .pending:
            return localized("pending")
        case .notSpecified:
            return localized("bet_result_not_specified")
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
