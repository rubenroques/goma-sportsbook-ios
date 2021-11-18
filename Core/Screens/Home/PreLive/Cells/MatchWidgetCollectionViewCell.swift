//
//  MatchWidgetCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 30/09/2021.
//

import UIKit
import Kingfisher
import Combine

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

    @IBOutlet weak var homeUpChangeOddValueImage: UIImageView!
    @IBOutlet weak var homeDownChangeOddValueImage: UIImageView!
    @IBOutlet weak var drawUpChangeOddValueImage: UIImageView!
    @IBOutlet weak var drawDownChangeOddValueImage: UIImageView!
    @IBOutlet weak var awayUpChangeOddValueImage: UIImageView!
    @IBOutlet weak var awayDownChangeOddValueImage: UIImageView!

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


    private var leftOddButtonSubscriber: AnyCancellable?
    private var middleOddButtonSubscriber: AnyCancellable?
    private var rightOddButtonSubscriber: AnyCancellable?

    var match: Match?

    var isFavorite: Bool = false {
            didSet {
                if isFavorite {
                    self.favoritesButton.setImage(UIImage(named: "selected_favorite_icon"), for: .normal)
                }
                else {
                    self.favoritesButton.setImage(UIImage(named: "unselected_favorite_icon"), for: .normal)
                }
            }
        }

    private var leftOutcome: Outcome?
    private var middleOutcome: Outcome?
    private var rightOutcome: Outcome?

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


    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear

        self.baseView.layer.cornerRadius = 9

        self.homeUpChangeOddValueImage.alpha = 0.0
        self.homeDownChangeOddValueImage.alpha = 0.0
        self.drawUpChangeOddValueImage.alpha = 0.0
        self.drawDownChangeOddValueImage.alpha = 0.0
        self.awayUpChangeOddValueImage.alpha = 0.0
        self.awayDownChangeOddValueImage.alpha = 0.0

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

        let tapLeftOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapLeftOddButton))
        self.homeBaseView.addGestureRecognizer(tapLeftOddButton)

        let tapMiddleOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapMiddleOddButton))
        self.drawBaseView.addGestureRecognizer(tapMiddleOddButton)

        let tapRightOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapRightOddButton))
        self.awayBaseView.addGestureRecognizer(tapRightOddButton)

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

        self.leftOddButtonSubscriber?.cancel()
        self.leftOddButtonSubscriber = nil
        self.middleOddButtonSubscriber?.cancel()
        self.middleOddButtonSubscriber = nil
        self.rightOddButtonSubscriber?.cancel()
        self.rightOddButtonSubscriber = nil

        self.currentHomeOddValue = nil
        self.currentDrawOddValue = nil
        self.currentAwayOddValue = nil

        self.isLeftOutcomeButtonSelected = false
        self.isMiddleOutcomeButtonSelected = false
        self.isRightOutcomeButtonSelected = false

        self.dateLabel.isHidden = false
        
        self.eventNameLabel.text = ""
        self.homeParticipantNameLabel.text = ""
        self.awayParticipantNameLabel.text = ""
        self.dateLabel.text = ""
        self.timeLabel.text = ""

        self.homeOddValueLabel.text = ""
        self.drawOddValueLabel.text = ""
        self.awayOddValueLabel.text = ""

        self.locationFlagImageView.isHidden = false
        self.locationFlagImageView.image = nil

        self.oddsStackView.alpha = 1.0

        self.isFavorite = false

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
                        weakSelf.homeOddValueLabel.text = "\(Double(floor(newOddValue * 100)/100))"
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
                        weakSelf.drawOddValueLabel.text = "\(Double(floor(newOddValue * 100)/100))"
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
                        weakSelf.awayOddValueLabel.text = "\(Double(floor(newOddValue * 100)/100))"
                    })

            }
        }
        else {
            Logger.log("No markets found")
            oddsStackView.alpha = 0.2

            self.homeOddValueLabel.text = "---"
            self.drawOddValueLabel.text = "---"
            self.awayOddValueLabel.text = "---"
        }

        for matchId in Env.favoritesManager.favoriteEventsId{
            if matchId == match.id {
                self.isFavorite = true
            }
        }

    }

    func shouldShowCountryFlag(_ show: Bool) {
        self.locationFlagImageView.isHidden = !show
    }

    @IBAction func didTapFavoritesButton(_ sender: Any) {
        if UserDefaults.standard.userSession != nil {

            if let matchId = self.match?.id {
                Env.favoritesManager.checkFavorites(eventId: matchId)
            }

            if self.isFavorite {
                self.isFavorite = false
            }
            else {
                self.isFavorite = true
            }
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
