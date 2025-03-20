//
//  MatchWidgetCollectionViewCell+Configuration.swift
//  Sportsbook
//
//  Created by Refactoring on 2024.
//

import UIKit
import Combine
import ServicesProvider

// MARK: - Configuration Methods
extension MatchWidgetCollectionViewCell {

    // MARK: - ViewModel Configuration
    func configure(withViewModel viewModel: MatchWidgetCellViewModel) {
        self.viewModel = viewModel

        guard let viewModel = self.viewModel else { return }

        self.adjustDesignToCardHeightStyle()

        // Live card styling based on match status
        Publishers.CombineLatest(viewModel.$matchWidgetStatus, viewModel.$matchWidgetType)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matchWidgetStatus, matchWidgetType in
                switch matchWidgetType {
                case .normal, .boosted, .topImage, .topImageWithMixMatch:
                    if matchWidgetStatus == .live {
                        self?.gradientBorderView.isHidden = true
                        self?.liveGradientBorderView.isHidden = false
                    }
                    else {
                        self?.gradientBorderView.isHidden = false
                        self?.liveGradientBorderView.isHidden = true
                    }
                case .backgroundImage, .topImageOutright:
                    self?.gradientBorderView.isHidden = true
                    self?.liveGradientBorderView.isHidden = true
                }
            }
            .store(in: &self.cancellables)

        // Live card layout setup
        Publishers.CombineLatest(viewModel.$matchWidgetStatus, viewModel.isLiveCardPublisher)
            .removeDuplicates(by: { oldPair, newPair in
                return oldPair.0 == newPair.0 && oldPair.1 == newPair.1
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matchWidgetStatus, isLiveCard in
                if isLiveCard || matchWidgetStatus == .live {
                    self?.drawAsLiveCard()
                }
                else {
                    self?.drawAsPreLiveCard()
                }
            }
            .store(in: &self.cancellables)

        // Match widget type changes
        viewModel.$matchWidgetType
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matchWidgetType in
                self?.drawForMatchWidgetType(matchWidgetType)
                
                switch matchWidgetType {
                case .topImageOutright:
                    self?.showOutrightLayout()
                default:
                    break
                }
            }
            .store(in: &self.cancellables)

        // Bind team names
        viewModel.homeTeamNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] homeTeamName in
                self?.homeNameLabel.text = homeTeamName
            }
            .store(in: &self.cancellables)

        viewModel.awayTeamNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] awayTeamName in
                self?.awayNameLabel.text = awayTeamName
            }
            .store(in: &self.cancellables)

        // Bind serving indicator
        viewModel.activePlayerServePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] activePlayerServing in
                switch activePlayerServing {
                case .home:
                    self?.homeServingIndicatorView.isHidden = false
                    self?.awayServingIndicatorView.isHidden = true
                case .away:
                    self?.homeServingIndicatorView.isHidden = true
                    self?.awayServingIndicatorView.isHidden = false
                case .none:
                    self?.homeServingIndicatorView.isHidden = true
                    self?.awayServingIndicatorView.isHidden = true
                }
            }
            .store(in: &self.cancellables)

        // Bind date and time
        viewModel.startDateStringPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] startDateString in
                self?.dateNewLabel.text = startDateString
            }
            .store(in: &self.cancellables)

        viewModel.startTimeStringPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] startTimeString in
                self?.timeNewLabel.text = startTimeString
            }
            .store(in: &self.cancellables)

        // Bind boosted odds data
        configureBoostedOddsSubscription()

        // Bind match scores
        viewModel.detailedScoresPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detailedScoresDict, sportAlphaId in
                self?.detailedScoreView.sportCode = sportAlphaId
                self?.detailedScoreView.updateScores(detailedScoresDict)
            }
            .store(in: &self.cancellables)

        // Bind icons
        viewModel.countryFlagImagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countryFlagImage in
                self?.locationFlagImageView.image = countryFlagImage
            }
            .store(in: &self.cancellables)

        viewModel.sportIconImagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sportIconImage in
                self?.sportTypeImageView.image = sportIconImage
            }
            .store(in: &self.cancellables)

        // Bind match time details
        viewModel.matchTimeDetailsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matchTimeDetails in
                self?.matchTimeStatusNewLabel.text = matchTimeDetails
            }
            .store(in: &self.cancellables)

        // Bind promo image
        viewModel.promoImageURLPublisher
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] promoImageURL in
                self?.backgroundImageView.kf.setImage(with: promoImageURL)
                self?.topImageView.kf.setImage(with: promoImageURL)
            }
            .store(in: &self.cancellables)

        // Bind favorite status
        viewModel.isFavoriteMatchPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFavoriteMatch in
                self?.isFavorite = isFavoriteMatch
            }
            .store(in: &self.cancellables)

        // Bind cashback status
        viewModel.canHaveCashbackPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canHaveCashback in
                self?.hasCashback = canHaveCashback
            }
            .store(in: &self.cancellables)

        // Bind market data
        configureMarketAndOutcomes()

        // Bind event and competition names
        configureEventAndCompetitionNames()

        // Bind horizontal match info
        viewModel.horizontalMatchInfoViewModelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] horizontalMatchInfoViewModel in
                self?.horizontalMatchInfoView.configure(with: horizontalMatchInfoViewModel)
            }
            .store(in: &self.cancellables)
    }

    // MARK: - Helper Configuration Methods
    private func configureBoostedOddsSubscription() {
        guard let viewModel = self.viewModel else { return }
        
        Publishers.CombineLatest(
            viewModel.$match,
            viewModel.$oldBoostedOddOutcome
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] match, oldBoostedOddOutcome in

            self?.oldTitleBoostedOddLabel.text = "" // same title for both old and new
            self?.oldValueBoostedOddLabel.text = "-" // The new odd, from the market outcome

            self?.newTitleBoostedOddLabel.text = "" // same title for both old and new
            self?.newValueBoostedOddLabel.text = "-" // The old odd from the old market subscriber

            guard
                let newMarket = match.markets.first,
                let newOutcome = newMarket.outcomes.first
            else {
                // No "new" market found
                return
            }

            // We have enough data to show the new odd value and title
            self?.newTitleBoostedOddLabel.text = newOutcome.typeName // same title for both old and new

            let newValueString = OddFormatter.formatOdd(withValue: newOutcome.bettingOffer.decimalOdd)
            self?.newValueBoostedOddLabel.text = newValueString // The old odd from the old market subscriber

            guard
                let oldBoostedOddOutcomeValue = oldBoostedOddOutcome
            else {
                // No old value found
                // we need to configure the new market and new outcome
                self?.configureBoostedOutcome()
                return
            }

            self?.oldValueBoostedOddLabel.attributedText = oldBoostedOddOutcomeValue.valueAttributedString // The old odd, from the old market outcome
            self?.oldTitleBoostedOddLabel.text = newOutcome.typeName // same title for both old and new

            self?.configureBoostedOutcome()
        }
        .store(in: &self.cancellables)
    }

    private func configureMarketAndOutcomes() {
        guard let viewModel = self.viewModel else { return }
        
        Publishers.CombineLatest(viewModel.defaultMarketPublisher, viewModel.isDefaultMarketAvailablePublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] defaultMarket, isAvailable in
                if let market = defaultMarket {
                    // Setup outcome buttons
                    self?.oddsStackView.alpha = 1.0

                    if self?.viewModel?.matchWidgetType == .boosted {
                        self?.configureBoostedOutcome()
                    }
                    else {
                        self?.configureOutcomes(withMarket: market)
                    }

                    if isAvailable {
                        self?.showMarketButtons()
                    }
                    else {
                        self?.showSuspendedView()
                    }

                    if self?.viewModel?.matchWidgetType == .topImageWithMixMatch {
                        if let customBetAvailable = market.customBetAvailable,
                           customBetAvailable {
                            self?.mixMatchContainerView.isHidden = false
                            self?.bottomSeeAllMarketsContainerView.isHidden = true
                        }
                        else {
                            self?.mixMatchContainerView.isHidden = true
                            self?.bottomSeeAllMarketsContainerView.isHidden = false
                        }
                    }
                    else if self?.viewModel?.matchWidgetType == .topImage {
                        self?.mixMatchContainerView.isHidden = true
                        self?.bottomSeeAllMarketsContainerView.isHidden = false
                    }
                }
                else {
                    // Hide outcome buttons if we don't have any market
                    self?.oddsStackView.alpha = 0.2
                    self?.showSeeAllView()
                }
            }
            .store(in: &self.cancellables)

        Publishers.CombineLatest4(viewModel.mainMarketNamePublisher,
                                  viewModel.$matchWidgetType,
                                  viewModel.$matchWidgetStatus,
                                  viewModel.defaultMarketPublisher)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] mainMarketName, matchWidgetType, matchWidgetStatus, defaultMarket in
            self?.marketNameLabel.text = mainMarketName
            self?.marketNamePillLabelView.title = mainMarketName

            if matchWidgetType == .normal && matchWidgetStatus == .live && defaultMarket != nil {
                self?.marketNamePillLabelView.isHidden = false
            }
            else if matchWidgetType == .boosted {
                self?.marketNamePillLabelView.isHidden = false
            }
            else {
                self?.marketNamePillLabelView.isHidden = true
            }
        }
        .store(in: &self.cancellables)
    }

    private func configureEventAndCompetitionNames() {
        guard let viewModel = self.viewModel else { return }
        Publishers.CombineLatest3(viewModel.$matchWidgetType,
                                  viewModel.eventNamePublisher,
                                  viewModel.competitionNamePublisher)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] matchWidgetType, eventName, competitionName in
            switch matchWidgetType {
            case .topImageOutright:
                self?.eventNameLabel.text = eventName
            default:
                self?.eventNameLabel.text = competitionName
            }
        }
        .store(in: &self.cancellables)

        self.viewModel?.outrightNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] outrightName in
                self?.outrightNameLabel.text = outrightName
            }
            .store(in: &self.cancellables)
    }

    // MARK: - Configure Outcomes
    func configureBoostedOutcome() {
        if self.viewModel?.matchWidgetType != .boosted {
            return
        }

        self.boostedOddBarView.isHidden = false

        self.homeBaseView.isHidden = true
        self.drawBaseView.isHidden = true
        self.awayBaseView.isHidden = true

        guard let market = self.viewModel?.match.markets.first, let outcome = market.outcomes.first else { return }

        self.isBoostedOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)
    }

    func configureOutcomes(withMarket market: Market) {
        // Configure left (home) outcome
        configureLeftOutcome(market)

        // Configure middle (draw) outcome
        configureMiddleOutcome(market)

        // Configure right (away) outcome
        configureRightOutcome(market)

        // Hide boosted odds bar since we're showing regular odds
        self.boostedOddBarView.isHidden = true

        // Show/hide outcome buttons based on available outcomes
        if market.outcomes.count == 3 {
            self.homeBaseView.isHidden = false
            self.drawBaseView.isHidden = false
            self.awayBaseView.isHidden = false
        }
        else if market.outcomes.count == 2 {
            self.homeBaseView.isHidden = false
            self.drawBaseView.isHidden = false
            self.awayBaseView.isHidden = true
        }
        else if market.outcomes.count == 1 {
            self.homeBaseView.isHidden = false
            self.drawBaseView.isHidden = true
            self.awayBaseView.isHidden = true
        }
    }

    private func configureLeftOutcome(_ market: Market) {
        guard let outcome = market.outcomes[safe: 0] else { return }

        // Configure outcome title
        if let nameDigit1 = market.nameDigit1 {
            if outcome.typeName.contains("\(nameDigit1)") {
                self.homeOddTitleLabel.text = outcome.typeName
            }
            else {
                self.homeOddTitleLabel.text = "\(outcome.typeName) \(nameDigit1)"
            }
        }
        else {
            self.homeOddTitleLabel.text = outcome.typeName
        }

        // Store outcome and set selection state
        self.leftOutcome = outcome
        self.isLeftOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

        // Check for invalid odd
        if !outcome.bettingOffer.decimalOdd.isNaN {
            self.setHomeOddValueLabel(toText: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd))
        }
        else {
            self.homeBaseView.isUserInteractionEnabled = false
            self.homeBaseView.alpha = 0.5
            self.setHomeOddValueLabel(toText: "-")
        }

        // Subscribe to outcome updates
        self.leftOddButtonSubscriber = Env.servicesProvider
            .subscribeToEventOnListsOutcomeUpdates(withId: outcome.bettingOffer.id)
            .compactMap({ $0 })
            .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome: ))
            .handleEvents(receiveOutput: { [weak self] outcome in
                self?.leftOutcome = outcome
            })
            .map(\.bettingOffer)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in

            }, receiveValue: { [weak self] bettingOffer in

                guard let weakSelf = self else { return }

                if !bettingOffer.isAvailable || bettingOffer.decimalOdd.isNaN {
                    weakSelf.homeBaseView.isUserInteractionEnabled = false
                    weakSelf.homeBaseView.alpha = 0.5
                    weakSelf.setHomeOddValueLabel(toText: "-")
                }
                else {
                    weakSelf.homeBaseView.isUserInteractionEnabled = true
                    weakSelf.homeBaseView.alpha = 1.0

                    let newOddValue = bettingOffer.decimalOdd

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
                    weakSelf.setHomeOddValueLabel(toText: OddFormatter.formatOdd(withValue: newOddValue))
                }
            })
    }

    private func configureMiddleOutcome(_ market: Market) {
        guard let outcome = market.outcomes[safe: 1] else { return }

        // Configure outcome title
        if let nameDigit1 = market.nameDigit1 {
            if outcome.typeName.contains("\(nameDigit1)") {
                self.drawOddTitleLabel.text = outcome.typeName
            }
            else {
                self.drawOddTitleLabel.text = "\(outcome.typeName) \(nameDigit1)"
            }
        }
        else {
            self.drawOddTitleLabel.text = outcome.typeName
        }

        // Store outcome and set selection state
        self.middleOutcome = outcome
        self.isMiddleOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

        // Check for invalid odd
        if !outcome.bettingOffer.decimalOdd.isNaN {
            self.setDrawOddValueLabel(toText: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd))
        }
        else {
            self.drawBaseView.isUserInteractionEnabled = false
            self.drawBaseView.alpha = 0.5
            self.setDrawOddValueLabel(toText: "-")
        }

        // Subscribe to outcome updates
        self.middleOddButtonSubscriber = Env.servicesProvider
            .subscribeToEventOnListsOutcomeUpdates(withId: outcome.bettingOffer.id)
            .compactMap({ $0 })
            .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome:))
            .handleEvents(receiveOutput: { [weak self] outcome in
                self?.middleOutcome = outcome
            })
            .map(\.bettingOffer)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] bettingOffer in

                guard let weakSelf = self else { return }

                if !bettingOffer.isAvailable || bettingOffer.decimalOdd.isNaN {
                    weakSelf.drawBaseView.isUserInteractionEnabled = false
                    weakSelf.drawBaseView.alpha = 0.5
                    weakSelf.setDrawOddValueLabel(toText: "-")
                }
                else {
                    weakSelf.drawBaseView.isUserInteractionEnabled = true
                    weakSelf.drawBaseView.alpha = 1.0

                    let newOddValue = bettingOffer.decimalOdd
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
                    weakSelf.setDrawOddValueLabel(toText: OddFormatter.formatOdd(withValue: newOddValue))
                }
            })
    }

    private func configureRightOutcome(_ market: Market) {
        guard let outcome = market.outcomes[safe: 2] else { return }

        // Configure outcome title
        if let nameDigit1 = market.nameDigit1 {
            if outcome.typeName.contains("\(nameDigit1)") {
                self.awayOddTitleLabel.text = outcome.typeName
            }
            else {
                self.awayOddTitleLabel.text = "\(outcome.typeName) \(nameDigit1)"
            }
        }
        else {
            self.awayOddTitleLabel.text = outcome.typeName
        }

        // Store outcome and set selection state
        self.rightOutcome = outcome
        self.isRightOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

        // Check for invalid odd
        if !outcome.bettingOffer.decimalOdd.isNaN {
            self.setAwayOddValueLabel(toText: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd))
        }
        else {
            self.awayBaseView.isUserInteractionEnabled = false
            self.awayBaseView.alpha = 0.5
            self.setAwayOddValueLabel(toText: "-")
        }

        // Subscribe to outcome updates
        self.rightOddButtonSubscriber = Env.servicesProvider
            .subscribeToEventOnListsOutcomeUpdates(withId: outcome.bettingOffer.id)
            .compactMap({ $0 })
            .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome:))
            .handleEvents(receiveOutput: { [weak self] outcome in
                self?.rightOutcome = outcome
            })
            .map(\.bettingOffer)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] bettingOffer in

                guard let weakSelf = self else { return }

                if !bettingOffer.isAvailable || bettingOffer.decimalOdd.isNaN {
                    weakSelf.awayBaseView.isUserInteractionEnabled = false
                    weakSelf.awayBaseView.alpha = 0.5
                    weakSelf.setAwayOddValueLabel(toText: "-")
                }
                else {
                    weakSelf.awayBaseView.isUserInteractionEnabled = true
                    weakSelf.awayBaseView.alpha = 1.0

                    let newOddValue = bettingOffer.decimalOdd
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
                    weakSelf.setAwayOddValueLabel(toText: OddFormatter.formatOdd(withValue: newOddValue))
                }
            })
    }

    // MARK: - Helper Methods
    func setHomeOddValueLabel(toText text: String) {
        self.homeOddValueLabel.text = text
        self.homeNewBoostedOddValueLabel.text = text
    }

    func setDrawOddValueLabel(toText text: String) {
        self.drawOddValueLabel.text = text
        self.drawNewBoostedOddValueLabel.text = text
    }

    func setAwayOddValueLabel(toText text: String) {
        self.awayOddValueLabel.text = text
        self.awayNewBoostedOddValueLabel.text = text
    }

    func shouldShowCountryFlag(_ show: Bool) {
        self.locationFlagImageView.isHidden = !show
    }

    // MARK: - Cleanup
    func cleanupForReuse() {
        self.viewModel = nil

        self.mixMatchContainerView.isHidden = true
        self.bottomSeeAllMarketsContainerView.isHidden = true

        self.cancellables.removeAll()

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

        self.isBoostedOutcomeButtonSelected = false

        self.oddsStackView.alpha = 1.0
        self.oddsStackView.isHidden = false

        self.homeBaseView.alpha = 1.0
        self.drawBaseView.alpha = 1.0
        self.awayBaseView.alpha = 1.0

        self.homeServingIndicatorView.isHidden = true
        self.awayServingIndicatorView.isHidden = true

        self.outrightNameBaseView.isHidden = true

        // Old style for teams and scores
        self.horizontalMatchInfoBaseView.isHidden = true
        self.marketNameView.isHidden = true

        self.adjustDesignToCardHeightStyle()

        // Reset text fields
        self.eventNameLabel.text = ""
        self.homeNameLabel.text = ""
        self.awayNameLabel.text = ""
        self.dateNewLabel.text = ""
        self.timeNewLabel.text = ""

        self.homeOddTitleLabel.text = ""
        self.drawOddTitleLabel.text = ""
        self.awayOddTitleLabel.text = ""

        self.setHomeOddValueLabel(toText: "")
        self.setDrawOddValueLabel(toText: "")
        self.setAwayOddValueLabel(toText: "")

        self.detailedScoreView.updateScores([:])

        self.outrightNameLabel.text = ""

        self.matchTimeStatusNewLabel.isHidden = true
        self.matchTimeStatusNewLabel.text = ""

        self.marketNameLabel.text = ""

        // Reset live indicators
        self.liveTipView.isHidden = true
        self.gradientBorderView.isHidden = true
        self.liveGradientBorderView.isHidden = true

        self.marketNamePillLabelView.title = ""
        self.marketNamePillLabelView.isHidden = true

        // Reset button interaction states
        self.homeBaseView.isUserInteractionEnabled = true
        self.drawBaseView.isUserInteractionEnabled = true
        self.awayBaseView.isUserInteractionEnabled = true

        self.locationFlagImageView.isHidden = false
        self.locationFlagImageView.image = nil

        self.sportTypeImageView.image = nil

        self.isFavorite = false
        self.hasCashback = false

        self.leftOutcomeDisabled = false
        self.middleOutcomeDisabled = false
        self.rightOutcomeDisabled = false

        self.suspendedBaseView.isHidden = true
        self.seeAllBaseView.isHidden = true
        self.outrightBaseView.isHidden = true

        self.setupWithTheme()
    }
}
