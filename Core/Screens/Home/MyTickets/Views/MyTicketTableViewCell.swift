//
//  MyTicketTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/12/2021.
//

import UIKit

class MyTicketTableViewCell: UITableViewCell {

    @IBOutlet private weak var baseView: UIView!

    @IBOutlet private weak var topStatusView: UIView!

    @IBOutlet private weak var headerBaseView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var shareButton: UIButton!

    @IBOutlet private weak var betCardsBaseView: UIView!
    @IBOutlet private weak var betCardsStackView: UIStackView!

    @IBOutlet private weak var bottomBaseView: UIView!
    @IBOutlet private weak var bottomSeparatorLineView: UIView!
    @IBOutlet private weak var bottomStackView: UIStackView!

    @IBOutlet private weak var totalOddTitleLabel: UILabel!
    @IBOutlet private weak var totalOddSubtitleLabel: UILabel!

    @IBOutlet private weak var betAmountTitleLabel: UILabel!
    @IBOutlet private weak var betAmountSubtitleLabel: UILabel!

    @IBOutlet private weak var winningsTitleLabel: UILabel!
    @IBOutlet private weak var winningsSubtitleLabel: UILabel!

    @IBOutlet private weak var cashoutBaseView: UIView!
    @IBOutlet private weak var cashoutButton: UIButton!

    private var betHistoryEntry: BetHistoryEntry?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectionStyle = .none
        
        // self.cashoutBaseView.isHidden = true

        self.baseView.clipsToBounds = true
        self.baseView.layer.cornerRadius = 10
        self.baseView.layer.masksToBounds = true

        self.cashoutButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        self.cashoutButton.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)
        self.cashoutButton.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.39), for: .disabled)

        self.cashoutButton.setBackgroundColor(UIColor.App.tertiaryBackground, for: .normal)
        self.cashoutButton.setBackgroundColor(UIColor.App.tertiaryBackground.withAlphaComponent(0.7), for: .highlighted)

        self.cashoutButton.layer.cornerRadius = CornerRadius.button
        self.cashoutButton.layer.masksToBounds = true
        self.cashoutButton.backgroundColor = .clear

        self.totalOddSubtitleLabel.text = "-"
        self.betAmountSubtitleLabel.text = "-"
        self.winningsSubtitleLabel.text = "-"

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.betHistoryEntry = nil

        self.cashoutBaseView.isHidden = true

        self.titleLabel.text = ""
        self.subtitleLabel.text = ""

        self.totalOddTitleLabel.text = "Total Odd"
        self.betAmountTitleLabel.text = "Bet Amount"
        self.winningsTitleLabel.text = "Possible Winnings"

        self.totalOddSubtitleLabel.text = "-"
        self.betAmountSubtitleLabel.text = "-"
        self.winningsSubtitleLabel.text = "-"
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {

        self.backgroundColor = UIColor.clear
        self.backgroundView?.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear

        self.baseView.backgroundColor = UIColor.App.mainBackground
        self.topStatusView.backgroundColor = .clear
        self.headerBaseView.backgroundColor = .clear
        self.betCardsBaseView.backgroundColor = .clear
        self.betCardsStackView.backgroundColor = .clear
        self.bottomSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        self.bottomBaseView.backgroundColor = .clear
        self.bottomStackView.backgroundColor = .clear
        self.cashoutBaseView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.headingMain
        self.subtitleLabel.textColor = UIColor.App.headingSecondary
        self.totalOddTitleLabel.textColor = UIColor.App.headingMain
        self.totalOddSubtitleLabel.textColor = UIColor.App.headingMain
        self.betAmountTitleLabel.textColor = UIColor.App.headingMain
        self.betAmountSubtitleLabel.textColor = UIColor.App.headingMain
        self.winningsTitleLabel.textColor = UIColor.App.headingMain
        self.winningsSubtitleLabel.textColor = UIColor.App.headingMain

        if let status = self.betHistoryEntry?.status?.uppercased() {
            switch status {
            case "WON", "HALF_WON":
                self.highlightCard(withColor: UIColor.App.statusWon)
            case "LOST", "HALF_LOST":
                self.highlightCard(withColor: UIColor.App.statusLoss)
            case "CASHED_OUT", "CANCELLED":
                self.highlightCard(withColor: UIColor.App.statusDraw)
            default:
                self.resetHighlightedCard()
            }
        }
    }

    func configure(withBetHistoryEntry betHistoryEntry: BetHistoryEntry) {

        self.betHistoryEntry = betHistoryEntry

        self.cashoutBaseView.isHidden = true

        self.betCardsStackView.removeAllArrangedSubviews()

        for betHistoryEntrySelection in betHistoryEntry.selections ?? [] {
            let myTicketBetLineView = MyTicketBetLineView(betHistoryEntrySelection: betHistoryEntrySelection)
            self.betCardsStackView.addArrangedSubview(myTicketBetLineView)
        }

        if betHistoryEntry.type == "SINGLE" {
            self.titleLabel.text = "Single Bet [\(betHistoryEntry.status?.uppercased() ?? "-")]"
        }
        else if betHistoryEntry.type == "MULTIPLE" {
            self.titleLabel.text = "Multiple Bet [\(betHistoryEntry.status?.uppercased() ?? "-")]"
        }
        else if betHistoryEntry.type == "SYSTEM" {
            self.titleLabel.text = "System Bet [\(betHistoryEntry.status?.uppercased() ?? "-")]"
        }

        if let date = betHistoryEntry.placedDate {
            self.subtitleLabel.text = MyTicketTableViewCell.dateFormatter.string(from: date)
        }

        if let oddValue = betHistoryEntry.totalPriceValue {
            self.totalOddSubtitleLabel.text = "\(Double(floor(oddValue * 100)/100))"
        }

        if let betAmount = betHistoryEntry.amount,
           let betAmountString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: betAmount)) {
            self.betAmountSubtitleLabel.text = betAmountString
        }

        if let maxWinnings = betHistoryEntry.maxWinning,
           let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
            self.winningsSubtitleLabel.text = maxWinningsString
        }

        if let status = betHistoryEntry.status?.uppercased() {
            switch status {
            case "WON", "HALF_WON":
                self.highlightCard(withColor: UIColor.App.statusWon)
            case "LOST", "HALF_LOST":
                self.highlightCard(withColor: UIColor.App.statusLoss)
            case "CASHED_OUT", "CANCELLED":
                self.highlightCard(withColor: UIColor.App.statusDraw)
            default:
                self.resetHighlightedCard()
            }
        }
    }

    private func resetHighlightedCard() {
        self.bottomBaseView.backgroundColor = .clear
        self.topStatusView.backgroundColor = .clear
        self.bottomSeparatorLineView.backgroundColor = UIColor.App.separatorLine
    }

    private func highlightCard(withColor color: UIColor) {
        self.bottomBaseView.backgroundColor = color
        self.topStatusView.backgroundColor = color

        self.bottomSeparatorLineView.backgroundColor = .white
    }

}

extension MyTicketTableViewCell {
    static var dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        return dateFormatter
    }()
}
