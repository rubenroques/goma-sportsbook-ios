//
//  SubmitedBetSelectionView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/11/2021.
//

import UIKit

class SubmitedBetSelectionView: NibView {

    @IBOutlet private weak var topSeparatorLineView: UIView!
    @IBOutlet private weak var countryCompetitionFlagImageView: UIImageView!

    @IBOutlet private weak var eventNameLabel: UILabel!
    @IBOutlet private weak var eventTimeLabel: UILabel!

    @IBOutlet private weak var marketNameLabel: UILabel!
    @IBOutlet private weak var betNameLabel: UILabel!

    @IBOutlet weak var oddBaseView: UIView!
    @IBOutlet weak var oddValueLabel: UILabel!
    @IBOutlet weak var upChangeOddValueImage: UIImageView!
    @IBOutlet weak var downChangeOddValueImage: UIImageView!

    var betHistoryEntrySelection: BetHistoryEntrySelection

    convenience init(betHistoryEntrySelection: BetHistoryEntrySelection) {
        self.init(frame: .zero, betHistoryEntrySelection: betHistoryEntrySelection)
    }

    init(frame: CGRect, betHistoryEntrySelection: BetHistoryEntrySelection) {
        self.betHistoryEntrySelection = betHistoryEntrySelection
        super.init(frame: frame)

        self.commonInit()
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.countryCompetitionFlagImageView.layer.cornerRadius = self.countryCompetitionFlagImageView.frame.size.width / 2
    }

    override func commonInit() {

        self.countryCompetitionFlagImageView.clipsToBounds = true
        self.countryCompetitionFlagImageView.layer.masksToBounds = true

        self.oddValueLabel.text = "-.--"
        self.eventTimeLabel.text = ""

        self.upChangeOddValueImage.alpha = 0.0
        self.downChangeOddValueImage.alpha = 0.0

        if let eventName = betHistoryEntrySelection.eventName {
            eventNameLabel.text = eventName
        }

        if let eventDate = betHistoryEntrySelection.eventDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            eventTimeLabel.text = dateFormatter.string(from: eventDate)
        }

        if let marketName = betHistoryEntrySelection.marketName {
            marketNameLabel.text = marketName
        }

        if let betName = betHistoryEntrySelection.betName {
            self.betNameLabel.text = betName
        }

        if let venueId = betHistoryEntrySelection.venueId,
           let venue = Env.everyMatrixStorage.location(forId: venueId),
           let isoCode = venue.code {
            self.countryCompetitionFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: isoCode))
        }
        else {
            self.countryCompetitionFlagImageView.isHidden = true
        }

        self.setupWithTheme()

    }

    func setupWithTheme() {
        self.backgroundColor = UIColor.App.secondaryBackground

        topSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        
        eventNameLabel.textColor = UIColor.App.headingMain
        eventTimeLabel.textColor = UIColor.App.headingSecondary
        marketNameLabel.textColor = UIColor.App.headingMain
        betNameLabel.textColor = UIColor.App.headingSecondary
        oddValueLabel.textColor = UIColor.App.headingMain
    }

}
