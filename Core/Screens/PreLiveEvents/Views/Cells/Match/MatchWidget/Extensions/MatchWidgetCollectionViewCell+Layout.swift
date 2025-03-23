//
//  MatchWidgetCollectionViewCell+Layout.swift
//  Sportsbook
//
//  Created by Refactoring on 2024.
//

import UIKit

// MARK: - Layout Methods
extension MatchWidgetCollectionViewCell {

    func setupFonts() {
        self.suspendedLabel.font = AppFont.with(type: .bold, size: 13)
        self.seeAllLabel.font = AppFont.with(type: .bold, size: 13)
        // Odd value labels
        self.homeOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.drawOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.awayOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        // Odd title labels
        self.homeOddTitleLabel.font = AppFont.with(type: .medium, size: 10)
        self.drawOddTitleLabel.font = AppFont.with(type: .medium, size: 10)
        self.awayOddTitleLabel.font = AppFont.with(type: .medium, size: 10)
        // Participant name labels
        self.outrightNameLabel.font = AppFont.with(type: .bold, size: 14)

        // Boosted odds fonts
        self.homeNewBoostedOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.homeOldBoostedOddValueLabel.font = AppFont.with(type: .semibold, size: 9)
        self.drawNewBoostedOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.drawOldBoostedOddValueLabel.font = AppFont.with(type: .semibold, size: 9)
        self.awayNewBoostedOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.awayOldBoostedOddValueLabel.font = AppFont.with(type: .semibold, size: 9)

        self.outrightSeeLabel.font = AppFont.with(type: .semibold, size: 12)
    }

    func setupViewProperties() {
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear

        self.baseView.clipsToBounds = true
        self.baseView.layer.cornerRadius = 9

        self.boostedOddBottomLineAnimatedGradientView.startAnimations()
        
        self.homeUpChangeOddValueImage.alpha = 0.0
        self.homeDownChangeOddValueImage.alpha = 0.0
        self.drawUpChangeOddValueImage.alpha = 0.0
        self.drawDownChangeOddValueImage.alpha = 0.0
        self.awayUpChangeOddValueImage.alpha = 0.0
        self.awayDownChangeOddValueImage.alpha = 0.0

        self.outrightNameBaseView.backgroundColor = .clear

        self.oddsStackView.backgroundColor = .clear
        self.homeBaseView.backgroundColor = .clear
        self.drawBaseView.backgroundColor = .clear
        self.awayBaseView.backgroundColor = .clear

        self.awayBaseView.isHidden = false
        self.drawBaseView.isHidden = false

        self.suspendedBaseView.layer.cornerRadius = 4.5
        self.homeBaseView.layer.cornerRadius = 4.5
        self.drawBaseView.layer.cornerRadius = 4.5
        self.awayBaseView.layer.cornerRadius = 4.5

        self.seeAllBaseView.layer.cornerRadius = 4.5
        self.outrightBaseView.layer.cornerRadius = 4.5

        self.homeOddTitleLabel.text = ""
        self.drawOddTitleLabel.text = ""
        self.awayOddTitleLabel.text = ""

        self.setHomeOddValueLabel(toText: "")
        self.setDrawOddValueLabel(toText: "")
        self.setAwayOddValueLabel(toText: "")

        self.homeBaseView.isUserInteractionEnabled = true
        self.drawBaseView.isUserInteractionEnabled = true
        self.awayBaseView.isUserInteractionEnabled = true

        self.homeBaseView.alpha = 1.0
        self.drawBaseView.alpha = 1.0
        self.awayBaseView.alpha = 1.0

        self.outrightNameLabel.text = ""
        self.suspendedLabel.text = localized("suspended")

        self.oddsStackView.isHidden = false
        self.suspendedBaseView.isHidden = true
        self.seeAllBaseView.isHidden = true
        self.outrightBaseView.isHidden = true

        // Outright
        self.outrightSeeLabel.text = localized("view_competition_markets")
        self.outrightSeeLabel.font = AppFont.with(type: .semibold, size: 12)

        // Setup Live Tip
        self.hideLiveTipView()
        self.liveTipLabel.text = localized("live").uppercased() + " ⦿"

        // Setup Gradient Border
        self.gradientBorderView.isHidden = true
        self.liveGradientBorderView.isHidden = true

        // Setup Cashback
        self.hasCashback = false

        // Init with Theme
        self.setupWithTheme()
    }

    // MARK: - Setup Main Layout
    func setupSubviews() {
        // Add base view to content view
        self.contentView.addSubview(self.baseView)

        // Add stack view to base view
        self.baseView.addSubview(self.baseStackView)

        // Add elements to stack view
        self.baseStackView.addArrangedSubview(self.topImageBaseView)
        self.baseStackView.addArrangedSubview(self.mainContentBaseView)
        self.baseStackView.addArrangedSubview(self.boostedOddBottomLineView)

        // Set up top image view
        self.topImageBaseView.addSubview(self.topImageView)

        // Set up main content
        self.mainContentBaseView.addSubview(self.backgroundImageView)
        self.mainContentBaseView.addSubview(self.matchHeaderView)

        // Add odds stack view
        self.mainContentBaseView.addSubview(self.oddsStackView)

        // Set up odds buttons
        self.oddsStackView.addArrangedSubview(self.homeBaseView)
        self.oddsStackView.addArrangedSubview(self.drawBaseView)
        self.oddsStackView.addArrangedSubview(self.awayBaseView)

        // Set up home odds
        self.homeBaseView.addSubview(self.homeOddTitleLabel)
        self.homeBaseView.addSubview(self.homeOddValueLabel)
        self.homeBaseView.addSubview(self.homeBoostedOddValueBaseView)

        // Set up home boosted odds
        self.homeBoostedOddValueBaseView.addSubview(self.homeOldBoostedOddValueLabel)
        self.homeBoostedOddValueBaseView.addSubview(self.homeBoostedOddArrowView)
        self.homeBoostedOddValueBaseView.addSubview(self.homeNewBoostedOddValueLabel)

        // Set up home odd change indicators
        let homeOddChangeView = UIView()
        homeOddChangeView.translatesAutoresizingMaskIntoConstraints = false
        homeOddChangeView.backgroundColor = .clear
        homeOddChangeView.addSubview(self.homeUpChangeOddValueImage)
        homeOddChangeView.addSubview(self.homeDownChangeOddValueImage)
        self.homeBaseView.addSubview(homeOddChangeView)

        // Set up draw odds
        self.drawBaseView.addSubview(self.drawOddTitleLabel)
        self.drawBaseView.addSubview(self.drawOddValueLabel)
        self.drawBaseView.addSubview(self.drawBoostedOddValueBaseView)

        // Set up draw boosted odds
        self.drawBoostedOddValueBaseView.addSubview(self.drawOldBoostedOddValueLabel)
        self.drawBoostedOddValueBaseView.addSubview(self.drawBoostedOddArrowView)
        self.drawBoostedOddValueBaseView.addSubview(self.drawNewBoostedOddValueLabel)

        // Set up draw odd change indicators
        let drawOddChangeView = UIView()
        drawOddChangeView.translatesAutoresizingMaskIntoConstraints = false
        drawOddChangeView.backgroundColor = .clear
        drawOddChangeView.addSubview(self.drawUpChangeOddValueImage)
        drawOddChangeView.addSubview(self.drawDownChangeOddValueImage)
        self.drawBaseView.addSubview(drawOddChangeView)

        // Set up away odds
        self.awayBaseView.addSubview(self.awayOddTitleLabel)
        self.awayBaseView.addSubview(self.awayOddValueLabel)
        self.awayBaseView.addSubview(self.awayBoostedOddValueBaseView)

        // Set up away boosted odds
        self.awayBoostedOddValueBaseView.addSubview(self.awayOldBoostedOddValueLabel)
        self.awayBoostedOddValueBaseView.addSubview(self.awayBoostedOddArrowView)
        self.awayBoostedOddValueBaseView.addSubview(self.awayNewBoostedOddValueLabel)

        // Set up away odd change indicators
        let awayOddChangeView = UIView()
        awayOddChangeView.translatesAutoresizingMaskIntoConstraints = false
        awayOddChangeView.backgroundColor = .clear
        awayOddChangeView.addSubview(self.awayUpChangeOddValueImage)
        awayOddChangeView.addSubview(self.awayDownChangeOddValueImage)
        self.awayBaseView.addSubview(awayOddChangeView)

        // Set up suspended view
        self.mainContentBaseView.addSubview(self.suspendedBaseView)
        self.suspendedBaseView.addSubview(self.suspendedLabel)

        // Set up see all view
        self.mainContentBaseView.addSubview(self.seeAllBaseView)
        self.seeAllBaseView.addSubview(self.seeAllLabel)

        // Set up outright view
        self.mainContentBaseView.addSubview(self.outrightBaseView)
        self.outrightBaseView.addSubview(self.outrightSeeLabel)

        // Set up outright name view
        self.mainContentBaseView.addSubview(self.outrightNameBaseView)
        self.outrightNameBaseView.addSubview(self.outrightNameLabel)

        // Initialize the horizontalMatchInfoView
        // Set up border views
        self.baseView.addSubview(self.gradientBorderView)
        self.baseView.addSubview(self.liveGradientBorderView)

        self.baseView.sendSubviewToBack(self.liveGradientBorderView)
        self.baseView.sendSubviewToBack(self.gradientBorderView)

        //
        // Top Right icons
        // Setup cashback icon
        self.baseView.addSubview(self.topRightInfoIconsStackView)
        
        // Live Tip
        self.hideLiveTipView()
        self.liveTipView.addSubview(self.liveTipLabel)
        self.liveTipLabel.text = localized("live").uppercased() + " ⦿"
        self.liveTipView.layer.cornerRadius = 9
        
        self.cashbackIconContainerView.addSubview(self.cashbackIconImageView)
        self.topRightInfoIconsStackView.addArrangedSubview(self.cashbackIconContainerView)
        self.topRightInfoIconsStackView.addArrangedSubview(self.liveTipView)
        //
        
        //
        // Setup boosted odd bottom line

        self.setupBoostedOddBottomLine()
        self.setupBoostedAndMixMatch()

        // Initialize constraints
        self.initConstraints()

        // Setup redesign interface
        self.createRedesignInterface()

        // Setup boosted odd bar view
        self.setupBoostedOddBarView()
    }

    // MARK: - Setup Constraints
    func initConstraints() {
        // Base view constraints
        NSLayoutConstraint.activate([
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])

        // Base stack view constraints
        NSLayoutConstraint.activate([
            self.baseStackView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.baseStackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.baseStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.baseStackView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor)
        ])

        // Top image view constraints
        NSLayoutConstraint.activate([
            self.topImageBaseView.heightAnchor.constraint(equalToConstant: 100)
        ])

        NSLayoutConstraint.activate([
            self.topImageView.topAnchor.constraint(equalTo: self.topImageBaseView.topAnchor, constant: 2),
            self.topImageView.leadingAnchor.constraint(equalTo: self.topImageBaseView.leadingAnchor, constant: 2),
            self.topImageView.trailingAnchor.constraint(equalTo: self.topImageBaseView.trailingAnchor, constant: -2)
        ])

        // Header line constraints
        self.headerHeightConstraint = self.matchHeaderView.heightAnchor.constraint(equalToConstant: 17)
        self.headerHeightConstraint.isActive = true

        self.topMarginSpaceConstraint = self.matchHeaderView.topAnchor.constraint(equalTo: self.mainContentBaseView.topAnchor, constant: 12)
        self.leadingMarginSpaceConstraint = self.matchHeaderView.leadingAnchor.constraint(equalTo: self.mainContentBaseView.leadingAnchor, constant: 12)

        NSLayoutConstraint.activate([
            self.topMarginSpaceConstraint,
            self.leadingMarginSpaceConstraint,
            self.matchHeaderView.trailingAnchor.constraint(equalTo: self.topRightInfoIconsStackView.leadingAnchor, constant: -4)
        ])

        // Odds stack view constraints
        self.buttonsHeightConstraint = self.oddsStackView.heightAnchor.constraint(equalToConstant: 40)
        self.buttonsHeightConstraint.isActive = true

        self.bottomMarginSpaceConstraint = self.oddsStackView.bottomAnchor.constraint(equalTo: self.mainContentBaseView.bottomAnchor, constant: -12)
        self.trailingMarginSpaceConstraint = self.oddsStackView.trailingAnchor.constraint(equalTo: self.mainContentBaseView.trailingAnchor, constant: -12)

        NSLayoutConstraint.activate([
            self.oddsStackView.leadingAnchor.constraint(equalTo: self.mainContentBaseView.leadingAnchor, constant: 12),
            self.bottomMarginSpaceConstraint,
            self.trailingMarginSpaceConstraint
        ])

        // Home odds constraints
        NSLayoutConstraint.activate([
            self.homeOddTitleLabel.topAnchor.constraint(equalTo: self.homeBaseView.topAnchor, constant: 6),
            self.homeOddTitleLabel.centerXAnchor.constraint(equalTo: self.homeBaseView.centerXAnchor),
            self.homeOddTitleLabel.leadingAnchor.constraint(equalTo: self.homeBaseView.leadingAnchor, constant: 2),
            self.homeOddTitleLabel.trailingAnchor.constraint(equalTo: self.homeBaseView.trailingAnchor, constant: -2),
            self.homeOddTitleLabel.heightAnchor.constraint(equalToConstant: 14),

            self.homeOddValueLabel.topAnchor.constraint(equalTo: self.homeBaseView.centerYAnchor),
            self.homeOddValueLabel.topAnchor.constraint(equalTo: self.homeOddTitleLabel.bottomAnchor),
            self.homeOddValueLabel.centerXAnchor.constraint(equalTo: self.homeBaseView.centerXAnchor),
            self.homeOddValueLabel.leadingAnchor.constraint(equalTo: self.homeBaseView.leadingAnchor, constant: 2),
            self.homeOddValueLabel.trailingAnchor.constraint(equalTo: self.homeBaseView.trailingAnchor, constant: -2)
        ])

        // Draw odds constraints
        NSLayoutConstraint.activate([
            self.drawOddTitleLabel.topAnchor.constraint(equalTo: self.drawBaseView.topAnchor, constant: 6),
            self.drawOddTitleLabel.centerXAnchor.constraint(equalTo: self.drawBaseView.centerXAnchor),
            self.drawOddTitleLabel.leadingAnchor.constraint(equalTo: self.drawBaseView.leadingAnchor, constant: 2),
            self.drawOddTitleLabel.trailingAnchor.constraint(equalTo: self.drawBaseView.trailingAnchor, constant: -2),
            self.drawOddTitleLabel.heightAnchor.constraint(equalToConstant: 14),

            self.drawOddValueLabel.topAnchor.constraint(equalTo: self.drawBaseView.centerYAnchor),
            self.drawOddValueLabel.topAnchor.constraint(equalTo: self.drawOddTitleLabel.bottomAnchor),
            self.drawOddValueLabel.centerXAnchor.constraint(equalTo: self.drawBaseView.centerXAnchor),
            self.drawOddValueLabel.leadingAnchor.constraint(equalTo: self.drawBaseView.leadingAnchor, constant: 2),
            self.drawOddValueLabel.trailingAnchor.constraint(equalTo: self.drawBaseView.trailingAnchor, constant: -2)
        ])

        // Away odds constraints
        NSLayoutConstraint.activate([
            self.awayOddTitleLabel.topAnchor.constraint(equalTo: self.awayBaseView.topAnchor, constant: 6),
            self.awayOddTitleLabel.centerXAnchor.constraint(equalTo: self.awayBaseView.centerXAnchor),
            self.awayOddTitleLabel.leadingAnchor.constraint(equalTo: self.awayBaseView.leadingAnchor, constant: 2),
            self.awayOddTitleLabel.trailingAnchor.constraint(equalTo: self.awayBaseView.trailingAnchor, constant: -2),
            self.awayOddTitleLabel.heightAnchor.constraint(equalToConstant: 14),

            self.awayOddValueLabel.topAnchor.constraint(equalTo: self.awayBaseView.centerYAnchor),
            self.awayOddValueLabel.topAnchor.constraint(equalTo: self.awayOddTitleLabel.bottomAnchor),
            self.awayOddValueLabel.centerXAnchor.constraint(equalTo: self.awayBaseView.centerXAnchor),
            self.awayOddValueLabel.leadingAnchor.constraint(equalTo: self.awayBaseView.leadingAnchor, constant: 2),
            self.awayOddValueLabel.trailingAnchor.constraint(equalTo: self.awayBaseView.trailingAnchor, constant: -2)
        ])

        // Suspended view constraints
        NSLayoutConstraint.activate([
            self.suspendedBaseView.leadingAnchor.constraint(equalTo: self.homeBaseView.leadingAnchor),
            self.suspendedBaseView.trailingAnchor.constraint(equalTo: self.awayBaseView.trailingAnchor),
            self.suspendedBaseView.topAnchor.constraint(equalTo: self.homeBaseView.topAnchor),
            self.suspendedBaseView.bottomAnchor.constraint(equalTo: self.homeBaseView.bottomAnchor),

            self.suspendedLabel.centerXAnchor.constraint(equalTo: self.suspendedBaseView.centerXAnchor),
            self.suspendedLabel.centerYAnchor.constraint(equalTo: self.suspendedBaseView.centerYAnchor)
        ])

        // See all view constraints
        NSLayoutConstraint.activate([
            self.seeAllBaseView.leadingAnchor.constraint(equalTo: self.homeBaseView.leadingAnchor),
            self.seeAllBaseView.trailingAnchor.constraint(equalTo: self.awayBaseView.trailingAnchor),
            self.seeAllBaseView.topAnchor.constraint(equalTo: self.homeBaseView.topAnchor),
            self.seeAllBaseView.bottomAnchor.constraint(equalTo: self.homeBaseView.bottomAnchor),

            self.seeAllLabel.centerXAnchor.constraint(equalTo: self.seeAllBaseView.centerXAnchor),
            self.seeAllLabel.centerYAnchor.constraint(equalTo: self.seeAllBaseView.centerYAnchor)
        ])

        // Outright view constraints
        NSLayoutConstraint.activate([
            self.outrightBaseView.leadingAnchor.constraint(equalTo: self.oddsStackView.leadingAnchor),
            self.outrightBaseView.trailingAnchor.constraint(equalTo: self.oddsStackView.trailingAnchor),
            self.outrightBaseView.topAnchor.constraint(equalTo: self.homeBaseView.topAnchor),
            self.outrightBaseView.bottomAnchor.constraint(equalTo: self.homeBaseView.bottomAnchor),

            self.outrightSeeLabel.centerXAnchor.constraint(equalTo: self.outrightBaseView.centerXAnchor),
            self.outrightSeeLabel.centerYAnchor.constraint(equalTo: self.outrightBaseView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            self.outrightNameBaseView.topAnchor.constraint(equalTo: self.matchHeaderView.bottomAnchor, constant: 4),
            self.outrightNameBaseView.bottomAnchor.constraint(equalTo: self.oddsStackView.topAnchor, constant: 5),

            self.outrightNameLabel.centerYAnchor.constraint(equalTo: self.outrightNameBaseView.centerYAnchor),
            self.outrightNameLabel.leadingAnchor.constraint(equalTo: self.outrightNameBaseView.leadingAnchor, constant: 15),
            self.outrightNameLabel.trailingAnchor.constraint(equalTo: self.outrightNameBaseView.trailingAnchor, constant: -15)
        ])

        // Border view constraints
        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.gradientBorderView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.gradientBorderView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.gradientBorderView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.gradientBorderView.bottomAnchor),

            self.baseView.leadingAnchor.constraint(equalTo: self.liveGradientBorderView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.liveGradientBorderView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.liveGradientBorderView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.liveGradientBorderView.bottomAnchor),
        ])

        // Cashback
        NSLayoutConstraint.activate([
            self.cashbackIconImageView.widthAnchor.constraint(equalToConstant: 18),
            self.cashbackIconImageView.heightAnchor.constraint(equalTo: self.cashbackIconImageView.widthAnchor),
            
            self.cashbackIconContainerView.topAnchor.constraint(equalTo: self.cashbackIconImageView.topAnchor),
            self.cashbackIconContainerView.leadingAnchor.constraint(equalTo: self.cashbackIconImageView.leadingAnchor),
            self.cashbackIconContainerView.trailingAnchor.constraint(equalTo: self.cashbackIconImageView.trailingAnchor, constant: 16),
            self.cashbackIconContainerView.bottomAnchor.constraint(equalTo: self.cashbackIconImageView.bottomAnchor),
        ])
        
        // Live Tip
        NSLayoutConstraint.activate([
            self.liveTipView.heightAnchor.constraint(equalToConstant: 18),

            self.liveTipView.leadingAnchor.constraint(equalTo: self.liveTipLabel.leadingAnchor, constant: -9),
            self.liveTipView.trailingAnchor.constraint(equalTo: self.liveTipLabel.trailingAnchor, constant: 18),
            self.liveTipView.centerYAnchor.constraint(equalTo: self.liveTipLabel.centerYAnchor),
            self.liveTipView.topAnchor.constraint(equalTo: self.liveTipLabel.topAnchor, constant: 2),

            //
            self.topRightInfoIconsStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: 8),
            self.topRightInfoIconsStackView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 10)
        ])
    }

    // MARK: - Setup Specialized Views
    func setupBoostedOddBottomLine() {
        self.boostedOddBottomLineView.addSubview(self.boostedOddBottomLineAnimatedGradientView)

        NSLayoutConstraint.activate([
            self.boostedOddBottomLineView.leadingAnchor.constraint(equalTo: self.boostedOddBottomLineAnimatedGradientView.leadingAnchor),
            self.boostedOddBottomLineView.trailingAnchor.constraint(equalTo: self.boostedOddBottomLineAnimatedGradientView.trailingAnchor),
            self.boostedOddBottomLineView.topAnchor.constraint(equalTo: self.boostedOddBottomLineAnimatedGradientView.topAnchor),
            self.boostedOddBottomLineView.bottomAnchor.constraint(equalTo: self.boostedOddBottomLineAnimatedGradientView.bottomAnchor),
        ])
    }

    func setupBoostedAndMixMatch() {
        // See all button
        self.bottomSeeAllMarketsContainerView.isHidden = true

        self.baseStackView.addArrangedSubview(self.bottomSeeAllMarketsContainerView)

        self.bottomSeeAllMarketsContainerView.addSubview(self.bottomSeeAllMarketsBaseView)
        self.bottomSeeAllMarketsBaseView.addSubview(self.bottomSeeAllMarketsLabel)
        self.bottomSeeAllMarketsBaseView.addSubview(self.bottomSeeAllMarketsArrowIconImageView)

        NSLayoutConstraint.activate([
            self.bottomSeeAllMarketsContainerView.heightAnchor.constraint(equalToConstant: 34),

            self.bottomSeeAllMarketsBaseView.heightAnchor.constraint(equalToConstant: 27),
            self.bottomSeeAllMarketsBaseView.leadingAnchor.constraint(equalTo: self.bottomSeeAllMarketsContainerView.leadingAnchor, constant: 12),
            self.bottomSeeAllMarketsBaseView.trailingAnchor.constraint(equalTo: self.bottomSeeAllMarketsContainerView.trailingAnchor, constant: -12),
            self.bottomSeeAllMarketsBaseView.topAnchor.constraint(equalTo: self.bottomSeeAllMarketsContainerView.topAnchor),

            self.bottomSeeAllMarketsLabel.centerXAnchor.constraint(equalTo: self.bottomSeeAllMarketsBaseView.centerXAnchor),
            self.bottomSeeAllMarketsLabel.centerYAnchor.constraint(equalTo: self.bottomSeeAllMarketsBaseView.centerYAnchor),

            self.bottomSeeAllMarketsArrowIconImageView.widthAnchor.constraint(equalToConstant: 12),
            self.bottomSeeAllMarketsArrowIconImageView.heightAnchor.constraint(equalToConstant: 12),
            self.bottomSeeAllMarketsArrowIconImageView.leadingAnchor.constraint(equalTo: self.bottomSeeAllMarketsLabel.trailingAnchor, constant: 4),
            self.bottomSeeAllMarketsArrowIconImageView.centerYAnchor.constraint(equalTo: self.bottomSeeAllMarketsLabel.centerYAnchor),
        ])

        // MixMatch
        self.mixMatchContainerView.isHidden = true

        self.baseStackView.addArrangedSubview(self.mixMatchContainerView)
        self.mixMatchContainerView.addSubview(self.mixMatchBaseView)
        self.mixMatchBaseView.addSubview(self.mixMatchBackgroundImageView)
        self.mixMatchBaseView.addSubview(self.mixMatchIconImageView)
        self.mixMatchBaseView.addSubview(self.mixMatchLabel)
        self.mixMatchBaseView.addSubview(self.mixMatchNavigationIconImageView)

        NSLayoutConstraint.activate([
            self.mixMatchContainerView.heightAnchor.constraint(equalToConstant: 34),

            self.mixMatchBaseView.heightAnchor.constraint(equalToConstant: 27),
            self.mixMatchBaseView.leadingAnchor.constraint(equalTo: self.mixMatchContainerView.leadingAnchor, constant: 12),
            self.mixMatchBaseView.trailingAnchor.constraint(equalTo: self.mixMatchContainerView.trailingAnchor, constant: -12),
            self.mixMatchBaseView.topAnchor.constraint(equalTo: self.mixMatchContainerView.topAnchor),

            self.mixMatchBackgroundImageView.leadingAnchor.constraint(equalTo: self.mixMatchBaseView.leadingAnchor),
            self.mixMatchBackgroundImageView.trailingAnchor.constraint(equalTo: self.mixMatchBaseView.trailingAnchor),
            self.mixMatchBackgroundImageView.topAnchor.constraint(equalTo: self.mixMatchBaseView.topAnchor),
            self.mixMatchBackgroundImageView.bottomAnchor.constraint(equalTo: self.mixMatchBaseView.bottomAnchor),

            self.mixMatchLabel.centerXAnchor.constraint(equalTo: self.mixMatchBaseView.centerXAnchor),
            self.mixMatchLabel.centerYAnchor.constraint(equalTo: self.mixMatchBaseView.centerYAnchor),

            self.mixMatchIconImageView.widthAnchor.constraint(equalToConstant: 21),
            self.mixMatchIconImageView.heightAnchor.constraint(equalToConstant: 25),
            self.mixMatchIconImageView.trailingAnchor.constraint(equalTo: self.mixMatchLabel.leadingAnchor, constant: -2),
            self.mixMatchIconImageView.centerYAnchor.constraint(equalTo: self.mixMatchLabel.centerYAnchor),

            self.mixMatchNavigationIconImageView.widthAnchor.constraint(equalToConstant: 11),
            self.mixMatchNavigationIconImageView.heightAnchor.constraint(equalToConstant: 13),
            self.mixMatchNavigationIconImageView.leadingAnchor.constraint(equalTo: self.mixMatchLabel.trailingAnchor, constant: 6),
            self.mixMatchNavigationIconImageView.centerYAnchor.constraint(equalTo: self.mixMatchLabel.centerYAnchor),
        ])
    }
    
    func setupLayoutSubviews() {
        self.backgroundImageBorderGradientLayer.frame = self.baseView.bounds
        self.backgroundImageBorderShapeLayer.path = UIBezierPath(roundedRect: self.baseView.bounds,
                                                                 cornerRadius: 9).cgPath

        self.backgroundImageGradientLayer.frame = self.backgroundImageView.bounds

        self.topImageView.roundCorners(corners: [.topRight, .topLeft], radius: 9)
    }

    // MARK: - Card State Adjustments
    func drawAsLiveCard() {
        self.showLiveTipView()

        switch StyleHelper.cardsStyleActive() {
        case .small:
            self.adjustMarketNameView(isShown: false)
        case .normal:
            self.adjustMarketNameView(isShown: true)
        }

        if StyleHelper.cardsStyleActive() == .normal && self.viewModel?.matchWidgetType == .normal {
            self.bottomMarginSpaceConstraint.constant = -12
        }
    }

    func drawAsPreLiveCard() {
        self.hideLiveTipView()

        self.adjustMarketNameView(isShown: false)

        if StyleHelper.cardsStyleActive() == .normal && self.viewModel?.matchWidgetType == .normal {
            self.bottomMarginSpaceConstraint.constant = -12
        }
    }
    
    func showLiveTipView() {
        self.liveTipView.isHidden = false
        // to create a negative spacing to the cashback, make it closer
        self.topRightInfoIconsStackView.spacing = -7
    }
    
    func hideLiveTipView() {
        self.liveTipView.isHidden = true
        // cashback icon has a container view to give it space to the trailling superview
        self.topRightInfoIconsStackView.spacing = 0
    }

    private func adjustMarketNameView(isShown: Bool) {
        if isShown {
            self.marketTopConstraint.constant = 8
            self.marketBottomConstraint.constant = -10
            self.marketHeightConstraint.constant = 15
        }
        else {
            self.marketTopConstraint.constant = 0
            self.marketBottomConstraint.constant = 0
            self.marketHeightConstraint.constant = 0
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    // MARK: - Card Layout Style
    func adjustDesignToCardHeightStyle() {
        guard let matchWidgetType = self.viewModel?.matchWidgetType else { return }

        if matchWidgetType != .normal {
            if self.cachedCardsStyle == .small {
                self.cachedCardsStyle = .normal

                self.adjustDesignToNormalCardHeightStyle()

                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
            return
        }

        // Avoid calling redraw and layout if the style is the same.
        if self.cachedCardsStyle == StyleHelper.cardsStyleActive() {
            return
        }

        self.cachedCardsStyle = StyleHelper.cardsStyleActive()

        switch StyleHelper.cardsStyleActive() {
        case .small:
            self.adjustDesignToSmallCardHeightStyle()
        case .normal:
            self.adjustDesignToNormalCardHeightStyle()
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    func adjustDesignToSmallCardHeightStyle() {
        self.topMarginSpaceConstraint.constant = 8
        self.bottomMarginSpaceConstraint.constant = -8
        self.leadingMarginSpaceConstraint.constant = 8
        self.trailingMarginSpaceConstraint.constant = -8
        
        self.headerHeightConstraint.constant = 12
        self.buttonsHeightConstraint.constant = 27

        self.outrightNameLabel.font = AppFont.with(type: .bold, size: 13)
        self.outrightNameLabel.numberOfLines = 2

        self.homeOddValueLabel.font = AppFont.with(type: .bold, size: 12)
        self.drawOddValueLabel.font = AppFont.with(type: .bold, size: 12)
        self.awayOddValueLabel.font = AppFont.with(type: .bold, size: 12)
    }

    func adjustDesignToNormalCardHeightStyle() {
        self.topMarginSpaceConstraint.constant = 11
        self.bottomMarginSpaceConstraint.constant = -12
        self.leadingMarginSpaceConstraint.constant = 12
        self.trailingMarginSpaceConstraint.constant = -12

        self.headerHeightConstraint.constant = 17
        self.buttonsHeightConstraint.constant = 40

        self.outrightNameLabel.font = AppFont.with(type: .bold, size: 14)
        self.outrightNameLabel.numberOfLines = 3

        self.homeOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.drawOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.awayOddValueLabel.font = AppFont.with(type: .bold, size: 13)
    }

    // MARK: - Create Redesign Interface
    func createRedesignInterface() {
        // Add the matchInfoView to the mainContentBaseView
        self.mainContentBaseView.addSubview(self.matchInfoView)

        // Set up constraints for the matchInfoView
        NSLayoutConstraint.activate([
            self.matchInfoView.leadingAnchor.constraint(equalTo: self.mainContentBaseView.leadingAnchor, constant: 2),
            self.matchInfoView.trailingAnchor.constraint(equalTo: self.mainContentBaseView.trailingAnchor, constant: -2),
            self.matchInfoView.topAnchor.constraint(equalTo: self.matchHeaderView.bottomAnchor, constant: 3),
            self.matchInfoView.bottomAnchor.constraint(equalTo: self.oddsStackView.topAnchor, constant: 0)
        ])

        self.topSeparatorAlphaLineView.backgroundColor = UIColor.App.highlightPrimary
    }

    // MARK: - Setup Boosted Odd Bar
    func setupBoostedOddBarView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapBoostedOddButton))
        self.newValueBoostedButtonView.addGestureRecognizer(tapGesture)

        self.oldValueBoostedButtonView.addSubview(self.oldValueBoostedOddLabel)
        self.oldValueBoostedButtonView.addSubview(self.oldTitleBoostedOddLabel)

        self.oldValueBoostedButtonContainerView.addSubview(self.oldValueBoostedButtonView)

        self.newValueBoostedButtonView.addSubview(self.newValueBoostedOddLabel)
        self.newValueBoostedButtonView.addSubview(self.newTitleBoostedOddLabel)

        self.newValueBoostedButtonContainerView.addSubview(self.newValueBoostedButtonView)

        self.boostedOddBarStackView.addArrangedSubview(self.oldValueBoostedButtonContainerView)
        self.boostedOddBarStackView.addArrangedSubview(self.arrowSpacerView)
        self.boostedOddBarStackView.addArrangedSubview(self.newValueBoostedButtonContainerView)

        self.boostedOddBarView.addSubview(self.boostedOddBarStackView)

        self.mainContentBaseView.addSubview(self.boostedOddBarView)

        NSLayoutConstraint.activate([

            self.oldTitleBoostedOddLabel.leadingAnchor.constraint(equalTo: self.oldValueBoostedButtonView.leadingAnchor, constant: 3),
            self.oldTitleBoostedOddLabel.trailingAnchor.constraint(equalTo: self.oldValueBoostedButtonView.trailingAnchor, constant: -3),
            self.oldTitleBoostedOddLabel.topAnchor.constraint(equalTo: self.oldValueBoostedButtonView.topAnchor, constant: 6),
            self.oldTitleBoostedOddLabel.heightAnchor.constraint(equalToConstant: 9),

            self.oldValueBoostedOddLabel.leadingAnchor.constraint(equalTo: self.oldValueBoostedButtonView.leadingAnchor, constant: 3),
            self.oldValueBoostedOddLabel.trailingAnchor.constraint(equalTo: self.oldValueBoostedButtonView.trailingAnchor, constant: 3),
            self.oldValueBoostedOddLabel.bottomAnchor.constraint(equalTo: self.oldValueBoostedButtonView.bottomAnchor, constant: -6),
            self.oldValueBoostedOddLabel.heightAnchor.constraint(equalToConstant: 15),

            self.oldValueBoostedButtonView.leadingAnchor.constraint(equalTo: self.oldValueBoostedButtonContainerView.leadingAnchor),
            self.oldValueBoostedButtonView.trailingAnchor.constraint(equalTo: self.oldValueBoostedButtonContainerView.trailingAnchor),
            self.oldValueBoostedButtonView.topAnchor.constraint(equalTo: self.oldValueBoostedButtonContainerView.topAnchor),
            self.oldValueBoostedButtonView.bottomAnchor.constraint(equalTo: self.oldValueBoostedButtonContainerView.bottomAnchor),

            self.newTitleBoostedOddLabel.leadingAnchor.constraint(equalTo: self.newValueBoostedButtonView.leadingAnchor, constant: 3),
            self.newTitleBoostedOddLabel.trailingAnchor.constraint(equalTo: self.newValueBoostedButtonView.trailingAnchor, constant: -3),
            self.newTitleBoostedOddLabel.topAnchor.constraint(equalTo: self.newValueBoostedButtonView.topAnchor, constant: 6),
            self.newTitleBoostedOddLabel.heightAnchor.constraint(equalToConstant: 9),

            self.newValueBoostedOddLabel.leadingAnchor.constraint(equalTo: self.newValueBoostedButtonView.leadingAnchor, constant: 3),
            self.newValueBoostedOddLabel.trailingAnchor.constraint(equalTo: self.newValueBoostedButtonView.trailingAnchor, constant: 3),
            self.newValueBoostedOddLabel.bottomAnchor.constraint(equalTo: self.newValueBoostedButtonView.bottomAnchor, constant: -6),
            self.newValueBoostedOddLabel.heightAnchor.constraint(equalToConstant: 15),

            self.newValueBoostedButtonView.leadingAnchor.constraint(equalTo: self.newValueBoostedButtonContainerView.leadingAnchor),
            self.newValueBoostedButtonView.trailingAnchor.constraint(equalTo: self.newValueBoostedButtonContainerView.trailingAnchor),
            self.newValueBoostedButtonView.topAnchor.constraint(equalTo: self.newValueBoostedButtonContainerView.topAnchor),
            self.newValueBoostedButtonView.bottomAnchor.constraint(equalTo: self.newValueBoostedButtonContainerView.bottomAnchor),

            self.boostedOddBarView.leadingAnchor.constraint(equalTo: self.oddsStackView.leadingAnchor),
            self.boostedOddBarView.trailingAnchor.constraint(equalTo: self.oddsStackView.trailingAnchor),
            self.boostedOddBarView.topAnchor.constraint(equalTo: self.oddsStackView.topAnchor),
            self.boostedOddBarView.bottomAnchor.constraint(equalTo: self.oddsStackView.bottomAnchor),

            self.arrowSpacerView.widthAnchor.constraint(equalTo: self.boostedOddBarStackView.heightAnchor),

            self.oldValueBoostedButtonContainerView.widthAnchor.constraint(equalTo: self.newValueBoostedButtonContainerView.widthAnchor),

            self.boostedOddBarStackView.leadingAnchor.constraint(equalTo: self.boostedOddBarView.leadingAnchor),
            self.boostedOddBarStackView.trailingAnchor.constraint(equalTo: self.boostedOddBarView.trailingAnchor),
            self.boostedOddBarStackView.topAnchor.constraint(equalTo: self.boostedOddBarView.topAnchor),
            self.boostedOddBarStackView.bottomAnchor.constraint(equalTo: self.boostedOddBarView.bottomAnchor),
        ])
    }

    // MARK: - Setup Boosted Odds Subviews
    func setupBoostedOddsSubviews() {
        self.boostedTopRightCornerBaseView.translatesAutoresizingMaskIntoConstraints = false
        self.boostedTopRightCornerBaseView.backgroundColor = .clear

        self.boostedTopRightCornerImageView.contentMode = .scaleAspectFit
        self.boostedTopRightCornerImageView.translatesAutoresizingMaskIntoConstraints = false

        self.boostedTopRightCornerBaseView.addSubview(self.boostedTopRightCornerImageView)
        self.baseView.addSubview(self.boostedTopRightCornerBaseView)

        self.boostedBackgroungImageView.translatesAutoresizingMaskIntoConstraints = false
        self.boostedBackgroungImageView.backgroundColor = UIColor.App.backgroundCards
        self.boostedBackgroungImageView.contentMode = .scaleAspectFill
        self.boostedBackgroungImageView.image = UIImage(named: "boosted_card_background")

        self.baseView.insertSubview(self.boostedBackgroungImageView, at: 0)

        NSLayoutConstraint.activate([
            self.boostedTopRightCornerImageView.topAnchor.constraint(equalTo: self.boostedTopRightCornerBaseView.topAnchor),
            self.boostedTopRightCornerImageView.trailingAnchor.constraint(equalTo: self.boostedTopRightCornerBaseView.trailingAnchor),
            self.boostedTopRightCornerImageView.widthAnchor.constraint(equalTo: self.boostedTopRightCornerImageView.heightAnchor, multiplier: (134.0/34.0)),

            self.boostedTopRightCornerImageView.heightAnchor.constraint(equalToConstant: 24),

            self.boostedBackgroungImageView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.boostedBackgroungImageView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.boostedBackgroungImageView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.boostedBackgroungImageView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),

            self.boostedTopRightCornerBaseView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 6),
            self.boostedTopRightCornerBaseView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -7),
        ])
    }
}
