//
//  LiveMatchWidgetCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/10/2021.
//

import UIKit
import Kingfisher
import LinkPresentation
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
    @IBOutlet private weak var liveIndicatorImageView: UIImageView!
    @IBOutlet private weak var resultCenterStackView: UIStackView!

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

    //
    // Design Constraints
    @IBOutlet private weak var topMarginSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomMarginSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leadingMarginSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var trailingMarginSpaceConstraint: NSLayoutConstraint!

    @IBOutlet private weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var teamsHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var resultCenterConstraint: NSLayoutConstraint!
    @IBOutlet private weak var buttonsHeightConstraint: NSLayoutConstraint!

    private var cachedCardsStyle: CardsStyle?
    //

    var viewModel: MatchWidgetCellViewModel?

    static var cellHeight: CGFloat = 156

    var snapshot: UIImage?

    var isFavorite: Bool = false {
        didSet {
            if isFavorite {
                self.favoritesIconImageView.image = UIImage(named: "selected_favorite_icon")
            }
            else {
                self.favoritesIconImageView.image = UIImage(named: "unselected_favorite_icon")
            }
        }
    }

    var tappedMatchWidgetAction: (() -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var didLongPressOdd: ((BettingTicket) -> Void)?

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

        self.homeOddTitleLabel.text = "-"
        self.drawOddTitleLabel.text = "-"
        self.awayOddTitleLabel.text = "-"

        self.eventNameLabel.text = ""
        self.homeParticipantNameLabel.text = ""
        self.awayParticipantNameLabel.text = ""
        self.matchTimeLabel.text = ""
        self.resultLabel.text = ""

        self.locationFlagImageView.image = nil
        self.suspendedBaseView.isHidden = true

        self.baseView.bringSubviewToFront(self.suspendedBaseView)

        self.liveIndicatorImageView.image = UIImage(named: "icon_live")

        let tapLeftOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapLeftOddButton))
        self.homeBaseView.addGestureRecognizer(tapLeftOddButton)

        let longPressLeftOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressLeftOddButton))
        self.homeBaseView.addGestureRecognizer(longPressLeftOddButton)

        let tapMiddleOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapMiddleOddButton))
        self.drawBaseView.addGestureRecognizer(tapMiddleOddButton)

        let longPressMiddleOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressMiddleOddButton))
        self.drawBaseView.addGestureRecognizer(longPressMiddleOddButton)

        let tapRightOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapRightOddButton))
        self.awayBaseView.addGestureRecognizer(tapRightOddButton)

        let longPressRightOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressRightOddButton))
        self.awayBaseView.addGestureRecognizer(longPressRightOddButton)

        let tapMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMatchView))
        self.addGestureRecognizer(tapMatchView)

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressCard))
        self.participantsBaseView.addGestureRecognizer(longPressGestureRecognizer)

        self.adjustDesignToCardStyle()
        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.adjustDesignToCardStyle()
        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.locationFlagImageView.layer.cornerRadius = self.locationFlagImageView.frame.size.width / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.viewModel = nil
        self.snapshot = nil

        self.leftOutcome = nil
        self.middleOutcome = nil
        self.rightOutcome = nil

        self.eventNameLabel.text = ""
        self.homeParticipantNameLabel.text = ""
        self.awayParticipantNameLabel.text = ""
        self.matchTimeLabel.text = ""
        self.resultLabel.text = ""

        self.homeOddTitleLabel.text = "-"
        self.drawOddTitleLabel.text = "-"
        self.awayOddTitleLabel.text = "-"

        self.homeOddValueLabel.text = ""
        self.drawOddValueLabel.text = ""
        self.awayOddValueLabel.text = ""

        self.homeBaseView.isUserInteractionEnabled = true
        self.drawBaseView.isUserInteractionEnabled = true
        self.awayBaseView.isUserInteractionEnabled = true

        self.homeBaseView.alpha = 1.0
        self.drawBaseView.alpha = 1.0
        self.awayBaseView.alpha = 1.0

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

        self.marketSubscriber?.cancel()
        self.marketSubscriber = nil

        self.locationFlagImageView.isHidden = false
        self.locationFlagImageView.image = nil

        self.oddsStackView.alpha = 1.0
        
        self.awayBaseView.isHidden = false

        self.isFavorite = false

        self.leftOutcomeDisabled = false
        self.middleOutcomeDisabled = false
        self.rightOutcomeDisabled = false
        self.suspendedBaseView.isHidden = true

        self.adjustDesignToCardStyle()
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.baseView.backgroundColor = UIColor.App.backgroundCards

        self.numberOfBetsLabels.textColor = UIColor.App.textPrimary
        self.eventNameLabel.textColor = UIColor.App.textSecondary
        self.homeParticipantNameLabel.textColor = UIColor.App.textPrimary
        self.awayParticipantNameLabel.textColor = UIColor.App.textPrimary
        self.matchTimeLabel.textColor = UIColor.App.textPrimary
        self.resultLabel.textColor = UIColor.App.textPrimary
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

        if isLeftOutcomeButtonSelected {
            self.homeBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.homeOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.homeOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        }
        else {
            self.homeBaseView.backgroundColor = UIColor.App.backgroundOdds
            self.homeOddTitleLabel.textColor = UIColor.App.textPrimary
            self.homeOddValueLabel.textColor = UIColor.App.textPrimary
        }

        if isMiddleOutcomeButtonSelected {
            self.drawBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.drawOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.drawOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        }
        else {
            self.drawBaseView.backgroundColor = UIColor.App.backgroundOdds
            self.drawOddTitleLabel.textColor = UIColor.App.textPrimary
            self.drawOddValueLabel.textColor = UIColor.App.textPrimary
        }

        if isRightOutcomeButtonSelected {
            self.awayBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.awayOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.awayOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        }
        else {
            self.awayBaseView.backgroundColor = UIColor.App.backgroundOdds
            self.awayOddTitleLabel.textColor = UIColor.App.textPrimary
            self.awayOddValueLabel.textColor = UIColor.App.textPrimary
        }
    }

    private func adjustDesignToCardStyle() {

        if self.cachedCardsStyle == StyleHelper.cardsStyleActive() {
            return
        }

        self.cachedCardsStyle = StyleHelper.cardsStyleActive()

        switch StyleHelper.cardsStyleActive() {
        case .small:
            self.adjustDesignToSmallCardStyle()
        case .normal:
            self.adjustDesignToNormalCardStyle()
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func adjustDesignToSmallCardStyle() {
        self.topMarginSpaceConstraint.constant = 8
        self.leadingMarginSpaceConstraint.constant = 8
        self.trailingMarginSpaceConstraint.constant = 8
        self.bottomMarginSpaceConstraint.constant = 8

        self.headerHeightConstraint.constant = 12
        self.teamsHeightConstraint.constant = 26
        self.resultCenterConstraint.constant = -2
        self.buttonsHeightConstraint.constant = 27

        self.resultCenterStackView.spacing = -1

        self.eventNameLabel.font = AppFont.with(type: .semibold, size: 9)
        self.resultLabel.font = AppFont.with(type: .bold, size: 13)
        self.matchTimeLabel.font = AppFont.with(type: .semibold, size: 8)

        self.homeParticipantNameLabel.font = AppFont.with(type: .bold, size: 13)
        self.homeParticipantNameLabel.numberOfLines = 2
        self.awayParticipantNameLabel.font = AppFont.with(type: .bold, size: 13)
        self.awayParticipantNameLabel.numberOfLines = 2

        self.homeOddValueLabel.font = AppFont.with(type: .bold, size: 12)
        self.drawOddValueLabel.font = AppFont.with(type: .bold, size: 12)
        self.awayOddValueLabel.font = AppFont.with(type: .bold, size: 12)
    }

    private func adjustDesignToNormalCardStyle() {
        self.topMarginSpaceConstraint.constant = 11
        self.bottomMarginSpaceConstraint.constant = 12
        self.leadingMarginSpaceConstraint.constant = 12
        self.trailingMarginSpaceConstraint.constant = 12

        self.headerHeightConstraint.constant = 17
        self.teamsHeightConstraint.constant = 67
        self.resultCenterConstraint.constant = 0
        self.buttonsHeightConstraint.constant = 40

        self.resultCenterStackView.spacing = 2

        self.eventNameLabel.font = AppFont.with(type: .semibold, size: 11)
        self.resultLabel.font = AppFont.with(type: .bold, size: 16)
        self.matchTimeLabel.font = AppFont.with(type: .semibold, size: 8)

        self.homeParticipantNameLabel.font = AppFont.with(type: .bold, size: 14)
        self.homeParticipantNameLabel.numberOfLines = 3
        self.awayParticipantNameLabel.font = AppFont.with(type: .bold, size: 14)
        self.awayParticipantNameLabel.numberOfLines = 3

        self.homeOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.drawOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.awayOddValueLabel.font = AppFont.with(type: .bold, size: 13)
    }

    func configure(withViewModel viewModel: MatchWidgetCellViewModel) {

        self.viewModel = viewModel

        self.eventNameLabel.text = "\(viewModel.competitionName)"
        self.homeParticipantNameLabel.text = "\(viewModel.homeTeamName)"
        self.awayParticipantNameLabel.text = "\(viewModel.awayTeamName)"

        self.resultLabel.text = ""
        self.matchTimeLabel.text = ""

       // self.sportTypeImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModel.countryISOCode))
        if viewModel.countryISOCode != "" {
            self.locationFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModel.countryISOCode))
        }
        else {
            self.locationFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: viewModel.countryId))
        }

        guard
            let match = viewModel.match
        else {
            return
        }

        if let market = match.markets.first {

            if let marketPublisher = viewModel.store.marketPublisher(withId: market.id) {
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

                self.homeOddTitleLabel.text = market.nameDigit1 != nil ? (outcome.typeName + " \(market.nameDigit1!)") : outcome.typeName
                self.leftOutcome = outcome
                self.isLeftOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)
                self.homeOddValueLabel.text = OddConverter.stringForValue(outcome.bettingOffer.value, format: UserDefaults.standard.userOddsFormat)

                self.leftOddButtonSubscriber = viewModel.store
                    .bettingOfferPublisher(withId: outcome.bettingOffer.id)?
                    .compactMap({ $0 })
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] bettingOffer in

                        guard let weakSelf = self else { return }

                        if !bettingOffer.isOpen {
                            weakSelf.homeBaseView.isUserInteractionEnabled = false
                            weakSelf.homeBaseView.alpha = 0.5
                            weakSelf.homeOddValueLabel.text = "-"
                        }
                        else {
                            weakSelf.homeBaseView.isUserInteractionEnabled = true
                            weakSelf.homeBaseView.alpha = 1.0

                            guard
                                let newOddValue = bettingOffer.oddsValue
                            else {
                                return
                            }

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
                            weakSelf.homeOddValueLabel.text = OddConverter.stringForValue(newOddValue, format: UserDefaults.standard.userOddsFormat)
                        }
                    })

            }

            if let outcome = market.outcomes[safe: 1] {

                self.drawOddTitleLabel.text = market.nameDigit1 != nil ? (outcome.typeName + " \(market.nameDigit1!)") : outcome.typeName
                self.middleOutcome = outcome
                self.isMiddleOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)
                self.drawOddValueLabel.text = OddConverter.stringForValue(outcome.bettingOffer.value, format: UserDefaults.standard.userOddsFormat)

                self.middleOddButtonSubscriber = viewModel.store
                    .bettingOfferPublisher(withId: outcome.bettingOffer.id)?
                    .compactMap({ $0 })
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] bettingOffer in

                        guard let weakSelf = self else { return }

                        if !bettingOffer.isOpen {
                            weakSelf.drawBaseView.isUserInteractionEnabled = false
                            weakSelf.drawBaseView.alpha = 0.5
                            weakSelf.drawOddValueLabel.text = "-"
                        }
                        else {
                            weakSelf.drawBaseView.isUserInteractionEnabled = true
                            weakSelf.drawBaseView.alpha = 1.0

                            guard
                                let newOddValue = bettingOffer.oddsValue
                            else {
                                return
                            }

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
                            weakSelf.drawOddValueLabel.text = OddConverter.stringForValue(newOddValue, format: UserDefaults.standard.userOddsFormat)
                        }
                    })
            }

            if let outcome = market.outcomes[safe: 2] {

                self.awayOddTitleLabel.text = market.nameDigit1 != nil ? (outcome.typeName + " \(market.nameDigit1!)") : outcome.typeName
                self.rightOutcome = outcome
                self.isRightOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)
                self.awayOddValueLabel.text = OddConverter.stringForValue(outcome.bettingOffer.value, format: UserDefaults.standard.userOddsFormat)

                self.rightOddButtonSubscriber = viewModel.store
                    .bettingOfferPublisher(withId: outcome.bettingOffer.id)?
                    .compactMap({ $0 })
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] bettingOffer in

                        guard let weakSelf = self else { return }

                        if !bettingOffer.isOpen {
                            weakSelf.awayBaseView.isUserInteractionEnabled = false
                            weakSelf.awayBaseView.alpha = 0.5
                            weakSelf.awayOddValueLabel.text = "-"
                        }
                        else {
                            weakSelf.awayBaseView.isUserInteractionEnabled = true
                            weakSelf.awayBaseView.alpha = 1.0

                            guard
                                let newOddValue = bettingOffer.oddsValue
                            else {
                                return
                            }

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
                            weakSelf.awayOddValueLabel.text = OddConverter.stringForValue(newOddValue, format: UserDefaults.standard.userOddsFormat)
                        }
                    })

            }

            if market.outcomes.count == 2 {
                awayBaseView.isHidden = true
            }

        }
        else {
            Logger.log("No markets found")
            oddsStackView.alpha = 0.2

            self.homeOddValueLabel.text = "-"
            self.drawOddValueLabel.text = "-"
            self.awayOddValueLabel.text = "-"

        }

        for matchId in Env.favoritesManager.favoriteEventsIdPublisher.value where matchId == match.id {
            self.isFavorite = true
        }

        //
        // Live infos
        //
        var homeGoals = ""
        var awayGoals = ""
        var minutes = ""
        var matchPart = ""

        // Env.everyMatrixStorage.matchesInfoForMatch[match.id]
        if let matchInfoArray = viewModel.store.matchesInfoForMatchList()[match.id] {
            for matchInfoId in matchInfoArray {
                // Env.everyMatrixStorage.matchesInfo[matchInfoId]
                if let matchInfo = viewModel.store.matchesInfoList()[matchInfoId] {
                    if (matchInfo.typeId ?? "") == "1" && (matchInfo.eventPartId ?? "") == self.viewModel?.match?.rootPartId {
                        // Goals
                        if let homeGoalsFloat = matchInfo.paramFloat1 {
                            if self.viewModel?.match?.homeParticipant.id == matchInfo.paramParticipantId1 {
                                homeGoals = "\(homeGoalsFloat)"
                            }
                            else if self.viewModel?.match?.awayParticipant.id == matchInfo.paramParticipantId1 {
                                awayGoals = "\(homeGoalsFloat)"
                            }
                        }
                        if let awayGoalsFloat = matchInfo.paramFloat2 {
                            if self.viewModel?.match?.homeParticipant.id == matchInfo.paramParticipantId2 {
                                homeGoals = "\(awayGoalsFloat)"
                            }
                            else if self.viewModel?.match?.awayParticipant.id == matchInfo.paramParticipantId2 {
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
            self.resultLabel.setNeedsLayout()
            self.resultLabel.layoutIfNeeded()
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

    //
    //
    private func showMarketButtons() {
        self.suspendedBaseView.isHidden = true
    }

    private func showSuspendedView() {
        self.suspendedLabel.text = localized("suspended_market")
        self.suspendedBaseView.isHidden = false
    }

    private func showClosedView() {
        self.suspendedLabel.text = localized("closed_market")
        self.suspendedBaseView.isHidden = false
    }

    //
    //
    func shouldShowCountryFlag(_ show: Bool) {
        self.locationFlagImageView.isHidden = !show
    }

    func markAsFavorite(match: Match) {
        if Env.favoritesManager.isEventFavorite(eventId: match.id) {
            Env.favoritesManager.removeFavorite(eventId: match.id, favoriteType: .match)
            self.isFavorite = false
        }
        else {
            Env.favoritesManager.addFavorite(eventId: match.id, favoriteType: .match)
            self.isFavorite = true
        }
    }

    @IBAction private func didTapFavoritesButton(_ sender: Any) {
        if UserSessionStore.isUserLogged() {
            if let match = self.viewModel?.match {
                self.markAsFavorite(match: match)
            }
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.viewController?.present(loginViewController, animated: true, completion: nil)
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

    //
    //
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
    // Odd buttons interaction
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

        if self.leftOutcomeDisabled {
            return
        }

        guard
            let match = self.viewModel?.match,
            let market = match.markets.first,
            let outcome = self.leftOutcome
        else {
            return
        }

        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isLeftOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)
            self.isLeftOutcomeButtonSelected = true
        }

    }

    @objc func didLongPressLeftOddButton(_ sender: Any) {

        guard let longPressGesture = sender as? UILongPressGestureRecognizer else {return}

        // Triggers function only once instead of rapid fire event
        if longPressGesture.state == .began {
            print("LONG PRESS LEFT ODD!")

            guard
                let match = self.viewModel?.match,
                let market = match.markets.first,
                let outcome = self.leftOutcome
            else {
                return
            }

            let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

            self.didLongPressOdd?(bettingTicket)
        }
    }

    func selectMiddleOddButton() {
        self.drawBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.drawOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        self.drawOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
    }
    func deselectMiddleOddButton() {
        self.drawBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.drawOddValueLabel.textColor = UIColor.App.textPrimary
        self.drawOddTitleLabel.textColor = UIColor.App.textPrimary
    }
    @objc func didTapMiddleOddButton() {

        if self.middleOutcomeDisabled {
            return
        }

        guard
            let match = self.viewModel?.match,
            let market = match.markets.first,
            let outcome = self.middleOutcome
        else {
            return
        }

        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isMiddleOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)
            self.isMiddleOutcomeButtonSelected = true
        }
    }

    @objc func didLongPressMiddleOddButton(_ sender: Any) {

        guard let longPressGesture = sender as? UILongPressGestureRecognizer else {return}

        // Triggers function only once instead of rapid fire event
        if longPressGesture.state == .began {
            print("LONG PRESS MIDDLE ODD!")

            guard
                let match = self.viewModel?.match,
                let market = match.markets.first,
                let outcome = self.middleOutcome
            else {
                return
            }

            let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

            print("BETTING TICKET: \(bettingTicket)")

            self.didLongPressOdd?(bettingTicket)

        }
    }

    func selectRightOddButton() {
        self.awayBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.awayOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
        self.awayOddValueLabel.textColor = UIColor.App.buttonTextPrimary
    }
    func deselectRightOddButton() {
        self.awayBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.awayOddValueLabel.textColor = UIColor.App.textPrimary
        self.awayOddTitleLabel.textColor = UIColor.App.textPrimary
    }
    @objc func didTapRightOddButton() {
        if self.rightOutcomeDisabled {
            return
        }

        guard
            let match = self.viewModel?.match,
            let market = match.markets.first,
            let outcome = self.rightOutcome
        else {
            return
        }

        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isRightOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)
            self.isRightOutcomeButtonSelected = true
        }
    }

    @objc func didLongPressRightOddButton(_ sender: Any) {

        guard let longPressGesture = sender as? UILongPressGestureRecognizer else {return}

        // Triggers function only once instead of rapid fire event
        if longPressGesture.state == .began {
            print("LONG PRESS RIGHT ODD!")

            guard
                let match = self.viewModel?.match,
                let market = match.markets.first,
                let outcome = self.rightOutcome
            else {
                return
            }

            let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

            print("BETTING TICKET: \(bettingTicket)")

            self.didLongPressOdd?(bettingTicket)

        }
    }

}

extension LiveMatchWidgetCollectionViewCell {

    @IBAction private func didLongPressCard() {

        if UserSessionStore.isUserLogged() {
          
            guard
                let parentViewController = self.viewController,
                let match = self.viewModel?.match
            else {
                return
            }

            let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            if Env.favoritesManager.isEventFavorite(eventId: match.id) {
                let favoriteAction: UIAlertAction = UIAlertAction(title: "Remove from favorites", style: .default) { _ -> Void in
                    Env.favoritesManager.removeFavorite(eventId: match.id, favoriteType: .match)
                }
                actionSheetController.addAction(favoriteAction)
            }
            else {
                let favoriteAction: UIAlertAction = UIAlertAction(title: "Add to favorites", style: .default) { _ -> Void in
                    Env.favoritesManager.addFavorite(eventId: match.id, favoriteType: .match)
                }
                actionSheetController.addAction(favoriteAction)
            }

            let shareAction: UIAlertAction = UIAlertAction(title: "Share event", style: .default) { [weak self] _ -> Void in
                self?.didTapShareButton()
            }
            actionSheetController.addAction(shareAction)

            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { _ -> Void in }
            actionSheetController.addAction(cancelAction)

            if let popoverController = actionSheetController.popoverPresentationController {
                popoverController.sourceView = parentViewController.view
                popoverController.sourceRect = CGRect(x: parentViewController.view.bounds.midX, y: parentViewController.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }

            parentViewController.present(actionSheetController, animated: true, completion: nil)
        
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.viewController?.present(loginViewController, animated: true, completion: nil)
        }
    }

    private func didTapShareButton() {

        guard
            let parentViewController = self.viewController,
            let match = self.viewModel?.match
        else {
            return
        }

        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        let snapshot = renderer.image { _ in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }

        let metadata = LPLinkMetadata()
        let urlMobile = Env.urlMobileShares

        if let matchUrl = URL(string: "\(urlMobile)/gamedetail/\(match.id)") {

            let imageProvider = NSItemProvider(object: snapshot)
            metadata.imageProvider = imageProvider
            metadata.url = matchUrl
            metadata.originalURL = matchUrl
            metadata.title = localized("check_this_game")
        }

        let metadataItemSource = LinkPresentationItemSource(metaData: metadata)

        let shareActivityViewController = UIActivityViewController(activityItems: [metadataItemSource, snapshot], applicationActivities: nil)
        if let popoverController = shareActivityViewController.popoverPresentationController {
            popoverController.sourceView = parentViewController.view
            popoverController.sourceRect = CGRect(x: parentViewController.view.bounds.midX, y: parentViewController.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        parentViewController.present(shareActivityViewController, animated: true, completion: nil)
    }

}
