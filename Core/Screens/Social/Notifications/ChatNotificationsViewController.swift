//
//  ChatNotificationsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 13/04/2022.
//

import UIKit
import Combine

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
    private lazy var chatNotificationsStackView: UIStackView = Self.createChatNotificationsStackView()
    private lazy var sharedTicketsStackView: UIStackView = Self.createSharedTicketsStackView()
    private lazy var emptyStateView: UIView = Self.createEmptyStateView()
    private lazy var emptyStateImageView: UIImageView = Self.createEmptyStateImageView()
    private lazy var emptyStateLabel: UILabel = Self.createEmptyStateLabel()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()

    private var viewModel: ChatNotificationsViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var isNotificationMuted: Bool = true {
        didSet {
            if isNotificationMuted {
                self.notificationsButton.setImage(UIImage(named: "notifications_status_on_icon"), for: UIControl.State.normal)
            }
            else {
                self.notificationsButton.setImage(UIImage(named: "notifications_status_icon"), for: UIControl.State.normal)
            }
        }
    }

    var isEmptyState: Bool = false {
        didSet {
            self.emptyStateView.isHidden = !isEmptyState
        }
    }

    var isLoading: Bool = false {
        didSet {
            self.loadingBaseView.isHidden = !isLoading
        }
    }

    // MARK: - Lifetime and Cycle
    init(viewModel: ChatNotificationsViewModel = ChatNotificationsViewModel()) {
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

        self.bind(toViewModel: self.viewModel)

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)
        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)
        self.notificationsButton.addTarget(self, action: #selector(didTapNotificationButton), for: .primaryActionTriggered)
        self.clearAllButon.addTarget(self, action: #selector(didTapClearAllButton), for: .primaryActionTriggered)

        self.isNotificationMuted = false

        self.isEmptyState = false

    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        self.emptyStateImageView.layer.cornerRadius = self.emptyStateImageView.frame.height / 2

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

        self.chatNotificationsStackView.backgroundColor = UIColor.App.backgroundSecondary
        self.sharedTicketsStackView.backgroundColor = UIColor.App.backgroundSecondary

        self.emptyStateView.backgroundColor = UIColor.App.backgroundPrimary
        self.emptyStateImageView.backgroundColor = .clear
        self.emptyStateLabel.textColor = UIColor.App.textPrimary

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary
    }

    // MARK: Binding
    func bind(toViewModel viewModel: ChatNotificationsViewModel) {

        viewModel.shouldRemoveFollowerView = { [weak self] userActionView in
            self?.chatNotificationsStackView.removeArrangedSubview(userActionView)
        }

        viewModel.isEmptyStatePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isEmptyState in
                self?.isEmptyState = isEmptyState
            })
            .store(in: &cancellables)

        viewModel.chatNotificationsPublisher
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] chatNotifications in
                if chatNotifications.isEmpty {
                    self?.chatNotificationsStackView.isHidden = true
                }
                else {
                    self?.chatNotificationsStackView.isHidden = false
                }
            })
            .store(in: &cancellables)

        viewModel.chatNotificationViewsPublisher
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] chatViews in
                if chatViews.isEmpty {
                    self?.chatNotificationsStackView.removeAllArrangedSubviews()
                    self?.isEmptyState = true
                }
                else {
                    self?.setupChatNotificationsStackView()
                    self?.isEmptyState = false
                }
            })
            .store(in: &cancellables)

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                self?.isLoading = isLoading
            })
            .store(in: &cancellables)

    }

    // MARK: Functions

    private func setupChatNotificationsStackView() {

        for (index, userActionView) in self.viewModel.chatNotificationViewsPublisher.value.enumerated() {

            if index == self.viewModel.chatNotificationViewsPublisher.value.count - 1 {
                userActionView.hasLineSeparator = false
            }

            self.chatNotificationsStackView.addArrangedSubview(userActionView)
        }
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

        if self.isNotificationMuted == false {
            let alert = UIAlertController(
                title: "Mute notifications",
                message: nil,
                preferredStyle: .actionSheet
            )
            alert.addAction(UIAlertAction(
                title: "For 15 minutes",
                style: .default,
                handler: { _ in
                    print("15MIN")
                    self.isNotificationMuted = true
            }))
            alert.addAction(UIAlertAction(
                title: "For 1 hour",
                style: .default,
                handler: { _ in
                    print("1H")
                    self.isNotificationMuted = true

            }))
            alert.addAction(UIAlertAction(
                title: "For 8 hours",
                style: .default,
                handler: { _ in
                    print("8H")
                    self.isNotificationMuted = true

            }))
            alert.addAction(UIAlertAction(
                title: "For 24 hours",
                style: .default,
                handler: { _ in
                    print("24H")
                    self.isNotificationMuted = true

            }))
            alert.addAction(UIAlertAction(
                title: "Until I turn it back on",
                style: .default,
                handler: { _ in
                    print("ALWAYS")
                    self.isNotificationMuted = true
            }))
            alert.addAction(UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: { _ in
                print("CANCEL")
            }))
            present(alert,
                    animated: true,
                    completion: nil
            )
        }
        else {
            self.isNotificationMuted = false
        }
    }

    @objc func didTapClearAllButton() {
        self.chatNotificationsStackView.removeAllArrangedSubviews()
        // self.sharedTicketsStackView.removeAllArrangedSubviews()
        self.isEmptyState = true
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
        button.setImage(UIImage(named: "notifications_status_on_icon"), for: .normal)
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
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
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

    private static func createChatNotificationsStackView() -> UIStackView {
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

    private static func createEmptyStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createEmptyStateImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "no_content_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("no_notifications")
        label.numberOfLines = 0
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .center
        return label
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        return activityIndicatorView
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

        self.scrollView.addSubview(self.chatNotificationsStackView)
        //self.scrollView.addSubview(self.sharedTicketsStackView)

        self.view.addSubview(self.emptyStateView)

        self.emptyStateView.addSubview(self.emptyStateImageView)
        self.emptyStateView.addSubview(self.emptyStateLabel)

        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.activityIndicatorView)

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

            self.notificationsButton.leadingAnchor.constraint(equalTo: self.backButton.trailingAnchor, constant: 0),
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
            self.clearAllButon.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 0),
            self.clearAllButon.heightAnchor.constraint(equalToConstant: 40)
        ])

        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.clearAllButon.bottomAnchor, constant: 0),
            self.scrollView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),
            self.scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: self.view.widthAnchor),

            self.chatNotificationsStackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: 16),
            self.chatNotificationsStackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor, constant: -16),
            self.chatNotificationsStackView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.chatNotificationsStackView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor)

//            self.sharedTicketsStackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: 16),
//            self.sharedTicketsStackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor, constant: -16),
//            self.sharedTicketsStackView.topAnchor.constraint(equalTo: self.chatNotificationsStackView.bottomAnchor, constant: 30),
//            self.sharedTicketsStackView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.emptyStateView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.emptyStateView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.emptyStateView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.emptyStateView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),

            self.emptyStateImageView.topAnchor.constraint(equalTo: self.emptyStateView.topAnchor, constant: 60),
            self.emptyStateImageView.widthAnchor.constraint(equalToConstant: 120),
            self.emptyStateImageView.heightAnchor.constraint(equalTo: self.emptyStateImageView.widthAnchor),
            self.emptyStateImageView.centerXAnchor.constraint(equalTo: self.emptyStateView.centerXAnchor),

            self.emptyStateLabel.leadingAnchor.constraint(equalTo: self.emptyStateView.leadingAnchor, constant: 80),
            self.emptyStateLabel.trailingAnchor.constraint(equalTo: self.emptyStateView.trailingAnchor, constant: -80),
            self.emptyStateLabel.topAnchor.constraint(equalTo: self.emptyStateImageView.bottomAnchor, constant: 30)
        ])

        // Loading Screen
        NSLayoutConstraint.activate([
            self.loadingBaseView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor)
        ])
    }
}
