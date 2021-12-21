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
        
        static let mainTint: UIColor = UIColor(named: "mainTintColor")!
        
        static let mainBackground = UIColor(named: "mainBackgroundColor")!
        static let secondaryBackground = UIColor(named: "secondaryBackgroundColor")!
        static let tertiaryBackground = UIColor(named: "tertiaryBackgroundColor")!

        static let contentBackground = UIColor(named: "contentBackgroundColor")!
        
        static let separatorLine = UIColor(named: "separatorLineColor")!
        static let fadeOutHeading = UIColor(named: "fadeOutHeadingColor")!
        static let fadedGrayLine = UIColor(named: "fadedGrayLineColor")!

        static let headingMain = UIColor(named: "headingMainColor")!
        static let headingSecondary = UIColor(named: "headingSecondaryColor")!
        static let headingDisabled = UIColor(named: "headingDisabledColor")!

        static let headerTextField = UIColor(named: "headerTextFieldGrayColor")!
        
        static let primaryButtonNormal = UIColor(named: "primaryButtonNormalColor")!
        static let primaryButtonPressed = UIColor(named: "primaryButtonPressedColor")!
        static let contentAlphaBackground = UIColor(named: "contentAlphaBackgroundColor")!
        static let clearButtonAction = UIColor(named: "clearButtonActionColor")!
        
        static let alertError = UIColor(named: "alertErrorColor")!
        static let alertSuccess = UIColor(named: "alertSuccessColor")!


        static let statusWon = UIColor(named: "statusWon")!
        static let statusDraw = UIColor(named: "statusDraw")!
        static let statusLoss = UIColor(named: "statusLoss")!


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
