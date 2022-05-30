//
//  DateHeaderFooterView.swift
//  Sportsbook
//
//  Created by André Lascas on 08/04/2022.
//

import UIKit

class DateHeaderFooterView: UITableViewHeaderFooterView {

    // MARK: Private Properties
    private lazy var baseView: UIView = Self.createBaseView()
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

        self.setupWithTheme()
        self.titleLabel.text = ""
    }

    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.baseView.backgroundColor = UIColor.App.backgroundPrimary
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

    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = ""
        label.font = AppFont.with(type: .bold, size: 9)
        label.textAlignment = .center
        return label
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.baseView)
        self.baseView.addSubview(self.titleLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
        ])

        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 30),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -30),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor)
        ])
    }
}
