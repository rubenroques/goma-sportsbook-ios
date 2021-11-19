//
//  StyleHelpers.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/11/2021.
//

import UIKit

struct StyleHelper {

    static func styleButton(button: UIButton) {
        button.setTitleColor(UIColor.App.headingMain, for: .normal)
        button.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)
        button.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.39), for: .disabled)

        button.setBackgroundColor(UIColor.App.primaryButtonNormal, for: .normal)
        button.setBackgroundColor(UIColor.App.primaryButtonPressed, for: .highlighted)

        button.layer.cornerRadius = CornerRadius.button
        button.layer.masksToBounds = true
        button.backgroundColor = .clear
    }

}
