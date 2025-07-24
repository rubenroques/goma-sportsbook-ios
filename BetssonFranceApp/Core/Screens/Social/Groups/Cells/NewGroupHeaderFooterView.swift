//
//  NewGroupHeaderFooterView.swift
//  Sportsbook
//
//  Created by André Lascas on 22/07/2022.
//

import UIKit

class NewGroupHeaderFooterView: UITableViewHeaderFooterView {

    // MARK: Private Properties
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()

    // MARK: - Lifetime and Cycle
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

    }

    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.titleLabel.textColor = UIColor.App.textPrimary

        self.subtitleLabel.textColor = UIColor.App.textSecondary

        self.contentView.backgroundColor = .clear
    }

    // MARK: Functions
    func configureHeader(title: String, subtitle: String) {
        self.titleLabel.text = title

        self.subtitleLabel.text = subtitle
    }

}

//
// MARK: Subviews initialization and setup
//
extension NewGroupHeaderFooterView {

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = localized("title")
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .left
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "Subtitle"
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textAlignment = .left
        return label
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.titleLabel)

        self.contentView.addSubview(self.subtitleLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 25),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -25),
            self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 4),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 25),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -25),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 4),
            self.subtitleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -4)
        ])
    }
}

