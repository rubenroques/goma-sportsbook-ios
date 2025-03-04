//
//  AddContactViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 20/04/2022.
//

import UIKit
import Combine
import LinkPresentation

class AddContactViewController: UIViewController {
    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var searchBar: UISearchBar = Self.createSearchBar()
    private lazy var tableSeparatorLineView: UIView = Self.createTableSeparatorLineView()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var addFriendBaseView: UIView = Self.createAddFriendBaseView()
    private lazy var addFriendButton: UIButton = Self.createAddFriendButton()
    private lazy var addFriendSeparatorLineView: UIView = Self.createAddFriendSeparatorLineView()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: AddContactViewModel

    var isEmptySearch: Bool = true {
        didSet {
            self.tableView.isHidden = isEmptySearch
            self.tableSeparatorLineView.isHidden = isEmptySearch
        }
    }

    var isLoading: Bool = false {
        didSet {
            self.loadingBaseView.isHidden = !isLoading
        }
    }

    var chatListNeedsReload: (() -> Void)?

    // MARK: - Lifetime and Cycle
    init(viewModel: AddContactViewModel) {
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

        self.searchBar.delegate = self

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(ResultsHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: ResultsHeaderFooterView.identifier)
        self.tableView.register(AddFriendTableViewCell.self,
                                forCellReuseIdentifier: AddFriendTableViewCell.identifier)
        self.tableView.register(InviteContactTableViewCell.self,
                                forCellReuseIdentifier: InviteContactTableViewCell.identifier)

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)

        self.addFriendButton.addTarget(self, action: #selector(didTapAddFriendButton), for: .primaryActionTriggered)

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(backgroundTapGesture)

        self.bind(toViewModel: self.viewModel)

        self.isEmptySearch = false
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

        self.closeButton.backgroundColor = .clear
        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.setupSearchBarStyle()

        self.tableSeparatorLineView.backgroundColor = UIColor.App.separatorLine

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary

        self.addFriendBaseView.backgroundColor = UIColor.App.backgroundPrimary

        StyleHelper.styleButton(button: self.addFriendButton)

        self.addFriendSeparatorLineView.backgroundColor = UIColor.App.separatorLine
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: AddContactViewModel) {

        viewModel.dataNeedsReload
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        viewModel.isEmptySearchPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isEmptySearch in
                self?.isEmptySearch = isEmptySearch
            })
            .store(in: &cancellables)

        viewModel.canAddFriendPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isEnabled in
                self?.addFriendButton.isEnabled = isEnabled
            })
            .store(in: &cancellables)

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                self?.isLoading = isLoading
            })
            .store(in: &cancellables)

        viewModel.shouldShowAlert
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] showAlert in
                if showAlert, let friendAlertType = viewModel.friendAlertType {
                    self?.showAddFriendAlert(friendAlertType: friendAlertType)
                }
            })
            .store(in: &cancellables)

        // Close screen after chatroom list and last message are updated
        Env.gomaSocialClient.allDataSubscribed
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in

                guard let self = self else {return}

                if self.viewModel.chatroomsResponse.count > 1 {
                    self.navigationController?.popToRootViewController(animated: true)

                }
                else {
                    if let chatroomId = self.viewModel.chatroomsResponse[safe: 0] {

                        self.showChatroom(chatroomId: chatroomId)

                    }
                }
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
            textfield.attributedPlaceholder = NSAttributedString(string: localized("search_by_contact"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor:
                                                                                UIColor.App.inputTextTitle,
                                                                              NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 14)])

            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = UIColor.App.inputTextTitle
            }
        }
    }

    private func shareAppInvite() {

        let metadata = LPLinkMetadata()
        let urlMobile = TargetVariables.clientBaseUrl

        metadata.url = URL(string: urlMobile)
        metadata.originalURL = metadata.url
        var text = ""
        if let loggedUser = Env.userSessionStore.loggedUserProfile,
           let userCode = Env.gomaNetworkClient.getCurrentToken()?.code {
            metadata.title = "The user \(loggedUser.username) has invited you to Sportsbook!"
            text = "The user \(loggedUser.username) has invited you to Sportsbook! Join him and add him as a friend by searching this code in the app: \(userCode)"
        }

        let metadataItemSource = LinkPresentationItemSource(metaData: metadata)

        let shareActivityViewController = UIActivityViewController(activityItems: [metadataItemSource, text], applicationActivities: nil)

        shareActivityViewController.setValue("Sportsbook App Invite!", forKey: "subject")

        if let popoverController = shareActivityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        self.present(shareActivityViewController, animated: true, completion: nil)

    }

    private func showAddFriendAlert(friendAlertType: FriendAlertType) {
        switch friendAlertType {
        case .success:
            
            Env.gomaSocialClient.forceRefresh()

//            self.chatListNeedsReload?()
//
//            self.navigationController?.popToRootViewController(animated: true)
        case .error:
            let errorFriendAlert = UIAlertController(title: localized("friend_added_error"),
                                                       message: localized("friend_added_message_error"),
                                                       preferredStyle: UIAlertController.Style.alert)

            errorFriendAlert.addAction(UIAlertAction(title: localized("ok"), style: .default))

            self.present(errorFriendAlert, animated: true, completion: nil)
        }

    }

    private func showChatroom(chatroomId: Int) {

        let conversationDetailViewModel = ConversationDetailViewModel(chatId: chatroomId)

        let conversationDetailViewController = ConversationDetailViewController(viewModel: conversationDetailViewModel)

        self.navigationController?.pushViewController(conversationDetailViewController, animated: true)

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

    @objc func didTapAddFriendButton() {

        self.viewModel.sendFriendRequest()
    }

    @objc func didTapBackground() {
        self.searchBar.resignFirstResponder()
    }

}

//
// MARK: Delegates
//
extension AddContactViewController: UISearchBarDelegate {

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

extension AddContactViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.sectionUsersArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.sectionUsersArray[section].userContacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.viewModel.sectionUsersArray[safe: indexPath.section]?.contactType == .registered {

            guard let cell = tableView.dequeueCellType(AddFriendTableViewCell.self)
            else {
                fatalError()
            }

            if let userContact = self.viewModel.sectionUsersArray[safe: indexPath.section]?.userContacts[safe: indexPath.row] {

                if let cellViewModel = self.viewModel.cachedFriendCellViewModels[userContact.id] {
                    cell.configure(viewModel: cellViewModel)

                    cell.didTapCheckboxAction = { [weak self] in
                        self?.viewModel.checkSelectedUserContact(cellViewModel: cellViewModel)
                    }
                }
                else {
                    let cellViewModel = AddFriendCellViewModel(userContact: userContact)
                    self.viewModel.cachedFriendCellViewModels[userContact.id] = cellViewModel
                    cell.configure(viewModel: cellViewModel)

                    cell.didTapCheckboxAction = { [weak self] in
                        self?.viewModel.checkSelectedUserContact(cellViewModel: cellViewModel)
                    }
                }

            }

            if let sectionUsersCount = self.viewModel.sectionUsersArray[safe: indexPath.section]?.userContacts.count, indexPath.row == sectionUsersCount - 1 {

                cell.hasSeparatorLine = false
            }

            return cell
        }
        else {
            guard let cell = tableView.dequeueCellType(InviteContactTableViewCell.self)
            else {
                fatalError()
            }

            cell.didTapInviteAction = { [weak self] in
                    self?.shareAppInvite()
                }

            return cell
        }

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if !self.viewModel.isEmptySearchPublisher.value {
            guard
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ResultsHeaderFooterView.identifier) as? ResultsHeaderFooterView
            else {
                fatalError()
            }

            if self.viewModel.sectionUsersArray[section].contactType == .registered {
                let resultsLabel = localized("my_friends")

                headerView.configureHeader(title: resultsLabel)
            }
            else {
                if self.viewModel.hasRegisteredFriends && self.viewModel.sectionUsers[UserContactType.registered.identifier] != nil {
                    let resultsLabel = localized("invite_more_friends")

                    headerView.configureHeader(title: resultsLabel)
                }
                else if self.viewModel.hasRegisteredFriends && self.viewModel.sectionUsers[UserContactType.registered.identifier] == nil {

                    let resultsLabel = localized("no_other_users_registered")

                    headerView.configureHeader(title: resultsLabel)                }
                else {
                    let resultsLabel = localized("no_user_contact_registered")

                    headerView.configureHeader(title: resultsLabel)
                }

            }

            return headerView
        }
        else {
            return UIView()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if !self.viewModel.isEmptySearchPublisher.value {
            return UITableView.automaticDimension
        }
        else {
            return 0
        }

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        if !self.viewModel.isEmptySearchPublisher.value {
            return 70
        }
        else {
            return 0
        }

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if !self.viewModel.isEmptySearchPublisher.value {
            return 30
        }
        else {
            return 0
        }

    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

        if !self.viewModel.isEmptySearchPublisher.value {
            return 30
        }
        else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension AddContactViewController {
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

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = localized("add_contact")
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

    private static func createSearchBar() -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }

    private static func createTableSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }

    private static func createAddFriendBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAddFriendButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("add_friend"), for: .normal)
        return button
    }

    private static func createAddFriendSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        self.navigationView.addSubview(self.titleLabel)
        self.navigationView.addSubview(self.closeButton)

        self.view.addSubview(self.searchBar)

        self.view.addSubview(self.tableSeparatorLineView)

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.addFriendBaseView)

        self.addFriendBaseView.addSubview(self.addFriendButton)
        self.addFriendBaseView.addSubview(self.addFriendSeparatorLineView)

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
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

            self.closeButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -16),
            self.closeButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.closeButton.heightAnchor.constraint(equalToConstant: 40)

        ])

        // Searchbar
        NSLayoutConstraint.activate([
            self.searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            self.searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            self.searchBar.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 8),
            self.searchBar.heightAnchor.constraint(equalToConstant: 60)
        ])

        // Tableview
        NSLayoutConstraint.activate([

            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 16),

            self.tableSeparatorLineView.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor, constant: 25),
            self.tableSeparatorLineView.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor, constant: -25),
            self.tableSeparatorLineView.bottomAnchor.constraint(equalTo: self.tableView.topAnchor),
            self.tableSeparatorLineView.heightAnchor.constraint(equalToConstant: 1)

        ])

        // Add Friend Button View
        NSLayoutConstraint.activate([
            self.addFriendBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.addFriendBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.addFriendBaseView.topAnchor.constraint(equalTo: self.tableView.bottomAnchor, constant: 8),
            self.addFriendBaseView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),
            self.addFriendBaseView.heightAnchor.constraint(equalToConstant: 105),

            self.addFriendButton.leadingAnchor.constraint(equalTo: self.addFriendBaseView.leadingAnchor, constant: 33),
            self.addFriendButton.trailingAnchor.constraint(equalTo: self.addFriendBaseView.trailingAnchor, constant: -33),
            self.addFriendButton.heightAnchor.constraint(equalToConstant: 55),
            self.addFriendButton.centerYAnchor.constraint(equalTo: self.addFriendBaseView.centerYAnchor),

            self.addFriendSeparatorLineView.leadingAnchor.constraint(equalTo: self.addFriendBaseView.leadingAnchor),
            self.addFriendSeparatorLineView.trailingAnchor.constraint(equalTo: self.addFriendBaseView.trailingAnchor),
            self.addFriendSeparatorLineView.topAnchor.constraint(equalTo: self.addFriendBaseView.topAnchor),
            self.addFriendSeparatorLineView.heightAnchor.constraint(equalToConstant: 1),
        ])

        // Loading Screen
        NSLayoutConstraint.activate([
            self.loadingBaseView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor),
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor)
        ])

    }
}
