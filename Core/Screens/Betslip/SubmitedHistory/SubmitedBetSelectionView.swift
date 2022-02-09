//
//  SubmitedBetSelectionView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/11/2021.
//

import UIKit
import Combine

class SubmitedBetSelectionView: NibView {

    @IBOutlet private weak var topSeparatorLineView: UIView!
    @IBOutlet private weak var countryCompetitionFlagImageView: UIImageView!

    @IBOutlet private weak var betNameLabel: UILabel!
    @IBOutlet private weak var eventTimeLabel: UILabel!

    @IBOutlet private weak var marketNameLabel: UILabel!
    @IBOutlet private weak var eventNameLabel: UILabel!

    @IBOutlet private weak var oddBaseView: UIView!
    @IBOutlet private weak var oddValueLabel: UILabel!
    @IBOutlet private weak var upChangeOddValueImage: UIImageView!
    @IBOutlet private weak var downChangeOddValueImage: UIImageView!

    var oddSubscriber: AnyCancellable?
    var currentOddValue: Double?

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
        if let oddValue = betHistoryEntrySelection.priceValue {
            let oddValueString = String(format: "%.2f", oddValue)
            self.oddValueLabel.text = "\(oddValueString)"
        }
        else {
            self.oddValueLabel.text = "-.--"
        }

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

        if let bettingOffer = Env.everyMatrixStorage.bettingOffers[betHistoryEntrySelection.outcomeId] {

        self.oddSubscriber = Env.everyMatrixStorage
            .oddPublisherForBettingOfferId(bettingOffer.id)?
            .map(\.oddsValue)
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newOddValue in

                if let currentOddValue = self?.currentOddValue {
                    if newOddValue > currentOddValue {
                        self?.highlightOddChangeUp()
                    }
                    else if newOddValue < currentOddValue {
                        self?.highlightOddChangeDown()
                    }
                }
                self?.currentOddValue = newOddValue
                // self?.oddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
            })
        }
        
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = UIColor.App.backgroundSecondary

        topSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        
        betNameLabel.textColor = UIColor.App.textPrimary
        eventTimeLabel.textColor = UIColor.App.textSecond
        marketNameLabel.textColor = UIColor.App.textPrimary
        eventNameLabel.textColor = UIColor.App.textSecond
        oddValueLabel.textColor = UIColor.App.textPrimary
    }

    func highlightOddChangeUp(animated: Bool = true) {
        self.oddBaseView.layer.borderWidth = 1.5
        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: .curveEaseIn, animations: {
            self.upChangeOddValueImage.alpha = 1.0
            self.animateBorderColor(view: self.oddBaseView, color: UIColor.App.alertSuccess, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            self.upChangeOddValueImage.alpha = 0.0
            self.animateBorderColor(view: self.oddBaseView, color: UIColor.clear, duration: animated ? 0.4 : 0.0)
        }, completion: nil)
    }

    func highlightOddChangeDown(animated: Bool = true) {
        self.oddBaseView.layer.borderWidth = 1.5
        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: .curveEaseIn, animations: {
            self.downChangeOddValueImage.alpha = 1.0
            self.animateBorderColor(view: self.oddBaseView, color: UIColor.App.alertError, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            self.downChangeOddValueImage.alpha = 0.0
            self.animateBorderColor(view: self.oddBaseView, color: UIColor.clear, duration: animated ? 0.4 : 0.0)
        }, completion: nil)
    }

    private func animateBorderColor(view: UIView, color: UIColor, duration: Double) {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = layer.borderColor
        animation.toValue = color.cgColor
        animation.duration = duration
        view.layer.add(animation, forKey: "borderColor")
        view.layer.borderColor = color.cgColor
    }
    
}
