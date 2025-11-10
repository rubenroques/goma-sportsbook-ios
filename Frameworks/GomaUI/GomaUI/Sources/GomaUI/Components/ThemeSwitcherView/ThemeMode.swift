
import Foundation

/// Theme mode enumeration
public enum ThemeMode: String, CaseIterable {
    case light = "light"
    case system = "system"
    case dark = "dark"

    /// Localized display name for the theme mode
    public var displayName: String {
        switch self {
        case .light:
            return LocalizationProvider.string("theme_short_light")
        case .system:
            return LocalizationProvider.string("theme_short_system")
        case .dark:
            return LocalizationProvider.string("theme_short_dark")
        }
    }

    var iconName: String {
        switch self {
        case .light: return "sun.max.fill"
        case .system: return "lightbulb.fill"
        case .dark: return "moon.fill"
        }
    }
}
