//
//  SearchTitleSectionTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 21/01/2022.
//

import UIKit

class SearchTitleSectionUITableViewHeaderFooterView: UITableViewHeaderFooterView {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.nameLabel.text = ""
        self.countLabel.text = ""
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = UIColor.App.contentBackground

        self.nameLabel.textColor = UIColor.App.headingMain
        self.nameLabel.font = AppFont.with(type: .bold, size: 16)

        self.countLabel.textColor = UIColor.App.headerTextField
        self.countLabel.font = AppFont.with(type: .bold, size: 16)
    }

    func configureLabels(nameText: String, countText: String) {
        self.nameLabel.text = nameText
        self.countLabel.text = countText
    }
    
}
