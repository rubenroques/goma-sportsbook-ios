//
//  UserProfileViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 20/09/2022.
//

import UIKit
import Combine

class UserProfileViewController: UIViewController {

    // MARK: Private properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var userProfileActionsStackView: UIStackView = Self.createUserProfileActionsStackView()
    private lazy var followActionsStackView: UIStackView = Self.createFollowActionsStackView()
    private lazy var followButton: UIButton = Self.createFollowButton()
    private lazy var unfollowButton: UIButton = Self.createUnfollowButton()
    private lazy var friendActionsStackView: UIStackView = Self.createFriendActionsStackView()
    private lazy var addFriendButton: UIButton = Self.createAddFriendButton()
    private lazy var chatButton: UIButton = Self.createChatButton()
    private lazy var moreOptionsButton: UIButton = Self.createMoreOptionsButton()
    private lazy var userTopInfoView: UIView = Self.createUserTopInfoView()
    private lazy var userImageView: UIImageView = Self.createUserImageView()
    private lazy var usernameLabel: UILabel = Self.createUsernameLabel()
    private lazy var followersValueLabel: UILabel = Self.createFollowersValueLabel()
    private lazy var followersLabel: UILabel = Self.createFollowersLabel()
    private lazy var followingValueLabel: UILabel = Self.createFollowingValueLabel()
    private lazy var followingLabel: UILabel = Self.createFollowingLabel()
    private lazy var userInfoTabsContainerView: UIView = Self.createUserInfoTabsContainerView()

    private var tabViewController: TabularViewController
    private var viewControllerTabDataSource: TitleTabularDataSource
    private var viewControllers: [UIViewController] = []

    private var userInfoViewController: UserProfileInfoViewController
    private var userTipsViewController: UserProfileTipsViewController

    private var viewModel: UserProfileViewModel

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public properties
    var hasFollowOption: Bool = true {
        didSet {
            self.followButton.isHidden = !hasFollowOption
            self.unfollowButton.isHidden = hasFollowOption
        }
    }

    var hasFriendOption: Bool = true {
        didSet {
            self.addFriendButton.isHidden = !hasFriendOption
            self.chatButton.isHidden = hasFriendOption
        }
    }

    var isChatProfile: Bool = false {
        didSet {
            self.friendActionsStackView.isHidden = isChatProfile
        }
    }

    var isLoggedUser: Bool = false {
        didSet {
            self.userProfileActionsStackView.isHidden = isLoggedUser
            self.moreOptionsButton.isHidden = isLoggedUser
        }
    }

    var shouldCloseChat: (() -> Void)?
    var shouldReloadChatList: (() -> Void)?

    // MARK: - Lifetime and Cycle
    init(viewModel: UserProfileViewModel) {

        self.viewModel = viewModel

        self.userInfoViewController = UserProfileInfoViewController(viewModel: UserProfileInfoViewModel(userId: self.viewModel.getUserId()))
        self.userTipsViewController = UserProfileTipsViewController(viewModel: UserProfileTipsViewModel(userId: self.viewModel.getUserId()))

        self.viewControllers = [self.userInfoViewController, self.userTipsViewController]
        self.viewControllerTabDataSource = TitleTabularDataSource(with: viewControllers)

        self.viewControllerTabDataSource.initialPage = 0

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

        self.addChildViewController(tabViewController, toView: self.userInfoTabsContainerView)
        self.tabViewController.textFont = AppFont.with(type: .bold, size: 16)
        self.tabViewController.setBarDistribution(.parent)

        self.setupWithTheme()

        self.hasFollowOption = true

        self.hasFriendOption = true

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.followButton.addTarget(self, action: #selector(didTapFollowButton), for: .primaryActionTriggered)

        self.unfollowButton.addTarget(self, action: #selector(didTapUnfollowButton), for: .primaryActionTriggered)

        self.addFriendButton.addTarget(self, action: #selector(didTapAddFriendButton), for: .primaryActionTriggered)

        self.chatButton.addTarget(self, action: #selector(didTapChatButton), for: .primaryActionTriggered)

        self.moreOptionsButton.addTarget(self, action: #selector(didTapMoreOptionsButton), for: .primaryActionTriggered)

        self.configure()

        self.bind(toViewModel: self.viewModel)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.followButton.layer.cornerRadius = CornerRadius.button

        self.unfollowButton.layer.cornerRadius = CornerRadius.button

        self.userImageView.layer.cornerRadius = self.userImageView.frame.width / 2
        self.userImageView.layer.masksToBounds = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationView.backgroundColor = .clear

        self.backButton.backgroundColor = .clear

        self.userProfileActionsStackView.backgroundColor = .clear

        self.followActionsStackView.backgroundColor = .clear

        self.followButton.backgroundColor = UIColor.App.buttonBackgroundSecondary
        self.followButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)

        self.unfollowButton.backgroundColor = .clear
        self.unfollowButton.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.unfollowButton.layer.borderColor = UIColor.App.buttonBackgroundSecondary.cgColor

        self.friendActionsStackView.backgroundColor = .clear

        self.addFriendButton.backgroundColor = .clear

        self.chatButton.backgroundColor = .clear

        self.moreOptionsButton.backgroundColor = .clear

        self.userTopInfoView.backgroundColor = .clear

        self.userImageView.backgroundColor = .clear
        self.userImageView.layer.borderColor = UIColor.App.highlightPrimary.cgColor

        self.usernameLabel.textColor = UIColor.App.textPrimary

        self.followersValueLabel.textColor = UIColor.App.textPrimary

        self.followersLabel.textColor = UIColor.App.textSecondary

        self.followingValueLabel.textColor = UIColor.App.textPrimary

        self.followingLabel.textColor = UIColor.App.textSecondary

        self.userInfoTabsContainerView.backgroundColor = .clear

        self.tabViewController.sliderBarColor = UIColor.App.highlightSecondary
        self.tabViewController.barColor = UIColor.App.backgroundPrimary
        self.tabViewController.textColor = UIColor.App.textPrimary
        self.tabViewController.separatorBarColor = UIColor.App.separatorLine

    }

    // MARK: Functions
    private func configure() {
        self.usernameLabel.text = self.viewModel.userBasicInfo.username

        if let loggedUserId = Env.gomaNetworkClient.getCurrentToken()?.userId,
           "\(loggedUserId)" == self.viewModel.userBasicInfo.userId {
            self.isLoggedUser = true
        }
    }

    private func showFriendRequestAlert() {
        let customToast = ToastCustom.text(title: localized("friend_request_sent"))

        customToast.show()

        self.addFriendButton.isEnabled = false
    }

    private func closeUserProfile() {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: UserProfileViewModel) {

        viewModel.isFollowingUser
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isFollowing in
                self?.hasFollowOption = !isFollowing
            })
            .store(in: &cancellables)

        if !self.isChatProfile {
            viewModel.isFriendUser
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] isFriend in
                    self?.hasFriendOption = !isFriend
                })
                .store(in: &cancellables)

            viewModel.isFriendRequestPending
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] isFriendRequestPending in
                    self?.addFriendButton.isEnabled = !isFriendRequestPending
                })
                .store(in: &cancellables)
        }

        viewModel.followingCountPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] followingCount in
                self?.followingValueLabel.text = followingCount
            })
            .store(in: &cancellables)

        viewModel.followersCountPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] followersCount in
                self?.followersValueLabel.text = followersCount
            })
            .store(in: &cancellables)

        viewModel.userProfileInfoStatePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] userProfileInfoState in

                switch userProfileInfoState {
                case .loaded:
                    if let userProfileInfo = viewModel.userProfileInfo {

                        self?.userInfoViewController.getViewModel().setUserProfileInfoState(userProfileState: .loaded, userProfileInfo: userProfileInfo)
                    }
                case .failed:
                    self?.userInfoViewController.getViewModel().setUserProfileInfoState(userProfileState: .failed)
                case .loading:
                    self?.userInfoViewController.getViewModel().setUserProfileInfoState(userProfileState: .loading)
                }

            })
            .store(in: &cancellables)

        viewModel.showFriendRequestAlert = { [weak self] in
            self?.showFriendRequestAlert()
        }

        viewModel.shouldCloseUserProfile = { [weak self] in
            guard let self = self else {return}
            if self.isChatProfile {
                self.shouldCloseChat?()
                self.navigationController?.popToRootViewController(animated: true)
            }
            self.closeUserProfile()
        }

    }

    // MARK: Actions
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func didTapFollowButton() {
        self.viewModel.followUser()
    }

    @objc func didTapUnfollowButton() {
        self.viewModel.deleteFollowUser()
    }

    @objc func didTapAddFriendButton() {
        self.viewModel.addFriendRequest()
    }

    @objc func didTapChatButton() {

        if let chatId = self.viewModel.userConnection?.chatRoomId {
            let conversationDetailViewModel = ConversationDetailViewModel(chatId: chatId)

            let conversationDetailViewController = ConversationDetailViewController(viewModel: conversationDetailViewModel)

            conversationDetailViewController.cameFromProfile = true

            self.navigationController?.pushViewController(conversationDetailViewController, animated: true)

        }
    }

    @objc func didTapMoreOptionsButton() {

        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if self.viewModel.isFriendUser.value {
            let unfriendUserAction: UIAlertAction = UIAlertAction(title: localized("unfriend"), style: .default) { [weak self] _ in
                self?.viewModel.unfriendUser()
            }
            actionSheetController.addAction(unfriendUserAction)
        }

        let blockUserAction: UIAlertAction = UIAlertAction(title: localized("block_user"), style: .default) { _ in
            // NOT YET AVAILABLE
        }
        actionSheetController.addAction(blockUserAction)

        let reportUserAction: UIAlertAction = UIAlertAction(title: localized("report"), style: .default) { _ in
            // NOT YET AVAILABLE
        }
        actionSheetController.addAction(reportUserAction)

        let cancelAction: UIAlertAction = UIAlertAction(title: localized("cancel"), style: .cancel) { _ in }
        actionSheetController.addAction(cancelAction)

        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        self.present(actionSheetController, animated: true, completion: nil)
    }

}

extension UserProfileViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

extension UserProfileViewController {

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
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        return button
    }

    private static func createUserProfileActionsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        return stackView
    }

    private static func createFollowActionsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }

    private static func createFollowButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("follow"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        return button
    }

    private static func createUnfollowButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("unfollow"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        button.layer.borderWidth = 2
        return button
    }

    private static func createFriendActionsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }

    private static func createAddFriendButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "user_add_friend_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }

    private static func createChatButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "user_chat_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }

    private static func createMoreOptionsButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "more_options_icon"), for: .normal)
        return button
    }

    private static func createUserTopInfoView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createUserImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "my_account_profile_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 2
        return imageView
    }

    private static func createUsernameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Username"
        label.font = AppFont.with(type: .bold, size: 18)
        return label
    }

    private static func createFollowersValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0"
        label.font = AppFont.with(type: .semibold, size: 11)
        return label
    }

    private static func createFollowersLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Followers"
        label.font = AppFont.with(type: .semibold, size: 11)
        return label
    }

    private static func createFollowingValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0"
        label.font = AppFont.with(type: .semibold, size: 11)
        return label
    }

    private static func createFollowingLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Following"
        label.font = AppFont.with(type: .semibold, size: 11)
        return label
    }

    private static func createUserInfoTabsContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.bottomSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)

        self.navigationView.addSubview(self.userProfileActionsStackView)

        self.userProfileActionsStackView.addArrangedSubview(self.followActionsStackView)

        self.followActionsStackView.addArrangedSubview(self.followButton)
        self.followActionsStackView.addArrangedSubview(self.unfollowButton)

        self.userProfileActionsStackView.addArrangedSubview(self.friendActionsStackView)

        self.friendActionsStackView.addArrangedSubview(self.addFriendButton)
        self.friendActionsStackView.addArrangedSubview(self.chatButton)

        self.navigationView.addSubview(self.moreOptionsButton)

        self.view.addSubview(self.userTopInfoView)

        self.userTopInfoView.addSubview(self.userImageView)
        self.userTopInfoView.addSubview(self.usernameLabel)
        self.userTopInfoView.addSubview(self.followersValueLabel)
        self.userTopInfoView.addSubview(self.followersLabel)
        self.userTopInfoView.addSubview(self.followingValueLabel)
        self.userTopInfoView.addSubview(self.followingLabel)

        self.view.addSubview(self.userInfoTabsContainerView)

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

        // Navigation view
        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),

            self.userProfileActionsStackView.trailingAnchor.constraint(equalTo: self.moreOptionsButton.leadingAnchor, constant: -15),
            self.userProfileActionsStackView.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

            self.followButton.widthAnchor.constraint(equalToConstant: 81),
            self.followButton.heightAnchor.constraint(equalToConstant: 29),

            self.unfollowButton.widthAnchor.constraint(equalToConstant: 81),
            self.unfollowButton.heightAnchor.constraint(equalToConstant: 29),

            self.addFriendButton.widthAnchor.constraint(equalToConstant: 32),
            self.addFriendButton.heightAnchor.constraint(equalToConstant: 32),

            self.chatButton.widthAnchor.constraint(equalToConstant: 32),
            self.chatButton.heightAnchor.constraint(equalToConstant: 32),

            self.moreOptionsButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor),
            self.moreOptionsButton.widthAnchor.constraint(equalToConstant: 40),
            self.moreOptionsButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        // User top info view
        NSLayoutConstraint.activate([
            self.userTopInfoView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.userTopInfoView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.userTopInfoView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),

            self.userImageView.leadingAnchor.constraint(equalTo: self.userTopInfoView.leadingAnchor, constant: 33),
            self.userImageView.widthAnchor.constraint(equalToConstant: 52),
            self.userImageView.heightAnchor.constraint(equalTo: self.userImageView.widthAnchor),
            self.userImageView.topAnchor.constraint(equalTo: self.userTopInfoView.topAnchor, constant: 15),
            self.userImageView.bottomAnchor.constraint(equalTo: self.userTopInfoView.bottomAnchor, constant: -40),

            self.usernameLabel.leadingAnchor.constraint(equalTo: self.userImageView.trailingAnchor, constant: 11),
            self.usernameLabel.trailingAnchor.constraint(equalTo: self.userTopInfoView.trailingAnchor, constant: -33),
            self.usernameLabel.centerYAnchor.constraint(equalTo: self.userImageView.centerYAnchor, constant: -12),

            self.followersValueLabel.leadingAnchor.constraint(equalTo: self.userImageView.trailingAnchor, constant: 11),
            self.followersValueLabel.centerYAnchor.constraint(equalTo: self.userImageView.centerYAnchor, constant: 12),

            self.followersLabel.leadingAnchor.constraint(equalTo: self.followersValueLabel.trailingAnchor, constant: 2),
            self.followersLabel.centerYAnchor.constraint(equalTo: self.followersValueLabel.centerYAnchor),

            self.followingValueLabel.leadingAnchor.constraint(equalTo: self.followersLabel.trailingAnchor, constant: 5),
            self.followingValueLabel.centerYAnchor.constraint(equalTo: self.followersValueLabel.centerYAnchor),

            self.followingLabel.leadingAnchor.constraint(equalTo: self.followingValueLabel.trailingAnchor, constant: 2),
            self.followingLabel.centerYAnchor.constraint(equalTo: self.followersValueLabel.centerYAnchor)
        ])

        // User tabs view
        NSLayoutConstraint.activate([
            self.userInfoTabsContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.userInfoTabsContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.userInfoTabsContainerView.topAnchor.constraint(equalTo: self.userTopInfoView.bottomAnchor),
            self.userInfoTabsContainerView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor)
        ])
    }
}

enum UserProfileState {
    case loading
    case loaded
    case failed
}
