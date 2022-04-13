//
//  SocialViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 23/03/2022.
//

import UIKit

class SocialViewModel {

    enum StartScreen {
        case conversations
        case friendsList
    }

    var startScreen: StartScreen

    init(startScreen: StartScreen = .conversations) {
        self.startScreen = startScreen

    }

}

extension SocialViewModel {

    func startPageIndex() -> Int {
        switch self.startScreen {
        case .conversations: return 0
        case .friendsList: return 1
        }
    }

}

class SocialViewController: UIViewController {

    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var containerBaseView: UIView = Self.createContainerBaseView()
    private lazy var notificationsButton: UIButton = Self.createNotificationsButton()
    private lazy var friendsButton: UIButton = Self.createFriendsButton()
    private lazy var settingsButton: UIButton = Self.createSettingsButton()
    private lazy var closeButton: UIButton = Self.createCloseButton()

    private var tabViewController: TabularViewController
    private var viewControllerTabDataSource: TitleTabularDataSource
    private var viewControllers: [UIViewController] = []

    private var conversationsViewController: ConversationsViewController
    private var friendsListViewController: FriendsListViewController

    private var viewModel: SocialViewModel

    // MARK: - Lifetime and Cycle
    init(viewModel: SocialViewModel = SocialViewModel()) {
        self.viewModel = viewModel

        self.conversationsViewController = ConversationsViewController(viewModel: ConversationsViewModel())
        self.friendsListViewController = FriendsListViewController(viewModel: FriendsListViewModel())

        self.viewControllers = [conversationsViewController, friendsListViewController]
        self.viewControllerTabDataSource = TitleTabularDataSource(with: viewControllers)

        self.viewControllerTabDataSource.initialPage = self.viewModel.startPageIndex()

        self.tabViewController = TabularViewController(dataSource: viewControllerTabDataSource)

        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()

        self.addChildViewController(tabViewController, toView: containerBaseView)
        self.tabViewController.textFont = AppFont.with(type: .bold, size: 16)

        self.setupWithTheme()

        self.notificationsButton.addTarget(self, action: #selector(didTapNotificationsButton), for: .primaryActionTriggered)

        self.friendsButton.addTarget(self, action: #selector(didTapFriendsButton), for: .primaryActionTriggered)

        self.settingsButton.addTarget(self, action: #selector(didTapSettingsButton), for: .primaryActionTriggered)

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)
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

        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary

        self.tabViewController.sliderBarColor = UIColor.App.highlightSecondary
        self.tabViewController.barColor = UIColor.App.backgroundPrimary
        self.tabViewController.textColor = UIColor.App.textPrimary
        self.tabViewController.separatorBarColor = UIColor.App.separatorLine

        self.titleLabel.backgroundColor = .clear
        self.titleLabel.textColor = UIColor.App.textPrimary

        self.containerBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.notificationsButton.backgroundColor = .clear

        self.friendsButton.backgroundColor = .clear

        self.settingsButton.backgroundColor = .clear

        self.closeButton.backgroundColor = .clear
        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: SocialViewModel) {

    }

    // MARK: Action

    @objc func didTapNotificationsButton() {
        print("NOTIFICATIONS")
        let notificationsViewController = ChatNotificationsViewController()

        self.navigationController?.pushViewController(notificationsViewController, animated: true)
    }

    @objc func didTapFriendsButton() {
        print("FRIENDS")
    }

    @objc func didTapSettingsButton() {
        print("SETTINGS")
    }

    @objc func didTapCloseButton() {
        print("CLOSE")

        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension SocialViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNavigationView() -> UIView {
        let navigationView = UIView()
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        return navigationView
    }

    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.App.textPrimary
        titleLabel.font = AppFont.with(type: .semibold, size: 16)
        titleLabel.textAlignment = .center
        titleLabel.text = "Chat"
        return titleLabel
    }

    private static func createBackButton() -> UIButton {
        let backButton = UIButton.init(type: .custom)
        backButton.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        backButton.setTitle(nil, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        return backButton
    }

    private static func createContainerBaseView() -> UIView {
        let containerBaseView = UIView()
        containerBaseView.translatesAutoresizingMaskIntoConstraints = false
        return containerBaseView
    }

    private static func createNotificationsButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "notification_inactive_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }

    private static func createFriendsButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "add_friend_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }

    private static func createSettingsButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "app_settings_profile_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("close"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 12)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)
        self.navigationView.addSubview(self.titleLabel)

        self.navigationView.addSubview(self.notificationsButton)
        self.navigationView.addSubview(self.friendsButton)
        self.navigationView.addSubview(self.settingsButton)
        self.navigationView.addSubview(self.closeButton)

        self.view.addSubview(self.containerBaseView)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.navigationView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 50),
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationView.centerXAnchor),
//            self.titleLabel.leadingAnchor.constraint(equalTo: self.friendsButton.trailingAnchor, constant: 8),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

            self.notificationsButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 8),
            self.notificationsButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.notificationsButton.widthAnchor.constraint(equalToConstant: 40),
            self.notificationsButton.heightAnchor.constraint(equalTo: self.notificationsButton.widthAnchor),

            self.friendsButton.leadingAnchor.constraint(equalTo: self.notificationsButton.trailingAnchor, constant: 8),
            self.friendsButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.friendsButton.widthAnchor.constraint(equalToConstant: 40),
            self.friendsButton.heightAnchor.constraint(equalTo: self.friendsButton.widthAnchor),

            self.settingsButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.settingsButton.widthAnchor.constraint(equalToConstant: 40),
            self.settingsButton.heightAnchor.constraint(equalTo: self.settingsButton.widthAnchor),

            self.closeButton.leadingAnchor.constraint(equalTo: self.settingsButton.trailingAnchor, constant: 8),
            self.closeButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -8),
            self.closeButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.closeButton.heightAnchor.constraint(equalToConstant: 40),
        ])

        NSLayoutConstraint.activate([
            self.containerBaseView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.containerBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.containerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])

    }
}
