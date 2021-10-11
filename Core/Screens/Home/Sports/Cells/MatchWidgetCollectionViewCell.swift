//
//  MatchWidgetCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 30/09/2021.
//

import UIKit

class MatchWidgetCollectionViewCell: UICollectionViewCell {

    //
    @IBOutlet weak var baseView: UIView!

    @IBOutlet weak var favoritesIconImageView: UIImageView!

    @IBOutlet weak var numberOfBetsLabels: UILabel!
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var sportTypeImageView: UIImageView!
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


    var viewModel: MatchWidgetCellViewModel? {
        didSet {
            
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

        self.sportTypeImageView.backgroundColor = .clear

        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.locationFlagImageView.layer.cornerRadius = 3

        self.homeBaseView.layer.cornerRadius = 4
        self.drawBaseView.layer.cornerRadius = 4
        self.awayBaseView.layer.cornerRadius = 4
    }

    func setupWithTheme() {
        self.baseView.backgroundColor = UIColor.App.secondaryBackground

        self.numberOfBetsLabels.textColor = UIColor.App.headingMain
        self.eventNameLabel.textColor = UIColor.App.headingMain
        self.homeParticipantNameLabel.textColor = UIColor.App.headingMain
        self.awayParticipantNameLabel.textColor = UIColor.App.headingMain
        self.dateLabel.textColor = UIColor.App.fadeOutHeading
        self.timeLabel.textColor = UIColor.App.headingMain
        self.homeOddTitleLabel.textColor = UIColor.App.headingMain
        self.homeOddValueLabel.textColor = UIColor.App.headingMain
        self.drawOddTitleLabel.textColor = UIColor.App.headingMain
        self.drawOddValueLabel.textColor = UIColor.App.headingMain
        self.awayOddTitleLabel.textColor = UIColor.App.headingMain
        self.awayOddValueLabel.textColor = UIColor.App.headingMain

        self.homeBaseView.backgroundColor = UIColor.App.mainBackground
        self.drawBaseView.backgroundColor = UIColor.App.mainBackground
        self.awayBaseView.backgroundColor = UIColor.App.mainBackground

    }

    @IBAction func didTapFavoritesButton(_ sender: Any) {

    }

}
