//
//  LiveMatchWidgetCollectionViewCell+Configuration.swift
//  Sportsbook
//
//  Created by Refactoring on 2024.
//

import UIKit
import Combine
import ServicesProvider

// MARK: - Configuration Methods
extension LiveMatchWidgetCollectionViewCell {

    // MARK: - ViewModel Configuration
    func configure(withViewModel viewModel: MatchWidgetCellViewModel) {
        self.cancelSubscriptions()
        self.viewModel = viewModel

        // Additional configuration...
        guard let viewModel = self.viewModel else { return }

        // Setup MatchInfoView with data from viewModel
        self.matchInfoView.configure(with: viewModel.matchInfoViewModel)

        self.matchHeaderView.configure(with: viewModel.matchHeaderViewModel)

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

                    self?.configureOutcomesUI(marketPresentation.outcomes)

                    if marketPresentation.isMarketAvailable {
                        self?.showMarketButtons()
                    } else {
                        self?.showSuspendedView()
                    }
                } else {
                    // Hide outcome buttons if we don't have any market
                    self?.oddsStackView.alpha = 0.2
                    self?.showSeeAllView()
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

    // MARK: - Configure Outcomes UI
    func configureOutcomesUI(_ outcomes: [OutcomePresentation]) {
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

    //

    // MARK: - View State Management
    func showMarketButtons() {
        self.oddsStackView.isHidden = false
        self.suspendedBaseView.isHidden = true
        self.seeAllBaseView.isHidden = true
    }

    func showSuspendedView() {
        self.suspendedLabel.text = localized("suspended")
        self.suspendedBaseView.isHidden = false
        self.seeAllBaseView.isHidden = true
        self.oddsStackView.isHidden = true
    }

    func showClosedView() {
        self.suspendedLabel.text = localized("closed_market")
        self.suspendedBaseView.isHidden = false
        self.seeAllBaseView.isHidden = true
        self.oddsStackView.isHidden = true
    }

    func showSeeAllView() {
        self.seeAllLabel.text = localized("see_all")
        self.seeAllBaseView.isHidden = false
        self.oddsStackView.isHidden = true
    }

    // MARK: - Helper Methods
    func setHomeOddValueLabel(toText text: String) {
        self.homeOddValueLabel.text = text
    }

    func setDrawOddValueLabel(toText text: String) {
        self.drawOddValueLabel.text = text
    }

    func setAwayOddValueLabel(toText text: String) {
        self.awayOddValueLabel.text = text
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

        self.oddsStackView.alpha = 1.0
        self.oddsStackView.isHidden = false

        self.homeBaseView.alpha = 1.0
        self.drawBaseView.alpha = 1.0
        self.awayBaseView.alpha = 1.0

        self.homeOddTitleLabel.text = ""
        self.drawOddTitleLabel.text = ""
        self.awayOddTitleLabel.text = ""

        self.setHomeOddValueLabel(toText: "")
        self.setDrawOddValueLabel(toText: "")
        self.setAwayOddValueLabel(toText: "")

        // Reset button interaction states
        self.homeBaseView.isUserInteractionEnabled = true
        self.drawBaseView.isUserInteractionEnabled = true
        self.awayBaseView.isUserInteractionEnabled = true

        self.hasCashback = false

        self.suspendedBaseView.isHidden = true
        self.seeAllBaseView.isHidden = true

        self.setupButtonsColorState()
    }

}
