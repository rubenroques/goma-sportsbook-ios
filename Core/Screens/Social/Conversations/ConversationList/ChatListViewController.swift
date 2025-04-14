//
//  ChatListViewController.swift
//  MultiBet
//
//  Created by André Lascas on 13/11/2024.
//

import UIKit
import Combine

class ChatListViewController: UIViewController {

    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var containerBaseView: UIView = Self.createContainerBaseView()
    private lazy var notificationsButton: UIButton = Self.createNotificationsButton()
    private lazy var friendsButton: UIButton = Self.createFriendsButton()
//    private lazy var settingsButton: UIButton = Self.createSettingsButton()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var tableView: UITableView = Self.createTableView()
//    private lazy var tableViewHeader: UIView = Self.createTableViewHeader()
    private lazy var searchBar: UISearchBar = Self.createSearchBar()
    private lazy var cancelButton: UIButton = Self.createCancelButton()

    private lazy var messagesLabel: UILabel = Self.createMessagesLabel()
    private lazy var newGroupButton: UIButton = Self.createNewGroupButton()
    private lazy var emptyStateView: UIView = Self.createEmptyStateView()
    private lazy var emptyStateImageView: UIImageView = Self.createEmptyStateImageView()
    private lazy var emptyStateLabel: UILabel = Self.createEmptyStateLabel()
    private lazy var emptyStateAddFriendButton: UIButton = Self.createEmptyStateAddFriendButton()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()
    
    private lazy var emptySearchView: UIView = Self.createEmptySearchView()
    private lazy var emptySearchImageView: UIImageView = Self.createEmptySearchImageView()
    private lazy var emptySearchLabel: UILabel = Self.createEmptySearchLabel()
    
    // Constraints
    private lazy var searchBarTrailingConstraint: NSLayoutConstraint = Self.createSearchBarTrailingConstraint()
    private lazy var searchBarTopNavigationConstraint: NSLayoutConstraint = Self.createSearchBarTopNavigationConstraint()
    private lazy var searchBarTopViewConstraint: NSLayoutConstraint = Self.createSearchBarTopViewConstraint()


    private var viewModel: ConversationsViewModel
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
    
    var isEmptySearch: Bool = true {
        didSet {
            self.emptySearchView.isHidden = !isEmptySearch
        }
    }
    
    var isShowingSearchLayout: Bool = false {
        didSet {
            self.emptySearchView.isHidden = !isShowingSearchLayout
            
            self.newGroupButton.isHidden = isShowingSearchLayout
            
            self.messagesLabel.text = isShowingSearchLayout ? localized("results") : localized("messages")

        }
    }

    var reloadFriendsData: (() -> Void)?

    // MARK: - Lifetime and Cycle
    init(viewModel: ConversationsViewModel = ConversationsViewModel()) {
        
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

        self.notificationsButton.addTarget(self, action: #selector(didTapNotificationsButton), for: .primaryActionTriggered)

        self.friendsButton.addTarget(self, action: #selector(didTapFriendsButton), for: .primaryActionTriggered)

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)
        
        self.cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .primaryActionTriggered)
        
        self.searchBar.delegate = self

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(PreviewChatTableViewCell.self,
                                forCellReuseIdentifier: PreviewChatTableViewCell.identifier)
        self.tableView.register(AIAssistantUITableViewCell.self,
                                forCellReuseIdentifier: AIAssistantUITableViewCell.identifier)

        self.newGroupButton.addTarget(self, action: #selector(didTapNewGroupButton), for: .primaryActionTriggered)
        
        self.emptyStateAddFriendButton.addTarget(self, action: #selector(didTapAddFriendButton), for: .primaryActionTriggered)


        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(backgroundTapGesture)

        self.bind(toViewModel: self.viewModel)
        
        self.isShowingSearchLayout = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.tableView.reloadData()

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
        self.view.backgroundColor = UIColor.App.backgroundSecondary

        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundSecondary
        self.navigationView.backgroundColor = UIColor.App.backgroundSecondary

        self.titleLabel.backgroundColor = .clear
        self.titleLabel.textColor = UIColor.App.textPrimary

        self.containerBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.notificationsButton.backgroundColor = .clear

        self.friendsButton.backgroundColor = .clear

//        self.settingsButton.backgroundColor = .clear

        self.closeButton.backgroundColor = .clear
        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        
        self.cancelButton.backgroundColor = .clear
        self.cancelButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        self.tableView.backgroundColor = UIColor.App.backgroundSecondary

        self.newGroupButton.setTitleColor(UIColor.App.highlightTertiary, for: .normal)
        self.newGroupButton.setTitleColor(UIColor.App.highlightTertiary.withAlphaComponent(0.5), for: .disabled)

        self.emptyStateView.backgroundColor = UIColor.App.backgroundSecondary
        self.emptyStateImageView.backgroundColor = .clear
        self.emptyStateLabel.textColor = UIColor.App.textPrimary
        
        StyleHelper.styleButtonWithTheme(button: self.emptyStateAddFriendButton,
                                         titleColor: UIColor.App.buttonTextTertiary,
                                         titleDisabledColor: UIColor.App.buttonTextDisableTertiary,
                                         backgroundColor: UIColor.App.buttonBackgroundTertiary,
                                         backgroundHighlightedColor: UIColor.App.buttonBackgroundTertiary,
                                         withBorder: true,
                                         borderColor: UIColor.App.buttonBorderTertiary)

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundSecondary
        
        self.emptySearchView.backgroundColor = UIColor.App.backgroundSecondary
        self.emptySearchImageView.backgroundColor = .clear
        self.emptySearchLabel.textColor = UIColor.App.textPrimary

        self.setupSearchBar()
    }
    
    // MARK: Functions
    private func showConversationDetail(conversationData: ConversationData, isChatAssistant: Bool = false) {
        
        let conversationDetailViewModel = ConversationDetailViewModel(chatId: conversationData.id)

        let conversationDetailViewController = ConversationDetailViewController(viewModel: conversationDetailViewModel)
        
        conversationDetailViewController.isChatAssistant = isChatAssistant

        conversationDetailViewController.shouldCloseChat = { [weak self] in
            self?.needsRefetchData()
            self?.reloadFriendsData?()
        }

        conversationDetailViewController.shouldReloadData = { [weak self] in
            self?.needsRefetchData()
        }

        self.navigationController?.pushViewController(conversationDetailViewController, animated: true)
    }

    func needsRefetchData() {
        self.viewModel.refetchConversations()
    }
    
    private func setupSearchBar() {
        self.searchBar.searchBarStyle = UISearchBar.Style.prominent
        self.searchBar.sizeToFit()
        self.searchBar.isTranslucent = false
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.tintColor = .white
        self.searchBar.barTintColor = .white
        self.searchBar.backgroundImage = UIColor.App.backgroundSecondary.image()
        self.searchBar.placeholder = localized("search")

        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.App.inputBackground
            textfield.textColor = UIColor.App.textPrimary
            textfield.tintColor = UIColor.App.textPrimary
            textfield.attributedPlaceholder = NSAttributedString(string: localized("search_field"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor:
                                                                                UIColor.App.inputTextTitle,
                                                                              NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 14)])

            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = UIColor.App.iconSecondary
            }
            
            textfield.layer.borderWidth = 1
            textfield.layer.borderColor = UIColor.App.separatorLineSecondary.cgColor
            textfield.layer.cornerRadius = 10
        }
    }
    
    private func showSearchLayout() {
        self.isShowingSearchLayout = true
        
        self.cancelButton.isHidden = false
        self.navigationView.isHidden = true
        
        self.isEmptySearch = true
        
        self.isShowingSearchLayout = true
        
        UIView.animate(withDuration: 0.3) {
            self.searchBarTrailingConstraint.constant = -70
            self.searchBarTopNavigationConstraint.isActive = false
            self.searchBarTopViewConstraint.isActive = true
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideSearchLayout() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.searchBarTrailingConstraint.constant = -5
            self.searchBarTopNavigationConstraint.isActive = true
            self.searchBarTopViewConstraint.isActive = false
            self.view.layoutIfNeeded()
        }) { _ in
            self.cancelButton.isHidden = true
            self.navigationView.isHidden = false
            
            self.isEmptySearch = true

            self.isShowingSearchLayout = false
        }
    }
    
    // MARK: - Bindings
    private func bind(toViewModel viewModel: ConversationsViewModel) {

        viewModel.dataNeedsReload
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        viewModel.conversationsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] conversations in
                if conversations.count == 1,
                   let users = conversations.first?.groupUsers,
                   users.contains(where: {
                       $0.id == 1
                   }){
                    self?.isEmptyState = true
                    
                    self?.newGroupButton.isEnabled = false
                }
                else {
                    self?.isEmptyState = conversations.isEmpty
                    
                    self?.newGroupButton.isEnabled = conversations.isNotEmpty

                }
//                self?.isEmptyState = conversations.isEmpty
                
                if let isShowingSearchLayout = self?.isShowingSearchLayout {
                    
                    if isShowingSearchLayout {
                        if !conversations.isEmpty {
                            
                            self?.isEmptySearch = false
                        }
                        else {
                            let searchQuery = viewModel.searchQuery
                            
                            if searchQuery != "" {
                                self?.emptySearchImageView.image = UIImage(named: "no_friends_icon")
                                self?.emptySearchLabel.text = localized("no_results_for_chat").replacingFirstOccurrence(of: "{query}", with: searchQuery)
                            }
                            else {
                                self?.emptySearchImageView.image = UIImage(named: "empty_search_chat_icon")
                                self?.emptySearchLabel.text = localized("search_for_something")
                            }
                            self?.isEmptySearch = true
                        }
                    }
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
    
    // MARK: Action
    @objc private func didTapNotificationsButton() {
        let notificationsViewController = ChatNotificationsViewController()

        self.navigationController?.pushViewController(notificationsViewController, animated: true)
    }

    @objc private func didTapFriendsButton() {
        let addFriendsViewModel = AddFriendViewModel()

        let addFriendsViewController = AddFriendViewController(viewModel: addFriendsViewModel)

        addFriendsViewController.chatListNeedsReload = { [weak self] in
            self?.needsRefetchData()
        }

        self.navigationController?.pushViewController(addFriendsViewController, animated: true)
    }

    @objc private func didTapSettingsButton() {
        let chatSettingsViewModel = ChatSettingsViewModel()

        let chatSettingsViewController = ChatSettingsViewController(viewModel: chatSettingsViewModel)

        self.navigationController?.pushViewController(chatSettingsViewController, animated: true)
    }

    @objc private func didTapCloseButton() {

        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func didTapCancelButton() {
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        self.viewModel.resetUsers()
        self.hideSearchLayout()
    }
    
    @objc private func didTapBackground() {
        self.searchBar.resignFirstResponder()
    }

    @objc private func didTapNewGroupButton() {
        let newGroupViewModel = NewGroupViewModel()
        let newGroupViewController = NewGroupViewController(viewModel: newGroupViewModel)

        newGroupViewController.chatListNeedReload = { [weak self] in
            self?.needsRefetchData()
        }

        self.navigationController?.pushViewController(newGroupViewController, animated: true)
    }

    @objc private func didTapAddFriendButton() {
        
        let addFriendsViewModel = AddFriendViewModel()

        let addFriendsViewController = AddFriendViewController(viewModel: addFriendsViewModel)

        addFriendsViewController.chatListNeedsReload = { [weak self] in
            self?.needsRefetchData()
            self?.reloadFriendsData?()
        }

        self.navigationController?.pushViewController(addFriendsViewController, animated: true)

    }
}

//
// MARK: - TableView Protocols
//
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows(forSectionIndex: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cellData = self.viewModel.conversationsPublisher.value[safe: indexPath.row],
           let cellGroupUsers = cellData.groupUsers,
           cellGroupUsers.contains(where: {$0.id == 1}) && cellGroupUsers.count < 3 {
            
            guard
                let cell = tableView.dequeueCellType(AIAssistantUITableViewCell.self)
            else {
                fatalError()
            }
            
            let cellViewModel = PreviewChatCellViewModel(cellData: cellData)
            cell.configure(withViewModel: cellViewModel)
            
            cell.didTapConversationAction = { [weak self] conversationData in
                self?.showConversationDetail(conversationData: conversationData, isChatAssistant: true)
            }
            
            return cell
        }
        
        guard
            let cell = tableView.dequeueCellType(PreviewChatTableViewCell.self)
        else {
            fatalError()
        }
        
        if let cellData = self.viewModel.conversationsPublisher.value[safe: indexPath.row] {
            let cellViewModel = PreviewChatCellViewModel(cellData: cellData)
            cell.configure(withViewModel: cellViewModel)
            
            if indexPath.row == self.viewModel.conversationsPublisher.value.count - 1 {
                cell.hasSeparatorLine = false
            }
        }
        
        cell.didTapConversationAction = { [weak self] conversationData in
            self?.showConversationDetail(conversationData: conversationData)
        }
        
        cell.removeChatroomAction = { [weak self] chatroomId in
            self?.viewModel.removeChatroom(chatroomId: chatroomId)
        }
        
        return cell
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        // TODO: Enable mute later when endpoint available
//        let muteAction = UIContextualAction(style: .normal,
//                                        title: localized("mute")) { [weak self] action, view, completionHandler in
//            self?.handleMuteAction()
//            completionHandler(true)
//        }
//
//        if let cellViewModel = self.viewModel.conversationsPublisher.value[safe: indexPath.row] {
//            if cellViewModel.notificationsEnabled {
//                muteAction.title = "Mute"
//            }
//            else {
//                muteAction.title = "Unmute"
//            }
//            
//        }
//
//        muteAction.image = createActionImage(title: localized("mute"), imageName: "mute_channel_icon")
//
//        muteAction.backgroundColor = UIColor.App.alertWarning

        let deleteAction = UIContextualAction(style: .normal,
                                              title: localized("delete")) { [weak self] action, view, completionHandler in
            if let cellData = self?.viewModel.conversationsPublisher.value[safe: indexPath.row] {
                self?.handleDeleteAction(chatroomId: cellData.id)
                completionHandler(true)
            }

        }
        
        deleteAction.image = createActionImage(title: localized("delete"), imageName: "trash_simple_icon")

        deleteAction.backgroundColor = UIColor.App.alertError

        let swipeActionCofiguration = UISwipeActionsConfiguration(actions: [deleteAction])

        swipeActionCofiguration.performsFirstActionWithFullSwipe = false

        return swipeActionCofiguration

    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    private func handleMuteAction() {
        print("Muted!")
        // TODO: Implement mute action
    }

    private func handleDeleteAction(chatroomId: Int) {
        self.viewModel.removeChatroom(chatroomId: chatroomId)
    }
    
    func createActionImage(title: String, imageName: String) -> UIImage {
        let size = CGSize(width: 60, height: 60)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background color
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Draw the icon
            if let icon = UIImage(named: imageName) {
                let iconSize = CGSize(width: 25, height: 25)
                let iconOrigin = CGPoint(x: (size.width - iconSize.width) / 2, y: 10) // Centered horizontally, near top
                icon.draw(in: CGRect(origin: iconOrigin, size: iconSize))
            }
            
            // Draw the title
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [
                .font: AppFont.with(type: .semibold, size: 12),
                .foregroundColor: UIColor.App.buttonTextSecondary,
                .paragraphStyle: paragraphStyle
            ]
            
            let titleRect = CGRect(x: 0, y: 40, width: size.width, height: 20)
            title.draw(in: titleRect, withAttributes: attributes)
        }
    }
}

extension ChatListViewController: UISearchBarDelegate {

    func searchUsers(searchQuery: String = "") {

        if searchQuery != "" {
            self.viewModel.filterSearch(searchQuery: searchQuery)
        }
        else {
            self.viewModel.resetSearchUsers()
        }

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if let searchText = searchBar.text {
            self.searchUsers(searchQuery: searchText)
        }

    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("Search bar focused")
        self.showSearchLayout()
        self.viewModel.resetSearchUsers()

    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("Finished writing or search button clicked")
        self.viewModel.resetUsers()
        self.hideSearchLayout()
    }
    

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let recentSearch = searchBar.text {

           // Do something if needed
        }

        self.searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        self.searchUsers()
    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension ChatListViewController {

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
        titleLabel.font = AppFont.with(type: .bold, size: 17)
        titleLabel.textAlignment = .center
        titleLabel.text = localized("chat")
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
        button.setImage(UIImage(named: "chat_settings_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("close"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }
    
//    private static func createTableViewHeader() -> UIView {
//        let tableViewHeader = UIView(frame: CGRect(x: 0, y: 0, width: 104, height: 90))
//        tableViewHeader.autoresizingMask = .flexibleWidth
//        tableViewHeader.translatesAutoresizingMaskIntoConstraints = true
//        return tableViewHeader
//    }

    private static func createSearchBar() -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }
    
    private static func createCancelButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("cancel"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        button.isHidden = true
        return button
    }
    
    private static func createMessagesLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("messages")
        label.font = AppFont.with(type: .bold, size: 18)
        return label
    }

    private static func createNewGroupButton() -> UIButton {
        let newGroupButton = UIButton(type: .custom)
        newGroupButton.setTitle(localized("new_group"), for: .normal)
        newGroupButton.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        newGroupButton.translatesAutoresizingMaskIntoConstraints = false
        return newGroupButton
    }

    private static func createHeaderSeparatorLineView() -> UIView {
        let headerSeparatorLine = UIView()
        headerSeparatorLine.translatesAutoresizingMaskIntoConstraints = false
        return headerSeparatorLine
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }

    private static func createEmptyStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createEmptyStateImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "no_friends_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("you_still_havent_added_friends")
        label.numberOfLines = 0
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .center
        return label
    }

    private static func createEmptyStateAddFriendButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("add_friends"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        button.contentEdgeInsets = UIEdgeInsets(top: 15.0, left: 30.0, bottom: 15.0, right: 30.0)
        return button
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
    
    private static func createEmptySearchView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createEmptySearchImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "empty_search_chat_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createEmptySearchLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("search_for_something")
        label.numberOfLines = 0
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .center
        return label
    }
    
    // Constraints
    private static func createSearchBarTrailingConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private static func createSearchBarTopNavigationConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private static func createSearchBarTopViewConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)
        self.navigationView.addSubview(self.titleLabel)

        self.navigationView.addSubview(self.notificationsButton)
        self.navigationView.addSubview(self.friendsButton)
//        self.navigationView.addSubview(self.settingsButton)
        self.navigationView.addSubview(self.closeButton)
        
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.cancelButton)
        
        self.view.addSubview(self.messagesLabel)
        self.view.addSubview(self.newGroupButton)

        self.view.addSubview(self.tableView)

//        self.tableView.tableHeaderView = self.tableViewHeader

        self.view.addSubview(self.emptyStateView)

        self.emptyStateView.addSubview(self.emptyStateImageView)
        self.emptyStateView.addSubview(self.emptyStateLabel)
        self.emptyStateView.addSubview(self.emptyStateAddFriendButton)

        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.activityIndicatorView)
        
        self.view.addSubview(self.emptySearchView)

        self.emptySearchView.addSubview(self.emptySearchImageView)
        self.emptySearchView.addSubview(self.emptySearchLabel)

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

            self.friendsButton.leadingAnchor.constraint(equalTo: self.notificationsButton.trailingAnchor, constant: 0),
            self.friendsButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.friendsButton.widthAnchor.constraint(equalToConstant: 40),
            self.friendsButton.heightAnchor.constraint(equalTo: self.friendsButton.widthAnchor),

//            self.settingsButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
//            self.settingsButton.widthAnchor.constraint(equalToConstant: 40),
//            self.settingsButton.heightAnchor.constraint(equalTo: self.settingsButton.widthAnchor),

//            self.closeButton.leadingAnchor.constraint(equalTo: self.settingsButton.trailingAnchor, constant: 0),
            self.closeButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -8),
            self.closeButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.closeButton.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        NSLayoutConstraint.activate([
            self.searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 5),
            self.searchBar.heightAnchor.constraint(equalToConstant: 40),
            
            self.cancelButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            self.cancelButton.leadingAnchor.constraint(equalTo: self.searchBar.trailingAnchor, constant: 5),
            self.cancelButton.centerYAnchor.constraint(equalTo: self.searchBar.centerYAnchor),

            self.messagesLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            self.messagesLabel.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 10),

            self.newGroupButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            self.newGroupButton.centerYAnchor.constraint(equalTo: self.messagesLabel.centerYAnchor)
        ])

        // Table view
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.messagesLabel.bottomAnchor, constant: 10),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])

        // Empty state view
        NSLayoutConstraint.activate([
            self.emptyStateView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.emptyStateView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.emptyStateView.topAnchor.constraint(equalTo: self.tableView.topAnchor, constant: 70),
            self.emptyStateView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.emptyStateImageView.topAnchor.constraint(equalTo: self.emptyStateView.topAnchor, constant: 20),
            self.emptyStateImageView.leadingAnchor.constraint(equalTo: self.emptyStateView.leadingAnchor, constant: 75),
            self.emptyStateImageView.trailingAnchor.constraint(equalTo: self.emptyStateView.trailingAnchor, constant: -75),

            self.emptyStateLabel.leadingAnchor.constraint(equalTo: self.emptyStateView.leadingAnchor, constant: 67),
            self.emptyStateLabel.trailingAnchor.constraint(equalTo: self.emptyStateView.trailingAnchor, constant: -67),
            self.emptyStateLabel.topAnchor.constraint(equalTo: self.emptyStateImageView.bottomAnchor, constant: 22),

            self.emptyStateAddFriendButton.topAnchor.constraint(equalTo: self.emptyStateLabel.bottomAnchor, constant: 24),
            self.emptyStateAddFriendButton.heightAnchor.constraint(equalToConstant: 50),
            self.emptyStateAddFriendButton.centerXAnchor.constraint(equalTo: self.emptyStateView.centerXAnchor)
        ])

        // Loading Screen
        NSLayoutConstraint.activate([
            self.loadingBaseView.topAnchor.constraint(equalTo: self.messagesLabel.bottomAnchor),
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor)
        ])
        
        // Search mepty
        NSLayoutConstraint.activate([
            self.emptySearchView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.emptySearchView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.emptySearchView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 4),
            self.emptySearchView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.emptySearchImageView.topAnchor.constraint(equalTo: self.emptySearchView.topAnchor, constant: 20),
            self.emptySearchImageView.leadingAnchor.constraint(equalTo: self.emptySearchView.leadingAnchor, constant: 75),
            self.emptySearchImageView.trailingAnchor.constraint(equalTo: self.emptySearchView.trailingAnchor, constant: -75),

            self.emptySearchLabel.leadingAnchor.constraint(equalTo: self.emptySearchView.leadingAnchor, constant: 67),
            self.emptySearchLabel.trailingAnchor.constraint(equalTo: self.emptySearchView.trailingAnchor, constant: -67),
            self.emptySearchLabel.topAnchor.constraint(equalTo: self.emptySearchImageView.bottomAnchor, constant: 22)
        ])
        
        // Constraint
        self.searchBarTrailingConstraint = self.searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5)
        self.searchBarTrailingConstraint.isActive = true
        
        self.searchBarTopNavigationConstraint = self.searchBar.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 5)
        self.searchBarTopNavigationConstraint.isActive = true
        
        self.searchBarTopViewConstraint = self.searchBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10)
        self.searchBarTopViewConstraint.isActive = false

    }
}
