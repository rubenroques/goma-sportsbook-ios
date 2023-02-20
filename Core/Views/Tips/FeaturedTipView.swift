//
//  FeaturedTipView.swift
//  Sportsbook
//
//  Created by André Lascas on 31/08/2022.
//

import Foundation
import UIKit
import Combine

class FeaturedTipView: UIView {
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var sportIconImageView: UIImageView = Self.createSportIconImageView()
    private lazy var countryIconImageView: UIImageView = Self.createCountryIconImageView()
    private lazy var tournamentLabel: UILabel = Self.createTournamentLabel()
    private lazy var outcomeLabel: UILabel = Self.createOutcomeLabel()
    private lazy var matchLabel: UILabel = Self.createMatchLabel()

    // MARK: - Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
        self.setupWithTheme()
    }

    func commonInit() {

        self.setupSubviews()

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.button

        self.sportIconImageView.layer.cornerRadius = self.sportIconImageView.frame.height / 2
        self.countryIconImageView.layer.cornerRadius = self.countryIconImageView.frame.height / 2
    }

    func setupWithTheme() {
        self.containerView.backgroundColor = UIColor.App.backgroundTertiary

        self.sportIconImageView.backgroundColor = .clear

        self.countryIconImageView.backgroundColor = .clear

        self.tournamentLabel.textColor = UIColor.App.textSecondary

        self.outcomeLabel.textColor = UIColor.App.textPrimary

        self.matchLabel.textColor = UIColor.App.textSecondary
    }

    // MARK: Functions
    func configure(featuredTipSelection: FeaturedTipSelection) {

        self.outcomeLabel.text = "\(featuredTipSelection.betName) (\(featuredTipSelection.bettingTypeName))"

        self.matchLabel.text = featuredTipSelection.eventName

        let matchSportId = featuredTipSelection.sportId
        self.sportIconImageView.image = UIImage(named: "sport_type_icon_\(matchSportId)")

        if let matchLocation = Env.everyMatrixStorage.location(forId: featuredTipSelection.venueId),
           let countryIsoCode = matchLocation.code {
            self.setCountryFlag(isoCode: countryIsoCode, countryId: matchLocation.id)

        }

        self.tournamentLabel.text = featuredTipSelection.sportParentName

    }

    func setCountryFlag(isoCode: String, countryId: String) {

        if isoCode != "" {
            let gameFlag = Assets.flagName(withCountryCode: isoCode)

            if gameFlag != "country_flag_" {
                self.countryIconImageView.image = UIImage(named: gameFlag)
            }
            else {
                self.countryIconImageView.image = UIImage(named: "country_flag_240")
            }
        }
        else {
            let gameFlag = Assets.flagName(withCountryCode: countryId)
            self.countryIconImageView.image = UIImage(named: gameFlag)

        }
    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension FeaturedTipView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSportIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "sport_type_mono_icon_default")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }

    private static func createCountryIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "country_flag_240")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }

    private static func createTournamentLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("tournament")
        label.font = AppFont.with(type: .semibold, size: 11)
        return label
    }

    private static func createOutcomeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("outcome")
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }

    private static func createMatchLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Match Home x Match Away"
        label.font = AppFont.with(type: .semibold, size: 12)
        return label
    }

    private func setupSubviews() {

        self.addSubview(self.containerView)

        self.containerView.addSubview(self.sportIconImageView)
        self.containerView.addSubview(self.countryIconImageView)
        self.containerView.addSubview(self.tournamentLabel)
        self.containerView.addSubview(self.outcomeLabel)
        self.containerView.addSubview(self.matchLabel)

        self.initConstraints()


    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.sportIconImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 8),
            self.sportIconImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 8),
            self.sportIconImageView.widthAnchor.constraint(equalToConstant: 16),
            self.sportIconImageView.heightAnchor.constraint(equalTo: self.sportIconImageView.widthAnchor),

            self.countryIconImageView.leadingAnchor.constraint(equalTo: self.sportIconImageView.trailingAnchor, constant: 6),
            self.countryIconImageView.centerYAnchor.constraint(equalTo: self.sportIconImageView.centerYAnchor),
            self.countryIconImageView.widthAnchor.constraint(equalToConstant: 16),
            self.countryIconImageView.heightAnchor.constraint(equalTo: self.countryIconImageView.widthAnchor),

            self.tournamentLabel.leadingAnchor.constraint(equalTo: self.countryIconImageView.trailingAnchor, constant: 6),
            self.tournamentLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            self.tournamentLabel.centerYAnchor.constraint(equalTo: self.countryIconImageView.centerYAnchor),

            self.outcomeLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 8),
            self.outcomeLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            self.outcomeLabel.topAnchor.constraint(equalTo: self.sportIconImageView.bottomAnchor, constant: 9),

            self.matchLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 8),
            self.matchLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            self.matchLabel.topAnchor.constraint(equalTo: self.outcomeLabel.bottomAnchor, constant: 9),
            self.matchLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -8)

        ])
    }
}
