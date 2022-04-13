//
//  ChatNotificationsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 13/04/2022.
//

import UIKit

class ChatNotificationsViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var notificationsButton: UIButton = Self.createNotificationsButton()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var clearAllButon: UIButton = Self.createClearAllButton()
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var followersStackView: UIStackView = Self.createFollowersStackView()
    private lazy var sharedTicketsStackView: UIStackView = Self.createSharedTicketsStackView()

    // MARK: Public Properties
    var isNotificationEnabled: Bool = false {
        didSet {
            if isNotificationEnabled {
                self.notificationsButton.setImage(UIImage(named: "notifications_status_on_icon"), for: UIControl.State.normal)
            }
            else {
                self.notificationsButton.setImage(UIImage(named: "notifications_status_icon"), for: UIControl.State.normal)
            }
        }
    }

    // MARK: - Lifetime and Cycle
    init(viewModel: ConversationDetailViewModel = ConversationDetailViewModel()) {
        //self.viewModel = viewModel
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

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)

        self.notificationsButton.addTarget(self, action: #selector(didTapNotificationButton), for: .primaryActionTriggered)

        self.clearAllButon.addTarget(self, action: #selector(didTapClearAllButton), for: .primaryActionTriggered)

        self.setupFollowersStackView()

        self.setupSharedTicketsStackView()

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

        self.notificationsButton.backgroundColor = .clear

        self.closeButton.backgroundColor = .clear
        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.clearAllButon.backgroundColor = .clear
        self.clearAllButon.setTitleColor(UIColor.App.textSecondary, for: .normal)

        self.scrollView.backgroundColor = .clear

        self.followersStackView.backgroundColor = UIColor.App.backgroundSecondary

        self.sharedTicketsStackView.backgroundColor = UIColor.App.backgroundSecondary

    }

    // MARK: Functions

    private func setupFollowersStackView() {

        let titleView = TitleView()
        titleView.setTitle(title: localized("users_followed_you"))

        self.followersStackView.addArrangedSubview(titleView)

        let followerView = UserActionView()
        followerView.isOnline = true
        let followerView2 = UserActionView()
        followerView2.isOnline = true
        let followerView3 = UserActionView()
        let followerView4 = UserActionView()
        followerView4.isOnline = true
        let followerView5 = UserActionView()
        let followerView6 = UserActionView()
        followerView6.isOnline = true
        followerView6.hasLineSeparator = false

        self.followersStackView.addArrangedSubview(followerView)
        self.followersStackView.addArrangedSubview(followerView2)
        self.followersStackView.addArrangedSubview(followerView3)
        self.followersStackView.addArrangedSubview(followerView4)
        self.followersStackView.addArrangedSubview(followerView5)
        self.followersStackView.addArrangedSubview(followerView6)

    }

    private func setupSharedTicketsStackView() {

        let titleView = TitleView()
        titleView.setTitle(title: localized("shared_tickets_to"))

        self.sharedTicketsStackView.addArrangedSubview(titleView)

        let sharedTicketView = UserActionView()
        let sharedTicketView2 = UserActionView()
        let sharedTicketView3 = UserActionView()
        sharedTicketView3.isOnline = true
        let sharedTicketView4 = UserActionView()
        let sharedTicketView5 = UserActionView()
        sharedTicketView5.isOnline = true
        let sharedTicketView6 = UserActionView()
        sharedTicketView6.isOnline = true
        sharedTicketView6.hasLineSeparator = false

        self.sharedTicketsStackView.addArrangedSubview(sharedTicketView)
        self.sharedTicketsStackView.addArrangedSubview(sharedTicketView2)
        self.sharedTicketsStackView.addArrangedSubview(sharedTicketView3)
        self.sharedTicketsStackView.addArrangedSubview(sharedTicketView4)
        self.sharedTicketsStackView.addArrangedSubview(sharedTicketView5)
        self.sharedTicketsStackView.addArrangedSubview(sharedTicketView6)

    }

    // MARK: Actions
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func didTapCloseButton() {

        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc func didTapNotificationButton() {
        if self.isNotificationEnabled == true {
            self.isNotificationEnabled = false
        }
        else {
            self.isNotificationEnabled = true
        }
    }

    @objc func didTapClearAllButton() {
        print("CLEAR ALL")
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension ChatNotificationsViewController {
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

    private static func createNotificationsButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "notifications_status_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = localized("notifications")
        return label
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("close"), for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 12)
        return button
    }

    private static func createClearAllButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("clear_all"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 12)
        return button
    }

    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    private static func createFollowersStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.distribution = .equalSpacing
        stackView.layer.cornerRadius = CornerRadius.view
        stackView.clipsToBounds = true
        return stackView
    }

    private static func createSharedTicketsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.distribution = .equalSpacing
        stackView.layer.cornerRadius = CornerRadius.view
        stackView.clipsToBounds = true
        return stackView
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.notificationsButton)
        self.navigationView.addSubview(self.titleLabel)
        self.navigationView.addSubview(self.closeButton)

        self.view.addSubview(self.clearAllButon)

        self.view.addSubview(self.scrollView)

        self.scrollView.addSubview(self.followersStackView)
        self.scrollView.addSubview(self.sharedTicketsStackView)

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
            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 10),

            self.notificationsButton.leadingAnchor.constraint(equalTo: self.backButton.trailingAnchor, constant: 8),
            self.notificationsButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.notificationsButton.widthAnchor.constraint(equalToConstant: 40),
            self.notificationsButton.heightAnchor.constraint(equalTo: self.notificationsButton.widthAnchor),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

            self.closeButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -16),
            self.closeButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        NSLayoutConstraint.activate([
            self.clearAllButon.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            self.clearAllButon.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 10),
            self.clearAllButon.heightAnchor.constraint(equalToConstant: 40)
        ])

        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.clearAllButon.bottomAnchor, constant: 8),
            self.scrollView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),
            self.scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: self.view.widthAnchor),

            self.followersStackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: 16),
            self.followersStackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor, constant: -16),
            self.followersStackView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor, constant: 20),

            self.sharedTicketsStackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: 16),
            self.sharedTicketsStackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor, constant: -16),
            self.sharedTicketsStackView.topAnchor.constraint(equalTo: self.followersStackView.bottomAnchor, constant: 30),
            self.sharedTicketsStackView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor)
        ])
    }
}
