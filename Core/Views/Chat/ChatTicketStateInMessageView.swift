//
//  ChatTicketStateInMessageView.swift
//  Sportsbook
//
//  Created by André Lascas on 28/06/2022.
//

import UIKit
import Combine

class ChatTicketStateInMessageView: UIView {

    // MARK: Private Properties
    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var topStateView: UIView = Self.createTopStateView()
    private lazy var ticketsStackView: UIStackView = Self.createTicketsStackView()
    private lazy var bottomStateView: UIView = Self.createBottomStateView()
    private lazy var bottomTitlesStackView: UIStackView = Self.createBottomTitlesStackView()
    private lazy var totalOddTitleLabel: UILabel = Self.createTotalOddTitleLabel()
    private lazy var betAmountTitleLabel: UILabel = Self.createBetAmountTitleLabel()
    private lazy var possibleWinningTitleLabel: UILabel = Self.createPossibleWinningTitleLabel()

    private lazy var bottomValuesStackView: UIStackView = Self.createBottomValuesStackView()
    private lazy var totalOddValueLabel: UILabel = Self.createTotalOddValueLabel()
    private lazy var betAmountValueLabel: UILabel = Self.createBetAmountValueLabel()
    private lazy var possibleWinningValueLabel: UILabel = Self.createPossibleWinningValueLabel()

    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()

    private var cancellables = Set<AnyCancellable>()

    private var betSelectionCellViewModel: BetSelectionCellViewModel

    // MARK: Public Properties
    var cardBackgroundColor: UIColor = .white {
        didSet {
            self.baseView.backgroundColor = self.cardBackgroundColor
        }
    }

    var betState: BetState = .draw {
        didSet {
            switch betState {
            case .won:
                self.topStateView.backgroundColor = UIColor.App.myTicketsWon
                self.bottomStateView.backgroundColor = UIColor.App.myTicketsWon
            case .lost:
                self.topStateView.backgroundColor = UIColor.App.myTicketsLost
                self.bottomStateView.backgroundColor = UIColor.App.myTicketsLost
            case .draw:
                self.topStateView.backgroundColor = UIColor.App.myTicketsOther
                self.bottomStateView.backgroundColor = UIColor.App.myTicketsOther
            }
        }
    }

    // MARK: Lifetime and Cycle
    init(betSelectionCellViewModel: BetSelectionCellViewModel) {
        self.betSelectionCellViewModel = betSelectionCellViewModel

        super.init(frame: .zero)
        self.commonInit()
    }

    @available(iOS, unavailable)
    override init(frame: CGRect) {
        fatalError()
    }

    @available(iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func commonInit() {
        self.setupSubviews()
        self.setupWithTheme()

        self.setupTicketStackView()

        if self.betSelectionCellViewModel.ticket.status == "WON" {
            self.betState = .won
        }
        else if self.betSelectionCellViewModel.ticket.status == "LOST" {
            self.betState = .lost
        }
        else {
            self.betState = .draw
        }

        self.totalOddValueLabel.text = self.betSelectionCellViewModel.oddValueString

        self.betAmountValueLabel.text = self.betSelectionCellViewModel.betAmountString

        self.possibleWinningValueLabel.text = self.betSelectionCellViewModel.possibleWinningString

    }

    override func layoutSubviews() {
        super.layoutSubviews()

    }

    // MARK: Layout and Theme
    func setupWithTheme() {

        self.backgroundColor = .clear

        self.baseView.backgroundColor = UIColor.App.backgroundSecondary

        self.topStateView.backgroundColor = UIColor.App.backgroundSecondary

        self.ticketsStackView.backgroundColor = .clear
        self.separatorLineView.backgroundColor = .white

        self.bottomStateView.backgroundColor = UIColor.App.backgroundSecondary

        self.bottomTitlesStackView.backgroundColor = .clear
        self.totalOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
        self.betAmountTitleLabel.textColor = UIColor.App.buttonTextPrimary
        self.possibleWinningTitleLabel.textColor = UIColor.App.buttonTextPrimary

        self.bottomValuesStackView.backgroundColor = .clear
        self.totalOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        self.betAmountValueLabel.textColor = UIColor.App.buttonTextPrimary
        self.possibleWinningValueLabel.textColor = UIColor.App.buttonTextPrimary

    }

    func setupTicketStackView() {
        self.ticketsStackView.removeAllArrangedSubviews()

        for selection in self.betSelectionCellViewModel.betSelections() {
            let ticketView = ChatTicketSelectionView(betHistoryEntrySelection: selection, hasBetStatus: true)
            self.ticketsStackView.addArrangedSubview(ticketView)
        }

        self.ticketsStackView.layoutIfNeeded()
    }

}

extension ChatTicketStateInMessageView {

    private static func createBaseView() -> UIView {
        let baseView = UIView()
        baseView.translatesAutoresizingMaskIntoConstraints = false
        baseView.layer.cornerRadius = CornerRadius.view
        baseView.layer.masksToBounds = true
        baseView.clipsToBounds = true
        return baseView
    }

    private static func createTopStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTicketsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .equalSpacing
        return stackView
    }

    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomTitlesStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }

    private static func createTotalOddTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Total Odd"
        label.font = AppFont.with(type: .semibold, size: 10)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }

    private static func createBetAmountTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Bet Amount"
        label.font = AppFont.with(type: .semibold, size: 10)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }

    private static func createPossibleWinningTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Possible Winning"
        label.font = AppFont.with(type: .semibold, size: 10)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }

    private static func createBottomValuesStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }

    private static func createTotalOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "--"
        label.font = AppFont.with(type: .semibold, size: 13)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }

    private static func createBetAmountValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "--"
        label.font = AppFont.with(type: .semibold, size: 13)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }

    private static func createPossibleWinningValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "--"
        label.font = AppFont.with(type: .semibold, size: 13)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }

    private func setupSubviews() {

        self.addSubview(self.baseView)

        self.baseView.addSubview(self.topStateView)

        self.baseView.addSubview(self.ticketsStackView)

        self.baseView.addSubview(self.bottomStateView)

        self.bottomStateView.addSubview(self.bottomTitlesStackView)
        self.bottomTitlesStackView.addArrangedSubview(self.totalOddTitleLabel)
        self.bottomTitlesStackView.addArrangedSubview(self.betAmountTitleLabel)
        self.bottomTitlesStackView.addArrangedSubview(self.possibleWinningTitleLabel)

        self.bottomStateView.addSubview(self.separatorLineView)

        self.bottomStateView.addSubview(self.bottomValuesStackView)
        self.bottomValuesStackView.addArrangedSubview(self.totalOddValueLabel)
        self.bottomValuesStackView.addArrangedSubview(self.betAmountValueLabel)
        self.bottomValuesStackView.addArrangedSubview(self.possibleWinningValueLabel)

        self.initConstraints()

    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.baseView.heightAnchor.constraint(greaterThanOrEqualToConstant: 140),
            self.baseView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.baseView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            self.baseView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2),
            self.baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2),

            self.topStateView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.topStateView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.topStateView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.topStateView.heightAnchor.constraint(equalToConstant: 6),
        ])

        // Stackview
        NSLayoutConstraint.activate([
            self.ticketsStackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 15),
            self.ticketsStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -15),
            self.ticketsStackView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 15),
            self.ticketsStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])

        // Bottom part
        NSLayoutConstraint.activate([
            self.bottomStateView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.bottomStateView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.bottomStateView.topAnchor.constraint(equalTo: self.ticketsStackView.bottomAnchor),
            self.bottomStateView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),
            self.bottomStateView.heightAnchor.constraint(equalToConstant: 60),

            self.bottomTitlesStackView.leadingAnchor.constraint(equalTo: self.bottomStateView.leadingAnchor, constant: 10),
            self.bottomTitlesStackView.trailingAnchor.constraint(equalTo: self.bottomStateView.trailingAnchor, constant: -10),
            self.bottomTitlesStackView.topAnchor.constraint(equalTo: self.bottomStateView.topAnchor),
            self.bottomTitlesStackView.heightAnchor.constraint(equalToConstant: 29),

            self.separatorLineView.leadingAnchor.constraint(equalTo: self.bottomStateView.leadingAnchor, constant: 10),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.bottomStateView.trailingAnchor, constant: -10),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),
            self.separatorLineView.topAnchor.constraint(equalTo: self.bottomTitlesStackView.bottomAnchor, constant: 1),

            self.bottomValuesStackView.leadingAnchor.constraint(equalTo: self.bottomStateView.leadingAnchor, constant: 10),
            self.bottomValuesStackView.trailingAnchor.constraint(equalTo: self.bottomStateView.trailingAnchor, constant: -10),
            self.bottomValuesStackView.topAnchor.constraint(equalTo: self.separatorLineView.bottomAnchor, constant: 1),
            self.bottomValuesStackView.heightAnchor.constraint(equalToConstant: 29)
        ])

    }

}
