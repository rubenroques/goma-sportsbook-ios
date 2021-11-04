//
//  MatchWidgetCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 30/09/2021.
//

import UIKit
import Kingfisher

class MatchWidgetCollectionViewCell: UICollectionViewCell {

    //
    @IBOutlet weak var baseView: UIView!

    @IBOutlet weak var favoritesIconImageView: UIImageView!

    @IBOutlet weak var numberOfBetsLabels: UILabel!
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var locationFlagImageView: UIImageView!

    @IBOutlet weak var favoritesButton: UIButton!

    @IBOutlet weak var participantsBaseView: UIView!

    @IBOutlet weak var homeParticipantNameLabel: UILabel!
    @IBOutlet weak var awayParticipantNameLabel: UILabel!

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var oddsStackView: UIStackView!

    @IBOutlet weak var homeBaseView: UIView!
    @IBOutlet weak var homeOddTitleLabel: UILabel!
    @IBOutlet weak var homeOddValueLabel: UILabel!

    @IBOutlet weak var drawBaseView: UIView!
    @IBOutlet weak var drawOddTitleLabel: UILabel!
    @IBOutlet weak var drawOddValueLabel: UILabel!

    @IBOutlet weak var awayBaseView: UIView!
    @IBOutlet weak var awayOddTitleLabel: UILabel!
    @IBOutlet weak var awayOddValueLabel: UILabel!

    @IBOutlet weak var suspendedBaseView: UIView!
    @IBOutlet weak var suspendedLabel: UILabel!

    var viewModel: MatchWidgetCellViewModel? {
        didSet {
            if let viewModelValue = self.viewModel {
                self.eventNameLabel.text = "\(viewModelValue.competitionName)"
                self.homeParticipantNameLabel.text = "\(viewModelValue.homeTeamName)"
                self.awayParticipantNameLabel.text = "\(viewModelValue.awayTeamName)"
                self.dateLabel.text = "\(viewModelValue.startDateString)"
                self.timeLabel.text = "\(viewModelValue.startTimeString)"

               // self.sportTypeImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModelValue.countryISOCode))
                self.locationFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModelValue.countryISOCode))

                if viewModelValue.isToday {
                    self.dateLabel.isHidden = true
                }
            }
        }
    }

    var match: Match?

    var isFavorite: Bool = false {
        didSet {
            if isFavorite {
                self.favoritesButton.setImage(UIImage(named: "selected_favorite_icon"), for: .normal)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear

        self.baseView.layer.cornerRadius = 9
        
        self.numberOfBetsLabels.isHidden = true
        self.favoritesButton.backgroundColor = .clear
        self.participantsBaseView.backgroundColor = .clear
        self.oddsStackView.backgroundColor = .clear
        self.homeBaseView.backgroundColor = .clear
        self.drawBaseView.backgroundColor = .clear
        self.awayBaseView.backgroundColor = .clear

        self.suspendedBaseView.layer.cornerRadius = 4.5
        self.homeBaseView.layer.cornerRadius = 4.5
        self.drawBaseView.layer.cornerRadius = 4.5
        self.awayBaseView.layer.cornerRadius = 4.5

        self.eventNameLabel.text = ""
        self.homeParticipantNameLabel.text = ""
        self.awayParticipantNameLabel.text = ""
        self.dateLabel.text = ""
        self.timeLabel.text = ""
        self.locationFlagImageView.image = nil
        self.suspendedBaseView.isHidden = true

        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.locationFlagImageView.layer.cornerRadius = self.locationFlagImageView.frame.size.width / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.viewModel = nil
        self.match = nil

        self.dateLabel.isHidden = false
        
        self.eventNameLabel.text = ""
        self.homeParticipantNameLabel.text = ""
        self.awayParticipantNameLabel.text = ""
        self.dateLabel.text = ""
        self.timeLabel.text = ""

        self.locationFlagImageView.isHidden = false
        self.locationFlagImageView.image = nil
    }

    func setupWithTheme() {
        self.baseView.backgroundColor = UIColor.App.secondaryBackground

        self.numberOfBetsLabels.textColor = UIColor.App.headingMain
        self.eventNameLabel.textColor = UIColor.App.headingSecondary
        self.homeParticipantNameLabel.textColor = UIColor.App.headingMain
        self.awayParticipantNameLabel.textColor = UIColor.App.headingMain
        self.dateLabel.textColor = UIColor.App.headingSecondary
        self.timeLabel.textColor = UIColor.App.headingMain
        self.homeOddTitleLabel.textColor = UIColor.App.headingMain
        self.homeOddValueLabel.textColor = UIColor.App.headingMain
        self.drawOddTitleLabel.textColor = UIColor.App.headingMain
        self.drawOddValueLabel.textColor = UIColor.App.headingMain
        self.awayOddTitleLabel.textColor = UIColor.App.headingMain
        self.awayOddValueLabel.textColor = UIColor.App.headingMain

        self.homeBaseView.backgroundColor = UIColor.App.tertiaryBackground
        self.drawBaseView.backgroundColor = UIColor.App.tertiaryBackground
        self.awayBaseView.backgroundColor = UIColor.App.tertiaryBackground

        self.suspendedBaseView.backgroundColor = UIColor.App.mainBackground
        self.suspendedLabel.textColor = UIColor.App.headingDisabled
    }

    func setupWithMatch(_ match: Match) {
        self.match = match

        let viewModel = MatchWidgetCellViewModel(match: match)

        self.eventNameLabel.text = "\(viewModel.competitionName)"
        self.homeParticipantNameLabel.text = "\(viewModel.homeTeamName)"
        self.awayParticipantNameLabel.text = "\(viewModel.awayTeamName)"
        self.dateLabel.text = "\(viewModel.startDateString)"
        self.timeLabel.text = "\(viewModel.startTimeString)"

       // self.sportTypeImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModel.countryISOCode))
        self.locationFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModel.countryISOCode))

        if viewModel.isToday {
            self.dateLabel.isHidden = true
        }

        if let market = match.markets.first {
            if let rightOutcome = market.outcomes[safe: 0] {
                self.homeOddTitleLabel.text = rightOutcome.translatedName
                self.homeOddValueLabel.text = String(format: "%.2f", rightOutcome.bettingOffer.value)
            }

            if let middleOutcome = market.outcomes[safe: 1] {
                self.drawOddTitleLabel.text = middleOutcome.translatedName
                self.drawOddValueLabel.text = String(format: "%.2f", middleOutcome.bettingOffer.value)
            }

            if let leftOutcome = market.outcomes[safe: 2] {
                self.awayOddTitleLabel.text = leftOutcome.translatedName
                self.awayOddValueLabel.text = String(format: "%.2f", leftOutcome.bettingOffer.value)
            }
        }

        for matchId in Env.favoritesManager.favoriteMatchesId {
            if matchId == match.id {
                print("CELL MATCH: \(matchId)")
                print("MATCH: \(match)")
                self.isFavorite = true
            }
        }
    }

    func shouldShowCountryFlag(_ show: Bool) {
        self.locationFlagImageView.isHidden = !show
    }

    @IBAction func didTapFavoritesButton(_ sender: Any) {
        
        var favoriteMatchExists = false
        Env.favoritesManager.getUserMetadata()
        
        for matchId in Env.favoritesManager.favoriteMatchesId {
            if self.match!.id == matchId {
                favoriteMatchExists = true
                Env.favoritesManager.favoriteMatchesId = Env.favoritesManager.favoriteMatchesId.filter {$0 != self.match!.id}
            }
        }

        if self.isFavorite {
            self.isFavorite = false
            self.favoritesButton.setImage(UIImage(named: "unselected_favorite_icon"), for: .normal)
        }
        else {
            self.isFavorite = true
            self.favoritesButton.setImage(UIImage(named: "selected_favorite_icon"), for: .normal)

            Env.favoritesManager.favoriteMatchesId.append(self.match!.id)
        }
        Env.favoritesManager.postUserMetadata(favoriteEvents: Env.favoritesManager.favoriteMatchesId)
    }

}
