// GENERATED FILE - DO NOT EDIT MANUALLY
// Generated from Figma design tokens
// To update this file, modify the Python generation script and re-run it

import UIKit
import Combine

extension UIColor {

    // Colors now provided dynamically from ThemeService
    struct App {
        
        // MARK: - Helper method for creating dynamic colors
        private static func dynamicColor(
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
        
        // MARK: - Background Colors
        static var backgroundPrimary: UIColor {
            return dynamicColor(lightKeyPath: \.backgroundPrimary, darkKeyPath: \.backgroundPrimary)
        }
        
        static var backgroundSecondary: UIColor {
            return dynamicColor(lightKeyPath: \.backgroundSecondary, darkKeyPath: \.backgroundSecondary)
        }
        
        static var backgroundTertiary: UIColor {
            return dynamicColor(lightKeyPath: \.backgroundTertiary, darkKeyPath: \.backgroundTertiary)
        }
        
        static var backgroundBorder: UIColor {
            return dynamicColor(lightKeyPath: \.backgroundBorder, darkKeyPath: \.backgroundBorder)
        }
        
        static var backgroundCards: UIColor {
            return dynamicColor(lightKeyPath: \.backgroundCards, darkKeyPath: \.backgroundCards)
        }
        
        static var backgroundHeader: UIColor {
            return dynamicColor(lightKeyPath: \.backgroundHeader, darkKeyPath: \.backgroundHeader)
        }
        
        static var backgroundOdds: UIColor {
            return dynamicColor(lightKeyPath: \.backgroundOdds, darkKeyPath: \.backgroundOdds)
        }
        
        static var backgroundDisabledOdds: UIColor {
            return dynamicColor(lightKeyPath: \.backgroundDisabledOdds, darkKeyPath: \.backgroundDisabledOdds)
        }
        
        static var backgroundDrop: UIColor {
            return dynamicColor(lightKeyPath: \.backgroundDrop, darkKeyPath: \.backgroundDrop)
        }
        
        static var backgroundDarker: UIColor {
            return dynamicColor(lightKeyPath: \.backgroundDarker, darkKeyPath: \.backgroundDarker)
        }
        
        static var backgroundGradient1: UIColor {
            return dynamicColor(lightKeyPath: \.backgroundGradient1, darkKeyPath: \.backgroundGradient1)
        }
        
        static var backgroundGradient2: UIColor {
            return dynamicColor(lightKeyPath: \.backgroundGradient2, darkKeyPath: \.backgroundGradient2)
        }
        
        static var backgroundHeaderGradient1: UIColor {
            return dynamicColor(lightKeyPath: \.backgroundHeaderGradient1, darkKeyPath: \.backgroundHeaderGradient1)
        }
        
        static var backgroundHeaderGradient2: UIColor {
            return dynamicColor(lightKeyPath: \.backgroundHeaderGradient2, darkKeyPath: \.backgroundHeaderGradient2)
        }
        
        // MARK: - Text Colors
        static var textPrimary: UIColor {
            return dynamicColor(lightKeyPath: \.textPrimary, darkKeyPath: \.textPrimary)
        }
        
        static var textHeadlinePrimary: UIColor {
            return dynamicColor(lightKeyPath: \.textHeadlinePrimary, darkKeyPath: \.textHeadlinePrimary)
        }
        
        static var textDisablePrimary: UIColor {
            return dynamicColor(lightKeyPath: \.textDisablePrimary, darkKeyPath: \.textDisablePrimary)
        }
        
        static var textSecondary: UIColor {
            return dynamicColor(lightKeyPath: \.textSecondary, darkKeyPath: \.textSecondary)
        }
        
        static var textHeroCard: UIColor {
            return dynamicColor(lightKeyPath: \.textHeroCard, darkKeyPath: \.textHeroCard)
        }
        
        static var textSecondaryHeroCard: UIColor {
            return dynamicColor(lightKeyPath: \.textSecondaryHeroCard, darkKeyPath: \.textSecondaryHeroCard)
        }
        
        // MARK: - Separator Colors
        static var separatorLine: UIColor {
            return dynamicColor(lightKeyPath: \.separatorLine, darkKeyPath: \.separatorLine)
        }
        
        static var separatorLineHighlightPrimary: UIColor {
            return dynamicColor(lightKeyPath: \.separatorLineHighlightPrimary, darkKeyPath: \.separatorLineHighlightPrimary)
        }
        
        static var separatorLineHighlightSecondary: UIColor {
            return dynamicColor(lightKeyPath: \.separatorLineHighlightSecondary, darkKeyPath: \.separatorLineHighlightSecondary)
        }
        
        static var separatorLineSecondary: UIColor {
            return dynamicColor(lightKeyPath: \.separatorLineSecondary, darkKeyPath: \.separatorLineSecondary)
        }
        
        // MARK: - Scroll Color
        static var scroll: UIColor {
            return dynamicColor(lightKeyPath: \.scroll, darkKeyPath: \.scroll)
        }
        
        // MARK: - Pill Colors
        static var pillBackground: UIColor {
            return dynamicColor(lightKeyPath: \.pillBackground, darkKeyPath: \.pillBackground)
        }
        
        static var pillNavigation: UIColor {
            return dynamicColor(lightKeyPath: \.pillNavigation, darkKeyPath: \.pillNavigation)
        }
        
        static var pillSettings: UIColor {
            return dynamicColor(lightKeyPath: \.pillSettings, darkKeyPath: \.pillSettings)
        }
        
        // MARK: - Input Colors
        static var inputBackground: UIColor {
            return dynamicColor(lightKeyPath: \.inputBackground, darkKeyPath: \.inputBackground)
        }
        
        static var inputBorderActive: UIColor {
            return dynamicColor(lightKeyPath: \.inputBorderActive, darkKeyPath: \.inputBorderActive)
        }
        
        static var inputBorderDisabled: UIColor {
            return dynamicColor(lightKeyPath: \.inputBorderDisabled, darkKeyPath: \.inputBorderDisabled)
        }
        
        static var inputBackgroundSecondary: UIColor {
            return dynamicColor(lightKeyPath: \.inputBackgroundSecondary, darkKeyPath: \.inputBackgroundSecondary)
        }
        
        static var inputTextTitle: UIColor {
            return dynamicColor(lightKeyPath: \.inputTextTitle, darkKeyPath: \.inputTextTitle)
        }
        
        static var inputText: UIColor {
            return dynamicColor(lightKeyPath: \.inputText, darkKeyPath: \.inputText)
        }
        
        static var inputError: UIColor {
            return dynamicColor(lightKeyPath: \.inputError, darkKeyPath: \.inputError)
        }
        
        static var inputTextDisable: UIColor {
            return dynamicColor(lightKeyPath: \.inputTextDisable, darkKeyPath: \.inputTextDisable)
        }
        
        // MARK: - Icon Colors
        static var iconPrimary: UIColor {
            return dynamicColor(lightKeyPath: \.iconPrimary, darkKeyPath: \.iconPrimary)
        }
        
        static var iconSecondary: UIColor {
            return dynamicColor(lightKeyPath: \.iconSecondary, darkKeyPath: \.iconSecondary)
        }
        
        static var iconSportsHeroCard: UIColor {
            return dynamicColor(lightKeyPath: \.iconSportsHeroCard, darkKeyPath: \.iconSportsHeroCard)
        }
        
        // MARK: - Border Colors
        static var borderDrop: UIColor {
            return dynamicColor(lightKeyPath: \.borderDrop, darkKeyPath: \.borderDrop)
        }
        
        // MARK: - Highlight Colors
        static var highlightPrimary: UIColor {
            return dynamicColor(lightKeyPath: \.highlightPrimary, darkKeyPath: \.highlightPrimary)
        }
        
        static var highlightSecondary: UIColor {
            return dynamicColor(lightKeyPath: \.highlightSecondary, darkKeyPath: \.highlightSecondary)
        }
        
        static var highlightPrimaryContrast: UIColor {
            return dynamicColor(lightKeyPath: \.highlightPrimaryContrast, darkKeyPath: \.highlightPrimaryContrast)
        }
        
        static var highlightSecondaryContrast: UIColor {
            return dynamicColor(lightKeyPath: \.highlightSecondaryContrast, darkKeyPath: \.highlightSecondaryContrast)
        }
        
        static var highlightTertiary: UIColor {
            return dynamicColor(lightKeyPath: \.highlightTertiary, darkKeyPath: \.highlightTertiary)
        }
        
        // MARK: - Button Colors
        static var buttonTextPrimary: UIColor {
            return dynamicColor(lightKeyPath: \.buttonTextPrimary, darkKeyPath: \.buttonTextPrimary)
        }
        
        static var buttonBackgroundPrimary: UIColor {
            return dynamicColor(lightKeyPath: \.buttonBackgroundPrimary, darkKeyPath: \.buttonBackgroundPrimary)
        }
        
        static var buttonActiveHoverPrimary: UIColor {
            return dynamicColor(lightKeyPath: \.buttonActiveHoverPrimary, darkKeyPath: \.buttonActiveHoverPrimary)
        }
        
        static var buttonDisablePrimary: UIColor {
            return dynamicColor(lightKeyPath: \.buttonDisablePrimary, darkKeyPath: \.buttonDisablePrimary)
        }
        
        static var buttonTextDisablePrimary: UIColor {
            return dynamicColor(lightKeyPath: \.buttonTextDisablePrimary, darkKeyPath: \.buttonTextDisablePrimary)
        }
        
        static var buttonTextSecondary: UIColor {
            return dynamicColor(lightKeyPath: \.buttonTextSecondary, darkKeyPath: \.buttonTextSecondary)
        }
        
        static var buttonTextTertiary: UIColor {
            return dynamicColor(lightKeyPath: \.buttonTextTertiary, darkKeyPath: \.buttonTextTertiary)
        }
        
        static var buttonTextDisableTertiary: UIColor {
            return dynamicColor(lightKeyPath: \.buttonTextDisableTertiary, darkKeyPath: \.buttonTextDisableTertiary)
        }
        
        static var buttonBackgroundSecondary: UIColor {
            return dynamicColor(lightKeyPath: \.buttonBackgroundSecondary, darkKeyPath: \.buttonBackgroundSecondary)
        }
        
        static var buttonActiveHoverSecondary: UIColor {
            return dynamicColor(lightKeyPath: \.buttonActiveHoverSecondary, darkKeyPath: \.buttonActiveHoverSecondary)
        }
        
        static var buttonBackgroundTertiary: UIColor {
            return dynamicColor(lightKeyPath: \.buttonBackgroundTertiary, darkKeyPath: \.buttonBackgroundTertiary)
        }
        
        static var buttonActiveHoverTertiary: UIColor {
            return dynamicColor(lightKeyPath: \.buttonActiveHoverTertiary, darkKeyPath: \.buttonActiveHoverTertiary)
        }
        
        static var buttonBorderTertiary: UIColor {
            return dynamicColor(lightKeyPath: \.buttonBorderTertiary, darkKeyPath: \.buttonBorderTertiary)
        }
        
        static var buttonBorderDisableTertiary: UIColor {
            return dynamicColor(lightKeyPath: \.buttonBorderDisableTertiary, darkKeyPath: \.buttonBorderDisableTertiary)
        }
        
        // MARK: - Bubbles Color
        static var bubblesPrimary: UIColor {
            return dynamicColor(lightKeyPath: \.bubblesPrimary, darkKeyPath: \.bubblesPrimary)
        }
        
        // MARK: - Alert Colors
        static var alertError: UIColor {
            return dynamicColor(lightKeyPath: \.alertError, darkKeyPath: \.alertError)
        }
        
        static var alertSuccess: UIColor {
            return dynamicColor(lightKeyPath: \.alertSuccess, darkKeyPath: \.alertSuccess)
        }
        
        static var alertWarning: UIColor {
            return dynamicColor(lightKeyPath: \.alertWarning, darkKeyPath: \.alertWarning)
        }
        
        // MARK: - My Tickets Colors
        static var myTicketsLost: UIColor {
            return dynamicColor(lightKeyPath: \.myTicketsLost, darkKeyPath: \.myTicketsLost)
        }
        
        static var myTicketsLostFaded: UIColor {
            return dynamicColor(lightKeyPath: \.myTicketsLostFaded, darkKeyPath: \.myTicketsLostFaded)
        }
        
        static var myTicketsWon: UIColor {
            return dynamicColor(lightKeyPath: \.myTicketsWon, darkKeyPath: \.myTicketsWon)
        }
        
        static var myTicketsWonFaded: UIColor {
            return dynamicColor(lightKeyPath: \.myTicketsWonFaded, darkKeyPath: \.myTicketsWonFaded)
        }
        
        static var myTicketsOther: UIColor {
            return dynamicColor(lightKeyPath: \.myTicketsOther, darkKeyPath: \.myTicketsOther)
        }
        
        // MARK: - Stats Colors
        static var statsHome: UIColor {
            return dynamicColor(lightKeyPath: \.statsHome, darkKeyPath: \.statsHome)
        }
        
        static var statsAway: UIColor {
            return dynamicColor(lightKeyPath: \.statsAway, darkKeyPath: \.statsAway)
        }
        
        // MARK: - Gradient Colors
        static var headerGradient1: UIColor {
            return dynamicColor(lightKeyPath: \.headerGradient1, darkKeyPath: \.headerGradient1)
        }
        
        static var headerGradient2: UIColor {
            return dynamicColor(lightKeyPath: \.headerGradient2, darkKeyPath: \.headerGradient2)
        }
        
        static var headerGradient3: UIColor {
            return dynamicColor(lightKeyPath: \.headerGradient3, darkKeyPath: \.headerGradient3)
        }
        
        static var cardBorderLineGradient1: UIColor {
            return dynamicColor(lightKeyPath: \.cardBorderLineGradient1, darkKeyPath: \.cardBorderLineGradient1)
        }
        
        static var cardBorderLineGradient2: UIColor {
            return dynamicColor(lightKeyPath: \.cardBorderLineGradient2, darkKeyPath: \.cardBorderLineGradient2)
        }
        
        static var cardBorderLineGradient3: UIColor {
            return dynamicColor(lightKeyPath: \.cardBorderLineGradient3, darkKeyPath: \.cardBorderLineGradient3)
        }
        
        static var liveBorderGradient1: UIColor {
            return dynamicColor(lightKeyPath: \.liveBorderGradient1, darkKeyPath: \.liveBorderGradient1)
        }
        
        static var liveBorderGradient2: UIColor {
            return dynamicColor(lightKeyPath: \.liveBorderGradient2, darkKeyPath: \.liveBorderGradient2)
        }
        
        static var liveBorderGradient3: UIColor {
            return dynamicColor(lightKeyPath: \.liveBorderGradient3, darkKeyPath: \.liveBorderGradient3)
        }
        
        static var messageGradient1: UIColor {
            return dynamicColor(lightKeyPath: \.messageGradient1, darkKeyPath: \.messageGradient1)
        }
        
        static var messageGradient2: UIColor {
            return dynamicColor(lightKeyPath: \.messageGradient2, darkKeyPath: \.messageGradient2)
        }
        
        // MARK: - Navigation Colors
        static var navBanner: UIColor {
            return dynamicColor(lightKeyPath: \.navBanner, darkKeyPath: \.navBanner)
        }
        
        static var navBannerActive: UIColor {
            return dynamicColor(lightKeyPath: \.navBannerActive, darkKeyPath: \.navBannerActive)
        }
        
        // MARK: - Game Header Color
        static var gameHeader: UIColor {
            return dynamicColor(lightKeyPath: \.gameHeader, darkKeyPath: \.gameHeader)
        }
        
        // MARK: - Background Odds Hero Card
        static var backgroundOddsHeroCard: UIColor {
            return dynamicColor(lightKeyPath: \.backgroundOddsHeroCard, darkKeyPath: \.backgroundOddsHeroCard)
        }
    }
} 
