//
//  DefaultColorScheme.swift
//  Theming
//
//  Created by Ruben Roques on 15/10/2024.
//

import Foundation
import UIKit

public struct DefaultColorScheme: ColorScheme {

    public static let shared = DefaultColorScheme()

    private init() {}

    public var backgroundPrimary: UIColor = UIColor(named: "backgroundPrimary", in: Bundle.module, compatibleWith: nil)!
    public var backgroundSecondary: UIColor = UIColor(named: "backgroundSecondary", in: Bundle.module, compatibleWith: nil)!
    public var backgroundTertiary: UIColor = UIColor(named: "backgroundTertiary", in: Bundle.module, compatibleWith: nil)!
    public var backgroundBorder: UIColor = UIColor(named: "backgroundBorder", in: Bundle.module, compatibleWith: nil)!

    public var backgroundCards: UIColor = UIColor(named: "backgroundCards", in: Bundle.module, compatibleWith: nil)!
    public var backgroundHeader: UIColor {
        return UIColor(named: "backgroundHeader", in: Bundle.module, compatibleWith: nil) ?? self.backgroundPrimary
    }

    public var textPrimary: UIColor = UIColor(named: "textPrimary", in: Bundle.module, compatibleWith: nil)!
    public var textHeadlinePrimary: UIColor = UIColor(named: "textHeadlinePrimary", in: Bundle.module, compatibleWith: nil)!
    public var textDisablePrimary: UIColor = UIColor(named: "textDisablePrimary", in: Bundle.module, compatibleWith: nil)!
    public var textSecondary: UIColor = UIColor(named: "textSecondary", in: Bundle.module, compatibleWith: nil)!

    public var backgroundOdds: UIColor = UIColor(named: "backgroundOdds", in: Bundle.module, compatibleWith: nil)!
    public var backgroundDisabledOdds: UIColor = UIColor(named: "backgroundDisabledOdds", in: Bundle.module, compatibleWith: nil)!

    public var separatorLine: UIColor = UIColor(named: "separatorLine", in: Bundle.module, compatibleWith: nil)!

    public var scroll: UIColor = UIColor(named: "scroll", in: Bundle.module, compatibleWith: nil)!

    public var pillBackground: UIColor {
        return UIColor(named: "pillBackground", in: Bundle.module, compatibleWith: nil) ?? self.backgroundPrimary
    }
    public var pillNavigation: UIColor {
        return UIColor(named: "pillNavigation", in: Bundle.module, compatibleWith: nil) ?? self.backgroundSecondary
    }
    public var pillSettings: UIColor {
        return UIColor(named: "pillSettings", in: Bundle.module, compatibleWith: nil) ?? self.backgroundTertiary
    }

    public var inputBackground: UIColor = UIColor(named: "inputBackground", in: Bundle.module, compatibleWith: nil)!
    public var inputBorderActive: UIColor = UIColor(named: "inputBorderActive", in: Bundle.module, compatibleWith: nil)!
    public var inputBorderDisabled: UIColor = UIColor(named: "inputBorderDisabled", in: Bundle.module, compatibleWith: nil)!
    public var inputBackgroundSecondary: UIColor = UIColor(named: "inputBackgroundSecondary", in: Bundle.module, compatibleWith: nil)!
    public var inputTextTitle: UIColor = UIColor(named: "inputTextTitle", in: Bundle.module, compatibleWith: nil)!
    public var inputText: UIColor = UIColor(named: "inputText", in: Bundle.module, compatibleWith: nil)!
    public var inputError: UIColor = UIColor(named: "inputError", in: Bundle.module, compatibleWith: nil)!
    public var inputTextDisable: UIColor {
        UIColor(named: "inputTextDisable", in: Bundle.module, compatibleWith: nil) ?? self.inputText
    }

    public var iconPrimary: UIColor {
        return UIColor(named: "iconPrimary", in: Bundle.module, compatibleWith: nil) ?? self.textPrimary
    }
    public var iconSecondary: UIColor = UIColor(named: "iconSecondary", in: Bundle.module, compatibleWith: nil)!

    public var backgroundDrop: UIColor = UIColor(named: "backgroundDrop", in: Bundle.module, compatibleWith: nil)!
    public var borderDrop: UIColor = UIColor(named: "borderDrop", in: Bundle.module, compatibleWith: nil)!

    public var highlightPrimary: UIColor = UIColor(named: "highlightPrimary", in: Bundle.module, compatibleWith: nil)!
    public var highlightSecondary: UIColor = UIColor(named: "highlightSecondary", in: Bundle.module, compatibleWith: nil)!

    public var buttonTextPrimary: UIColor = UIColor(named: "buttonTextPrimary", in: Bundle.module, compatibleWith: nil)!
    public var buttonBackgroundPrimary: UIColor = UIColor(named: "buttonBackgroundPrimary", in: Bundle.module, compatibleWith: nil)!
    public var buttonActiveHoverPrimary: UIColor = UIColor(named: "buttonActiveHoverPrimary", in: Bundle.module, compatibleWith: nil)!
    public var buttonDisablePrimary: UIColor = UIColor(named: "buttonDisablePrimary", in: Bundle.module, compatibleWith: nil)!
    public var buttonTextDisablePrimary: UIColor = UIColor(named: "buttonTextDisablePrimary", in: Bundle.module, compatibleWith: nil)!

    public var buttonBackgroundSecondary: UIColor = UIColor(named: "buttonBackgroundSecondary", in: Bundle.module, compatibleWith: nil)!
    public var buttonActiveHoverSecondary: UIColor = UIColor(named: "buttonActiveHoverSecondary", in: Bundle.module, compatibleWith: nil)!

    public var buttonActiveHoverTertiary: UIColor = UIColor(named: "buttonActiveHoverTertiary", in: Bundle.module, compatibleWith: nil)!

    public var buttonBorderTertiary: UIColor = UIColor(named: "buttonBorderTertiary", in: Bundle.module, compatibleWith: nil)!

    public var bubblesPrimary: UIColor = UIColor(named: "bubblesPrimary", in: Bundle.module, compatibleWith: nil)!

    public var alertError: UIColor = UIColor(named: "alertError", in: Bundle.module, compatibleWith: nil)!
    public var alertSuccess: UIColor = UIColor(named: "alertSuccess", in: Bundle.module, compatibleWith: nil)!
    public var alertWarning: UIColor = UIColor(named: "alertWarning", in: Bundle.module, compatibleWith: nil)!

    public var myTicketsLost: UIColor = UIColor(named: "myTicketsLost", in: Bundle.module, compatibleWith: nil)!
    public var myTicketsLostFaded: UIColor = UIColor(named: "myTicketsLostFaded", in: Bundle.module, compatibleWith: nil)!

    public var myTicketsWon: UIColor = UIColor(named: "myTicketsWon", in: Bundle.module, compatibleWith: nil)!
    public var myTicketsWonFaded: UIColor = UIColor(named: "myTicketsWonFaded", in: Bundle.module, compatibleWith: nil)!

    public var myTicketsOther: UIColor = UIColor(named: "myTicketsOther", in: Bundle.module, compatibleWith: nil)!

    public var backgroundDarker: UIColor = UIColor(named: "backgroundDarker", in: Bundle.module, compatibleWith: nil)!

    public var statsHome: UIColor = UIColor(named: "statsHome", in: Bundle.module, compatibleWith: nil)!
    public var statsAway: UIColor = UIColor(named: "statsAway", in: Bundle.module, compatibleWith: nil)!

    public var highlightPrimaryContrast: UIColor = UIColor(named: "highlightPrimaryContrast", in: Bundle.module, compatibleWith: nil)!
    public var highlightSecondaryContrast: UIColor {
        return UIColor(named: "highlightSecondaryContrast", in: Bundle.module, compatibleWith: nil) ?? self.highlightPrimaryContrast
    }

    public var backgroundGradient1: UIColor {
        return UIColor(named: "backgroundGradient1", in: Bundle.module, compatibleWith: nil) ?? self.backgroundPrimary
    }
    public var backgroundGradient2: UIColor {
        return UIColor(named: "backgroundGradient2", in: Bundle.module, compatibleWith: nil) ?? self.backgroundPrimary
    }

    public var headerGradient1: UIColor {
        return UIColor(named: "headerGradient1", in: Bundle.module, compatibleWith: nil) ?? self.backgroundPrimary
    }
    public var headerGradient2: UIColor {
        return UIColor(named: "headerGradient2", in: Bundle.module, compatibleWith: nil) ?? self.backgroundPrimary
    }
    public var headerGradient3: UIColor {
        return UIColor(named: "headerGradient3", in: Bundle.module, compatibleWith: nil) ?? self.backgroundPrimary
    }

    public var cardBorderLineGradient1: UIColor {
        return UIColor(named: "cardBorderLineGradient1", in: Bundle.module, compatibleWith: nil) ?? self.backgroundSecondary
    }
    public var cardBorderLineGradient2: UIColor {
        return UIColor(named: "cardBorderLineGradient2", in: Bundle.module, compatibleWith: nil) ?? self.backgroundSecondary
    }
    public var cardBorderLineGradient3: UIColor {
        return UIColor(named: "cardBorderLineGradient3", in: Bundle.module, compatibleWith: nil) ?? self.backgroundSecondary
    }

    public var gameHeader: UIColor {
        return UIColor(named: "gameHeader", in: Bundle.module, compatibleWith: nil) ?? self.backgroundSecondary
    }

    public var separatorLineHighlightPrimary: UIColor {
        return UIColor(named: "separatorLineHighlightPrimary", in: Bundle.module, compatibleWith: nil) ?? self.separatorLine
    }

    public var separatorLineHighlightSecondary: UIColor {
        return UIColor(named: "separatorLineHighlightSecondary", in: Bundle.module, compatibleWith: nil) ?? self.separatorLine
    }

    public var separatorLineSecondary: UIColor {
        return UIColor(named: "separatorLineSecondary", in: Bundle.module, compatibleWith: nil) ?? self.separatorLine
    }

    public var navBanner: UIColor {
        return UIColor(named: "navBanner", in: Bundle.module, compatibleWith: nil) ?? self.backgroundPrimary
    }

    public var navBannerActive: UIColor {
        return UIColor(named: "navBannerActive", in: Bundle.module, compatibleWith: nil) ?? self.backgroundSecondary
    }

    public var backgroundHeaderGradient1: UIColor {
        return UIColor(named: "backgroundHeaderGradient1", in: Bundle.module, compatibleWith: nil) ?? self.headerGradient1
    }

    public var backgroundHeaderGradient2: UIColor {
        return UIColor(named: "backgroundHeaderGradient2", in: Bundle.module, compatibleWith: nil) ?? self.headerGradient2
    }

    public var highlightTertiary: UIColor {
        return UIColor(named: "highlightTertiary", in: Bundle.module, compatibleWith: nil) ?? self.alertSuccess
    }

    public var liveBorderGradient1: UIColor {
        return UIColor(named: "liveColor1", in: Bundle.module, compatibleWith: nil) ?? self.highlightPrimary
    }
    public var liveBorderGradient2: UIColor {
        return UIColor(named: "liveColor2", in: Bundle.module, compatibleWith: nil) ?? self.highlightPrimary
    }
    public var liveBorderGradient3: UIColor {
        return UIColor(named: "liveColor3", in: Bundle.module, compatibleWith: nil) ?? self.highlightPrimary
    }

    public var textHeroCard: UIColor {
        return UIColor(named: "textHeroCard", in: Bundle.module, compatibleWith: nil) ?? self.textHeroCard
    }

    public var textSecondaryHeroCard: UIColor {
        return UIColor(named: "textSecondaryHeroCard", in: Bundle.module, compatibleWith: nil) ?? self.textSecondaryHeroCard
    }

    public var backgroundOddsHeroCard: UIColor {
        return UIColor(named: "backgroundOddsHeroCard", in: Bundle.module, compatibleWith: nil) ?? self.backgroundOddsHeroCard
    }

    public var iconSportsHeroCard: UIColor {
        return UIColor(named: "iconSportsHeroCard", in: Bundle.module, compatibleWith: nil) ?? self.iconSportsHeroCard
    }


}

// Extension to make it easier to use the default scheme
public extension ColorScheme where Self == DefaultColorScheme {
    var `default`: ColorScheme { DefaultColorScheme.shared }
}
