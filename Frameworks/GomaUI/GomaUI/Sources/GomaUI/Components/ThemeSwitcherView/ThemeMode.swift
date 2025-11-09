
import Foundation

/// Theme mode enumeration
public enum ThemeMode: String, CaseIterable {
    case light = "Light"
    case system = "System"
    case dark = "Dark"
    
    var iconName: String {
        switch self {
        case .light: return "sun.max.fill"
        case .system: return "lightbulb.fill"
        case .dark: return "moon.fill"
        }
    }
}
