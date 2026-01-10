//
//  BonusEmptyView.swift
//  Sportsbook
//
//  Created by André Lascas on 24/03/2023.
//

import UIKit

class BonusEmptyView: UIView {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var emptyBonusView: UIView = Self.createEmptyBonusView()
    private lazy var emptyBonusLabel: UILabel = Self.createEmptyBonusLabel()

    // MARK: Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupSubviews()
        self.setupWithTheme()
    }

    private func setupWithTheme() {

        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.emptyBonusView.backgroundColor = UIColor.App.backgroundSecondary

        self.emptyBonusView.layer.borderColor = UIColor.App.backgroundBorder.cgColor

        self.emptyBonusLabel.textColor = UIColor.App.textDisablePrimary
    }

    func configure(title: String, message: String) {

        self.titleLabel.text = title

        self.emptyBonusLabel.text = message

    }

}

//
// MARK: Subviews initialization and setup
//
extension BonusEmptyView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("title")
        label.numberOfLines = 0
        label.font = AppFont.with(type: .bold, size: 12)
        return label
    }

    private static func createEmptyBonusView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.label
        view.layer.borderWidth = 2
        return view
    }

    private static func createEmptyBonusLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("title")
        label.numberOfLines = 0
        label.font = AppFont.with(type: .bold, size: 12)
        label.textAlignment = .center
        return label
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.emptyBonusView)
        self.containerView.addSubview(self.emptyBonusLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.containerView.heightAnchor.constraint(equalToConstant: 60),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 8),

            self.emptyBonusView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.emptyBonusView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.emptyBonusView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),

            self.emptyBonusLabel.leadingAnchor.constraint(equalTo: self.emptyBonusView.leadingAnchor, constant: 15),
            self.emptyBonusLabel.trailingAnchor.constraint(equalTo: self.emptyBonusView.trailingAnchor, constant: -15),
            self.emptyBonusLabel.topAnchor.constraint(equalTo: self.emptyBonusView.topAnchor, constant: 10),
            self.emptyBonusLabel.bottomAnchor.constraint(equalTo: self.emptyBonusView.bottomAnchor, constant: -10)
        ])

    }

}
