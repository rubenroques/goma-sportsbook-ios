//
//  CheckboxButton.swift
//  Sportsbook
//
//  Created by André Lascas on 13/10/2021.
//

import UIKit

class CheckboxButton: UIButton {

    var didTapCheckbox: ((Bool) -> Void)?

    var isChecked: Bool = false {
        didSet {
            if isChecked {
                self.setImage(UIImage(named: "active_toggle_icon"), for: .normal)
                self.backgroundColor = UIColor.App2.highlightPrimary
                self.layer.borderColor = UIColor.App2.highlightPrimary.cgColor
            }
            else {
                self.setImage(nil, for: .normal)
                self.backgroundColor = UIColor.App2.backgroundSecondary
                self.layer.borderColor = UIColor.App2.separatorLine.cgColor
            }
        }
    }

    override func awakeFromNib() {
        self.addTarget(self, action: #selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)

        self.backgroundColor = UIColor.App2.buttonTextPrimary

        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.App2.backgroundSecondary.cgColor
        self.layer.cornerRadius = 4

        self.tintColor = UIColor.App2.buttonTextPrimary

    }

    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
            didTapCheckbox?(isChecked)
        }
    }
}
