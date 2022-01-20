//
//  SubmitedBetTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/11/2021.
//

import UIKit
import Combine

class SubmitedBetTableViewCell: UITableViewCell {

    @IBOutlet private weak var baseView: UIView!

    @IBOutlet private weak var topView: UIView!

    @IBOutlet private weak var betTypeLabel: UILabel!
    @IBOutlet private weak var oddBaseView: UIView!
    @IBOutlet private weak var oddValueLabel: UILabel!
    @IBOutlet private weak var upChangeOddValueImage: UIImageView!
    @IBOutlet private weak var downChangeOddValueImage: UIImageView!

    @IBOutlet private weak var stackBaseView: UIView!
    @IBOutlet private weak var stackView: UIStackView!

    @IBOutlet private weak var bottomSeparatorView: UIView!
    @IBOutlet private weak var bottomView: UIView!

    @IBOutlet private weak var betAmountTitleLabel: UILabel!
    @IBOutlet private weak var betAmountValueLabel: UILabel!

    @IBOutlet private weak var possibleWinningsTitleLabel: UILabel!
    @IBOutlet private weak var possibleWinningsValueLabel: UILabel!

    @IBOutlet private weak var cashoutStackView: UIStackView!
    @IBOutlet private weak var cashoutView: UIView!
    @IBOutlet private weak var cashoutLogoImageView: UIImageView!
    @IBOutlet private weak var cashoutTitleLabel: UILabel!
    @IBOutlet private weak var cashoutValueLabel: UILabel!
    @IBOutlet private weak var cashoutButton: UIButton!
    @IBOutlet private weak var cashoutSeparatorView: UIView!

    private var cancellables = Set<AnyCancellable>()

    var betHistoryEntry: BetHistoryEntry?
    var viewModel: SubmitedBetTableViewCellViewModel?
    var cashoutEnabledSubscription: AnyCancellable?
    var cashoutValuePublisher: AnyCancellable?

    var cashoutAction: ((EveryMatrix.Cashout) -> Void)?
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
        
        self.betAmountTitleLabel.text = localized("bet_amount")
        self.possibleWinningsTitleLabel.text = localized("possible_winnings")

        self.cashoutLogoImageView.image = UIImage(systemName: "info.circle")
        let logoGesture = UITapGestureRecognizer(target: self, action: #selector(self.showPopover))
        self.cashoutLogoImageView.addGestureRecognizer(logoGesture)
        self.cashoutLogoImageView.isUserInteractionEnabled = true

        self.cashoutTitleLabel.text = localized("cashout_available")
        self.cashoutTitleLabel.font = AppFont.with(type: .semibold, size: 12)

        self.cashoutValueLabel.text = ""
        self.cashoutValueLabel.font = AppFont.with(type: .semibold, size: 14)

        self.cashoutButton.setTitle(localized("cashout"), for: .normal)
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

        self.cashoutValueLabel.text = ""

        self.viewModel = nil
        self.cashoutEnabledSubscription = nil
        self.cashoutEnabledSubscription?.cancel()

        self.cashoutValuePublisher = nil
        self.cashoutValuePublisher?.cancel()
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
            self.betTypeLabel.text = localized("multiple") + " (\(betCount))"
            self.oddBaseView.isHidden = true
        }
        else if betHistoryEntry.type == "SINGLE" {
            self.betTypeLabel.text = localized("single")
            self.oddBaseView.isHidden = true
        }
        else if betHistoryEntry.type == "SYSTEM" {
            self.betTypeLabel.text = localized("system")
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

        self.cashoutEnabledSubscription = viewModel.hasCashoutEnabled
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] enabled in
                if !enabled && viewModel.cashout == nil {
                    self?.removeCashout()
                }
                if enabled, let cashout = viewModel.cashout {
                    self?.setupCashout(cashout: cashout)
                }

            })

        self.cashoutValuePublisher = self.viewModel?.cashoutValueSubscription
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                self?.cashoutValueLabel.text = "\(value)"
            })

    }

    func setupCashout(cashout: EveryMatrix.Cashout) {
        if let cashoutValue = cashout.value {
            self.cashoutValueLabel.text = "\(cashoutValue)"
            self.cashoutView.isHidden = false
            self.needsRedraw?()
            self.cashoutEnabledSubscription?.cancel()
        }

    }

    func removeCashout() {
        self.cashoutView.isHidden = true
        self.needsRedraw?()
        
    }

    @objc private func showPopover(sender: UITapGestureRecognizer) {
        self.infoAction?()
    }

    @IBAction private func cashoutButtonAction(_ sender: Any) {
        if let cashout = self.viewModel?.cashout {
            self.cashoutAction?(cashout)
        }
    }

}
