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
        static let mainTintColor: UIColor = UIColor(named: "mainTintColor")! // This will read the tintColor on the Client ThemeColor.xcasset

        static let mainBackgroundColor: UIColor = UIColor(named: "mainBackgroundColor")!

        static let secondaryBackgroundColor: UIColor = UIColor(named: "secondaryBackgroundColor")!

        static let separatorLineColor: UIColor = UIColor(named: "separatorLineColor")!

        static let fadeOutHeadingColor: UIColor = UIColor(named: "fadeOutHeadingColor")!

        static let primaryButtonNormalColor = UIColor(named: "primaryButtonNormalColor")!

        static let primaryButtonPressedColor = UIColor(named: "primaryButtonPressedColor")!

        static let contentAlphaBackgroundColor = UIColor(named: "contentAlphaBackgroundColor")!

        static let contentBackgroundColor = UIColor(named: "contentBackgroundColor")!

        static let clearButtonAction: UIColor = UIColor(named: "clearButtonActionColor")

        static let headingMain: UIColor = UIColor(named: "headingMainColor")

        static let error: UIColor = UIColor(named: "alertErrorColor")

        static let success: UIColor = UIColor(named: "alertSuccessColor")

        static let headerTextFieldGray: UIColor = UIColor(named: "headerTextFieldGrayColor")

        // Duplicado
        static let buttonMain: UIColor = UIColor(named: "mainTintColor")

        // Duplicado
        static let subtitleGray: UIColor = UIColor(named: "fadeOutHeadingColor")

        // Duplicado
        static let backgroundDarkFade: UIColor = UIColor(named: "contentBackgroundColor")

        // Duplicado
        static let backgroundDarkModal: UIColor = UIColor(named: "secondaryBackgroundColor")

        // Duplicado
        static let alertError: UIColor = UIColor(named: "alertErrorColor")

        // Duplicado
        static let backgroundDarkProfile: UIColor = UIColor(named: "mainBackgroundColor")

    }

}

