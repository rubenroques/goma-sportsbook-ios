//
//  CheckboxToggleView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/10/2021.
//

import UIKit
import SwiftUI

class CheckboxToggleView: UIView, NibLoadable {

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var roundCornerView: UIView!

    var unselectedColor: UIColor = UIColor.systemGray {
        didSet {
            self.drawView()
        }
    }

    var selectedColor: UIColor = UIColor.systemBlue {
        didSet {
            self.drawView()
        }
    }

    var isSelected: Bool = false {
        didSet {
            self.drawView()
        }
    }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        loadFromNib()
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromNib()
        commonInit()
    }

    func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear

        self.roundCornerView.layer.cornerRadius = 3
        self.iconImageView.image = UIImage(named: "active_toggle_icon")

        self.drawView()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 20, height: 20)
    }

    func drawView() {
        if self.isSelected {
            self.iconImageView.isHidden = false
            self.roundCornerView.backgroundColor = selectedColor

            self.roundCornerView.layer.borderWidth = 0.0
        }
        else {
            self.iconImageView.isHidden = true
            self.roundCornerView.backgroundColor = .clear

            self.roundCornerView.layer.borderWidth = 1.5
            self.roundCornerView.layer.borderColor = self.unselectedColor.cgColor
        }
    }
}
