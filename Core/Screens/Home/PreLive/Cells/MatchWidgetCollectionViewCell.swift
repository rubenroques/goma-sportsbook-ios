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

    @IBOutlet private weak var baseView: UIView!

    @IBOutlet private weak var favoritesIconImageView: UIImageView!

    @IBOutlet private weak var numberOfBetsLabels: UILabel!
    
    @IBOutlet private weak var eventNameLabel: UILabel!
    @IBOutlet private weak var locationFlagImageView: UIImageView!

    @IBOutlet private weak var favoritesButton: UIButton!

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

    @IBOutlet private weak var homeUpChangeOddValueImage: UIImageView!
    @IBOutlet private weak var homeDownChangeOddValueImage: UIImageView!
    @IBOutlet private weak var drawUpChangeOddValueImage: UIImageView!
    @IBOutlet private weak var drawDownChangeOddValueImage: UIImageView!
    @IBOutlet private weak var awayUpChangeOddValueImage: UIImageView!
    @IBOutlet private weak var awayDownChangeOddValueImage: UIImageView!

    @IBOutlet private weak var suspendedBaseView: UIView!
    @IBOutlet private weak var suspendedLabel: UILabel!

    var viewModel: MatchWidgetCellViewModel? {
        didSet {
            if let viewModelValue = self.viewModel {
                self.eventNameLabel.text = "\(viewModelValue.competitionName)"
                self.homeParticipantNameLabel.text = "\(viewModelValue.homeTeamName)"
                self.awayParticipantNameLabel.text = "\(viewModelValue.awayTeamName)"
                self.dateLabel.text = "\(viewModelValue.startDateString)"
                self.timeLabel.text = "\(viewModelValue.startTimeString)"

                if viewModelValue.countryISOCode != "" {
                    self.locationFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModelValue.countryISOCode))
                }
                else {
                    self.locationFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModelValue.countryId))
                }

            }
        }
    }

    static var cellHeight: CGFloat = 156

    var match: Match?
    var snapshot: UIImage?

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

    var tappedMatchWidgetAction: (() -> Void)?

    private var leftOddButtonSubscriber: AnyCancellable?
    private var middleOddButtonSubscriber: AnyCancellable?
    private var rightOddButtonSubscriber: AnyCancellable?

    private var marketSubscriber: AnyCancellable?

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

    private var leftOutcomeDisabled: Bool = false
    private var middleOutcomeDisabled: Bool = false
    private var rightOutcomeDisabled: Bool = false

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

        self.awayBaseView.isHidden = false

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
        self.snapshot = nil

        self.leftOutcome = nil
        self.middleOutcome = nil
        self.rightOutcome = nil

        self.leftOddButtonSubscriber?.cancel()
        self.leftOddButtonSubscriber = nil
        self.middleOddButtonSubscriber?.cancel()
        self.middleOddButtonSubscriber = nil
        self.rightOddButtonSubscriber?.cancel()
        self.rightOddButtonSubscriber = nil

        self.marketSubscriber?.cancel()
        self.marketSubscriber = nil
        
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

        self.homeBaseView.isUserInteractionEnabled = true
        self.drawBaseView.isUserInteractionEnabled = true
        self.awayBaseView.isUserInteractionEnabled = true

        self.homeBaseView.alpha = 1.0
        self.drawBaseView.alpha = 1.0
        self.awayBaseView.alpha = 1.0

        self.locationFlagImageView.isHidden = false
        self.locationFlagImageView.image = nil

        self.oddsStackView.alpha = 1.0
        
        self.awayBaseView.isHidden = false

        self.isFavorite = false

        self.leftOutcomeDisabled = false
        self.middleOutcomeDisabled = false
        self.rightOutcomeDisabled = false
        self.suspendedBaseView.isHidden = true
    }

    func setupWithTheme() {
        self.baseView.backgroundColor = UIColor.App.backgroundCards
        self.numberOfBetsLabels.textColor = UIColor.App.textPrimary
        self.eventNameLabel.textColor = UIColor.App.textSecond
        self.homeParticipantNameLabel.textColor = UIColor.App.textPrimary
        self.awayParticipantNameLabel.textColor = UIColor.App.textPrimary
        self.dateLabel.textColor = UIColor.App.textPrimary
        self.timeLabel.textColor = UIColor.App.textPrimary
        self.homeOddTitleLabel.textColor = UIColor.App.textPrimary
        self.homeOddValueLabel.textColor = UIColor.App.textPrimary
        self.drawOddTitleLabel.textColor = UIColor.App.textPrimary
        self.drawOddValueLabel.textColor = UIColor.App.textPrimary
        self.awayOddTitleLabel.textColor = UIColor.App.textPrimary
        self.awayOddValueLabel.textColor = UIColor.App.textPrimary

        self.homeBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.drawBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.awayBaseView.backgroundColor = UIColor.App.backgroundOdds

        self.suspendedBaseView.backgroundColor = UIColor.App.backgroundDisabledOdds
        self.suspendedLabel.textColor = UIColor.App.textDisablePrimary
        
    }

    func configure(withViewModel viewModel: MatchWidgetCellViewModel) {

        self.viewModel = viewModel

        if let viewModel = self.viewModel {
            self.eventNameLabel.text = "\(viewModel.competitionName)"
            self.homeParticipantNameLabel.text = "\(viewModel.homeTeamName)"
            self.awayParticipantNameLabel.text = "\(viewModel.awayTeamName)"
            self.dateLabel.text = "\(viewModel.startDateString)"
            self.timeLabel.text = "\(viewModel.startTimeString)"

            // self.sportTypeImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModel.countryISOCode))
            if viewModel.countryISOCode != "" {
                self.locationFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModel.countryISOCode))
            }
            else {
                self.locationFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModel.countryId))
            }

            if let match = viewModel.match {
                self.setupMarketsWithStore(match: match)

                for matchId in Env.favoritesManager.favoriteEventsIdPublisher.value {
                    if matchId == match.id {
                        self.isFavorite = true
                    }
                }
            }
        }
    }

    func setupMarketsWithStore(match: Match) {
        if let market = match.markets.first {

            if let marketPublisher = self.viewModel?.store?.marketPublisher(withId: market.id) {
                self.marketSubscriber = marketPublisher
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] marketUpdate in
                        if marketUpdate.isAvailable ?? true {
                            self?.showMarketButtons()
                        }
                        else {
                            if marketUpdate.isClosed ?? false {
                                self?.showClosedView()
                            }
                            else {
                                self?.showSuspendedView()
                            }
                        }
                    }
            }
            
            if let outcome = market.outcomes[safe: 0] {
                self.homeOddTitleLabel.text = outcome.typeName
                //self.homeOddValueLabel.text = OddFormatter.formatOdd(withValue: outcome.bettingOffer.value)
                // self.currentHomeOddValue = outcome.bettingOffer.value
                self.leftOutcome = outcome

                self.isLeftOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

                if outcome.bettingOffer.value < 1.0 {
                    self.setOddViewDisabled(disabled: true, oddViewPosition: .left)
                    self.homeOddValueLabel.text = "-"
                }
                else {
                    self.homeOddValueLabel.text = OddFormatter.formatOdd(withValue: outcome.bettingOffer.value)
                }

                self.leftOddButtonSubscriber = self.viewModel?.store?.bettingOfferPublisher(withId: outcome.bettingOffer.id)?
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
                        weakSelf.setOddViewDisabled(disabled: false, oddViewPosition: .left)
                    })

            }

            if let outcome = market.outcomes[safe: 1] {
                self.drawOddTitleLabel.text = outcome.typeName
                // self.drawOddValueLabel.text = OddFormatter.formatOdd(withValue: outcome.bettingOffer.value)
                // self.currentDrawOddValue = outcome.bettingOffer.value
                self.middleOutcome = outcome

                self.isMiddleOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

                if outcome.bettingOffer.value < 1.0 {
                    self.setOddViewDisabled(disabled: true, oddViewPosition: .middle)
                    self.drawOddValueLabel.text = "-"
                }
                else {
                    self.drawOddValueLabel.text = OddFormatter.formatOdd(withValue: outcome.bettingOffer.value)
                }

                self.middleOddButtonSubscriber = self.viewModel?.store?.bettingOfferPublisher(withId: outcome.bettingOffer.id)?
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
                        weakSelf.setOddViewDisabled(disabled: false, oddViewPosition: .middle)
                    })
            }

            if let outcome = market.outcomes[safe: 2] {
                self.awayOddTitleLabel.text = outcome.typeName
                //self.awayOddValueLabel.text = OddFormatter.formatOdd(withValue: outcome.bettingOffer.value)
                // self.currentAwayOddValue = outcome.bettingOffer.value
                self.rightOutcome = outcome

                self.isRightOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

                if outcome.bettingOffer.value < 1.0 {
                    self.setOddViewDisabled(disabled: true, oddViewPosition: .right)
                    self.awayOddValueLabel.text = "-"
                    self.awayBaseView.backgroundColor = UIColor.App.backgroundDisabledOdds
                }
                else {
                    self.awayOddValueLabel.text = OddFormatter.formatOdd(withValue: outcome.bettingOffer.value)
                }

                self.rightOddButtonSubscriber = self.viewModel?.store?.bettingOfferPublisher(withId: outcome.bettingOffer.id)?
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
                        weakSelf.setOddViewDisabled(disabled: false, oddViewPosition: .right)
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
    }

    func setOddViewDisabled(disabled: Bool, oddViewPosition: OddViewPosition) {
        if disabled {
            switch oddViewPosition {
            case .left:
                self.homeBaseView.backgroundColor = UIColor.App.backgroundDisabledOdds
                self.homeOddValueLabel.textColor = UIColor.App.textDisablePrimary
                self.homeOddTitleLabel.textColor = UIColor.App.textDisablePrimary
                self.leftOutcomeDisabled = disabled
            case .middle:
                self.drawBaseView.backgroundColor = UIColor.App.backgroundDisabledOdds
                self.drawOddValueLabel.textColor = UIColor.App.textDisablePrimary
                self.drawOddTitleLabel.textColor = UIColor.App.textDisablePrimary
                self.middleOutcomeDisabled = disabled
            case .right:
                self.awayBaseView.backgroundColor = UIColor.App.backgroundDisabledOdds
                self.awayOddValueLabel.textColor = UIColor.App.textDisablePrimary
                self.awayOddTitleLabel.textColor = UIColor.App.textDisablePrimary
                self.rightOutcomeDisabled = disabled
            }

        }
        else {
            switch oddViewPosition {
            case .left:
                self.homeBaseView.backgroundColor = UIColor.App.backgroundOdds
                self.homeOddValueLabel.textColor = UIColor.App.textPrimary
                self.homeOddTitleLabel.textColor = UIColor.App.textPrimary
                self.leftOutcomeDisabled = disabled

            case .middle:
                self.drawBaseView.backgroundColor = UIColor.App.backgroundOdds
                self.drawOddValueLabel.textColor = UIColor.App.textPrimary
                self.drawOddTitleLabel.textColor = UIColor.App.textPrimary
                self.middleOutcomeDisabled = disabled

            case .right:
                self.awayBaseView.backgroundColor = UIColor.App.backgroundOdds
                self.awayOddValueLabel.textColor = UIColor.App.textPrimary
                self.awayOddValueLabel.textColor = UIColor.App.textPrimary
                self.rightOutcomeDisabled = disabled
            }
        }
    }

    //
    //
    private func showMarketButtons() {
        self.suspendedBaseView.isHidden = true
    }

    private func showSuspendedView() {
        self.suspendedLabel.text = localized("suspended_market")
        self.suspendedBaseView.isHidden = false
    }

    func shouldShowCountryFlag(_ show: Bool) {
        self.locationFlagImageView.isHidden = !show
    }

    private func showClosedView() {
        self.suspendedLabel.text = localized("closed_market")
        self.suspendedBaseView.isHidden = false
    }

    //
    //
    @IBAction private func didTapFavoritesButton(_ sender: Any) {
        if UserDefaults.standard.userSession != nil {

            if self.isFavorite {
                if let matchId = self.viewModel?.match?.id {
                    Env.favoritesManager.removeFavorite(eventId: matchId, favoriteType: "event")
                }
                self.isFavorite = false
            }
            else {
                if let matchId = self.viewModel?.match?.id {
                    Env.favoritesManager.addFavorite(eventId: matchId, favoriteType: "event")
                }
                self.isFavorite = true
            }
        }
    }

    @IBAction private func didTapMatchView(_ sender: Any) {
        let renderer = UIGraphicsImageRenderer(size: self.contentView.bounds.size)
        let image = renderer.image { _ in
            self.contentView.drawHierarchy(in: self.contentView.bounds, afterScreenUpdates: true)
        }
        self.snapshot = image
        
        self.tappedMatchWidgetAction?()
    }

    // TODO: This func is called even if the cell is reused
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

    //
    func selectLeftOddButton() {
        self.homeBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.homeOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
        self.homeOddValueLabel.textColor = UIColor.App.buttonTextPrimary
    }

    func deselectLeftOddButton() {
        self.homeBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.homeOddTitleLabel.textColor = UIColor.App.textPrimary
        self.homeOddValueLabel.textColor = UIColor.App.textPrimary
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
                                          marketId: firstMarket.id,
                                          matchId: match.id,
                                          value: outcome.bettingOffer.value,
                                          isAvailable: outcome.bettingOffer.isAvailable,
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

    //
    func selectMiddleOddButton() {
        self.drawBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.drawOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
        self.drawOddValueLabel.textColor = UIColor.App.buttonTextPrimary
    }

    func deselectMiddleOddButton() {
        self.drawBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.drawOddTitleLabel.textColor = UIColor.App.textPrimary
        self.drawOddValueLabel.textColor = UIColor.App.textPrimary
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
                                          marketId: firstMarket.id,
                                          matchId: match.id,
                                          value: outcome.bettingOffer.value,
                                          isAvailable: outcome.bettingOffer.isAvailable,
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

    //
    func selectRightOddButton() {
        self.awayBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.awayOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
        self.awayOddValueLabel.textColor = UIColor.App.buttonTextPrimary
    }

    func deselectRightOddButton() {
        self.awayBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.awayOddTitleLabel.textColor = UIColor.App.textPrimary
        self.awayOddValueLabel.textColor = UIColor.App.textPrimary
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
                                          marketId: firstMarket.id,
                                          matchId: match.id,
                                          value: outcome.bettingOffer.value,
                                          isAvailable: outcome.bettingOffer.isAvailable,
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
