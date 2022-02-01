//
//  SeeMoreMarketsCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 13/10/2021.
//

import UIKit

class SeeMoreMarketsCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var baseView: UIView!
    @IBOutlet private weak var arrowImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    var tappedAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.baseView.layer.cornerRadius = 9

        self.titleLabel.text = localized("see_all")
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

        self.baseView.backgroundColor = UIColor.App2.backgroundCards

        self.titleLabel.textColor = UIColor.App2.textPrimary
        self.subtitleLabel.textColor = UIColor.App2.textSecond
    }

    @IBAction private func didTapMatchView(_ sender: Any) {
        self.tappedAction?()
    }

    func configureWithSubtitleString(_ subtitle: String) {
        self.subtitleLabel.text = subtitle
    }
    
}
