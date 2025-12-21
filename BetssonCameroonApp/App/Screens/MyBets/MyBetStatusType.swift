
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

    /// Returns title with count suffix for applicable status types
    /// - Parameter count: The count to display. If nil or 0, returns plain title
    /// - Returns: Formatted title, e.g., "Open (5)" for .open with count 5
    func title(withCount count: Int?) -> String {
        switch self {
        case .open:
            if let count = count, count > 0 {
                return "\(localized("open")) (\(count))"
            }
            return localized("open")
        case .cashOut, .won, .settled:
            return title
        }
    }
}
