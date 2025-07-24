// GENERATED FILE - DO NOT EDIT MANUALLY
// Generated from Figma design tokens
// To update this file, modify the Python generation script and re-run it

import UIKit
import Combine

struct Theme: Codable {
    let id: String
    let name: String
    let lightColors: ThemeColors
    let darkColors: ThemeColors
    
    static let defaultTheme = Theme(
        id: "default",
        name: "Default Theme",
        lightColors: ThemeColors.defaultLight,
        darkColors: ThemeColors.defaultDark
    )
}

// Extension for notification name
extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}
