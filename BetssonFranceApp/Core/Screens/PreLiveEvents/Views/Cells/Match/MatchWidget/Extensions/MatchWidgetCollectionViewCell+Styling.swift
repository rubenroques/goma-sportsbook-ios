//
//  MatchWidgetCollectionViewCell+Styling.swift
//  Sportsbook
//
//  Created by Refactoring on 2024.
//

import UIKit

// MARK: - Styling Methods
extension MatchWidgetCollectionViewCell {

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

        self.outrightBaseView.backgroundColor = UIColor.App.backgroundDisabledOdds
        self.outrightSeeLabel.textColor = UIColor.App.textPrimary

        // Bottom UI Elements
        self.bottomSeeAllMarketsBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.bottomSeeAllMarketsLabel.textColor = UIColor.App.textSecondary
        self.bottomSeeAllMarketsArrowIconImageView.setTintColor(color: UIColor.App.iconSecondary)

        // Boosted Odds
        self.boostedTopRightCornerLabel.textColor = UIColor.App.textPrimary

        self.homeBoostedOddValueBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.drawBoostedOddValueBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.awayBoostedOddValueBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary

        self.homeNewBoostedOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        self.homeOldBoostedOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        self.drawNewBoostedOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        self.drawOldBoostedOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        self.awayNewBoostedOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        self.awayOldBoostedOddValueLabel.textColor = UIColor.App.buttonTextPrimary

        self.liveGradientBorderView.gradientColors = [UIColor.App.liveBorder3,
                                                      UIColor.App.liveBorder2,
                                                      UIColor.App.liveBorder1]

        self.gradientBorderView.gradientColors = [UIColor.App.cardBorderLineGradient1,
                                                  UIColor.App.cardBorderLineGradient2,
                                                  UIColor.App.cardBorderLineGradient3]


        // Apply styling based on widget type
        self.applyWidgetTypeSpecificStyling()

        // Colors based of status
        self.applyStatusBasedStyling()

        self.matchInfoView.setupWithTheme()
        self.matchHeaderView.setupWithTheme()
    }

    // MARK: - Widget Type Styling
    private func applyWidgetTypeSpecificStyling() {
        switch self.viewModel?.matchWidgetType ?? .normal {
        case .normal, .topImage, .topImageWithMixMatch:
            applyNormalStyling()
        case .topImageOutright:
            applyOutrightStyling()
        case .boosted:
            applyBoostedStyling()
        case .backgroundImage:
            applyBackgroundImageStyling()
        }
    }

    private func applyNormalStyling() {
        self.topSeparatorAlphaLineView.isHidden = false

        self.oddsStackView.isHidden = false
        self.boostedOddBarView.isHidden = true

        // Home button styling
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

        // Draw button styling
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

        // Away button styling
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

        // Clear borders
        self.homeBaseView.layer.borderColor = UIColor.clear.cgColor
        self.drawBaseView.layer.borderColor = UIColor.clear.cgColor
        self.awayBaseView.layer.borderColor = UIColor.clear.cgColor

        self.homeBaseView.layer.borderWidth = 0
        self.drawBaseView.layer.borderWidth = 0
        self.awayBaseView.layer.borderWidth = 0
    }

    private func applyOutrightStyling() {
        self.liveTipLabel.textColor = UIColor.App.buttonTextPrimary
        self.outrightNameLabel.textColor = UIColor.App.textPrimary

        self.topSeparatorAlphaLineView.isHidden = false

        self.oddsStackView.isHidden = false
        self.boostedOddBarView.isHidden = true

        // Apply button stylings similar to normal mode
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

        // Clear borders
        self.homeBaseView.layer.borderColor = UIColor.clear.cgColor
        self.drawBaseView.layer.borderColor = UIColor.clear.cgColor
        self.awayBaseView.layer.borderColor = UIColor.clear.cgColor

        self.homeBaseView.layer.borderWidth = 0
        self.drawBaseView.layer.borderWidth = 0
        self.awayBaseView.layer.borderWidth = 0
    }

    private func applyBoostedStyling() {
        self.liveTipLabel.textColor = UIColor.App.buttonTextPrimary

        self.topSeparatorAlphaLineView.isHidden = false

        self.oddsStackView.isHidden = true
        self.boostedOddBarView.isHidden = false

        // Boosted button styling
        if self.isBoostedOutcomeButtonSelected {
            self.newValueBoostedButtonView.backgroundColor = UIColor.App.highlightPrimary
            self.newValueBoostedButtonView.layer.borderColor = UIColor.App.buttonTextPrimary.cgColor
            self.newTitleBoostedOddLabel.textColor = UIColor.App.buttonTextPrimary
            self.newValueBoostedOddLabel.textColor = UIColor.App.buttonTextPrimary
        }
        else {
            self.newValueBoostedButtonView.backgroundColor = UIColor.App.inputBackground
            self.newValueBoostedButtonView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
            self.newTitleBoostedOddLabel.textColor = UIColor.App.textPrimary
            self.newValueBoostedOddLabel.textColor = UIColor.App.textPrimary
        }

        // Clear borders
        self.homeBaseView.layer.borderColor = UIColor.clear.cgColor
        self.drawBaseView.layer.borderColor = UIColor.clear.cgColor
        self.awayBaseView.layer.borderColor = UIColor.clear.cgColor

        self.homeBaseView.layer.borderWidth = 0
        self.drawBaseView.layer.borderWidth = 0
        self.awayBaseView.layer.borderWidth = 0

        self.boostedOddBottomLineAnimatedGradientView.startAnimations()
    }

    private func applyBackgroundImageStyling() {
        self.liveTipLabel.textColor = UIColor.App.buttonTextPrimary

        self.topSeparatorAlphaLineView.isHidden = true

        self.oddsStackView.isHidden = false
        self.boostedOddBarView.isHidden = true

        // Button styling with transparent background
        if isLeftOutcomeButtonSelected {
            self.homeBaseView.backgroundColor = UIColor.App.highlightPrimary
            self.homeOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.homeOddValueLabel.textColor = UIColor.App.buttonTextPrimary

            self.homeBaseView.layer.borderWidth = 0
        }

        if isMiddleOutcomeButtonSelected {
            self.drawBaseView.backgroundColor = UIColor.App.highlightPrimary
            self.drawOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.drawOddValueLabel.textColor = UIColor.App.buttonTextPrimary

            self.drawBaseView.layer.borderWidth = 0
        }

        if isRightOutcomeButtonSelected {
            self.awayBaseView.backgroundColor = UIColor.App.highlightPrimary
            self.awayOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.awayOddValueLabel.textColor = UIColor.App.buttonTextPrimary

            self.awayBaseView.layer.borderWidth = 0
        }

        // Add borders to non-selected buttons
        self.homeBaseView.layer.borderColor = UIColor.App.buttonTextPrimary.cgColor
        self.drawBaseView.layer.borderColor = UIColor.App.buttonTextPrimary.cgColor
        self.awayBaseView.layer.borderColor = UIColor.App.buttonTextPrimary.cgColor

        self.homeBaseView.layer.borderWidth = 2
        self.drawBaseView.layer.borderWidth = 2
        self.awayBaseView.layer.borderWidth = 2

        self.homeBaseView.backgroundColor = UIColor.clear
        self.drawBaseView.backgroundColor = UIColor.clear
        self.awayBaseView.backgroundColor = UIColor.clear

        self.homeOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
        self.homeOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        self.drawOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
        self.drawOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        self.awayOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
        self.awayOddValueLabel.textColor = UIColor.App.buttonTextPrimary
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

    // MARK: - Widget Type Layout
    func drawForMatchWidgetType(_ matchWidgetType: MatchWidgetType) {
        switch matchWidgetType {
        case .normal:
            setupNormalWidgetLayout()
        case .topImage, .topImageWithMixMatch:
            setupTopImageWidgetLayout()
        case .topImageOutright:
            setupTopImageOutrightWidgetLayout()
        case .boosted:
            setupBoostedWidgetLayout()
        case .backgroundImage:
            setupBackgroundImageWidgetLayout()
        }

        self.setupWithTheme()
    }

    private func setupNormalWidgetLayout() {
        self.backgroundImageView.isHidden = true

        self.topImageBaseView.isHidden = true
        self.boostedOddBottomLineView.isHidden = true
        self.boostedTopRightCornerBaseView.isHidden = true

        self.mainContentBaseView.isHidden = false

        self.outrightNameBaseView.isHidden = true

        self.baseView.layer.borderWidth = 0
        self.baseView.layer.borderColor = nil


        self.homeBoostedOddValueBaseView.isHidden = true
        self.drawBoostedOddValueBaseView.isHidden = true
        self.awayBoostedOddValueBaseView.isHidden = true

        switch StyleHelper.cardsStyleActive() {
        case .small:
            self.bottomMarginSpaceConstraint.constant = -8
            self.topMarginSpaceConstraint.constant = 8
        case .normal:
            self.bottomMarginSpaceConstraint.constant = -12
            self.topMarginSpaceConstraint.constant = 11
        }
    }

    private func setupTopImageWidgetLayout() {
        self.backgroundImageView.isHidden = true

        self.topImageBaseView.isHidden = false

        self.boostedOddBottomLineView.isHidden = true
        self.boostedTopRightCornerBaseView.isHidden = true

        self.mainContentBaseView.isHidden = false

        self.outrightNameBaseView.isHidden = true

        self.homeBoostedOddValueBaseView.isHidden = true
        self.drawBoostedOddValueBaseView.isHidden = true
        self.awayBoostedOddValueBaseView.isHidden = true

        self.baseView.layer.borderWidth = 0
        self.baseView.layer.borderColor = nil

        self.bottomMarginSpaceConstraint.constant = -12
        self.topMarginSpaceConstraint.constant = 11
    }

    private func setupTopImageOutrightWidgetLayout() {
        self.backgroundImageView.isHidden = true

        self.topImageBaseView.isHidden = false

        self.boostedOddBottomLineView.isHidden = true
        self.boostedTopRightCornerBaseView.isHidden = true

        self.mainContentBaseView.isHidden = false

        self.homeBoostedOddValueBaseView.isHidden = true
        self.drawBoostedOddValueBaseView.isHidden = true
        self.awayBoostedOddValueBaseView.isHidden = true

        self.seeAllBaseView.isHidden = true
        self.oddsStackView.isHidden = true
        self.suspendedBaseView.isHidden = true
        self.outrightBaseView.isHidden = false

        self.baseView.layer.borderWidth = 0
        self.baseView.layer.borderColor = nil

        self.bottomMarginSpaceConstraint.constant = -12
        self.topMarginSpaceConstraint.constant = 11

        self.showOutrightLayout()
    }

    private func setupBoostedWidgetLayout() {
        self.backgroundImageView.isHidden = true

        self.topImageBaseView.isHidden = true
        self.boostedOddBottomLineView.isHidden = false
        self.boostedTopRightCornerBaseView.isHidden = false

        self.mainContentBaseView.isHidden = false

        self.outrightNameBaseView.isHidden = true

        self.homeBoostedOddValueBaseView.isHidden = false
        self.drawBoostedOddValueBaseView.isHidden = false
        self.awayBoostedOddValueBaseView.isHidden = false

        self.bottomMarginSpaceConstraint.constant = -12
        self.topMarginSpaceConstraint.constant = 11

        self.setupBoostedOddsSubviews()
    }

    private func setupBackgroundImageWidgetLayout() {
        self.backgroundImageView.isHidden = false

        self.topImageBaseView.isHidden = true
        self.boostedOddBottomLineView.isHidden = true
        self.boostedTopRightCornerBaseView.isHidden = true

        self.mainContentBaseView.isHidden = false

        self.outrightNameBaseView.isHidden = true

        self.homeBoostedOddValueBaseView.isHidden = true
        self.drawBoostedOddValueBaseView.isHidden = true
        self.awayBoostedOddValueBaseView.isHidden = true

        self.baseView.layer.borderWidth = 0
        self.baseView.layer.borderColor = nil

        self.bottomMarginSpaceConstraint.constant = -28
        self.topMarginSpaceConstraint.constant = 0

        self.backgroundImageBorderGradientLayer.colors = [UIColor(hex: 0x404CFF).cgColor, UIColor(hex: 0x404CFF).withAlphaComponent(0.0).cgColor]
        self.backgroundImageBorderGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        self.backgroundImageBorderGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        self.backgroundImageBorderShapeLayer.cornerRadius = 9
        self.backgroundImageBorderShapeLayer.lineWidth = 2
        self.backgroundImageBorderShapeLayer.strokeColor = UIColor.black.cgColor
        self.backgroundImageBorderShapeLayer.fillColor = UIColor.clear.cgColor

        self.backgroundImageBorderGradientLayer.mask = self.backgroundImageBorderShapeLayer
        self.baseView.layer.addSublayer(self.backgroundImageBorderGradientLayer)
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

    func showOutrightLayout() {
        self.oddsStackView.isHidden = true
        self.suspendedBaseView.isHidden = true
        self.seeAllBaseView.isHidden = true
        self.outrightBaseView.isHidden = false

        self.outrightNameBaseView.isHidden = false
    }
}
