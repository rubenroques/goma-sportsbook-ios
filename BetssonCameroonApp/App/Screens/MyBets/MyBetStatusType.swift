
import Foundation

enum MyBetStatusType: String, CaseIterable {
    case open = "open"
    case cashOut = "cash_out"
    case won = "won"
    case settled = "settled"
    
    var title: String {
        switch self {
        case .open:
            return localized("open")
        case .cashOut:
            return localized("mybets_status_cashout")
        case .won:
            return localized("won")
        case .settled:
            return localized("mybets_status_settled")
        }
    }
    
    var pillId: String {
        return rawValue
    }
}
