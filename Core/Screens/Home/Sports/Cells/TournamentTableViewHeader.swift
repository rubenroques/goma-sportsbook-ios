//
//  TournamentTableViewHeader.swift
//  Sportsbook
//
//  Created by Ruben Roques on 01/10/2021.
//

import UIKit

class TournamentTableViewHeader: UITableViewCell {

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

    }
    
}
