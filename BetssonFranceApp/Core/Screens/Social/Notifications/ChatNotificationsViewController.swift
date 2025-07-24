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
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var scrollContainerView: UIView = Self.createScrollContainerView()
    private lazy var friendsBaseView: UIView = Self.createFriendsBaseView()
    private lazy var friendsTitleLabel: UILabel = Self.createFriendsTitleLabel()
    private lazy var friendsStackView: UIStackView = Self.createFriendsStackView()
    private lazy var notificationsBaseView: UIView = Self.createNotificationsBaseView()
    private lazy var notificationsTitleLabel: UILabel = Self.createNotificationsTitleLabel()
    private lazy var readAllButon: UIButton = Self.createReadAllButton()
    private lazy var notificationStackView: UIStackView = Self.createNotificationsStackView()
    private lazy var emptyStateView: UIView = Self.createEmptyStateView()
    private lazy var emptyStateImageView: UIImageView = Self.createEmptyStateImageView()
    private lazy var emptyStateLabel: UILabel = Self.createEmptyStateLabel()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()
    
    // Constraints
    private lazy var notificationsToFriendsTopConstraints: NSLayoutConstraint = Self.createNotificationsToFriendsTopConstraints()
    private lazy var notificationsToScrollTopConstraints: NSLayoutConstraint = Self.createNotificationsToScrollTopConstraints()


    private var viewModel: ChatNotificationsViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
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
        
        self.readAllButon.addTarget(self, action: #selector(didTapReadAllButton), for: .primaryActionTriggered)

        self.isEmptyState = false

    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()
        
        self.friendsBaseView.layer.cornerRadius = CornerRadius.status
        
        self.notificationsBaseView.layer.cornerRadius = CornerRadius.status

        self.emptyStateImageView.layer.cornerRadius = self.emptyStateImageView.frame.height / 2
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundSecondary

        self.topSafeAreaView.backgroundColor = .clear
        self.bottomSafeAreaView.backgroundColor = .clear
        self.navigationView.backgroundColor = UIColor.App.backgroundSecondary
        self.backButton.backgroundColor = .clear
        self.titleLabel.textColor = UIColor.App.textPrimary

        self.scrollView.backgroundColor = .clear
        
        self.scrollContainerView.backgroundColor = .clear
        
        self.friendsBaseView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.friendsTitleLabel.textColor = UIColor.App.textPrimary
        
        self.friendsStackView.backgroundColor = .clear
        
        self.notificationsBaseView.backgroundColor = .clear
        self.notificationsBaseView.layer.borderColor = UIColor.App.backgroundBorder.cgColor

        self.notificationsTitleLabel.textColor = UIColor.App.textPrimary
        
        self.readAllButon.setTitleColor(UIColor.App.textSecondary, for: .normal)
        
        self.notificationStackView.backgroundColor = .clear

        self.emptyStateView.backgroundColor = UIColor.App.backgroundSecondary
        self.emptyStateImageView.backgroundColor = .clear
        self.emptyStateLabel.textColor = UIColor.App.textPrimary

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary
    }

    // MARK: Binding
    func bind(toViewModel viewModel: ChatNotificationsViewModel) {

        Publishers.CombineLatest(viewModel.friendRequestsPublisher, viewModel.chatNotificationsPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] friendRequest, chatNotifications in

                if friendRequest.isEmpty && chatNotifications.isEmpty {
                    self?.isEmptyState = true
                }
                else {
                    self?.isEmptyState = false
                }
                
                self?.friendsBaseView.isHidden = friendRequest.isEmpty ? true : false
                
                self?.notificationsBaseView.isHidden = chatNotifications.isEmpty ? true : false
                
                if friendRequest.isEmpty {
                    self?.notificationsToScrollTopConstraints.isActive = true
                    self?.notificationsToFriendsTopConstraints.isActive = false
                }
                else {
                    self?.notificationsToScrollTopConstraints.isActive = false
                    self?.notificationsToFriendsTopConstraints.isActive = true
                }

            })
            .store(in: &cancellables)

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                self?.isLoading = isLoading
                
                if !isLoading {
                    self?.setupFriendsStackView()
                    self?.setupNotificationsStackView()
                }
            })
            .store(in: &cancellables)

        viewModel.shouldReloadData = { [weak self] in
            self?.setupFriendsStackView()
            self?.setupNotificationsStackView()
        }

    }
    
    private func setupFriendsStackView() {
        
        for arrangedSubview in  self.friendsStackView.arrangedSubviews {
            self.friendsStackView.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }
        
        let friendRequests = viewModel.friendRequestsPublisher.value
                
        for (index, friendRequest) in friendRequests.enumerated() {
            if let friendRequestViewModel = viewModel.friendRequestViewModel(forIndex: index) {
                
                let friendRequestView = FriendRequestView()
                
                friendRequestView.configure(viewModel: friendRequestViewModel)
                
                friendRequestView.hasSeparatorLine = friendRequests.count - 1 == index ? false : true
                
                friendRequestView.tappedActionButton = { [weak self] userId in
                    self?.viewModel.approveFriendRequest(friendRequestId: userId)
                }
                
                friendRequestView.tappedCloseButton = { [weak self] userId in
                    self?.viewModel.rejectFriendRequest(friendRequestId: userId)
                }
                
                self.friendsStackView.addArrangedSubview(friendRequestView)
                
            }
            
        }
        
        self.friendsStackView.setNeedsLayout()
        self.friendsStackView.layoutIfNeeded()
    }
    
    private func setupNotificationsStackView() {
        
        for arrangedSubview in  self.notificationStackView.arrangedSubviews {
            self.notificationStackView.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }
        
        let notifications = viewModel.chatNotificationsPublisher.value
        
        for (index, notification) in notifications.enumerated() {
            if let notificationViewModel = viewModel.notificationViewModel(forIndex: index) {
                
                let notificationView = NotificationView()
                
                notificationView.configure(viewModel: notificationViewModel)
                
                notificationView.hasSeparatorLine = notifications.count - 1 == index ? false : true
                
                self.notificationStackView.addArrangedSubview(notificationView)
                
            }
            
        }
        
        self.notificationStackView.setNeedsLayout()
        self.notificationStackView.layoutIfNeeded()
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

//    @objc func didTapNotificationButton() {
//
//        if self.isNotificationMuted == false {
//            let alert = UIAlertController(
//                title: "Mute notifications",
//                message: nil,
//                preferredStyle: .actionSheet
//            )
//            alert.addAction(UIAlertAction(
//                title: "For 15 minutes",
//                style: .default,
//                handler: { _ in
//                    print("15MIN")
//                    self.isNotificationMuted = true
//            }))
//            alert.addAction(UIAlertAction(
//                title: "For 1 hour",
//                style: .default,
//                handler: { _ in
//                    print("1H")
//                    self.isNotificationMuted = true
//
//            }))
//            alert.addAction(UIAlertAction(
//                title: "For 8 hours",
//                style: .default,
//                handler: { _ in
//                    print("8H")
//                    self.isNotificationMuted = true
//
//            }))
//            alert.addAction(UIAlertAction(
//                title: "For 24 hours",
//                style: .default,
//                handler: { _ in
//                    print("24H")
//                    self.isNotificationMuted = true
//
//            }))
//            alert.addAction(UIAlertAction(
//                title: "Until I turn it back on",
//                style: .default,
//                handler: { _ in
//                    print("ALWAYS")
//                    self.isNotificationMuted = true
//            }))
//            alert.addAction(UIAlertAction(
//                title: localized("cancel"),
//                style: .cancel,
//                handler: { _ in
//                print("CANCEL")
//            }))
//            present(alert,
//                    animated: true,
//                    completion: nil
//            )
//        }
//        else {
//            self.isNotificationMuted = false
//        }
//    }

    @objc func didTapReadAllButton() {
        self.viewModel.markNotificationsAsRead()

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

    private static func createReadAllButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("read_all"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 12)
        button.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }
    
    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    private static func createScrollContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createFriendsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }
    
    private static func createFriendsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("friend_requests")
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        return label
    }
    
    private static func createFriendsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }
    
    private static func createNotificationsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        return view
    }
    
    private static func createNotificationsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(localized("notifications")):"
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        return label
    }
    
    private static func createNotificationsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
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
    
    // Constraints
    private static func createNotificationsToFriendsTopConstraints() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private static func createNotificationsToScrollTopConstraints() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.titleLabel)

        self.view.addSubview(self.scrollView)

        self.scrollView.addSubview(self.scrollContainerView)
        
        self.scrollContainerView.addSubview(self.friendsBaseView)
        
        self.friendsBaseView.addSubview(self.friendsTitleLabel)
        self.friendsBaseView.addSubview(self.friendsStackView)
        
        self.scrollContainerView.addSubview(self.notificationsBaseView)
        
        self.notificationsBaseView.addSubview(self.notificationsTitleLabel)
        self.notificationsBaseView.addSubview(self.readAllButon)
        self.notificationsBaseView.addSubview(self.notificationStackView)
        
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

            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor)
        ])

        // Scroll view
        NSLayoutConstraint.activate([

            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),

            self.scrollContainerView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.scrollContainerView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.scrollContainerView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.scrollContainerView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.scrollContainerView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor),
            
            self.friendsBaseView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 15),
            self.friendsBaseView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -15),
            self.friendsBaseView.topAnchor.constraint(equalTo: self.scrollContainerView.topAnchor, constant: 10),
            
            self.friendsTitleLabel.leadingAnchor.constraint(equalTo: self.friendsBaseView.leadingAnchor, constant: 16),
            self.friendsTitleLabel.trailingAnchor.constraint(equalTo: self.friendsBaseView.trailingAnchor, constant: -16),
            self.friendsTitleLabel.topAnchor.constraint(equalTo: self.friendsBaseView.topAnchor, constant: 16),
            
            self.friendsStackView.leadingAnchor.constraint(equalTo: self.friendsBaseView.leadingAnchor),
            self.friendsStackView.trailingAnchor.constraint(equalTo: self.friendsBaseView.trailingAnchor),
            self.friendsStackView.topAnchor.constraint(equalTo: self.friendsTitleLabel.bottomAnchor, constant: 7),
            self.friendsStackView.bottomAnchor.constraint(equalTo: self.friendsBaseView.bottomAnchor, constant: -4),
            
            self.notificationsBaseView.leadingAnchor.constraint(equalTo: self.scrollContainerView.leadingAnchor, constant: 15),
            self.notificationsBaseView.trailingAnchor.constraint(equalTo: self.scrollContainerView.trailingAnchor, constant: -15),
            self.notificationsBaseView.bottomAnchor.constraint(equalTo: self.scrollContainerView.bottomAnchor, constant: -10),
            
            self.notificationsTitleLabel.leadingAnchor.constraint(equalTo: self.notificationsBaseView.leadingAnchor, constant: 15),
            self.notificationsTitleLabel.topAnchor.constraint(equalTo: self.notificationsBaseView.topAnchor, constant: 18),
//            self.notificationsTitleLabel.trailingAnchor.constraint(equalTo: self.notificationsBaseView.trailingAnchor, constant: -15),
            
            self.readAllButon.trailingAnchor.constraint(equalTo: self.notificationsBaseView.trailingAnchor, constant: -15),
            self.readAllButon.leadingAnchor.constraint(equalTo: self.notificationsTitleLabel.trailingAnchor, constant: 10),
            self.readAllButon.centerYAnchor.constraint(equalTo: self.notificationsTitleLabel.centerYAnchor),
            self.readAllButon.heightAnchor.constraint(equalToConstant: 40),
            
            self.notificationStackView.leadingAnchor.constraint(equalTo: self.notificationsBaseView.leadingAnchor),
            self.notificationStackView.trailingAnchor.constraint(equalTo: self.notificationsBaseView.trailingAnchor),
            self.notificationStackView.topAnchor.constraint(equalTo: self.notificationsTitleLabel.bottomAnchor, constant: 12),
            self.notificationStackView.bottomAnchor.constraint(equalTo: self.notificationsBaseView.bottomAnchor, constant: -12)

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
        
        self.notificationsToFriendsTopConstraints =             self.notificationsBaseView.topAnchor.constraint(equalTo: self.friendsBaseView.bottomAnchor, constant: 16)

        self.notificationsToFriendsTopConstraints.isActive = true
        
        self.notificationsToScrollTopConstraints =             self.notificationsBaseView.topAnchor.constraint(equalTo: self.scrollContainerView.topAnchor, constant: 10)

        self.notificationsToScrollTopConstraints.isActive = false
    }
}
