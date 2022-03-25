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
    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: SocialViewModel) {

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

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)
        self.navigationView.addSubview(self.titleLabel)

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
            self.titleLabel.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 80),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            self.containerBaseView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.containerBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.containerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])

    }
}
