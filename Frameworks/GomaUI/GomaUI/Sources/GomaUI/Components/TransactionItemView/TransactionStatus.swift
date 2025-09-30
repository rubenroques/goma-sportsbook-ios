import Foundation
import UIKit

public enum TransactionStatus: Hashable {
    case won
    case placed
    case tax
    case pending
    case cancelled
    
    public var displayName: String {
        switch self {
        case .won:
            return "Won"
        case .placed:
            return "Placed"
        case .tax:
            return "Tax"
        case .pending:
            return "Pending"
        case .cancelled:
            return "Cancelled"
        }
    }

    public var backgroundColor: UIColor {
        switch self {
        case .won:
            return StyleProvider.Color.alertSuccess.withAlphaComponent(0.2)
        case .placed:
            return StyleProvider.Color.highlightTertiary.withAlphaComponent(0.2)
        case .tax, .pending, .cancelled:
            return StyleProvider.Color.backgroundPrimary
        }
    }

    public var textColor: UIColor {
        switch self {
        case .won:
            return StyleProvider.Color.alertSuccess
        case .placed:
            return StyleProvider.Color.highlightTertiary
        case .tax, .pending, .cancelled:
            return StyleProvider.Color.textPrimary
        }
    }
}
