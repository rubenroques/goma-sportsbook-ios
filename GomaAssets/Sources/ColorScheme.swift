//
//  ColorScheme.swift
//  Theming
//
//  Created by Ruben Roques on 15/10/2024.
//

import UIKit

public protocol ColorScheme {

    var backgroundPrimary: UIColor { get }
    var backgroundSecondary: UIColor { get }
    var backgroundTertiary: UIColor { get }
    var backgroundBorder: UIColor { get }

    var backgroundCards: UIColor { get }
    var backgroundHeader: UIColor { get }

    var textPrimary: UIColor { get }
    var textHeadlinePrimary: UIColor { get }
    var textDisablePrimary: UIColor { get }
    var textSecondary: UIColor { get }

    var backgroundOdds: UIColor { get }
    var backgroundDisabledOdds: UIColor { get }

    var separatorLine: UIColor { get }

    var scroll: UIColor { get }

    var pillBackground: UIColor { get }
    var pillNavigation: UIColor { get }
    var pillSettings: UIColor { get }

    var inputBorderActive: UIColor { get }
    var inputBorderDisabled: UIColor { get }
    var inputBackgroundSecondary: UIColor { get }
    var inputTextTitle: UIColor { get }
    var inputText: UIColor { get }
    var inputError: UIColor { get }
    var inputTextDisable: UIColor { get }

    var iconPrimary: UIColor { get }
    var iconSecondary: UIColor { get }

    var backgroundDrop: UIColor { get }
    var borderDrop: UIColor { get }

    var highlightPrimary: UIColor { get }
    var highlightSecondary: UIColor { get }

    var buttonTextPrimary: UIColor { get }
    var buttonBackgroundPrimary: UIColor { get }
    var buttonActiveHoverPrimary: UIColor { get }
    var buttonDisablePrimary: UIColor { get }
    var buttonTextDisablePrimary: UIColor { get }

    var buttonBackgroundSecondary: UIColor { get }
    var buttonActiveHoverSecondary: UIColor { get }

    var buttonActiveHoverTertiary: UIColor { get }

    var buttonBorderTertiary: UIColor { get }

    var bubblesPrimary: UIColor { get }

    var alertError: UIColor { get }
    var alertSuccess: UIColor { get }
    var alertWarning: UIColor { get }

    var myTicketsLost: UIColor { get }
    var myTicketsLostFaded: UIColor { get }

    var myTicketsWon: UIColor { get }
    var myTicketsWonFaded: UIColor { get }

    var myTicketsOther: UIColor { get }

    var backgroundDarker: UIColor { get }

    var statsHome: UIColor { get }
    var statsAway: UIColor { get }

    var highlightPrimaryContrast: UIColor { get }
    var highlightSecondaryContrast: UIColor { get }

    var backgroundGradient1: UIColor { get }
    var backgroundGradient2: UIColor { get }

    var headerGradient1: UIColor { get }
    var headerGradient2: UIColor { get }
    var headerGradient3: UIColor { get }

    var cardBorderLineGradient1: UIColor { get }
    var cardBorderLineGradient2: UIColor { get }
    var cardBorderLineGradient3: UIColor { get }

    var gameHeader: UIColor { get }

    var separatorLineHighlightPrimary: UIColor { get }

    var separatorLineHighlightSecondary: UIColor { get }

    var separatorLineSecondary: UIColor { get }

    var navBanner: UIColor { get }

    var navBannerActive: UIColor { get }

    var backgroundHeaderGradient1: UIColor { get }

    var backgroundHeaderGradient2: UIColor { get }

    var highlightTertiary: UIColor { get }

    var liveBorderGradient1: UIColor { get }
    var liveBorderGradient2: UIColor { get }
    var liveBorderGradient3: UIColor { get }

    var textHeroCard: UIColor { get }

    var textSecondaryHeroCard: UIColor { get }

    var backgroundOddsHeroCard: UIColor { get }

    var iconSportsHeroCard: UIColor { get }
}
