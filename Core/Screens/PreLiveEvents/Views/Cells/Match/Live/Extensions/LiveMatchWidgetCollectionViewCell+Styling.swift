//
//  LiveMatchWidgetCollectionViewCell+Styling.swift
//  Sportsbook
//
//  Created by Refactoring on 2024.
//

import UIKit

// MARK: - Styling Methods
extension LiveMatchWidgetCollectionViewCell {

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

        self.topSeparatorAlphaLineView.backgroundColor = UIColor.App.highlightPrimary

        // Boosted Odds
        self.liveGradientBorderView.gradientColors = [UIColor.App.liveBorderGradient3,
                                                      UIColor.App.liveBorderGradient2,
                                                      UIColor.App.liveBorderGradient1]

        self.topSeparatorAlphaLineView.isHidden = false

        self.oddsStackView.isHidden = false

        self.setupButtonsColorState()

        // Clear borders
        self.homeBaseView.layer.borderColor = UIColor.clear.cgColor
        self.drawBaseView.layer.borderColor = UIColor.clear.cgColor
        self.awayBaseView.layer.borderColor = UIColor.clear.cgColor

        self.homeBaseView.layer.borderWidth = 0
        self.drawBaseView.layer.borderWidth = 0
        self.awayBaseView.layer.borderWidth = 0

        // Colors based of status
        self.baseView.backgroundColor = UIColor.App.backgroundDrop

        self.matchInfoView.setupWithTheme()
        self.matchHeaderView.setupWithTheme()
    }

    func setupButtonsColorState() {

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
    }
}
