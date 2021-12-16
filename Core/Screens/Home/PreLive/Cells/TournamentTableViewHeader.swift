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
    var competition: Competition? {
        didSet {
            self.setupCompetition()
        }
    }

    var isFavorite: Bool = false {
        didSet {
            if isFavorite {
                self.favoriteLeagueImageView.image = UIImage(named: "selected_favorite_icon")
            }
            else {
                self.favoriteLeagueImageView.image = UIImage(named: "unselected_favorite_icon")
            }
        }
    }

    var didToggleHeaderViewAction: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.favoriteLeagueBaseView.layer.cornerRadius = 4
        self.collapseBaseView.layer.cornerRadius = 4

        self.countryFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: "pt") )
        self.favoriteLeagueImageView.image = UIImage(named: "unselected_favorite_icon")
        self.collapseImageView.image = UIImage(named: "arrow_up_icon")

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didToggleCell))
        collapseLargeBaseView.addGestureRecognizer(tapGesture)

        let tapFavoriteGesture = UITapGestureRecognizer(target: self, action: #selector(didTapFavoriteImageView))
        favoriteLeagueBaseView.addGestureRecognizer(tapFavoriteGesture)

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.countryFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: "pt") )

        self.collapseImageView.image = UIImage(named: "arrow_up_icon")

        self.nameTitleLabel.text = ""
        self.sectionIndex = nil

        self.isFavorite = false
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

    func setupCompetition() {
        for competitionId in Env.favoritesManager.favoriteEventsIdPublisher.value {
            if competitionId == self.competition!.id {
                self.isFavorite = true
            }
        }
    }

    @objc func didToggleCell() {
        if let sectionIndex = sectionIndex {
            self.didToggleHeaderViewAction?(sectionIndex)
        }
    }

    @objc func didTapFavoriteImageView() {
        if UserDefaults.standard.userSession != nil {

            if let competitionId = self.competition?.id {
                Env.favoritesManager.checkFavorites(eventId: competitionId)
            }

            if self.isFavorite {
                self.isFavorite = false
            }
            else {
                self.isFavorite = true

            }

        }
    }
}
