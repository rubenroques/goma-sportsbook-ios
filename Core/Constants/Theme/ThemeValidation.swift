// NOT GENERATED - This file is maintained manually
// ThemeValidation contains validation logic for theme colors

import UIKit

// MARK: - Theme Validation
extension Theme {
    // Validation functions for theme colors
    static func validateThemeColors() -> [String] {
        var issues: [String] = []
        
        // Get mirror of the ThemeColors properties
        let mirror = Mirror(reflecting: ThemeColors.defaultLight)
        
        // Validate each color in light theme
        for child in mirror.children {
            guard let propertyName = child.label, let hexValue = child.value as? String else { continue }
            
            // Check if hex value is valid
            if !isValidHexColor(hexValue) {
                issues.append("Invalid light theme hex color for \(propertyName): \(hexValue)")
            }
        }
        
        // Validate each color in dark theme
        let darkMirror = Mirror(reflecting: ThemeColors.defaultDark)
        for child in darkMirror.children {
            guard let propertyName = child.label, let hexValue = child.value as? String else { continue }
            
            // Check if hex value is valid
            if !isValidHexColor(hexValue) {
                issues.append("Invalid dark theme hex color for \(propertyName): \(hexValue)")
            }
        }
        
        return issues
    }
    
    // Helper to validate hex color format
    private static func isValidHexColor(_ hex: String) -> Bool {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        // Check if hex is valid format (6 or 8 characters for RGB/RGBA)
        if hexSanitized.count != 6 && hexSanitized.count != 8 {
            return false
        }
        
        // Check if all characters are valid hex digits
        let validHexChars = CharacterSet(charactersIn: "0123456789ABCDEFabcdef")
        let hexCharacterSet = CharacterSet(charactersIn: hexSanitized)
        return validHexChars.isSuperset(of: hexCharacterSet)
    }
}

// MARK: - UIColor App Validation
extension UIColor.App {
    // Validation function to ensure all colors are properly defined
    static func validateAppColors() -> [String] {
        var issues: [String] = []
        
        // First check that the Theme default colors are valid hex values
        let themeIssues = Theme.validateThemeColors()
        issues.append(contentsOf: themeIssues)
        
        // Now check that every UIColor.App property has a corresponding ThemeColors property
        // List of all expected color names
        let expectedColorNames: [String] = [
            "backgroundPrimary", "backgroundSecondary", "backgroundTertiary", "backgroundBorder", 
            "backgroundCards", "backgroundHeader", "backgroundOdds", "backgroundDisabledOdds",
            "backgroundDrop", "backgroundDarker", "backgroundGradient1", "backgroundGradient2",
            "backgroundHeaderGradient1", "backgroundHeaderGradient2", "textPrimary", "textHeadlinePrimary",
            "textDisablePrimary", "textSecondary", "textHeroCard", "textSecondaryHeroCard",
            "inputBackground", "inputBorderActive", "inputBorderDisabled", "inputBackgroundSecondary",
            "inputTextTitle", "inputText", "inputError", "inputTextDisable", "iconPrimary",
            "iconSecondary", "iconSportsHeroCard", "pillBackground", "pillNavigation", "pillSettings",
            "buttonTextPrimary", "buttonBackgroundPrimary", "buttonActiveHoverPrimary", "buttonDisablePrimary",
            "buttonTextDisablePrimary", "buttonTextSecondary", "buttonTextTertiary", "buttonTextDisableTertiary",
            "buttonBackgroundSecondary", "buttonActiveHoverSecondary", "buttonBackgroundTertiary",
            "buttonActiveHoverTertiary", "buttonBorderTertiary", "buttonBorderDisableTertiary",
            "highlightPrimary", "highlightSecondary", "highlightPrimaryContrast", "highlightSecondaryContrast",
            "highlightTertiary", "alertError", "alertSuccess", "alertWarning", "separatorLine",
            "separatorLineHighlightPrimary", "separatorLineHighlightSecondary", "separatorLineSecondary",
            "myTicketsLost", "myTicketsLostFaded", "myTicketsWon", "myTicketsWonFaded", "myTicketsOther",
            "statsHome", "statsAway", "scroll", "borderDrop", "bubblesPrimary", "headerGradient1",
            "headerGradient2", "headerGradient3", "cardBorderLineGradient1", "cardBorderLineGradient2",
            "cardBorderLineGradient3", "liveBorderGradient1", "liveBorderGradient2", "liveBorderGradient3",
            "messageGradient1", "messageGradient2", "navBanner", "navBannerActive", "gameHeader", 
            "backgroundOddsHeroCard"
        ]
        
        // Verify each color exists in ThemeColors
        let mirror = Mirror(reflecting: ThemeColors.defaultLight)
        let themeColorProperties = mirror.children.compactMap { $0.label }
        
        for colorName in expectedColorNames {
            if !themeColorProperties.contains(colorName) {
                issues.append("Color '\(colorName)' is used in UIColor.App but not defined in ThemeColors struct")
            }
        }
        
        // Check for unused colors in ThemeColors
        for colorProperty in themeColorProperties {
            if !expectedColorNames.contains(colorProperty) {
                issues.append("Color '\(colorProperty)' is defined in ThemeColors but not used in UIColor.App")
            }
        }
        
        // Make sure all UIColor.App colors resolve properly
        do {
            // Try to access all dynamically computed colors - any errors would indicate problems
            _ = backgroundPrimary
            _ = backgroundSecondary
            _ = backgroundTertiary
            _ = backgroundBorder
            _ = backgroundCards
            _ = backgroundHeader
            _ = backgroundOdds
            _ = backgroundDisabledOdds
            _ = textPrimary
            _ = textHeadlinePrimary
            _ = textDisablePrimary
            _ = textSecondary
            _ = separatorLine
            _ = scroll
            _ = pillBackground
            _ = pillNavigation
            _ = pillSettings
            _ = inputBackground
            _ = inputBorderActive
            _ = inputBorderDisabled
            _ = inputBackgroundSecondary
            _ = inputTextTitle
            _ = inputText
            _ = inputError
            _ = inputTextDisable
            _ = iconPrimary
            _ = iconSecondary
            _ = backgroundDrop
            _ = borderDrop
            _ = highlightPrimary
            _ = highlightSecondary
            _ = buttonTextPrimary
            _ = buttonBackgroundPrimary
            _ = buttonActiveHoverPrimary
            _ = buttonDisablePrimary
            _ = buttonTextDisablePrimary
            _ = buttonTextSecondary
            _ = buttonTextTertiary
            _ = buttonTextDisableTertiary
            _ = buttonBackgroundSecondary
            _ = buttonActiveHoverSecondary
            _ = buttonBackgroundTertiary
            _ = buttonActiveHoverTertiary
            _ = buttonBorderTertiary
            _ = buttonBorderDisableTertiary
            _ = bubblesPrimary
            _ = alertError
            _ = alertSuccess
            _ = alertWarning
            _ = myTicketsLost
            _ = myTicketsLostFaded
            _ = myTicketsWon
            _ = myTicketsWonFaded
            _ = myTicketsOther
            _ = backgroundDarker
            _ = statsHome
            _ = statsAway
            _ = highlightPrimaryContrast
            _ = highlightSecondaryContrast
            _ = backgroundGradient1
            _ = backgroundGradient2
            _ = headerGradient1
            _ = headerGradient2
            _ = headerGradient3
            _ = cardBorderLineGradient1
            _ = cardBorderLineGradient2
            _ = cardBorderLineGradient3
            _ = gameHeader
            _ = separatorLineHighlightPrimary
            _ = separatorLineHighlightSecondary
            _ = separatorLineSecondary
            _ = navBanner
            _ = navBannerActive
            _ = backgroundHeaderGradient1
            _ = backgroundHeaderGradient2
            _ = highlightTertiary
            _ = liveBorderGradient1
            _ = liveBorderGradient2
            _ = liveBorderGradient3
            _ = textHeroCard
            _ = textSecondaryHeroCard
            _ = backgroundOddsHeroCard
            _ = iconSportsHeroCard
            _ = messageGradient1
            _ = messageGradient2
        } catch {
            issues.append("Error accessing colors: \(error)")
        }
        
        return issues
    }
} 