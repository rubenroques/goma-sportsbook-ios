//
//  AppSettingsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 16/02/2022.
//

import UIKit
import Combine
import LocalAuthentication

class AppSettingsViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var topStackView: UIStackView = Self.createTopStackView()
    private lazy var bottomStackView: UIStackView = Self.createBottomStackView()

    // MARK: Lifetime and Cycle
    init() {
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
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: MyFavoritesViewModel) {
    }

    private func setupTopStackView() {
        let notificationView = SettingsRowView()
        notificationView.setTitle(title: localized("notifications"))
        notificationView.hasSeparatorLineView = true
        notificationView.hasNavigationImageView = true
        let notiticationTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapNotificationView))
        notificationView.addGestureRecognizer(notiticationTap)

        let appearanceView = SettingsRowView()
        appearanceView.setTitle(title: localized("appearance"))
        appearanceView.hasSeparatorLineView = true
        appearanceView.hasNavigationImageView = true
        let appearanceTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapAppearanceView))
        appearanceView.addGestureRecognizer(appearanceTap)

        let oddsView = SettingsRowView()
        oddsView.setTitle(title: localized("odds"))
        oddsView.hasSeparatorLineView = true
        oddsView.hasNavigationImageView = true
        let oddsTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapOddsView))
        oddsView.addGestureRecognizer(oddsTap)

        let chatView = SettingsRowView()
        chatView.setTitle(title: localized("chat"))
        chatView.hasSeparatorLineView = true
        chatView.hasNavigationImageView = true
        let chatTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapChatView))
        chatView.addGestureRecognizer(chatTap)

        let tipsView = SettingsRowView()
        tipsView.setTitle(title: localized("tips"))
        tipsView.hasNavigationImageView = true
        let tipsTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapTipsView))
        tipsView.addGestureRecognizer(tipsTap)

        self.topStackView.addArrangedSubview(notificationView)

        if TargetVariables.supportedThemes.count > 1 {
            self.topStackView.addArrangedSubview(appearanceView)
        }

        self.topStackView.addArrangedSubview(oddsView)

        self.topStackView.addArrangedSubview(chatView)

        self.topStackView.addArrangedSubview(tipsView)

    }

    private func setupBottomStackView() {

        if #available(iOS 11, *) {
            let authContext = LAContext()
            let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            switch authContext.biometryType {
            case .touchID:
                let fingerprintView = SettingsRowView()
                fingerprintView.setTitle(title: localized("fingerprint_login"))
                fingerprintView.hasSwitchButton = Env.userSessionStore.shouldRequestFaceId()
                fingerprintView.didTappedSwitch = { isSwitchOn in
                    Env.userSessionStore.setShouldRequestFaceId(isSwitchOn)
                }
                self.bottomStackView.addArrangedSubview(fingerprintView)
            case .faceID:
                let faceIdView = SettingsRowView()
                faceIdView.setTitle(title: localized("face_id_login"))
                faceIdView.hasSwitchButton = Env.userSessionStore.shouldRequestFaceId()
                faceIdView.didTappedSwitch = { isSwitchOn in
                    Env.userSessionStore.setShouldRequestFaceId(isSwitchOn)
                }
                self.bottomStackView.addArrangedSubview(faceIdView)
            case .none:
                self.bottomStackView.isHidden = true
            @unknown default:
                self.bottomStackView.isHidden = true
            }
        }

    }

}

//
// MARK: - Actions
//
extension AppSettingsViewController {
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapNotificationView() {
        let notificationViewController = NotificationsViewController()
        self.navigationController?.pushViewController(notificationViewController, animated: true)
    }

    @objc private func didTapAppearanceView() {
        let appearanceViewController = AppearanceViewController()
        self.navigationController?.pushViewController(appearanceViewController, animated: true)
    }

    @objc private func didTapOddsView() {
        let oddsViewController = OddsViewController()
        self.navigationController?.pushViewController(oddsViewController, animated: true)
    }

    @objc private func didTapChatView() {
        let chatSettingsViewModel = ChatSettingsViewModel()

        let chatSettingsViewController = ChatSettingsViewController(viewModel: chatSettingsViewModel)

        self.navigationController?.pushViewController(chatSettingsViewController, animated: true)
    }

    @objc private func didTapTipsView() {
        let tipsSettingsViewModel = TipsSettingsViewModel()

        let tipsSettingsViewController = TipsSettingsViewController(viewModel: tipsSettingsViewModel)

        self.navigationController?.pushViewController(tipsSettingsViewController, animated: true)
    }
}

//
// MARK: Subviews initialization and setup
//
extension AppSettingsViewController {

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
        label.text = localized("app_settings")
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
            self.topView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 0),
            self.backButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.topTitleLabel.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 20),
            self.topTitleLabel.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -20),
            self.topTitleLabel.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor)
        ])

        // StackView
        NSLayoutConstraint.activate([
            self.topStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.topStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.topStackView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 8),

        ])

        // StackView
        NSLayoutConstraint.activate([
            self.bottomStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.bottomStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.bottomStackView.topAnchor.constraint(equalTo: self.topStackView.bottomAnchor, constant: 16),

        ])

    }

}
