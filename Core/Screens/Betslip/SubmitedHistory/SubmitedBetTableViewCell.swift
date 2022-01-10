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

    @IBOutlet private var cashoutStackView: UIStackView!
    @IBOutlet private var cashoutView: UIView!
    @IBOutlet private var cashoutLogoImageView: UIImageView!
    @IBOutlet private var cashoutTitleLabel: UILabel!
    @IBOutlet private var cashoutValueLabel: UILabel!
    @IBOutlet private var cashoutButton: UIButton!
    @IBOutlet private var cashoutSeparatorView: UIView!

    private var cancellables = Set<AnyCancellable>()

    var betHistoryEntry: BetHistoryEntry?
    var viewModel: SubmitedBetTableViewCellViewModel?

    var cashoutAction: (() -> Void)?
    var infoAction: (() -> Void)?
    var needsRedraw: (() -> Void)?

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

        self.cashoutLogoImageView.image = UIImage(systemName: "info.circle")
        let logoGesture = UITapGestureRecognizer(target: self, action: #selector(self.showPopover))
        self.cashoutLogoImageView.addGestureRecognizer(logoGesture)
        self.cashoutLogoImageView.isUserInteractionEnabled = true

        self.cashoutTitleLabel.text = localized("string_cashout_available")
        self.cashoutTitleLabel.font = AppFont.with(type: .semibold, size: 12)

        self.cashoutValueLabel.text = "-.--"
        self.cashoutValueLabel.font = AppFont.with(type: .semibold, size: 14)

        self.cashoutButton.setTitle(localized("string_cashout"), for: .normal)
        self.cashoutButton.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        StyleHelper.styleButton(button: self.cashoutButton)
        self.cashoutButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

        self.cashoutView.isHidden = true

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

        self.oddBaseView.isHidden = false

        self.betHistoryEntry = nil

        self.oddValueLabel.text = "-.--"
        self.betTypeLabel.text = ""
        self.possibleWinningsValueLabel.text = ""

        self.stackView.removeAllArrangedSubviews()

        self.cashoutValueLabel.text = "-.--"

        self.viewModel = nil
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

        self.cashoutStackView.backgroundColor = UIColor.App.secondaryBackground
        self.cashoutView.backgroundColor = UIColor.App.secondaryBackground
        self.cashoutLogoImageView.backgroundColor = .clear
        self.cashoutTitleLabel.textColor = UIColor.App.headingSecondary
        self.cashoutValueLabel.textColor = UIColor.App.headingMain
        self.cashoutButton.setBackgroundColor(UIColor.App.tertiaryBackground, for: .normal)
        self.cashoutSeparatorView.backgroundColor = UIColor.App.separatorLine

    }

    func configureWithViewModel(viewModel: SubmitedBetTableViewCellViewModel) {

        self.viewModel = viewModel

        let betHistoryEntry = viewModel.ticket

        self.oddValueLabel.text = "-.--"

        if betHistoryEntry.type == "MULTIPLE" {
            let betCount = betHistoryEntry.selections?.count ?? 1
            self.betTypeLabel.text = "Multiple (\(betCount))"
            self.oddBaseView.isHidden = true
        }
        else if betHistoryEntry.type == "SINGLE" {
            self.betTypeLabel.text = "Simple"
            self.oddBaseView.isHidden = true
        }
        else if betHistoryEntry.type == "SYSTEM" {
            self.betTypeLabel.text = "System"
            self.oddBaseView.isHidden = true
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

//        if let cashout = viewModel.cashout {
//            self.setupCashout(cashout: cashout)
//        }

        viewModel.hasCashoutEnabled
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { enabled in
                if enabled, let cashout = viewModel.cashout {
                    self.setupCashout(cashout: cashout)
                }
            })
            .store(in: &cancellables)

    }

    func configureWithBetHistoryEntry(_ betHistoryEntry: BetHistoryEntry) {
        self.betHistoryEntry = betHistoryEntry

        self.oddValueLabel.text = "-.--"

        if betHistoryEntry.type == "MULTIPLE" {
            let betCount = betHistoryEntry.selections?.count ?? 1
            self.betTypeLabel.text = "Multiple (\(betCount))"
            self.oddBaseView.isHidden = true
        }
        else if betHistoryEntry.type == "SINGLE" {
            self.betTypeLabel.text = "Simple"
            self.oddBaseView.isHidden = true
        }
        else if betHistoryEntry.type == "SYSTEM" {
            self.betTypeLabel.text = "System"
            self.oddBaseView.isHidden = true
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

    func setupCashout(cashout: EveryMatrix.Cashout) {
        guard let cashoutValue = cashout.value else {return}
        self.cashoutValueLabel.text = "\(cashoutValue)"
        self.cashoutView.isHidden = false
        self.needsRedraw?()
    }

    @objc private func showPopover(sender: UITapGestureRecognizer) {
        self.infoAction?()
    }

    @IBAction private func cashoutButtonAction(_ sender: Any) {
        self.cashoutAction?()
    }

}
