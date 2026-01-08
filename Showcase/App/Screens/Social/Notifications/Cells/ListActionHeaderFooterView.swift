//
//  ListActionHeaderFooterView.swift
//  Sportsbook
//
//  Created by André Lascas on 30/09/2022.
//

import UIKit

class ListActionHeaderFooterView: UITableViewHeaderFooterView {

    // MARK: Private Properties
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var actionButton: UIButton = Self.createActionButton()

    var tappedActionButton: (() -> Void)?

    // MARK: - Lifetime and Cycle
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.actionButton.addTarget(self, action: #selector(didTapActionButton), for: .primaryActionTriggered)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.text = ""
    }

    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.actionButton.backgroundColor = .clear
        self.actionButton.setTitleColor(UIColor.App.textSecondary, for: .normal)

        self.contentView.backgroundColor = .clear
    }

    // MARK: Functions
    func configureHeader(title: String, actionTitle: String) {

        self.titleLabel.text = title

        self.actionButton.setTitle(actionTitle, for: .normal)

    }

    // MARK: Actions
    @objc private func didTapActionButton() {
        self.tappedActionButton?()
    }
}

//
// MARK: Subviews initialization and setup
//
extension ListActionHeaderFooterView {

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = AppFont.with(type: .semibold, size: 14)
        label.textAlignment = .left
        return label
    }

    private static func createActionButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Action", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 12)
        return button
    }

    private func setupSubviews() {
        self.contentView.addSubview(self.titleLabel)

        self.contentView.addSubview(self.actionButton)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.actionButton.leadingAnchor, constant: -10),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

            self.actionButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
            self.actionButton.heightAnchor.constraint(equalToConstant: 40),
            self.actionButton.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.actionButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
//            self.actionButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
    }
}
