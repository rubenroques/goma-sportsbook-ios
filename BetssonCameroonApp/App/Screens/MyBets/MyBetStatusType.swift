
import Foundation

enum MyBetStatusType: String, CaseIterable {
    case open = "open"
    case cashOut = "cash_out"
    case won = "won"
    case settled = "settled"
    
    var title: String {
        switch self {
        case .open:
            return "Open"
        case .cashOut:
            return "Cash Out"
        case .won:
            return "Won"
        case .settled:
            return "Settled"
        }
    }
    
    var pillId: String {
        return rawValue
    }
}
