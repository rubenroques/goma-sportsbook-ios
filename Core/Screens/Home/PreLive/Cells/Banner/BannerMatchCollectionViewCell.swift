//
//  BannerMatchCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 12/10/2021.
//

import UIKit
import Combine

class BannerMatchCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var baseView: UIView!

    //
    @IBOutlet private weak var imageBaseView: UIView!
    @IBOutlet private weak var imageView: UIImageView!

    @IBOutlet private weak var matchBaseView: UIView!
    @IBOutlet private weak var matchOffuscationView: UIView!
    @IBOutlet private weak var matchGradientView: UIView!
    @IBOutlet private weak var centerView: UIView!

    @IBOutlet private weak var participantsBaseView: UIView!

    @IBOutlet private weak var homeParticipantNameLabel: UILabel!
    @IBOutlet private weak var awayParticipantNameLabel: UILabel!

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!

    @IBOutlet private weak var oddsStackView: UIStackView!

    @IBOutlet private weak var homeBaseView: UIView!
    @IBOutlet private weak var homeOddTitleLabel: UILabel!
    @IBOutlet private weak var homeOddValueLabel: UILabel!

    @IBOutlet private weak var drawBaseView: UIView!
    @IBOutlet private weak var drawOddTitleLabel: UILabel!
    @IBOutlet private weak var drawOddValueLabel: UILabel!

    @IBOutlet private weak var awayBaseView: UIView!
    @IBOutlet private weak var awayOddTitleLabel: UILabel!
    @IBOutlet private weak var awayOddValueLabel: UILabel!

    var cancellables = Set<AnyCancellable>()

    var viewModel: BannerCellViewModel?

    var matchViewModel: MatchWidgetCellViewModel? {
        didSet {
            if let matchViewModelValue = self.matchViewModel {

                self.homeParticipantNameLabel.text = "\(matchViewModelValue.homeTeamName)"
                self.awayParticipantNameLabel.text = "\(matchViewModelValue.awayTeamName)"
                self.dateLabel.text = "\(matchViewModelValue.startDateString)"
                self.timeLabel.text = "\(matchViewModelValue.startTimeString)"
                if matchViewModelValue.isToday {
                    self.dateLabel.isHidden = true
                }

                self.matchBaseView.isHidden = false
                self.imageView.isHidden = false
            }
        }
    }

    var completeMatch: Match?
    var tappedMatchBaseViewAction: ((Match) -> Void)?

    private var leftOutcome: Outcome?
    private var middleOutcome: Outcome?
    private var rightOutcome: Outcome?

    private var leftOddButtonSubscriber: AnyCancellable?
    private var middleOddButtonSubscriber: AnyCancellable?
    private var rightOddButtonSubscriber: AnyCancellable?

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

        self.bringSubviewToFront(self.matchBaseView)

        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.centerView.backgroundColor = .clear

        self.baseView.clipsToBounds = true
        self.baseView.alpha = 1.0

        self.participantsBaseView.backgroundColor = .clear
        self.oddsStackView.backgroundColor = .clear
        self.homeBaseView.backgroundColor = .clear
        self.drawBaseView.backgroundColor = .clear
        self.awayBaseView.backgroundColor = .clear

        self.homeParticipantNameLabel.text = ""
        self.awayParticipantNameLabel.text = ""
        self.dateLabel.text = ""
        self.timeLabel.text = ""

        let tapLeftOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapLeftOddButton))
        self.homeBaseView.addGestureRecognizer(tapLeftOddButton)

        let tapMiddleOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapMiddleOddButton))
        self.drawBaseView.addGestureRecognizer(tapMiddleOddButton)

        let tapRightOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapRightOddButton))
        self.awayBaseView.addGestureRecognizer(tapRightOddButton)

        let tapMatchBaseView = UITapGestureRecognizer(target: self, action: #selector(didTapMatchBaseView))
        self.matchBaseView.addGestureRecognizer(tapMatchBaseView)

        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.homeBaseView.layer.cornerRadius = 4
        self.drawBaseView.layer.cornerRadius = 4
        self.awayBaseView.layer.cornerRadius = 4

        self.baseView.layer.cornerRadius = 8

        self.setupGradient()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.dateLabel.isHidden = false
        self.matchBaseView.isHidden = true

        self.homeParticipantNameLabel.text = ""
        self.awayParticipantNameLabel.text = ""
        self.dateLabel.text = ""
        self.timeLabel.text = ""

        self.viewModel = nil
        self.completeMatch = nil

        self.leftOutcome = nil
        self.middleOutcome = nil
        self.rightOutcome = nil

        self.leftOddButtonSubscriber?.cancel()
        self.leftOddButtonSubscriber = nil
        self.middleOddButtonSubscriber?.cancel()
        self.middleOddButtonSubscriber = nil
        self.rightOddButtonSubscriber?.cancel()
        self.rightOddButtonSubscriber = nil

        self.isLeftOutcomeButtonSelected = false
        self.isMiddleOutcomeButtonSelected = false
        self.isRightOutcomeButtonSelected = false

        self.homeOddValueLabel.text = ""
        self.drawOddValueLabel.text = ""
        self.awayOddValueLabel.text = ""
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear

        self.matchBaseView.backgroundColor = .clear
        self.imageBaseView.backgroundColor = .clear

        self.baseView.backgroundColor = UIColor.App2.backgroundCards

        self.homeParticipantNameLabel.textColor = UIColor.App2.textPrimary
        self.awayParticipantNameLabel.textColor = UIColor.App2.textPrimary
        self.dateLabel.textColor = UIColor.App2.textPrimary
        self.timeLabel.textColor = UIColor.App2.textPrimary

        self.homeOddTitleLabel.textColor = UIColor.App2.textPrimary
        self.homeOddValueLabel.textColor = UIColor.App2.textPrimary
        self.drawOddTitleLabel.textColor = UIColor.App2.textPrimary
        self.drawOddValueLabel.textColor = UIColor.App2.textPrimary
        self.awayOddTitleLabel.textColor = UIColor.App2.textPrimary
        self.awayOddValueLabel.textColor = UIColor.App2.textPrimary

        self.homeBaseView.backgroundColor = UIColor.App2.backgroundOdds
        self.drawBaseView.backgroundColor = UIColor.App2.backgroundOdds
        self.awayBaseView.backgroundColor = UIColor.App2.backgroundOdds

        self.matchOffuscationView.backgroundColor = UIColor.App2.backgroundSecondary
        self.matchOffuscationView.alpha = 0.66

        self.setupGradient()
    }

    func setupGradient() {
        self.matchGradientView.alpha = 1.0
        self.matchGradientView.backgroundColor = UIColor.App2.backgroundSecondary

        let rightGradientMaskLayer = CAGradientLayer()
        rightGradientMaskLayer.frame = matchGradientView.bounds
        rightGradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.white.cgColor]
        rightGradientMaskLayer.locations = [0.0, 0.48, 1.0]
        rightGradientMaskLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        rightGradientMaskLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        self.matchGradientView.layer.mask = rightGradientMaskLayer
    }

    func setupWithViewModel(_ viewModel: BannerCellViewModel) {
        self.viewModel = viewModel

        self.matchBaseView.isHidden = true
        self.imageView.isHidden = true

        switch viewModel.presentationType {
        case .match:
            if let url = viewModel.imageURL {
                self.imageView.kf.setImage(with: url)
            }
            viewModel.match
                .receive(on: DispatchQueue.main)
                .compactMap({$0}).sink { [weak self] match in
                    self?.matchViewModel = MatchWidgetCellViewModel(match: match)
                }
                .store(in: &cancellables)

            viewModel.completeMatch
                .receive(on: DispatchQueue.main)
                .compactMap({$0}).sink { [weak self] completeMatch in
                    self?.completeMatch = completeMatch
                    self?.setupWithMatch(completeMatch)
                }
                .store(in: &cancellables)

        case .image:
            self.imageView.isHidden = false
            if let url = viewModel.imageURL {
                self.imageView.kf.setImage(with: url)
            }
        }

    }

    func setupWithMatch(_ match: Match) {

        // let viewModel = MatchWidgetCellViewModel(match: match)
        guard let viewModel = self.matchViewModel else {
            return
        }

        guard let cellViewModel = self.viewModel else {
            return
        }

        // self.eventNameLabel.text = "\(viewModel.competitionName)"
        self.homeParticipantNameLabel.text = "\(viewModel.homeTeamName)"
        self.awayParticipantNameLabel.text = "\(viewModel.awayTeamName)"
        self.dateLabel.text = "\(viewModel.startDateString)"
        self.timeLabel.text = "\(viewModel.startTimeString)"

       // self.sportTypeImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModel.countryISOCode))
        // self.locationFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModel.countryISOCode))

        if viewModel.isToday {
            self.dateLabel.isHidden = true
        }

        if let market = match.markets.first {
            if let outcome = market.outcomes[safe: 0] {
                self.homeOddTitleLabel.text = outcome.typeName
                self.homeOddValueLabel.text = "\(Double(floor(outcome.bettingOffer.value * 100)/100))"
                // self.currentHomeOddValue = outcome.bettingOffer.value
                self.leftOutcome = outcome

                self.isLeftOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

                self.leftOddButtonSubscriber = cellViewModel.oddPublisherForBettingOfferId(outcome.bettingOffer.id)?
                    .map(\.oddsValue)
                    .compactMap({ $0 })
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] newOddValue in

                        guard let weakSelf = self else { return }

//                        if let currentOddValue = weakSelf.currentHomeOddValue {
//                            if newOddValue > currentOddValue {
//                                weakSelf.highlightOddChangeUp(animated: true,
//                                                           upChangeOddValueImage: weakSelf.homeUpChangeOddValueImage,
//                                                           baseView: weakSelf.homeBaseView)
//                            }
//                            else if newOddValue < currentOddValue {
//                                weakSelf.highlightOddChangeDown(animated: true,
//                                                           downChangeOddValueImage: weakSelf.homeDownChangeOddValueImage,
//                                                           baseView: weakSelf.homeBaseView)
//                            }
//                        }
//                        weakSelf.currentHomeOddValue = newOddValue
                        weakSelf.homeOddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
                    })

            }
            if let outcome = market.outcomes[safe: 1] {
                self.drawOddTitleLabel.text = outcome.typeName
                self.drawOddValueLabel.text = "\(Double(floor(outcome.bettingOffer.value * 100)/100))"
                // self.currentDrawOddValue = outcome.bettingOffer.value
                self.middleOutcome = outcome

                self.isMiddleOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

                self.middleOddButtonSubscriber = cellViewModel.oddPublisherForBettingOfferId(outcome.bettingOffer.id)?
                    .map(\.oddsValue)
                    .compactMap({ $0 })
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] newOddValue in

                        guard let weakSelf = self else { return }

//                        if let currentOddValue = weakSelf.currentDrawOddValue {
//                            if newOddValue > currentOddValue {
//                                weakSelf.highlightOddChangeUp(animated: true,
//                                                           upChangeOddValueImage: weakSelf.drawUpChangeOddValueImage,
//                                                           baseView: weakSelf.drawBaseView)
//                            }
//                            else if newOddValue < currentOddValue {
//                                weakSelf.highlightOddChangeDown(animated: true,
//                                                           downChangeOddValueImage: weakSelf.drawDownChangeOddValueImage,
//                                                           baseView: weakSelf.drawBaseView)
//                            }
//                        }
//                        weakSelf.currentDrawOddValue = newOddValue
                        weakSelf.drawOddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
                    })
            }
            if let outcome = market.outcomes[safe: 2] {
                self.awayOddTitleLabel.text = outcome.typeName
                self.awayOddValueLabel.text = "\(Double(floor(outcome.bettingOffer.value * 100)/100))"
                // self.currentAwayOddValue = outcome.bettingOffer.value
                self.rightOutcome = outcome

                self.isRightOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

                self.rightOddButtonSubscriber = cellViewModel.oddPublisherForBettingOfferId(outcome.bettingOffer.id)?
                    .map(\.oddsValue)
                    .compactMap({ $0 })
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] newOddValue in

                        guard let weakSelf = self else { return }

//                        if let currentOddValue = weakSelf.currentAwayOddValue {
//                            if newOddValue > currentOddValue {
//                                weakSelf.highlightOddChangeUp(animated: true,
//                                                           upChangeOddValueImage: weakSelf.awayUpChangeOddValueImage,
//                                                           baseView: weakSelf.awayBaseView)
//                            }
//                            else if newOddValue < currentOddValue {
//                                weakSelf.highlightOddChangeDown(animated: true,
//                                                           downChangeOddValueImage: weakSelf.awayDownChangeOddValueImage,
//                                                           baseView: weakSelf.awayBaseView)
//                            }
//                        }
//
//                        weakSelf.currentAwayOddValue = newOddValue
                        weakSelf.awayOddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
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

    }

    func selectLeftOddButton() {
        self.homeBaseView.backgroundColor = UIColor.App2.buttonBackgroundPrimary
        self.homeOddValueLabel.textColor = UIColor.App2.buttonTextPrimary
        self.homeOddTitleLabel.textColor = UIColor.App2.buttonTextPrimary
    }
    func deselectLeftOddButton() {
        self.homeBaseView.backgroundColor = UIColor.App2.backgroundOdds
        self.homeOddValueLabel.textColor = UIColor.App2.textPrimary
        self.homeOddTitleLabel.textColor = UIColor.App2.textPrimary
    }

    @objc func didTapLeftOddButton() {
        guard
            let match = self.completeMatch,
            let firstMarket = self.completeMatch?.markets.first,
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
        self.drawBaseView.backgroundColor = UIColor.App2.buttonBackgroundPrimary
        self.drawOddValueLabel.textColor = UIColor.App2.buttonTextPrimary
        self.drawOddTitleLabel.textColor = UIColor.App2.buttonTextPrimary
    }
    func deselectMiddleOddButton() {
        self.drawBaseView.backgroundColor = UIColor.App2.backgroundOdds
        self.drawOddTitleLabel.textColor = UIColor.App2.textPrimary
        self.drawOddValueLabel.textColor = UIColor.App2.textPrimary
    }

    @objc func didTapMiddleOddButton() {
        guard
            let match = self.completeMatch,
            let firstMarket = self.completeMatch?.markets.first,
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
        self.awayBaseView.backgroundColor = UIColor.App2.buttonBackgroundPrimary
        self.awayOddValueLabel.textColor = UIColor.App2.buttonTextPrimary
        self.awayOddTitleLabel.textColor = UIColor.App2.buttonTextPrimary
    }
    func deselectRightOddButton() {
        self.awayBaseView.backgroundColor = UIColor.App2.backgroundOdds
        self.awayOddValueLabel.textColor = UIColor.App2.textPrimary
        self.awayOddTitleLabel.textColor = UIColor.App2.textPrimary
    }

    @objc func didTapRightOddButton() {
        guard
            let match = self.completeMatch,
            let firstMarket = self.completeMatch?.markets.first,
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

    @objc func didTapMatchBaseView() {

        guard let completeMatch = self.completeMatch else { return }

        self.tappedMatchBaseViewAction?(completeMatch)

    }
}
