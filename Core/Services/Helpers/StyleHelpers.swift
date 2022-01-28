//
//  StyleHelpers.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/11/2021.
//

import UIKit

struct StyleHelper {

    static func styleButton(button: UIButton) {
        button.setTitleColor(UIColor.App2.buttonTextPrimary, for: .normal)
        button.setTitleColor(UIColor.App2.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        button.setTitleColor(UIColor.App2.buttonTextDisablePrimary.withAlphaComponent(0.39), for: .disabled)

        button.setBackgroundColor(UIColor.App2.buttonBackgroundPrimary, for: .normal)
        button.setBackgroundColor(UIColor.App2.buttonBackgroundSecondary, for: .highlighted)

        button.layer.cornerRadius = CornerRadius.button
        button.layer.masksToBounds = true
        button.backgroundColor = .clear
    }

}
