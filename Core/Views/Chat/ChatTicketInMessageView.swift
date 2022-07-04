//
//  ChatTicketInMessageView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 26/05/2022.
//

import UIKit
import Combine

class ChatTicketInMessageView: UIView {

    var didTapBetNowAction: ((BetSelectionCellViewModel) -> Void) = { _ in }

    // MARK: Private Properties
    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var ticketsStackView: UIStackView = Self.createTicketsStackView()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()
    private lazy var totalOddTitleLabel: UILabel = Self.createTotalOddTitleLabel()
    private lazy var totalOddValueLabel: UILabel = Self.createTotalOddValueLabel()
    private lazy var betNowButton: UIButton = Self.createBetNowButton()

    private var cancellables = Set<AnyCancellable>()

    private var shouldShowButton: Bool
    private var betSelectionCellViewModel: BetSelectionCellViewModel

    var cardBackgroundColor: UIColor = .white {
        didSet {
            self.baseView.backgroundColor = self.cardBackgroundColor
        }
    }

    // MARK: Lifetime and Cycle
    init(betSelectionCellViewModel: BetSelectionCellViewModel, shouldShowButton: Bool) {
        self.betSelectionCellViewModel = betSelectionCellViewModel
        self.shouldShowButton = shouldShowButton
        
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

        self.betNowButton.addTarget(self, action: #selector(self.didTapBetNowButton), for: .primaryActionTriggered)

        self.totalOddValueLabel.text = self.betSelectionCellViewModel.oddValueString

        if !shouldShowButton {
            self.betNowButton.isHidden = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

    }

    // MARK: Layout and Theme
    func setupWithTheme() {

        self.backgroundColor = .clear

        self.baseView.backgroundColor = UIColor.App.backgroundSecondary

        self.ticketsStackView.backgroundColor = .clear
        self.separatorLineView.backgroundColor = UIColor.App.buttonTextPrimary

        self.totalOddTitleLabel.textColor = UIColor.App.textSecondary
        self.totalOddValueLabel.textColor = UIColor.App.textPrimary

        self.betNowButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.betNowButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.betNowButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.39), for: .disabled)

        self.betNowButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary, for: .normal)
        self.betNowButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary.withAlphaComponent(0.7), for: .highlighted)

    }

    func setupTicketStackView() {
        self.ticketsStackView.removeAllArrangedSubviews()

        for selection in self.betSelectionCellViewModel.betSelections() {
            let ticketView = ChatTicketSelectionView(betHistoryEntrySelection: selection)
            self.ticketsStackView.addArrangedSubview(ticketView)
        }

        self.ticketsStackView.layoutIfNeeded()
    }

    @objc func didTapBetNowButton() {
        self.didTapBetNowAction(self.betSelectionCellViewModel)
    }

}

extension ChatTicketInMessageView {

    private static func createBaseView() -> UIView {
        let baseView = UIView()
        baseView.translatesAutoresizingMaskIntoConstraints = false
        baseView.layer.cornerRadius = CornerRadius.view
        baseView.layer.masksToBounds = true
        baseView.clipsToBounds = true
        return baseView
    }

    private static func createCheckboxBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCheckboxImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "checkbox_unselected_icon")
        imageView.contentMode = .scaleToFill
        return imageView
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

    private static func createTotalOddTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Total Odd: "
        label.font = AppFont.with(type: .bold, size: 12)
        label.numberOfLines = 1
        return label
    }

    private static func createTotalOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "--"
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }

    private static func createBetNowButton() -> UIButton {
        let button = UIButton.init(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        button.setTitle("Bet Now", for: .normal)
        button.setBackgroundColor(UIColor.App.backgroundOdds, for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 13)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        return button
    }

    private func setupSubviews() {

        self.addSubview(self.baseView)

        self.baseView.addSubview(self.ticketsStackView)
        self.baseView.addSubview(self.separatorLineView)
        self.baseView.addSubview(self.totalOddTitleLabel)
        self.baseView.addSubview(self.totalOddValueLabel)
        self.baseView.addSubview(self.betNowButton)

        self.initConstraints()

    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.baseView.heightAnchor.constraint(greaterThanOrEqualToConstant: 140),
            self.baseView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.baseView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            self.baseView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2),
            self.baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2),
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
            self.separatorLineView.leadingAnchor.constraint(equalTo: self.ticketsStackView.leadingAnchor),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -10),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),
            self.separatorLineView.topAnchor.constraint(equalTo: self.ticketsStackView.bottomAnchor, constant: 10),

            self.totalOddTitleLabel.heightAnchor.constraint(equalToConstant: 40),
            self.totalOddTitleLabel.leadingAnchor.constraint(equalTo: self.separatorLineView.leadingAnchor),
            self.totalOddTitleLabel.topAnchor.constraint(equalTo: self.separatorLineView.bottomAnchor),
            self.totalOddTitleLabel.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),

            self.totalOddValueLabel.leadingAnchor.constraint(equalTo: self.totalOddTitleLabel.trailingAnchor, constant: 5),
            self.totalOddValueLabel.centerYAnchor.constraint(equalTo: self.totalOddTitleLabel.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            self.betNowButton.heightAnchor.constraint(equalToConstant: 28),
            self.betNowButton.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -10),
            self.betNowButton.centerYAnchor.constraint(equalTo: self.totalOddTitleLabel.centerYAnchor),
        ])
    }

}
