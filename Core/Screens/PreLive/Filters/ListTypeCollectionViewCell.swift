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

    var selectedType: Bool = false

    override func layoutSubviews() {
        super.layoutSubviews()

        self.selectionHighlightView.layer.cornerRadius = self.selectionHighlightView.frame.size.height / 2
        self.labelView.layer.cornerRadius = self.labelView.frame.size.height / 2
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.setupWithTheme()
        self.setSelectedType(false)
    }

    func setupWithTheme() {
        self.normalColor = UIColor.App.pillBackground
        self.selectedColor = UIColor.App.highlightPrimary
        self.selectionHighlightView.backgroundColor = UIColor.App.highlightPrimary
        self.labelView.backgroundColor = UIColor.App.pillBackground
        self.setupWithSelection(self.selectedType)
        self.titleLabel.textColor = UIColor.App.textPrimary

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    func setupWithTitle(_ title: String) {
        self.titleLabel.text = title
    }

    func setSelectedType(_ selected: Bool) {
        self.selectedType = selected
        self.setupWithSelection(self.selectedType)
    }

    func setupWithSelection(_ selected: Bool) {
        if selected {
            self.selectionHighlightView.backgroundColor = self.selectedColor
            self.labelView.backgroundColor = self.normalColor
        }
        else {
            self.selectionHighlightView.backgroundColor = self.normalColor
            self.labelView.backgroundColor = self.normalColor
        }
    }
}
