//
//  BonusProgressView.swift
//  Sportsbook
//
//  Created by André Lascas on 05/04/2022.
//

import UIKit
import Combine

class BonusProgressView: UIView {
    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var progressBarView: UIProgressView = Self.createProgressBarView()
    private lazy var progressInfoLabel: UILabel = Self.createProgressInfoLabel()
    private lazy var progressAmountLabel: UILabel = Self.createProgressAmountLabel()

    // MARK: Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupSubviews()
        self.setupWithTheme()
    }

    private func setupWithTheme() {

        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.progressBarView.trackTintColor = UIColor.App.buttonBackgroundSecondary

        self.progressAmountLabel.textColor = UIColor.App.textPrimary
    }

    func configure(withViewModel viewModel: BonusProgressViewModel) {

        self.titleLabel.text = viewModel.title

        self.setupProgressInfo(viewModel: viewModel)
    }

    func setupProgressInfo(viewModel: BonusProgressViewModel) {

        var bonusColor = UIColor.App.textPrimary

        switch viewModel.progressType {
        case .bonus:
            bonusColor = UIColor.App.statsAway
            self.setupColoredLabel(label: self.progressInfoLabel, text: localized("remaining_total_bonus"), color: bonusColor)

            self.progressBarView.progressTintColor = bonusColor

        case .wager:
            bonusColor = UIColor.App.highlightSecondary
            self.setupColoredLabel(label: self.progressInfoLabel, text: "\(localized("used")) / \(localized("total_wager"))", color: bonusColor)

            self.progressBarView.progressTintColor = bonusColor

        }

        self.progressBarView.progress = viewModel.progressBarAmount

        let progressAmountString = viewModel.progressAmountString

        self.setupColoredLabel(label: self.progressAmountLabel, text: progressAmountString, color: bonusColor)

    }

    func setupColoredLabel(label: UILabel, text: String, color: UIColor) {
        let fullString = text
        var splitString = fullString.components(separatedBy: "/")
        let coloredString = splitString[0]
        let range = (fullString as NSString).range(of: coloredString)

        let mutableAttributedString = NSMutableAttributedString.init(string: fullString)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)

        label.attributedText = mutableAttributedString
    }

    func testSetupProgressInfo(bonus: EveryMatrix.GrantedBonus, progressType: ProgressType) {

        var bonusColor = UIColor.App.textPrimary
        var remainingAmount = 5.0
        var totalAmount = 10.0
        var amountCurrency = CurrencySymbol.eur.identifier

        switch progressType {
        case .bonus:
            bonusColor = UIColor.App.statsAway
            self.setupColoredLabel(label: self.progressInfoLabel, text: localized("remaining_total_bonus"), color: bonusColor)

            self.progressBarView.progressTintColor = bonusColor

        case .wager:
            bonusColor = UIColor.App.statsHome
            self.setupColoredLabel(label: self.progressInfoLabel, text: localized("remaining_total_wager"), color: bonusColor)

            self.progressBarView.progressTintColor = bonusColor

        }

        let progressBarAmount = Float(remainingAmount/totalAmount)

        self.progressBarView.progress = progressBarAmount

        // let progressAmountString = "\(remainingAmount) / \(totalAmount) \(amountCurrency)"
        let progressAmountString = "\(remainingAmount) / \(totalAmount)"
        self.setupColoredLabel(label: self.progressAmountLabel, text: progressAmountString, color: bonusColor)

    }
}

//
// MARK: Subviews initialization and setup
//
extension BonusProgressView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("title")
        label.numberOfLines = 0
        label.font = AppFont.with(type: .bold, size: 12)
        return label
    }

    private static func createProgressBarView() -> UIProgressView {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0
        return progressView
    }

    private static func createProgressInfoLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = localized("remaining_total_bonus")
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }

    private static func createProgressAmountLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = AppFont.with(type: .semibold, size: 12)
        label.text = "50/100"
        label.textAlignment = .right
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.progressBarView)
        self.containerView.addSubview(self.progressInfoLabel)
        self.containerView.addSubview(self.progressAmountLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.containerView.heightAnchor.constraint(equalToConstant: 60),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 8),

            self.progressBarView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.progressBarView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.progressBarView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),

            self.progressInfoLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.progressInfoLabel.topAnchor.constraint(equalTo: self.progressBarView.bottomAnchor, constant: 8),
            self.progressInfoLabel.trailingAnchor.constraint(equalTo: self.progressAmountLabel.leadingAnchor, constant: -8),

            self.progressAmountLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.progressAmountLabel.topAnchor.constraint(equalTo: self.progressBarView.bottomAnchor, constant: 8)
        ])

    }

}

enum ProgressType {
    case bonus
    case wager
}

enum CurrencySymbol: String {
    case eur = "EUR"
    case usd = "USD"
    case gbp = "GBP"

    var identifier: String {
        switch self {
        case .eur: return "€"
        case .usd: return "$"
        case .gbp: return "£"
        }
    }
}
