//
//  NotificationsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 17/02/2022.
//

import UIKit

class NotificationsViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var topStackView: UIStackView = Self.createTopStackView()
    private lazy var bottomStackView: UIStackView = Self.createBottomStackView()

    // MARK: Public Properties
    var viewModel: NotificationsViewModel

    // MARK: Lifetime and Cycle
    init() {
        self.viewModel = NotificationsViewModel()
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

        self.setupTopStackView()
        self.setupBottomStackView()

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = UIColor.App.backgroundPrimary

        self.backButton.tintColor = UIColor.App.textPrimary

        self.topTitleLabel.textColor = UIColor.App.textPrimary

        self.topStackView.backgroundColor = UIColor.App.backgroundSecondary

        self.bottomStackView.backgroundColor = UIColor.App.backgroundSecondary

//        self.deviceSettingsView.backgroundColor = UIColor.App.backgroundSecondary

    }

    private func setupTopStackView() {
        let deviceView = SettingsRowView()
        deviceView.setTitle(title: localized("device_settings"))
        deviceView.hasSeparatorLineView = true
        deviceView.hasNavigationImageView = true
        let deviceTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapDeviceView))
        deviceView.addGestureRecognizer(deviceTap)

        let gamesNotificationView = SettingsRowView()
        gamesNotificationView.setTitle(title: localized("games_notification_defaults"))
        gamesNotificationView.hasSeparatorLineView = true
        gamesNotificationView.hasNavigationImageView = true
        let gamesNotificationTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapGamesNotificationView))
        gamesNotificationView.addGestureRecognizer(gamesNotificationTap)

        let bettingNotificationView = SettingsRowView()
        bettingNotificationView.setTitle(title: localized("betting_notification_defaults"))
        bettingNotificationView.hasNavigationImageView = true
        let bettingNotificationTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapBettingNotificationView))
        bettingNotificationView.addGestureRecognizer(bettingNotificationTap)

        self.topStackView.addArrangedSubview(deviceView)
        self.topStackView.addArrangedSubview(gamesNotificationView)
        self.topStackView.addArrangedSubview(bettingNotificationView)

    }

    private func setupBottomStackView() {

        let allowSportsbookView = SettingsRowView()
        allowSportsbookView.setTitle(title: localized("allow_sportsbook_contact"))

        let smsView = SettingsRowView()
        smsView.setTitle(title: localized("sms"))
        smsView.hasSeparatorLineView = true
        smsView.hasSwitchButton = true

        smsView.didTappedSwitch = {
            self.viewModel.updateSmsSetting(isSettingEnabled: smsView.isSwitchOn)
        }

        let emailView = SettingsRowView()
        emailView.setTitle(title: localized("email"))
        emailView.hasSwitchButton = true

        emailView.didTappedSwitch = {
            self.viewModel.updateEmailSetting(isSettingEnabled: emailView.isSwitchOn)
        }

        // Check options
        if let userSettings = self.viewModel.userSettings {
            if userSettings.notificationSms == 1 {
                smsView.isSwitchOn = true
            }
            else {
                smsView.isSwitchOn = false
            }

            if userSettings.notificationEmail == 1 {
                emailView.isSwitchOn = true
            }
            else {
                emailView.isSwitchOn = false
            }
        }

        self.bottomStackView.addArrangedSubview(allowSportsbookView)
        self.bottomStackView.addArrangedSubview(smsView)
        self.bottomStackView.addArrangedSubview(emailView)

    }

}

//
// MARK: - Actions
//
extension NotificationsViewController {
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapDeviceView() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }

    @objc private func didTapGamesNotificationView() {
        let gamesNotificationViewController = GamesNotificationViewController()
        self.navigationController?.pushViewController(gamesNotificationViewController, animated: true)
    }

    @objc private func didTapBettingNotificationView() {
        let bettingNotificationViewController = BettingNotificationsViewController()
        self.navigationController?.pushViewController(bettingNotificationViewController, animated: true)
    }

}

//
// MARK: Subviews initialization and setup
//
extension NotificationsViewController {

    private static func createTopView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        return button
    }

    private static func createTopTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("notifications")
        label.font = AppFont.with(type: .bold, size: 17)
        label.textAlignment = .center
        return label
    }

    private static func createTopStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.layer.cornerRadius = CornerRadius.button
        return stackView
    }

    private static func createBottomStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.layer.cornerRadius = CornerRadius.button
        return stackView
    }

    private func setupSubviews() {
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)
        self.topView.bringSubviewToFront(self.topTitleLabel)

        self.view.addSubview(self.topStackView)

        self.view.addSubview(self.bottomStackView)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topView.heightAnchor.constraint(equalToConstant: 70),

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 10),
            self.backButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 20),
            self.backButton.widthAnchor.constraint(equalToConstant: 15),

            self.topTitleLabel.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 20),
            self.topTitleLabel.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -20),
            self.topTitleLabel.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor)

        ])

        // Top StackView
        NSLayoutConstraint.activate([
            self.topStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.topStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.topStackView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 8),

        ])

        // Bottom StackView
        NSLayoutConstraint.activate([
            self.bottomStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.bottomStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.bottomStackView.topAnchor.constraint(equalTo: self.topStackView.bottomAnchor, constant: 16)

        ])

    }

}
