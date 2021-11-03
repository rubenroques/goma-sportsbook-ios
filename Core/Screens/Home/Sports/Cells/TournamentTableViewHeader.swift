//
//  TournamentTableViewHeader.swift
//  Sportsbook
//
//  Created by Ruben Roques on 01/10/2021.
//

import UIKit

class TournamentTableViewHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var countryFlagImageView: UIImageView!
    @IBOutlet weak var nameTitleLabel: UILabel!

    @IBOutlet weak var favoriteLeagueBaseView: UIView!
    @IBOutlet weak var favoriteLeagueImageView: UIImageView!

    @IBOutlet weak var collapseLargeBaseView: UIView!
    @IBOutlet weak var collapseBaseView: UIView!
    @IBOutlet weak var collapseImageView: UIImageView!

    var sectionIndex: Int?

    var didToggleHeaderViewAction: ((Int) -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.favoriteLeagueBaseView.layer.cornerRadius = 4
        self.collapseBaseView.layer.cornerRadius = 4

        self.countryFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: "pt") )
        self.favoriteLeagueImageView.image = UIImage(named: "unselected_favorite_icon")
        self.collapseImageView.image = UIImage(named: "arrow_up_icon")

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didToggleCell))
        collapseLargeBaseView.addGestureRecognizer(tapGesture)

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.countryFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: "pt") )
        self.favoriteLeagueImageView.image = UIImage(named: "unselected_favorite_icon")
        self.collapseImageView.image = UIImage(named: "arrow_up_icon")

        self.nameTitleLabel.text = ""
        self.sectionIndex = nil
    }


    override func layoutSubviews() {
        super.layoutSubviews()

        self.countryFlagImageView.layer.cornerRadius = self.countryFlagImageView.frame.size.width / 2
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.favoriteLeagueBaseView.backgroundColor = UIColor.App.secondaryBackground
        self.collapseBaseView.backgroundColor = UIColor.App.secondaryBackground

        self.nameTitleLabel.textColor = UIColor.App.headingMain
    }

    @objc func didToggleCell() {
        if let sectionIndex = sectionIndex {
            self.didToggleHeaderViewAction?(sectionIndex)
        }
    }

}
