//
//  FeaturedTipCollectionViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 30/08/2022.
//

import UIKit

class FeaturedTipCollectionViewCell: UICollectionViewCell {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var topInfoStackView: UIStackView = Self.createTopInfoStackView()
    private lazy var counterView: UIView = Self.createCounterView()
    private lazy var userImageView: UIImageView = Self.createUserImageView()
    private lazy var usernameLabel: UILabel = Self.createUsernameLabel()
    private lazy var followButton: UIButton = Self.createFollowButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.setupWithTheme()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.contentView.layer.cornerRadius = CornerRadius.view
        self.contentView.layer.masksToBounds = true

        self.containerView.layer.cornerRadius = CornerRadius.view
        self.containerView.layer.masksToBounds = true

        self.counterView.layer.cornerRadius = self.counterView.frame.height / 2
        self.counterView.layer.masksToBounds = true

        self.userImageView.layer.cornerRadius = self.userImageView.frame.height / 2
        self.userImageView.layer.masksToBounds = true

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {

        self.contentView.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.alertError

        self.topInfoStackView.backgroundColor = .yellow

        self.counterView.backgroundColor = .blue

        self.userImageView.backgroundColor = .clear

        self.usernameLabel.textColor = UIColor.App.textPrimary

        self.followButton.backgroundColor = .yellow
        self.followButton.setTitleColor(UIColor.App.highlightSecondary, for: .normal)

    }
}

extension FeaturedTipCollectionViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopInfoStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 3
        stackView.distribution = .fillProportionally
        return stackView
    }

    private static func createCounterView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createUserImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "my_account_profile_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 2
        return imageView
    }

    private static func createUsernameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Username"
        label.font = AppFont.with(type: .semibold, size: 15)
        return label
    }

    private static func createFollowButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("follow"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 12)
        return button
    }

    private static func createTestLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "TEST"
        label.font = AppFont.with(type: .semibold, size: 16)
        return label
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.topInfoStackView)

        self.topInfoStackView.addArrangedSubview(self.counterView)
        self.topInfoStackView.addArrangedSubview(self.userImageView)
        self.topInfoStackView.addArrangedSubview(self.usernameLabel)

        self.containerView.addSubview(self.followButton)

        self.initConstraints()

        self.containerView.layoutIfNeeded()
        self.containerView.layoutSubviews()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])

        // Top Info stackview
        NSLayoutConstraint.activate([
            self.topInfoStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 10),
            self.topInfoStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 5),
            self.topInfoStackView.heightAnchor.constraint(equalToConstant: 40),
            self.topInfoStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -60),

            self.counterView.widthAnchor.constraint(equalToConstant: 15),
            self.counterView.heightAnchor.constraint(equalToConstant: 15),
            self.counterView.centerYAnchor.constraint(equalTo: self.topInfoStackView.centerYAnchor),

            self.userImageView.widthAnchor.constraint(equalToConstant: 26),
            self.userImageView.heightAnchor.constraint(equalTo: self.userImageView.widthAnchor),
            self.userImageView.centerYAnchor.constraint(equalTo: self.topInfoStackView.centerYAnchor),

            self.usernameLabel.centerYAnchor.constraint(equalTo: self.topInfoStackView.centerYAnchor),

            self.followButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -5),
            self.followButton.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 5),
            self.followButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
