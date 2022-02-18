//
//  GamesNotificationViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 18/02/2022.
//

import UIKit

class GamesNotificationViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var topStackView: UIStackView = Self.createTopStackView()
    private lazy var bottomStackView: UIStackView = Self.createBottomStackView()

    // MARK: Public Properties
    var notificationsEnabledViews: [SettingsRowView] = []

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

        self.scrollView.backgroundColor = .clear

        self.topStackView.backgroundColor = UIColor.App.backgroundSecondary

        self.bottomStackView.backgroundColor = UIColor.App.backgroundSecondary

    }

    private func setupTopStackView() {
        let myGamesView = SettingsRowView()
        myGamesView.setTitle(title: localized("allow_mygames_notifications"))
        myGamesView.hasSeparatorLineView = true
        myGamesView.hasSwitchButton = true
        self.notificationsEnabledViews.append(myGamesView)

        let myCompetitionsView = SettingsRowView()
        myCompetitionsView.setTitle(title: localized("allow_mycompetitions_notifications"))
        myCompetitionsView.hasSwitchButton = true
        self.notificationsEnabledViews.append(myCompetitionsView)

        self.topStackView.addArrangedSubview(myGamesView)
        self.topStackView.addArrangedSubview(myCompetitionsView)

        self.checkNotificationSwitches()

    }

    private func setupBottomStackView() {

        let notifyAboutView = SettingsRowView()
        notifyAboutView.setTitle(title: localized("notify_me_about"))

        let startGameView = SettingsRowView()
        startGameView.setTitle(title: localized("start_of_game"))
        startGameView.hasSwitchButton = true
        startGameView.hasSeparatorLineView = true

        let goalsView = SettingsRowView()
        goalsView.setTitle(title: localized("goals"))
        goalsView.hasSwitchButton = true
        goalsView.hasSeparatorLineView = true

        let halfTimeView = SettingsRowView()
        halfTimeView.setTitle(title: localized("half_time"))
        halfTimeView.hasSwitchButton = true
        halfTimeView.hasSeparatorLineView = true

        let secondHalfTimeView = SettingsRowView()
        secondHalfTimeView.setTitle(title: localized("second_half_time"))
        secondHalfTimeView.hasSwitchButton = true
        secondHalfTimeView.hasSeparatorLineView = true

        let fullTimeView = SettingsRowView()
        fullTimeView.setTitle(title: localized("full_time"))
        fullTimeView.hasSwitchButton = true
        fullTimeView.hasSeparatorLineView = true

        let redCardsView = SettingsRowView()
        redCardsView.setTitle(title: localized("red_cards"))
        redCardsView.hasSwitchButton = true

        self.bottomStackView.addArrangedSubview(notifyAboutView)
        self.bottomStackView.addArrangedSubview(startGameView)
        self.bottomStackView.addArrangedSubview(goalsView)
        self.bottomStackView.addArrangedSubview(halfTimeView)
        self.bottomStackView.addArrangedSubview(secondHalfTimeView)
        self.bottomStackView.addArrangedSubview(fullTimeView)
        self.bottomStackView.addArrangedSubview(redCardsView)

    }

    private func checkNotificationSwitches() {
        var disabledStackView = true

        for view in self.notificationsEnabledViews {
            if view.isSwitchOn {
                disabledStackView = false
            }
            view.didTappedSwitch = {[weak self] in
                self?.checkBottomStackViewDisableState()
            }
        }

        self.isBottomStackViewDisabled = disabledStackView
    }

    private func checkBottomStackViewDisableState() {
        var disabledStackView = true

        for view in self.notificationsEnabledViews {
            if view.isSwitchOn {
                disabledStackView = false
            }

        }

        self.isBottomStackViewDisabled = disabledStackView

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
        label.text = localized("app_settings")
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
            self.topView.heightAnchor.constraint(equalToConstant: 70),

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 10),
            self.backButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 20),
            self.backButton.widthAnchor.constraint(equalToConstant: 15),

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
