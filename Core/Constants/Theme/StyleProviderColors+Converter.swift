import Foundation
import GomaUI

// This is a helper file to convert the ThemeColors to StyleProviderColors
// StyleProviderColors is a GomaUI struct that contains the colors used by the components

// MARK: - StyleProviderColors Converter
extension StyleProviderColors {

    /// Creates a StyleProviderColors instance from light and dark ThemeColors
    /// - Parameters:
    ///   - lightTheme: ThemeColors instance for light mode
    ///   - darkTheme: ThemeColors instance for dark mode
    /// - Returns: StyleProviderColors with light/dark tuples for each color
    static func create(fromTheme theme: Theme) -> StyleProviderColors {
        Self.create(fromLightTheme: theme.lightColors, andDarkTheme: theme.darkColors)
    }

    /// Creates StyleProviderColors from a single ThemeColors instance (same for light and dark)
    /// - Parameter theme: ThemeColors instance to use for both light and dark modes
    /// - Returns: StyleProviderColors with the same colors for light and dark
    static func create(fromThemeColors theme: ThemeColors) -> StyleProviderColors {
        return Self.create(fromLightTheme: theme, andDarkTheme: theme)
    }

    /// Creates StyleProviderColors from light and dark ThemeColors
    /// - Parameters:
    ///   - lightTheme: ThemeColors instance for light mode
    ///   - darkTheme: ThemeColors instance for dark mode
    /// - Returns: StyleProviderColors with light/dark tuples for each color
    static func create(fromLightTheme lightTheme: ThemeColors, andDarkTheme darkTheme: ThemeColors) -> StyleProviderColors {
        return StyleProviderColors(
            // Highlights colors
            highlightPrimaryContrast: DynamicColorHex(
                light: lightTheme.highlightPrimaryContrast,
                dark: darkTheme.highlightPrimaryContrast
            ),
            highlightSecondaryContrast: DynamicColorHex(
                light: lightTheme.highlightSecondaryContrast,
                dark: darkTheme.highlightSecondaryContrast
            ),
            highlightPrimary: DynamicColorHex(
                light: lightTheme.highlightPrimary,
                dark: darkTheme.highlightPrimary
            ),
            highlightSecondary: DynamicColorHex(
                light: lightTheme.highlightSecondary,
                dark: darkTheme.highlightSecondary
            ),
            highlightTertiary: DynamicColorHex(
                light: lightTheme.highlightTertiary,
                dark: darkTheme.highlightTertiary
            ),

            // Backgrounds colors
            backgroundPrimary: DynamicColorHex(
                light: lightTheme.backgroundPrimary,
                dark: darkTheme.backgroundPrimary
            ),
            backgroundSecondary: DynamicColorHex(
                light: lightTheme.backgroundSecondary,
                dark: darkTheme.backgroundSecondary
            ),
            backgroundTertiary: DynamicColorHex(
                light: lightTheme.backgroundTertiary,
                dark: darkTheme.backgroundTertiary
            ),
            backgroundBorder: DynamicColorHex(
                light: lightTheme.backgroundBorder,
                dark: darkTheme.backgroundBorder
            ),
            backgroundCards: DynamicColorHex(
                light: lightTheme.backgroundCards,
                dark: darkTheme.backgroundCards
            ),
            appBottomMenu: DynamicColorHex(
                light: lightTheme.appBottomMenu,
                dark: darkTheme.appBottomMenu
            ),

            // Separators colors
            separatorLine: DynamicColorHex(
                light: lightTheme.separatorLine,
                dark: darkTheme.separatorLine
            ),
            separatorLineSecondary: DynamicColorHex(
                light: lightTheme.separatorLineSecondary,
                dark: darkTheme.separatorLineSecondary
            ),
            separatorLineHighlightPrimary: DynamicColorHex(
                light: lightTheme.separatorLineHighlightPrimary,
                dark: darkTheme.separatorLineHighlightPrimary
            ),
            separatorLineHighlightSecondary: DynamicColorHex(
                light: lightTheme.separatorLineHighlightSecondary,
                dark: darkTheme.separatorLineHighlightSecondary
            ),

            // Text colors
            textPrimary: DynamicColorHex(
                light: lightTheme.textPrimary,
                dark: darkTheme.textPrimary
            ),
            textSecondary: DynamicColorHex(
                light: lightTheme.textSecondary,
                dark: darkTheme.textSecondary
            ),
            textHeadlinePrimary: DynamicColorHex(
                light: lightTheme.textHeadlinePrimary,
                dark: darkTheme.textHeadlinePrimary
            ),
            textDisablePrimary: DynamicColorHex(
                light: lightTheme.textDisablePrimary,
                dark: darkTheme.textDisablePrimary
            ),
            textTopbar: DynamicColorHex(
                light: lightTheme.textTopbar,
                dark: darkTheme.textTopbar
            ),

            // Odds colors
            backgroundOdds: DynamicColorHex(
                light: lightTheme.backgroundOdds,
                dark: darkTheme.backgroundOdds
            ),
            textOdds: DynamicColorHex(
                light: lightTheme.textOdds,
                dark: darkTheme.textOdds
            ),
            textDisabledOdds: DynamicColorHex(
                light: lightTheme.textDisabledOdds,
                dark: darkTheme.textDisabledOdds
            ),
            backgroundDisabledOdds: DynamicColorHex(
                light: lightTheme.backgroundDisabledOdds,
                dark: darkTheme.backgroundDisabledOdds
            ),

            // Icons colors
            iconPrimary: DynamicColorHex(
                light: lightTheme.iconPrimary,
                dark: darkTheme.iconPrimary
            ),
            iconSecondary: DynamicColorHex(
                light: lightTheme.iconSecondary,
                dark: darkTheme.iconSecondary
            ),

            // Inputs colors
            inputBackground: DynamicColorHex(
                light: lightTheme.inputBackground,
                dark: darkTheme.inputBackground
            ),
            inputBackgroundSecondary: DynamicColorHex(
                light: lightTheme.inputBackgroundSecondary,
                dark: darkTheme.inputBackgroundSecondary
            ),
            inputBorderActive: DynamicColorHex(
                light: lightTheme.inputBorderActive,
                dark: darkTheme.inputBorderActive
            ),
            inputError: DynamicColorHex(
                light: lightTheme.inputError,
                dark: darkTheme.inputError
            ),
            inputBackgroundDisable: DynamicColorHex(
                light: lightTheme.inputBackgroundDisable,
                dark: darkTheme.inputBackgroundDisable
            ),
            inputBorderDisabled: DynamicColorHex(
                light: lightTheme.inputBorderDisabled,
                dark: darkTheme.inputBorderDisabled
            ),
            inputTextTitle: DynamicColorHex(
                light: lightTheme.inputTextTitle,
                dark: darkTheme.inputTextTitle
            ),
            inputText: DynamicColorHex(
                light: lightTheme.inputText,
                dark: darkTheme.inputText
            ),
            inputTextTitleDisable: DynamicColorHex(
                light: lightTheme.inputTextTitleDisable,
                dark: darkTheme.inputTextTitleDisable
            ),
            inputTextDisable: DynamicColorHex(
                light: lightTheme.inputTextDisable,
                dark: darkTheme.inputTextDisable
            ),

            // Nav Pills colors
            navPills: DynamicColorHex(
                light: lightTheme.navPills,
                dark: darkTheme.navPills
            ),
            pills: DynamicColorHex(
                light: lightTheme.pills,
                dark: darkTheme.pills
            ),
            settingPill: DynamicColorHex(
                light: lightTheme.settingPill,
                dark: darkTheme.settingPill
            ),

            // Drops colors
            backgroundDrop: DynamicColorHex(
                light: lightTheme.backgroundDrop,
                dark: darkTheme.backgroundDrop
            ),
            borderDrop: DynamicColorHex(
                light: lightTheme.borderDrop,
                dark: darkTheme.borderDrop
            ),

            // Nav Banner colors
            navBannerActive: DynamicColorHex(
                light: lightTheme.navBannerActive,
                dark: darkTheme.navBannerActive
            ),
            navBanner: DynamicColorHex(
                light: lightTheme.navBanner,
                dark: darkTheme.navBanner
            ),

            // Buttons colors
            buttonTextPrimary: DynamicColorHex(
                light: lightTheme.buttonTextPrimary,
                dark: darkTheme.buttonTextPrimary
            ),
            buttonTextSecondary: DynamicColorHex(
                light: lightTheme.buttonTextSecondary,
                dark: darkTheme.buttonTextSecondary
            ),
            buttonBackgroundPrimary: DynamicColorHex(
                light: lightTheme.buttonBackgroundPrimary,
                dark: darkTheme.buttonBackgroundPrimary
            ),
            buttonActiveHoverPrimary: DynamicColorHex(
                light: lightTheme.buttonActiveHoverPrimary,
                dark: darkTheme.buttonActiveHoverPrimary
            ),
            buttonDisablePrimary: DynamicColorHex(
                light: lightTheme.buttonDisablePrimary,
                dark: darkTheme.buttonDisablePrimary
            ),
            buttonTextDisablePrimary: DynamicColorHex(
                light: lightTheme.buttonTextDisablePrimary,
                dark: darkTheme.buttonTextDisablePrimary
            ),
            buttonBackgroundSecondary: DynamicColorHex(
                light: lightTheme.buttonBackgroundSecondary,
                dark: darkTheme.buttonBackgroundSecondary
            ),
            buttonActiveHoverSecondary: DynamicColorHex(
                light: lightTheme.buttonActiveHoverSecondary,
                dark: darkTheme.buttonActiveHoverSecondary
            ),
            buttonDisableSecondary: DynamicColorHex(
                light: lightTheme.buttonDisableSecondary,
                dark: darkTheme.buttonDisableSecondary
            ),
            buttonTextDisableSecondary: DynamicColorHex(
                light: lightTheme.buttonTextDisableSecondary,
                dark: darkTheme.buttonTextDisableSecondary
            ),
            buttonBackgroundTertiary: DynamicColorHex(
                light: lightTheme.buttonBackgroundTertiary,
                dark: darkTheme.buttonBackgroundTertiary
            ),
            buttonTextTertiary: DynamicColorHex(
                light: lightTheme.buttonTextTertiary,
                dark: darkTheme.buttonTextTertiary
            ),
            buttonBorderTertiary: DynamicColorHex(
                light: lightTheme.buttonBorderTertiary,
                dark: darkTheme.buttonBorderTertiary
            ),
            buttonActiveHoverTertiary: DynamicColorHex(
                light: lightTheme.buttonActiveHoverTertiary,
                dark: darkTheme.buttonActiveHoverTertiary
            ),
            buttonBorderDisableTertiary: DynamicColorHex(
                light: lightTheme.buttonBorderDisableTertiary,
                dark: darkTheme.buttonBorderDisableTertiary
            ),
            buttonTextDisableTertiary: DynamicColorHex(
                light: lightTheme.buttonTextDisableTertiary,
                dark: darkTheme.buttonTextDisableTertiary
            ),

            // Alerts colors
            alertError: DynamicColorHex(
                light: lightTheme.alertError,
                dark: darkTheme.alertError
            ),
            alertSuccess: DynamicColorHex(
                light: lightTheme.alertSuccess,
                dark: darkTheme.alertSuccess
            ),
            alertWarning: DynamicColorHex(
                light: lightTheme.alertWarning,
                dark: darkTheme.alertWarning
            ),

            // Tickets colors
            myTicketsLostFaded: DynamicColorHex(
                light: lightTheme.myTicketsLostFaded,
                dark: darkTheme.myTicketsLostFaded
            ),
            myTicketsWon: DynamicColorHex(
                light: lightTheme.myTicketsWon,
                dark: darkTheme.myTicketsWon
            ),
            myTicketsWonFaded: DynamicColorHex(
                light: lightTheme.myTicketsWonFaded,
                dark: darkTheme.myTicketsWonFaded
            ),
            myTicketsOther: DynamicColorHex(
                light: lightTheme.myTicketsOther,
                dark: darkTheme.myTicketsOther
            ),
            myTicketsLost: DynamicColorHex(
                light: lightTheme.myTicketsLost,
                dark: darkTheme.myTicketsLost
            ),

            // Stats colors
            statsAway: DynamicColorHex(
                light: lightTheme.statsAway,
                dark: darkTheme.statsAway
            ),
            statsHome: DynamicColorHex(
                light: lightTheme.statsHome,
                dark: darkTheme.statsHome
            ),

            // Shadow colors
            shadow: DynamicColorHex(
                light: lightTheme.shadow,
                dark: darkTheme.shadow
            ),
            shadowMedium: DynamicColorHex(
                light: lightTheme.shadowMedium,
                dark: darkTheme.shadowMedium
            ),
            shadowDarker: DynamicColorHex(
                light: lightTheme.shadowDarker,
                dark: darkTheme.shadowDarker
            ),

            // Misc colors
            scroll: DynamicColorHex(
                light: lightTheme.scroll,
                dark: darkTheme.scroll
            ),
            bubblesPrimary: DynamicColorHex(
                light: lightTheme.bubblesPrimary,
                dark: darkTheme.bubblesPrimary
            ),
            menuSelector: DynamicColorHex(
                light: lightTheme.menuSelector,
                dark: darkTheme.menuSelector
            ),
            menuSelectorHover: DynamicColorHex(
                light: lightTheme.menuSelectorHover,
                dark: darkTheme.menuSelectorHover
            ),
            allWhite: DynamicColorHex(
                light: lightTheme.allWhite,
                dark: darkTheme.allWhite
            ),
            allDark: DynamicColorHex(
                light: lightTheme.allDark,
                dark: darkTheme.allDark
            ),
            favorites: DynamicColorHex(
                light: lightTheme.favorites,
                dark: darkTheme.favorites
            ),
            liveTag: DynamicColorHex(
                light: lightTheme.liveTag,
                dark: darkTheme.liveTag
            ),

            // Hero cards colors
            textHeroCard: DynamicColorHex(
                light: lightTheme.textHeroCard,
                dark: darkTheme.textHeroCard
            ),
            textSecondaryHeroCard: DynamicColorHex(
                light: lightTheme.textSecondaryHeroCard,
                dark: darkTheme.textSecondaryHeroCard
            ),
            iconSportsHeroCard: DynamicColorHex(
                light: lightTheme.iconSportsHeroCard,
                dark: darkTheme.iconSportsHeroCard
            ),
            backgroundOddsHeroCard: DynamicColorHex(
                light: lightTheme.backgroundOddsHeroCard,
                dark: darkTheme.backgroundOddsHeroCard
            ),

            // Betslip colors
            backgroundBetslip: DynamicColorHex(
                light: lightTheme.backgroundBetslip,
                dark: darkTheme.backgroundBetslip
            ),
            addBetslip: DynamicColorHex(
                light: lightTheme.addBetslip,
                dark: darkTheme.addBetslip
            ),

            // Game Header colors
            gameHeaderTextPrimary: DynamicColorHex(
                light: lightTheme.gameHeaderTextPrimary,
                dark: darkTheme.gameHeaderTextPrimary
            ),
            gameHeaderTextSecondary: DynamicColorHex(
                light: lightTheme.gameHeaderTextSecondary,
                dark: darkTheme.gameHeaderTextSecondary
            ),
            gameHeader: DynamicColorHex(
                light: lightTheme.gameHeader,
                dark: darkTheme.gameHeader
            ),

            // Gradients colors
            cardBorderLineGradient1: DynamicColorHex(
                light: lightTheme.cardBorderLineGradient1,
                dark: darkTheme.cardBorderLineGradient1
            ),
            cardBorderLineGradient2: DynamicColorHex(
                light: lightTheme.cardBorderLineGradient2,
                dark: darkTheme.cardBorderLineGradient2
            ),
            cardBorderLineGradient3: DynamicColorHex(
                light: lightTheme.cardBorderLineGradient3,
                dark: darkTheme.cardBorderLineGradient3
            ),
            boostedOddsGradient1: DynamicColorHex(
                light: lightTheme.boostedOddsGradient1,
                dark: darkTheme.boostedOddsGradient1
            ),
            boostedOddsGradient2: DynamicColorHex(
                light: lightTheme.boostedOddsGradient2,
                dark: darkTheme.boostedOddsGradient2
            ),
            backgroundGradientDark: DynamicColorHex(
                light: lightTheme.backgroundGradientDark,
                dark: darkTheme.backgroundGradientDark
            ),
            backgroundGradientLight: DynamicColorHex(
                light: lightTheme.backgroundGradientLight,
                dark: darkTheme.backgroundGradientLight
            ),
            backgroundGradient1: DynamicColorHex(
                light: lightTheme.backgroundGradient1,
                dark: darkTheme.backgroundGradient1
            ),
            backgroundGradient2: DynamicColorHex(
                light: lightTheme.backgroundGradient2,
                dark: darkTheme.backgroundGradient2
            ),
            topBarGradient1: DynamicColorHex(
                light: lightTheme.topBarGradient1,
                dark: darkTheme.topBarGradient1
            ),
            topBarGradient2: DynamicColorHex(
                light: lightTheme.topBarGradient2,
                dark: darkTheme.topBarGradient2
            ),
            topBarGradient3: DynamicColorHex(
                light: lightTheme.topBarGradient3,
                dark: darkTheme.topBarGradient3
            ),
            liveBorder1: DynamicColorHex(
                light: lightTheme.liveBorder1,
                dark: darkTheme.liveBorder1
            ),
            liveBorder2: DynamicColorHex(
                light: lightTheme.liveBorder2,
                dark: darkTheme.liveBorder2
            ),
            liveBorder3: DynamicColorHex(
                light: lightTheme.liveBorder3,
                dark: darkTheme.liveBorder3
            ),
            messageGradient1: DynamicColorHex(
                light: lightTheme.messageGradient1,
                dark: darkTheme.messageGradient1
            ),
            messageGradient2: DynamicColorHex(
                light: lightTheme.messageGradient2,
                dark: darkTheme.messageGradient2
            ),
            backgroundEmptySuccess1: DynamicColorHex(
                light: lightTheme.backgroundEmptySuccess1,
                dark: darkTheme.backgroundEmptySuccess1
            ),
            backgroundEmptySuccess2: DynamicColorHex(
                light: lightTheme.backgroundEmptySuccess2,
                dark: darkTheme.backgroundEmptySuccess2
            ),
            backgroundEmptySuccess3: DynamicColorHex(
                light: lightTheme.backgroundEmptySuccess3,
                dark: darkTheme.backgroundEmptySuccess3
            ),
            backgroundEmptyWinner1: DynamicColorHex(
                light: lightTheme.backgroundEmptyWinner1,
                dark: darkTheme.backgroundEmptyWinner1
            ),
            backgroundEmptyWinner2: DynamicColorHex(
                light: lightTheme.backgroundEmptyWinner2,
                dark: darkTheme.backgroundEmptyWinner2
            ),
            backgroundEmptyWinner3: DynamicColorHex(
                light: lightTheme.backgroundEmptyWinner3,
                dark: darkTheme.backgroundEmptyWinner3
            ),
            backgroundEmptyMessage1: DynamicColorHex(
                light: lightTheme.backgroundEmptyMessage1,
                dark: darkTheme.backgroundEmptyMessage1
            ),
            backgroundEmptyMessage2: DynamicColorHex(
                light: lightTheme.backgroundEmptyMessage2,
                dark: darkTheme.backgroundEmptyMessage2
            ),
            backgroundEmptyMessage3: DynamicColorHex(
                light: lightTheme.backgroundEmptyMessage3,
                dark: darkTheme.backgroundEmptyMessage3
            )
        )
    }
}
