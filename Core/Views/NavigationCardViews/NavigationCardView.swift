//
//  NavigationCardView.swift
//  Sportsbook
//
//  Created by André Lascas on 22/03/2022.
//

import UIKit

class NavigationCardView: UIView {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var navigationImageView: UIImageView = Self.createNavigationImageView()

    // MARK: Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    private func commonInit() {
    }

    private func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.iconBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.iconImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

    }

    func setupView(title: String, iconTitle: String) {
        self.titleLabel.text = title

        self.iconImageView.image = UIImage(named: iconTitle)
    }

}

//
// MARK: Subviews initialization and setup
//
extension NavigationCardView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        return view
    }

    private static func createIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view

        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.numberOfLines = 0
        label.font = AppFont.with(type: .bold, size: 16)
        return label
    }

    private static func createNavigationImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "nav_arrow_right_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.iconBaseView)

        self.iconBaseView.addSubview(self.iconImageView)

        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.navigationImageView)

        self.initConstraints()
    }

    private func initConstraints() {

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.containerView.heightAnchor.constraint(equalToConstant: 55),

            self.iconBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 8),
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 36),
            self.iconBaseView.heightAnchor.constraint(equalToConstant: 36),
            self.iconBaseView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.iconImageView.widthAnchor.constraint(equalToConstant: 18),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 18),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.iconBaseView.centerYAnchor),
            self.iconImageView.centerXAnchor.constraint(equalTo: self.iconBaseView.centerXAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 20),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.navigationImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            self.navigationImageView.widthAnchor.constraint(equalToConstant: 10),
            self.navigationImageView.heightAnchor.constraint(equalToConstant: 15),
            self.navigationImageView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor)

        ])

    }

}
