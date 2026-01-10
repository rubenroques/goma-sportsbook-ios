//
//  SharedGameCardView.swift
//  Sportsbook
//
//  Created by André Lascas on 28/02/2022.
//

import UIKit

class SharedGameCardView: UIView {

    // MARK: - Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var topView: UIView = Self.createTopView()
    private lazy var locationImageView: UIImageView = Self.createLocationImageView()
    private lazy var competitionLabel: UILabel = Self.createCompetitionLabel()

    private lazy var participantsStackView: UIStackView = Self.createPaticipantsStackView()
    private lazy var homeView: UIView = Self.createHomeView()
    private lazy var homeLabel: UILabel = Self.createHomeLabel()
    private lazy var awayView: UIView = Self.createAwayView()
    private lazy var awayLabel: UILabel = Self.createAwayLabel()

    private lazy var matchDetailView: UIView = Self.createMatchDetailView()
    private lazy var matchDetailStackView: UIStackView = Self.createMatchDetailStackView()
    private lazy var preLiveView: UIView = Self.createPreLiveView()
    private lazy var preLiveTopLabel: UILabel = Self.createPreLiveTopLabel()
    private lazy var preLiveBottomLabel: UILabel = Self.createPreLiveBottomLabel()
    private lazy var liveView: UIView = Self.createLiveView()
    private lazy var liveTopLabel: UILabel = Self.createLiveTopLabel()
    private lazy var liveBottomLabel: UILabel = Self.createLiveBottomLabel()

    private lazy var oddsStackView: UIStackView = Self.createOddsStackView()
    private lazy var leftOddView: UIView = Self.createLeftOddView()
    private lazy var middleOddView: UIView = Self.createMiddleOddView()
    private lazy var rightOddView: UIView = Self.createRightOddView()
    private lazy var leftOddTopLabel: UILabel = Self.createLeftOddTopLabel()
    private lazy var leftOddBottomLabel: UILabel = Self.createLeftOddBottomLabel()
    private lazy var middleOddTopLabel: UILabel = Self.createMiddleOddTopLabel()
    private lazy var middleOddBottomLabel: UILabel = Self.createMiddleOddBottomLabel()
    private lazy var rightOddTopLabel: UILabel = Self.createMiddleOddTopLabel()
    private lazy var rightOddBottomLabel: UILabel = Self.createMiddleOddBottomLabel()

    // MARK: Public Properties
    var isLiveCard: Bool = false {
        didSet {
            if isLiveCard {
                self.preLiveView.isHidden = true
                self.liveView.isHidden = false
            }
            else {
                self.preLiveView.isHidden = false
                self.liveView.isHidden = true
            }
        }
    }

    var isTwoMarket: Bool = false {
        didSet {
            if isTwoMarket {
                self.middleOddView.isHidden = true
            }
            else {
                self.middleOddView.isHidden = false
            }
        }
    }

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

        self.isLiveCard = false
        self.isTwoMarket = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.button

        self.locationImageView.layer.cornerRadius = self.locationImageView.frame.width/2

        self.leftOddView.layer.cornerRadius = CornerRadius.button
        self.middleOddView.layer.cornerRadius = CornerRadius.button
        self.rightOddView.layer.cornerRadius = CornerRadius.button

    }

    func setupWithTheme() {
        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = .clear

        self.locationImageView.backgroundColor = .clear

        self.competitionLabel.textColor = UIColor.App.textSecondary

        self.participantsStackView.backgroundColor = .clear

        self.homeView.backgroundColor = .clear
        self.awayView.backgroundColor = .clear
        self.matchDetailView.backgroundColor = .clear

        self.preLiveView.backgroundColor = .clear
        self.liveView.backgroundColor = .clear

        self.preLiveTopLabel.textColor = UIColor.App.textPrimary
        self.preLiveBottomLabel.textColor = UIColor.App.textPrimary

        self.oddsStackView.backgroundColor = .clear

        self.leftOddView.backgroundColor = UIColor.App.backgroundOdds
        self.middleOddView.backgroundColor = UIColor.App.backgroundOdds
        self.rightOddView.backgroundColor = UIColor.App.backgroundOdds

    }

    func setupSharedCardInfo(withMatch match: Match) {
        
        self.competitionLabel.text = match.competitionName
        if let venue = match.venue {
            if venue.isoCode != "" {
                self.locationImageView.image = UIImage(named: Assets.flagName(withCountryCode: venue.isoCode))
            }
            else {
                self.locationImageView.image = UIImage(named: Assets.flagName(withCountryCode: venue.id))
            }
        }
        
        self.homeLabel.text = match.homeParticipant.name
        self.awayLabel.text = match.awayParticipant.name
        
        self.isLiveCard = false
        self.setPreLiveCardDetails(match: match)
        
        self.setMainMarketOdds(withMatch: match)
        
    }

    func setPreLiveCardDetails(match: Match) {
        // Match Details
        var startDateString = ""
        var startTimeString = ""

        if let startDate = match.date {

            let relativeFormatter = MatchWidgetCellViewModel.relativeDateFormatter
            let relativeDateString = relativeFormatter.string(from: startDate)
            // "Jan 18, 2018"

            let nonRelativeFormatter = MatchWidgetCellViewModel.normalDateFormatter
            let normalDateString = nonRelativeFormatter.string(from: startDate)
            // "Jan 18, 2018"

            if relativeDateString == normalDateString {
                let customFormatter = Date.buildFormatter(locale: Env.locale, dateFormat: "dd MMM")
                startDateString = customFormatter.string(from: startDate)
            }
            else {
                startDateString = relativeDateString // Today, Yesterday
            }

            startTimeString = MatchWidgetCellViewModel.hourDateFormatter.string(from: startDate)

            self.preLiveTopLabel.text = startDateString
            self.preLiveBottomLabel.text = startTimeString
        }

    }

    func setLiveCardDetails(viewModel: MatchDetailsViewModel) {
        var homeGoals = ""
        var awayGoals = ""
        var minutes = ""
        var matchPart = ""

        if homeGoals.isNotEmpty && awayGoals.isNotEmpty {
            self.liveTopLabel.text = "\(homeGoals) - \(awayGoals)"
        }

        if minutes.isNotEmpty && matchPart.isNotEmpty {
            self.liveBottomLabel.text = "\(minutes)' - \(matchPart)"
        }
        else if minutes.isNotEmpty {
            self.liveBottomLabel.text = "\(minutes)'"
        }
        else if matchPart.isNotEmpty {
            self.liveBottomLabel.text = "\(matchPart)"
        }
    }

    func setMainMarketOdds(withMatch match: Match) {
        if let mainMarket = match.markets.first {

            if mainMarket.outcomes.count > 2 {
                if let leftOdd = mainMarket.outcomes[safe: 0] {
                    self.leftOddTopLabel.text = leftOdd.typeName
                    self.leftOddBottomLabel.text = OddFormatter.formatOdd(withValue: leftOdd.bettingOffer.decimalOdd)
                }
                if let middleOdd = mainMarket.outcomes[safe: 1] {
                    self.middleOddTopLabel.text = middleOdd.typeName
                    self.middleOddBottomLabel.text = OddFormatter.formatOdd(withValue: middleOdd.bettingOffer.decimalOdd)
                }
                if let rightOdd = mainMarket.outcomes[safe: 2] {
                    self.rightOddTopLabel.text = rightOdd.typeName
                    self.rightOddBottomLabel.text = OddFormatter.formatOdd(withValue: rightOdd.bettingOffer.decimalOdd)
                }

            }
            else {
                self.isTwoMarket = true
                if let leftOdd = mainMarket.outcomes[safe: 0] {
                    self.leftOddTopLabel.text = leftOdd.typeName
                    self.leftOddBottomLabel.text = OddFormatter.formatOdd(withValue: leftOdd.bettingOffer.decimalOdd)
                }
                if let rightOdd = mainMarket.outcomes[safe: 1] {
                    self.rightOddTopLabel.text = rightOdd.typeName
                    self.rightOddBottomLabel.text = OddFormatter.formatOdd(withValue: rightOdd.bettingOffer.decimalOdd)
                }
            }
        }
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension SharedGameCardView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLocationImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "country_flag_240")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }

    private static func createCompetitionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Competition"
        label.font = AppFont.with(type: .semibold, size: 11)
        return label
    }

    private static func createPaticipantsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }

    private static func createHomeView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createHomeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = localized("home")
        label.textAlignment = .right
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }

    private static func createAwayView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAwayLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = localized("away")
        label.textAlignment = .left
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }

    private static func createMatchDetailView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createMatchDetailStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }

    private static func createPreLiveView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createPreLiveTopLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "Day"
        label.textAlignment = .center
        label.font = AppFont.with(type: .semibold, size: 11)
        return label
    }

    private static func createPreLiveBottomLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "Hours"
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 16)
        return label
    }

    private static func createLiveView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLiveTopLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "0 - 0"
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 16)
        return label
    }

    private static func createLiveBottomLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "Game Start"
        label.textAlignment = .center
        label.font = AppFont.with(type: .semibold, size: 11)
        return label
    }

    private static func createOddsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }

    private static func createLeftOddView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createMiddleOddView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createRightOddView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLeftOddTopLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Left"
        label.textAlignment = .center
        label.font = AppFont.with(type: .medium, size: 10)
        return label
    }

    private static func createLeftOddBottomLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1,5"
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }

    private static func createMiddleOddTopLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Middle"
        label.textAlignment = .center
        label.font = AppFont.with(type: .medium, size: 10)
        return label
    }

    private static func createMiddleOddBottomLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1,5"
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }

    private static func createRightOddTopLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Right"
        label.textAlignment = .center
        label.font = AppFont.with(type: .medium, size: 10)
        return label
    }

    private static func createRightOddBottomLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1,5"
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }

    private func setupSubviews() {

        self.addSubview(self.containerView)

        self.containerView.addSubview(self.topView)
        self.topView.addSubview(self.locationImageView)
        self.topView.addSubview(self.competitionLabel)

        self.containerView.addSubview(self.participantsStackView)

        self.participantsStackView.addArrangedSubview(self.homeView)
        self.participantsStackView.addArrangedSubview(self.matchDetailView)
        self.participantsStackView.addArrangedSubview(self.awayView)

        self.homeView.addSubview(self.homeLabel)

        self.awayView.addSubview(self.awayLabel)

        self.matchDetailView.addSubview(self.matchDetailStackView)

        self.matchDetailStackView.addArrangedSubview(self.preLiveView)
        self.matchDetailStackView.addArrangedSubview(self.liveView)

        self.preLiveView.addSubview(self.preLiveTopLabel)
        self.preLiveView.addSubview(self.preLiveBottomLabel)

        self.liveView.addSubview(self.liveTopLabel)
        self.liveView.addSubview(self.liveBottomLabel)

        self.containerView.addSubview(self.oddsStackView)

        self.oddsStackView.addArrangedSubview(self.leftOddView)
        self.oddsStackView.addArrangedSubview(self.middleOddView)
        self.oddsStackView.addArrangedSubview(self.rightOddView)

        self.leftOddView.addSubview(self.leftOddTopLabel)
        self.leftOddView.addSubview(self.leftOddBottomLabel)

        self.middleOddView.addSubview(self.middleOddTopLabel)
        self.middleOddView.addSubview(self.middleOddBottomLabel)

        self.rightOddView.addSubview(self.rightOddTopLabel)
        self.rightOddView.addSubview(self.rightOddBottomLabel)

        self.initConstraints()

        self.locationImageView.layer.cornerRadius = self.locationImageView.frame.width/2
        self.locationImageView.layer.masksToBounds = true
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)

        ])

        // TopView
        NSLayoutConstraint.activate([
            self.topView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.topView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: 16),
            self.topView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 10),
            // self.topView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            self.topView.heightAnchor.constraint(equalToConstant: 30),

            self.locationImageView.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor),
            self.locationImageView.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.locationImageView.widthAnchor.constraint(equalToConstant: 20),
            self.locationImageView.heightAnchor.constraint(equalToConstant: 20),

            self.competitionLabel.leadingAnchor.constraint(equalTo: self.locationImageView.trailingAnchor, constant: 8),
            self.competitionLabel.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor),
            self.competitionLabel.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor)

        ])

        // Participants StackView
        NSLayoutConstraint.activate([
            self.participantsStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.participantsStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.participantsStackView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 8),
            self.participantsStackView.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Home View
        NSLayoutConstraint.activate([
            self.homeLabel.leadingAnchor.constraint(equalTo: self.homeView.leadingAnchor),
            self.homeLabel.trailingAnchor.constraint(equalTo: self.homeView.trailingAnchor),
            self.homeLabel.centerYAnchor.constraint(equalTo: self.homeView.centerYAnchor)

        ])

        // Away View
        NSLayoutConstraint.activate([
            self.awayLabel.leadingAnchor.constraint(equalTo: self.awayView.leadingAnchor),
            self.awayLabel.trailingAnchor.constraint(equalTo: self.awayView.trailingAnchor),
            self.awayLabel.centerYAnchor.constraint(equalTo: self.awayView.centerYAnchor)

        ])

        // Match Detail Views
        NSLayoutConstraint.activate([
            self.matchDetailStackView.leadingAnchor.constraint(equalTo: self.matchDetailView.leadingAnchor),
            self.matchDetailStackView.trailingAnchor.constraint(equalTo: self.matchDetailView.trailingAnchor),
            self.matchDetailStackView.centerYAnchor.constraint(equalTo: self.matchDetailView.centerYAnchor),

            self.preLiveTopLabel.leadingAnchor.constraint(equalTo: self.preLiveView.leadingAnchor, constant: 8),
            self.preLiveTopLabel.trailingAnchor.constraint(equalTo: self.preLiveView.trailingAnchor, constant: -8),
            self.preLiveTopLabel.centerYAnchor.constraint(equalTo: self.preLiveView.centerYAnchor, constant: -8),

            self.preLiveBottomLabel.leadingAnchor.constraint(equalTo: self.preLiveView.leadingAnchor, constant: 8),
            self.preLiveBottomLabel.trailingAnchor.constraint(equalTo: self.preLiveView.trailingAnchor, constant: -8),
            self.preLiveBottomLabel.topAnchor.constraint(equalTo: self.preLiveTopLabel.bottomAnchor, constant: 2),

            self.liveTopLabel.leadingAnchor.constraint(equalTo: self.liveView.leadingAnchor, constant: 8),
            self.liveTopLabel.trailingAnchor.constraint(equalTo: self.liveView.trailingAnchor, constant: -8),
            self.liveTopLabel.centerYAnchor.constraint(equalTo: self.liveView.centerYAnchor),

            self.liveBottomLabel.leadingAnchor.constraint(equalTo: self.liveView.leadingAnchor, constant: 8),
            self.liveBottomLabel.trailingAnchor.constraint(equalTo: self.liveView.trailingAnchor, constant: -8),
            self.liveBottomLabel.topAnchor.constraint(equalTo: self.liveView.bottomAnchor, constant: 8)

        ])

        // Odds StackView
        NSLayoutConstraint.activate([
            self.oddsStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.oddsStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.oddsStackView.topAnchor.constraint(equalTo: self.participantsStackView.bottomAnchor, constant: 8),
            self.oddsStackView.heightAnchor.constraint(equalToConstant: 40),
            self.oddsStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20),

            self.leftOddTopLabel.leadingAnchor.constraint(equalTo: self.leftOddView.leadingAnchor, constant: 8),
            self.leftOddTopLabel.trailingAnchor.constraint(equalTo: self.leftOddView.trailingAnchor, constant: -8),
            self.leftOddTopLabel.topAnchor.constraint(equalTo: self.leftOddView.topAnchor, constant: 6),

            self.leftOddBottomLabel.leadingAnchor.constraint(equalTo: self.leftOddView.leadingAnchor, constant: 8),
            self.leftOddBottomLabel.trailingAnchor.constraint(equalTo: self.leftOddView.trailingAnchor, constant: -8),
            self.leftOddBottomLabel.bottomAnchor.constraint(equalTo: self.leftOddView.bottomAnchor, constant: -6),

            self.middleOddTopLabel.leadingAnchor.constraint(equalTo: self.middleOddView.leadingAnchor, constant: 8),
            self.middleOddTopLabel.trailingAnchor.constraint(equalTo: self.middleOddView.trailingAnchor, constant: -8),
            self.middleOddTopLabel.topAnchor.constraint(equalTo: self.middleOddView.topAnchor, constant: 6),

            self.middleOddBottomLabel.leadingAnchor.constraint(equalTo: self.middleOddView.leadingAnchor, constant: 8),
            self.middleOddBottomLabel.trailingAnchor.constraint(equalTo: self.middleOddView.trailingAnchor, constant: -8),
            self.middleOddBottomLabel.bottomAnchor.constraint(equalTo: self.middleOddView.bottomAnchor, constant: -6),

            self.rightOddTopLabel.leadingAnchor.constraint(equalTo: self.rightOddView.leadingAnchor, constant: 8),
            self.rightOddTopLabel.trailingAnchor.constraint(equalTo: self.rightOddView.trailingAnchor, constant: -8),
            self.rightOddTopLabel.topAnchor.constraint(equalTo: self.rightOddView.topAnchor, constant: 6),

            self.rightOddBottomLabel.leadingAnchor.constraint(equalTo: self.rightOddView.leadingAnchor, constant: 8),
            self.rightOddBottomLabel.trailingAnchor.constraint(equalTo: self.rightOddView.trailingAnchor, constant: -8),
            self.rightOddBottomLabel.bottomAnchor.constraint(equalTo: self.rightOddView.bottomAnchor, constant: -6),
        ])
    }

}
