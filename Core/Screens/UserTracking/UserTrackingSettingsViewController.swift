//
//  UserTrackingSettingsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 31/03/2023.
//

import Foundation
import UIKit
import Combine

struct UserTrackingSettingsViewModel {

}

class UserTrackingSettingsViewController: UIViewController {

    // MARK: - Variables
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationBaseView: UIView = Self.createNavigationBaseView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    private lazy var continueButton: UIButton = Self.createContinueButton()
    private lazy var skipButton: UIButton = Self.createSkipButton()

    private lazy var contentBaseView: UIView = Self.createContentBaseView()
    private lazy var contentScrollView: UIScrollView = Self.createScrollBaseView()

    private lazy var descriptionTextLabel: UILabel = Self.createDescriptionTextLabel()

    private lazy var settingsStackView: UIStackView = Self.createSettingsStackView()

    private lazy var essencialBaseView: UIView = Self.createSettingsBaseView()
    private lazy var essencialLabel: UILabel = Self.createSettingLabel()
    private lazy var essencialSwitch: UISwitch = Self.createSettingSwitch()

    private lazy var audienceBaseView: UIView = Self.createSettingsBaseView()
    private lazy var audienceLabel: UILabel = Self.createSettingLabel()
    private lazy var audienceSwitch: UISwitch = Self.createSettingSwitch()

    private lazy var offersBaseView: UIView = Self.createSettingsBaseView()
    private lazy var offersLabel: UILabel = Self.createSettingLabel()
    private lazy var offersSwitch: UISwitch = Self.createSettingSwitch()

    private lazy var buttonsStackView: UIStackView = Self.createButtonsStackView()
    private lazy var bottomBaseView: UIView = Self.createBottomBaseView()

    private var viewModel: UserTrackingSettingsViewModel
    var cancellables = Set<AnyCancellable>()

    // MARK: - Lifetime and Cycle
    init(viewModel: UserTrackingSettingsViewModel) {
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
        self.commonInit()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }
    func commonInit() {

        self.essencialSwitch.isOn = true
        self.essencialSwitch.isEnabled = false
        self.essencialSwitch.isUserInteractionEnabled = false

        self.audienceSwitch.isOn = false
        self.offersSwitch.isOn = false

        self.essencialLabel.text = localized("essential_mandatory")
        self.audienceLabel.text = localized("audience_measurement")
        self.offersLabel.text = localized("advertising_and_offers_optimization")

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)
        self.continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .primaryActionTriggered)
        self.skipButton.addTarget(self, action: #selector(didTapSkipButton), for: .primaryActionTriggered)
        
        self.skipButton.isHidden = true
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary
        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.titleLabel.backgroundColor = .clear
        self.titleLabel.textColor = UIColor.App.textPrimary

        self.essencialBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.audienceBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.offersBaseView.backgroundColor = UIColor.App.backgroundSecondary
    }

    // MARK: - Actions

    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func didTapContinueButton() {
        Env.userSessionStore.didAcceptedTracking()
    }

    @objc func didTapSkipButton() {
        Env.userSessionStore.didSkippedTracking()
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension UserTrackingSettingsViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBaseView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNavigationBaseView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
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

    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = localized("tracking_policy_title")
        titleLabel.font = AppFont.with(type: .bold, size: 17)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        return titleLabel
    }

    private static func createContentBaseView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createScrollBaseView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    private static func createDescriptionTextLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = AppFont.with(type: .semibold, size: 14)
        label.text = localized("details_cookies_settings")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createSettingsBaseView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSettingsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 26
        return stackView
    }

    private static func createSettingLabel() -> UILabel {
        let label = UILabel()
        label.setContentHuggingPriority(.init(125), for: .vertical)
        label.setContentHuggingPriority(.init(125), for: .horizontal)
        label.font = AppFont.with(type: .semibold, size: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createSettingSwitch() -> UISwitch {
        let toggleSwitch = UISwitch()
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        return toggleSwitch
    }

    private static func createBottomBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createButtonsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 26
        return stackView
    }

    private static func createContinueButton() -> UIButton {
        let sendButton = UIButton()
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle(localized("accept_all_cookies"), for: .normal)
        StyleHelper.styleButton(button: sendButton)
        sendButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        return sendButton
    }

    private static func createSkipButton() -> UIButton {
        let sendButton = UIButton()
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle(localized("continue_without_accepting_cookies"), for: .normal)
        StyleHelper.styleButton(button: sendButton)
        sendButton.setBackgroundColor(.clear, for: .normal)
        sendButton.setTitleColor(UIColor.App.textSecondary, for: .normal)
        return sendButton
    }

    private func setupSubviews() {
        self.navigationBaseView.addSubview(self.titleLabel)
        self.navigationBaseView.addSubview(self.backButton)

        self.contentBaseView.addSubview(self.descriptionTextLabel)

        self.contentBaseView.addSubview(self.settingsStackView)

        self.essencialBaseView.addSubview(self.essencialLabel)
        self.essencialBaseView.addSubview(self.essencialSwitch)
        self.settingsStackView.addArrangedSubview(self.essencialBaseView)

        self.audienceBaseView.addSubview(self.audienceLabel)
        self.audienceBaseView.addSubview(self.audienceSwitch)
        self.settingsStackView.addArrangedSubview(self.audienceBaseView)

        self.offersBaseView.addSubview(self.offersLabel)
        self.offersBaseView.addSubview(self.offersSwitch)
        self.settingsStackView.addArrangedSubview(self.offersBaseView)

        self.buttonsStackView.addArrangedSubview(self.continueButton)
        self.buttonsStackView.addArrangedSubview(self.skipButton)

        self.bottomBaseView.addSubview(self.buttonsStackView)

        self.contentScrollView.addSubview(self.contentBaseView)

        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.navigationBaseView)

        self.view.addSubview(self.contentScrollView)

        self.view.addSubview(self.bottomBaseView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])

        NSLayoutConstraint.activate([
            self.navigationBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationBaseView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationBaseView.heightAnchor.constraint(equalToConstant: 70),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationBaseView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.backButton.centerYAnchor),

            self.backButton.leadingAnchor.constraint(equalTo: self.navigationBaseView.leadingAnchor, constant: 27),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationBaseView.centerYAnchor),
            self.backButton.widthAnchor.constraint(equalTo: self.backButton.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
        ])

        NSLayoutConstraint.activate([
            self.contentScrollView.topAnchor.constraint(equalTo: self.navigationBaseView.bottomAnchor),
            self.contentScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.contentScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.contentScrollView.bottomAnchor.constraint(equalTo: self.bottomBaseView.topAnchor, constant: -8),

            self.contentBaseView.topAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.topAnchor),
            self.contentBaseView.leadingAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.leadingAnchor),
            self.contentBaseView.trailingAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.trailingAnchor),
            self.contentBaseView.bottomAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.bottomAnchor),
            self.contentBaseView.widthAnchor.constraint(equalTo: self.contentScrollView.frameLayoutGuide.widthAnchor),

            self.descriptionTextLabel.topAnchor.constraint(equalTo: self.contentBaseView.topAnchor, constant: 12),
            self.descriptionTextLabel.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 34),
            self.descriptionTextLabel.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -34),
        ])

        NSLayoutConstraint.activate([
            self.descriptionTextLabel.bottomAnchor.constraint(equalTo: self.settingsStackView.topAnchor, constant: -24),

            self.settingsStackView.leadingAnchor.constraint(equalTo: self.descriptionTextLabel.leadingAnchor),
            self.settingsStackView.trailingAnchor.constraint(equalTo: self.descriptionTextLabel.trailingAnchor),
            self.settingsStackView.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor, constant: -12),

            self.essencialBaseView.heightAnchor.constraint(equalToConstant: 46),
            self.essencialLabel.centerYAnchor.constraint(equalTo: self.essencialBaseView.centerYAnchor),
            self.essencialLabel.leadingAnchor.constraint(equalTo: self.essencialBaseView.leadingAnchor, constant: 16),

            self.essencialLabel.trailingAnchor.constraint(equalTo: self.essencialSwitch.leadingAnchor, constant: -4),
            self.essencialSwitch.centerYAnchor.constraint(equalTo: self.essencialBaseView.centerYAnchor),
            self.essencialSwitch.trailingAnchor.constraint(equalTo: self.essencialBaseView.trailingAnchor, constant: -16),

            self.audienceBaseView.heightAnchor.constraint(equalToConstant: 46),
            self.audienceLabel.centerYAnchor.constraint(equalTo: self.audienceBaseView.centerYAnchor),
            self.audienceLabel.leadingAnchor.constraint(equalTo: self.audienceBaseView.leadingAnchor, constant: 16),

            self.audienceLabel.trailingAnchor.constraint(equalTo: self.audienceSwitch.leadingAnchor, constant: -4),
            self.audienceSwitch.centerYAnchor.constraint(equalTo: self.audienceBaseView.centerYAnchor),
            self.audienceSwitch.trailingAnchor.constraint(equalTo: self.audienceBaseView.trailingAnchor, constant: -16),

            self.offersBaseView.heightAnchor.constraint(equalToConstant: 46),
            self.offersLabel.centerYAnchor.constraint(equalTo: self.offersBaseView.centerYAnchor),
            self.offersLabel.leadingAnchor.constraint(equalTo: self.offersBaseView.leadingAnchor, constant: 16),

            self.offersLabel.trailingAnchor.constraint(equalTo: self.offersSwitch.leadingAnchor, constant: -4),
            self.offersSwitch.centerYAnchor.constraint(equalTo: self.offersBaseView.centerYAnchor),
            self.offersSwitch.trailingAnchor.constraint(equalTo: self.offersBaseView.trailingAnchor, constant: -16),
        ])

        NSLayoutConstraint.activate([
            self.continueButton.heightAnchor.constraint(equalToConstant: 50),
            self.skipButton.heightAnchor.constraint(equalToConstant: 50),

            self.buttonsStackView.leadingAnchor.constraint(equalTo: self.bottomBaseView.leadingAnchor, constant: 34),
            self.buttonsStackView.trailingAnchor.constraint(equalTo: self.bottomBaseView.trailingAnchor, constant: -34),
            self.buttonsStackView.bottomAnchor.constraint(equalTo: self.bottomBaseView.bottomAnchor),
            self.buttonsStackView.topAnchor.constraint(equalTo: self.bottomBaseView.topAnchor),

            self.bottomBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomBaseView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])

    }

}
