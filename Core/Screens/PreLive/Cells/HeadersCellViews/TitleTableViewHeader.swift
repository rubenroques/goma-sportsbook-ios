//
//  TitleTableViewHeader.swift
//  Sportsbook
//
//  Created by Ruben Roques on 01/10/2021.
//

import UIKit

class TitleTableViewHeader: UITableViewHeaderFooterView {

    @IBOutlet private weak var baseView: UIView!
    @IBOutlet private weak var sectionTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.sectionTitleLabel.text = localized("empty_value")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear

        self.sectionTitleLabel.textColor = UIColor.App.textPrimary
    }

    func configureWithTitle(_ title: String) {
        self.sectionTitleLabel.text = title
    }

}
