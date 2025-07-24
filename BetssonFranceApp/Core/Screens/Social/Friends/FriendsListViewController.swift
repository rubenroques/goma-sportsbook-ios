//
//  FriendsListViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/03/2022.
//

import UIKit
import Combine

class FriendsListViewController: UIViewController {

    // MARK: Private Properties
    private lazy var searchBar: UISearchBar = Self.createSearchBar()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var emptyStateView: UIView = Self.createEmptyStateView()
    private lazy var emptyStateImageView: UIView = Self.createEmptyStateImageView()
    private lazy var emptyStateLabel: UILabel = Self.createEmptyStateLabel()

    private var viewModel: FriendsListViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var isEmptyState: Bool = false {
        didSet {
            self.emptyStateView.isHidden = !isEmptyState
        }
    }

    var reloadConversationsData: ( () -> Void)?

    // MARK: - Lifetime and Cycle
    init(viewModel: FriendsListViewModel = FriendsListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Friends"

        self.setupSubviews()
        self.setupWithTheme()

        self.searchBar.delegate = self

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(ResultsHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: ResultsHeaderFooterView.identifier)

        self.tableView.register(FriendStatusTableViewCell.self,
                                forCellReuseIdentifier: FriendStatusTableViewCell.identifier)

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(backgroundTapGesture)

        self.bind(toViewModel: self.viewModel)

        // TableView top padding fix
        if #available(iOS 15.0, *) {
          tableView.sectionHeaderTopPadding = 0
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.reloadData()
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

        self.setupSearchBarStyle()

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: FriendsListViewModel) {

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                // Spinner if needed
            })
            .store(in: &cancellables)

        viewModel.dataNeedsReload
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        viewModel.friendsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] friends in
                self?.isEmptyState = friends.isEmpty
            })
            .store(in: &cancellables)

        viewModel.conversationDataNeedsReload
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.reloadConversationsData?()
            })
            .store(in: &cancellables)
    }

    // MARK: Functions
    private func setupSearchBarStyle() {
        self.searchBar.searchBarStyle = UISearchBar.Style.prominent
        self.searchBar.sizeToFit()
        self.searchBar.isTranslucent = false
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.tintColor = .white
        self.searchBar.barTintColor = .white
        self.searchBar.backgroundImage = UIColor.App.backgroundPrimary.image()
        self.searchBar.placeholder = localized("search")

        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.App.backgroundSecondary
            textfield.textColor = UIColor.App.textPrimary
            textfield.tintColor = UIColor.App.textPrimary
            textfield.attributedPlaceholder = NSAttributedString(string: localized("search_friend"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor:
                                                                                UIColor.App.inputTextTitle,
                                                                              NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 14)])

            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = UIColor.App.inputTextTitle
            }
        }

    }

    func needsRefetchData() {
        self.viewModel.refetchConversations()
    }

    // MARK: Actions
    @objc func didTapBackground() {
        self.searchBar.resignFirstResponder()
    }
}

//
// MARK: Searchbar Protocols
//
extension FriendsListViewController: UISearchBarDelegate {

    func searchUsers(searchQuery: String = "") {

        if searchQuery != "" && searchQuery.count >= 3 {
            self.viewModel.filterSearch(searchQuery: searchQuery)
        }
        else {
            self.viewModel.resetUsers()
        }

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if let searchText = searchBar.text {
            self.searchUsers(searchQuery: searchText)
        }

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
// MARK: - TableView Protocols
//
extension FriendsListViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows(forSectionIndex: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueCellType(FriendStatusTableViewCell.self)
        else {
            fatalError()
        }

        if let friend = self.viewModel.friendsPublisher.value[safe: indexPath.row] {

            if let cellViewModel = self.viewModel.cachedFriendCellViewModels[friend.id] {
                cell.configure(withViewModel: cellViewModel)
            }
            else {
                let cellViewModel = FriendStatusCellViewModel(friend: friend)
                self.viewModel.cachedFriendCellViewModels[friend.id] = cellViewModel

                cell.configure(withViewModel: cellViewModel)
            }

            cell.removeFriendAction = { [weak self] friendId in
                self?.viewModel.removeFriend(friendId: friendId)
            }

            cell.showProfileAction = { [weak self] in
                self?.handleProfileAction(friendData: friend)

            }

        }

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if !self.viewModel.friendsPublisher.value.isEmpty {
            guard
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ResultsHeaderFooterView.identifier) as? ResultsHeaderFooterView
            else {
                fatalError()
            }

            let titleLabel = localized("my_friends")

            headerView.configureHeader(title: titleLabel)

            return headerView
        }
        else {
            return UIView()
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if !self.viewModel.friendsPublisher.value.isEmpty {
            return UITableView.automaticDimension
        }
        else {
            return 0.01
        }

    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

        if !self.viewModel.friendsPublisher.value.isEmpty {
            return 30
        }
        else {
            return 0.01
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let muteAction = UIContextualAction(style: .normal,
                                        title: "Mute") { [weak self] action, view, completionHandler in
            self?.handleMuteAction()
            completionHandler(true)
        }

        if let friend = self.viewModel.friendsPublisher.value[safe: indexPath.row] {

            if let cellViewModel = self.viewModel.cachedFriendCellViewModels[friend.id] {
                if cellViewModel.notificationsEnabled {
                    muteAction.title = "Mute"
                }
                else {
                    muteAction.title = "Unmute"
                }

            }
        }

        muteAction.backgroundColor = UIColor.App.backgroundTertiary

        let deleteAction = UIContextualAction(style: .normal,
                                        title: "Delete") { [weak self] action, view, completionHandler in
            if let friendData = self?.viewModel.friendsPublisher.value[safe: indexPath.row] {
                self?.handleDeleteAction(friendId: friendData.id)
                completionHandler(true)
            }

        }

        deleteAction.backgroundColor = UIColor.App.backgroundSecondary

        let profileAction = UIContextualAction(style: .normal,
                                        title: "Profile") { [weak self] action, view, completionHandler in
            if let friendData = self?.viewModel.friendsPublisher.value[safe: indexPath.row] {
                self?.handleProfileAction(friendData: friendData)
                completionHandler(true)
            }

        }

        profileAction.backgroundColor = UIColor.App.backgroundTertiary

        let swipeActionCofiguration = UISwipeActionsConfiguration(actions: [profileAction, deleteAction, muteAction])

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
    }

    private func handleDeleteAction(friendId: Int) {
        print("Deleted")
        self.viewModel.removeFriend(friendId: friendId)
    }

    private func handleProfileAction(friendData: UserFriend) {

        let friendProfileViewModel = FriendProfileViewModel(friendData: friendData)

        let friendProfileViewController = FriendProfileViewController(viewModel: friendProfileViewModel)

        self.navigationController?.pushViewController(friendProfileViewController, animated: true)
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension FriendsListViewController {
    private static func createSearchBar() -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.contentInsetAdjustmentBehavior = .never
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
        imageView.image = UIImage(named: "no_content_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("no_friends_to_display")
        label.numberOfLines = 0
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .center
        return label
    }

    private func setupSubviews() {

        self.view.addSubview(self.searchBar)

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.emptyStateView)

        self.emptyStateView.addSubview(self.emptyStateImageView)
        self.emptyStateView.addSubview(self.emptyStateLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        // Searchbar
        NSLayoutConstraint.activate([
            self.searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            self.searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            self.searchBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8),
            self.searchBar.heightAnchor.constraint(equalToConstant: 60)
        ])

        // Tableview
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])

        // Empty state view
        NSLayoutConstraint.activate([
            self.emptyStateView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.emptyStateView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.emptyStateView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor),
            self.emptyStateView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.emptyStateImageView.topAnchor.constraint(equalTo: self.emptyStateView.topAnchor, constant: 60),
            self.emptyStateImageView.widthAnchor.constraint(equalToConstant: 120),
            self.emptyStateImageView.heightAnchor.constraint(equalTo: self.emptyStateImageView.widthAnchor),
            self.emptyStateImageView.centerXAnchor.constraint(equalTo: self.emptyStateView.centerXAnchor),

            self.emptyStateLabel.leadingAnchor.constraint(equalTo: self.emptyStateView.leadingAnchor, constant: 80),
            self.emptyStateLabel.trailingAnchor.constraint(equalTo: self.emptyStateView.trailingAnchor, constant: -80),
            self.emptyStateLabel.topAnchor.constraint(equalTo: self.emptyStateImageView.bottomAnchor, constant: 30)
        ])
    }

}
