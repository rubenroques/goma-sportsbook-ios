//
//  SeeMoreMarketsCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 13/10/2021.
//

import UIKit

class SeeMoreMarketsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    var tappedAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.baseView.layer.cornerRadius = 9

        self.titleLabel.text = "See All"
        self.setupWithTheme()

        let tapMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMatchView))
        self.addGestureRecognizer(tapMatchView)

    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.subtitleLabel.text = ""
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.baseView.backgroundColor = UIColor.App.secondaryBackground

        self.titleLabel.textColor = UIColor.App.headingMain
        self.subtitleLabel.textColor = UIColor.App.headingSecondary
    }

    @IBAction func didTapMatchView(_ sender: Any) {
        self.tappedAction?()
    }

}
