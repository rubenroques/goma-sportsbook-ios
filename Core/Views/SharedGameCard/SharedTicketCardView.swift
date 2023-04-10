//
//  SharedTicketCardView.swift
//  Sportsbook
//
//  Created by André Lascas on 11/07/2022.
//

import UIKit

class SharedTicketCardView: UIView {

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var shareButton: UIButton = Self.createShareButton()
    private lazy var betCardsBaseView: UIView = Self.createBetCardsBaseView()
    private lazy var betCardsStackView: UIStackView = Self.createBetCardsStackView()
    private lazy var bottomBaseView: UIView = Self.createBottomBaseView()
    private lazy var bottomSeparatorLineView: UIView = Self.createBottomSeparatorLineView()
    private lazy var bottomTitlesStackView: UIStackView = Self.createBottomTitlesStackView()
    private lazy var bottomSubtitlesStackView: UIStackView = Self.createBottomSubtitlesStackView()
    private lazy var totalOddTitleLabel: UILabel = Self.createTotalOddTitleLabel()
    private lazy var totalOddSubtitleLabel: UILabel = Self.createTotalOddSubtitleLabel()
    private lazy var betAmountTitleLabel: UILabel = Self.createBetAmountTitleLabel()
    private lazy var betAmountSubtitleLabel: UILabel = Self.createBetAmountSubtitleLabel()
    private lazy var winningsTitleLabel: UILabel = Self.createWinningsTitleLabel()
    private lazy var winningsSubtitleLabel: UILabel = Self.createWinningsSubtitleLabel()

    private var betHistoryEntry: BetHistoryEntry?

    var didTappedSharebet: ((UIImage?) -> Void)?

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

        if Env.appSession.businessModulesManager.isSocialFeaturesEnabled {
            self.shareButton.isHidden = false
        }
        else {
            self.shareButton.isHidden = true
        }
        
        self.shareButton.addTarget(self, action: #selector(didTapShareButton), for: .primaryActionTriggered)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.baseView.layer.cornerRadius = CornerRadius.button
        self.baseView.clipsToBounds = true
        self.baseView.layer.masksToBounds = true

    }

    func setupWithTheme() {

        self.backgroundColor = UIColor.App.backgroundPrimary

        self.shareButton.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.subtitleLabel.textColor = UIColor.App.textPrimary

        self.baseView.backgroundColor = UIColor.App.backgroundSecondary
        self.betCardsBaseView.backgroundColor = .clear
        self.betCardsStackView.backgroundColor = .clear

        self.bottomSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        self.bottomBaseView.backgroundColor = .clear
        self.bottomTitlesStackView.backgroundColor = .clear
        self.bottomSubtitlesStackView.backgroundColor = .clear

        self.totalOddTitleLabel.textColor = UIColor.App.textSecondary

        self.totalOddSubtitleLabel.textColor = UIColor.App.textPrimary

        self.betAmountTitleLabel.textColor = UIColor.App.textSecondary

        self.betAmountSubtitleLabel.textColor = UIColor.App.textPrimary

        self.winningsTitleLabel.textColor = UIColor.App.textSecondary

        self.winningsSubtitleLabel.textColor = UIColor.App.textPrimary
    }

    func configure(withBetHistoryEntry betHistoryEntry: BetHistoryEntry, countryCodes: [String], viewModel: MyTicketCellViewModel) {

        self.betHistoryEntry = betHistoryEntry

        self.betCardsStackView.removeAllArrangedSubviews()

        for (index, betHistoryEntrySelection) in (betHistoryEntry.selections ?? []).enumerated() {

            let sharedTicketBetLineView = SharedTicketBetLineView(betHistoryEntrySelection: betHistoryEntrySelection, countryCode: countryCodes[safe: index] ?? "")

            sharedTicketBetLineView.layoutIfNeeded()
            sharedTicketBetLineView.layoutSubviews()

            self.betCardsStackView.addArrangedSubview(sharedTicketBetLineView)
        }

        if betHistoryEntry.type?.lowercased() == "single" {
            self.titleLabel.text = localized("single")+" Bet"
        }
        else if betHistoryEntry.type?.lowercased() == "multiple" {
            self.titleLabel.text = localized("multiple")+" Bet"
        }
        else {
            self.titleLabel.text = localized("system")+" Bet"
        }

        self.titleLabel.text = betHistoryEntry.type?.lowercased() ?? ""

        if let date = betHistoryEntry.placedDate {
            self.subtitleLabel.text = MyTicketBetLineView.dateFormatter.string(from: date)
        }

        if let oddValue = betHistoryEntry.totalPriceValue, betHistoryEntry.type != "SYSTEM" {
            self.totalOddSubtitleLabel.text = OddConverter.stringForValue(oddValue, format: UserDefaults.standard.userOddsFormat)
        }

        if let betAmount = betHistoryEntry.totalBetAmount,
           let betAmountString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: betAmount)) {
            self.betAmountSubtitleLabel.text = betAmountString
        }

        self.winningsTitleLabel.text = localized("possible_winnings")
        if let maxWinnings = betHistoryEntry.maxWinning,
           let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
            self.winningsSubtitleLabel.text = maxWinningsString
        }

    }

    @objc func didTapShareButton() {
        print("Tapped share")
        let renderer = UIGraphicsImageRenderer(size: self.baseView.bounds.size)
        let image = renderer.image { _ in
            self.baseView.drawHierarchy(in: self.baseView.bounds, afterScreenUpdates: true)
        }

        didTappedSharebet?(image)
    }

}

extension SharedTicketCardView {
    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createHeaderBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 14)
        label.text = localized("title")
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 9)
        label.text = localized("subtitle")
        return label
    }

    private static func createShareButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "send_bet_icon"), for: .normal)
        return button
    }

    private static func createBetCardsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBetCardsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }

    private static func createBottomBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomTitlesStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.distribution = .fillEqually
        return stackView
    }

    private static func createBottomSubtitlesStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.distribution = .fillEqually
        return stackView
    }

    private static func createTotalOddTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold , size: 10)
        label.text = localized("total_odd")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    private static func createTotalOddSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold , size: 12)
        label.text = "-.--"
        label.textAlignment = .center
        return label
    }

    private static func createBetAmountTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold , size: 10)
        label.text = localized("bet_amount")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    private static func createBetAmountSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold , size: 12)
        label.text = "-.--"
        label.textAlignment = .center
        return label
    }

    private static func createWinningsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold , size: 10)
        label.text = localized("winnings")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    private static func createWinningsSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold , size: 14)
        label.text = "-.--"
        label.textAlignment = .center
        return label
    }

    private func setupSubviews() {
        self.addSubview(self.baseView)

        self.baseView.addSubview(self.titleLabel)

        self.baseView.addSubview(self.subtitleLabel)

        self.baseView.addSubview(self.shareButton)

        self.baseView.addSubview(self.betCardsBaseView)

        self.betCardsBaseView.addSubview(self.betCardsStackView)

        self.baseView.addSubview(self.bottomBaseView)

        self.bottomBaseView.addSubview(self.bottomTitlesStackView)

        self.bottomBaseView.addSubview(self.bottomSeparatorLineView)

        self.bottomBaseView.addSubview(self.bottomSubtitlesStackView)

        self.bottomTitlesStackView.addArrangedSubview(self.totalOddTitleLabel)
        self.bottomTitlesStackView.addArrangedSubview(self.betAmountTitleLabel)
        self.bottomTitlesStackView.addArrangedSubview(self.winningsTitleLabel)

        self.bottomSubtitlesStackView.addArrangedSubview(self.totalOddSubtitleLabel)
        self.bottomSubtitlesStackView.addArrangedSubview(self.betAmountSubtitleLabel)
        self.bottomSubtitlesStackView.addArrangedSubview(self.winningsSubtitleLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 16),
            self.titleLabel.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 14),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -16),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 16),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 3),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -16),

            self.shareButton.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -5),
            self.shareButton.widthAnchor.constraint(equalToConstant: 40),
            self.shareButton.heightAnchor.constraint(equalTo: self.shareButton.widthAnchor),
            self.shareButton.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),

            self.betCardsBaseView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 16),
            self.betCardsBaseView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -16),
            self.betCardsBaseView.topAnchor.constraint(equalTo: self.subtitleLabel.bottomAnchor, constant: 9),
            self.betCardsBaseView.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),

            self.betCardsStackView.leadingAnchor.constraint(equalTo: self.betCardsBaseView.leadingAnchor),
            self.betCardsStackView.trailingAnchor.constraint(equalTo: self.betCardsBaseView.trailingAnchor),
            self.betCardsStackView.topAnchor.constraint(equalTo: self.betCardsBaseView.topAnchor),
            self.betCardsStackView.bottomAnchor.constraint(equalTo: self.betCardsBaseView.bottomAnchor),

            self.bottomBaseView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.bottomBaseView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.bottomBaseView.topAnchor.constraint(equalTo: self.betCardsBaseView.bottomAnchor, constant: 12),
            self.bottomBaseView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -14),
//            self.bottomBaseView.heightAnchor.constraint(equalToConstant: 55),

            self.bottomTitlesStackView.leadingAnchor.constraint(equalTo: self.bottomBaseView.leadingAnchor, constant: 25),
            self.bottomTitlesStackView.trailingAnchor.constraint(equalTo: self.bottomBaseView.trailingAnchor, constant: -25),
            self.bottomTitlesStackView.topAnchor.constraint(equalTo: self.bottomBaseView.topAnchor, constant: 0),
            self.bottomTitlesStackView.heightAnchor.constraint(equalToConstant: 25),

            self.bottomSeparatorLineView.leadingAnchor.constraint(equalTo: self.bottomBaseView.leadingAnchor, constant: 25),
            self.bottomSeparatorLineView.trailingAnchor.constraint(equalTo: self.bottomBaseView.trailingAnchor, constant: -25),
            self.bottomSeparatorLineView.topAnchor.constraint(equalTo: self.bottomTitlesStackView.bottomAnchor, constant: 2),
            self.bottomSeparatorLineView.heightAnchor.constraint(equalToConstant: 1),

            self.bottomSubtitlesStackView.leadingAnchor.constraint(equalTo: self.bottomBaseView.leadingAnchor, constant: 25),
            self.bottomSubtitlesStackView.trailingAnchor.constraint(equalTo: self.bottomBaseView.trailingAnchor, constant: -25),
            self.bottomSubtitlesStackView.topAnchor.constraint(equalTo: self.bottomSeparatorLineView.bottomAnchor, constant: 2),
            self.bottomSubtitlesStackView.bottomAnchor.constraint(equalTo: self.bottomBaseView.bottomAnchor, constant: 0),
            self.bottomSubtitlesStackView.heightAnchor.constraint(equalToConstant: 25)

        ])

    }
}
