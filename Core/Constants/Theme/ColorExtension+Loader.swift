// GENERATED FILE - DO NOT EDIT MANUALLY
// Generated from Figma design tokens
// To update this file, modify the Python generation script and re-run it

import UIKit
import Combine

extension UIColor {

    // Colors now provided dynamically from ThemeService
    struct App {
        
        // MARK: - Helper method for creating dynamic colors
        static func dynamicColor(
            lightKeyPath: KeyPath<ThemeColors, String>,
            darkKeyPath: KeyPath<ThemeColors, String>
        ) -> UIColor {
            return UIColor { (traitCollection) -> UIColor in
                let theme = ThemeService.shared.currentTheme
                let isDarkMode = traitCollection.userInterfaceStyle == .dark
                
                // Get the appropriate colors based on mode
                let colors = isDarkMode ? theme.darkColors : theme.lightColors
                
                // Get the hex string using keypath
                let hexString = colors[keyPath: isDarkMode ? darkKeyPath : lightKeyPath]
                
                // Convert hex to UIColor
                return UIColor(hexaString: hexString)
            }
        }
    }
}
