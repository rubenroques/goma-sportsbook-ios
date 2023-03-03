//
//  TipInfoView.swift
//  Sportsbook
//
//  Created by André Lascas on 02/03/2023.
//

import UIKit

class TipInfoView: UIView {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var textLabel: UILabel = Self.createTextLabel()

    // MARK: - Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
        self.setupWithTheme()
    }

    func commonInit() {

        self.setupSubviews()

    }

    override func layoutSubviews() {
        super.layoutSubviews()

    }

    func setupWithTheme() {
        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.textLabel.textColor = UIColor.App.textPrimary

    }

    // MARK: Functions
    func configure(title: String, text: String) {
        self.titleLabel.text = title

        self.textLabel.text = text
    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension TipInfoView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("tip_title")
        label.font = AppFont.with(type: .bold, size: 16)
        return label
    }

    private static func createTextLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("tip_message")
        label.font = AppFont.with(type: .regular, size: 14)
        label.numberOfLines = 0
        return label
    }

    private func setupSubviews() {

        self.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.textLabel)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 5),

            self.textLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.textLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.textLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 15),
            self.textLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -5)

        ])
    }
}
