//
//  PreLiveMatchWidgetCollectionViewCell+Configuration.swift
//  Sportsbook
//
//  Created by Refactoring on 2024.
//

import UIKit
import Combine
import ServicesProvider

// MARK: - Configuration Methods
extension PreLiveMatchWidgetCollectionViewCell {

    // MARK: - ViewModel Configuration
    func configure(withViewModel viewModel: MatchWidgetCellViewModel) {
        self.cancelSubscriptions()
        self.viewModel = viewModel


        // Additional configuration...
        guard let viewModel = self.viewModel else { return }

        self.adjustDesignToCardHeightStyle()

        // Setup MatchInfoView with data from viewModel
        self.matchInfoView.configure(with: viewModel.matchInfoViewModel)

        self.matchHeaderView.configure(with: viewModel.matchHeaderViewModel)

        // Set up main widget appearance based on type and status
        viewModel.widgetAppearancePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] appearance in
                // Apply card style based on appearance
                if appearance.isLive {
                    self?.gradientBorderView.isHidden = appearance.shouldHideNormalGradient
                    self?.liveGradientBorderView.isHidden = appearance.shouldHideLiveGradient

                    if appearance.isLiveCard {
                        self?.drawAsLiveCard()
                    } else {
                        self?.drawAsPreLiveCard()
                    }
                } else {
                    self?.gradientBorderView.isHidden = appearance.shouldHideNormalGradient
                    self?.liveGradientBorderView.isHidden = appearance.shouldHideLiveGradient
                    self?.drawAsPreLiveCard()
                }

                // Set widget type-specific styles
                self?.drawForMatchWidgetType(appearance.widgetType)

                if appearance.widgetType == .topImageOutright {
                    self?.showOutrightLayout()
                }
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

        // Bind cashback status
        viewModel.canHaveCashbackPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canHaveCashback in
                self?.hasCashback = canHaveCashback
            }
            .store(in: &self.cancellables)

        // Bind market data - use new presentation model publisher from viewModel
        viewModel.marketPresentationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] marketPresentation in
                // Handle market presentation
                if let market = marketPresentation.market {
                    self?.oddsStackView.alpha = 1.0

                    if marketPresentation.widgetType == .boosted {
                        self?.configureBoostedOutcomeUI(marketPresentation.boostedOutcome)
                    } else {
                        self?.configureOutcomesUI(marketPresentation.outcomes)
                    }

                    if marketPresentation.isMarketAvailable {
                        self?.showMarketButtons()
                    } else {
                        self?.showSuspendedView()
                    }

                    // Configure Mix Match visibility
                    self?.configureMixMatch(marketPresentation.isCustomBetAvailable,
                                          widgetType: marketPresentation.widgetType)
                } else {
                    // Hide outcome buttons if we don't have any market
                    self?.oddsStackView.alpha = 0.2
                    self?.showSeeAllView()
                }

            }
            .store(in: &self.cancellables)

        viewModel.outrightNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] outrightName in
                self?.outrightNameLabel.text = outrightName
            }
            .store(in: &self.cancellables)

        // Bind boosted odds data
        viewModel.boostedOddsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] boostedOddsInfo in
                self?.oldTitleBoostedOddLabel.text = boostedOddsInfo.title
                self?.oldValueBoostedOddLabel.text = boostedOddsInfo.oldValue

                self?.newTitleBoostedOddLabel.text = boostedOddsInfo.title
                self?.newValueBoostedOddLabel.text = boostedOddsInfo.newValue

                if let attributedString = boostedOddsInfo.oldValueAttributed {
                    self?.oldValueBoostedOddLabel.attributedText = attributedString
                }
            }
            .store(in: &self.cancellables)

        // Bind outcome updates for highlighting changes (subscribe to viewModel's transformed publishers)
        viewModel.leftOutcomeUpdatesPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print("leftOutcomeUpdatesPublisher completion \(completion)")
            }, receiveValue: { [weak self] update in
                guard let self = self else { return }

                if !update.isAvailable {
                    self.homeBaseView.isUserInteractionEnabled = false
                    self.homeBaseView.alpha = 0.5
                    self.setHomeOddValueLabel(toText: "-")
                } else {
                    self.homeBaseView.isUserInteractionEnabled = true
                    self.homeBaseView.alpha = 1.0

                    if let changeDirection = update.changeDirection {
                        switch changeDirection {
                        case .up:
                            self.highlightOddChangeUp(animated: true,
                                                    upChangeOddValueImage: self.homeUpChangeOddValueImage,
                                                    baseView: self.homeBaseView)
                        case .down:
                            self.highlightOddChangeDown(animated: true,
                                                      downChangeOddValueImage: self.homeDownChangeOddValueImage,
                                                      baseView: self.homeBaseView)
                        case .none:
                            break
                        }
                    }

                    self.currentHomeOddValue = update.newValue
                    self.setHomeOddValueLabel(toText: update.formattedValue)
                    self.isLeftOutcomeButtonSelected = update.isSelected
                    self.leftOutcome = update.outcome
                }
            })
            .store(in: &self.cancellables)

        viewModel.middleOutcomeUpdatesPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print("middleOutcomeUpdatesPublisher completion \(completion)")
            }, receiveValue: { [weak self] update in
                guard let self = self else { return }

                if !update.isAvailable {
                    self.drawBaseView.isUserInteractionEnabled = false
                    self.drawBaseView.alpha = 0.5
                    self.setDrawOddValueLabel(toText: "-")
                } else {
                    self.drawBaseView.isUserInteractionEnabled = true
                    self.drawBaseView.alpha = 1.0

                    if let changeDirection = update.changeDirection {
                        switch changeDirection {
                        case .up:
                            self.highlightOddChangeUp(animated: true,
                                                    upChangeOddValueImage: self.drawUpChangeOddValueImage,
                                                    baseView: self.drawBaseView)
                        case .down:
                            self.highlightOddChangeDown(animated: true,
                                                      downChangeOddValueImage: self.drawDownChangeOddValueImage,
                                                      baseView: self.drawBaseView)
                        case .none:
                            break
                        }
                    }

                    self.currentDrawOddValue = update.newValue
                    self.setDrawOddValueLabel(toText: update.formattedValue)
                    self.isMiddleOutcomeButtonSelected = update.isSelected
                    self.middleOutcome = update.outcome
                }
            })
            .store(in: &self.cancellables)

        viewModel.rightOutcomeUpdatesPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print("rightOutcomeUpdatesPublisher completion \(completion)")
            }, receiveValue: { [weak self] update in
                guard let self = self else { return }

                if !update.isAvailable {
                    self.awayBaseView.isUserInteractionEnabled = false
                    self.awayBaseView.alpha = 0.5
                    self.setAwayOddValueLabel(toText: "-")
                } else {
                    self.awayBaseView.isUserInteractionEnabled = true
                    self.awayBaseView.alpha = 1.0

                    if let changeDirection = update.changeDirection {
                        switch changeDirection {
                        case .up:
                            self.highlightOddChangeUp(animated: true,
                                                    upChangeOddValueImage: self.awayUpChangeOddValueImage,
                                                    baseView: self.awayBaseView)
                        case .down:
                            self.highlightOddChangeDown(animated: true,
                                                      downChangeOddValueImage: self.awayDownChangeOddValueImage,
                                                      baseView: self.awayBaseView)
                        case .none:
                            break
                        }
                    }

                    self.currentAwayOddValue = update.newValue
                    self.setAwayOddValueLabel(toText: update.formattedValue)
                    self.isRightOutcomeButtonSelected = update.isSelected
                    self.rightOutcome = update.outcome
                }
            })
            .store(in: &self.cancellables)
    }

    // MARK: - Helper UI Methods

    private func configureMixMatch(_ isCustomBetAvailable: Bool, widgetType: MatchWidgetType) {
        if widgetType == .topImageWithMixMatch {
            if isCustomBetAvailable {
                self.mixMatchContainerView.isHidden = false
                self.bottomSeeAllMarketsContainerView.isHidden = true
            } else {
                self.mixMatchContainerView.isHidden = true
                self.bottomSeeAllMarketsContainerView.isHidden = false
            }
        }
        else if widgetType == .topImage {
            self.mixMatchContainerView.isHidden = true
            self.bottomSeeAllMarketsContainerView.isHidden = false
        }
    }

    // MARK: - Configure Boosted UI
    func configureBoostedOutcomeUI(_ isBoostedOutcomeSelected: Bool?) {
        if self.viewModel?.matchWidgetType != .boosted {
            return
        }

        self.boostedOddBarView.isHidden = false
        self.homeBaseView.isHidden = true
        self.drawBaseView.isHidden = true
        self.awayBaseView.isHidden = true

        if let isSelected = isBoostedOutcomeSelected {
            self.isBoostedOutcomeButtonSelected = isSelected
        }
    }

    // MARK: - Configure Outcomes UI
    func configureOutcomesUI(_ outcomes: [OutcomePresentation]) {
        // Hide boosted odds bar since we're showing regular odds
        self.boostedOddBarView.isHidden = true

        // Configure left (home) outcome if available
        if let leftOutcome = outcomes.first(where: { $0.position == .left }) {
            self.homeOddTitleLabel.text = leftOutcome.title
            self.setHomeOddValueLabel(toText: leftOutcome.formattedValue)
            self.isLeftOutcomeButtonSelected = leftOutcome.isSelected
            self.homeBaseView.isUserInteractionEnabled = leftOutcome.isInteractive
            self.homeBaseView.alpha = leftOutcome.isInteractive ? 1.0 : 0.5
            self.homeBaseView.isHidden = false
        } else {
            self.homeBaseView.isHidden = true
        }

        // Configure middle (draw) outcome if available
        if let middleOutcome = outcomes.first(where: { $0.position == .middle }) {
            self.drawOddTitleLabel.text = middleOutcome.title
            self.setDrawOddValueLabel(toText: middleOutcome.formattedValue)
            self.isMiddleOutcomeButtonSelected = middleOutcome.isSelected
            self.drawBaseView.isUserInteractionEnabled = middleOutcome.isInteractive
            self.drawBaseView.alpha = middleOutcome.isInteractive ? 1.0 : 0.5
            self.drawBaseView.isHidden = false
        } else {
            self.drawBaseView.isHidden = true
        }

        // Configure right (away) outcome if available
        if let rightOutcome = outcomes.first(where: { $0.position == .right }) {
            self.awayOddTitleLabel.text = rightOutcome.title
            self.setAwayOddValueLabel(toText: rightOutcome.formattedValue)
            self.isRightOutcomeButtonSelected = rightOutcome.isSelected
            self.awayBaseView.isUserInteractionEnabled = rightOutcome.isInteractive
            self.awayBaseView.alpha = rightOutcome.isInteractive ? 1.0 : 0.5
            self.awayBaseView.isHidden = false
        } else {
            self.awayBaseView.isHidden = true
        }
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
        self.viewModel?.setCountryFlag(hidden: !show)
    }

    // MARK: - Cleanup
    func cleanupForReuse() {
        // Cancel previous subscriptions
        self.cancelSubscriptions()

        // Custom subviews cleanup
        self.matchHeaderView.cleanupForReuse()
        self.matchInfoView.cleanupForReuse()

        // Reset view model
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

        self.outrightNameBaseView.isHidden = true

        self.adjustDesignToCardHeightStyle()

        self.homeOddTitleLabel.text = ""
        self.drawOddTitleLabel.text = ""
        self.awayOddTitleLabel.text = ""

        self.setHomeOddValueLabel(toText: "")
        self.setDrawOddValueLabel(toText: "")
        self.setAwayOddValueLabel(toText: "")

        self.outrightNameLabel.text = ""

        // Reset live indicators
        self.hideLiveTipView()
        self.gradientBorderView.isHidden = true
        self.liveGradientBorderView.isHidden = true

        // Reset button interaction states
        self.homeBaseView.isUserInteractionEnabled = true
        self.drawBaseView.isUserInteractionEnabled = true
        self.awayBaseView.isUserInteractionEnabled = true

        self.hasCashback = false

        self.suspendedBaseView.isHidden = true
        self.seeAllBaseView.isHidden = true
        self.outrightBaseView.isHidden = true

        self.setupWithTheme()
    }

}
