//
//  SettingsRowView.swift
//  Sportsbook
//
//  Created by André Lascas on 16/02/2022.
//

import UIKit

class SettingsRowView: UIView {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()

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

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.alertError

        self.titleLabel.textColor = UIColor.App.textPrimary

    }

    func setTitle(title: String) {
        self.titleLabel.text = title
    }

}

//
// MARK: Subviews initialization and setup
//
extension SettingsRowView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = AppFont.with(type: .bold, size: 16)
        return label
    }

    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }


    private func setupSubviews() {
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.separatorLineView)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.containerView.heightAnchor.constraint(equalToConstant: 60),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.separatorLineView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.separatorLineView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.separatorLineView.trailingAnchor

        ])

    }

}
