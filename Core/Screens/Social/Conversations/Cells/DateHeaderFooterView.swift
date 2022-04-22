//
//  DateHeaderFooterView.swift
//  Sportsbook
//
//  Created by André Lascas on 08/04/2022.
//

import UIKit

class DateHeaderFooterView: UITableViewHeaderFooterView {

    // MARK: Private Properties
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

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
        self.titleLabel.textColor = UIColor.App.textDisablePrimary
    }

    // MARK: Functions
    func configureHeader(title: String) {
        self.titleLabel.text = title

    }
}

//
// MARK: Subviews initialization and setup
//
extension DateHeaderFooterView {

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = "01/04/2022"
        label.font = AppFont.with(type: .bold, size: 9)
        label.textAlignment = .center
        return label
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.titleLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 30),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -30),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
    }
}
