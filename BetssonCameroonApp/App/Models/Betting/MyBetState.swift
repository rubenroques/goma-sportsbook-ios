
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
            return localized("open")
        case .closed:
            return localized("bet_state_closed")
        case .settled:
            return localized("settled")
        case .cancelled:
            return localized("cancelled")
        case .attempted:
            return localized("bet_state_attempted")
        case .won:
            return localized("won")
        case .lost:
            return localized("lost")
        case .cashedOut:
            return localized("bet_state_cashed_out")
        case .void:
            return localized("void")
        case .undefined:
            return localized("bet_state_undefined")
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
