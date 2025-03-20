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
        self.eventNameLabel.font = AppFont.with(type: .medium, size: 14)
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
        self.marketNameLabel.font = AppFont.with(type: .bold, size: 8)
    }

    func setupViewProperties() {
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear

        self.baseView.clipsToBounds = true
        self.baseView.layer.cornerRadius = 9

        self.homeUpChangeOddValueImage.alpha = 0.0
        self.homeDownChangeOddValueImage.alpha = 0.0
        self.drawUpChangeOddValueImage.alpha = 0.0
        self.drawDownChangeOddValueImage.alpha = 0.0
        self.awayUpChangeOddValueImage.alpha = 0.0
        self.awayDownChangeOddValueImage.alpha = 0.0

        self.favoritesButton.backgroundColor = .clear
        self.horizontalMatchInfoBaseView.backgroundColor = .clear
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

        self.eventNameLabel.text = ""

        self.homeNameLabel.text = ""
        self.awayNameLabel.text = ""

        self.homeServingIndicatorView.isHidden = true
        self.awayServingIndicatorView.isHidden = true

        self.detailedScoreView.updateScores([:])

        self.outrightNameLabel.text = ""

        self.matchTimeStatusNewLabel.text = ""

        self.dateNewLabel.text = ""
        self.timeNewLabel.text = ""

        self.matchTimeStatusNewLabel.isHidden = true

        self.suspendedLabel.text = localized("suspended")

        self.locationFlagImageView.image = nil
        self.sportTypeImageView.image = nil

        self.oddsStackView.isHidden = false
        self.suspendedBaseView.isHidden = true
        self.seeAllBaseView.isHidden = true
        self.outrightBaseView.isHidden = true

        // Outright
        self.outrightSeeLabel.text = localized("view_competition_markets")
        self.outrightSeeLabel.font = AppFont.with(type: .semibold, size: 12)

        // Market view and label
        self.marketNameLabel.text = ""
        self.marketNameLabel.font = AppFont.with(type: .bold, size: 8)

        self.marketNamePillLabelView.title = ""
        self.marketNamePillLabelView.isHidden = true

        // Old style for teams and scores
        self.horizontalMatchInfoBaseView.isHidden = true
        self.marketNameView.isHidden = true

        // Setup Live Tip
        self.liveTipView.isHidden = true
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
        self.mainContentBaseView.addSubview(self.headerLineStackView)

        // Set up header line
        self.headerLineStackView.addArrangedSubview(self.favoritesIconImageView)
        self.headerLineStackView.addArrangedSubview(self.sportTypeImageView)
        self.headerLineStackView.addArrangedSubview(self.locationFlagImageView)

        // Add event name to container and add to header
        self.eventNameContainerView.addSubview(self.eventNameLabel)
        self.headerLineStackView.addArrangedSubview(self.eventNameContainerView)

        // Add favorites button
        self.mainContentBaseView.addSubview(self.favoritesButton)

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

        // Set up horizontal match info view
        self.mainContentBaseView.addSubview(self.horizontalMatchInfoBaseView)
        self.horizontalMatchInfoBaseView.addSubview(self.horizontalMatchInfoView)

        // Set up market name view
        self.mainContentBaseView.addSubview(self.marketNameView)
        self.marketNameView.addSubview(self.marketNameInnerView)
        self.marketNameInnerView.addSubview(self.marketNameLabel)

        // Initialize the horizontalMatchInfoView
        self.horizontalMatchInfoBaseView.addSubview(self.horizontalMatchInfoView)

        // Set up border views
        self.baseView.addSubview(self.gradientBorderView)
        self.baseView.addSubview(self.liveGradientBorderView)

        self.baseView.sendSubviewToBack(self.liveGradientBorderView)
        self.baseView.sendSubviewToBack(self.gradientBorderView)

        // Setup live tip view
        self.baseView.addSubview(self.liveTipView)
        self.liveTipView.addSubview(self.liveTipLabel)

        // Setup cashback icon
        self.baseView.addSubview(self.cashbackIconImageView)

        // Setup boosted odd bottom line
        self.setupBoostedOddBottomLine()

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
        self.headerHeightConstraint = self.headerLineStackView.heightAnchor.constraint(equalToConstant: 17)
        self.headerHeightConstraint.isActive = true

        self.topMarginSpaceConstraint = self.headerLineStackView.topAnchor.constraint(equalTo: self.mainContentBaseView.topAnchor, constant: 12)
        self.leadingMarginSpaceConstraint = self.headerLineStackView.leadingAnchor.constraint(equalTo: self.mainContentBaseView.leadingAnchor, constant: 12)

        NSLayoutConstraint.activate([
            self.topMarginSpaceConstraint,
            self.leadingMarginSpaceConstraint
        ])

        // Event name label constraints
        NSLayoutConstraint.activate([
            self.eventNameLabel.leadingAnchor.constraint(equalTo: eventNameContainerView.leadingAnchor),
            self.eventNameLabel.trailingAnchor.constraint(equalTo: eventNameContainerView.trailingAnchor, constant: -1),
            self.eventNameLabel.centerYAnchor.constraint(equalTo: eventNameContainerView.centerYAnchor, constant: 1)
        ])

        // Favorites button constraints
        NSLayoutConstraint.activate([
            self.favoritesButton.centerXAnchor.constraint(equalTo: self.favoritesIconImageView.centerXAnchor),
            self.favoritesButton.centerYAnchor.constraint(equalTo: self.favoritesIconImageView.centerYAnchor),
            self.favoritesButton.widthAnchor.constraint(equalToConstant: 40),
            self.favoritesButton.heightAnchor.constraint(equalToConstant: 40)
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

        // Outright name view constraints
        self.teamsHeightConstraint = self.horizontalMatchInfoBaseView.heightAnchor.constraint(greaterThanOrEqualToConstant: 67)
        self.teamsHeightConstraint.isActive = true

        NSLayoutConstraint.activate([
            self.outrightNameBaseView.leadingAnchor.constraint(equalTo: self.horizontalMatchInfoBaseView.leadingAnchor),
            self.outrightNameBaseView.trailingAnchor.constraint(equalTo: self.horizontalMatchInfoBaseView.trailingAnchor),
            self.outrightNameBaseView.topAnchor.constraint(equalTo: self.headerLineStackView.bottomAnchor, constant: 4),
            self.outrightNameBaseView.bottomAnchor.constraint(equalTo: self.oddsStackView.topAnchor, constant: 5),

            self.outrightNameLabel.centerYAnchor.constraint(equalTo: self.outrightNameBaseView.centerYAnchor),
            self.outrightNameLabel.leadingAnchor.constraint(equalTo: self.outrightNameBaseView.leadingAnchor, constant: 15),
            self.outrightNameLabel.trailingAnchor.constraint(equalTo: self.outrightNameBaseView.trailingAnchor, constant: -15)
        ])

        // Horizontal match info view constraints
        NSLayoutConstraint.activate([
            self.horizontalMatchInfoBaseView.leadingAnchor.constraint(equalTo: self.oddsStackView.leadingAnchor),
            self.horizontalMatchInfoBaseView.trailingAnchor.constraint(equalTo: self.oddsStackView.trailingAnchor),
            self.horizontalMatchInfoBaseView.topAnchor.constraint(equalTo: self.headerLineStackView.bottomAnchor, constant: 4)
        ])

        // Market name view constraints
        self.marketHeightConstraint = self.marketNameView.heightAnchor.constraint(equalToConstant: 15)
        self.marketHeightConstraint.isActive = true

        self.marketTopConstraint = self.marketNameView.topAnchor.constraint(equalTo: self.horizontalMatchInfoBaseView.bottomAnchor, constant: 8)
        self.marketBottomConstraint = self.marketNameView.bottomAnchor.constraint(equalTo: self.oddsStackView.topAnchor, constant: -10)

        NSLayoutConstraint.activate([
            self.marketNameView.leadingAnchor.constraint(equalTo: self.mainContentBaseView.leadingAnchor, constant: 12),
            self.marketNameView.trailingAnchor.constraint(equalTo: self.mainContentBaseView.trailingAnchor, constant: -12),
            self.marketTopConstraint,
            self.marketBottomConstraint,

            self.marketNameInnerView.centerXAnchor.constraint(equalTo: self.marketNameView.centerXAnchor),
            self.marketNameInnerView.topAnchor.constraint(equalTo: self.marketNameView.topAnchor, constant: 1),
            self.marketNameInnerView.bottomAnchor.constraint(equalTo: self.marketNameView.bottomAnchor, constant: -1),

            self.marketNameLabel.centerYAnchor.constraint(equalTo: self.marketNameInnerView.centerYAnchor),
            self.marketNameLabel.leadingAnchor.constraint(equalTo: self.marketNameInnerView.leadingAnchor, constant: 7),
            self.marketNameLabel.trailingAnchor.constraint(equalTo: self.marketNameInnerView.trailingAnchor, constant: -7)
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
    }

    // MARK: - Setup Specialized Views
    func setupBoostedOddBottomLine() {
        self.boostedOddBottomLineAnimatedGradientView.translatesAutoresizingMaskIntoConstraints = false
        self.boostedOddBottomLineAnimatedGradientView.colors = [
            (UIColor.init(hex: 0xFF6600), NSNumber(0.0)),
            (UIColor.init(hex: 0xFEDB00), NSNumber(1.0))
        ]
        self.boostedOddBottomLineAnimatedGradientView.startPoint = CGPoint(x: 0.0, y: 0.5)
        self.boostedOddBottomLineAnimatedGradientView.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.boostedOddBottomLineAnimatedGradientView.startAnimations()

        self.boostedOddBottomLineView.addSubview(self.boostedOddBottomLineAnimatedGradientView)

        NSLayoutConstraint.activate([
            self.boostedOddBottomLineView.leadingAnchor.constraint(equalTo: self.boostedOddBottomLineAnimatedGradientView.leadingAnchor),
            self.boostedOddBottomLineView.trailingAnchor.constraint(equalTo: self.boostedOddBottomLineAnimatedGradientView.trailingAnchor),
            self.boostedOddBottomLineView.topAnchor.constraint(equalTo: self.boostedOddBottomLineAnimatedGradientView.topAnchor),
            self.boostedOddBottomLineView.bottomAnchor.constraint(equalTo: self.boostedOddBottomLineAnimatedGradientView.bottomAnchor),
        ])
    }

    func setupLayoutSubviews() {
        self.backgroundImageBorderGradientLayer.frame = self.baseView.bounds
        self.backgroundImageBorderShapeLayer.path = UIBezierPath(roundedRect: self.baseView.bounds,
                                                                 cornerRadius: 9).cgPath

        self.backgroundImageGradientLayer.frame = self.backgroundImageView.bounds
        self.locationFlagImageView.layer.cornerRadius = self.locationFlagImageView.frame.size.width / 2

        self.awayServingIndicatorView.layer.cornerRadius = self.awayServingIndicatorView.frame.size.width / 2
        self.homeServingIndicatorView.layer.cornerRadius = self.homeServingIndicatorView.frame.size.width / 2

        self.locationFlagImageView.layer.borderWidth = 0.5

        self.topImageView.roundCorners(corners: [.topRight, .topLeft], radius: 9)

        self.marketNameInnerView.layer.cornerRadius = self.marketNameInnerView.frame.size.height / 2
    }

    // MARK: - Card State Adjustments
    func drawAsLiveCard() {
        self.dateNewLabel.isHidden = true
        self.timeNewLabel.isHidden = true

        self.homeToRightConstraint.isActive = false
        self.awayToRightConstraint.isActive = false

        self.detailedScoreView.isHidden = false

        self.matchTimeStatusNewLabel.isHidden = false

        self.liveTipView.isHidden = false

        self.cashbackImageViewBaseTrailingConstraint.isActive = false
        self.cashbackImageViewLiveTrailingConstraint.isActive = true

        switch StyleHelper.cardsStyleActive() {
        case .small:
            self.adjustMarketNameView(isShown: false)
        case .normal:
            self.adjustMarketNameView(isShown: true)
        }

        if StyleHelper.cardsStyleActive() == .normal && self.viewModel?.matchWidgetType == .normal {
            self.bottomMarginSpaceConstraint.constant = 12

            self.homeContentRedesignTopConstraint.constant = 13
            self.awayContentRedesignTopConstraint.constant = 33
        }
    }

    func drawAsPreLiveCard() {
        self.dateNewLabel.isHidden = false
        self.timeNewLabel.isHidden = false

        self.homeToRightConstraint.isActive = true
        self.awayToRightConstraint.isActive = true

        self.detailedScoreView.isHidden = true

        self.matchTimeStatusNewLabel.isHidden = true

        self.liveTipView.isHidden = true

        self.cashbackImageViewBaseTrailingConstraint.isActive = true
        self.cashbackImageViewLiveTrailingConstraint.isActive = false

        self.adjustMarketNameView(isShown: false)

        if StyleHelper.cardsStyleActive() == .normal && self.viewModel?.matchWidgetType == .normal {
            self.bottomMarginSpaceConstraint.constant = 12

            self.homeContentRedesignTopConstraint.constant = 25
            self.awayContentRedesignTopConstraint.constant = 45
        }
    }

    private func adjustMarketNameView(isShown: Bool) {
        if isShown {
            self.marketTopConstraint.constant = 8
            self.marketBottomConstraint.constant = -10
            self.marketHeightConstraint.constant = 15

            self.marketNamePillLabelView.isHidden = false
        }
        else {
            self.marketTopConstraint.constant = 0
            self.marketBottomConstraint.constant = 0
            self.marketHeightConstraint.constant = 0

            self.marketNameLabel.text = ""

            self.marketNamePillLabelView.title = ""
            self.marketNamePillLabelView.isHidden = true
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

                self.contentRedesignBaseView.isHidden = false
                self.horizontalMatchInfoBaseView.isHidden = true
                self.marketNameView.isHidden = true

                self.adjustDesignToNormalCardHeightStyle()

                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
            return
        }

        switch StyleHelper.cardsStyleActive() {
        case .small:
            self.contentRedesignBaseView.isHidden = true
            self.horizontalMatchInfoBaseView.isHidden = false
            self.marketNameView.isHidden = true
        case .normal:
            self.contentRedesignBaseView.isHidden = false
            self.horizontalMatchInfoBaseView.isHidden = true
            self.marketNameView.isHidden = true
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
        self.leadingMarginSpaceConstraint.constant = 8
        self.trailingMarginSpaceConstraint.constant = 8
        self.bottomMarginSpaceConstraint.constant = 8

        self.headerHeightConstraint.constant = 12
        self.teamsHeightConstraint.constant = 26
        self.buttonsHeightConstraint.constant = 27

        self.cashbackIconImageViewHeightConstraint.constant = 12

        self.eventNameLabel.font = AppFont.with(type: .semibold, size: 9)
        self.outrightNameLabel.font = AppFont.with(type: .bold, size: 13)
        self.outrightNameLabel.numberOfLines = 2

        self.homeOddValueLabel.font = AppFont.with(type: .bold, size: 12)
        self.drawOddValueLabel.font = AppFont.with(type: .bold, size: 12)
        self.awayOddValueLabel.font = AppFont.with(type: .bold, size: 12)
    }

    func adjustDesignToNormalCardHeightStyle() {
        self.topMarginSpaceConstraint.constant = 11
        self.bottomMarginSpaceConstraint.constant = 12
        self.leadingMarginSpaceConstraint.constant = 12
        self.trailingMarginSpaceConstraint.constant = 12

        self.headerHeightConstraint.constant = 17
        self.teamsHeightConstraint.constant = 67
        self.buttonsHeightConstraint.constant = 40

        self.cashbackIconImageViewHeightConstraint.constant = 18

        self.eventNameLabel.font = AppFont.with(type: .semibold, size: 11)

        self.outrightNameLabel.font = AppFont.with(type: .bold, size: 14)
        self.outrightNameLabel.numberOfLines = 3

        self.homeOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.drawOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.awayOddValueLabel.font = AppFont.with(type: .bold, size: 13)
    }

    // MARK: - Create Redesign Interface
    func createRedesignInterface() {
        self.contentRedesignBaseView.backgroundColor = UIColor.App.backgroundCards

        self.topSeparatorAlphaLineView.backgroundColor = UIColor.App.highlightPrimary

        self.mainContentBaseView.addSubview(self.contentRedesignBaseView)
        self.contentRedesignBaseView.addSubview(self.topSeparatorAlphaLineView)

        self.contentRedesignBaseView.addSubview(self.detailedScoreView)

        // Add home elements to stack view
        self.homeElementsStackView.addArrangedSubview(self.homeNameLabel)
        self.homeElementsStackView.addArrangedSubview(self.homeServingIndicatorView)
        self.contentRedesignBaseView.addSubview(self.homeElementsStackView)

        // Add away elements to stack view
        self.awayElementsStackView.addArrangedSubview(self.awayNameLabel)
        self.awayElementsStackView.addArrangedSubview(self.awayServingIndicatorView)
        self.contentRedesignBaseView.addSubview(self.awayElementsStackView)

        self.contentRedesignBaseView.addSubview(self.dateNewLabel)
        self.contentRedesignBaseView.addSubview(self.timeNewLabel)

        self.contentRedesignBaseView.addSubview(self.matchTimeStatusNewLabel)

        self.contentRedesignBaseView.addSubview(self.marketNamePillLabelView)

        self.homeContentRedesignTopConstraint = self.homeElementsStackView.topAnchor.constraint(equalTo: self.contentRedesignBaseView.topAnchor, constant: 13)
        self.awayContentRedesignTopConstraint = self.awayElementsStackView.topAnchor.constraint(equalTo: self.contentRedesignBaseView.topAnchor, constant: 33)

        self.homeToRightConstraint = self.dateNewLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.homeElementsStackView.trailingAnchor, constant: 5)
        self.awayToRightConstraint = self.timeNewLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.awayElementsStackView.trailingAnchor, constant: 5)

        NSLayoutConstraint.activate([
            self.contentRedesignBaseView.leadingAnchor.constraint(equalTo: self.mainContentBaseView.leadingAnchor, constant: 2),
            self.contentRedesignBaseView.trailingAnchor.constraint(equalTo: self.mainContentBaseView.trailingAnchor, constant: -2),
            self.contentRedesignBaseView.topAnchor.constraint(equalTo: self.headerLineStackView.bottomAnchor, constant: 3),
            self.contentRedesignBaseView.bottomAnchor.constraint(equalTo: self.oddsStackView.topAnchor, constant: 0),

            self.topSeparatorAlphaLineView.leadingAnchor.constraint(equalTo: self.contentRedesignBaseView.leadingAnchor),
            self.topSeparatorAlphaLineView.trailingAnchor.constraint(equalTo: self.contentRedesignBaseView.trailingAnchor),
            self.topSeparatorAlphaLineView.heightAnchor.constraint(equalToConstant: 1),
            self.topSeparatorAlphaLineView.topAnchor.constraint(equalTo: self.contentRedesignBaseView.topAnchor, constant: 4),

            self.detailedScoreView.trailingAnchor.constraint(equalTo: self.contentRedesignBaseView.trailingAnchor, constant: -12),
            self.detailedScoreView.topAnchor.constraint(equalTo: self.contentRedesignBaseView.topAnchor, constant: 13),

            self.detailedScoreView.leadingAnchor.constraint(greaterThanOrEqualTo: self.homeElementsStackView.trailingAnchor, constant: 5),
            self.homeContentRedesignTopConstraint,
            self.homeNameLabel.heightAnchor.constraint(equalTo: self.detailedScoreView.heightAnchor, multiplier: 0.5, constant: 1),

            self.detailedScoreView.leadingAnchor.constraint(greaterThanOrEqualTo: self.awayElementsStackView.trailingAnchor, constant: 5),
            self.awayContentRedesignTopConstraint,
            self.awayNameLabel.heightAnchor.constraint(equalTo: self.detailedScoreView.heightAnchor, multiplier: 0.5, constant: 1),

            self.homeElementsStackView.leadingAnchor.constraint(equalTo: self.contentRedesignBaseView.leadingAnchor, constant: 12),
            self.awayElementsStackView.leadingAnchor.constraint(equalTo: self.contentRedesignBaseView.leadingAnchor, constant: 12),

            self.homeServingIndicatorView.widthAnchor.constraint(equalTo: self.homeServingIndicatorView.heightAnchor),
            self.homeServingIndicatorView.widthAnchor.constraint(equalToConstant: 9),

            self.awayServingIndicatorView.widthAnchor.constraint(equalTo: self.awayServingIndicatorView.heightAnchor),
            self.awayServingIndicatorView.widthAnchor.constraint(equalToConstant: 9),

            self.dateNewLabel.trailingAnchor.constraint(equalTo: self.contentRedesignBaseView.trailingAnchor, constant: -12),
            self.dateNewLabel.topAnchor.constraint(equalTo: self.homeNameLabel.topAnchor),
            self.homeToRightConstraint,

            self.timeNewLabel.trailingAnchor.constraint(equalTo: self.contentRedesignBaseView.trailingAnchor, constant: -12),
            self.timeNewLabel.bottomAnchor.constraint(equalTo: self.awayNameLabel.bottomAnchor),
            self.awayToRightConstraint,

            self.matchTimeStatusNewLabel.trailingAnchor.constraint(equalTo: self.contentRedesignBaseView.trailingAnchor, constant: -12),
            self.matchTimeStatusNewLabel.bottomAnchor.constraint(equalTo: self.contentRedesignBaseView.bottomAnchor, constant: -6),

            self.marketNamePillLabelView.leadingAnchor.constraint(equalTo: self.contentRedesignBaseView.leadingAnchor, constant: 11),
            self.marketNamePillLabelView.bottomAnchor.constraint(equalTo: self.contentRedesignBaseView.bottomAnchor, constant: -4),

            self.matchTimeStatusNewLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.marketNamePillLabelView.trailingAnchor, constant: 5),
        ])

        self.marketNamePillLabelView.setContentCompressionResistancePriority(UILayoutPriority(990), for: .horizontal)
        self.matchTimeStatusNewLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        self.homeNameLabel.setContentHuggingPriority(UILayoutPriority(990), for: .horizontal)
        self.awayNameLabel.setContentHuggingPriority(UILayoutPriority(990), for: .horizontal)
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
