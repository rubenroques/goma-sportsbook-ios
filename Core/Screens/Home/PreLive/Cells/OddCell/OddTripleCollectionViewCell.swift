//
//  OddDoubleCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 13/10/2021.
//

import UIKit
import Combine

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


    @IBOutlet weak var leftUpChangeOddValueImage: UIImageView!
    @IBOutlet weak var leftDownChangeOddValueImage: UIImageView!
    @IBOutlet weak var middleUpChangeOddValueImage: UIImageView!
    @IBOutlet weak var middleDownChangeOddValueImage: UIImageView!
    @IBOutlet weak var rightUpChangeOddValueImage: UIImageView!
    @IBOutlet weak var rightDownChangeOddValueImage: UIImageView!

    var match: Match?
    var market: Market?

    private var leftOutcome: Outcome?
    private var middleOutcome: Outcome?
    private var rightOutcome: Outcome?

    private var leftOddButtonSubscriber: AnyCancellable?
    private var middleOddButtonSubscriber: AnyCancellable?
    private var rightOddButtonSubscriber: AnyCancellable?

    private var currentLeftOddValue: Double?
    private var currentMiddleOddValue: Double?
    private var currentRightOddValue: Double?

    private var isLeftOutcomeButtonSelected: Bool = false {
        didSet {
            self.isLeftOutcomeButtonSelected ? self.selectLeftOddButton() : self.deselectLeftOddButton()
        }
    }
    private var isMiddleOutcomeButtonSelected: Bool = false {
        didSet {
            self.isMiddleOutcomeButtonSelected ? self.selectMiddleOddButton() : self.deselectMiddleOddButton()
        }
    }
    private var isRightOutcomeButtonSelected: Bool = false {
        didSet {
            self.isRightOutcomeButtonSelected ? self.selectRightOddButton() : self.deselectRightOddButton()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear

        self.layer.cornerRadius = 9

        self.oddsStackView.backgroundColor = .clear

        self.suspendedBaseView.layer.cornerRadius = 4.5

        self.leftBaseView.layer.cornerRadius = 4.5
        self.middleBaseView.layer.cornerRadius = 4.5
        self.rightBaseView.layer.cornerRadius = 4.5

        self.participantsNameLabel.text = ""
        self.marketNameLabel.text = ""
        self.participantsCountryImageView.image = nil
        self.suspendedBaseView.isHidden = true

        self.leftUpChangeOddValueImage.alpha = 0.0
        self.leftDownChangeOddValueImage.alpha = 0.0
        self.middleUpChangeOddValueImage.alpha = 0.0
        self.middleDownChangeOddValueImage.alpha = 0.0
        self.rightUpChangeOddValueImage.alpha = 0.0
        self.rightDownChangeOddValueImage.alpha = 0.0

        let tapLeftOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapLeftOddButton))
        self.leftBaseView.addGestureRecognizer(tapLeftOddButton)

        let tapMiddleOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapMiddleOddButton))
        self.middleBaseView.addGestureRecognizer(tapMiddleOddButton)

        let tapRightOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapRightOddButton))
        self.rightBaseView.addGestureRecognizer(tapRightOddButton)


        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.match = nil
        self.market = nil

        self.leftOutcome = nil
        self.middleOutcome = nil
        self.rightOutcome = nil

        self.leftOddButtonSubscriber?.cancel()
        self.leftOddButtonSubscriber = nil
        self.middleOddButtonSubscriber?.cancel()
        self.middleOddButtonSubscriber = nil
        self.rightOddButtonSubscriber?.cancel()
        self.rightOddButtonSubscriber = nil

        self.currentLeftOddValue = nil
        self.currentMiddleOddValue = nil
        self.currentRightOddValue = nil

        self.isLeftOutcomeButtonSelected = false
        self.isMiddleOutcomeButtonSelected = false
        self.isRightOutcomeButtonSelected = false

        self.marketNameLabel.text = ""
        self.participantsNameLabel.text = ""
        self.leftOddTitleLabel.text = ""
        self.leftOddValueLabel.text = ""
        self.middleOddTitleLabel.text = ""
        self.middleOddValueLabel.text = ""
        self.rightOddTitleLabel.text = ""
        self.rightOddValueLabel.text =  ""

        self.participantsCountryImageView.isHidden = false
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


    func setupWithMarket(_ market: Market, match: Match, teamsText: String, countryIso: String) {

        self.match = match
        self.market = market
        
        self.marketNameLabel.text = market.name

        self.participantsNameLabel.text = teamsText

        self.participantsCountryImageView.image = UIImage(named: Assets.flagName(withCountryCode: countryIso))

        if let outcome = market.outcomes[safe: 0] {
            self.leftOddTitleLabel.text = outcome.typeName
            self.leftOddValueLabel.text = "\(Double(floor(outcome.bettingOffer.value * 100)/100))"
            self.leftOutcome = outcome
            self.currentLeftOddValue = outcome.bettingOffer.value

            self.isLeftOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

            self.leftOddButtonSubscriber = Env.everyMatrixStorage
                .oddPublisherForBettingOfferId(outcome.bettingOffer.id)?
                .map(\.oddsValue)
                .compactMap({ $0 })
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] newOddValue in

                    guard let weakSelf = self else { return }

                    if let currentOddValue = weakSelf.currentLeftOddValue {
                        if newOddValue > currentOddValue {
                            weakSelf.highlightOddChangeUp(animated: true,
                                                       upChangeOddValueImage: weakSelf.leftUpChangeOddValueImage,
                                                       baseView: weakSelf.leftBaseView)
                        }
                        else if newOddValue < currentOddValue {
                            weakSelf.highlightOddChangeDown(animated: true,
                                                       downChangeOddValueImage: weakSelf.leftDownChangeOddValueImage,
                                                       baseView: weakSelf.leftBaseView)
                        }
                    }
                    weakSelf.currentLeftOddValue = newOddValue
                    weakSelf.leftOddValueLabel.text = "\(Double(floor(newOddValue * 100)/100))"
                })
        }

        if let outcome = market.outcomes[safe: 1] {
            self.middleOddTitleLabel.text = outcome.typeName
            self.middleOddValueLabel.text = "\(Double(floor(outcome.bettingOffer.value * 100)/100))"

            self.currentMiddleOddValue = outcome.bettingOffer.value
            self.middleOutcome = outcome

            self.isMiddleOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

            self.middleOddButtonSubscriber = Env.everyMatrixStorage
                .oddPublisherForBettingOfferId(outcome.bettingOffer.id)?
                .map(\.oddsValue)
                .compactMap({ $0 })
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] newOddValue in

                    guard let weakSelf = self else { return }

                    if let currentOddValue = weakSelf.currentMiddleOddValue {
                        if newOddValue > currentOddValue {
                            weakSelf.highlightOddChangeUp(animated: true,
                                                       upChangeOddValueImage: weakSelf.middleUpChangeOddValueImage,
                                                       baseView: weakSelf.middleBaseView)
                        }
                        else if newOddValue < currentOddValue {
                            weakSelf.highlightOddChangeDown(animated: true,
                                                       downChangeOddValueImage: weakSelf.middleDownChangeOddValueImage,
                                                       baseView: weakSelf.middleBaseView)
                        }
                    }
                    weakSelf.currentMiddleOddValue = newOddValue
                    weakSelf.middleOddValueLabel.text = "\(Double(floor(newOddValue * 100)/100))"
                })
        }

        if let outcome = market.outcomes[safe: 2] {
            self.rightOddTitleLabel.text = outcome.typeName
            self.rightOddValueLabel.text = "\(Double(floor(outcome.bettingOffer.value * 100)/100))"
            self.currentRightOddValue = outcome.bettingOffer.value
            self.rightOutcome = outcome

            self.isRightOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

            self.rightOddButtonSubscriber = Env.everyMatrixStorage
                .oddPublisherForBettingOfferId(outcome.bettingOffer.id)?
                .map(\.oddsValue)
                .compactMap({ $0 })
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] newOddValue in

                    guard let weakSelf = self else { return }

                    if let currentOddValue = weakSelf.currentRightOddValue {
                        if newOddValue > currentOddValue {
                            weakSelf.highlightOddChangeUp(animated: true,
                                                       upChangeOddValueImage: weakSelf.rightUpChangeOddValueImage,
                                                       baseView: weakSelf.rightBaseView)
                        }
                        else if newOddValue < currentOddValue {
                            weakSelf.highlightOddChangeDown(animated: true,
                                                       downChangeOddValueImage: weakSelf.rightDownChangeOddValueImage,
                                                       baseView: weakSelf.rightBaseView)
                        }
                    }

                    weakSelf.currentRightOddValue = newOddValue
                    weakSelf.rightOddValueLabel.text = "\(Double(floor(newOddValue * 100)/100))"
                })
        }

    }


    func highlightOddChangeUp(animated: Bool = true, upChangeOddValueImage: UIImageView, baseView: UIView) {
        baseView.layer.borderWidth = 1.5
        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: .curveEaseIn, animations: {
            upChangeOddValueImage.alpha = 1.0
            self.animateBorderColor(view: baseView, color: UIColor.App.alertSuccess, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            upChangeOddValueImage.alpha = 0.0
            self.animateBorderColor(view: baseView, color: UIColor.clear, duration: animated ? 0.4 : 0.0)
        }, completion: nil)
    }

    func highlightOddChangeDown(animated: Bool = true, downChangeOddValueImage: UIImageView, baseView: UIView) {
        baseView.layer.borderWidth = 1.5
        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: .curveEaseIn, animations: {
            downChangeOddValueImage.alpha = 1.0
            self.animateBorderColor(view: baseView, color: UIColor.App.alertError, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            downChangeOddValueImage.alpha = 0.0
            self.animateBorderColor(view: baseView, color: UIColor.clear, duration: animated ? 0.4 : 0.0)
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

    
    func shouldShowCountryFlag(_ show: Bool) {
        self.participantsCountryImageView.isHidden = !show
    }


    func selectLeftOddButton() {
        self.leftBaseView.backgroundColor = UIColor.App.mainTint
    }
    func deselectLeftOddButton() {
        self.leftBaseView.backgroundColor = UIColor.App.tertiaryBackground
    }
    @objc func didTapLeftOddButton() {

        guard
            let match = self.match,
            let market = self.market,
            let outcome = self.leftOutcome
        else {
            return
        }

        let matchDescription = "\(match.homeParticipant.name) x \(match.awayParticipant.name)"
        let marketDescription = market.name
        let outcomeDescription = outcome.teamName

        let bettingTicket = BettingTicket(id: outcome.bettingOffer.id,
                                          outcomeId: outcome.id,
                                          matchId: match.id,
                                          value: outcome.bettingOffer.value,
                                          matchDescription: matchDescription,
                                          marketDescription: marketDescription,
                                          outcomeDescription: outcomeDescription)

        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isLeftOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)
            self.isLeftOutcomeButtonSelected = true
        }

    }


    func selectMiddleOddButton() {
        self.middleBaseView.backgroundColor = UIColor.App.mainTint
    }
    func deselectMiddleOddButton() {
        self.middleBaseView.backgroundColor = UIColor.App.tertiaryBackground
    }
    @objc func didTapMiddleOddButton() {
        guard
            let match = self.match,
            let market = self.market,
            let outcome = self.middleOutcome
        else {
            return
        }

        let matchDescription = "\(match.homeParticipant.name) x \(match.awayParticipant.name)"
        let marketDescription = market.name
        let outcomeDescription = outcome.teamName

        let bettingTicket = BettingTicket(id: outcome.bettingOffer.id,
                                          outcomeId: outcome.id,
                                          matchId: match.id,
                                          value: outcome.bettingOffer.value,
                                          matchDescription: matchDescription,
                                          marketDescription: marketDescription,
                                          outcomeDescription: outcomeDescription)

        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isMiddleOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)
            self.isMiddleOutcomeButtonSelected = true
        }
    }


    func selectRightOddButton() {
        self.rightBaseView.backgroundColor = UIColor.App.mainTint
    }
    func deselectRightOddButton() {
        self.rightBaseView.backgroundColor = UIColor.App.tertiaryBackground
    }
    @objc func didTapRightOddButton() {
        guard
            let match = self.match,
            let market = self.market,
            let outcome = self.rightOutcome
        else {
            return
        }

        let matchDescription = "\(match.homeParticipant.name) x \(match.awayParticipant.name)"
        let marketDescription = market.name
        let outcomeDescription = outcome.teamName

        let bettingTicket = BettingTicket(id: outcome.bettingOffer.id,
                                          outcomeId: outcome.id,
                                          matchId: match.id,
                                          value: outcome.bettingOffer.value,
                                          matchDescription: matchDescription,
                                          marketDescription: marketDescription,
                                          outcomeDescription: outcomeDescription)
        
        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isRightOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)
            self.isRightOutcomeButtonSelected = true
        }
    }

    
}
