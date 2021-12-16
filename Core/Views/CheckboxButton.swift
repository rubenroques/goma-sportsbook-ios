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
                self.backgroundColor = UIColor.App.mainTint
                self.layer.borderColor = UIColor.App.mainTint.cgColor
            }
            else {
                self.setImage(nil, for: .normal)
                self.backgroundColor = UIColor.App.secondaryBackground
                self.layer.borderColor = UIColor.App.fadedGrayLine.cgColor
            }
        }
    }

    override func awakeFromNib() {
        self.addTarget(self, action: #selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)

        self.backgroundColor = UIColor.App.secondaryBackground

        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.App.fadedGrayLine.cgColor
        self.layer.cornerRadius = 4

        self.tintColor = UIColor.App.headingMain

    }

    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
            didTapCheckbox?(isChecked)
        }
    }
}
