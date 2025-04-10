//
//  ClassicMatchWidgetCollectionViewCell+Styling.swift
//  Sportsbook
//
//  Created by Refactoring on 2024.
//

import UIKit

// MARK: - Styling Methods
extension ClassicMatchWidgetCollectionViewCell {

    // MARK: - Theme Setup
    func setupWithTheme() {
        self.liveTipView.backgroundColor = UIColor.App.highlightPrimary

        self.homeBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.drawBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.awayBaseView.backgroundColor = UIColor.App.backgroundOdds

        self.suspendedBaseView.backgroundColor = UIColor.App.backgroundDisabledOdds
        self.suspendedBaseView.layer.borderColor = UIColor.App.backgroundBorder.resolvedColor(with: self.traitCollection).cgColor

        self.suspendedLabel.textColor = UIColor.App.textDisablePrimary

        self.seeAllBaseView.backgroundColor = UIColor.App.backgroundDisabledOdds
        self.seeAllLabel.textColor = UIColor.App.textPrimary

        self.liveGradientBorderView.gradientColors = [UIColor.App.liveBorderGradient3,
                                                      UIColor.App.liveBorderGradient2,
                                                      UIColor.App.liveBorderGradient1]

        self.gradientBorderView.gradientColors = [UIColor.App.cardBorderLineGradient1,
                                                  UIColor.App.cardBorderLineGradient2,
                                                  UIColor.App.cardBorderLineGradient3]


        // Home button styling
        if self.isLeftOutcomeButtonSelected {
            self.homeBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.homeOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.homeOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        }
        else {
            self.homeBaseView.backgroundColor = UIColor.App.backgroundOdds
            self.homeOddTitleLabel.textColor = UIColor.App.textPrimary
            self.homeOddValueLabel.textColor = UIColor.App.textPrimary
        }

        // Draw button styling
        if self.isMiddleOutcomeButtonSelected {
            self.drawBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.drawOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.drawOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        }
        else {
            self.drawBaseView.backgroundColor = UIColor.App.backgroundOdds
            self.drawOddTitleLabel.textColor = UIColor.App.textPrimary
            self.drawOddValueLabel.textColor = UIColor.App.textPrimary
        }

        // Away button styling
        if self.isRightOutcomeButtonSelected {
            self.awayBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.awayOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.awayOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        }
        else {
            self.awayBaseView.backgroundColor = UIColor.App.backgroundOdds
            self.awayOddTitleLabel.textColor = UIColor.App.textPrimary
            self.awayOddValueLabel.textColor = UIColor.App.textPrimary
        }


        // Colors based of status
        self.applyStatusBasedStyling()

        self.matchInfoView.setupWithTheme()
        self.matchHeaderView.setupWithTheme()
    }


    // MARK: - Status Based Styling
    private func applyStatusBasedStyling() {
        switch self.viewModel?.matchWidgetStatus ?? .unknown {
        case .live:
            self.baseView.backgroundColor = UIColor.App.backgroundDrop
        case .preLive:
            self.baseView.backgroundColor = UIColor.App.backgroundCards
        case .unknown:
            break
        }
    }

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

}
