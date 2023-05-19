//
//  BonusActiveTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 03/03/2022.
//

import UIKit
import Combine

class BonusActiveTableViewCell: UITableViewCell {
    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var dateIconImageView: UIImageView = Self.createDateIconImageView()
    private lazy var dateLabel: UILabel = Self.createDateLabel()
    private lazy var bonusIconImageView: UIImageView = Self.createBonusIconImageView()
    private lazy var bonusLabel: UILabel = Self.createBonusLabel()
    private lazy var bonusStatusView: UIView = Self.createBonusStatusView()
    private lazy var bonusStatusIconImageView: UIImageView = Self.createBonusStatusIconImageView()
    private lazy var bonusStatusLabel: UILabel = Self.createBonusStatusLabel()
    private lazy var stackView: UIStackView = Self.createStackView()
    private lazy var cancelButton: UIButton = Self.createCancelButton()

    private lazy var separatorView: UIView = Self.createSeparatorView()

    private lazy var stackViewBottomConstraint: NSLayoutConstraint = Self.createStackViewBottomConstraint()
    private lazy var cancelButtonBottomConstraint: NSLayoutConstraint = Self.createCancelButtonBottomConstraint()
    private lazy var titleTrailingConstraint: NSLayoutConstraint = Self.createTitleTrailingConstraint()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var hasBonusAmount: Bool = false {
        didSet {
            self.stackView.isHidden = !hasBonusAmount
        }
    }

    var isSimpleBonus: Bool = false {
        didSet {
            self.bonusStatusIconImageView.isHidden = !isSimpleBonus
            self.bonusLabel.isHidden = !isSimpleBonus
        }
    }

    var hasTypeStatus: Bool = false {
        didSet {
            self.bonusStatusView.isHidden = !hasTypeStatus

            self.titleTrailingConstraint.isActive = !hasTypeStatus
        }
    }

    var hasCancelButton: Bool = true {
        didSet {
            self.cancelButton.isHidden = !hasCancelButton

            self.stackViewBottomConstraint.isActive = !hasCancelButton

            self.cancelButtonBottomConstraint.isActive = hasCancelButton
        }
    }

    var viewModel: BonusActiveCellViewModel?

    // MARK: Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .primaryActionTriggered)

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
        self.cancelButton.layer.cornerRadius = CornerRadius.button
        self.cancelButton.layer.borderWidth = 2
        self.cancelButton.layer.masksToBounds = true

        self.bonusStatusView.clipsToBounds = true
        self.bonusStatusView.layer.cornerRadius = CornerRadius.status
        self.bonusStatusView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    }

    private func setupWithTheme() {

        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.titleLabel.textColor = UIColor.App.highlightPrimary

        self.dateLabel.textColor = UIColor.App.textSecondary

        self.bonusLabel.textColor = UIColor.App.textSecondary

        self.bonusStatusView.backgroundColor = UIColor.App.iconSecondary

        self.bonusStatusLabel.textColor = UIColor.App.buttonTextPrimary

        self.separatorView.backgroundColor = UIColor.App.separatorLine

        self.stackView.backgroundColor = UIColor.App.backgroundSecondary

        self.cancelButton.backgroundColor = .clear
        self.cancelButton.layer.borderColor = UIColor.App.buttonActiveHoverSecondary.cgColor
        self.cancelButton.setTitleColor(UIColor.App.textPrimary, for: .normal)

    }

    func configure(withViewModel viewModel: BonusActiveCellViewModel) {

        self.viewModel = viewModel

        viewModel.titlePublisher
            .sink(receiveValue: { [weak self] title in
                self?.titleLabel.text = title
            })
            .store(in: &cancellables)

        viewModel.dateStringPublisher
            .sink(receiveValue: { [weak self] dateString in
                self?.dateLabel.text = dateString
            })
            .store(in: &cancellables)

        viewModel.hasBonusAmountPublisher
            .sink(receiveValue: { [weak self] hasBonus in
                if hasBonus {
                    self?.stackView.removeAllArrangedSubviews()

                    self?.setupProgressBars(bonus: viewModel.bonus)

                }
                else {
                    self?.stackView.removeAllArrangedSubviews()

                    self?.setupEmptyBonus()
                }
            })
            .store(in: &cancellables)

        let bonusStatus = viewModel.bonus.status

        if bonusStatus == "ACTIVE" {
            self.hasTypeStatus = false
            self.hasCancelButton = true
        }
        else if bonusStatus == "QUEUED" {
            self.hasTypeStatus = true
            self.hasCancelButton = true
            self.bonusStatusLabel.text = BonusTypeMapper.init(bonusType: bonusStatus)?.bonusName ?? bonusStatus.capitalized
            self.bonusStatusView.backgroundColor = UIColor.App.iconSecondary
            self.bonusStatusIconImageView.image = UIImage(named: "pause_circle_icon")
        }
        else {
            self.hasTypeStatus = true
            self.hasCancelButton = false
            self.bonusStatusLabel.text = BonusTypeMapper.init(bonusType: bonusStatus)?.bonusName ?? bonusStatus.capitalized
            self.bonusStatusView.backgroundColor = UIColor.App.iconSecondary
            self.bonusStatusIconImageView.image = UIImage(named: "pause_circle_icon")
        }
    }

    private func setupEmptyBonus() {
        let emptyBonusView = BonusEmptyView()
        emptyBonusView.configure(title: localized("wager_amount"), message: localized("no_wager_info"))

        self.stackView.addArrangedSubview(emptyBonusView)

        self.bonusLabel.text = "-"

    }

    private func setupProgressBars(bonus: GrantedBonus) {

        if !self.isSimpleBonus {
            if let bonusAmount = bonus.amount, bonusAmount > 0 {
                let bonusProgressCardView = BonusProgressView()
                //            bonusProgressCardView.setTitle(title: localized("bonus_amount"))
                //            bonusProgressCardView.setupProgressInfo(bonus: bonus, progressType: .bonus)
                let bonusProgressViewModel = BonusProgressViewModel(bonus: bonus, progressType: .bonus)
                bonusProgressCardView.configure(withViewModel: bonusProgressViewModel)
                self.stackView.addArrangedSubview(bonusProgressCardView)

            }
        }
        else {
            if let bonusAmount = bonus.amount {
                self.bonusLabel.text = "\(bonusAmount)"
            }
        }

        if let wagerAmount = bonus.initialWagerRequirementAmount, wagerAmount > 0 {
            let wagerProgressCardView = BonusProgressView()
//            wagerProgressCardView.setTitle(title: localized("wager_amount"))
//            wagerProgressCardView.setupProgressInfo(bonus: bonus, progressType: .wager)
            let wagerProgressViewModel = BonusProgressViewModel(bonus: bonus, progressType: .wager)
            wagerProgressCardView.configure(withViewModel: wagerProgressViewModel)
            self.stackView.addArrangedSubview(wagerProgressCardView)

        }

//        let bonusProgressCardView = BonusProgressView()
//        bonusProgressCardView.setTitle(title: "Bonus Amount")
//        bonusProgressCardView.testSetupProgressInfo(bonus: bonus, progressType: .bonus)
//        self.stackView.addArrangedSubview(bonusProgressCardView)
//
//        let wagerProgressCardView = BonusProgressView()
//        wagerProgressCardView.setTitle(title: "Wager Amount")
//        wagerProgressCardView.testSetupProgressInfo(bonus: bonus, progressType: .wager)
//        self.stackView.addArrangedSubview(wagerProgressCardView)

    }

    // MARK: Actions
    @objc func didTapCancelButton() {
        let alert = UIAlertController(title: localized("cancel_bonus"),
                                      message: localized("cancel_bonus_confirmation"),
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { [weak self] _ in
            self?.viewModel?.cancelBonus()

        }))

        alert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel, handler: nil))

        self.viewController?.present(alert, animated: true, completion: nil)

    }

}

//
// MARK: Subviews initialization and setup
//
extension BonusActiveTableViewCell {

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
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(localized("expire_date")):"
        label.font = AppFont.with(type: .medium, size: 11)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }

    private static func createDateIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "calendar_expired_icon")
        return imageView
    }

    private static func createDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "01.01.2022"
        label.font = AppFont.with(type: .medium, size: 11)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }

    private static func createBonusIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "cardholder_icon")
        return imageView
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

    private static func createBonusStatusView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.layer.cornerRadius = CornerRadius.label
        return view
    }

    private static func createBonusStatusIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "pause_circle_icon")
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

    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }

    private static func createCancelButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("cancel"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        return button
    }

    private static func createSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createStackViewBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createCancelButtonBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createTitleTrailingConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {
        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)

        self.containerView.addSubview(self.separatorView)

        self.containerView.addSubview(self.dateIconImageView)
        self.containerView.addSubview(self.dateLabel)

        self.containerView.addSubview(self.bonusIconImageView)
        self.containerView.addSubview(self.bonusLabel)

        self.contentView.addSubview(self.bonusStatusView)

        self.bonusStatusView.addSubview(self.bonusStatusIconImageView)
        self.bonusStatusView.addSubview(self.bonusStatusLabel)

        self.containerView.addSubview(self.stackView)

        self.containerView.addSubview(self.cancelButton)

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
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 11),

            self.separatorView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.separatorView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.separatorView.heightAnchor.constraint(equalToConstant: 1),
            self.separatorView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 10),

            self.dateIconImageView.leadingAnchor.constraint(equalTo: self.separatorView.leadingAnchor),
            self.dateIconImageView.topAnchor.constraint(equalTo: self.separatorView.bottomAnchor, constant: 10),
            self.dateIconImageView.widthAnchor.constraint(equalToConstant: 12),
            self.dateIconImageView.heightAnchor.constraint(equalToConstant: 13),

            self.dateLabel.leadingAnchor.constraint(equalTo: self.dateIconImageView.trailingAnchor, constant: 4),
            self.dateLabel.centerYAnchor.constraint(equalTo: self.dateIconImageView.centerYAnchor),

            self.bonusIconImageView.leadingAnchor.constraint(equalTo: self.dateLabel.trailingAnchor, constant: 20),
            self.bonusIconImageView.centerYAnchor.constraint(equalTo: self.dateIconImageView.centerYAnchor),
            self.bonusIconImageView.widthAnchor.constraint(equalToConstant: 12),
            self.bonusIconImageView.heightAnchor.constraint(equalToConstant: 13),

            self.bonusLabel.leadingAnchor.constraint(equalTo: self.bonusIconImageView.trailingAnchor, constant: 4),
            self.bonusLabel.centerYAnchor.constraint(equalTo: self.dateLabel.centerYAnchor)
        ])

        // Bonus status
        NSLayoutConstraint.activate([
            self.bonusStatusView.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 8),
            self.bonusStatusView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: 2),
            self.bonusStatusView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 11),
//            self.bonusStatusView.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
//            self.bonusStatusView.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),

            self.bonusStatusIconImageView.leadingAnchor.constraint(equalTo: self.bonusStatusView.leadingAnchor, constant: 8),
            self.bonusStatusIconImageView.widthAnchor.constraint(equalToConstant: 15),
            self.bonusStatusIconImageView.heightAnchor.constraint(equalTo: self.bonusStatusIconImageView.widthAnchor),
            self.bonusStatusIconImageView.topAnchor.constraint(equalTo: self.bonusStatusView.topAnchor, constant: 4),
            self.bonusStatusIconImageView.bottomAnchor.constraint(equalTo: self.bonusStatusView.bottomAnchor, constant: -4),

            self.bonusStatusLabel.leadingAnchor.constraint(equalTo: self.bonusStatusIconImageView.trailingAnchor, constant: 8),
            self.bonusStatusLabel.trailingAnchor.constraint(equalTo: self.bonusStatusView.trailingAnchor, constant: -8),
            self.bonusStatusLabel.centerYAnchor.constraint(equalTo: self.bonusStatusIconImageView.centerYAnchor)
        ])

        // StackView
        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.stackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.stackView.topAnchor.constraint(equalTo: self.dateLabel.bottomAnchor, constant: 16),
            // self.stackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20)
        ])

        // Cancel button
        NSLayoutConstraint.activate([
            self.cancelButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.cancelButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.cancelButton.topAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 15),
            // self.cancelButton.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20),
            self.cancelButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        self.stackViewBottomConstraint = self.stackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20)
        self.stackViewBottomConstraint.isActive = false

        self.cancelButtonBottomConstraint = self.cancelButton.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20)
        self.cancelButtonBottomConstraint.isActive = true

        self.titleTrailingConstraint =             self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15)
        self.titleTrailingConstraint.isActive = false

    }

}
