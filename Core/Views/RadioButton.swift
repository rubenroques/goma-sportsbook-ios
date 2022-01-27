//
//  RadioButton.swift
//  Sportsbook
//
//  Created by André Lascas on 13/10/2021.
//

import UIKit

class RadioButton: UIButton {
    var alternateButton: [RadioButton]?

    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.width/2
        self.layer.borderWidth = 2.0
        // self.layer.masksToBounds = true
        self.isSelected = false
    }

    func unselectAlternateButtons() {
        if alternateButton != nil {
            self.isSelected = true

            for aButton: RadioButton in alternateButton! {
                aButton.isSelected = false
            }
        }
        else {
            toggleButton()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        unselectAlternateButtons()
        super.touchesBegan(touches, with: event)
    }

    func toggleButton() {
        self.isSelected = !isSelected
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.layer.borderColor = UIColor.App2.highlightPrimary.cgColor
                self.backgroundColor = UIColor.App2.highlightPrimary
                self.setImage(UIImage(named: "white_dot_icon"), for: .normal)
            }
            else {
                self.layer.borderColor = UIColor.App2.separatorLine.cgColor
                self.backgroundColor = UIColor.App2.backgroundSecondary
                self.setImage(nil, for: .normal)
            }
        }
    }
}
