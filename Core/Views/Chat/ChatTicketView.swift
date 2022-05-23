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

    // MARK: Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    func commonInit() {
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.sportIconBaseView.layer.cornerRadius = self.sportIconBaseView.frame.height / 2

        self.sportIconImageView.layer.cornerRadius = self.sportIconImageView.frame.height / 2

        self.countryIconBaseView.layer.cornerRadius = self.countryIconBaseView.frame.height / 2

        self.countryIconImageView.layer.cornerRadius = self.countryIconImageView.frame.height / 2
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.sportIconImageView.backgroundColor = .clear

        self.countryIconImageView.backgroundColor = .clear

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
        return imageView
    }

    private static func createCompetitionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 8)
        label.text = "Competition"
        return label
    }

    private static func createMatchLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 10)
        label.text = "Team1 vs Team2"
        return label
    }

    private static func createMarketLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 10)
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
            self.containerView.heightAnchor.constraint(equalToConstant: 50),

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

            self.competitionLabel.leadingAnchor.constraint(equalTo: self.countryIconImageView.trailingAnchor, constant: 6),
            self.competitionLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -5),
            self.competitionLabel.centerYAnchor.constraint(equalTo: self.countryIconImageView.centerYAnchor),

            self.matchLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.matchLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -5),
            self.matchLabel.topAnchor.constraint(equalTo: self.sportIconImageView.bottomAnchor, constant: 8),

            self.marketLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.marketLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -5),
            self.marketLabel.topAnchor.constraint(equalTo: self.matchLabel.bottomAnchor, constant: 8),
            self.marketLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
        ])

    }

}
