//
//  SharedTicketCardView.swift
//  Sportsbook
//
//  Created by André Lascas on 11/07/2022.
//

import UIKit

class SharedTicketCardView: UIView {

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var headerBaseView: UIView = Self.createHeaderBaseView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    // private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
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
//
//        self.isLiveCard = false
//        self.isTwoMarket = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.baseView.layer.cornerRadius = CornerRadius.button
        self.baseView.clipsToBounds = true
        self.baseView.layer.masksToBounds = true
//        self.locationImageView.layer.cornerRadius = self.locationImageView.frame.width/2
//
//        self.leftOddView.layer.cornerRadius = CornerRadius.button
//        self.middleOddView.layer.cornerRadius = CornerRadius.button
//        self.rightOddView.layer.cornerRadius = CornerRadius.button

    }

    func setupWithTheme() {

        self.backgroundColor = UIColor.App.backgroundPrimary

        self.headerBaseView.backgroundColor = .clear
        self.baseView.backgroundColor = UIColor.App.backgroundSecondary
        self.betCardsBaseView.backgroundColor = .clear
        self.betCardsStackView.backgroundColor = .clear

        self.bottomSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        self.bottomBaseView.backgroundColor = .clear
        self.bottomTitlesStackView.backgroundColor = .clear
        self.bottomSubtitlesStackView.backgroundColor = .clear

    }

    func configure(withBetHistoryEntry betHistoryEntry: BetHistoryEntry, countryCodes: [String], viewModel: MyTicketCellViewModel) {

        self.betHistoryEntry = betHistoryEntry
        let ticketCellViewModel = viewModel

        self.betCardsStackView.removeAllArrangedSubviews()

        for (index, betHistoryEntrySelection) in (betHistoryEntry.selections ?? []).enumerated() {

            let myTicketBetLineView = MyTicketBetLineView(betHistoryEntrySelection: betHistoryEntrySelection,
                                                          countryCode: countryCodes[safe: index] ?? "",
                                                          viewModel: ticketCellViewModel.selections[index])

            self.betCardsStackView.addArrangedSubview(myTicketBetLineView)
        }

        //
        if betHistoryEntry.type == "SINGLE" {
            self.titleLabel.text = localized("single")+" Bet"
        }
        else if betHistoryEntry.type == "MULTIPLE" {
            self.titleLabel.text = localized("multiple")+" Bet"
        }
        else if betHistoryEntry.type == "SYSTEM" {
            self.titleLabel.text = localized("system")+" Bet"
        }

//        if let date = betHistoryEntry.placedDate {
//            self.subtitleLabel.text = MyTicketTableViewCell.dateFormatter.string(from: date)
//        }

        if let oddValue = betHistoryEntry.totalPriceValue, betHistoryEntry.type != "SYSTEM" {
            // let newOddValue = Double(floor(oddValue * 100)/100)
            self.totalOddSubtitleLabel.text = OddConverter.stringForValue(oddValue, format: UserDefaults.standard.userOddsFormat)
        }

        if let betAmount = betHistoryEntry.totalBetAmount,
           let betAmountString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: betAmount)) {
            self.betAmountSubtitleLabel.text = betAmountString
        }

        //
        self.winningsTitleLabel.text = localized("possible_winnings")
        if let maxWinnings = betHistoryEntry.maxWinning,
           let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
            self.winningsSubtitleLabel.text = maxWinningsString
        }

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
        label.font = AppFont.with(type: .bold, size: 16)
        label.text = "Title"
        return label
    }

//    private static func createSubtitleLabel() -> UILabel {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = AppFont.with(type: .semibold , size: 10)
//        label.text = "Subtitle"
//        return label
//    }

    private static func createBetCardsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBetCardsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
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
        label.font = AppFont.with(type: .semibold , size: 12)
        label.text = "Total Odd"
        label.textAlignment = .center
        return label
    }

    private static func createTotalOddSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold , size: 12)
        label.text = "-.--"
        label.textAlignment = .center
        return label
    }

    private static func createBetAmountTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold , size: 12)
        label.text = "Bet Amount"
        label.textAlignment = .center
        return label
    }

    private static func createBetAmountSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold , size: 12)
        label.text = "-.--"
        label.textAlignment = .center
        return label
    }

    private static func createWinningsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold , size: 12)
        label.text = "Winnings"
        label.textAlignment = .center
        return label
    }

    private static func createWinningsSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold , size: 12)
        label.text = "-.--"
        label.textAlignment = .center
        return label
    }

    private func setupSubviews() {
        self.addSubview(self.baseView)

        self.baseView.addSubview(self.headerBaseView)

        self.headerBaseView.addSubview(self.titleLabel)
        // self.headerBaseView.addSubview(self.subtitleLabel)

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

            self.titleLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 10),
            self.titleLabel.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 14),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -14),

            self.betCardsBaseView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.betCardsBaseView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.betCardsBaseView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 14),
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

            self.bottomTitlesStackView.leadingAnchor.constraint(equalTo: self.bottomBaseView.leadingAnchor, constant: 10),
            self.bottomTitlesStackView.trailingAnchor.constraint(equalTo: self.bottomBaseView.trailingAnchor, constant: -10),
            self.bottomTitlesStackView.topAnchor.constraint(equalTo: self.bottomBaseView.topAnchor, constant: 5),
            self.bottomTitlesStackView.heightAnchor.constraint(equalToConstant: 25),

            self.bottomSeparatorLineView.leadingAnchor.constraint(equalTo: self.bottomBaseView.leadingAnchor, constant: 10),
            self.bottomSeparatorLineView.trailingAnchor.constraint(equalTo: self.bottomBaseView.trailingAnchor, constant: -10),
            self.bottomSeparatorLineView.topAnchor.constraint(equalTo: self.bottomTitlesStackView.bottomAnchor, constant: 2),
            self.bottomSeparatorLineView.heightAnchor.constraint(equalToConstant: 1),

            self.bottomSubtitlesStackView.leadingAnchor.constraint(equalTo: self.bottomBaseView.leadingAnchor, constant: 10),
            self.bottomSubtitlesStackView.trailingAnchor.constraint(equalTo: self.bottomBaseView.trailingAnchor, constant: -10),
            self.bottomSubtitlesStackView.topAnchor.constraint(equalTo: self.bottomSeparatorLineView.bottomAnchor, constant: 2),
            self.bottomSubtitlesStackView.bottomAnchor.constraint(equalTo: self.bottomBaseView.bottomAnchor, constant: -5),
            self.bottomSubtitlesStackView.heightAnchor.constraint(equalToConstant: 25)

        ])

    }
}
