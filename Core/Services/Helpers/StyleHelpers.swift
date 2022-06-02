//
//  StyleHelpers.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/11/2021.
//

import UIKit

struct StyleHelper {

    static func styleButton(button: UIButton) {
        button.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        button.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        button.setTitleColor(UIColor.App.buttonTextDisablePrimary.withAlphaComponent(0.39), for: .disabled)

        button.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        button.setBackgroundColor(UIColor.App.buttonBackgroundSecondary, for: .highlighted)

        button.layer.cornerRadius = CornerRadius.button
        button.layer.masksToBounds = true
        button.backgroundColor = .clear
    }

    static func styleInfoButton(button: UIButton) {
        button.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        button.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        button.setTitleColor(UIColor.App.buttonTextDisablePrimary, for: .disabled)

        button.setBackgroundColor(UIColor.App.backgroundSecondary, for: .normal)
        button.setBackgroundColor(UIColor.App.buttonBackgroundSecondary, for: .highlighted)

        button.layer.cornerRadius = CornerRadius.button
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.App.textPrimary.cgColor
        button.layer.masksToBounds = true
        button.backgroundColor = .clear
    }

    static func cardsStyleHeight() -> CGFloat {
        var height = MatchWidgetCollectionViewCell.normalCellHeight
        switch UserDefaults.standard.cardsStyle {
        case .small:
            height = MatchWidgetCollectionViewCell.smallCellHeight
        case .normal:
            height = MatchWidgetCollectionViewCell.normalCellHeight
        }
        return height
    }
}
