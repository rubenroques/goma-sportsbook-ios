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

    }

    func setupBonus(bonus: EveryMatrix.GrantedBonus) {

        self.titleLabel.text = bonus.name

        self.dateLabel.text = bonus.expiryDate
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

    private func setupSubviews() {
        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.subtitleLabel)
        self.containerView.addSubview(self.dateLabel)

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
            self.subtitleLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20),

            self.dateLabel.leadingAnchor.constraint(equalTo: self.subtitleLabel.trailingAnchor, constant: 4),
            self.dateLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.dateLabel.centerYAnchor.constraint(equalTo: self.subtitleLabel.centerYAnchor)
        ])

    }

}
