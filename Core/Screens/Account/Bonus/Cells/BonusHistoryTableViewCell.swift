//
//  BonusHistoryTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 03/03/2022.
//

import UIKit
import Combine

class BonusHistoryTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var startDateDescriptionLabel: UILabel = Self.createStartDateDescriptionLabel()
    private lazy var startDateLabel: UILabel = Self.createStartDateLabel()
    private lazy var endDateDescriptionLabel: UILabel = Self.createEndDateDescriptionLabel()
    private lazy var endDateLabel: UILabel = Self.createEndDateLabel()
    private lazy var bonusStatusView: UIView = Self.createBonusStatusView()
    private lazy var bonusStatusLabel: UILabel = Self.createBonusStatusLabel()
    private lazy var bonusLabel: UILabel = Self.createBonusLabel()
    private lazy var bonusAmountLabel: UILabel = Self.createBonusAmountLabel()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {

        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.startDateDescriptionLabel.textColor = UIColor.App.textPrimary
        self.startDateLabel.textColor = UIColor.App.textSecondary

        self.endDateDescriptionLabel.textColor = UIColor.App.textPrimary
        self.endDateLabel.textColor = UIColor.App.textSecondary

        self.bonusLabel.textColor = UIColor.App.textPrimary
        self.bonusAmountLabel.textColor = UIColor.App.textSecondary

        self.bonusStatusView.backgroundColor = UIColor.App.backgroundOdds

        self.bonusStatusLabel.textColor = UIColor.App.textPrimary
    }

    func configure(withViewModel viewModel: BonusHistoryCellViewModel) {

        viewModel.titlePublisher
            .sink(receiveValue: { [weak self] title in
                self?.titleLabel.text = title
            })
            .store(in: &cancellables)

        viewModel.startDateStringPublisher
            .sink(receiveValue: { [weak self] startDateString in
                self?.startDateLabel.text = startDateString
            })
            .store(in: &cancellables)

        viewModel.endDateStringPublisher
            .sink(receiveValue: { [weak self] endDateString in
                self?.endDateLabel.text = endDateString
            })
            .store(in: &cancellables)

        viewModel.bonusValuePublisher
            .sink(receiveValue: { [weak self] bonusValue in
                self?.bonusAmountLabel.text = bonusValue
            })
            .store(in: &cancellables)

        viewModel.bonusStatusPublisher
            .sink(receiveValue: { [weak self] bonusStatus in
                self?.bonusStatusLabel.text = bonusStatus
            })
            .store(in: &cancellables)
    }

}

//
// MARK: Subviews initialization and setup
//
extension BonusHistoryTableViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.button
        view.layer.masksToBounds = true
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title here"
        label.numberOfLines = 0
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }

    private static func createStartDateDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(localized("start_date")):"
        label.font = AppFont.with(type: .medium, size: 11)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }

    private static func createStartDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "01.01.0101"
        label.font = AppFont.with(type: .medium, size: 11)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }

    private static func createEndDateDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(localized("expire_date")):"
        label.font = AppFont.with(type: .medium, size: 11)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }

    private static func createEndDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "01.01.0101"
        label.font = AppFont.with(type: .medium, size: 11)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }

    private static func createBonusStatusView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.layer.cornerRadius = CornerRadius.label
        return view
    }

    private static func createBonusStatusLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Status"
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 11)
        return label
    }

    private static func createBonusLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(localized("bonus")):"
        label.font = AppFont.with(type: .medium, size: 11)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }

    private static func createBonusAmountLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0.0"
        label.font = AppFont.with(type: .medium, size: 11)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }

    private func setupSubviews() {
        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.startDateDescriptionLabel)
        self.containerView.addSubview(self.startDateLabel)
        self.containerView.addSubview(self.endDateDescriptionLabel)
        self.containerView.addSubview(self.endDateLabel)
        self.containerView.addSubview(self.bonusStatusView)
        self.containerView.addSubview(self.bonusLabel)
        self.containerView.addSubview(self.bonusAmountLabel)

        self.bonusStatusView.addSubview(self.bonusStatusLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 25),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -25),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8)

        ])

        // Labels
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            // self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 20),

            self.startDateDescriptionLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.startDateDescriptionLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 12),

            self.startDateLabel.leadingAnchor.constraint(equalTo: self.startDateDescriptionLabel.trailingAnchor, constant: 4),
            self.startDateLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.startDateLabel.centerYAnchor.constraint(equalTo: self.startDateDescriptionLabel.centerYAnchor),

            self.endDateDescriptionLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.endDateDescriptionLabel.topAnchor.constraint(equalTo: self.startDateDescriptionLabel.bottomAnchor, constant: 12),
            self.endDateDescriptionLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20),

            self.endDateLabel.leadingAnchor.constraint(equalTo: self.endDateDescriptionLabel.trailingAnchor, constant: 4),
            self.endDateLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.endDateLabel.centerYAnchor.constraint(equalTo: self.endDateDescriptionLabel.centerYAnchor),

            self.bonusLabel.centerYAnchor.constraint(equalTo: self.bonusAmountLabel.centerYAnchor),

            self.bonusAmountLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.bonusAmountLabel.leadingAnchor.constraint(equalTo: self.bonusLabel.trailingAnchor, constant: 4),
            self.bonusAmountLabel.centerYAnchor.constraint(equalTo: self.endDateDescriptionLabel.centerYAnchor)
        ])

        // Bonus status
        NSLayoutConstraint.activate([
            self.bonusStatusView.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 8),
            self.bonusStatusView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.bonusStatusView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 10),
            self.bonusStatusView.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            self.bonusStatusView.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),

            self.bonusStatusLabel.leadingAnchor.constraint(equalTo: self.bonusStatusView.leadingAnchor, constant: 8),
            self.bonusStatusLabel.trailingAnchor.constraint(equalTo: self.bonusStatusView.trailingAnchor, constant: -8),
            self.bonusStatusLabel.centerYAnchor.constraint(equalTo: self.bonusStatusView.centerYAnchor)
        ])
    }

}
