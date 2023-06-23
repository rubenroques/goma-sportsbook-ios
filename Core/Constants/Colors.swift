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
        static let inputTextTitle = UIColor(named: "inputTextTitle")!
        static let inputText = UIColor(named: "inputText")!
        static let inputError = UIColor(named: "inputError")!
        static let inputTextDisable = UIColor(named: "inputTextDisable")

        static var iconPrimary: UIColor {
            return UIColor(named: "iconPrimary") ?? Self.textPrimary
        }
        static let iconSecondary = UIColor(named: "iconSecondary")!

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

        static let buttonActiveHoverTertiary = UIColor(named: "buttonActiveHoverTertiary")

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
