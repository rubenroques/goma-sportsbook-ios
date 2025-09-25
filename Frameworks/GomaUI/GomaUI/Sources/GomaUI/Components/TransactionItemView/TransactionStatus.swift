import Foundation
import UIKit

public enum TransactionStatus: Hashable {
    case won
    case placed
    case tax

    public var displayName: String {
        switch self {
        case .won:
            return "Won"
        case .placed:
            return "Placed"
        case .tax:
            return "Tax"
        }
    }

    public var backgroundColor: UIColor {
        switch self {
        case .won:
            return StyleProvider.Color.alertSuccess.withAlphaComponent(0.2)
        case .placed:
            return StyleProvider.Color.highlightTertiary.withAlphaComponent(0.2)
        case .tax:
            return StyleProvider.Color.backgroundPrimary
        }
    }

    public var textColor: UIColor {
        switch self {
        case .won:
            return StyleProvider.Color.alertSuccess
        case .placed:
            return StyleProvider.Color.highlightTertiary
        case .tax:
            return StyleProvider.Color.textPrimary
        }
    }
}