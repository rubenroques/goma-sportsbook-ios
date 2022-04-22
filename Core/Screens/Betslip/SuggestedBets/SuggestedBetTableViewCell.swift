//
//  SuggestedBetTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/04/2022.
//

import UIKit
import Combine

class SuggestedBetCellViewModel {

}

class SuggestedBetTableViewCell: UITableViewCell {

    //
    // MARK: Public Properties
    var betNowCallbackAction: (() -> Void)?
    var needsReloadCallbackAction: (() -> Void)?

    //
    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()

    private lazy var topBaseView: UIView = Self.createTopBaseView()
    private lazy var ticketsStackView: UIStackView = Self.createTicketsStackView()

    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()
    private lazy var bottomBaseView: UIView = Self.createBottomBaseView()
    private lazy var infoLabelsStackView: UIStackView = Self.createInfoLabelsStackView()

    private lazy var topInfoLabelsBaseView: UIView = Self.createTopInfoLabelsBaseView()
    private lazy var bottomInfoLabelsBaseView: UIView = Self.createBottomInfoLabelsBaseView()

    private lazy var numberOfSelectionsLabel: UILabel = Self.createNumberOfSelectionsLabel()
    private lazy var numberOfSelectionsValueLabel: UILabel = Self.createNumberOfSelectionsValueLabel()
    private lazy var totalOddLabel: UILabel = Self.createTotalOddLabel()
    private lazy var totalOddValueLabel: UILabel = Self.createTotalOddValueLabel()

    private lazy var placeBetButton: UIButton = Self.createPlaceBetButton()

    private var cancellables = Set<AnyCancellable>()
    private var viewModel: SuggestedBetViewModel?

    //
    // MARK: Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.placeBetButton.addTarget(self, action: #selector(didTapPlaceBetButton), for: .primaryActionTriggered)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Cell clear for reuse
    override func prepareForReuse() {
        super.prepareForReuse()

        self.setupWithTheme()
    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

        self.numberOfSelectionsLabel.textColor = UIColor.App.textPrimary
        self.numberOfSelectionsValueLabel.textColor = UIColor.App.textPrimary
        self.totalOddLabel.textColor = UIColor.App.textPrimary
        self.totalOddValueLabel.textColor = UIColor.App.textPrimary

        StyleHelper.styleButton(button: self.placeBetButton)
    }

    func setupWithViewModel(viewModel: SuggestedBetViewModel) {
        self.viewModel = viewModel

        self.viewModel?.isViewModelFinishedLoading
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                if value {
                    self?.setupStackBetView()
                }
            })
            .store(in: &cancellables)
    }

    func setupStackBetView() {

        guard let viewModel = self.viewModel else {
            return
        }

        self.ticketsStackView.removeAllArrangedSubviews()

        for gameSuggestedView in viewModel.gameSuggestedViewsArray {
            self.ticketsStackView.addArrangedSubview(gameSuggestedView)
        }

        self.setupInfoBetValues(totalOdd: viewModel.totalOdd, numberOfSelection: viewModel.numberOfSelection)

        if !viewModel.reloadedState {
            self.needsReloadCallbackAction?()
        }
    }

    func setupInfoBetValues(totalOdd: Double, numberOfSelection: Int) {
        let formatedOdd = OddConverter.stringForValue(totalOdd, format: UserDefaults.standard.userOddsFormat)
        totalOddValueLabel.text = "\(formatedOdd)"
        numberOfSelectionsValueLabel.text = "\(numberOfSelection)"
     }

    @objc private func didTapPlaceBetButton() {

        guard let viewModel = self.viewModel else {
            return
        }

        for ticket in viewModel.betslipTickets {
            Env.betslipManager.addBettingTicket(ticket)
        }

        self.betNowCallbackAction?()
    }

}


// MARK: - Subviews initialization and setup
extension SuggestedBetTableViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        return view
    }

    private static func createTopBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTicketsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        return stackView
    }

    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createInfoLabelsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        return stackView
    }

    private static func createTopInfoLabelsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNumberOfSelectionsLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 12)
        label.text = "Number of Selections:"
        return label
    }
    private static func createNumberOfSelectionsValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.text = "-"
        return label
    }
    private static func createTotalOddLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 12)
        label.text = "Total Odd:"
        return label
    }
    private static func createTotalOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.text = "-"
        return label
    }

    private static func createBottomInfoLabelsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createPlaceBetButton() -> UIButton {
        let placeBetButton = UIButton()
        placeBetButton.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        placeBetButton.translatesAutoresizingMaskIntoConstraints = false
        placeBetButton.setTitle("Bet now", for: .normal)
        return placeBetButton
    }

    private func setupSubviews() {
        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.topBaseView)
        self.topBaseView.addSubview(self.ticketsStackView)

        self.containerView.addSubview(self.separatorLineView)

        self.containerView.addSubview(self.bottomBaseView)
        self.bottomBaseView.addSubview(self.infoLabelsStackView)
        self.bottomBaseView.addSubview(self.placeBetButton)

        self.infoLabelsStackView.addArrangedSubview(self.topInfoLabelsBaseView)
        self.infoLabelsStackView.addArrangedSubview(self.bottomInfoLabelsBaseView)

        self.topInfoLabelsBaseView.addSubview(self.numberOfSelectionsLabel)
        self.topInfoLabelsBaseView.addSubview(self.numberOfSelectionsValueLabel)

        self.bottomInfoLabelsBaseView.addSubview(self.totalOddLabel)
        self.bottomInfoLabelsBaseView.addSubview(self.totalOddValueLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 12),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -12),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),

            self.containerView.leadingAnchor.constraint(equalTo: self.topBaseView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.topBaseView.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topBaseView.topAnchor),
            self.topBaseView.heightAnchor.constraint(equalToConstant: 240),

            self.separatorLineView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -12),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),

            self.separatorLineView.topAnchor.constraint(equalTo: self.topBaseView.bottomAnchor),
            self.bottomBaseView.topAnchor.constraint(equalTo: self.separatorLineView.bottomAnchor),

            self.containerView.leadingAnchor.constraint(equalTo: self.bottomBaseView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.bottomBaseView.trailingAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomBaseView.bottomAnchor),
            self.bottomBaseView.heightAnchor.constraint(equalToConstant: 60),

            self.ticketsStackView.leadingAnchor.constraint(equalTo: self.topBaseView.leadingAnchor),
            self.ticketsStackView.trailingAnchor.constraint(equalTo: self.topBaseView.trailingAnchor),
            self.ticketsStackView.topAnchor.constraint(equalTo: self.topBaseView.topAnchor),
            self.ticketsStackView.bottomAnchor.constraint(equalTo: self.topBaseView.bottomAnchor),

            self.infoLabelsStackView.leadingAnchor.constraint(equalTo: self.bottomBaseView.leadingAnchor),
            self.infoLabelsStackView.topAnchor.constraint(equalTo: self.bottomBaseView.topAnchor, constant: 4),
            self.infoLabelsStackView.bottomAnchor.constraint(equalTo: self.bottomBaseView.bottomAnchor, constant: -4),
            self.infoLabelsStackView.trailingAnchor.constraint(equalTo: self.placeBetButton.leadingAnchor, constant: 12),

            self.placeBetButton.centerYAnchor.constraint(equalTo: self.bottomBaseView.centerYAnchor),
            self.placeBetButton.trailingAnchor.constraint(equalTo: self.bottomBaseView.trailingAnchor, constant: -12),
            self.placeBetButton.widthAnchor.constraint(equalToConstant: 80),
            self.placeBetButton.heightAnchor.constraint(equalToConstant: 35),

            self.numberOfSelectionsLabel.leadingAnchor.constraint(equalTo: self.topInfoLabelsBaseView.leadingAnchor, constant: 12),
            self.numberOfSelectionsLabel.centerYAnchor.constraint(equalTo: self.topInfoLabelsBaseView.centerYAnchor),
            self.numberOfSelectionsValueLabel.leadingAnchor.constraint(equalTo: self.numberOfSelectionsLabel.trailingAnchor, constant: 5),
            self.numberOfSelectionsValueLabel.centerYAnchor.constraint(equalTo: self.topInfoLabelsBaseView.centerYAnchor),

            self.totalOddLabel.leadingAnchor.constraint(equalTo: self.bottomInfoLabelsBaseView.leadingAnchor, constant: 12),
            self.totalOddLabel.centerYAnchor.constraint(equalTo: self.bottomInfoLabelsBaseView.centerYAnchor),
            self.totalOddValueLabel.leadingAnchor.constraint(equalTo: self.totalOddLabel.trailingAnchor, constant: 5),
            self.totalOddValueLabel.centerYAnchor.constraint(equalTo: self.bottomInfoLabelsBaseView.centerYAnchor),
     ])

    }

}
