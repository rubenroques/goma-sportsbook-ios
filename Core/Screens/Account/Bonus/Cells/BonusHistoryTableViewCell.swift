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
    private lazy var startDateIconImageView: UIImageView = Self.createStartDateIconImageView()
    private lazy var startDateLabel: UILabel = Self.createStartDateLabel()
    private lazy var endDateIconImageView: UIImageView = Self.createEndDateIconImageView()
    private lazy var endDateLabel: UILabel = Self.createEndDateLabel()
    private lazy var bonusStatusView: UIView = Self.createBonusStatusView()
    private lazy var bonusStatusIconImageView: UIImageView = Self.createBonusStatusIconImageView()
    private lazy var bonusStatusLabel: UILabel = Self.createBonusStatusLabel()

    private lazy var separatorView: UIView = Self.createSeparatorView()

    private lazy var bonusIconImageView: UIImageView = Self.createBonusIconImageView()
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

    override func layoutSubviews() {
        super.layoutSubviews()

        self.bonusStatusView.clipsToBounds = true
        self.bonusStatusView.layer.cornerRadius = CornerRadius.status
        self.bonusStatusView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    }

    private func setupWithTheme() {

        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.startDateLabel.textColor = UIColor.App.textSecondary

        self.endDateLabel.textColor = UIColor.App.textSecondary

        self.bonusAmountLabel.textColor = UIColor.App.textSecondary

        self.bonusStatusView.backgroundColor = UIColor.App.iconSecondary

        self.bonusStatusLabel.textColor = UIColor.App.buttonTextPrimary

        self.separatorView.backgroundColor = UIColor.App.separatorLine

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
                self?.bonusAmountLabel.text = "\(bonusValue)\(Env.userSessionStore.userProfilePublisher.value?.currency ?? "")"
            })
            .store(in: &cancellables)

        viewModel.bonusStatusPublisher
            .sink(receiveValue: { [weak self] bonusStatus in
                self?.bonusStatusLabel.text = bonusStatus

                switch viewModel.bonusType {
                case .expired:
                    self?.bonusStatusView.backgroundColor = UIColor.App.alertWarning
                    self?.bonusStatusIconImageView.image = UIImage(named: "bell_expired_icon")
                case .cancelled:
                    self?.bonusStatusView.backgroundColor = UIColor.App.alertError
                    self?.bonusStatusIconImageView.image = UIImage(named: "x_circle_icon")
                case .released:
                    self?.bonusStatusView.backgroundColor = UIColor.App.iconSecondary
                    self?.bonusStatusIconImageView.image = UIImage(named: "prohibit_icon")
                default:
                    self?.bonusStatusView.backgroundColor = UIColor.App.iconSecondary
                    self?.bonusStatusIconImageView.image = UIImage(named: "prohibit_icon")
                }

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
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return label
    }

    private static func createStartDateIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "calendar_check_icon")
        return imageView
    }

    private static func createStartDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "01.01.0101"
        label.font = AppFont.with(type: .medium, size: 11)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }

    private static func createEndDateIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "calendar_expired_icon")
        return imageView
    }

    private static func createEndDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "01.01.0101"
        label.font = AppFont.with(type: .medium, size: 11)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }

    private static func createBonusStatusView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        view.layer.cornerRadius = CornerRadius.label
        return view
    }

    private static func createBonusStatusIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "check_circle_icon")
        return imageView
    }

    private static func createBonusStatusLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Status"
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 11)
        return label
    }

    private static func createBonusIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "cardholder_icon")
        return imageView
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

    private static func createSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {
        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.startDateIconImageView)
        self.containerView.addSubview(self.startDateLabel)
        self.containerView.addSubview(self.endDateIconImageView)
        self.containerView.addSubview(self.endDateLabel)
        self.contentView.addSubview(self.bonusStatusView)
        self.containerView.addSubview(self.bonusIconImageView)
        self.containerView.addSubview(self.bonusAmountLabel)

        self.bonusStatusView.addSubview(self.bonusStatusIconImageView)
        self.bonusStatusView.addSubview(self.bonusStatusLabel)

        self.containerView.addSubview(self.separatorView)

        self.initConstraints()

        self.bonusStatusView.setNeedsLayout()
        self.bonusStatusView.layoutIfNeeded()
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
            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 11),

            self.separatorView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.separatorView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -12),
            self.separatorView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 12),
            self.separatorView.heightAnchor.constraint(equalToConstant: 1),

            self.startDateIconImageView.leadingAnchor.constraint(equalTo: self.separatorView.leadingAnchor),
            self.startDateIconImageView.topAnchor.constraint(equalTo: self.separatorView.bottomAnchor, constant: 10),
            self.startDateIconImageView.widthAnchor.constraint(equalToConstant: 12),
            self.startDateIconImageView.heightAnchor.constraint(equalToConstant: 13),

            self.startDateLabel.leadingAnchor.constraint(equalTo: self.startDateIconImageView.trailingAnchor, constant: 4),
            self.startDateLabel.centerYAnchor.constraint(equalTo: self.startDateIconImageView.centerYAnchor),
            self.startDateLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -11),

            self.endDateIconImageView.leadingAnchor.constraint(equalTo: self.startDateLabel.trailingAnchor, constant: 20),
            self.endDateIconImageView.centerYAnchor.constraint(equalTo: self.startDateIconImageView.centerYAnchor),
            self.endDateIconImageView.widthAnchor.constraint(equalToConstant: 12),
            self.endDateIconImageView.heightAnchor.constraint(equalToConstant: 13),

            self.endDateLabel.leadingAnchor.constraint(equalTo: self.endDateIconImageView.trailingAnchor, constant: 4),
            self.endDateLabel.centerYAnchor.constraint(equalTo: self.startDateLabel.centerYAnchor),

            self.bonusIconImageView.leadingAnchor.constraint(equalTo: self.endDateLabel.trailingAnchor, constant: 20),
            self.bonusIconImageView.centerYAnchor.constraint(equalTo: self.endDateIconImageView.centerYAnchor),
            self.bonusIconImageView.widthAnchor.constraint(equalToConstant: 12),
            self.bonusIconImageView.heightAnchor.constraint(equalToConstant: 13),

            self.bonusAmountLabel.leadingAnchor.constraint(equalTo: self.bonusIconImageView.trailingAnchor, constant: 4),
            self.bonusAmountLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -12),
            self.bonusAmountLabel.centerYAnchor.constraint(equalTo: self.endDateLabel.centerYAnchor)
        ])

        // Bonus status
        NSLayoutConstraint.activate([
            self.bonusStatusView.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 8),
            self.bonusStatusView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: 2),
            self.bonusStatusView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 11),

            self.bonusStatusIconImageView.leadingAnchor.constraint(equalTo: self.bonusStatusView.leadingAnchor, constant: 8),
            self.bonusStatusIconImageView.widthAnchor.constraint(equalToConstant: 15),
            self.bonusStatusIconImageView.heightAnchor.constraint(equalTo: self.bonusStatusIconImageView.widthAnchor),
            self.bonusStatusIconImageView.topAnchor.constraint(equalTo: self.bonusStatusView.topAnchor, constant: 4),
            self.bonusStatusIconImageView.bottomAnchor.constraint(equalTo: self.bonusStatusView.bottomAnchor, constant: -4),

            self.bonusStatusLabel.leadingAnchor.constraint(equalTo: self.bonusStatusIconImageView.trailingAnchor, constant: 4),
            self.bonusStatusLabel.trailingAnchor.constraint(equalTo: self.bonusStatusView.trailingAnchor, constant: -8),
            self.bonusStatusLabel.centerYAnchor.constraint(equalTo: self.bonusStatusIconImageView.centerYAnchor)
        ])
    }

}
