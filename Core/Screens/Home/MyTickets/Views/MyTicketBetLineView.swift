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

    @IBOutlet private weak var indicatorBaseView: UIView!
    @IBOutlet private weak var indicatorInternalBaseView: UIView!
    @IBOutlet private weak var indicatorLabel: UILabel!

    var betHistoryEntrySelection: BetHistoryEntrySelection

    convenience init(betHistoryEntrySelection: BetHistoryEntrySelection) {
        self.init(frame: .zero, betHistoryEntrySelection: betHistoryEntrySelection)
    }

    init(frame: CGRect, betHistoryEntrySelection: BetHistoryEntrySelection) {
        self.betHistoryEntrySelection = betHistoryEntrySelection
        super.init(frame: frame)

        self.commonInit()
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        self.tournamentNameLabel.text = self.betHistoryEntrySelection.tournamentName ?? ""

        let splittedTeamNames = Array((self.betHistoryEntrySelection.eventName ?? "").components(separatedBy: " - "))
        if splittedTeamNames.count == 2 {
            self.homeTeamNameLabel.text = splittedTeamNames.first ?? ""
            self.awayTeamNameLabel.text = splittedTeamNames.last ?? ""
        }

        if let sportId = self.betHistoryEntrySelection.sportId {
            self.sportTypeImageView.image = UIImage(named: "sport_type_icon_\(sportId)")
        }

        self.marketLabel.text = self.betHistoryEntrySelection.marketName ?? ""
        self.outcomeLabel.text = self.betHistoryEntrySelection.betName ?? ""
        self.oddTitleLabel.text = "Odd"

        if let oddValue = self.betHistoryEntrySelection.priceValue {
            self.oddValueLabel.text = String(format: "%.2f", Double(floor(oddValue * 100)/100))
        }

        self.homeTeamScoreLabel.text = ""
        self.awayTeamScoreLabel.text = ""

        if let status = self.betHistoryEntrySelection.status?.uppercased() {
            switch status {
            case "WON", "HALF_WON":
                self.indicatorBaseView.isHidden = false
                self.separatorView.isHidden = true
                self.indicatorInternalBaseView.backgroundColor = UIColor.App.statusWon.withAlphaComponent(0.5)
                self.bottomBaseView.backgroundColor = UIColor.App.statusWon.withAlphaComponent(0.5)
                self.indicatorLabel.text = "Won"
            case "LOST", "HALF_LOST":
                self.indicatorBaseView.isHidden = false
                self.separatorView.isHidden = true
                self.indicatorInternalBaseView.backgroundColor = UIColor.App.statusLoss.withAlphaComponent(0.5)
                self.bottomBaseView.backgroundColor = UIColor.App.statusLoss.withAlphaComponent(0.5)
                self.indicatorLabel.text = "Lost"
            default:
                self.indicatorLabel.text = ""
                self.indicatorBaseView.isHidden = true
                self.separatorView.isHidden = false
                self.bottomBaseView.backgroundColor = .clear
            }
        }

        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.baseView.backgroundColor = UIColor.App.tertiaryBackground
        self.indicatorBaseView.backgroundColor = UIColor.clear


        self.separatorView.backgroundColor = UIColor.App.separatorLine

        self.tournamentNameLabel.textColor = UIColor.App.headingMain
        self.homeTeamNameLabel.textColor = UIColor.App.headingMain
        self.homeTeamScoreLabel.textColor = UIColor.App.headingMain
        self.awayTeamNameLabel.textColor = UIColor.App.headingMain
        self.awayTeamScoreLabel.textColor = UIColor.App.headingMain
        self.marketLabel.textColor = UIColor.App.headingMain
        self.outcomeLabel.textColor = UIColor.App.headingMain
        self.oddTitleLabel.textColor = UIColor.App.headingMain
        self.oddValueLabel.textColor = UIColor.App.headingMain

        self.indicatorLabel.textColor = UIColor.App.headingMain

        if let status = self.betHistoryEntrySelection.status?.uppercased() {
            switch status {
            case "WON", "HALF_WON":
                self.indicatorBaseView.isHidden = false
                self.separatorView.isHidden = true
                self.indicatorInternalBaseView.backgroundColor = UIColor.App.statusWon.withAlphaComponent(0.5)
                self.bottomBaseView.backgroundColor = UIColor.App.statusWon.withAlphaComponent(0.5)
                self.indicatorLabel.text = "Won"
            case "LOST", "HALF_LOST":
                self.indicatorBaseView.isHidden = false
                self.separatorView.isHidden = true
                self.indicatorInternalBaseView.backgroundColor = UIColor.App.statusLoss.withAlphaComponent(0.5)
                self.bottomBaseView.backgroundColor = UIColor.App.statusLoss.withAlphaComponent(0.5)
                self.indicatorLabel.text = "Lost"
            default:
                self.indicatorLabel.text = ""
                self.indicatorBaseView.isHidden = true
                self.separatorView.isHidden = false
                self.bottomBaseView.backgroundColor = .clear
            }
        }

    }

}
