//
//  TitleTableViewHeader.swift
//  Sportsbook
//
//  Created by Ruben Roques on 01/10/2021.
//

import UIKit

class TitleTableViewHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = UIColor.App.mainBackgroundColor
        self.backgroundView?.backgroundColor = UIColor.App.mainBackgroundColor

        self.titleLabel.textColor = UIColor.App.headingMain
    }

}
