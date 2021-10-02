//
//  ListTypeCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 01/10/2021.
//

import UIKit

class ListTypeCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var selectionHighlightView: UIView!
    @IBOutlet private weak var labelView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!

    var selectedColor: UIColor = .white
    var normalColor: UIColor = .black

    override var bounds: CGRect {
        didSet {
            self.layoutIfNeeded()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.selectionHighlightView.layer.cornerRadius = selectionHighlightView.frame.size.height / 2
        self.labelView.layer.cornerRadius = labelView.frame.size.height / 2
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.normalColor = UIColor.App.secundaryBackgroundColor
        self.selectedColor = UIColor.App.mainTintColor

        self.selectionHighlightView.backgroundColor = self.selectedColor
        self.labelView.backgroundColor = self.normalColor
    }

    func setupWithTitle(_ title: String) {
        self.titleLabel.text = title
    }

    func setSelected(_ selected: Bool) {
        self.isSelected = selected
        if self.isSelected {
            self.selectionHighlightView.backgroundColor = self.selectedColor
            self.labelView.backgroundColor = self.normalColor
        }
        else {
            self.selectionHighlightView.backgroundColor = self.normalColor
            self.labelView.backgroundColor = self.normalColor
        }
    }
}
