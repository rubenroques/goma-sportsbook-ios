//
//  TipsSettingsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 29/09/2022.
//

import UIKit
import Combine

class TipsSettingsViewModel {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var bettingUserSettings: BettingUserSettings?

    init() {

        self.getUserSettings()
    }

    // MARK: Setup and functions
    private func getUserSettings() {
        self.bettingUserSettings = UserDefaults.standard.bettingUserSettings
    }

    func storeBettingUserSettings() {
        if let bettingUserSettings = self.bettingUserSettings {
            UserDefaults.standard.bettingUserSettings = bettingUserSettings
            let newBetting = UserDefaults.standard.bettingUserSettings
            self.postOddsSettingsToGoma()
        }
    }

    func updateAnonymousTipsSetting(enabled: Bool) {
        self.bettingUserSettings?.anonymousTips = enabled
        self.storeBettingUserSettings()
    }

    private func postOddsSettingsToGoma() {
        let bettingUserSettings = UserDefaults.standard.bettingUserSettings
        Env.gomaNetworkClient.postBettingUserSettings(deviceId: Env.deviceId, bettingUserSettings: bettingUserSettings)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print("PostSettings Betting completion \(completion)")
            }, receiveValue: { response in
                print("PostSettings Betting response \(response)")
            })
            .store(in: &cancellables)
    }
}

class TipsSettingsViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var tipsStackView: UIStackView = Self.createTipsStackView()

    // MARK: Public Properties
    var viewModel: TipsSettingsViewModel

    // MARK: - Lifetime and Cycle
    init(viewModel: TipsSettingsViewModel) {
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

        self.setupTopStackView()

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

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

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.tipsStackView.backgroundColor = UIColor.App.backgroundSecondary

    }

    // MARK: Functions
    private func setupTopStackView() {

        let anonymousTipsInfoView = SettingsRowView()
        anonymousTipsInfoView.setTitle(title: localized("anonymous_tips_info"))

        let anonymousTipsView = SettingsRowView()
        anonymousTipsView.setTitle(title: localized("anonymous_tips"))
        anonymousTipsView.hasSwitchButton = true

        anonymousTipsView.didTappedSwitch = { [weak self] isSwitchOn in
            self?.viewModel.updateAnonymousTipsSetting(enabled: isSwitchOn)
        }

        // Check options
        if let tipsUserSettings = self.viewModel.bettingUserSettings {

            if tipsUserSettings.anonymousTips {
                anonymousTipsView.isSwitchOn = true
            }
            else {
                anonymousTipsView.isSwitchOn = false
            }

        }

        self.tipsStackView.addArrangedSubview(anonymousTipsInfoView)
        self.tipsStackView.addArrangedSubview(anonymousTipsView)
    }

    // MARK: Actions
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension TipsSettingsViewController {
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

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = localized("tips")
        return label
    }

    private static func createTipsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.layer.cornerRadius = CornerRadius.button
        return stackView
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.titleLabel)

        self.view.addSubview(self.tipsStackView)

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
            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 0),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor)

        ])

        // Tips StackView
        NSLayoutConstraint.activate([
            self.tipsStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.tipsStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.tipsStackView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 8),

        ])

    }
}
