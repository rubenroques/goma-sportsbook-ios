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
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
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

//        self.setupSubviews()
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

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold , size: 10)
        label.text = "Subtitle"
        return label
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
        return label
    }

    private static func createTotalOddSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold , size: 12)
        label.text = "-.--"
        return label
    }

    private static func createBetAmountTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold , size: 12)
        label.text = "Bet Amount"
        return label
    }

    private static func createBetAmountSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold , size: 12)
        label.text = "-.--"
        return label
    }

    private static func createWinningsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold , size: 12)
        label.text = "Winnings"
        return label
    }

    private static func createWinningsSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold , size: 12)
        label.text = "-.--"
        return label
    }

    private func setupSubviews() {
        self.addSubview(self.baseView)

        self.baseView.addSubview(self.headerBaseView)

        self.headerBaseView.addSubview(self.titleLabel)
        self.headerBaseView.addSubview(self.subtitleLabel)

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

    }
}
