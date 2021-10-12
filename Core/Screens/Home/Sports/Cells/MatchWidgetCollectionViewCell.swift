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

        self.dateLabel.isHidden = false
        
        self.eventNameLabel.text = ""
        self.homeParticipantNameLabel.text = ""
        self.awayParticipantNameLabel.text = ""
        self.dateLabel.text = ""
        self.timeLabel.text = ""
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

    @IBAction func didTapFavoritesButton(_ sender: Any) {

    }

}
