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
        static let secundaryBackgroundColor: UIColor = UIColor(named: "secundaryBackgroundColor")!
        static let separatorLineColor: UIColor = UIColor(named: "separatorLineColor")!


        static let fadeOutHeadingColor: UIColor = UIColor(named: "fadeOutHeadingColor")!

        static let primaryButtonNormalColor = UIColor(named: "primaryButtonNormalColor")!
        static let primaryButtonPressedColor = UIColor(named: "primaryButtonPressedColor")!

        static let contentAlphaBackgroundColor = UIColor(named: "contentAlphaBackgroundColor")!
        static let contentBackgroundColor = UIColor(named: "contentBackgroundColor")!

        static let clearButtonAction: UIColor = UIColor(red: 0.11, green: 0.49, blue: 1.00, alpha: 1)

        static let headingMain: UIColor = UIColor.white // Placeholder
        static let buttonMain: UIColor = UIColor(red: 4/255, green: 125/255, blue: 255/255, alpha: 1.0)

        static let subtitleGray: UIColor = UIColor(red: 114/255, green: 118/255, blue: 141/255, alpha: 1.0)
        static let backgroundDarkFade: UIColor = UIColor(red: 29/255, green: 31/255, blue: 38/255, alpha: 0.95)
        static let backgroundDarkModal: UIColor = UIColor(red: 49/255, green: 53/255, blue: 67/255, alpha: 1.0)
        static let headerTextFieldGray: UIColor = UIColor(red: 116/255, green: 126/255, blue: 143/255, alpha: 1.0)

        static let alertError: UIColor = UIColor(red: 0.88, green: 0.14, blue: 0.23, alpha: 1)

        static let backgroundDarkProfile: UIColor = UIColor(red: 36/255, green: 39/255, blue: 49/255, alpha: 1.0)

        static let error: UIColor = UIColor(red: 225/255, green: 36/255, blue: 59/255, alpha: 1.0)
        static let success: UIColor = UIColor(red: 123/255, green: 194/255, blue: 62/255, alpha: 1.0)
    }

}
