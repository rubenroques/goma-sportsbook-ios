//
//  SubmitedBetSelectionView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/11/2021.
//

import UIKit
import Combine

class MyTicketBetLineView: NibView {

    @IBOutlet private weak var baseView: UIView!

    @IBOutlet private weak var sportTypeImageView: UIImageView!
    @IBOutlet private weak var locationImageView: UIImageView!

    @IBOutlet private weak var tournamentNameLabel: UILabel!

    @IBOutlet private weak var homeTeamNameLabel: UILabel!
    @IBOutlet private weak var homeTeamScoreLabel: UILabel!

    @IBOutlet private weak var awayTeamNameLabel: UILabel!
    @IBOutlet private weak var awayTeamScoreLabel: UILabel!

    @IBOutlet private weak var separatorView: UIView!

    @IBOutlet private weak var marketLabel: UILabel!
    @IBOutlet private weak var outcomeLabel: UILabel!

    @IBOutlet private weak var bottomBaseView: UIView!
    @IBOutlet private weak var oddTitleLabel: UILabel!
    @IBOutlet private weak var oddValueLabel: UILabel!

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var liveIconImage: UIImageView!
    
    @IBOutlet private weak var indicatorBaseView: UIView!
    @IBOutlet private weak var indicatorInternalBaseView: UIView!
    @IBOutlet private weak var indicatorLabel: UILabel!

    @IBOutlet private weak var baseViewHeightConstraint: NSLayoutConstraint!

    var betHistoryEntrySelection: BetHistoryEntrySelection
    var countryCode: String = ""

    var viewModel: MyTicketBetLineViewModel?
    var tappedMatchDetail: ((String) -> Void)?
    
    private var homeResultSubscription: AnyCancellable?
    private var awayResultSubscription: AnyCancellable?

    private var cancellables = Set<AnyCancellable>()
    
    convenience init(betHistoryEntrySelection: BetHistoryEntrySelection, countryCode: String, viewModel: MyTicketBetLineViewModel) {
        self.init(frame: .zero, betHistoryEntrySelection: betHistoryEntrySelection, countryCode: countryCode, viewModel: viewModel)
    }

    init(frame: CGRect, betHistoryEntrySelection: BetHistoryEntrySelection, countryCode: String, viewModel: MyTicketBetLineViewModel) {
        self.betHistoryEntrySelection = betHistoryEntrySelection
        self.countryCode = countryCode
        self.viewModel = viewModel

        super.init(frame: frame)

        self.commonInit()

        self.getMatchLiveDetails()
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("MyTicketBetLineView deinit")

        self.homeResultSubscription?.cancel()
        self.homeResultSubscription = nil

        self.awayResultSubscription?.cancel()
        self.awayResultSubscription = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.locationImageView.layer.cornerRadius = self.locationImageView.frame.height/2
        self.indicatorInternalBaseView.layer.cornerRadius = self.indicatorInternalBaseView.frame.height/2
    }

    override func commonInit() {

        self.marketLabel.text = ""
        self.oddValueLabel.text = " - "

        self.homeTeamScoreLabel.text = ""
        self.awayTeamScoreLabel.text = ""

        self.liveIconImage.isHidden = true
        
        self.baseView.clipsToBounds = true
        self.baseView.layer.cornerRadius = 8
        self.baseView.layer.masksToBounds = true

        self.locationImageView.contentMode = .scaleAspectFill
        self.locationImageView.clipsToBounds = true
        self.locationImageView.layer.masksToBounds = true

        if (self.betHistoryEntrySelection.tournamentName ?? "").isEmpty {
            self.tournamentNameLabel.text = self.betHistoryEntrySelection.eventName ?? ""
        }
        else {
            self.tournamentNameLabel.text = self.betHistoryEntrySelection.tournamentName ?? ""
        }

        self.homeTeamNameLabel.text = self.betHistoryEntrySelection.homeParticipantName ?? ""
        self.awayTeamNameLabel.text = self.betHistoryEntrySelection.awayParticipantName ?? ""

//        if let sportId = self.betHistoryEntrySelection.sportId, let image = UIImage(named: "sport_type_icon_\(sportId)") {
//            self.sportTypeImageView.image = image
//        }
//        else {
//            self.sportTypeImageView.image = UIImage(named: "sport_type_icon_default")
//        }
        if let sportCode = self.betHistoryEntrySelection.sportName {

            if let sportId = Env.sportsStore.getSportId(sportCode: sportCode) {
                let image = UIImage(named: "sport_type_icon_\(sportId)")
                self.sportTypeImageView.image = image
            }
            else {
                self.sportTypeImageView.image = UIImage(named: "sport_type_icon_default")
            }

        }
        else {
            self.sportTypeImageView.image = UIImage(named: "sport_type_icon_default")
        }
        self.sportTypeImageView.setImageColor(color: UIColor.App.textPrimary)

        if let image = UIImage(named: Assets.flagName(withCountryCode: self.betHistoryEntrySelection.venueName ?? "")) {
            self.locationImageView.image = image
        }
        else {
            self.locationImageView.isHidden = true
        }
//        if let image = UIImage(named: Assets.flagName(withCountryCode: self.countryCode)) {
//            self.locationImageView.image = image
//        }
//        else {
//            self.locationImageView.isHidden = true
//        }

        if let marketName = self.betHistoryEntrySelection.marketName, let partName = self.betHistoryEntrySelection.bettingTypeEventPartName {
            self.marketLabel.text = "\(marketName) (\(partName))"
        }
        else if let marketName = self.betHistoryEntrySelection.marketName {
            self.marketLabel.text = "\(marketName)"
        }
        self.outcomeLabel.text = self.betHistoryEntrySelection.betName ?? ""
        self.oddTitleLabel.text = localized("odd")

        if let oddValue = self.betHistoryEntrySelection.priceValue {
            // self.oddValueLabel.text = String(format: "%.2f", Double(floor(oddValue * 100)/100))
            // let newOddValue = Double(floor(oddValue * 100)/100)
//            self.oddValueLabel.text = OddConverter.stringForValue(oddValue, format: UserDefaults.standard.userOddsFormat)
            self.oddValueLabel.text = OddFormatter.formatOdd(withValue: oddValue)
        }

        self.dateLabel.text = ""
        if let statusId = self.betHistoryEntrySelection.eventStatusId {
            if statusId == "2" {
                self.dateLabel.isHidden = true
                self.liveIconImage.isHidden = false
            }
            else if let date = self.betHistoryEntrySelection.eventDate {
                self.dateLabel.text = MyTicketBetLineView.dateFormatter.string(from: date)
                self.liveIconImage.isHidden = true
                self.dateLabel.isHidden = false
            }
            
//            let baseViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBaseView))
//            baseView.addGestureRecognizer(baseViewTapGesture)
        }
        else if let date = self.betHistoryEntrySelection.eventDate {
            self.dateLabel.text = MyTicketBetLineView.dateFormatter.string(from: date)
            self.liveIconImage.isHidden = true
            self.dateLabel.isHidden = false
        }

        if self.betHistoryEntrySelection.status == .opened {
            let baseViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBaseView))
            baseView.addGestureRecognizer(baseViewTapGesture)
        }

        if self.betHistoryEntrySelection.homeParticipantName != nil {

            self.homeTeamScoreLabel.text = self.betHistoryEntrySelection.homeParticipantScore ?? "-"
        }

        if self.betHistoryEntrySelection.awayParticipantName != nil {
            
            self.awayTeamScoreLabel.text = self.betHistoryEntrySelection.awayParticipantScore ?? "-"
        }

        if (self.homeTeamNameLabel.text?.isEmpty ?? true) && (self.awayTeamNameLabel.text?.isEmpty ?? true) {
            self.homeTeamNameLabel.isHidden = true
            self.awayTeamNameLabel.isHidden = true
            self.baseViewHeightConstraint.constant = 100
        }

        self.configureFromStatus()
        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = UIColor.App.backgroundSecondary

        self.baseView.backgroundColor = UIColor.App.backgroundTertiary
        self.indicatorBaseView.backgroundColor = UIColor.clear

        self.separatorView.backgroundColor = UIColor.App.separatorLine

        self.tournamentNameLabel.textColor = UIColor.App.textPrimary
        self.homeTeamNameLabel.textColor = UIColor.App.textPrimary
        self.homeTeamScoreLabel.textColor = UIColor.App.textPrimary
        self.awayTeamNameLabel.textColor = UIColor.App.textPrimary
        self.awayTeamScoreLabel.textColor = UIColor.App.textPrimary
        self.marketLabel.textColor = UIColor.App.textPrimary
        self.outcomeLabel.textColor = UIColor.App.textPrimary
        self.oddTitleLabel.textColor = UIColor.App.textPrimary
        self.oddValueLabel.textColor = UIColor.App.textPrimary
        self.dateLabel.textColor = UIColor.App.textPrimary

        self.indicatorLabel.textColor = UIColor.white

        self.bottomBaseView.backgroundColor = .clear
        
        self.configureFromStatus()
    }

    func configureFromStatus() {
        switch self.betHistoryEntrySelection.result {
        case .won:
            self.indicatorBaseView.isHidden = false
            self.dateLabel.isHidden = true
            self.indicatorInternalBaseView.backgroundColor = UIColor.App.myTicketsWon
            self.indicatorLabel.text = localized("won")
            self.bottomBaseView.backgroundColor = .clear
            self.separatorView.isHidden = false
        case .halfWon:
            self.indicatorBaseView.isHidden = false
            self.dateLabel.isHidden = true
            self.indicatorInternalBaseView.backgroundColor = UIColor.App.myTicketsWon
            self.indicatorLabel.text = localized("half_won")
            self.bottomBaseView.backgroundColor = .clear
            self.separatorView.isHidden = false
        case .lost:
            self.indicatorBaseView.isHidden = false
            self.dateLabel.isHidden = true
            self.indicatorInternalBaseView.backgroundColor = UIColor.App.myTicketsLost
            self.bottomBaseView.backgroundColor = .clear
            self.indicatorLabel.text = localized("lost")
            self.separatorView.isHidden = false
        case .halfLost:
            self.indicatorBaseView.isHidden = false
            self.dateLabel.isHidden = true
            self.indicatorInternalBaseView.backgroundColor = UIColor.App.myTicketsLost
            self.bottomBaseView.backgroundColor = .clear
            self.indicatorLabel.text = localized("half_lost")
            self.separatorView.isHidden = false
        case .drawn:
            self.indicatorBaseView.isHidden = false
            self.dateLabel.isHidden = true
            self.indicatorInternalBaseView.backgroundColor = UIColor.App.myTicketsOther
            self.bottomBaseView.backgroundColor = .clear
            self.indicatorLabel.text = localized("draw")
            self.separatorView.isHidden = false
        case .open:
            self.dateLabel.isHidden = false
            self.indicatorLabel.text = ""
            self.indicatorBaseView.isHidden = true
        case .undefined:
            self.dateLabel.isHidden = true
            self.indicatorLabel.text = ""
            self.indicatorBaseView.isHidden = false
        }
    }

    func getMatchLiveDetails() {

        if let eventId = self.betHistoryEntrySelection.eventId {

            Env.servicesProvider.subscribeToEventLiveDataUpdates(withId: eventId)
                .compactMap({ $0 })
                .map(ServiceProviderModelMapper.match(fromEvent:))
                .sink(receiveCompletion: { completion in
                    print("matchSubscriber subscribeToEventLiveDataUpdates completion: \(completion)")
                }, receiveValue: { [weak self] updatedMatch in
                    switch updatedMatch.status {
                    case .notStarted, .ended, .unknown:
//                        self?.matchModePublisher.send(.preLive)
                        self?.liveIconImage.isHidden = true
                        self?.dateLabel.isHidden = false

                    case .inProgress:
//                        self?.matchModePublisher.send(.live)
                        self?.liveIconImage.isHidden = false
                        self?.dateLabel.isHidden = true

                        if let homeScore = updatedMatch.homeParticipantScore {
                            self?.homeTeamScoreLabel.text = "\(homeScore)"
                        }

                        if let awayScore = updatedMatch.awayParticipantScore {
                            self?.awayTeamScoreLabel.text = "\(awayScore)"
                        }
                    }

//                    self?.matchPublisher.send(.loaded(updatedMatch))
                })
                .store(in: &self.cancellables)
        }

    }
    
    @IBAction private func didTapBaseView() {
        if let matchId = self.betHistoryEntrySelection.eventId {
            self.tappedMatchDetail?(matchId)
        }
       
    }

}

extension MyTicketBetLineView {
    static var dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
}
