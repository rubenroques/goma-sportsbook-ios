//
//  OddDoubleCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 13/10/2021.
//

import UIKit
import Combine

class OddTripleCollectionViewCell: UICollectionViewCell {

    // @IBOutlet weak var cardBaseView: UIView!

    @IBOutlet private weak var participantsNameLabel: UILabel!
    @IBOutlet private weak var participantsCountryImageView: UIImageView!

    @IBOutlet private weak var marketStatsStackView: UIStackView!
    @IBOutlet private weak var marketNameLabel: UILabel!

    @IBOutlet private weak var oddsStackView: UIStackView!

    @IBOutlet private weak var leftBaseView: UIView!
    @IBOutlet private weak var leftOddTitleLabel: UILabel!
    @IBOutlet private weak var leftOddValueLabel: UILabel!

    @IBOutlet private weak var middleBaseView: UIView!
    @IBOutlet private weak var middleOddTitleLabel: UILabel!
    @IBOutlet private weak var middleOddValueLabel: UILabel!

    @IBOutlet private weak var rightBaseView: UIView!
    @IBOutlet private weak var rightOddTitleLabel: UILabel!
    @IBOutlet private weak var rightOddValueLabel: UILabel!

    @IBOutlet private weak var suspendedBaseView: UIView!
    @IBOutlet private weak var suspendedLabel: UILabel!

    @IBOutlet private weak var leftUpChangeOddValueImage: UIImageView!
    @IBOutlet private weak var leftDownChangeOddValueImage: UIImageView!
    @IBOutlet private weak var middleUpChangeOddValueImage: UIImageView!
    @IBOutlet private weak var middleDownChangeOddValueImage: UIImageView!
    @IBOutlet private weak var rightUpChangeOddValueImage: UIImageView!
    @IBOutlet private weak var rightDownChangeOddValueImage: UIImageView!

    @IBOutlet private weak var statsBaseView: UIView!
    @IBOutlet private weak var iconStatsImageView: UIImageView!
    @IBOutlet private weak var homeCircleCaptionView: UIView!
    @IBOutlet private weak var homeNameCaptionLabel: UILabel!
    @IBOutlet private weak var awayCircleCaptionView: UIView!
    @IBOutlet private weak var awayNameCaptionLabel: UILabel!

    
    var matchStatsViewModel: MatchStatsViewModel?

    var match: Match?
    var market: Market?

    private var leftOutcome: Outcome?
    private var middleOutcome: Outcome?
    private var rightOutcome: Outcome?

    private var matchStatsSubscriber: AnyCancellable?

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

    var tappedMatchWidgetAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear

        self.layer.cornerRadius = 9

        self.marketNameLabel.font = AppFont.with(type: .bold, size: 14)

        self.statsBaseView.isHidden = true

        self.homeCircleCaptionView.layer.masksToBounds = true
        self.awayCircleCaptionView.layer.masksToBounds = true
        
        self.oddsStackView.backgroundColor = .clear

        self.suspendedBaseView.layer.cornerRadius = 4.5

        self.leftBaseView.layer.cornerRadius = 4.5
        self.middleBaseView.layer.cornerRadius = 4.5
        self.rightBaseView.layer.cornerRadius = 4.5

        self.participantsNameLabel.text = ""
        self.marketNameLabel.text = ""

        self.suspendedBaseView.isHidden = true

        self.leftUpChangeOddValueImage.alpha = 0.0
        self.leftDownChangeOddValueImage.alpha = 0.0
        self.middleUpChangeOddValueImage.alpha = 0.0
        self.middleDownChangeOddValueImage.alpha = 0.0
        self.rightUpChangeOddValueImage.alpha = 0.0
        self.rightDownChangeOddValueImage.alpha = 0.0

        self.homeNameCaptionLabel.text = ""
        self.awayNameCaptionLabel.text = ""

        let tapLeftOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapLeftOddButton))
        self.leftBaseView.addGestureRecognizer(tapLeftOddButton)

        let tapMiddleOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapMiddleOddButton))
        self.middleBaseView.addGestureRecognizer(tapMiddleOddButton)

        let tapRightOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapRightOddButton))
        self.rightBaseView.addGestureRecognizer(tapRightOddButton)

        let tapMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMatchView))
        self.addGestureRecognizer(tapMatchView)

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        let stackSubviews = self.marketStatsStackView.arrangedSubviews
        stackSubviews.forEach({
            if $0 != self.marketNameLabel {
                self.marketStatsStackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
        })

        self.matchStatsViewModel = nil
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

        self.matchStatsSubscriber?.cancel()
        self.matchStatsSubscriber = nil

        self.currentLeftOddValue = nil
        self.currentMiddleOddValue = nil
        self.currentRightOddValue = nil

        self.isLeftOutcomeButtonSelected = false
        self.isMiddleOutcomeButtonSelected = false
        self.isRightOutcomeButtonSelected = false

        self.statsBaseView.isHidden = true
        self.homeNameCaptionLabel.text = ""
        self.awayNameCaptionLabel.text = ""
        
        self.marketNameLabel.text = ""
        self.participantsNameLabel.text = ""
        self.leftOddTitleLabel.text = ""
        self.leftOddValueLabel.text = ""
        self.middleOddTitleLabel.text = ""
        self.middleOddValueLabel.text = ""
        self.rightOddTitleLabel.text = ""
        self.rightOddValueLabel.text =  ""

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.homeCircleCaptionView.layer.cornerRadius = self.homeCircleCaptionView.frame.size.width / 2
        self.awayCircleCaptionView.layer.cornerRadius = self.awayCircleCaptionView.frame.size.width / 2
    }

    func setupWithTheme() {
        self.backgroundColor = UIColor.App2.backgroundCards

        self.participantsNameLabel.textColor = UIColor.App2.textPrimary
        self.marketNameLabel.textColor = UIColor.App2.textPrimary

       

        self.middleOddTitleLabel.textColor = UIColor.App2.textPrimary
        self.middleOddValueLabel.textColor = UIColor.App2.textPrimary

        self.rightOddTitleLabel.textColor = UIColor.App2.textPrimary
        self.rightOddValueLabel.textColor = UIColor.App2.textPrimary

        self.leftBaseView.backgroundColor = UIColor.App2.backgroundOdds
        self.middleBaseView.backgroundColor = UIColor.App2.backgroundOdds
        self.rightBaseView.backgroundColor = UIColor.App2.backgroundOdds

        self.suspendedBaseView.backgroundColor = UIColor.App2.backgroundDisabledOdds
        self.suspendedLabel.textColor = UIColor.App2.textDisablePrimary

        self.statsBaseView.backgroundColor = UIColor.App2.backgroundCards

        self.homeNameCaptionLabel.textColor = UIColor.App2.textPrimary
        self.awayNameCaptionLabel.textColor = UIColor.App2.textPrimary

        self.homeCircleCaptionView.backgroundColor = UIColor(hex: 0xD99F00)
        self.awayCircleCaptionView.backgroundColor = UIColor(hex: 0x46C1A7)
    }

    func setupWithMarket(_ market: Market, match: Match, teamsText: String, countryIso: String) {

        if let matchStatsViewModel = matchStatsViewModel,
           market.eventPartId != nil,
           market.bettingTypeId != nil {

            self.homeNameCaptionLabel.text = match.homeParticipant.name
            self.awayNameCaptionLabel.text = match.awayParticipant.name

            self.matchStatsSubscriber = matchStatsViewModel.statsTypePublisher
                .compactMap({ $0 })
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { json in
                    self.setupStatsLine(withjson: json)
                })
        }

        self.match = match
        self.market = market
        
        self.marketNameLabel.text = market.name

        self.participantsNameLabel.text = teamsText

        self.participantsCountryImageView.image = UIImage(named: "market_stats_icon")

        if let outcome = market.outcomes[safe: 0] {
            self.leftOddTitleLabel.text = outcome.typeName
            self.leftOddValueLabel.text = OddFormatter.formatOdd(withValue: outcome.bettingOffer.value)
            // self.currentLeftOddValue = outcome.bettingOffer.value
            self.leftOutcome = outcome

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
                    weakSelf.leftOddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
                })
        }

        if let outcome = market.outcomes[safe: 1] {
            self.middleOddTitleLabel.text = outcome.typeName
            self.middleOddValueLabel.text = OddFormatter.formatOdd(withValue: outcome.bettingOffer.value)
            // self.currentMiddleOddValue = outcome.bettingOffer.value
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
                    weakSelf.middleOddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
                })
        }

        if let outcome = market.outcomes[safe: 2] {
            self.rightOddTitleLabel.text = outcome.typeName
            self.rightOddValueLabel.text = OddFormatter.formatOdd(withValue: outcome.bettingOffer.value)
            // self.currentRightOddValue = outcome.bettingOffer.value
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
                    weakSelf.rightOddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
                })
        }

    }

    @IBAction func didTapMatchView(_ sender: Any) {
        self.tappedMatchWidgetAction?()
    }

    func highlightOddChangeUp(animated: Bool = true, upChangeOddValueImage: UIImageView, baseView: UIView) {
        baseView.layer.borderWidth = 1.5
        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: .curveEaseIn, animations: {
            upChangeOddValueImage.alpha = 1.0
            self.animateBorderColor(view: baseView, color: UIColor.App2.alertSuccess, duration: animated ? 0.4 : 0.0)
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
            self.animateBorderColor(view: baseView, color: UIColor.App2.alertError, duration: animated ? 0.4 : 0.0)
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

    func selectLeftOddButton() {
        self.leftBaseView.backgroundColor = UIColor.App2.buttonBackgroundPrimary
        self.leftOddTitleLabel.textColor = UIColor.App2.buttonTextPrimary
        self.leftOddValueLabel.textColor = UIColor.App2.buttonTextPrimary
    }

    func deselectLeftOddButton() {
        self.leftBaseView.backgroundColor = UIColor.App2.backgroundOdds
        self.leftOddTitleLabel.textColor = UIColor.App2.textPrimary
        self.leftOddValueLabel.textColor = UIColor.App2.textPrimary
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
        let outcomeDescription = outcome.translatedName

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
        self.middleBaseView.backgroundColor = UIColor.App2.buttonBackgroundPrimary
        self.middleOddTitleLabel.textColor = UIColor.App2.buttonTextPrimary
        self.middleOddValueLabel.textColor = UIColor.App2.buttonTextPrimary
    }
    func deselectMiddleOddButton() {
        self.middleBaseView.backgroundColor = UIColor.App2.backgroundOdds
        self.middleOddTitleLabel.textColor = UIColor.App2.textPrimary
        self.middleOddValueLabel.textColor = UIColor.App2.textPrimary
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
        let outcomeDescription = outcome.translatedName

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
        self.rightBaseView.backgroundColor = UIColor.App2.buttonBackgroundPrimary
        self.rightOddValueLabel.textColor = UIColor.App2.buttonTextPrimary
        self.rightOddTitleLabel.textColor = UIColor.App2.buttonTextPrimary
    }
    func deselectRightOddButton() {
        self.rightBaseView.backgroundColor = UIColor.App2.backgroundOdds
        self.rightOddTitleLabel.textColor = UIColor.App2.textPrimary
        self.rightOddValueLabel.textColor = UIColor.App2.textPrimary
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
        let outcomeDescription = outcome.translatedName

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


extension OddTripleCollectionViewCell {
    private func setupStatsLine(withjson json: JSON) {

        guard
            let eventPartId = self.market?.eventPartId,
            let bettingTypeId = self.market?.bettingTypeId
        else {
            return
        }

        var bettingType: JSON? = nil

        if let eventPartsArray = json["event_parts"].array {
            for partDict in eventPartsArray {
                if let id = partDict["id"].int, String(id) == eventPartId {

                    if let bettintTypesArray = partDict["betting_types"].array {
                        for dict in bettintTypesArray {
                            if let id = dict["id"].int, String(id) == bettingTypeId {
                                bettingType = dict
                                break
                            }
                        }
                    }

                }
            }
        }

        if let bettingTypeValue = bettingType,
           let bettingTypeStats = bettingTypeValue["stats"]["data"].dictionary {

            var homeWin: Int = 0
            var homeDraw: Int = 0
            var homeLoss: Int = 0
            var homeTotal: Int = 10

            var awayWin: Int = 0
            var awayDraw: Int = 0
            var awayLoss: Int = 0
            var awayTotal: Int = 10

            if let homeWinsValue = bettingTypeStats["home_participant"]?["Wins"].int,
               let homeDrawValue = bettingTypeStats["home_participant"]?["Draws"].int,
               let homeLossesValue = bettingTypeStats["home_participant"]?["Losses"].int,
               let awayWinsValue = bettingTypeStats["away_participant"]?["Wins"].int,
               let awayDrawValue = bettingTypeStats["away_participant"]?["Draws"].int,
               let awayLossesValue = bettingTypeStats["away_participant"]?["Losses"].int {

                homeWin = homeWinsValue
                homeDraw = homeDrawValue
                homeLoss = homeLossesValue
                homeTotal = homeWin + homeDraw + homeLoss

                awayWin = awayWinsValue
                awayDraw = awayDrawValue
                awayLoss = awayLossesValue
                awayTotal = awayWin + awayDraw + awayLoss

                self.marketNameLabel.font = AppFont.with(type: .bold, size: 12)

                let stackSubviews = self.marketStatsStackView.arrangedSubviews
                stackSubviews.forEach({
                    if $0 != self.marketNameLabel {
                        self.marketStatsStackView.removeArrangedSubview($0)
                        $0.removeFromSuperview()
                    }
                })
                
                let headToHeadCardStatsView = HeadToHeadCardStatsView()
                self.marketStatsStackView.addArrangedSubview(headToHeadCardStatsView)

                headToHeadCardStatsView.setupHomeValues(win: homeWin, draw: homeDraw, loss: homeLoss, total: homeTotal)
                headToHeadCardStatsView.setupAwayValues(win: awayWin, draw: awayDraw, loss: awayLoss, total: awayTotal)

                self.statsBaseView.isHidden = false
            }
        }
    }
}
