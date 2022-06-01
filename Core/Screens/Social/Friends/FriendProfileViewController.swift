//
//  FriendProfileViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 18/05/2022.
//

import UIKit

class FriendProfileViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var profileImageView: UIImageView = Self.createProfileImageView()
    private lazy var profileUsernameLabel: UILabel = Self.createProfileUsernameLabel()
    private lazy var muteButton: UIButton = Self.createMuteButton()
    private lazy var unfriendButton: UIButton = Self.createUnfriendButton()

    // MARK: Public Properties
    var viewModel: FriendProfileViewModel

    // MARK: - Lifetime and Cycle
    init(viewModel: FriendProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.setupProfile()

        self.muteButton.alignVertical()

        self.unfriendButton.alignVertical()

    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        self.muteButton.layer.cornerRadius = CornerRadius.button

        self.unfriendButton.layer.cornerRadius = CornerRadius.button

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topSafeAreaView.backgroundColor = .clear

        self.bottomSafeAreaView.backgroundColor = .clear

        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary

        self.backButton.backgroundColor = .clear

        self.profileImageView.backgroundColor = .clear

        self.profileUsernameLabel.textColor = UIColor.App.textPrimary

        self.muteButton.backgroundColor = UIColor.App.backgroundTertiary
        self.muteButton.setTitleColor(UIColor.App.textPrimary, for: .normal)

        self.unfriendButton.backgroundColor = UIColor.App.backgroundTertiary
        self.unfriendButton.setTitleColor(UIColor.App.textPrimary, for: .normal)

    }

    // MARK: Functions
    private func setupProfile() {
        self.profileUsernameLabel.text = self.viewModel.username
    }

    // MARK: Actions
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension FriendProfileViewController {
    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton.init(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        button.setTitle(nil, for: .normal)
        return button
    }

    private static func createProfileImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "my_account_profile_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createProfileUsernameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Username"
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        return label
    }

    private static func createMuteButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("mute"), for: .normal)
        button.setImage(UIImage(named: "notification_inactive_icon"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 12)
        return button
    }

    private static func createUnfriendButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("unfriend"), for: .normal)
        button.setImage(UIImage(named: "add_friend_icon"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 12)
        return button
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)

        self.view.addSubview(self.profileImageView)

        self.view.addSubview(self.profileUsernameLabel)

        self.view.addSubview(self.muteButton)

        self.view.addSubview(self.unfriendButton)

        self.view.addSubview(self.bottomSafeAreaView)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top and Bottom Safe Area View
        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),

            self.bottomSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.bottomSafeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        // Navigation View
        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.heightAnchor.constraint(equalTo: self.navigationView.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 0)
        ])

        NSLayoutConstraint.activate([
            self.profileImageView.widthAnchor.constraint(equalToConstant: 108),
            self.profileImageView.heightAnchor.constraint(equalTo: self.profileImageView.widthAnchor),
            self.profileImageView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 10),
            self.profileImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),

            self.profileUsernameLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            self.profileUsernameLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            self.profileUsernameLabel.topAnchor.constraint(equalTo: self.profileImageView.bottomAnchor, constant: 10),

            self.muteButton.widthAnchor.constraint(equalToConstant: 73),
            self.muteButton.heightAnchor.constraint(equalToConstant: 58),
            self.muteButton.topAnchor.constraint(equalTo: self.profileUsernameLabel.bottomAnchor, constant: 20),
            self.muteButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -41),

            self.unfriendButton.widthAnchor.constraint(equalToConstant: 73),
            self.unfriendButton.heightAnchor.constraint(equalToConstant: 58),
            self.unfriendButton.topAnchor.constraint(equalTo: self.profileUsernameLabel.bottomAnchor, constant: 20),
            self.unfriendButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 41)
        ])

    }
}
