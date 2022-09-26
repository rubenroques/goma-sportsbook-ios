//
//  GamesNotificationViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 18/02/2022.
//

import UIKit
import Combine

class GamesNotificationViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var topStackView: UIStackView = Self.createTopStackView()
    private lazy var bottomStackView: UIStackView = Self.createBottomStackView()
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: GamesNotificationViewModel
    var shouldUpdateSettings: Bool = false

    var isBottomStackViewDisabled: Bool = false {
        didSet {
            if isBottomStackViewDisabled {
                self.bottomStackView.alpha = 0.7
                self.bottomStackView.isUserInteractionEnabled = false
            }
            else {
                self.bottomStackView.alpha = 1.0
                self.bottomStackView.isUserInteractionEnabled = true
            }
        }
    }
    // MARK: Lifetime and Cycle
    init() {
        self.viewModel = GamesNotificationViewModel()
        super.init(nibName: nil, bundle: nil)

        self.bind(toViewModel: self.viewModel)
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // self.viewModel.storeNotificationsUserSettings()
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

        self.scrollView.backgroundColor = .clear

        self.topStackView.backgroundColor = UIColor.App.backgroundSecondary

        self.bottomStackView.backgroundColor = UIColor.App.backgroundSecondary

    }

    // MARK: Binding
    private func bind(toViewModel viewModel: GamesNotificationViewModel) {

        viewModel.isStackViewDisabledPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] disabledState in
                self?.isBottomStackViewDisabled = disabledState
            })
            .store(in: &cancellables)

    }

    private func setupTopStackView() {
        let myGamesView = SettingsRowView()
        myGamesView.setTitle(title: localized("allow_mygames_notifications"))
        myGamesView.hasSeparatorLineView = true
        myGamesView.hasSwitchButton = true
        self.viewModel.setGamesSelectedOption(view: myGamesView, settingType: .gamesWatchList)
        myGamesView.didTappedSwitch = { [weak self] in
            self?.viewModel.checkBottomStackViewDisableState()
            self?.viewModel.updateGamesSetting(isSettingEnabled: myGamesView.isSwitchOn, settingType: .gamesWatchList)
        }
        self.viewModel.notificationsEnabledViews.append(myGamesView)

        let myCompetitionsView = SettingsRowView()
        myCompetitionsView.setTitle(title: localized("allow_mycompetitions_notifications"))
        myCompetitionsView.hasSwitchButton = true
        self.viewModel.setGamesSelectedOption(view: myCompetitionsView, settingType: .competitionWatchList)
        myCompetitionsView.didTappedSwitch = { [weak self] in
            self?.viewModel.checkBottomStackViewDisableState()
            self?.viewModel.updateGamesSetting(isSettingEnabled: myCompetitionsView.isSwitchOn, settingType: .competitionWatchList)
        }
        self.viewModel.notificationsEnabledViews.append(myCompetitionsView)

        self.topStackView.addArrangedSubview(myGamesView)
        self.topStackView.addArrangedSubview(myCompetitionsView)

        self.viewModel.checkNotificationSwitches()

    }

    private func setupBottomStackView() {

        let notifyAboutView = SettingsRowView()
        notifyAboutView.setTitle(title: localized("notify_me_about"))

        let startGameView = SettingsRowView()
        startGameView.setTitle(title: localized("start_of_game"))
        startGameView.hasSwitchButton = true
        startGameView.hasSeparatorLineView = true
        self.viewModel.setGamesSelectedOption(view: startGameView, settingType: .startGame)
        startGameView.didTappedSwitch = {
            self.viewModel.updateGamesSetting(isSettingEnabled: startGameView.isSwitchOn, settingType: .startGame)
        }

        let goalsView = SettingsRowView()
        goalsView.setTitle(title: localized("goals"))
        goalsView.hasSwitchButton = true
        goalsView.hasSeparatorLineView = true
        self.viewModel.setGamesSelectedOption(view: goalsView, settingType: .goals)
        goalsView.didTappedSwitch = {
            self.viewModel.updateGamesSetting(isSettingEnabled: goalsView.isSwitchOn, settingType: .goals)
        }

        let halfTimeView = SettingsRowView()
        halfTimeView.setTitle(title: localized("half_time"))
        halfTimeView.hasSwitchButton = true
        halfTimeView.hasSeparatorLineView = true
        self.viewModel.setGamesSelectedOption(view: halfTimeView, settingType: .halfTime)
        halfTimeView.didTappedSwitch = {
            self.viewModel.updateGamesSetting(isSettingEnabled: halfTimeView.isSwitchOn, settingType: .halfTime)
        }

        let secondHalfTimeView = SettingsRowView()
        secondHalfTimeView.setTitle(title: localized("second_half_time"))
        secondHalfTimeView.hasSwitchButton = true
        secondHalfTimeView.hasSeparatorLineView = true
        self.viewModel.setGamesSelectedOption(view: secondHalfTimeView, settingType: .secondHalfTime)
        secondHalfTimeView.didTappedSwitch = {
            self.viewModel.updateGamesSetting(isSettingEnabled: secondHalfTimeView.isSwitchOn, settingType: .secondHalfTime)
        }

        let fullTimeView = SettingsRowView()
        fullTimeView.setTitle(title: localized("full_time"))
        fullTimeView.hasSwitchButton = true
        fullTimeView.hasSeparatorLineView = true
        self.viewModel.setGamesSelectedOption(view: fullTimeView, settingType: .fullTime)
        fullTimeView.didTappedSwitch = {
            self.viewModel.updateGamesSetting(isSettingEnabled: fullTimeView.isSwitchOn, settingType: .fullTime)
        }

        let redCardsView = SettingsRowView()
        redCardsView.setTitle(title: localized("red_cards"))
        redCardsView.hasSwitchButton = true
        self.viewModel.setGamesSelectedOption(view: redCardsView, settingType: .redCard)
        redCardsView.didTappedSwitch = {
            self.viewModel.updateGamesSetting(isSettingEnabled: redCardsView.isSwitchOn, settingType: .redCard)
        }

        self.bottomStackView.addArrangedSubview(notifyAboutView)
        self.bottomStackView.addArrangedSubview(startGameView)
        self.bottomStackView.addArrangedSubview(goalsView)
        self.bottomStackView.addArrangedSubview(halfTimeView)
        self.bottomStackView.addArrangedSubview(secondHalfTimeView)
        self.bottomStackView.addArrangedSubview(fullTimeView)
        self.bottomStackView.addArrangedSubview(redCardsView)

    }

}

//
// MARK: - Actions
//
extension GamesNotificationViewController {
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

//
// MARK: Subviews initialization and setup
//
extension GamesNotificationViewController {

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
        label.text = localized("games_notifications")
        label.font = AppFont.with(type: .bold, size: 17)
        label.textAlignment = .center
        return label
    }

    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
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

        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.topStackView)
        self.scrollView.addSubview(self.bottomStackView)

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

        // Scrollview
        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.topView.bottomAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.topStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.topStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.topStackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: 8),

            self.bottomStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.bottomStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.bottomStackView.topAnchor.constraint(equalTo: self.topStackView.bottomAnchor, constant: 16)
        ])

    }

}
