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

    var betHistoryEntrySelection: BetHistoryEntrySelection
    var countryCode: String = ""

    var viewModel: MyTicketBetLineViewModel?
    var tappedMatchDetail: ((String) -> Void)?
    
    private var homeResultSubscription: AnyCancellable?
    private var awayResultSubscription: AnyCancellable?
    
    convenience init(betHistoryEntrySelection: BetHistoryEntrySelection, countryCode: String, viewModel: MyTicketBetLineViewModel) {
        self.init(frame: .zero, betHistoryEntrySelection: betHistoryEntrySelection, countryCode: countryCode, viewModel: viewModel)
    }

    init(frame: CGRect, betHistoryEntrySelection: BetHistoryEntrySelection, countryCode: String, viewModel: MyTicketBetLineViewModel) {
        self.betHistoryEntrySelection = betHistoryEntrySelection
        self.countryCode = countryCode
        self.viewModel = viewModel

        super.init(frame: frame)

        self.commonInit()
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

        if let sportId = self.betHistoryEntrySelection.sportId, let image = UIImage(named: "sport_type_icon_\(sportId)") {
            self.sportTypeImageView.image = image
        }
        else {
            self.sportTypeImageView.image = UIImage(named: "sport_type_icon_default")
        }
        self.sportTypeImageView.setImageColor(color: UIColor.App.textPrimary)
        
        if let image = UIImage(named: Assets.flagName(withCountryCode: self.countryCode)) {
            self.locationImageView.image = image
        }
        else {
            self.locationImageView.isHidden = true
        }

        self.marketLabel.text = self.betHistoryEntrySelection.marketName ?? ""
        self.outcomeLabel.text = self.betHistoryEntrySelection.betName ?? ""
        self.oddTitleLabel.text = localized("odd")

        if let oddValue = self.betHistoryEntrySelection.priceValue {
            // self.oddValueLabel.text = String(format: "%.2f", Double(floor(oddValue * 100)/100))
            // let newOddValue = Double(floor(oddValue * 100)/100)
            self.oddValueLabel.text = OddConverter.stringForValue(oddValue, format: UserDefaults.standard.userOddsFormat)
        }

        self.dateLabel.text = localized("empty_value")
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
            
            let baseViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBaseView))
            baseView.addGestureRecognizer(baseViewTapGesture)
        }
        else if let date = self.betHistoryEntrySelection.eventDate {
            self.dateLabel.text = MyTicketBetLineView.dateFormatter.string(from: date)
            self.liveIconImage.isHidden = true
            self.dateLabel.isHidden = false
        }
              
        self.homeTeamScoreLabel.text = localized("empty_value")
        self.awayTeamScoreLabel.text = localized("empty_value")

        self.homeResultSubscription = self.viewModel?.homeScore
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] homeGoals in
            self?.homeTeamScoreLabel.text = homeGoals ?? ""
        })

        self.awayResultSubscription = self.viewModel?.awayScore
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] awayGoals in
            self?.awayTeamScoreLabel.text = awayGoals ?? ""
        })

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
        if let status = self.betHistoryEntrySelection.status?.uppercased() {
            switch status {
            case "WON":
                self.indicatorBaseView.isHidden = false
                self.dateLabel.isHidden = true
                self.indicatorInternalBaseView.backgroundColor = UIColor.App.myTicketsWon
                self.indicatorLabel.text = localized("won")
                self.bottomBaseView.backgroundColor = .clear
                self.separatorView.isHidden = false
            case "HALF_WON":
                self.indicatorBaseView.isHidden = false
                self.dateLabel.isHidden = true
                self.indicatorInternalBaseView.backgroundColor = UIColor.App.myTicketsWon
                self.indicatorLabel.text = localized("half_won")
                self.bottomBaseView.backgroundColor = .clear
                self.separatorView.isHidden = false
            case "LOST":
                self.indicatorBaseView.isHidden = false
                self.dateLabel.isHidden = true
                self.indicatorInternalBaseView.backgroundColor = UIColor.App.myTicketsLost
                self.bottomBaseView.backgroundColor = .clear
                self.indicatorLabel.text = localized("lost")
                self.separatorView.isHidden = false
            case "HALF_LOST":
                self.indicatorBaseView.isHidden = false
                self.dateLabel.isHidden = true
                self.indicatorInternalBaseView.backgroundColor = UIColor.App.myTicketsLost
                self.bottomBaseView.backgroundColor = .clear
                self.indicatorLabel.text = localized("half_lost")
                self.separatorView.isHidden = false
            case "DRAW":
                self.indicatorBaseView.isHidden = false
                self.dateLabel.isHidden = true
                self.indicatorInternalBaseView.backgroundColor = UIColor.App.myTicketsOther
                self.bottomBaseView.backgroundColor = .clear
                self.indicatorLabel.text = localized("draw")
                self.separatorView.isHidden = false
            case "OPEN":
                self.dateLabel.isHidden = false
                self.indicatorLabel.text = localized("empty_value")
                self.indicatorBaseView.isHidden = true
            default:
                self.dateLabel.isHidden = true
                self.indicatorLabel.text = localized("empty_value")
                self.indicatorBaseView.isHidden = false

            }
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
