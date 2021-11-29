//
//  LiveMatchWidgetCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/10/2021.
//

import UIKit
import Kingfisher
import Nuke
import Combine

class LiveMatchWidgetCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var baseView: UIView!

    @IBOutlet private weak var favoritesIconImageView: UIImageView!

    @IBOutlet private weak var numberOfBetsLabels: UILabel!
    
    @IBOutlet private weak var eventNameLabel: UILabel!
    @IBOutlet private weak var locationFlagImageView: UIImageView!

    @IBOutlet private weak var favoritesButton: UIButton!

    @IBOutlet private weak var participantsBaseView: UIView!

    @IBOutlet private weak var homeParticipantNameLabel: UILabel!
    @IBOutlet private weak var awayParticipantNameLabel: UILabel!

    @IBOutlet private weak var resultLabel: UILabel!
    @IBOutlet private weak var matchTimeLabel: UILabel!

    @IBOutlet private weak var oddsStackView: UIStackView!

    @IBOutlet private weak var homeBaseView: UIView!
    @IBOutlet private weak var homeOddTitleLabel: UILabel!
    @IBOutlet private weak var homeOddValueLabel: UILabel!
    @IBOutlet private weak var homeUpChangeOddValueImage: UIImageView!
    @IBOutlet private weak var homeDownChangeOddValueImage: UIImageView!

    @IBOutlet private weak var drawBaseView: UIView!
    @IBOutlet private weak var drawOddTitleLabel: UILabel!
    @IBOutlet private weak var drawOddValueLabel: UILabel!
    @IBOutlet private weak var drawUpChangeOddValueImage: UIImageView!
    @IBOutlet private weak var drawDownChangeOddValueImage: UIImageView!

    @IBOutlet private weak var awayBaseView: UIView!
    @IBOutlet private weak var awayOddTitleLabel: UILabel!
    @IBOutlet private weak var awayOddValueLabel: UILabel!
    @IBOutlet private weak var awayUpChangeOddValueImage: UIImageView!
    @IBOutlet private weak var awayDownChangeOddValueImage: UIImageView!

    @IBOutlet private weak var suspendedBaseView: UIView!
    @IBOutlet private weak var suspendedLabel: UILabel!

    private var leftOddButtonSubscriber: AnyCancellable?
    private var middleOddButtonSubscriber: AnyCancellable?
    private var rightOddButtonSubscriber: AnyCancellable?

    private var currentHomeOddValue: Double?
    private var currentDrawOddValue: Double?
    private var currentAwayOddValue: Double?

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

    var viewModel: MatchWidgetCellViewModel? {
        didSet {
            if let viewModelValue = self.viewModel {
                self.eventNameLabel.text = "\(viewModelValue.competitionName)"
                self.homeParticipantNameLabel.text = "\(viewModelValue.homeTeamName)"
                self.awayParticipantNameLabel.text = "\(viewModelValue.awayTeamName)"

               // self.sportTypeImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModelValue.countryISOCode))
                self.locationFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModelValue.countryISOCode))

            }
        }
    }

    var tappedMatchWidgetAction: (() -> Void)?
    
    var match: Match?

    private var leftOutcome: Outcome?
    private var middleOutcome: Outcome?
    private var rightOutcome: Outcome?

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

        self.homeUpChangeOddValueImage.alpha = 0.0
        self.homeDownChangeOddValueImage.alpha = 0.0
        self.drawUpChangeOddValueImage.alpha = 0.0
        self.drawDownChangeOddValueImage.alpha = 0.0
        self.awayUpChangeOddValueImage.alpha = 0.0
        self.awayDownChangeOddValueImage.alpha = 0.0

        self.eventNameLabel.text = ""
        self.homeParticipantNameLabel.text = ""
        self.awayParticipantNameLabel.text = ""
        self.matchTimeLabel.text = ""
        self.resultLabel.text = ""

        self.locationFlagImageView.image = nil
        self.suspendedBaseView.isHidden = true

        let tapLeftOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapLeftOddButton))
        self.homeBaseView.addGestureRecognizer(tapLeftOddButton)

        let tapMiddleOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapMiddleOddButton))
        self.drawBaseView.addGestureRecognizer(tapMiddleOddButton)

        let tapRightOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapRightOddButton))
        self.awayBaseView.addGestureRecognizer(tapRightOddButton)

        let tapMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMatchView))
        self.addGestureRecognizer(tapMatchView)

        
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

        self.leftOutcome = nil
        self.middleOutcome = nil
        self.rightOutcome = nil

        self.eventNameLabel.text = ""
        self.homeParticipantNameLabel.text = ""
        self.awayParticipantNameLabel.text = ""
        self.matchTimeLabel.text = ""
        self.resultLabel.text = ""

        self.homeOddValueLabel.text = ""
        self.drawOddValueLabel.text = ""
        self.awayOddValueLabel.text = ""

        self.isLeftOutcomeButtonSelected = false
        self.isMiddleOutcomeButtonSelected = false
        self.isRightOutcomeButtonSelected = false
        
        self.homeUpChangeOddValueImage.alpha = 0.0
        self.homeDownChangeOddValueImage.alpha = 0.0
        self.drawUpChangeOddValueImage.alpha = 0.0
        self.drawDownChangeOddValueImage.alpha = 0.0
        self.awayUpChangeOddValueImage.alpha = 0.0
        self.awayDownChangeOddValueImage.alpha = 0.0

        self.currentHomeOddValue = nil
        self.currentDrawOddValue = nil
        self.currentAwayOddValue = nil

        self.leftOddButtonSubscriber?.cancel()
        self.leftOddButtonSubscriber = nil
        self.middleOddButtonSubscriber?.cancel()
        self.middleOddButtonSubscriber = nil
        self.rightOddButtonSubscriber?.cancel()
        self.rightOddButtonSubscriber = nil

        self.locationFlagImageView.isHidden = false
        self.locationFlagImageView.image = nil

        self.oddsStackView.alpha = 1.0
        
        self.awayBaseView.isHidden = false
    }

    func setupWithTheme() {
        self.baseView.backgroundColor = UIColor.App.secondaryBackground

        self.numberOfBetsLabels.textColor = UIColor.App.headingMain
        self.eventNameLabel.textColor = UIColor.App.headingSecondary
        self.homeParticipantNameLabel.textColor = UIColor.App.headingMain
        self.awayParticipantNameLabel.textColor = UIColor.App.headingMain
        self.matchTimeLabel.textColor = UIColor.App.headingSecondary
        self.resultLabel.textColor = UIColor.App.headingMain
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

        self.resultLabel.text = ""
        self.matchTimeLabel.text = ""

       // self.sportTypeImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModel.countryISOCode))
        self.locationFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModel.countryISOCode))

        if let market = match.markets.first {
            if let outcome = market.outcomes[safe: 0] {
                self.homeOddTitleLabel.text = outcome.typeName
                self.homeOddValueLabel.text = "\(Double(floor(outcome.bettingOffer.value * 100)/100))"
                self.currentHomeOddValue = outcome.bettingOffer.value
                self.leftOutcome = outcome

                self.isLeftOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)
                
                self.leftOddButtonSubscriber = Env.everyMatrixStorage
                    .oddPublisherForBettingOfferId(outcome.bettingOffer.id)?
                    .map(\.oddsValue)
                    .compactMap({ $0 })
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] newOddValue in

                        guard let weakSelf = self else { return }

                        if let currentOddValue = weakSelf.currentHomeOddValue {
                            if newOddValue > currentOddValue {
                                weakSelf.highlightOddChangeUp(animated: true,
                                                           upChangeOddValueImage: weakSelf.homeUpChangeOddValueImage,
                                                           baseView: weakSelf.homeBaseView)
                            }
                            else if newOddValue < currentOddValue {
                                weakSelf.highlightOddChangeDown(animated: true,
                                                           downChangeOddValueImage: weakSelf.homeDownChangeOddValueImage,
                                                           baseView: weakSelf.homeBaseView)
                            }
                        }
                        weakSelf.currentHomeOddValue = newOddValue
                        weakSelf.homeOddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
                    })
            }

            if let outcome = market.outcomes[safe: 1] {
                self.drawOddTitleLabel.text = outcome.typeName
                self.drawOddValueLabel.text = "\(Double(floor(outcome.bettingOffer.value * 100)/100))"
                self.currentDrawOddValue = outcome.bettingOffer.value
                self.middleOutcome = outcome

                self.isMiddleOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)
                
                self.middleOddButtonSubscriber = Env.everyMatrixStorage
                    .oddPublisherForBettingOfferId(outcome.bettingOffer.id)?
                    .map(\.oddsValue)
                    .compactMap({ $0 })
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] newOddValue in

                        guard let weakSelf = self else { return }

                        if let currentOddValue = weakSelf.currentDrawOddValue {
                            if newOddValue > currentOddValue {
                                weakSelf.highlightOddChangeUp(animated: true,
                                                           upChangeOddValueImage: weakSelf.drawUpChangeOddValueImage,
                                                           baseView: weakSelf.drawBaseView)
                            }
                            else if newOddValue < currentOddValue {
                                weakSelf.highlightOddChangeDown(animated: true,
                                                           downChangeOddValueImage: weakSelf.drawDownChangeOddValueImage,
                                                           baseView: weakSelf.drawBaseView)
                            }
                        }
                        weakSelf.currentDrawOddValue = newOddValue
                        weakSelf.drawOddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
                    })
            }

            if let outcome = market.outcomes[safe: 2] {
                self.awayOddTitleLabel.text = outcome.typeName
                self.awayOddValueLabel.text = "\(Double(floor(outcome.bettingOffer.value * 100)/100))"
                self.currentAwayOddValue = outcome.bettingOffer.value
                self.rightOutcome = outcome

                self.isRightOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

                self.rightOddButtonSubscriber = Env.everyMatrixStorage
                    .oddPublisherForBettingOfferId(outcome.bettingOffer.id)?
                    .map(\.oddsValue)
                    .compactMap({ $0 })
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] newOddValue in

                        guard let weakSelf = self else { return }

                        if let currentOddValue = weakSelf.currentAwayOddValue {
                            if newOddValue > currentOddValue {
                                weakSelf.highlightOddChangeUp(animated: true,
                                                           upChangeOddValueImage: weakSelf.awayUpChangeOddValueImage,
                                                           baseView: weakSelf.awayBaseView)
                            }
                            else if newOddValue < currentOddValue {
                                weakSelf.highlightOddChangeDown(animated: true,
                                                           downChangeOddValueImage: weakSelf.awayDownChangeOddValueImage,
                                                           baseView: weakSelf.awayBaseView)
                            }
                        }

                        weakSelf.currentAwayOddValue = newOddValue
                        weakSelf.awayOddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
                    })
            }
            if market.outcomes.count == 2 {
               
                awayBaseView.isHidden = true
            }
        }
        else {
            Logger.log("No markets found")
            oddsStackView.alpha = 0.2

            self.homeOddValueLabel.text = "---"
            self.drawOddValueLabel.text = "---"
            self.awayOddValueLabel.text = "---"
        }

        var homeGoals = ""
        var awayGoals = ""
        var minutes = ""
        var matchPart = ""

        if let matchInfoArray = Env.everyMatrixStorage.matchesInfoForMatch[match.id] {
            for matchInfoId in matchInfoArray {
                if let matchInfo = Env.everyMatrixStorage.matchesInfo[matchInfoId] {
                    if (matchInfo.typeId ?? "") == "1" {
                        // Goals
                        if let homeGoalsFloat = matchInfo.paramFloat1 {
                            if self.match?.homeParticipant.id == matchInfo.paramParticipantId1 {
                                homeGoals = "\(homeGoalsFloat)"
                            }
                            else if self.match?.awayParticipant.id == matchInfo.paramParticipantId1 {
                                awayGoals = "\(homeGoalsFloat)"
                            }
                        }
                        if let awayGoalsFloat = matchInfo.paramFloat2 {
                            if self.match?.homeParticipant.id == matchInfo.paramParticipantId2 {
                                homeGoals = "\(awayGoalsFloat)"
                            }
                            else if self.match?.awayParticipant.id == matchInfo.paramParticipantId2 {
                                awayGoals = "\(awayGoalsFloat)"
                            }
                        }
                    }
                    else if (matchInfo.typeId ?? "") == "95", let awayGoalsFloat = matchInfo.paramFloat1 {
                        // Match Minutes
                        minutes = "\(awayGoalsFloat)"
                    }
                    else if (matchInfo.typeId ?? "") == "92", let eventPartName = matchInfo.paramEventPartName1 {
                        // Status
                        matchPart = eventPartName
                    }
                }
            }
        }

        if homeGoals.isNotEmpty && awayGoals.isNotEmpty {
            self.resultLabel.text = "\(homeGoals) - \(awayGoals)"
        }

        if minutes.isNotEmpty && matchPart.isNotEmpty {
            self.matchTimeLabel.text = "\(minutes)' - \(matchPart)"
        }
        else if minutes.isNotEmpty {
            self.matchTimeLabel.text = "\(minutes)'"
        }
        else if matchPart.isNotEmpty {
            self.matchTimeLabel.text = "\(matchPart)"
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
        self.locationFlagImageView.isHidden = !show
    }

    @IBAction private func didTapFavoritesButton(_ sender: Any) {

    }

    @IBAction func didTapMatchView(_ sender: Any) {
        self.tappedMatchWidgetAction?()
    }
    
    func selectLeftOddButton() {
        self.homeBaseView.backgroundColor = UIColor.App.mainTint
    }
    func deselectLeftOddButton() {
        self.homeBaseView.backgroundColor = UIColor.App.tertiaryBackground
    }
    @objc func didTapLeftOddButton() {

        guard
            let match = self.match,
            let firstMarket = self.match?.markets.first,
            let outcome = self.leftOutcome
        else {
            return
        }

        let matchDescription = "\(match.homeParticipant.name) x \(match.awayParticipant.name)"
        let marketDescription = firstMarket.name
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
        self.drawBaseView.backgroundColor = UIColor.App.mainTint
    }
    func deselectMiddleOddButton() {
        self.drawBaseView.backgroundColor = UIColor.App.tertiaryBackground
    }
    @objc func didTapMiddleOddButton() {
        guard
            let match = self.match,
            let firstMarket = self.match?.markets.first,
            let outcome = self.middleOutcome
        else {
            return
        }

        let matchDescription = "\(match.homeParticipant.name) x \(match.awayParticipant.name)"
        let marketDescription = firstMarket.name
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
        self.awayBaseView.backgroundColor = UIColor.App.mainTint
    }
    func deselectRightOddButton() {
        self.awayBaseView.backgroundColor = UIColor.App.tertiaryBackground
    }
    @objc func didTapRightOddButton() {
        guard
            let match = self.match,
            let firstMarket = self.match?.markets.first,
            let outcome = self.rightOutcome
        else {
            return
        }

        let matchDescription = "\(match.homeParticipant.name) x \(match.awayParticipant.name)"
        let marketDescription = firstMarket.name
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

extension LiveMatchWidgetCollectionViewCell {

}
