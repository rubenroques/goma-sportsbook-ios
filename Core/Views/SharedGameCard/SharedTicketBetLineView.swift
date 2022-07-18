//
//  SharedTicketBetLineView.swift
//  Sportsbook
//
//  Created by André Lascas on 14/07/2022.
//

import UIKit

class SharedTicketBetLineView: UIView {

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var sportTypeImageView: UIImageView = Self.createSportTypeImageView()
    private lazy var locationImageView: UIImageView = Self.createLocationImageView()
    private lazy var tournamentLabel: UILabel = Self.createTournamentLabel()
    private lazy var dateLabel: UILabel = Self.createDateLabel()
    private lazy var homeTeamLabel: UILabel = Self.createHomeTeamLabel()
    private lazy var awayTeamLabel: UILabel = Self.createAwayTeamLabel()
    private lazy var separatorView: UIView = Self.createSeparatorView()
    private lazy var marketTitleLabel: UILabel = Self.createMarketTitleLabel()
    private lazy var marketValueLabel: UILabel = Self.createMarketValueLabel()
    private lazy var oddsTitleLabel: UILabel = Self.createOddsTitleLabel()
    private lazy var oddsValueLabel: UILabel = Self.createOddsValueLabel()

    private var roundImageSize: CGFloat = 10
    var betHistoryEntrySelection: BetHistoryEntrySelection
    var countryCode: String = ""

    // MARK: - Lifetime and Cycle
    convenience init(betHistoryEntrySelection: BetHistoryEntrySelection, countryCode: String) {
        self.init(frame: .zero, betHistoryEntrySelection: betHistoryEntrySelection, countryCode: countryCode)
    }

    init(frame: CGRect, betHistoryEntrySelection: BetHistoryEntrySelection, countryCode: String) {
        self.betHistoryEntrySelection = betHistoryEntrySelection
        self.countryCode = countryCode

        super.init(frame: frame)

        self.commonInit()
        self.setupWithTheme()
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonInit() {

        self.setupSubviews()

        // Sport
        if let sportId = self.betHistoryEntrySelection.sportId {
            self.sportTypeImageView.image = UIImage(named: "sport_type_icon_\(sportId)")
        }

        // Location
        if let image = UIImage(named: Assets.flagName(withCountryCode: self.countryCode)) {
            self.locationImageView.image = image
        }
        else {
            self.locationImageView.isHidden = true
        }

        // Tournament
        if (self.betHistoryEntrySelection.tournamentName ?? "").isEmpty {
            self.tournamentLabel.text = self.betHistoryEntrySelection.eventName ?? ""
        }
        else {
            self.tournamentLabel.text = self.betHistoryEntrySelection.tournamentName ?? ""
        }

        // Date
        if let date = self.betHistoryEntrySelection.eventDate {
            self.dateLabel.text = MyTicketBetLineView.dateFormatter.string(from: date)
        }

        // Teams
        self.homeTeamLabel.text = self.betHistoryEntrySelection.homeParticipantName ?? ""
        self.awayTeamLabel.text = self.betHistoryEntrySelection.awayParticipantName ?? ""

        // Market
        let marketName = self.betHistoryEntrySelection.marketName ?? ""
        let outcomeName = self.betHistoryEntrySelection.betName ?? ""

        self.marketTitleLabel.text = marketName

        self.marketValueLabel.text = outcomeName

        // Odds
        self.oddsTitleLabel.text = localized("odd")

        if let oddValue = self.betHistoryEntrySelection.priceValue {
            let oddString = OddConverter.stringForValue(oddValue, format: UserDefaults.standard.userOddsFormat)

            self.oddsValueLabel.text = oddString
        }

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.baseView.layer.cornerRadius = CornerRadius.button
        self.baseView.clipsToBounds = true
        self.baseView.layer.masksToBounds = true

        self.sportTypeImageView.layer.cornerRadius = self.roundImageSize/2
        self.sportTypeImageView.clipsToBounds = true
        self.sportTypeImageView.layer.masksToBounds = true

        self.locationImageView.layer.cornerRadius = self.roundImageSize/2
        self.locationImageView.clipsToBounds = true
        self.locationImageView.layer.masksToBounds = true

        self.layoutIfNeeded()
    }

    func setupWithTheme() {

        self.backgroundColor = .clear

        self.baseView.backgroundColor = UIColor.App.backgroundTertiary

        self.tournamentLabel.textColor = UIColor.App.textSecondary

        self.dateLabel.textColor = UIColor.App.textPrimary

        self.homeTeamLabel.textColor = UIColor.App.textPrimary

        self.awayTeamLabel.textColor = UIColor.App.textPrimary

        self.separatorView.backgroundColor = UIColor.App.separatorLine

        self.marketTitleLabel.textColor = UIColor.App.textPrimary

        self.marketValueLabel.textColor = UIColor.App.textPrimary

        self.oddsTitleLabel.textColor = UIColor.App.textPrimary

        self.oddsValueLabel.textColor = UIColor.App.textPrimary

    }
}

extension SharedTicketBetLineView {
    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSportTypeImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }

    private static func createLocationImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }

    private static func createTournamentLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 9)
        label.text = "Tournament"
        return label
    }

    private static func createDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 9)
        label.text = "Date"
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }

    private static func createHomeTeamLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 11)
        label.text = "Home Team"
        return label
    }

    private static func createAwayTeamLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 11)
        label.text = "Away Team"
        return label
    }

    private static func createSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createMarketTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 10)
        label.text = "Market"
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createMarketValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 10)
        label.text = "Outcome"
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }

    private static func createOddsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 10)
        label.text = "Odds"
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createOddsValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 10)
        label.text = "-.--"
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }

    private func setupSubviews() {
        self.addSubview(self.baseView)

        self.baseView.addSubview(self.sportTypeImageView)
        self.baseView.addSubview(self.locationImageView)
        self.baseView.addSubview(self.tournamentLabel)
        self.baseView.addSubview(self.dateLabel)
        self.baseView.addSubview(self.homeTeamLabel)
        self.baseView.addSubview(self.awayTeamLabel)
        self.baseView.addSubview(self.separatorView)
        self.baseView.addSubview(self.marketTitleLabel)
        self.baseView.addSubview(self.marketValueLabel)
        self.baseView.addSubview(self.oddsTitleLabel)
        self.baseView.addSubview(self.oddsValueLabel)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

        ])

        // Top Info
        NSLayoutConstraint.activate([
            self.sportTypeImageView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 6),
            self.sportTypeImageView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 8),
            self.sportTypeImageView.widthAnchor.constraint(equalToConstant: self.roundImageSize),
            self.sportTypeImageView.heightAnchor.constraint(equalTo: self.sportTypeImageView.widthAnchor),

            self.locationImageView.leadingAnchor.constraint(equalTo: self.sportTypeImageView.trailingAnchor, constant: 4),
            self.locationImageView.topAnchor.constraint(equalTo: self.sportTypeImageView.topAnchor),
            self.locationImageView.widthAnchor.constraint(equalToConstant: self.roundImageSize),
            self.locationImageView.heightAnchor.constraint(equalTo: self.locationImageView.widthAnchor),

            self.tournamentLabel.leadingAnchor.constraint(equalTo: self.locationImageView.trailingAnchor, constant: 4),
            self.tournamentLabel.centerYAnchor.constraint(equalTo: self.locationImageView.centerYAnchor),
            self.tournamentLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -70),

            self.dateLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -6),
            self.dateLabel.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 8),
            self.dateLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 60)
        ])

        // Team Info
        NSLayoutConstraint.activate([
            self.homeTeamLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 8),
            self.homeTeamLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -30),
            self.homeTeamLabel.topAnchor.constraint(equalTo: self.sportTypeImageView.bottomAnchor, constant: 10),

            self.awayTeamLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 8),
            self.awayTeamLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -30),
            self.awayTeamLabel.topAnchor.constraint(equalTo: self.homeTeamLabel.bottomAnchor, constant: 7),

            self.separatorView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 8),
            self.separatorView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -8),
            self.separatorView.topAnchor.constraint(equalTo: self.awayTeamLabel.bottomAnchor, constant: 7),
            self.separatorView.heightAnchor.constraint(equalToConstant: 1)

        ])

        // Bottom info
        NSLayoutConstraint.activate([
            self.marketTitleLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 8),
            self.marketTitleLabel.trailingAnchor.constraint(equalTo: self.baseView.centerXAnchor, constant: -2),
            self.marketTitleLabel.topAnchor.constraint(equalTo: self.separatorView.bottomAnchor, constant: 8),


            self.marketValueLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -8),
            self.marketValueLabel.leadingAnchor.constraint(equalTo: self.baseView.centerXAnchor, constant: 2),
            self.marketValueLabel.topAnchor.constraint(equalTo: self.separatorView.bottomAnchor, constant: 8),

            self.oddsTitleLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 8),
            self.oddsTitleLabel.trailingAnchor.constraint(equalTo: self.baseView.centerXAnchor, constant: -2),
            self.oddsTitleLabel.topAnchor.constraint(equalTo: self.marketTitleLabel.bottomAnchor, constant: 7),
            self.oddsTitleLabel.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -8),

            self.oddsValueLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -8),
            self.oddsValueLabel.leadingAnchor.constraint(equalTo: self.baseView.centerXAnchor, constant: 2),
            self.oddsValueLabel.topAnchor.constraint(equalTo: self.marketValueLabel.bottomAnchor, constant: 7),
            self.oddsValueLabel.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -8)
        ])

    }
}
