import Foundation
import UIKit

public enum StatusNotificationType {
    case success
    case error
    case warning

    var backgroundColor: UIColor {
        switch self {
        case .success:
            return StyleProvider.Color.alertSuccess
        case .error:
            return StyleProvider.Color.alertError
        case .warning:
            return StyleProvider.Color.alertWarning
        }
    }

    var iconImage: UIImage? {
        switch self {
        case .success:
            return UIImage(named: "checkmark.circle.fill")
        case .error:
            return UIImage(systemName: "xmark.circle.fill")
        case .warning:
            return UIImage(systemName: "exclamationmark.triangle.fill")
        }
    }
}
