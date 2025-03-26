//
//  Colors.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/07/2021.
//

import UIKit

extension UIColor {

    // Colors file is localed on each Client "ThemeColors.xcassets" file
    struct App {

        static let backgroundPrimary: UIColor = UIColor(named: "backgroundPrimary")!
        static let backgroundSecondary = UIColor(named: "backgroundSecondary")!
        static let backgroundTertiary = UIColor(named: "backgroundTertiary")!
        static let backgroundBorder = UIColor(named: "backgroundBorder")!

        static let backgroundCards = UIColor(named: "backgroundCards")!
        static var backgroundHeader: UIColor {
            return UIColor(named: "backgroundHeader") ?? Self.backgroundPrimary
        }

        static let textPrimary = UIColor(named: "textPrimary")!
        static let textHeadlinePrimary = UIColor(named: "textHeadlinePrimary")!
        static let textDisablePrimary = UIColor(named: "textDisablePrimary")!
        static let textSecondary = UIColor(named: "textSecondary")!

        static let backgroundOdds = UIColor(named: "backgroundOdds")!
        static let backgroundDisabledOdds = UIColor(named: "backgroundDisabledOdds")!

        static let separatorLine = UIColor(named: "separatorLine")!

        static let scroll = UIColor(named: "scroll")!

        static var pillBackground: UIColor {
            return UIColor(named: "pillBackground") ?? Self.backgroundPrimary
        }
        static var pillNavigation: UIColor {
            return UIColor(named: "pillNavigation") ?? Self.backgroundSecondary
        }
        static var pillSettings: UIColor {
            return UIColor(named: "pillSettings") ?? Self.backgroundTertiary
        }

        static let inputBackground = UIColor(named: "inputBackground")!
        static let inputBorderActive = UIColor(named: "inputBorderActive")!
        static let inputBorderDisabled = UIColor(named: "inputBorderDisabled")!
        static let inputBackgroundSecondary = UIColor(named: "inputBackgroundSecondary")!
        static let inputTextTitle = UIColor(named: "inputTextTitle")!
        static let inputText = UIColor(named: "inputText")!
        static let inputError = UIColor(named: "inputError")!

        static var inputTextDisable: UIColor {
            return UIColor(named: "inputTextDisable") ?? Self.inputText
        }

        static var iconPrimary: UIColor {
            return UIColor(named: "iconPrimary") ?? Self.textPrimary
        }
        static var iconSecondary: UIColor {
            return UIColor(named: "iconSecondary") ?? Self.textSecondary
        }

        static let backgroundDrop: UIColor = UIColor(named: "backgroundDrop")!
        static let borderDrop = UIColor(named: "borderDrop")!

        static let highlightPrimary = UIColor(named: "highlightPrimary")!
        static let highlightSecondary = UIColor(named: "highlightSecondary")!

        static let buttonTextPrimary = UIColor(named: "buttonTextPrimary")!
        static let buttonBackgroundPrimary = UIColor(named: "buttonBackgroundPrimary")!
        static let buttonActiveHoverPrimary = UIColor(named: "buttonActiveHoverPrimary")!
        static let buttonDisablePrimary = UIColor(named: "buttonDisablePrimary")!
        static let buttonTextDisablePrimary = UIColor(named: "buttonTextDisablePrimary")!

        static let buttonBackgroundSecondary = UIColor(named: "buttonBackgroundSecondary")!
        static let buttonActiveHoverSecondary = UIColor(named: "buttonActiveHoverSecondary")!

        static let buttonActiveHoverTertiary = UIColor(named: "buttonActiveHoverTertiary")!

        static let buttonBorderTertiary = UIColor(named: "buttonBorderTertiary")!

        static let bubblesPrimary = UIColor(named: "bubblesPrimary")!

        static let alertError = UIColor(named: "alertError")!
        static let alertSuccess = UIColor(named: "alertSuccess")!
        static let alertWarning = UIColor(named: "alertWarning")!

        static let myTicketsLost = UIColor(named: "myTicketsLost")!
        static let myTicketsLostFaded = UIColor(named: "myTicketsLostFaded")!

        static let myTicketsWon = UIColor(named: "myTicketsWon")!
        static let myTicketsWonFaded = UIColor(named: "myTicketsWonFaded")!

        static let myTicketsOther = UIColor(named: "myTicketsOther")!

        static let backgroundDarker = UIColor(named: "backgroundDarker")!

        static let statsHome = UIColor(named: "statsHome")!
        static let statsAway = UIColor(named: "statsAway")!

        static let highlightPrimaryContrast = UIColor(named: "highlightPrimaryContrast")!
        static var highlightSecondaryContrast: UIColor {
            return UIColor(named: "highlightSecondaryContrast") ?? Self.highlightPrimaryContrast
        }

        static var backgroundGradient1: UIColor {
            return UIColor(named: "backgroundGradient1") ?? Self.backgroundPrimary
        }
        static var backgroundGradient2: UIColor {
            return UIColor(named: "backgroundGradient2") ?? Self.backgroundPrimary
        }

        static var headerGradient1: UIColor {
            return UIColor(named: "headerGradient1") ?? Self.backgroundPrimary
        }
        static var headerGradient2: UIColor {
            return UIColor(named: "headerGradient2") ?? Self.backgroundPrimary
        }
        static var headerGradient3: UIColor {
            return UIColor(named: "headerGradient3") ?? Self.backgroundPrimary
        }

        static var cardBorderLineGradient1: UIColor {
            return UIColor(named: "cardBorderLineGradient1") ?? Self.backgroundSecondary
        }
        static var cardBorderLineGradient2: UIColor {
            return UIColor(named: "cardBorderLineGradient2") ?? Self.backgroundSecondary
        }
        static var cardBorderLineGradient3: UIColor {
            return UIColor(named: "cardBorderLineGradient3") ?? Self.backgroundSecondary
        }

        static var gameHeader: UIColor {
            return UIColor(named: "gameHeader") ?? Self.backgroundSecondary
        }

        static var separatorLineHighlightPrimary: UIColor {
            return UIColor(named: "separatorLineHighlightPrimary") ?? Self.separatorLine
        }

        static var separatorLineHighlightSecondary: UIColor {
            return UIColor(named: "separatorLineHighlightSecondary") ?? Self.separatorLine
        }

        static var separatorLineSecondary: UIColor {
            return UIColor(named: "separatorLineSecondary") ?? Self.separatorLine
        }

        static var navBanner: UIColor {
            return UIColor(named: "navBanner") ?? Self.backgroundPrimary
        }

        static var navBannerActive: UIColor {
            return UIColor(named: "navBannerActive") ?? Self.backgroundSecondary
        }

        static var backgroundHeaderGradient1: UIColor {
            return UIColor(named: "backgroundHeaderGradient1") ?? Self.headerGradient1
        }

        static var backgroundHeaderGradient2: UIColor {
            return UIColor(named: "backgroundHeaderGradient2") ?? Self.headerGradient2
        }

        static var highlightTertiary: UIColor {
            return UIColor(named: "highlightTertiary") ?? Self.alertSuccess
        }

        static var liveBorderGradient1: UIColor {
            return UIColor(named: "liveBorderGradient1") ?? Self.highlightPrimary
        }
        static var liveBorderGradient2: UIColor {
            return UIColor(named: "liveBorderGradient2") ?? Self.highlightPrimary
        }
        static var liveBorderGradient3: UIColor {
            return UIColor(named: "liveBorderGradient3") ?? Self.highlightPrimary
        }

        static var textHeroCard: UIColor {
            return UIColor(named: "textHeroCard") ?? Self.textPrimary
        }

        static var textSecondaryHeroCard: UIColor {
            return UIColor(named: "textSecondaryHeroCard") ?? Self.textSecondary
        }

        static var backgroundOddsHeroCard: UIColor {
            return UIColor(named: "backgroundOddsHeroCard") ?? Self.backgroundOdds
        }

        static var iconSportsHeroCard: UIColor {
            return UIColor(named: "iconSportsHeroCard") ?? Self.textPrimary
        }

        static func validateThemeColors() -> [UIColor] {
            return [
                Self.backgroundPrimary,
                Self.backgroundSecondary,
                Self.backgroundTertiary,
                Self.backgroundBorder,
                Self.backgroundCards,
                Self.backgroundHeader,
                Self.textPrimary,
                Self.textHeadlinePrimary,
                Self.textDisablePrimary,
                Self.textSecondary,
                Self.backgroundOdds,
                Self.backgroundDisabledOdds,
                Self.separatorLine,
                Self.scroll,
                Self.pillBackground,
                Self.pillNavigation,
                Self.pillSettings,
                Self.inputBackground,
                Self.inputBorderActive,
                Self.inputBorderDisabled,
                Self.inputBackgroundSecondary,
                Self.inputTextTitle,
                Self.inputText,
                Self.inputError,
                Self.inputTextDisable,
                Self.iconPrimary,
                Self.iconSecondary,
                Self.backgroundDrop,
                Self.borderDrop,
                Self.highlightPrimary,
                Self.highlightSecondary,
                Self.buttonTextPrimary,
                Self.buttonBackgroundPrimary,
                Self.buttonActiveHoverPrimary,
                Self.buttonDisablePrimary,
                Self.buttonTextDisablePrimary,
                Self.buttonBackgroundSecondary,
                Self.buttonActiveHoverSecondary,
                Self.buttonActiveHoverTertiary,
                Self.buttonBorderTertiary,
                Self.bubblesPrimary,
                Self.alertError,
                Self.alertSuccess,
                Self.alertWarning,
                Self.myTicketsLost,
                Self.myTicketsLostFaded,
                Self.myTicketsWon,
                Self.myTicketsWonFaded,
                Self.myTicketsOther,
                Self.backgroundDarker,
                Self.statsHome,
                Self.statsAway,
                Self.highlightPrimaryContrast,
                Self.highlightSecondaryContrast,
                Self.backgroundGradient1,
                Self.backgroundGradient2,
                Self.headerGradient1,
                Self.headerGradient2,
                Self.headerGradient3,
                Self.cardBorderLineGradient1,
                Self.cardBorderLineGradient2,
                Self.cardBorderLineGradient3,
                Self.gameHeader,
                Self.separatorLineHighlightPrimary,
                Self.separatorLineHighlightSecondary,
                Self.separatorLineSecondary,
                Self.navBanner,
                Self.navBannerActive,
                Self.backgroundHeaderGradient1,
                Self.backgroundHeaderGradient2,
                Self.highlightTertiary,
                Self.liveBorderGradient1,
                Self.liveBorderGradient2,
                Self.liveBorderGradient3,
                Self.textHeroCard,
                Self.textSecondaryHeroCard,
                Self.backgroundOddsHeroCard,
                Self.iconSportsHeroCard,
            ]
        }
    }

}

// #047DFF ->  mainTintColor -

// #232730 ->  mainBackgroundColor -
// #313543 ->  secondaryBackgroundColor -
// #1D1F25 ->  contentBackgroundColor -
// #1A1C22 ->  contentAlphaBackgroundColor - (80%)

// #747E8F ->  headerTextFieldGrayColor -
// #FFFFFF ->  headingMainColor - (white)
// #6E7888 ->  fadeOutHeadingColor -

// #047DFF ->  primaryButtonNormalColor -
// #1974EB ->  primaryButtonPressedColor -
// #1C7CFF ->  clearButtonActionColor -

// #4A5468 ->  separatorLineColor -

// #E0243B ->  alertErrorColor -
// #7BC23E ->  alertSuccessColor -
