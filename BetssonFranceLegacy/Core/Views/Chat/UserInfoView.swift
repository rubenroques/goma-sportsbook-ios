//
//  UserInfoView.swift
//  Sportsbook
//
//  Created by André Lascas on 09/05/2022.
//

import UIKit

class UserInfoView: UIView {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var userInfoStackView: UIStackView = Self.createUserInfoStackView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var userStateBaseView: UIView = Self.createUserStateBaseView()
    private lazy var userStateView: UIView = Self.createUserStateView()

    // MARK: Public Properties
    var isOnline: Bool = false {
        didSet {
            self.userStateBaseView.isHidden = !isOnline
        }
    }

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

        self.isOnline = false

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.iconBaseView.layoutIfNeeded()
        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2

        self.iconImageView.layoutIfNeeded()
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2

        self.userStateView.layoutIfNeeded()
        self.userStateView.layer.cornerRadius = self.userStateView.frame.height / 2
    }

    // MARK: - Layout and Theme
    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.iconBaseView.backgroundColor = UIColor.App.backgroundTertiary

        self.iconImageView.backgroundColor = UIColor.App.backgroundTertiary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.userStateBaseView.backgroundColor = .clear

        self.userStateView.backgroundColor = UIColor.App.alertSuccess
    }

    // MARK: Functions
    func setupViewInfo(title: String) {
        self.titleLabel.text = title
    }

}

//
// MARK: Subviews initialization and setup
//
extension UserInfoView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "my_account_profile_icon")
        imageView.contentMode = .center
        return imageView
    }

    private static func createUserInfoStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fill
        return stackView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@User"
        label.font = AppFont.with(type: .bold, size: 16)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }

    private static func createUserStateBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }

    private static func createUserStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.iconBaseView)

        self.iconBaseView.addSubview(self.iconImageView)

        self.containerView.addSubview(self.userInfoStackView)

        self.userInfoStackView.addArrangedSubview(self.titleLabel)
        self.userInfoStackView.addArrangedSubview(self.userStateBaseView)

        self.userStateBaseView.addSubview(self.userStateView)

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

            self.iconBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 25),
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 40),
            self.iconBaseView.heightAnchor.constraint(equalTo: self.iconBaseView.widthAnchor),
            self.iconBaseView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.iconImageView.leadingAnchor.constraint(equalTo: self.iconBaseView.leadingAnchor, constant: 3),
            self.iconImageView.trailingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: -3),
            self.iconImageView.topAnchor.constraint(equalTo: self.iconBaseView.topAnchor, constant: 3),
            self.iconImageView.bottomAnchor.constraint(equalTo: self.iconBaseView.bottomAnchor, constant: -3),

            self.userInfoStackView.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 15),
            self.userInfoStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -25),
            self.userInfoStackView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            self.userInfoStackView.heightAnchor.constraint(equalToConstant: 30),

            self.userStateBaseView.widthAnchor.constraint(greaterThanOrEqualToConstant: 10),

            self.userStateView.widthAnchor.constraint(equalToConstant: 8),
            self.userStateView.heightAnchor.constraint(equalTo: self.userStateView.widthAnchor),
            self.userStateView.leadingAnchor.constraint(equalTo: self.userStateBaseView.leadingAnchor),
            self.userStateView.centerYAnchor.constraint(equalTo: self.userStateBaseView.centerYAnchor)
        ])

    }

}
