import UIKit

// MARK: - Component Category
enum ComponentCategory: String, CaseIterable {
    case matchCards = "Match Cards"
    case betting = "Betting"
    case casino = "Casino"
    case promotional = "Promotional"
    case wallet = "Wallet & Financial"
    case filters = "Filters & Selection"
    case navigation = "Navigation & Layout"
    case forms = "Forms & Input"
    case profile = "Profile & Settings"
    case status = "Status & Notifications"
    case uiElements = "UI Elements"

    var icon: String {
        switch self {
        case .matchCards:
            return "sportscourt.fill"
        case .betting:
            return "ticket.fill"
        case .casino:
            return "suit.diamond.fill"
        case .promotional:
            return "megaphone.fill"
        case .wallet:
            return "creditcard.fill"
        case .filters:
            return "line.3.horizontal.decrease.circle"
        case .navigation:
            return "sidebar.left"
        case .forms:
            return "rectangle.and.pencil.and.ellipsis"
        case .profile:
            return "person.circle.fill"
        case .status:
            return "bell.fill"
        case .uiElements:
            return "square.stack.3d.up.fill"
        }
    }

    var color: UIColor {
        switch self {
        case .matchCards:
            return UIColor.systemGreen
        case .betting:
            return UIColor.systemBlue
        case .casino:
            return UIColor.systemPurple
        case .promotional:
            return UIColor.systemRed
        case .wallet:
            return UIColor.systemYellow
        case .filters:
            return UIColor.systemOrange
        case .navigation:
            return UIColor.systemTeal
        case .forms:
            return UIColor.systemIndigo
        case .profile:
            return UIColor.systemPink
        case .status:
            return UIColor.systemMint
        case .uiElements:
            return UIColor.systemGray
        }
    }
}