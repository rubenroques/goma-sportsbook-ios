//
//  BonusActiveTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 03/03/2022.
//

import UIKit

class BonusActiveTableViewCell: UITableViewCell {
    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var dateLabel: UILabel = Self.createDateLabel()
    private lazy var stackView: UIStackView = Self.createStackView()

    // MARK: Public Properties
    var hasBonusAmount: Bool = false {
        didSet {
            self.stackView.isHidden = !hasBonusAmount
        }
    }

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

        self.titleLabel.textColor = UIColor.App.highlightSecondary

        self.subtitleLabel.textColor = UIColor.App.textPrimary

        self.dateLabel.textColor = UIColor.App.textSecondary

        self.stackView.backgroundColor = UIColor.App.backgroundSecondary

    }

    func setupBonus(bonus: EveryMatrix.GrantedBonus) {
        
        self.titleLabel.text = bonus.name

        let formattedDate = getDateFormatted(dateString: bonus.expiryDate ?? "")

        if formattedDate != "" {
            self.dateLabel.text = formattedDate
        }
        else {
            self.dateLabel.text = localized("permanent")
        }

        if let bonusAmount = bonus.amount, let wagerAmount = bonus.initialWagerRequirementAmount {
            if bonusAmount > 0 || wagerAmount > 0 {
                self.hasBonusAmount = true
            }
        }

        if self.hasBonusAmount {
            self.stackView.removeAllArrangedSubviews()
            self.setupProgressBars(bonus: bonus)
        }

    }

    private func setupProgressBars(bonus: EveryMatrix.GrantedBonus) {

        if let bonusAmount = bonus.amount, bonusAmount > 0 {
            let bonusProgressCardView = BonusProgressView()
            bonusProgressCardView.setTitle(title: "Bonus Amount")
            bonusProgressCardView.setupProgressInfo(bonus: bonus, progressType: .bonus)
            self.stackView.addArrangedSubview(bonusProgressCardView)

        }

        if let wagerAmount = bonus.initialWagerRequirementAmount, wagerAmount > 0 {
            let wagerProgressCardView = BonusProgressView()
            wagerProgressCardView.setTitle(title: "Wager Amount")
            wagerProgressCardView.setupProgressInfo(bonus: bonus, progressType: .wager)
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

    func getDateFormatted(dateString: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm"

        let date = dateString

        if let formattedDate = dateFormatterGet.date(from: date) {

            return dateFormatterPrint.string(from: formattedDate)
        }

        return ""
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

    private static func createDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "01.01.2022"
        label.font = AppFont.with(type: .medium, size: 11)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
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

    private func setupSubviews() {
        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.subtitleLabel)
        self.containerView.addSubview(self.dateLabel)
        self.containerView.addSubview(self.stackView)

        self.initConstraints()
    }

    private func initConstraints() {

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 25),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -25),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 25),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -25)

        ])

        // Labels
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 20),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 12),
//            self.subtitleLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20),

            self.dateLabel.leadingAnchor.constraint(equalTo: self.subtitleLabel.trailingAnchor, constant: 4),
            self.dateLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.dateLabel.centerYAnchor.constraint(equalTo: self.subtitleLabel.centerYAnchor)
        ])

        // StackView
        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.stackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.stackView.topAnchor.constraint(equalTo: self.subtitleLabel.bottomAnchor, constant: 16),
            self.stackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20)
        ])

    }

}
