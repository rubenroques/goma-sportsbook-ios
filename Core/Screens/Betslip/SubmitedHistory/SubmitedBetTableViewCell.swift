//
//  SubmitedBetTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/11/2021.
//

import UIKit
import Combine

class SubmitedBetTableViewCell: UITableViewCell {

    @IBOutlet weak var baseView: UIView!

    @IBOutlet weak var topView: UIView!

    @IBOutlet weak var betTypeLabel: UILabel!
    @IBOutlet weak var oddBaseView: UIView!
    @IBOutlet weak var oddValueLabel: UILabel!
    @IBOutlet weak var upChangeOddValueImage: UIImageView!
    @IBOutlet weak var downChangeOddValueImage: UIImageView!

    @IBOutlet weak var stackBaseView: UIView!
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var bottomSeparatorView: UIView!
    @IBOutlet weak var bottomView: UIView!

    @IBOutlet private weak var betAmountTitleLabel: UILabel!
    @IBOutlet private weak var betAmountValueLabel: UILabel!

    @IBOutlet private weak var possibleWinningsTitleLabel: UILabel!
    @IBOutlet private weak var possibleWinningsValueLabel: UILabel!

    private var cancellables = Set<AnyCancellable>()

    var betHistoryEntry: BetHistoryEntry?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.baseView.layer.masksToBounds = true
        self.baseView.clipsToBounds = true
        self.baseView.layer.cornerRadius = CornerRadius.view

        self.upChangeOddValueImage.alpha = 0.0
        self.downChangeOddValueImage.alpha = 0.0

        self.baseView.layer.cornerRadius = 9
        
        self.betAmountTitleLabel.text = "Bet Amount"
        self.possibleWinningsTitleLabel.text = "Possible Winnings"

        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.baseView.layer.cornerRadius = CornerRadius.view

        self.stackBaseView.subviews.forEach { subview in
            subview.layoutSubviews()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.betHistoryEntry = nil

        self.oddValueLabel.text = "-.--"
        self.betTypeLabel.text = ""
        self.possibleWinningsValueLabel.text = ""

        self.stackView.removeAllArrangedSubviews()
    }

    func setupWithTheme() {

        self.backgroundColor = UIColor.clear
        self.backgroundView?.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear

        self.stackBaseView.backgroundColor = UIColor.App.secondaryBackground
        self.stackView.backgroundColor = UIColor.App.secondaryBackground

        self.bottomSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.baseView.backgroundColor = UIColor.App.secondaryBackground

        for view in stackView.arrangedSubviews {
            if let typedView = view as? SubmitedBetSelectionView {
                typedView.setupWithTheme()
            }
        }
    }

    func configureWithBetHistoryEntry(_ betHistoryEntry: BetHistoryEntry) {
        self.betHistoryEntry = betHistoryEntry

        self.oddValueLabel.text = "-.--"

        if betHistoryEntry.type == "MULTIPLE" {
            let betCount = betHistoryEntry.selections?.count ?? 1
            self.betTypeLabel.text = "Multiple (\(betCount))"
        }
        else if betHistoryEntry.type == "SINGLE" {
            self.betTypeLabel.text = "Simple"
        }

        if let maxWinnings = betHistoryEntry.maxWinning {
            self.possibleWinningsValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) ?? "-.--€"
        }

        if let betAmount = betHistoryEntry.amount {
            self.betAmountValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: betAmount)) ?? "-.--€"
        }

        self.stackView.removeAllArrangedSubviews()

        for selection in betHistoryEntry.selections ?? [] {
            let submitedBetSelectionView = SubmitedBetSelectionView(betHistoryEntrySelection: selection)
            self.stackView.addArrangedSubview(submitedBetSelectionView)
            NSLayoutConstraint.activate([
                submitedBetSelectionView.heightAnchor.constraint(equalToConstant: 88)
            ])
        }

    }

}
