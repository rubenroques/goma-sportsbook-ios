import UIKit

// MARK: - Component Category
enum ComponentCategory: String, CaseIterable {
    case bettingSports = "Betting & Sports"
    case casino = "Casino"
    case matchDisplay = "Match & Sports"
    case filters = "Filters & Selection"
    case navigation = "Navigation & Layout"
    case forms = "Forms & Input"
    case wallet = "Wallet & Financial"
    case promotional = "Promotional"
    case profile = "Profile & Settings"
    case status = "Status & Notifications"
    case uiElements = "UI Elements"
    
    var icon: String {
        switch self {
        case .bettingSports:
            return "sportscourt.fill"
        case .casino:
            return "suit.diamond.fill"
        case .matchDisplay:
            return "tv.fill"
        case .filters:
            return "line.3.horizontal.decrease.circle"
        case .navigation:
            return "sidebar.left"
        case .forms:
            return "rectangle.and.pencil.and.ellipsis"
        case .wallet:
            return "creditcard.fill"
        case .promotional:
            return "megaphone.fill"
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
        case .bettingSports:
            return UIColor.systemBlue
        case .casino:
            return UIColor.systemPurple
        case .matchDisplay:
            return UIColor.systemGreen
        case .filters:
            return UIColor.systemOrange
        case .navigation:
            return UIColor.systemTeal
        case .forms:
            return UIColor.systemIndigo
        case .wallet:
            return UIColor.systemYellow
        case .promotional:
            return UIColor.systemRed
        case .profile:
            return UIColor.systemPink
        case .status:
            return UIColor.systemMint
        case .uiElements:
            return UIColor.systemGray
        }
    }
}