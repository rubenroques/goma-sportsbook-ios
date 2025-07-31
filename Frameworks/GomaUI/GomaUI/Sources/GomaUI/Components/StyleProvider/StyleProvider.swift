import UIKit

// MARK: - DynamicColorHex
public struct DynamicColorHex: Codable, Hashable {
    public let light: String
    public let dark: String

    public init(light: String, dark: String) {
        self.light = light
        self.dark = dark
    }
}

// MARK: - StyleProviderColors
public struct StyleProviderColors: Codable, Hashable {
    // Highlights colors
    let highlightPrimaryContrast: DynamicColorHex
    let highlightSecondaryContrast: DynamicColorHex
    let highlightPrimary: DynamicColorHex
    let highlightSecondary: DynamicColorHex
    let highlightTertiary: DynamicColorHex

    // Backgrounds colors
    let backgroundPrimary: DynamicColorHex
    let backgroundSecondary: DynamicColorHex
    let backgroundTertiary: DynamicColorHex
    let backgroundBorder: DynamicColorHex
    let backgroundCards: DynamicColorHex
    let appBottomMenu: DynamicColorHex

    // Separators colors
    let separatorLine: DynamicColorHex
    let separatorLineSecondary: DynamicColorHex
    let separatorLineHighlightPrimary: DynamicColorHex
    let separatorLineHighlightSecondary: DynamicColorHex

    // Text colors
    let textPrimary: DynamicColorHex
    let textSecondary: DynamicColorHex
    let textHeadlinePrimary: DynamicColorHex
    let textDisablePrimary: DynamicColorHex
    let textTopbar: DynamicColorHex

    // Odds colors
    let backgroundOdds: DynamicColorHex
    let textOdds: DynamicColorHex
    let textDisabledOdds: DynamicColorHex
    let backgroundDisabledOdds: DynamicColorHex

    // Icons colors
    let iconPrimary: DynamicColorHex
    let iconSecondary: DynamicColorHex

    // Inputs colors
    let inputBackground: DynamicColorHex
    let inputBackgroundSecondary: DynamicColorHex
    let inputBorderActive: DynamicColorHex
    let inputError: DynamicColorHex
    let inputBackgroundDisable: DynamicColorHex
    let inputBorderDisabled: DynamicColorHex
    let inputTextTitle: DynamicColorHex
    let inputText: DynamicColorHex
    let inputTextTitleDisable: DynamicColorHex
    let inputTextDisable: DynamicColorHex

    // Nav Pills colors
    let navPills: DynamicColorHex
    let pills: DynamicColorHex
    let settingPill: DynamicColorHex

    // Drops colors
    let backgroundDrop: DynamicColorHex
    let borderDrop: DynamicColorHex

    // Nav Banner colors
    let navBannerActive: DynamicColorHex
    let navBanner: DynamicColorHex

    // Buttons colors
    let buttonTextPrimary: DynamicColorHex
    let buttonTextSecondary: DynamicColorHex
    let buttonBackgroundPrimary: DynamicColorHex
    let buttonActiveHoverPrimary: DynamicColorHex
    let buttonDisablePrimary: DynamicColorHex
    let buttonTextDisablePrimary: DynamicColorHex
    let buttonBackgroundSecondary: DynamicColorHex
    let buttonActiveHoverSecondary: DynamicColorHex
    let buttonDisableSecondary: DynamicColorHex
    let buttonTextDisableSecondary: DynamicColorHex
    let buttonBackgroundTertiary: DynamicColorHex
    let buttonTextTertiary: DynamicColorHex
    let buttonBorderTertiary: DynamicColorHex
    let buttonActiveHoverTertiary: DynamicColorHex
    let buttonBorderDisableTertiary: DynamicColorHex
    let buttonTextDisableTertiary: DynamicColorHex

    // Alerts colors
    let alertError: DynamicColorHex
    let alertSuccess: DynamicColorHex
    let alertWarning: DynamicColorHex

    // Tickets colors
    let myTicketsLostFaded: DynamicColorHex
    let myTicketsWon: DynamicColorHex
    let myTicketsWonFaded: DynamicColorHex
    let myTicketsOther: DynamicColorHex
    let myTicketsLost: DynamicColorHex

    // Stats colors
    let statsAway: DynamicColorHex
    let statsHome: DynamicColorHex

    // Shadow colors
    let shadow: DynamicColorHex
    let shadowMedium: DynamicColorHex
    let shadowDarker: DynamicColorHex

    // Misc colors
    let scroll: DynamicColorHex
    let bubblesPrimary: DynamicColorHex
    let menuSelector: DynamicColorHex
    let menuSelectorHover: DynamicColorHex
    let allWhite: DynamicColorHex
    let allDark: DynamicColorHex
    let favorites: DynamicColorHex
    let liveTag: DynamicColorHex

    // Hero cards colors
    let textHeroCard: DynamicColorHex
    let textSecondaryHeroCard: DynamicColorHex
    let iconSportsHeroCard: DynamicColorHex
    let backgroundOddsHeroCard: DynamicColorHex

    // Betslip colors
    let backgroundBetslip: DynamicColorHex
    let addBetslip: DynamicColorHex

    // Game Header colors
    let gameHeaderTextPrimary: DynamicColorHex
    let gameHeaderTextSecondary: DynamicColorHex
    let gameHeader: DynamicColorHex

    // Gradients colors
    let cardBorderLineGradient1: DynamicColorHex
    let cardBorderLineGradient2: DynamicColorHex
    let cardBorderLineGradient3: DynamicColorHex
    let boostedOddsGradient1: DynamicColorHex
    let boostedOddsGradient2: DynamicColorHex
    let backgroundGradientDark: DynamicColorHex
    let backgroundGradientLight: DynamicColorHex
    let backgroundGradient1: DynamicColorHex
    let backgroundGradient2: DynamicColorHex
    let topBarGradient1: DynamicColorHex
    let topBarGradient2: DynamicColorHex
    let topBarGradient3: DynamicColorHex
    let liveBorder1: DynamicColorHex
    let liveBorder2: DynamicColorHex
    let liveBorder3: DynamicColorHex
    let messageGradient1: DynamicColorHex
    let messageGradient2: DynamicColorHex
    let backgroundEmptySuccess1: DynamicColorHex
    let backgroundEmptySuccess2: DynamicColorHex
    let backgroundEmptySuccess3: DynamicColorHex
    let backgroundEmptyWinner1: DynamicColorHex
    let backgroundEmptyWinner2: DynamicColorHex
    let backgroundEmptyWinner3: DynamicColorHex
    let backgroundEmptyMessage1: DynamicColorHex
    let backgroundEmptyMessage2: DynamicColorHex
    let backgroundEmptyMessage3: DynamicColorHex

    public init(highlightPrimaryContrast: DynamicColorHex,
                highlightSecondaryContrast: DynamicColorHex,
                highlightPrimary: DynamicColorHex,
                highlightSecondary: DynamicColorHex,
                highlightTertiary: DynamicColorHex,
                backgroundPrimary: DynamicColorHex,
                backgroundSecondary: DynamicColorHex,
                backgroundTertiary: DynamicColorHex,
                backgroundBorder: DynamicColorHex,
                backgroundCards: DynamicColorHex,
                appBottomMenu: DynamicColorHex,
                separatorLine: DynamicColorHex,
                separatorLineSecondary: DynamicColorHex,
                separatorLineHighlightPrimary: DynamicColorHex,
                separatorLineHighlightSecondary: DynamicColorHex,
                textPrimary: DynamicColorHex,
                textSecondary: DynamicColorHex,
                textHeadlinePrimary: DynamicColorHex,
                textDisablePrimary: DynamicColorHex,
                textTopbar: DynamicColorHex,
                backgroundOdds: DynamicColorHex,
                textOdds: DynamicColorHex,
                textDisabledOdds: DynamicColorHex,
                backgroundDisabledOdds: DynamicColorHex,
                iconPrimary: DynamicColorHex,
                iconSecondary: DynamicColorHex,
                inputBackground: DynamicColorHex,
                inputBackgroundSecondary: DynamicColorHex,
                inputBorderActive: DynamicColorHex,
                inputError: DynamicColorHex,
                inputBackgroundDisable: DynamicColorHex,
                inputBorderDisabled: DynamicColorHex,
                inputTextTitle: DynamicColorHex,
                inputText: DynamicColorHex,
                inputTextTitleDisable: DynamicColorHex,
                inputTextDisable: DynamicColorHex,
                navPills: DynamicColorHex,
                pills: DynamicColorHex,
                settingPill: DynamicColorHex,
                backgroundDrop: DynamicColorHex,
                borderDrop: DynamicColorHex,
                navBannerActive: DynamicColorHex,
                navBanner: DynamicColorHex,
                buttonTextPrimary: DynamicColorHex,
                buttonTextSecondary: DynamicColorHex,
                buttonBackgroundPrimary: DynamicColorHex,
                buttonActiveHoverPrimary: DynamicColorHex,
                buttonDisablePrimary: DynamicColorHex,
                buttonTextDisablePrimary: DynamicColorHex,
                buttonBackgroundSecondary: DynamicColorHex,
                buttonActiveHoverSecondary: DynamicColorHex,
                buttonDisableSecondary: DynamicColorHex,
                buttonTextDisableSecondary: DynamicColorHex,
                buttonBackgroundTertiary: DynamicColorHex,
                buttonTextTertiary: DynamicColorHex,
                buttonBorderTertiary: DynamicColorHex,
                buttonActiveHoverTertiary: DynamicColorHex,
                buttonBorderDisableTertiary: DynamicColorHex,
                buttonTextDisableTertiary: DynamicColorHex,
                alertError: DynamicColorHex,
                alertSuccess: DynamicColorHex,
                alertWarning: DynamicColorHex,
                myTicketsLostFaded: DynamicColorHex,
                myTicketsWon: DynamicColorHex,
                myTicketsWonFaded: DynamicColorHex,
                myTicketsOther: DynamicColorHex,
                myTicketsLost: DynamicColorHex,
                statsAway: DynamicColorHex,
                statsHome: DynamicColorHex,
                shadow: DynamicColorHex,
                shadowMedium: DynamicColorHex,
                shadowDarker: DynamicColorHex,
                scroll: DynamicColorHex,
                bubblesPrimary: DynamicColorHex,
                menuSelector: DynamicColorHex,
                menuSelectorHover: DynamicColorHex,
                allWhite: DynamicColorHex,
                allDark: DynamicColorHex,
                favorites: DynamicColorHex,
                liveTag: DynamicColorHex,
                textHeroCard: DynamicColorHex,
                textSecondaryHeroCard: DynamicColorHex,
                iconSportsHeroCard: DynamicColorHex,
                backgroundOddsHeroCard: DynamicColorHex,
                backgroundBetslip: DynamicColorHex,
                addBetslip: DynamicColorHex,
                gameHeaderTextPrimary: DynamicColorHex,
                gameHeaderTextSecondary: DynamicColorHex,
                gameHeader: DynamicColorHex,
                cardBorderLineGradient1: DynamicColorHex,
                cardBorderLineGradient2: DynamicColorHex,
                cardBorderLineGradient3: DynamicColorHex,
                boostedOddsGradient1: DynamicColorHex,
                boostedOddsGradient2: DynamicColorHex,
                backgroundGradientDark: DynamicColorHex,
                backgroundGradientLight: DynamicColorHex,
                backgroundGradient1: DynamicColorHex,
                backgroundGradient2: DynamicColorHex,
                topBarGradient1: DynamicColorHex,
                topBarGradient2: DynamicColorHex,
                topBarGradient3: DynamicColorHex,
                liveBorder1: DynamicColorHex,
                liveBorder2: DynamicColorHex,
                liveBorder3: DynamicColorHex,
                messageGradient1: DynamicColorHex,
                messageGradient2: DynamicColorHex,
                backgroundEmptySuccess1: DynamicColorHex,
                backgroundEmptySuccess2: DynamicColorHex,
                backgroundEmptySuccess3: DynamicColorHex,
                backgroundEmptyWinner1: DynamicColorHex,
                backgroundEmptyWinner2: DynamicColorHex,
                backgroundEmptyWinner3: DynamicColorHex,
                backgroundEmptyMessage1: DynamicColorHex,
                backgroundEmptyMessage2: DynamicColorHex,
                backgroundEmptyMessage3: DynamicColorHex) {
        
        self.highlightPrimaryContrast = highlightPrimaryContrast
        self.highlightSecondaryContrast = highlightSecondaryContrast
        self.highlightPrimary = highlightPrimary
        self.highlightSecondary = highlightSecondary
        self.highlightTertiary = highlightTertiary
        self.backgroundPrimary = backgroundPrimary
        self.backgroundSecondary = backgroundSecondary
        self.backgroundTertiary = backgroundTertiary
        self.backgroundBorder = backgroundBorder
        self.backgroundCards = backgroundCards
        self.appBottomMenu = appBottomMenu
        self.separatorLine = separatorLine
        self.separatorLineSecondary = separatorLineSecondary
        self.separatorLineHighlightPrimary = separatorLineHighlightPrimary
        self.separatorLineHighlightSecondary = separatorLineHighlightSecondary
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.textHeadlinePrimary = textHeadlinePrimary
        self.textDisablePrimary = textDisablePrimary
        self.textTopbar = textTopbar
        self.backgroundOdds = backgroundOdds
        self.textOdds = textOdds
        self.textDisabledOdds = textDisabledOdds
        self.backgroundDisabledOdds = backgroundDisabledOdds
        self.iconPrimary = iconPrimary
        self.iconSecondary = iconSecondary
        self.inputBackground = inputBackground
        self.inputBackgroundSecondary = inputBackgroundSecondary
        self.inputBorderActive = inputBorderActive
        self.inputError = inputError
        self.inputBackgroundDisable = inputBackgroundDisable
        self.inputBorderDisabled = inputBorderDisabled
        self.inputTextTitle = inputTextTitle
        self.inputText = inputText
        self.inputTextTitleDisable = inputTextTitleDisable
        self.inputTextDisable = inputTextDisable
        self.navPills = navPills
        self.pills = pills
        self.settingPill = settingPill
        self.backgroundDrop = backgroundDrop
        self.borderDrop = borderDrop
        self.navBannerActive = navBannerActive
        self.navBanner = navBanner
        self.buttonTextPrimary = buttonTextPrimary
        self.buttonTextSecondary = buttonTextSecondary
        self.buttonBackgroundPrimary = buttonBackgroundPrimary
        self.buttonActiveHoverPrimary = buttonActiveHoverPrimary
        self.buttonDisablePrimary = buttonDisablePrimary
        self.buttonTextDisablePrimary = buttonTextDisablePrimary
        self.buttonBackgroundSecondary = buttonBackgroundSecondary
        self.buttonActiveHoverSecondary = buttonActiveHoverSecondary
        self.buttonDisableSecondary = buttonDisableSecondary
        self.buttonTextDisableSecondary = buttonTextDisableSecondary
        self.buttonBackgroundTertiary = buttonBackgroundTertiary
        self.buttonTextTertiary = buttonTextTertiary
        self.buttonBorderTertiary = buttonBorderTertiary
        self.buttonActiveHoverTertiary = buttonActiveHoverTertiary
        self.buttonBorderDisableTertiary = buttonBorderDisableTertiary
        self.buttonTextDisableTertiary = buttonTextDisableTertiary
        self.alertError = alertError
        self.alertSuccess = alertSuccess
        self.alertWarning = alertWarning
        self.myTicketsLostFaded = myTicketsLostFaded
        self.myTicketsWon = myTicketsWon
        self.myTicketsWonFaded = myTicketsWonFaded
        self.myTicketsOther = myTicketsOther
        self.myTicketsLost = myTicketsLost
        self.statsAway = statsAway
        self.statsHome = statsHome
        self.shadow = shadow
        self.shadowMedium = shadowMedium
        self.shadowDarker = shadowDarker
        self.scroll = scroll
        self.bubblesPrimary = bubblesPrimary
        self.menuSelector = menuSelector
        self.menuSelectorHover = menuSelectorHover
        self.allWhite = allWhite
        self.allDark = allDark
        self.favorites = favorites
        self.liveTag = liveTag
        self.textHeroCard = textHeroCard
        self.textSecondaryHeroCard = textSecondaryHeroCard
        self.iconSportsHeroCard = iconSportsHeroCard
        self.backgroundOddsHeroCard = backgroundOddsHeroCard
        self.backgroundBetslip = backgroundBetslip
        self.addBetslip = addBetslip
        self.gameHeaderTextPrimary = gameHeaderTextPrimary
        self.gameHeaderTextSecondary = gameHeaderTextSecondary
        self.gameHeader = gameHeader
        self.cardBorderLineGradient1 = cardBorderLineGradient1
        self.cardBorderLineGradient2 = cardBorderLineGradient2
        self.cardBorderLineGradient3 = cardBorderLineGradient3
        self.boostedOddsGradient1 = boostedOddsGradient1
        self.boostedOddsGradient2 = boostedOddsGradient2
        self.backgroundGradientDark = backgroundGradientDark
        self.backgroundGradientLight = backgroundGradientLight
        self.backgroundGradient1 = backgroundGradient1
        self.backgroundGradient2 = backgroundGradient2
        self.topBarGradient1 = topBarGradient1
        self.topBarGradient2 = topBarGradient2
        self.topBarGradient3 = topBarGradient3
        self.liveBorder1 = liveBorder1
        self.liveBorder2 = liveBorder2
        self.liveBorder3 = liveBorder3
        self.messageGradient1 = messageGradient1
        self.messageGradient2 = messageGradient2
        self.backgroundEmptySuccess1 = backgroundEmptySuccess1
        self.backgroundEmptySuccess2 = backgroundEmptySuccess2
        self.backgroundEmptySuccess3 = backgroundEmptySuccess3
        self.backgroundEmptyWinner1 = backgroundEmptyWinner1
        self.backgroundEmptyWinner2 = backgroundEmptyWinner2
        self.backgroundEmptyWinner3 = backgroundEmptyWinner3
        self.backgroundEmptyMessage1 = backgroundEmptyMessage1
        self.backgroundEmptyMessage2 = backgroundEmptyMessage2
        self.backgroundEmptyMessage3 = backgroundEmptyMessage3
    }
}

// MARK: - Default Colors
extension StyleProviderColors {
    static let defaultColors = StyleProviderColors(
        highlightPrimaryContrast: DynamicColorHex(light: "#000114", dark: "#ffffff"),
        highlightSecondaryContrast: DynamicColorHex(light: "#ffffff", dark: "#000114"),
        highlightPrimary: DynamicColorHex(light: "#ff6600", dark: "#ff6600"),
        highlightSecondary: DynamicColorHex(light: "#40b840", dark: "#40b840"),
        highlightTertiary: DynamicColorHex(light: "#4a90e2", dark: "#4a90e2"),
        backgroundPrimary: DynamicColorHex(light: "#e7e7e7", dark: "#353743"),
        backgroundSecondary: DynamicColorHex(light: "#f6f6f8", dark: "#282933"),
        backgroundTertiary: DynamicColorHex(light: "#ffffff", dark: "#181a22"),
        backgroundBorder: DynamicColorHex(light: "#b3b3b3", dark: "#40424b"),
        backgroundCards: DynamicColorHex(light: "#ffffff", dark: "#17191e"),
        appBottomMenu: DynamicColorHex(light: "#e7e7e7", dark: "#353743"),
        separatorLine: DynamicColorHex(light: "#d8d8d8", dark: "#40424b"),
        separatorLineSecondary: DynamicColorHex(light: "#e1e1e1", dark: "#62626b"),
        separatorLineHighlightPrimary: DynamicColorHex(light: "#e45d1c", dark: "#e45d1c"),
        separatorLineHighlightSecondary: DynamicColorHex(light: "#40b840", dark: "#40b840"),
        textPrimary: DynamicColorHex(light: "#252634", dark: "#ffffff"),
        textSecondary: DynamicColorHex(light: "#84858c", dark: "#a5a5a5"),
        textHeadlinePrimary: DynamicColorHex(light: "#000114", dark: "#ffffff"),
        textDisablePrimary: DynamicColorHex(light: "#777777", dark: "#616265"),
        textTopbar: DynamicColorHex(light: "#000114", dark: "#ffffff"),
        backgroundOdds: DynamicColorHex(light: "#e7e7e7", dark: "#353743"),
        textOdds: DynamicColorHex(light: "#131416", dark: "#ffffff"),
        textDisabledOdds: DynamicColorHex(light: "#b5b5b5", dark: "#74757e"),
        backgroundDisabledOdds: DynamicColorHex(light: "#ededed", dark: "#212125"),
        iconPrimary: DynamicColorHex(light: "#000114", dark: "#ffffff"),
        iconSecondary: DynamicColorHex(light: "#21222e", dark: "#bfc1ca"),
        inputBackground: DynamicColorHex(light: "#ffffff", dark: "#353743"),
        inputBackgroundSecondary: DynamicColorHex(light: "#e2e2e2", dark: "#181a22"),
        inputBorderActive: DynamicColorHex(light: "#ff6600", dark: "#ff6600"),
        inputError: DynamicColorHex(light: "#ed4f63", dark: "#ed4f63"),
        inputBackgroundDisable: DynamicColorHex(light: "#d3d3d3", dark: "#1a1a1f"),
        inputBorderDisabled: DynamicColorHex(light: "#e4e4e4", dark: "#5e5e60"),
        inputTextTitle: DynamicColorHex(light: "#3e3e3e", dark: "#ffffff"),
        inputText: DynamicColorHex(light: "#000114", dark: "#ffffff"),
        inputTextTitleDisable: DynamicColorHex(light: "#919191", dark: "#acacac"),
        inputTextDisable: DynamicColorHex(light: "#919191", dark: "#acacac"),
        navPills: DynamicColorHex(light: "#eaeaea", dark: "#353743"),
        pills: DynamicColorHex(light: "#ffffff", dark: "#181a22"),
        settingPill: DynamicColorHex(light: "#d5d5d5", dark: "#181a22"),
        backgroundDrop: DynamicColorHex(light: "#f5f5f5", dark: "#181a22"),
        borderDrop: DynamicColorHex(light: "#aaaaaa", dark: "#181a22"),
        navBannerActive: DynamicColorHex(light: "#ffffff", dark: "#ffffff"),
        navBanner: DynamicColorHex(light: "#8f8f8f", dark: "#8f8f8f"),
        buttonTextPrimary: DynamicColorHex(light: "#ffffff", dark: "#ffffff"),
        buttonTextSecondary: DynamicColorHex(light: "#ffffff", dark: "#ffffff"),
        buttonBackgroundPrimary: DynamicColorHex(light: "#40b840", dark: "#40b840"),
        buttonActiveHoverPrimary: DynamicColorHex(light: "#009e27", dark: "#009e27"),
        buttonDisablePrimary: DynamicColorHex(light: "#acacac", dark: "#acacac"),
        buttonTextDisablePrimary: DynamicColorHex(light: "#f4f4f4", dark: "#f4f4f4"),
        buttonBackgroundSecondary: DynamicColorHex(light: "#4a90e2", dark: "#4a90e2"),
        buttonActiveHoverSecondary: DynamicColorHex(light: "#404cff", dark: "#404cff"),
        buttonDisableSecondary: DynamicColorHex(light: "#a4c7f1", dark: "#6d86b3"),
        buttonTextDisableSecondary: DynamicColorHex(light: "#ffffff", dark: "#a4a4a4"),
        buttonBackgroundTertiary: DynamicColorHex(light: "#ff6600", dark: "#ff6600"),
        buttonTextTertiary: DynamicColorHex(light: "#ff6600", dark: "#ffffff"),
        buttonBorderTertiary: DynamicColorHex(light: "#ff6600", dark: "#ff6600"),
        buttonActiveHoverTertiary: DynamicColorHex(light: "#ff6600", dark: "#b24700"),
        buttonBorderDisableTertiary: DynamicColorHex(light: "#acacac", dark: "#a24100"),
        buttonTextDisableTertiary: DynamicColorHex(light: "#acacac", dark: "#f4f4f4"),
        alertError: DynamicColorHex(light: "#f9554d", dark: "#f9554d"),
        alertSuccess: DynamicColorHex(light: "#21ba45", dark: "#21ba45"),
        alertWarning: DynamicColorHex(light: "#ea7714", dark: "#ea7714"),
        myTicketsLostFaded: DynamicColorHex(light: "#ffbfb3", dark: "#651b0d"),
        myTicketsWon: DynamicColorHex(light: "#3db341", dark: "#3db341"),
        myTicketsWonFaded: DynamicColorHex(light: "#c5ffa8", dark: "#2c4420"),
        myTicketsOther: DynamicColorHex(light: "#d6a40e", dark: "#d6a40e"),
        myTicketsLost: DynamicColorHex(light: "#ab1111", dark: "#ab1111"),
        statsAway: DynamicColorHex(light: "#46c1a7", dark: "#46c1a7"),
        statsHome: DynamicColorHex(light: "#d99f00", dark: "#d99f00"),
        shadow: DynamicColorHex(light: "#ffffff", dark: "#181a22"),
        shadowMedium: DynamicColorHex(light: "#f1f1f1", dark: "#181a22"),
        shadowDarker: DynamicColorHex(light: "#ffffff", dark: "#0e0e11"),
        scroll: DynamicColorHex(light: "#dbdbdb", dark: "#4f5052"),
        bubblesPrimary: DynamicColorHex(light: "#41a3ff", dark: "#4a90e2"),
        menuSelector: DynamicColorHex(light: "#ff6600", dark: "#181a22"),
        menuSelectorHover: DynamicColorHex(light: "#ffffff", dark: "#ff6600"),
        allWhite: DynamicColorHex(light: "#ffffff", dark: "#ffffff"),
        allDark: DynamicColorHex(light: "#03061b", dark: "#03061b"),
        favorites: DynamicColorHex(light: "#fac125", dark: "#fac125"),
        liveTag: DynamicColorHex(light: "#ff6600", dark: "#ff6600"),
        textHeroCard: DynamicColorHex(light: "#ffffff", dark: "#ffffff"),
        textSecondaryHeroCard: DynamicColorHex(light: "#a4a6aa", dark: "#a4a6aa"),
        iconSportsHeroCard: DynamicColorHex(light: "#ffffff", dark: "#ffffff"),
        backgroundOddsHeroCard: DynamicColorHex(light: "#353743", dark: "#353743"),
        backgroundBetslip: DynamicColorHex(light: "#eeeeee", dark: "#353743"),
        addBetslip: DynamicColorHex(light: "#ffffff", dark: "#a4a6aa"),
        gameHeaderTextPrimary: DynamicColorHex(light: "#03061b", dark: "#ffffff"),
        gameHeaderTextSecondary: DynamicColorHex(light: "#898e9e", dark: "#a4a6aa"),
        gameHeader: DynamicColorHex(light: "#ffffff", dark: "#353743"),
        cardBorderLineGradient1: DynamicColorHex(light: "#ffffff", dark: "#353743"),
        cardBorderLineGradient2: DynamicColorHex(light: "#ffffff", dark: "#353743"),
        cardBorderLineGradient3: DynamicColorHex(light: "#ffffff", dark: "#353743"),
        boostedOddsGradient1: DynamicColorHex(light: "#ffffff", dark: "#353743"),
        boostedOddsGradient2: DynamicColorHex(light: "#ffffff", dark: "#353743"),
        backgroundGradientDark: DynamicColorHex(light: "#ff6600", dark: "#ff6600"),
        backgroundGradientLight: DynamicColorHex(light: "#ffb300", dark: "#ffb300"),
        backgroundGradient1: DynamicColorHex(light: "#ffffff", dark: "#181a22"),
        backgroundGradient2: DynamicColorHex(light: "#ffe5d3", dark: "#623314"),
        topBarGradient1: DynamicColorHex(light: "#ff6600", dark: "#ff6600"),
        topBarGradient2: DynamicColorHex(light: "#ff6600", dark: "#ff6600"),
        topBarGradient3: DynamicColorHex(light: "#ff6600", dark: "#ff6600"),
        liveBorder1: DynamicColorHex(light: "#ff6600", dark: "#ff6600"),
        liveBorder2: DynamicColorHex(light: "#ffb300", dark: "#ffb300"),
        liveBorder3: DynamicColorHex(light: "#ff6600", dark: "#ff6600"),
        messageGradient1: DynamicColorHex(light: "#ffffff", dark: "#181a22"),
        messageGradient2: DynamicColorHex(light: "#f8c3a0", dark: "#4f5052"),
        backgroundEmptySuccess1: DynamicColorHex(light: "#ffffff", dark: "#353743"),
        backgroundEmptySuccess2: DynamicColorHex(light: "#ffffff", dark: "#353743"),
        backgroundEmptySuccess3: DynamicColorHex(light: "#ffffff", dark: "#353743"),
        backgroundEmptyWinner1: DynamicColorHex(light: "#ffffff", dark: "#353743"),
        backgroundEmptyWinner2: DynamicColorHex(light: "#ffffff", dark: "#353743"),
        backgroundEmptyWinner3: DynamicColorHex(light: "#ffffff", dark: "#353743"),
        backgroundEmptyMessage1: DynamicColorHex(light: "#ffffff", dark: "#353743"),
        backgroundEmptyMessage2: DynamicColorHex(light: "#ffffff", dark: "#353743"),
        backgroundEmptyMessage3: DynamicColorHex(light: "#ffffff", dark: "#353743")
    )
}

public class StyleProvider {

    // MARK: - Color Storage
    private static var currentColors: StyleProviderColors = StyleProviderColors.defaultColors

    // MARK: - Dynamic Color Helper
    private static func createDynamicColor(from colorHex: DynamicColorHex) -> UIColor {
        return UIColor { traitCollection in
            let isDark = traitCollection.userInterfaceStyle == .dark
            let hexString = isDark ? colorHex.dark : colorHex.light
            return UIColor(hexString: hexString) ?? UIColor.systemGray
        }
    }

    public struct Color {
        // Highlights colors
        public static var highlightPrimaryContrast: UIColor {
            return createDynamicColor(from: currentColors.highlightPrimaryContrast)
        }
        public static var highlightSecondaryContrast: UIColor {
            return createDynamicColor(from: currentColors.highlightSecondaryContrast)
        }
        public static var highlightPrimary: UIColor {
            return createDynamicColor(from: currentColors.highlightPrimary)
        }
        public static var highlightSecondary: UIColor {
            return createDynamicColor(from: currentColors.highlightSecondary)
        }
        public static var highlightTertiary: UIColor {
            return createDynamicColor(from: currentColors.highlightTertiary)
        }

        // Backgrounds colors
        public static var backgroundPrimary: UIColor {
            return createDynamicColor(from: currentColors.backgroundPrimary)
        }
        public static var backgroundSecondary: UIColor {
            return createDynamicColor(from: currentColors.backgroundSecondary)
        }
        public static var backgroundTertiary: UIColor {
            return createDynamicColor(from: currentColors.backgroundTertiary)
        }
        public static var backgroundBorder: UIColor {
            return createDynamicColor(from: currentColors.backgroundBorder)
        }
        public static var backgroundCards: UIColor {
            return createDynamicColor(from: currentColors.backgroundCards)
        }
        public static var appBottomMenu: UIColor {
            return createDynamicColor(from: currentColors.appBottomMenu)
        }

        // Separators colors
        public static var separatorLine: UIColor {
            return createDynamicColor(from: currentColors.separatorLine)
        }
        public static var separatorLineSecondary: UIColor {
            return createDynamicColor(from: currentColors.separatorLineSecondary)
        }
        public static var separatorLineHighlightPrimary: UIColor {
            return createDynamicColor(from: currentColors.separatorLineHighlightPrimary)
        }
        public static var separatorLineHighlightSecondary: UIColor {
            return createDynamicColor(from: currentColors.separatorLineHighlightSecondary)
        }

        // Text colors
        public static var textPrimary: UIColor {
            return createDynamicColor(from: currentColors.textPrimary)
        }
        public static var textSecondary: UIColor {
            return createDynamicColor(from: currentColors.textSecondary)
        }
        public static var textHeadlinePrimary: UIColor {
            return createDynamicColor(from: currentColors.textHeadlinePrimary)
        }
        public static var textDisablePrimary: UIColor {
            return createDynamicColor(from: currentColors.textDisablePrimary)
        }
        public static var textTopbar: UIColor {
            return createDynamicColor(from: currentColors.textTopbar)
        }

        // Odds colors
        public static var backgroundOdds: UIColor {
            return createDynamicColor(from: currentColors.backgroundOdds)
        }
        public static var textOdds: UIColor {
            return createDynamicColor(from: currentColors.textOdds)
        }
        public static var textDisabledOdds: UIColor {
            return createDynamicColor(from: currentColors.textDisabledOdds)
        }
        public static var backgroundDisabledOdds: UIColor {
            return createDynamicColor(from: currentColors.backgroundDisabledOdds)
        }

        // Icons colors
        public static var iconPrimary: UIColor {
            return createDynamicColor(from: currentColors.iconPrimary)
        }
        public static var iconSecondary: UIColor {
            return createDynamicColor(from: currentColors.iconSecondary)
        }

        // Inputs colors
        public static var inputBackground: UIColor {
            return createDynamicColor(from: currentColors.inputBackground)
        }
        public static var inputBackgroundSecondary: UIColor {
            return createDynamicColor(from: currentColors.inputBackgroundSecondary)
        }
        public static var inputBorderActive: UIColor {
            return createDynamicColor(from: currentColors.inputBorderActive)
        }
        public static var inputError: UIColor {
            return createDynamicColor(from: currentColors.inputError)
        }
        public static var inputBackgroundDisable: UIColor {
            return createDynamicColor(from: currentColors.inputBackgroundDisable)
        }
        public static var inputBorderDisabled: UIColor {
            return createDynamicColor(from: currentColors.inputBorderDisabled)
        }
        public static var inputTextTitle: UIColor {
            return createDynamicColor(from: currentColors.inputTextTitle)
        }
        public static var inputText: UIColor {
            return createDynamicColor(from: currentColors.inputText)
        }
        public static var inputTextTitleDisable: UIColor {
            return createDynamicColor(from: currentColors.inputTextTitleDisable)
        }
        public static var inputTextDisable: UIColor {
            return createDynamicColor(from: currentColors.inputTextDisable)
        }

        // Nav Pills colors
        public static var navPills: UIColor {
            return createDynamicColor(from: currentColors.navPills)
        }
        public static var pills: UIColor {
            return createDynamicColor(from: currentColors.pills)
        }
        public static var settingPill: UIColor {
            return createDynamicColor(from: currentColors.settingPill)
        }

        // Drops colors
        public static var backgroundDrop: UIColor {
            return createDynamicColor(from: currentColors.backgroundDrop)
        }
        public static var borderDrop: UIColor {
            return createDynamicColor(from: currentColors.borderDrop)
        }

        // Nav Banner colors
        public static var navBannerActive: UIColor {
            return createDynamicColor(from: currentColors.navBannerActive)
        }
        public static var navBanner: UIColor {
            return createDynamicColor(from: currentColors.navBanner)
        }

        // Buttons colors
        public static var buttonTextPrimary: UIColor {
            return createDynamicColor(from: currentColors.buttonTextPrimary)
        }
        public static var buttonTextSecondary: UIColor {
            return createDynamicColor(from: currentColors.buttonTextSecondary)
        }
        public static var buttonBackgroundPrimary: UIColor {
            return createDynamicColor(from: currentColors.buttonBackgroundPrimary)
        }
        public static var buttonActiveHoverPrimary: UIColor {
            return createDynamicColor(from: currentColors.buttonActiveHoverPrimary)
        }
        public static var buttonDisablePrimary: UIColor {
            return createDynamicColor(from: currentColors.buttonDisablePrimary)
        }
        public static var buttonTextDisablePrimary: UIColor {
            return createDynamicColor(from: currentColors.buttonTextDisablePrimary)
        }
        public static var buttonBackgroundSecondary: UIColor {
            return createDynamicColor(from: currentColors.buttonBackgroundSecondary)
        }
        public static var buttonActiveHoverSecondary: UIColor {
            return createDynamicColor(from: currentColors.buttonActiveHoverSecondary)
        }
        public static var buttonDisableSecondary: UIColor {
            return createDynamicColor(from: currentColors.buttonDisableSecondary)
        }
        public static var buttonTextDisableSecondary: UIColor {
            return createDynamicColor(from: currentColors.buttonTextDisableSecondary)
        }
        public static var buttonBackgroundTertiary: UIColor {
            return createDynamicColor(from: currentColors.buttonBackgroundTertiary)
        }
        public static var buttonTextTertiary: UIColor {
            return createDynamicColor(from: currentColors.buttonTextTertiary)
        }
        public static var buttonBorderTertiary: UIColor {
            return createDynamicColor(from: currentColors.buttonBorderTertiary)
        }
        public static var buttonActiveHoverTertiary: UIColor {
            return createDynamicColor(from: currentColors.buttonActiveHoverTertiary)
        }
        public static var buttonBorderDisableTertiary: UIColor {
            return createDynamicColor(from: currentColors.buttonBorderDisableTertiary)
        }
        public static var buttonTextDisableTertiary: UIColor {
            return createDynamicColor(from: currentColors.buttonTextDisableTertiary)
        }

        // Alerts colors
        public static var alertError: UIColor {
            return createDynamicColor(from: currentColors.alertError)
        }
        public static var alertSuccess: UIColor {
            return createDynamicColor(from: currentColors.alertSuccess)
        }
        public static var alertWarning: UIColor {
            return createDynamicColor(from: currentColors.alertWarning)
        }

        // Tickets colors
        public static var myTicketsLostFaded: UIColor {
            return createDynamicColor(from: currentColors.myTicketsLostFaded)
        }
        public static var myTicketsWon: UIColor {
            return createDynamicColor(from: currentColors.myTicketsWon)
        }
        public static var myTicketsWonFaded: UIColor {
            return createDynamicColor(from: currentColors.myTicketsWonFaded)
        }
        public static var myTicketsOther: UIColor {
            return createDynamicColor(from: currentColors.myTicketsOther)
        }
        public static var myTicketsLost: UIColor {
            return createDynamicColor(from: currentColors.myTicketsLost)
        }

        // Stats colors
        public static var statsAway: UIColor {
            return createDynamicColor(from: currentColors.statsAway)
        }
        public static var statsHome: UIColor {
            return createDynamicColor(from: currentColors.statsHome)
        }

        // Shadow colors
        public static var shadow: UIColor {
            return createDynamicColor(from: currentColors.shadow)
        }
        public static var shadowMedium: UIColor {
            return createDynamicColor(from: currentColors.shadowMedium)
        }
        public static var shadowDarker: UIColor {
            return createDynamicColor(from: currentColors.shadowDarker)
        }

        // Misc colors
        public static var scroll: UIColor {
            return createDynamicColor(from: currentColors.scroll)
        }
        public static var bubblesPrimary: UIColor {
            return createDynamicColor(from: currentColors.bubblesPrimary)
        }
        public static var menuSelector: UIColor {
            return createDynamicColor(from: currentColors.menuSelector)
        }
        public static var menuSelectorHover: UIColor {
            return createDynamicColor(from: currentColors.menuSelectorHover)
        }
        public static var allWhite: UIColor {
            return createDynamicColor(from: currentColors.allWhite)
        }
        public static var allDark: UIColor {
            return createDynamicColor(from: currentColors.allDark)
        }
        public static var favorites: UIColor {
            return createDynamicColor(from: currentColors.favorites)
        }
        public static var liveTag: UIColor {
            return createDynamicColor(from: currentColors.liveTag)
        }

        // Hero cards colors
        public static var textHeroCard: UIColor {
            return createDynamicColor(from: currentColors.textHeroCard)
        }
        public static var textSecondaryHeroCard: UIColor {
            return createDynamicColor(from: currentColors.textSecondaryHeroCard)
        }
        public static var iconSportsHeroCard: UIColor {
            return createDynamicColor(from: currentColors.iconSportsHeroCard)
        }
        public static var backgroundOddsHeroCard: UIColor {
            return createDynamicColor(from: currentColors.backgroundOddsHeroCard)
        }

        // Betslip colors
        public static var backgroundBetslip: UIColor {
            return createDynamicColor(from: currentColors.backgroundBetslip)
        }
        public static var addBetslip: UIColor {
            return createDynamicColor(from: currentColors.addBetslip)
        }

        // Game Header colors
        public static var gameHeaderTextPrimary: UIColor {
            return createDynamicColor(from: currentColors.gameHeaderTextPrimary)
        }
        public static var gameHeaderTextSecondary: UIColor {
            return createDynamicColor(from: currentColors.gameHeaderTextSecondary)
        }
        public static var gameHeader: UIColor {
            return createDynamicColor(from: currentColors.gameHeader)
        }

        // Gradients colors
        public static var cardBorderLineGradient1: UIColor {
            return createDynamicColor(from: currentColors.cardBorderLineGradient1)
        }
        public static var cardBorderLineGradient2: UIColor {
            return createDynamicColor(from: currentColors.cardBorderLineGradient2)
        }
        public static var cardBorderLineGradient3: UIColor {
            return createDynamicColor(from: currentColors.cardBorderLineGradient3)
        }
        public static var boostedOddsGradient1: UIColor {
            return createDynamicColor(from: currentColors.boostedOddsGradient1)
        }
        public static var boostedOddsGradient2: UIColor {
            return createDynamicColor(from: currentColors.boostedOddsGradient2)
        }
        public static var backgroundGradientDark: UIColor {
            return createDynamicColor(from: currentColors.backgroundGradientDark)
        }
        public static var backgroundGradientLight: UIColor {
            return createDynamicColor(from: currentColors.backgroundGradientLight)
        }
        public static var backgroundGradient1: UIColor {
            return createDynamicColor(from: currentColors.backgroundGradient1)
        }
        public static var backgroundGradient2: UIColor {
            return createDynamicColor(from: currentColors.backgroundGradient2)
        }
        public static var topBarGradient1: UIColor {
            return createDynamicColor(from: currentColors.topBarGradient1)
        }
        public static var topBarGradient2: UIColor {
            return createDynamicColor(from: currentColors.topBarGradient2)
        }
        public static var topBarGradient3: UIColor {
            return createDynamicColor(from: currentColors.topBarGradient3)
        }
        public static var liveBorder1: UIColor {
            return createDynamicColor(from: currentColors.liveBorder1)
        }
        public static var liveBorder2: UIColor {
            return createDynamicColor(from: currentColors.liveBorder2)
        }
        public static var liveBorder3: UIColor {
            return createDynamicColor(from: currentColors.liveBorder3)
        }
        public static var messageGradient1: UIColor {
            return createDynamicColor(from: currentColors.messageGradient1)
        }
        public static var messageGradient2: UIColor {
            return createDynamicColor(from: currentColors.messageGradient2)
        }
        public static var backgroundEmptySuccess1: UIColor {
            return createDynamicColor(from: currentColors.backgroundEmptySuccess1)
        }
        public static var backgroundEmptySuccess2: UIColor {
            return createDynamicColor(from: currentColors.backgroundEmptySuccess2)
        }
        public static var backgroundEmptySuccess3: UIColor {
            return createDynamicColor(from: currentColors.backgroundEmptySuccess3)
        }
        public static var backgroundEmptyWinner1: UIColor {
            return createDynamicColor(from: currentColors.backgroundEmptyWinner1)
        }
        public static var backgroundEmptyWinner2: UIColor {
            return createDynamicColor(from: currentColors.backgroundEmptyWinner2)
        }
        public static var backgroundEmptyWinner3: UIColor {
            return createDynamicColor(from: currentColors.backgroundEmptyWinner3)
        }
        public static var backgroundEmptyMessage1: UIColor {
            return createDynamicColor(from: currentColors.backgroundEmptyMessage1)
        }
        public static var backgroundEmptyMessage2: UIColor {
            return createDynamicColor(from: currentColors.backgroundEmptyMessage2)
        }
        public static var backgroundEmptyMessage3: UIColor {
            return createDynamicColor(from: currentColors.backgroundEmptyMessage3)
        }

        // Legacy color mappings for backward compatibility with existing GomaUI components
        public static var primaryColor: UIColor { highlightPrimary }
        public static var secondaryColor: UIColor { highlightSecondary }
        public static var accentColor: UIColor { highlightTertiary }
        public static var backgroundColor: UIColor { backgroundPrimary }
        public static var textColor: UIColor { textPrimary }
        public static var contrastTextColor: UIColor { highlightPrimaryContrast }
        public static var toolbarBackgroundColor: UIColor { highlightPrimary }
        public static var walletBackgroundColor: UIColor { highlightPrimary }
        public static var successColor: UIColor { alertSuccess }
        public static var semiTransparentColor: UIColor {
            return UIColor { traitCollection in
                let isDark = traitCollection.userInterfaceStyle == .dark
                return UIColor(white: isDark ? 0.0 : 1.0, alpha: 0.2)
            }
        }
        public static var matchTimeColor: UIColor { liveTag }
    }

    // MARK: - Customization Methods
    public static func customize(colors: StyleProviderColors) {
        currentColors = colors
    }

    public static func customizeColors(
        highlightPrimaryContrast: DynamicColorHex? = nil,
        highlightSecondaryContrast: DynamicColorHex? = nil,
        highlightPrimary: DynamicColorHex? = nil,
        highlightSecondary: DynamicColorHex? = nil,
        highlightTertiary: DynamicColorHex? = nil,
        backgroundPrimary: DynamicColorHex? = nil,
        backgroundSecondary: DynamicColorHex? = nil,
        backgroundTertiary: DynamicColorHex? = nil,
        backgroundBorder: DynamicColorHex? = nil,
        backgroundCards: DynamicColorHex? = nil,
        appBottomMenu: DynamicColorHex? = nil,
        separatorLine: DynamicColorHex? = nil,
        separatorLineSecondary: DynamicColorHex? = nil,
        separatorLineHighlightPrimary: DynamicColorHex? = nil,
        separatorLineHighlightSecondary: DynamicColorHex? = nil,
        textPrimary: DynamicColorHex? = nil,
        textSecondary: DynamicColorHex? = nil,
        textHeadlinePrimary: DynamicColorHex? = nil,
        textDisablePrimary: DynamicColorHex? = nil,
        textTopbar: DynamicColorHex? = nil,
        backgroundOdds: DynamicColorHex? = nil,
        textOdds: DynamicColorHex? = nil,
        textDisabledOdds: DynamicColorHex? = nil,
        backgroundDisabledOdds: DynamicColorHex? = nil,
        iconPrimary: DynamicColorHex? = nil,
        iconSecondary: DynamicColorHex? = nil,
        inputBackground: DynamicColorHex? = nil,
        inputBackgroundSecondary: DynamicColorHex? = nil,
        inputBorderActive: DynamicColorHex? = nil,
        inputError: DynamicColorHex? = nil,
        inputBackgroundDisable: DynamicColorHex? = nil,
        inputBorderDisabled: DynamicColorHex? = nil,
        inputTextTitle: DynamicColorHex? = nil,
        inputText: DynamicColorHex? = nil,
        inputTextTitleDisable: DynamicColorHex? = nil,
        inputTextDisable: DynamicColorHex? = nil,
        navPills: DynamicColorHex? = nil,
        pills: DynamicColorHex? = nil,
        settingPill: DynamicColorHex? = nil,
        backgroundDrop: DynamicColorHex? = nil,
        borderDrop: DynamicColorHex? = nil,
        navBannerActive: DynamicColorHex? = nil,
        navBanner: DynamicColorHex? = nil,
        buttonTextPrimary: DynamicColorHex? = nil,
        buttonTextSecondary: DynamicColorHex? = nil,
        buttonBackgroundPrimary: DynamicColorHex? = nil,
        buttonActiveHoverPrimary: DynamicColorHex? = nil,
        buttonDisablePrimary: DynamicColorHex? = nil,
        buttonTextDisablePrimary: DynamicColorHex? = nil,
        buttonBackgroundSecondary: DynamicColorHex? = nil,
        buttonActiveHoverSecondary: DynamicColorHex? = nil,
        buttonDisableSecondary: DynamicColorHex? = nil,
        buttonTextDisableSecondary: DynamicColorHex? = nil,
        buttonBackgroundTertiary: DynamicColorHex? = nil,
        buttonTextTertiary: DynamicColorHex? = nil,
        buttonBorderTertiary: DynamicColorHex? = nil,
        buttonActiveHoverTertiary: DynamicColorHex? = nil,
        buttonBorderDisableTertiary: DynamicColorHex? = nil,
        buttonTextDisableTertiary: DynamicColorHex? = nil,
        alertError: DynamicColorHex? = nil,
        alertSuccess: DynamicColorHex? = nil,
        alertWarning: DynamicColorHex? = nil,
        myTicketsLostFaded: DynamicColorHex? = nil,
        myTicketsWon: DynamicColorHex? = nil,
        myTicketsWonFaded: DynamicColorHex? = nil,
        myTicketsOther: DynamicColorHex? = nil,
        myTicketsLost: DynamicColorHex? = nil,
        statsAway: DynamicColorHex? = nil,
        statsHome: DynamicColorHex? = nil,
        shadow: DynamicColorHex? = nil,
        shadowMedium: DynamicColorHex? = nil,
        shadowDarker: DynamicColorHex? = nil,
        scroll: DynamicColorHex? = nil,
        bubblesPrimary: DynamicColorHex? = nil,
        menuSelector: DynamicColorHex? = nil,
        menuSelectorHover: DynamicColorHex? = nil,
        allWhite: DynamicColorHex? = nil,
        allDark: DynamicColorHex? = nil,
        favorites: DynamicColorHex? = nil,
        liveTag: DynamicColorHex? = nil,
        textHeroCard: DynamicColorHex? = nil,
        textSecondaryHeroCard: DynamicColorHex? = nil,
        iconSportsHeroCard: DynamicColorHex? = nil,
        backgroundOddsHeroCard: DynamicColorHex? = nil,
        backgroundBetslip: DynamicColorHex? = nil,
        addBetslip: DynamicColorHex? = nil,
        gameHeaderTextPrimary: DynamicColorHex? = nil,
        gameHeaderTextSecondary: DynamicColorHex? = nil,
        gameHeader: DynamicColorHex? = nil,
        cardBorderLineGradient1: DynamicColorHex? = nil,
        cardBorderLineGradient2: DynamicColorHex? = nil,
        cardBorderLineGradient3: DynamicColorHex? = nil,
        boostedOddsGradient1: DynamicColorHex? = nil,
        boostedOddsGradient2: DynamicColorHex? = nil,
        backgroundGradientDark: DynamicColorHex? = nil,
        backgroundGradientLight: DynamicColorHex? = nil,
        backgroundGradient1: DynamicColorHex? = nil,
        backgroundGradient2: DynamicColorHex? = nil,
        topBarGradient1: DynamicColorHex? = nil,
        topBarGradient2: DynamicColorHex? = nil,
        topBarGradient3: DynamicColorHex? = nil,
        liveBorder1: DynamicColorHex? = nil,
        liveBorder2: DynamicColorHex? = nil,
        liveBorder3: DynamicColorHex? = nil,
        messageGradient1: DynamicColorHex? = nil,
        messageGradient2: DynamicColorHex? = nil,
        backgroundEmptySuccess1: DynamicColorHex? = nil,
        backgroundEmptySuccess2: DynamicColorHex? = nil,
        backgroundEmptySuccess3: DynamicColorHex? = nil,
        backgroundEmptyWinner1: DynamicColorHex? = nil,
        backgroundEmptyWinner2: DynamicColorHex? = nil,
        backgroundEmptyWinner3: DynamicColorHex? = nil,
        backgroundEmptyMessage1: DynamicColorHex? = nil,
        backgroundEmptyMessage2: DynamicColorHex? = nil,
        backgroundEmptyMessage3: DynamicColorHex? = nil
    ) {
        currentColors = StyleProviderColors(
            highlightPrimaryContrast: highlightPrimaryContrast ?? currentColors.highlightPrimaryContrast,
            highlightSecondaryContrast: highlightSecondaryContrast ?? currentColors.highlightSecondaryContrast,
            highlightPrimary: highlightPrimary ?? currentColors.highlightPrimary,
            highlightSecondary: highlightSecondary ?? currentColors.highlightSecondary,
            highlightTertiary: highlightTertiary ?? currentColors.highlightTertiary,
            backgroundPrimary: backgroundPrimary ?? currentColors.backgroundPrimary,
            backgroundSecondary: backgroundSecondary ?? currentColors.backgroundSecondary,
            backgroundTertiary: backgroundTertiary ?? currentColors.backgroundTertiary,
            backgroundBorder: backgroundBorder ?? currentColors.backgroundBorder,
            backgroundCards: backgroundCards ?? currentColors.backgroundCards,
            appBottomMenu: appBottomMenu ?? currentColors.appBottomMenu,
            separatorLine: separatorLine ?? currentColors.separatorLine,
            separatorLineSecondary: separatorLineSecondary ?? currentColors.separatorLineSecondary,
            separatorLineHighlightPrimary: separatorLineHighlightPrimary ?? currentColors.separatorLineHighlightPrimary,
            separatorLineHighlightSecondary: separatorLineHighlightSecondary ?? currentColors.separatorLineHighlightSecondary,
            textPrimary: textPrimary ?? currentColors.textPrimary,
            textSecondary: textSecondary ?? currentColors.textSecondary,
            textHeadlinePrimary: textHeadlinePrimary ?? currentColors.textHeadlinePrimary,
            textDisablePrimary: textDisablePrimary ?? currentColors.textDisablePrimary,
            textTopbar: textTopbar ?? currentColors.textTopbar,
            backgroundOdds: backgroundOdds ?? currentColors.backgroundOdds,
            textOdds: textOdds ?? currentColors.textOdds,
            textDisabledOdds: textDisabledOdds ?? currentColors.textDisabledOdds,
            backgroundDisabledOdds: backgroundDisabledOdds ?? currentColors.backgroundDisabledOdds,
            iconPrimary: iconPrimary ?? currentColors.iconPrimary,
            iconSecondary: iconSecondary ?? currentColors.iconSecondary,
            inputBackground: inputBackground ?? currentColors.inputBackground,
            inputBackgroundSecondary: inputBackgroundSecondary ?? currentColors.inputBackgroundSecondary,
            inputBorderActive: inputBorderActive ?? currentColors.inputBorderActive,
            inputError: inputError ?? currentColors.inputError,
            inputBackgroundDisable: inputBackgroundDisable ?? currentColors.inputBackgroundDisable,
            inputBorderDisabled: inputBorderDisabled ?? currentColors.inputBorderDisabled,
            inputTextTitle: inputTextTitle ?? currentColors.inputTextTitle,
            inputText: inputText ?? currentColors.inputText,
            inputTextTitleDisable: inputTextTitleDisable ?? currentColors.inputTextTitleDisable,
            inputTextDisable: inputTextDisable ?? currentColors.inputTextDisable,
            navPills: navPills ?? currentColors.navPills,
            pills: pills ?? currentColors.pills,
            settingPill: settingPill ?? currentColors.settingPill,
            backgroundDrop: backgroundDrop ?? currentColors.backgroundDrop,
            borderDrop: borderDrop ?? currentColors.borderDrop,
            navBannerActive: navBannerActive ?? currentColors.navBannerActive,
            navBanner: navBanner ?? currentColors.navBanner,
            buttonTextPrimary: buttonTextPrimary ?? currentColors.buttonTextPrimary,
            buttonTextSecondary: buttonTextSecondary ?? currentColors.buttonTextSecondary,
            buttonBackgroundPrimary: buttonBackgroundPrimary ?? currentColors.buttonBackgroundPrimary,
            buttonActiveHoverPrimary: buttonActiveHoverPrimary ?? currentColors.buttonActiveHoverPrimary,
            buttonDisablePrimary: buttonDisablePrimary ?? currentColors.buttonDisablePrimary,
            buttonTextDisablePrimary: buttonTextDisablePrimary ?? currentColors.buttonTextDisablePrimary,
            buttonBackgroundSecondary: buttonBackgroundSecondary ?? currentColors.buttonBackgroundSecondary,
            buttonActiveHoverSecondary: buttonActiveHoverSecondary ?? currentColors.buttonActiveHoverSecondary,
            buttonDisableSecondary: buttonDisableSecondary ?? currentColors.buttonDisableSecondary,
            buttonTextDisableSecondary: buttonTextDisableSecondary ?? currentColors.buttonTextDisableSecondary,
            buttonBackgroundTertiary: buttonBackgroundTertiary ?? currentColors.buttonBackgroundTertiary,
            buttonTextTertiary: buttonTextTertiary ?? currentColors.buttonTextTertiary,
            buttonBorderTertiary: buttonBorderTertiary ?? currentColors.buttonBorderTertiary,
            buttonActiveHoverTertiary: buttonActiveHoverTertiary ?? currentColors.buttonActiveHoverTertiary,
            buttonBorderDisableTertiary: buttonBorderDisableTertiary ?? currentColors.buttonBorderDisableTertiary,
            buttonTextDisableTertiary: buttonTextDisableTertiary ?? currentColors.buttonTextDisableTertiary,
            alertError: alertError ?? currentColors.alertError,
            alertSuccess: alertSuccess ?? currentColors.alertSuccess,
            alertWarning: alertWarning ?? currentColors.alertWarning,
            myTicketsLostFaded: myTicketsLostFaded ?? currentColors.myTicketsLostFaded,
            myTicketsWon: myTicketsWon ?? currentColors.myTicketsWon,
            myTicketsWonFaded: myTicketsWonFaded ?? currentColors.myTicketsWonFaded,
            myTicketsOther: myTicketsOther ?? currentColors.myTicketsOther,
            myTicketsLost: myTicketsLost ?? currentColors.myTicketsLost,
            statsAway: statsAway ?? currentColors.statsAway,
            statsHome: statsHome ?? currentColors.statsHome,
            shadow: shadow ?? currentColors.shadow,
            shadowMedium: shadowMedium ?? currentColors.shadowMedium,
            shadowDarker: shadowDarker ?? currentColors.shadowDarker,
            scroll: scroll ?? currentColors.scroll,
            bubblesPrimary: bubblesPrimary ?? currentColors.bubblesPrimary,
            menuSelector: menuSelector ?? currentColors.menuSelector,
            menuSelectorHover: menuSelectorHover ?? currentColors.menuSelectorHover,
            allWhite: allWhite ?? currentColors.allWhite,
            allDark: allDark ?? currentColors.allDark,
            favorites: favorites ?? currentColors.favorites,
            liveTag: liveTag ?? currentColors.liveTag,
            textHeroCard: textHeroCard ?? currentColors.textHeroCard,
            textSecondaryHeroCard: textSecondaryHeroCard ?? currentColors.textSecondaryHeroCard,
            iconSportsHeroCard: iconSportsHeroCard ?? currentColors.iconSportsHeroCard,
            backgroundOddsHeroCard: backgroundOddsHeroCard ?? currentColors.backgroundOddsHeroCard,
            backgroundBetslip: backgroundBetslip ?? currentColors.backgroundBetslip,
            addBetslip: addBetslip ?? currentColors.addBetslip,
            gameHeaderTextPrimary: gameHeaderTextPrimary ?? currentColors.gameHeaderTextPrimary,
            gameHeaderTextSecondary: gameHeaderTextSecondary ?? currentColors.gameHeaderTextSecondary,
            gameHeader: gameHeader ?? currentColors.gameHeader,
            cardBorderLineGradient1: cardBorderLineGradient1 ?? currentColors.cardBorderLineGradient1,
            cardBorderLineGradient2: cardBorderLineGradient2 ?? currentColors.cardBorderLineGradient2,
            cardBorderLineGradient3: cardBorderLineGradient3 ?? currentColors.cardBorderLineGradient3,
            boostedOddsGradient1: boostedOddsGradient1 ?? currentColors.boostedOddsGradient1,
            boostedOddsGradient2: boostedOddsGradient2 ?? currentColors.boostedOddsGradient2,
            backgroundGradientDark: backgroundGradientDark ?? currentColors.backgroundGradientDark,
            backgroundGradientLight: backgroundGradientLight ?? currentColors.backgroundGradientLight,
            backgroundGradient1: backgroundGradient1 ?? currentColors.backgroundGradient1,
            backgroundGradient2: backgroundGradient2 ?? currentColors.backgroundGradient2,
            topBarGradient1: topBarGradient1 ?? currentColors.topBarGradient1,
            topBarGradient2: topBarGradient2 ?? currentColors.topBarGradient2,
            topBarGradient3: topBarGradient3 ?? currentColors.topBarGradient3,
            liveBorder1: liveBorder1 ?? currentColors.liveBorder1,
            liveBorder2: liveBorder2 ?? currentColors.liveBorder2,
            liveBorder3: liveBorder3 ?? currentColors.liveBorder3,
            messageGradient1: messageGradient1 ?? currentColors.messageGradient1,
            messageGradient2: messageGradient2 ?? currentColors.messageGradient2,
            backgroundEmptySuccess1: backgroundEmptySuccess1 ?? currentColors.backgroundEmptySuccess1,
            backgroundEmptySuccess2: backgroundEmptySuccess2 ?? currentColors.backgroundEmptySuccess2,
            backgroundEmptySuccess3: backgroundEmptySuccess3 ?? currentColors.backgroundEmptySuccess3,
            backgroundEmptyWinner1: backgroundEmptyWinner1 ?? currentColors.backgroundEmptyWinner1,
            backgroundEmptyWinner2: backgroundEmptyWinner2 ?? currentColors.backgroundEmptyWinner2,
            backgroundEmptyWinner3: backgroundEmptyWinner3 ?? currentColors.backgroundEmptyWinner3,
            backgroundEmptyMessage1: backgroundEmptyMessage1 ?? currentColors.backgroundEmptyMessage1,
            backgroundEmptyMessage2: backgroundEmptyMessage2 ?? currentColors.backgroundEmptyMessage2,
            backgroundEmptyMessage3: backgroundEmptyMessage3 ?? currentColors.backgroundEmptyMessage3
        )
    }
}

extension StyleProvider {

    // MARK: - Fonts
    public enum FontType: String {
        case thin
        case light
        case regular
        case medium
        case bold
        case semibold
        case heavy
    }

    // Font provider type
    public typealias FontProvider = (FontType, CGFloat) -> UIFont

    // Default implementation using system fonts
    private static var fontProvider: FontProvider = { type, size in
        switch type {
        case .thin:
            return .systemFont(ofSize: size, weight: .thin)
        case .light:
            return .systemFont(ofSize: size, weight: .light)
        case .regular:
            return .systemFont(ofSize: size, weight: .regular)
        case .medium:
            return .systemFont(ofSize: size, weight: .medium)
        case .semibold:
            return .systemFont(ofSize: size, weight: .semibold)
        case .bold:
            return .systemFont(ofSize: size, weight: .bold)
        case .heavy:
            return .systemFont(ofSize: size, weight: .heavy)
        }
    }

    // Method to customize the font provider
    public static func setFontProvider(_ provider: @escaping FontProvider) {
        fontProvider = provider
    }

    // Font access method
    public static func fontWith(type: FontType = .regular, size: CGFloat = 17.0) -> UIFont {
        return fontProvider(type, size)
    }
}


// MARK: - Color Extensions
extension UIColor {
    public convenience init(hex: Int) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }

    public convenience init?(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanHexString = hexString.replacingOccurrences(of: "#", with: "")

        guard cleanHexString.count == 6,
              let hexValue = Int(cleanHexString, radix: 16) else {
            return nil
        }

        self.init(hex: hexValue)
    }
}
