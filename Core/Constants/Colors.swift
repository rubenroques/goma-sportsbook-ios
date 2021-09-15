//
//  Colors.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/07/2021.
//

import UIKit

extension UIColor {

    // Colors file is localed on each Client "ThemeColors.xcassets" file
    struct Core {
        static let tint: UIColor = UIColor(named: "tintColor")! // This will read the tintColor on the Client ThemeColor.xcasset
        static let headingMain: UIColor = UIColor.white // Placeholder
        static let buttonMain: UIColor = UIColor(red: 4/255, green: 125/255, blue: 255/255, alpha: 1.0)
        static let subtitleGray: UIColor = UIColor(red: 114/255, green: 118/255, blue: 141/255, alpha: 1.0)
        static let backgroundDarkFade: UIColor = UIColor(red: 29/255, green: 31/255, blue: 38/255, alpha: 0.95)
        static let backgroundDarkModal: UIColor = UIColor(red: 49/255, green: 53/255, blue: 67/255, alpha: 1.0)

        static let primaryButtonNormalColor = UIColor(named: "primaryButtonNormalColor")!
        static let primaryButtonPressedColor = UIColor(named: "primaryButtonPressedColor")!
    }

}
