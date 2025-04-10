//
//  LiveMatchWidgetCollectionViewCell+Layout.swift
//  Sportsbook
//
//  Created by Refactoring on 2024.
//

import UIKit

// MARK: - Layout Methods
extension LiveMatchWidgetCollectionViewCell {

    // MARK: - Setup Main Layout
    func setupSubviews() {
        // Add base view to content view
        self.contentView.addSubview(self.baseView)

        // Add stack view to base view
        self.baseView.addSubview(self.baseStackView)

        // Add elements to stack view
        self.baseStackView.addArrangedSubview(self.mainContentBaseView)

        self.mainContentBaseView.addSubview(self.matchHeaderView)

        // Add odds stack view
        self.mainContentBaseView.addSubview(self.oddsStackView)

        // Add the matchInfoView to the mainContentBaseView
        self.mainContentBaseView.addSubview(self.matchInfoView)

        // Set up odds buttons
        self.oddsStackView.addArrangedSubview(self.homeBaseView)
        self.oddsStackView.addArrangedSubview(self.drawBaseView)
        self.oddsStackView.addArrangedSubview(self.awayBaseView)

        // Set up home odds
        self.homeBaseView.addSubview(self.homeOddTitleLabel)
        self.homeBaseView.addSubview(self.homeOddValueLabel)

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

        // Initialize the horizontalMatchInfoView
        // Set up border views
        self.baseView.addSubview(self.liveGradientBorderView)

        self.baseView.sendSubviewToBack(self.liveGradientBorderView)

        //
        // Top Right icons
        // Setup cashback icon
        self.baseView.addSubview(self.topRightInfoIconsStackView)

        // Live Tip
        self.liveTipView.addSubview(self.liveTipLabel)

        self.cashbackIconContainerView.addSubview(self.cashbackIconImageView)
        self.topRightInfoIconsStackView.addArrangedSubview(self.cashbackIconContainerView)
        self.topRightInfoIconsStackView.addArrangedSubview(self.liveTipView)
        //

        // Initialize constraints
        self.initConstraints()
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

        // Header line constraints - fixed values from normal style
        NSLayoutConstraint.activate([
            self.matchHeaderView.heightAnchor.constraint(equalToConstant: 17),
            self.matchHeaderView.topAnchor.constraint(equalTo: self.mainContentBaseView.topAnchor, constant: 12),
            self.matchHeaderView.leadingAnchor.constraint(equalTo: self.mainContentBaseView.leadingAnchor, constant: 12),
            self.matchHeaderView.trailingAnchor.constraint(equalTo: self.topRightInfoIconsStackView.leadingAnchor, constant: -4)
        ])

        // Odds stack view constraints - fixed values from normal style
        NSLayoutConstraint.activate([
            self.oddsStackView.heightAnchor.constraint(equalToConstant: 40),
            self.oddsStackView.leadingAnchor.constraint(equalTo: self.mainContentBaseView.leadingAnchor, constant: 12),
            self.oddsStackView.bottomAnchor.constraint(equalTo: self.mainContentBaseView.bottomAnchor, constant: -12),
            self.oddsStackView.trailingAnchor.constraint(equalTo: self.mainContentBaseView.trailingAnchor, constant: -12)
        ])

        // Set up constraints for the matchInfoView
        NSLayoutConstraint.activate([
            self.matchInfoView.leadingAnchor.constraint(equalTo: self.mainContentBaseView.leadingAnchor, constant: 2),
            self.matchInfoView.trailingAnchor.constraint(equalTo: self.mainContentBaseView.trailingAnchor, constant: -2),
            self.matchInfoView.topAnchor.constraint(equalTo: self.matchHeaderView.bottomAnchor, constant: 3),
            self.matchInfoView.bottomAnchor.constraint(equalTo: self.oddsStackView.topAnchor, constant: 0)
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

        // Border view constraints
        NSLayoutConstraint.activate([
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

}
