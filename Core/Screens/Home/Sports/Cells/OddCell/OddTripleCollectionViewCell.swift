//
//  OddDoubleCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 13/10/2021.
//

import UIKit

class OddTripleCollectionViewCell: UICollectionViewCell {

    //@IBOutlet weak var cardBaseView: UIView!

    @IBOutlet weak var participantsNameLabel: UILabel!
    @IBOutlet weak var participantsCountryImageView: UIImageView!
    @IBOutlet weak var marketNameLabel: UILabel!

    @IBOutlet weak var oddsStackView: UIStackView!

    @IBOutlet weak var leftBaseView: UIView!
    @IBOutlet weak var leftOddTitleLabel: UILabel!
    @IBOutlet weak var leftOddValueLabel: UILabel!

    @IBOutlet weak var middleBaseView: UIView!
    @IBOutlet weak var middleOddTitleLabel: UILabel!
    @IBOutlet weak var middleOddValueLabel: UILabel!

    @IBOutlet weak var rightBaseView: UIView!
    @IBOutlet weak var rightOddTitleLabel: UILabel!
    @IBOutlet weak var rightOddValueLabel: UILabel!

    @IBOutlet weak var suspendedBaseView: UIView!
    @IBOutlet weak var suspendedLabel: UILabel!

    var market: Market?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear

        self.layer.cornerRadius = 9

        self.oddsStackView.backgroundColor = .clear

        self.suspendedBaseView.layer.cornerRadius = 4.5
        self.leftBaseView.layer.cornerRadius = 4.5
        self.rightBaseView.layer.cornerRadius = 4.5

        self.participantsNameLabel.text = ""
        self.marketNameLabel.text = ""
        self.participantsCountryImageView.image = nil
        self.suspendedBaseView.isHidden = true

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.marketNameLabel.text = ""
        self.participantsNameLabel.text = ""
        self.leftOddTitleLabel.text = ""
        self.leftOddValueLabel.text = ""
        self.middleOddTitleLabel.text = ""
        self.middleOddValueLabel.text = ""
        self.rightOddTitleLabel.text = ""
        self.rightOddValueLabel.text =  ""

        self.participantsCountryImageView.image = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.participantsCountryImageView.layer.cornerRadius = self.participantsCountryImageView.frame.size.width / 2
    }


    func setupWithTheme() {
        self.backgroundColor = UIColor.App.secondaryBackground

        self.participantsNameLabel.textColor = UIColor.App.headingSecondary
        self.marketNameLabel.textColor = UIColor.App.headingMain

        self.leftOddTitleLabel.textColor = UIColor.App.headingMain
        self.leftOddValueLabel.textColor = UIColor.App.headingMain

        self.middleOddTitleLabel.textColor = UIColor.App.headingMain
        self.middleOddValueLabel.textColor = UIColor.App.headingMain

        self.rightOddTitleLabel.textColor = UIColor.App.headingMain
        self.rightOddValueLabel.textColor = UIColor.App.headingMain

        self.leftBaseView.backgroundColor = UIColor.App.tertiaryBackground
        self.middleBaseView.backgroundColor = UIColor.App.tertiaryBackground
        self.rightBaseView.backgroundColor = UIColor.App.tertiaryBackground

        self.suspendedBaseView.backgroundColor = UIColor.App.mainBackground
        self.suspendedLabel.textColor = UIColor.App.headingDisabled
    }


    func setupWithMarket(_ market: Market, teamsText: String, countryIso: String) {

        self.market = market
        self.marketNameLabel.text = market.name

        self.participantsNameLabel.text = teamsText

        self.participantsCountryImageView.image = UIImage(named: Assets.flagName(withCountryCode: countryIso))

        if let rightOutcome = market.outcomes[safe: 0] {
            self.leftOddTitleLabel.text = rightOutcome.translatedName
            self.leftOddValueLabel.text = String(format: "%.2f", rightOutcome.bettingOffer.value)
        }

        if let middleOutcome = market.outcomes[safe: 1] {
            self.middleOddTitleLabel.text = middleOutcome.translatedName
            self.middleOddValueLabel.text = String(format: "%.2f", middleOutcome.bettingOffer.value)
        }

        if let leftOutcome = market.outcomes[safe: 2] {
            self.rightOddTitleLabel.text = leftOutcome.translatedName
            self.rightOddValueLabel.text = String(format: "%.2f", leftOutcome.bettingOffer.value)
        }

    }

}
