//
//  MatchTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 30/09/2021.
//

import UIKit

class MatchTableViewCell: UITableViewCell {

    @IBOutlet private var collectionBaseView: UIView!
    @IBOutlet private var collectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setupWithTheme()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        
    }

}
