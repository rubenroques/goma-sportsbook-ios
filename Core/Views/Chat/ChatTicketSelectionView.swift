//
//  ChatTicketSelectionView.swift
//  Sportsbook
//
//  Created by André Lascas on 23/05/2022.
//

import UIKit

class ChatTicketSelectionView: UIView {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    
    private lazy var sportIconBaseView: UIView = Self.createSportIconBaseView()
    private lazy var sportIconImageView: UIImageView = Self.createSportIconImageView()
    private lazy var countryIconBaseView: UIView = Self.createCountryIconBaseView()
    private lazy var countryIconImageView: UIImageView = Self.createCountryIconImageView()
    private lazy var competitionLabel: UILabel = Self.createCompetitionLabel()
    
    private lazy var homeTeamLogoImageView: UIImageView = Self.createHomeTeamLogoImageView()
    private lazy var homeTeamNameLabel: UILabel = Self.createHomeTeamNameLabel()
    private lazy var homeTeamScoreLabel: UILabel = Self.createHomeTeamScoreLabel()
    
    private lazy var awayTeamLogoImageView: UIImageView = Self.createAwayTeamLogoImageView()
    private lazy var awayTeamNameLabel: UILabel = Self.createAwayTeamNameLabel()
    private lazy var awayTeamScoreLabel: UILabel = Self.createAwayTeamScoreLabel()
    
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()
    
    private lazy var marketLabel: UILabel = Self.createMarketLabel()
    private lazy var outcomeLabel: UILabel = Self.createOutcomeLabel()

    private lazy var oddTitleLabel: UILabel = Self.createOddTitleLabel()
    private lazy var oddValueLabel: UILabel = Self.createOddValueLabel()
    
    private lazy var betStatusView: UIView = Self.createBetStatusView()
    private lazy var betStatusLabel: UILabel = Self.createBetStatusLabel()
    private lazy var dateLabel: UILabel = Self.createDateLabel()

    private var betHistoryEntrySelection: BetHistoryEntrySelection

    var hasBetStatus: Bool = false {
        didSet {
            self.betStatusView.isHidden = !hasBetStatus
            self.betStatusLabel.isHidden = !hasBetStatus
            self.dateLabel.isHidden = hasBetStatus
        }
    }
    
    // Logos
    var homeTeamUrl: URL? {
//        if let logoURL = self.betHistoryEntrySelection.homeLogoUrl {
//            let completeUrl = TargetVariables.staticImagesURL + logoURL + ".png"
//            return URL(string: completeUrl)
//        }
        return nil
    }

    var awayTeamUrl: URL? {
//        if let logoURL = self.betHistoryEntrySelection.awayLogoUrl {
//            let completeUrl = TargetVariables.staticImagesURL + logoURL + ".png"
//            return URL(string: completeUrl)
//        }
        return nil
    }

    // MARK: Lifetime and Cycle
    init(betHistoryEntrySelection: BetHistoryEntrySelection, hasBetStatus: Bool = false) {
        self.betHistoryEntrySelection = betHistoryEntrySelection

        self.hasBetStatus = hasBetStatus

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
        
        //
        //
        if let sportId = self.betHistoryEntrySelection.sportId,
           let image = UIImage(named: "sport_type_icon_\(sportId)") {
                self.sportIconImageView.image = image
        }
        else {
            self.sportIconImageView.image = UIImage(named: "sport_type_icon_default")
        }
        self.sportIconImageView.setImageColor(color: UIColor.App.textPrimary)
        
        //
        if let image = UIImage(named: Assets.flagName(withCountryCode: self.betHistoryEntrySelection.venueId ?? "")) {
            self.countryIconImageView.image = image
        }
        else {
            self.countryIconImageView.image = UIImage(named: Assets.flagName(withCountryCode: "international"))
        }
        if let venueId = self.betHistoryEntrySelection.venueId {

            if let venue = Env.gomaSocialClient.location(forId: venueId),
               let venueCode = venue.code {
                let image = UIImage(named: Assets.flagName(withCountryCode: venueCode))
                self.countryIconImageView.image = image
            }
            else {
                let image = UIImage(named: Assets.flagName(withCountryCode: venueId))
                self.countryIconImageView.image = image
            }

        }
        else {
            self.countryIconImageView.isHidden = true
        }
        
        if let homeTeamUrl = self.homeTeamUrl {
            self.homeTeamLogoImageView.kf.setImage(with: homeTeamUrl, placeholder: UIImage(named: "no_emblem_icon"))
        }
        
        if let awayTeamUrl = self.awayTeamUrl {
            self.awayTeamLogoImageView.kf.setImage(with: awayTeamUrl, placeholder: UIImage(named: "no_emblem_icon"))
        }

        self.homeTeamNameLabel.text = self.betHistoryEntrySelection.homeParticipantName ?? ""
        self.awayTeamNameLabel.text = self.betHistoryEntrySelection.awayParticipantName ?? ""
        
        self.homeTeamScoreLabel.text = self.betHistoryEntrySelection.homeParticipantScore ?? "-"
        self.awayTeamScoreLabel.text = self.betHistoryEntrySelection.awayParticipantScore ?? "-"
        
        if let marketName = self.betHistoryEntrySelection.marketName, let partName = self.betHistoryEntrySelection.bettingTypeEventPartName {
            self.marketLabel.text = "\(marketName) (\(partName))"
        }
        else if let marketName = self.betHistoryEntrySelection.marketName {
            self.marketLabel.text = "\(marketName)"
        }
        self.outcomeLabel.text = self.betHistoryEntrySelection.betName ?? ""
        self.oddTitleLabel.text = localized("odd")

        if let oddValue = self.betHistoryEntrySelection.priceValue {
            self.oddValueLabel.text = OddFormatter.formatOdd(withValue: oddValue)
        }

        if hasBetStatus {
            switch self.betHistoryEntrySelection.result {
            case .won, .halfWon:
                self.betStatusView.backgroundColor = UIColor.App.myTicketsWon
                self.betStatusLabel.text = localized("won")
            case .lost, .halfLost:
                self.betStatusView.backgroundColor = UIColor.App.myTicketsLost
                self.betStatusLabel.text = localized("lost")
            case .drawn:
                self.betStatusView.backgroundColor = UIColor.App.myTicketsOther
                self.betStatusLabel.text = localized("draw")
            case .void:
                self.betStatusView.backgroundColor = UIColor.App.myTicketsOther
                self.betStatusLabel.text = localized("void")
            case .undefined, .open:
                self.hasBetStatus = false
            }
        }
        else {
            self.hasBetStatus = false
        }

        self.dateLabel.text = ""
        if let date = self.betHistoryEntrySelection.eventDate {
            self.dateLabel.text = MyTicketBetLineView.dateFormatter.string(from: date)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.containerView.layer.cornerRadius = CornerRadius.button
        self.containerView.layer.borderWidth = 1

        self.countryIconImageView.layer.cornerRadius = self.countryIconImageView.frame.height / 2

        self.betStatusView.layer.cornerRadius = self.betStatusView.frame.height / 2
        self.betStatusView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary
        self.containerView.layer.borderColor = UIColor.App.separatorLine.cgColor
        
        self.sportIconImageView.backgroundColor = .clear
        self.countryIconImageView.backgroundColor = .clear

        self.sportIconImageView.setImageColor(color: UIColor.App.textPrimary)
        
        self.competitionLabel.textColor = UIColor.App.textSecondary

        self.homeTeamLogoImageView.backgroundColor = .clear
        
        self.homeTeamNameLabel.textColor = UIColor.App.textPrimary
        
        self.homeTeamScoreLabel.textColor = UIColor.App.textPrimary
        
        self.awayTeamLogoImageView.backgroundColor = .clear
        
        self.awayTeamNameLabel.textColor = UIColor.App.textPrimary
        
        self.awayTeamScoreLabel.textColor = UIColor.App.textPrimary
        
        self.separatorLineView.backgroundColor = UIColor.App.separatorLine
        
        self.marketLabel.textColor = UIColor.App.textSecondary
        
        self.outcomeLabel.textColor = UIColor.App.textPrimary
        
        self.oddTitleLabel.textColor = UIColor.App.textSecondary
        
        self.oddValueLabel.textColor = UIColor.App.textPrimary

        self.betStatusLabel.textColor = UIColor.App.buttonTextSecondary
        
        self.dateLabel.textColor = UIColor.App.textPrimary
    }
}

//
// MARK: Subviews initialization and setup
//
extension ChatTicketSelectionView {

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
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }

    private static func createCompetitionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .medium, size: 12)
        label.text = "Competition"
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }
    
    private static func createHomeTeamLogoImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "no_emblem_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createHomeTeamNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.text = "Home Team"
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }
    
    private static func createHomeTeamScoreLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.text = "-"
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }
    
    private static func createAwayTeamLogoImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "no_emblem_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createAwayTeamNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.text = "Away Team"
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }
    
    private static func createAwayTeamScoreLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.text = "-"
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }
    
    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createMarketLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 11)
        label.text = "Market"
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }
    
    private static func createOutcomeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 11)
        label.text = "Outcome"
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }
    
    private static func createOddTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 11)
        label.text = localized("odd")
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }
    
    private static func createOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 11)
        label.text = "-"
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }

    private static func createBetStatusView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBetStatusLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "Status"
        label.font = AppFont.with(type: .semibold, size: 10)
        return label
    }
    
    private static func createDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.text = "Date"
        label.font = AppFont.with(type: .semibold, size: 10)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.sportIconBaseView)
        self.sportIconBaseView.addSubview(self.sportIconImageView)

        self.containerView.addSubview(self.countryIconBaseView)
        self.countryIconBaseView.addSubview(self.countryIconImageView)

        self.containerView.addSubview(self.competitionLabel)

        self.containerView.addSubview(self.homeTeamLogoImageView)
        self.containerView.addSubview(self.homeTeamNameLabel)
        self.containerView.addSubview(self.homeTeamScoreLabel)
        
        self.containerView.addSubview(self.awayTeamLogoImageView)
        self.containerView.addSubview(self.awayTeamNameLabel)
        self.containerView.addSubview(self.awayTeamScoreLabel)
        
        self.containerView.addSubview(self.separatorLineView)
        
        self.containerView.addSubview(self.marketLabel)
        self.containerView.addSubview(self.outcomeLabel)
        
        self.containerView.addSubview(self.oddTitleLabel)
        self.containerView.addSubview(self.oddValueLabel)

        self.containerView.addSubview(self.betStatusView)

        self.betStatusView.addSubview(self.betStatusLabel)
        
        self.containerView.bringSubviewToFront(self.betStatusView)
        
        self.containerView.addSubview(self.dateLabel)

        self.initConstraints()

    }

    private func initConstraints() {

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.sportIconBaseView.widthAnchor.constraint(equalToConstant: 12),
            self.sportIconBaseView.heightAnchor.constraint(equalTo: self.sportIconBaseView.widthAnchor),
            self.sportIconBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.sportIconBaseView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 12),

            self.sportIconImageView.leadingAnchor.constraint(equalTo: self.sportIconBaseView.leadingAnchor),
            self.sportIconImageView.trailingAnchor.constraint(equalTo: self.sportIconBaseView.trailingAnchor),
            self.sportIconImageView.topAnchor.constraint(equalTo: self.sportIconBaseView.topAnchor),
            self.sportIconImageView.bottomAnchor.constraint(equalTo: self.sportIconBaseView.bottomAnchor),

            self.countryIconBaseView.widthAnchor.constraint(equalToConstant: 12),
            self.countryIconBaseView.heightAnchor.constraint(equalTo: self.countryIconBaseView.widthAnchor),
            self.countryIconBaseView.leadingAnchor.constraint(equalTo: self.sportIconBaseView.trailingAnchor, constant: 6),
            self.countryIconBaseView.centerYAnchor.constraint(equalTo: self.sportIconBaseView.centerYAnchor),

            self.countryIconImageView.leadingAnchor.constraint(equalTo: self.countryIconBaseView.leadingAnchor),
            self.countryIconImageView.trailingAnchor.constraint(equalTo: self.countryIconBaseView.trailingAnchor),
            self.countryIconImageView.topAnchor.constraint(equalTo: self.countryIconBaseView.topAnchor),
            self.countryIconImageView.bottomAnchor.constraint(equalTo: self.countryIconBaseView.bottomAnchor),

            self.competitionLabel.leadingAnchor.constraint(equalTo: self.countryIconBaseView.trailingAnchor, constant: 6),
            self.competitionLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -12),
            self.competitionLabel.centerYAnchor.constraint(equalTo: self.countryIconBaseView.centerYAnchor),

            self.homeTeamLogoImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.homeTeamLogoImageView.widthAnchor.constraint(equalToConstant: 16),
            self.homeTeamLogoImageView.heightAnchor.constraint(equalTo: self.homeTeamLogoImageView.widthAnchor),
            self.homeTeamLogoImageView.topAnchor.constraint(equalTo: self.sportIconBaseView.bottomAnchor, constant: 18),
            
            self.homeTeamNameLabel.leadingAnchor.constraint(equalTo: self.homeTeamLogoImageView.trailingAnchor, constant: 6),
            self.homeTeamNameLabel.centerYAnchor.constraint(equalTo: self.homeTeamLogoImageView.centerYAnchor),
            
            self.homeTeamScoreLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.homeTeamScoreLabel.centerYAnchor.constraint(equalTo: self.homeTeamLogoImageView.centerYAnchor),
            self.homeTeamScoreLabel.leadingAnchor.constraint(equalTo: self.homeTeamNameLabel.trailingAnchor, constant: 5),
            
            self.awayTeamLogoImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.awayTeamLogoImageView.widthAnchor.constraint(equalToConstant: 16),
            self.awayTeamLogoImageView.heightAnchor.constraint(equalTo: self.awayTeamLogoImageView.widthAnchor),
            self.awayTeamLogoImageView.topAnchor.constraint(equalTo: self.homeTeamLogoImageView.bottomAnchor, constant: 15),
            
            self.awayTeamNameLabel.leadingAnchor.constraint(equalTo: self.awayTeamLogoImageView.trailingAnchor, constant: 6),
            self.awayTeamNameLabel.centerYAnchor.constraint(equalTo: self.awayTeamLogoImageView.centerYAnchor),
            
            self.awayTeamScoreLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.awayTeamScoreLabel.centerYAnchor.constraint(equalTo: self.awayTeamLogoImageView.centerYAnchor),
            self.awayTeamScoreLabel.leadingAnchor.constraint(equalTo: self.awayTeamNameLabel.trailingAnchor, constant: 5),
            
            self.separatorLineView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -12),
            self.separatorLineView.topAnchor.constraint(equalTo: self.awayTeamLogoImageView.bottomAnchor, constant: 18),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),
            
            self.marketLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.marketLabel.topAnchor.constraint(equalTo: self.separatorLineView.bottomAnchor, constant: 9),
            
            self.outcomeLabel.leadingAnchor.constraint(equalTo: self.marketLabel.trailingAnchor, constant: 5),
            self.outcomeLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -12),
            self.outcomeLabel.centerYAnchor.constraint(equalTo: self.marketLabel.centerYAnchor),
            
            self.oddTitleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.oddTitleLabel.topAnchor.constraint(equalTo: self.marketLabel.bottomAnchor, constant: 12),
            
            self.oddValueLabel.leadingAnchor.constraint(equalTo: self.oddTitleLabel.trailingAnchor, constant: 5),
            self.oddValueLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -12),
            self.oddValueLabel.centerYAnchor.constraint(equalTo: self.oddTitleLabel.centerYAnchor),
            self.oddValueLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -12),

            self.betStatusView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.betStatusView.centerYAnchor.constraint(equalTo: self.sportIconBaseView.centerYAnchor),

            self.betStatusLabel.leadingAnchor.constraint(equalTo: self.betStatusView.leadingAnchor, constant: 7),
            self.betStatusLabel.trailingAnchor.constraint(equalTo: self.betStatusView.trailingAnchor, constant: -8),
            self.betStatusLabel.topAnchor.constraint(equalTo: self.betStatusView.topAnchor, constant: 5),
            self.betStatusLabel.bottomAnchor.constraint(equalTo: self.betStatusView.bottomAnchor, constant: -5),
            
            self.dateLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.dateLabel.centerYAnchor.constraint(equalTo: self.sportIconBaseView.centerYAnchor),
            self.dateLabel.widthAnchor.constraint(equalToConstant: 62)
        ])

    }

}
//class ChatTicketSelectionView: UIView {
//
//    // MARK: Private Properties
//    private lazy var containerView: UIView = Self.createContainerView()
//    private lazy var sportIconBaseView: UIView = Self.createSportIconBaseView()
//    private lazy var sportIconImageView: UIImageView = Self.createSportIconImageView()
//    private lazy var countryIconBaseView: UIView = Self.createCountryIconBaseView()
//    private lazy var countryIconImageView: UIImageView = Self.createCountryIconImageView()
//    private lazy var competitionLabel: UILabel = Self.createCompetitionLabel()
//    private lazy var labelsStackView: UIStackView = Self.createLabelsStackView()
//    
//    private lazy var matchLabel: UILabel = Self.createMatchLabel()
//    private lazy var marketLabel: UILabel = Self.createMarketLabel()
//    private lazy var betStatusView: UIView = Self.createBetStatusView()
//    private lazy var betStatusLabel: UILabel = Self.createBetStatusLabel()
//
//    private var betHistoryEntrySelection: BetHistoryEntrySelection
//
//    var hasBetStatus: Bool = false {
//        didSet {
//            self.betStatusView.isHidden = !hasBetStatus
//            self.betStatusLabel.isHidden = !hasBetStatus
//        }
//    }
//
//    // MARK: Lifetime and Cycle
//    init(betHistoryEntrySelection: BetHistoryEntrySelection, hasBetStatus: Bool = false) {
//        self.betHistoryEntrySelection = betHistoryEntrySelection
//
//        self.hasBetStatus = hasBetStatus
//
//        super.init(frame: .zero)
//
//        self.commonInit()
//    }
//
//    @available(iOS, unavailable)
//    override init(frame: CGRect) {
//        fatalError()
//    }
//
//    @available(iOS, unavailable)
//    required init?(coder aDecoder: NSCoder) {
//        fatalError()
//    }
//
//    func commonInit() {
//        self.translatesAutoresizingMaskIntoConstraints = false
//        self.setupSubviews()
//        self.setupWithTheme()
//
//        if (self.betHistoryEntrySelection.tournamentName ?? "").isEmpty {
//            self.competitionLabel.text = self.betHistoryEntrySelection.eventName ?? ""
//        }
//        else {
//            self.competitionLabel.text = self.betHistoryEntrySelection.tournamentName ?? ""
//        }
//
//        if let sportId = self.betHistoryEntrySelection.sportId {
//            self.sportIconImageView.image = UIImage(named: "sport_type_icon_\(sportId)")
//            self.sportIconImageView.setImageColor(color: UIColor.App.textPrimary)
//        }
//
//        if let venueId = self.betHistoryEntrySelection.venueId {
//
//            if let venue = Env.gomaSocialClient.location(forId: venueId),
//               let venueCode = venue.code {
//                let image = UIImage(named: Assets.flagName(withCountryCode: venueCode))
//                self.countryIconImageView.image = image
//            }
//            else {
//                let image = UIImage(named: Assets.flagName(withCountryCode: venueId))
//                self.countryIconImageView.image = image
//            }
//
//        }
//        else {
//            self.countryIconImageView.isHidden = true
//        }
//
//        let participants = [self.betHistoryEntrySelection.homeParticipantName,
//                            self.betHistoryEntrySelection.awayParticipantName].compactMap({$0}).joined(separator: " - ")
//
//        let marketText = [self.betHistoryEntrySelection.marketName,
//                          self.betHistoryEntrySelection.betName].compactMap({$0}).joined(separator: " - ")
//
//        self.marketLabel.text = marketText
//        self.matchLabel.text = participants
//        
//        if participants.isEmpty {
//            self.marketLabel.text = ""
//            self.matchLabel.text = marketText
//            self.marketLabel.isHidden = true
//        }
//
//        if hasBetStatus {
//            switch self.betHistoryEntrySelection.result {
//            case .won, .halfWon:
//                self.betStatusView.backgroundColor = UIColor.App.myTicketsWon
//                self.betStatusLabel.text = localized("won")
//            case .lost, .halfLost:
//                self.betStatusView.backgroundColor = UIColor.App.myTicketsLost
//                self.betStatusLabel.text = localized("lost")
//            case .drawn:
//                self.betStatusView.backgroundColor = UIColor.App.myTicketsOther
//                self.betStatusLabel.text = localized("draw")
//            case .void:
//                self.betStatusView.backgroundColor = UIColor.App.myTicketsOther
//                self.betStatusLabel.text = localized("void")
//            case .undefined, .open:
//                self.hasBetStatus = false
//            }
//        }
//        else {
//            self.hasBetStatus = false
//        }
//
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        self.countryIconImageView.layer.cornerRadius = self.countryIconImageView.frame.height / 2
//
//        self.betStatusView.layer.cornerRadius = self.betStatusView.frame.height / 2
//        self.betStatusView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
//    }
//
//    func setupWithTheme() {
//        self.backgroundColor = .clear
//
//        self.containerView.backgroundColor = UIColor.App.backgroundSecondary
//
//        self.sportIconImageView.backgroundColor = .clear
//        self.countryIconImageView.backgroundColor = .clear
//
//        self.sportIconImageView.setImageColor(color: UIColor.App.textPrimary)
//        
//        self.competitionLabel.textColor = UIColor.App.textSecondary
//
//        self.matchLabel.textColor = UIColor.App.textPrimary
//
//        self.marketLabel.textColor = UIColor.App.textSecondary
//
//        self.betStatusLabel.textColor = UIColor.App.buttonTextPrimary
//    }
//}
//
////
//// MARK: Subviews initialization and setup
////
//extension ChatTicketSelectionView {
//
//    private static func createContainerView() -> UIView {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = CornerRadius.view
//        return view
//    }
//
//    private static func createSportIconBaseView() -> UIView {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }
//
//    private static func createSportIconImageView() -> UIImageView {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.image = UIImage(named: "sport_type_icon_default")
//        imageView.contentMode = .scaleAspectFit
//        return imageView
//    }
//
//    private static func createCountryIconBaseView() -> UIView {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }
//
//    private static func createCountryIconImageView() -> UIImageView {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.image = UIImage(named: "country_flag_240")
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        return imageView
//    }
//
//    private static func createCompetitionLabel() -> UILabel {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = AppFont.with(type: .semibold, size: 9)
//        label.text = "Competition"
//        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        return label
//    }
//
//    private static func createLabelsStackView() -> UIStackView {
//        let stackView = UIStackView()
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.distribution = .fillEqually
//        stackView.axis = .vertical
//        return stackView
//    }
//    
//    private static func createMatchLabel() -> UILabel {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = AppFont.with(type: .bold, size: 11)
//        label.text = "Team1 vs Team2"
//        label.numberOfLines = 2
//        return label
//    }
//
//    private static func createMarketLabel() -> UILabel {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = AppFont.with(type: .semibold, size: 11)
//        label.text = "Market - Outcome"
//        label.numberOfLines = 3
//        return label
//    }
//
//    private static func createBetStatusView() -> UIView {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }
//
//    private static func createBetStatusLabel() -> UILabel {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textAlignment = .center
//        label.text = "Status"
//        label.font = AppFont.with(type: .semibold, size: 10)
//        return label
//    }
//
//    private func setupSubviews() {
//        self.addSubview(self.containerView)
//
//        self.containerView.addSubview(self.sportIconBaseView)
//        self.sportIconBaseView.addSubview(self.sportIconImageView)
//
//        self.containerView.addSubview(self.countryIconBaseView)
//        self.countryIconBaseView.addSubview(self.countryIconImageView)
//
//        self.containerView.addSubview(self.competitionLabel)
//
//        self.containerView.addSubview(self.labelsStackView)
//
//        self.labelsStackView.addArrangedSubview(self.matchLabel)
//        self.labelsStackView.addArrangedSubview(self.marketLabel)
//
//        self.containerView.addSubview(self.betStatusView)
//
//        self.betStatusView.addSubview(self.betStatusLabel)
//
//        self.initConstraints()
//
//    }
//
//    private func initConstraints() {
//
//        // Container view
//        NSLayoutConstraint.activate([
//            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
//            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
//
//            self.sportIconBaseView.widthAnchor.constraint(equalToConstant: 14),
//            self.sportIconBaseView.heightAnchor.constraint(equalTo: self.sportIconBaseView.widthAnchor),
//            self.sportIconBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
//            self.sportIconBaseView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
//
//            self.sportIconImageView.leadingAnchor.constraint(equalTo: self.sportIconBaseView.leadingAnchor),
//            self.sportIconImageView.trailingAnchor.constraint(equalTo: self.sportIconBaseView.trailingAnchor),
//            self.sportIconImageView.topAnchor.constraint(equalTo: self.sportIconBaseView.topAnchor),
//            self.sportIconImageView.bottomAnchor.constraint(equalTo: self.sportIconBaseView.bottomAnchor),
//
//            self.countryIconBaseView.widthAnchor.constraint(equalToConstant: 14),
//            self.countryIconBaseView.heightAnchor.constraint(equalTo: self.countryIconBaseView.widthAnchor),
//            self.countryIconBaseView.leadingAnchor.constraint(equalTo: self.sportIconBaseView.trailingAnchor, constant: 3),
//            self.countryIconBaseView.centerYAnchor.constraint(equalTo: self.sportIconBaseView.centerYAnchor),
//
//            self.countryIconImageView.leadingAnchor.constraint(equalTo: self.countryIconBaseView.leadingAnchor),
//            self.countryIconImageView.trailingAnchor.constraint(equalTo: self.countryIconBaseView.trailingAnchor),
//            self.countryIconImageView.topAnchor.constraint(equalTo: self.countryIconBaseView.topAnchor),
//            self.countryIconImageView.bottomAnchor.constraint(equalTo: self.countryIconBaseView.bottomAnchor),
//
//            self.competitionLabel.heightAnchor.constraint(equalToConstant: 14),
//            self.competitionLabel.leadingAnchor.constraint(equalTo: self.countryIconBaseView.trailingAnchor, constant: 6),
//            self.competitionLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -5),
//            self.competitionLabel.centerYAnchor.constraint(equalTo: self.countryIconBaseView.centerYAnchor),
//
//            self.matchLabel.heightAnchor.constraint(equalToConstant: 20),
//            
//            self.marketLabel.heightAnchor.constraint(equalToConstant: 20),
//            
//            self.labelsStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
//            self.labelsStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -5),
//            self.labelsStackView.topAnchor.constraint(equalTo: self.sportIconBaseView.bottomAnchor, constant: 8),
//            self.labelsStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -2),
//            
////            self.marketLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
////            self.marketLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -5),
////            self.marketLabel.topAnchor.constraint(equalTo: self.matchLabel.bottomAnchor),
////            self.marketLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -2),
//
//            self.betStatusView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: 15),
//            self.betStatusView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 0),
//            self.betStatusView.heightAnchor.constraint(equalToConstant: 19),
//
//            self.betStatusLabel.leadingAnchor.constraint(equalTo: self.betStatusView.leadingAnchor, constant: 4),
//            self.betStatusLabel.trailingAnchor.constraint(equalTo: self.betStatusView.trailingAnchor, constant: -4),
//            self.betStatusLabel.centerYAnchor.constraint(equalTo: self.betStatusView.centerYAnchor)
//        ])
//
//    }
//
//}
