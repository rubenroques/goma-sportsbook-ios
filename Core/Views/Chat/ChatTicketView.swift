//
//  ChatTicketView.swift
//  Sportsbook
//
//  Created by André Lascas on 23/05/2022.
//

import UIKit

class ChatTicketView: UIView {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var sportIconBaseView: UIView = Self.createSportIconBaseView()
    private lazy var sportIconImageView: UIImageView = Self.createSportIconImageView()
    private lazy var countryIconBaseView: UIView = Self.createCountryIconBaseView()
    private lazy var countryIconImageView: UIImageView = Self.createCountryIconImageView()
    private lazy var competitionLabel: UILabel = Self.createCompetitionLabel()
    private lazy var matchLabel: UILabel = Self.createMatchLabel()
    private lazy var marketLabel: UILabel = Self.createMarketLabel()

    private var betHistoryEntrySelection: BetHistoryEntrySelection

    // MARK: Lifetime and Cycle
    init(betHistoryEntrySelection: BetHistoryEntrySelection) {
        self.betHistoryEntrySelection = betHistoryEntrySelection

        super.init(frame: .zero)

        self.commonInit()
    }

    @available(iOS, unavailable)
    override init(frame: CGRect) {
        fatalError()
    }

    @available(iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setupSubviews()
        self.setupWithTheme()

        if (self.betHistoryEntrySelection.tournamentName ?? "").isEmpty {
            self.competitionLabel.text = self.betHistoryEntrySelection.eventName ?? ""
        }
        else {
            self.competitionLabel.text = self.betHistoryEntrySelection.tournamentName ?? ""
        }

        if let sportId = self.betHistoryEntrySelection.sportId {
            self.sportIconImageView.image = UIImage(named: "sport_type_icon_\(sportId)")
            self.sportIconImageView.setImageColor(color: UIColor.App.textPrimary)
        }

        if let venueId = self.betHistoryEntrySelection.venueId,
            let image = UIImage(named: Assets.flagName(withCountryCode: venueId)) {
            self.countryIconImageView.image = image
        }
        else {
            self.countryIconImageView.isHidden = true
        }

        let participants = [self.betHistoryEntrySelection.homeParticipantName,
                            self.betHistoryEntrySelection.awayParticipantName].compactMap({$0}).joined(separator: " - ")

        let marketText = [self.betHistoryEntrySelection.marketName,
                          self.betHistoryEntrySelection.betName].compactMap({$0}).joined(separator: " - ")

        self.marketLabel.text = marketText
        self.matchLabel.text = participants

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.countryIconImageView.layer.cornerRadius = self.countryIconImageView.frame.height / 2
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.sportIconImageView.backgroundColor = .clear
        self.countryIconImageView.backgroundColor = .clear

        self.sportIconImageView.setImageColor(color: UIColor.App.textPrimary)
        
        self.competitionLabel.textColor = UIColor.App.textSecondary

        self.matchLabel.textColor = UIColor.App.textPrimary

        self.marketLabel.textColor = UIColor.App.textSecondary
    }
}

//
// MARK: Subviews initialization and setup
//
extension ChatTicketView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        return view
    }

    private static func createSportIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSportIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "sport_type_icon_default")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createCountryIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCountryIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "country_flag_240")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }

    private static func createCompetitionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 9)
        label.text = "Competition"
        return label
    }

    private static func createMatchLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 11)
        label.text = "Team1 vs Team2"
        return label
    }

    private static func createMarketLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 11)
        label.text = "Market - Outcome"
        return label
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.sportIconBaseView)
        self.sportIconBaseView.addSubview(self.sportIconImageView)

        self.containerView.addSubview(self.countryIconBaseView)
        self.countryIconBaseView.addSubview(self.countryIconImageView)

        self.containerView.addSubview(self.competitionLabel)

        self.containerView.addSubview(self.matchLabel)

        self.containerView.addSubview(self.marketLabel)

        self.initConstraints()

    }

    private func initConstraints() {

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.sportIconBaseView.widthAnchor.constraint(equalToConstant: 14),
            self.sportIconBaseView.heightAnchor.constraint(equalTo: self.sportIconBaseView.widthAnchor),
            self.sportIconBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.sportIconBaseView.topAnchor.constraint(equalTo: self.containerView.topAnchor),

            self.sportIconImageView.leadingAnchor.constraint(equalTo: self.sportIconBaseView.leadingAnchor),
            self.sportIconImageView.trailingAnchor.constraint(equalTo: self.sportIconBaseView.trailingAnchor),
            self.sportIconImageView.topAnchor.constraint(equalTo: self.sportIconBaseView.topAnchor),
            self.sportIconImageView.bottomAnchor.constraint(equalTo: self.sportIconBaseView.bottomAnchor),

            self.countryIconBaseView.widthAnchor.constraint(equalToConstant: 14),
            self.countryIconBaseView.heightAnchor.constraint(equalTo: self.countryIconBaseView.widthAnchor),
            self.countryIconBaseView.leadingAnchor.constraint(equalTo: self.sportIconBaseView.trailingAnchor, constant: 3),
            self.countryIconBaseView.centerYAnchor.constraint(equalTo: self.sportIconBaseView.centerYAnchor),

            self.countryIconImageView.leadingAnchor.constraint(equalTo: self.countryIconBaseView.leadingAnchor),
            self.countryIconImageView.trailingAnchor.constraint(equalTo: self.countryIconBaseView.trailingAnchor),
            self.countryIconImageView.topAnchor.constraint(equalTo: self.countryIconBaseView.topAnchor),
            self.countryIconImageView.bottomAnchor.constraint(equalTo: self.countryIconBaseView.bottomAnchor),

            self.competitionLabel.heightAnchor.constraint(equalToConstant: 14),
            self.competitionLabel.leadingAnchor.constraint(equalTo: self.countryIconImageView.trailingAnchor, constant: 6),
            self.competitionLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -5),
            self.competitionLabel.centerYAnchor.constraint(equalTo: self.countryIconImageView.centerYAnchor),

            self.matchLabel.heightAnchor.constraint(equalToConstant: 20),
            self.matchLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.matchLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -5),
            self.matchLabel.topAnchor.constraint(equalTo: self.sportIconImageView.bottomAnchor, constant: 8),

            self.marketLabel.heightAnchor.constraint(equalToConstant: 20),
            self.marketLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.marketLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -5),
            self.marketLabel.topAnchor.constraint(equalTo: self.matchLabel.bottomAnchor),
            self.marketLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -2),
        ])

    }

}
