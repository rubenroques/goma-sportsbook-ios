//
//  AddFriendViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 14/04/2022.
//

import UIKit
import Contacts
import Combine

class AddFriendViewController: UIViewController {
    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var searchFriendLabel: UILabel = Self.createSearchFriendLabel()
    private lazy var searchFriendTextFieldView: ActionTextFieldView = Self.createSearchFriendTextFieldView()
    private lazy var addContactFriendButton: UIButton = Self.createAddContactFriendButton()
    private lazy var tableSeparatorLineView: UIView = Self.createTableSeparatorLineView()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var addFriendBaseView: UIView = Self.createAddFriendBaseView()
    private lazy var addFriendButton: UIButton = Self.createAddFriendButton()
    private lazy var addFriendSeparatorLineView: UIView = Self.createAddFriendSeparatorLineView()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: AddFriendViewModel

    var isEmptySearch: Bool = true {
        didSet {
            self.tableView.isHidden = isEmptySearch
            self.tableSeparatorLineView.isHidden = isEmptySearch
        }
    }

    var chatListNeedsReload: (() -> Void)?

    // MARK: - Lifetime and Cycle
    init(viewModel: AddFriendViewModel) {
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

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(ResultsHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: ResultsHeaderFooterView.identifier)
        self.tableView.register(AddFriendTableViewCell.self,
                                forCellReuseIdentifier: AddFriendTableViewCell.identifier)
        self.tableView.register(FriendStatusTableViewCell.self,
                                forCellReuseIdentifier: FriendStatusTableViewCell.identifier)

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)

        self.addContactFriendButton.addTarget(self, action: #selector(didTapAddContactButton), for: .primaryActionTriggered)

        self.addFriendButton.addTarget(self, action: #selector(didTapAddFriendButton), for: .primaryActionTriggered)

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(backgroundTapGesture)

        self.bind(toViewModel: self.viewModel)

        self.setupPublishers()

        // TableView top padding fix
        if #available(iOS 15.0, *) {
          tableView.sectionHeaderTopPadding = 0
        }
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

        self.searchFriendLabel.textColor = UIColor.App.textPrimary

        self.addContactFriendButton.backgroundColor = .clear
        self.addContactFriendButton.tintColor = UIColor.App.highlightSecondary
        self.addContactFriendButton.setTitleColor(UIColor.App.highlightSecondary, for: .normal)

        self.tableSeparatorLineView.backgroundColor = UIColor.App.separatorLine

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary

        self.addFriendBaseView.backgroundColor = UIColor.App.backgroundPrimary

        StyleHelper.styleButton(button: self.addFriendButton)

        self.addFriendSeparatorLineView.backgroundColor = UIColor.App.separatorLine
    }

    // MARK: binding

    private func bind(toViewModel viewModel: AddFriendViewModel) {

        viewModel.dataNeedsReload
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        viewModel.canAddFriendPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isEnabled in
                self?.addFriendButton.isEnabled = isEnabled
            })
            .store(in: &cancellables)

        viewModel.friendsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] users in
                self?.isEmptySearch = users.isEmpty
            })
            .store(in: &cancellables)

        viewModel.friendCodeInvalidPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.showInvalidCodeAlert()
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

        viewModel.userContactSection
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] userContacts in
                self?.isEmptySearch = userContacts.isEmpty
            })
            .store(in: &cancellables)

        // Close screen after chatroom list and last message are updated
        Env.gomaSocialClient.allDataSubscribed
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                guard let self = self else {return}

                if self.viewModel.chatroomsResponse.count > 1 {
                    self.navigationController?.popViewController(animated: true)

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
    private func setupPublishers() {
        self.searchFriendTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                if text != "" {
                    self?.searchFriendTextFieldView.isActionDisabled = false
                }
                else {
                    self?.searchFriendTextFieldView.isActionDisabled = true
                }
            })
            .store(in: &cancellables)

        self.searchFriendTextFieldView.didTapButtonAction = { [weak self] in
            let friendCode = self?.searchFriendTextFieldView.getTextFieldValue() ?? ""
            self?.viewModel.getUserInfo(friendCode: friendCode)
        }
    }

    private func showInvalidCodeAlert() {
        let invalidCodeAlert = UIAlertController(title: localized("invalid_code"),
                                                   message: localized("invalid_code_message"),
                                                   preferredStyle: UIAlertController.Style.alert)

        invalidCodeAlert.addAction(UIAlertAction(title: localized("ok"), style: .default))

        self.present(invalidCodeAlert, animated: true, completion: nil)
    }

    private func showAddFriendAlert(friendAlertType: FriendAlertType) {
        switch friendAlertType {
        case .success:

            Env.gomaSocialClient.forceRefresh()

//            self.chatListNeedsReload?()
//
//            self.navigationController?.popViewController(animated: true)
        case .error:
            let errorFriendAlert = UIAlertController(title: localized("friend_added_error"),
                                                       message: localized("friend_added_message_error"),
                                                       preferredStyle: UIAlertController.Style.alert)

            errorFriendAlert.addAction(UIAlertAction(title: localized("ok"), style: .default))

            self.present(errorFriendAlert, animated: true, completion: nil)
        }

    }

    private func showChatroom(friendId: Int? = nil, chatroomId: Int? = nil) {

        if let friendId = friendId {
            let conversationData = self.viewModel.getConversationData(userId: "\(friendId)")

            let conversationDetailViewModel = ConversationDetailViewModel(conversationData: conversationData)

            let conversationDetailViewController = ConversationDetailViewController(viewModel: conversationDetailViewModel)

            self.navigationController?.pushViewController(conversationDetailViewController, animated: true)
        }

        if let chatroomId = chatroomId {
            let chatId = chatroomId

            let conversationDetailViewModel = ConversationDetailViewModel(chatId: chatId)

            let conversationDetailViewController = ConversationDetailViewController(viewModel: conversationDetailViewModel)

            self.navigationController?.pushViewController(conversationDetailViewController, animated: true)
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

    @objc func didTapAddContactButton() {

        let contactStore = CNContactStore()

        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            print("Authorized")
            let addContactViewModel = AddContactViewModel()
            let addContactViewController = AddContactViewController(viewModel: addContactViewModel)

            addContactViewController.chatListNeedsReload = { [weak self] in
                self?.chatListNeedsReload?()
            }

            self.navigationController?.pushViewController(addContactViewController, animated: true)

        case .notDetermined:
            print("Not determined")
            contactStore.requestAccess(for: .contacts) { succeeded, error in
                guard succeeded && error == nil else {
                    return
                }

                if succeeded {
                    DispatchQueue.main.async {
                        let addContactViewModel = AddContactViewModel()
                        let addContactViewController = AddContactViewController(viewModel: addContactViewModel)

                        addContactViewController.chatListNeedsReload = { [weak self] in
                            self?.chatListNeedsReload?()
                        }

                        self.navigationController?.pushViewController(addContactViewController, animated: true)
                    }

                }
            }

        case .denied:
            print("Not handled")

        case .restricted:
            print("Not handled")

        @unknown default:
            print("Not handled")
        }

    }

    @objc func didTapAddFriendButton() {
        print("FRIENDS SELECTED: \(self.viewModel.selectedUsers)")

        self.viewModel.sendFriendRequest()
    }

    @objc func didTapBackground() {
        self.searchFriendTextFieldView.resignFirstResponder()
    }

}

//
// MARK: Delegates
//
extension AddFriendViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.userContactSection.value.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return self.viewModel.usersPublisher.value.count
        return self.viewModel.userContactSection.value[section].userContacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if self.viewModel.userContactSection.value[indexPath.section].contactSectionType == .search {

            guard let cell = tableView.dequeueCellType(AddFriendTableViewCell.self)
            else {
                fatalError()
            }

            if let userContact = self.viewModel.usersPublisher.value[safe: indexPath.row] {

                if let cellViewModel = self.viewModel.cachedSearchCellViewModels[userContact.id] {
                    cell.configure(viewModel: cellViewModel)

                    cell.didTapCheckboxAction = { [weak self] in
                        self?.viewModel.checkSelectedUserContact(cellViewModel: cellViewModel)
                    }
                }
                else {
                    let cellViewModel = AddFriendCellViewModel(userContact: userContact)
                    self.viewModel.cachedSearchCellViewModels[userContact.id] = cellViewModel
                    cell.configure(viewModel: cellViewModel)

                    cell.didTapCheckboxAction = { [weak self] in
                        self?.viewModel.checkSelectedUserContact(cellViewModel: cellViewModel)
                    }
                }

            }

            if indexPath.row == self.viewModel.usersPublisher.value.count - 1 {
                cell.hasSeparatorLine = false
            }

            return cell
        }
        else if self.viewModel.userContactSection.value[indexPath.section].contactSectionType == .friends {
            guard
                let cell = tableView.dequeueCellType(FriendStatusTableViewCell.self)
            else {
                fatalError()
            }

            if let friend = self.viewModel.friendsPublisher.value[safe: indexPath.row] {

                if let cellViewModel = self.viewModel.cachedFriendsCellViewModels[friend.id] {
                    cell.configure(withViewModel: cellViewModel)
                }
                else {
                    let cellViewModel = FriendStatusCellViewModel(friend: friend)
                    self.viewModel.cachedFriendsCellViewModels[friend.id] = cellViewModel

                    cell.configure(withViewModel: cellViewModel)
                }

                if indexPath.row == self.viewModel.userContactSection.value[indexPath.section].userContacts.count - 1 {
                    cell.hasSeparatorLine = false
                }
                else {
                    cell.hasSeparatorLine = true
                }

                cell.shouldShowChatroom = { [weak self] in
                    self?.showChatroom(friendId: friend.id)
                }

            }

            return cell
        }

        else {
            return UITableViewCell()
        }

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if self.viewModel.userContactSection.value[section].contactSectionType == .search {

            if self.viewModel.usersPublisher.value.isNotEmpty {
                guard
                    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ResultsHeaderFooterView.identifier) as? ResultsHeaderFooterView
                else {
                    fatalError()
                }

                let resultsLabel = "Results (\(self.viewModel.usersPublisher.value.count))"

                headerView.configureHeader(title: resultsLabel)

                return headerView
            }
            else {
                return UIView()
            }
        }
        else if self.viewModel.userContactSection.value[section].contactSectionType == .friends {
            if self.viewModel.friendsPublisher.value.isNotEmpty {
                guard
                    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ResultsHeaderFooterView.identifier) as? ResultsHeaderFooterView
                else {
                    fatalError()
                }

                let resultsLabel = localized("my_friends")

                headerView.configureHeader(title: resultsLabel)

                return headerView
            }
            else {
                return UIView()
            }

        }
        else {
            return UIView()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if self.viewModel.userContactSection.value.isNotEmpty {
            return 70
        }
        else {
            return 0
        }

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        if self.viewModel.userContactSection.value.isNotEmpty {
            return 70
        }
        else {
            return 0
        }

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if self.viewModel.userContactSection.value.isNotEmpty {
            return 30
        }
        else {
            return 0
        }

    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

        if self.viewModel.userContactSection.value.isNotEmpty {
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
extension AddFriendViewController {
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
        label.text = localized("add_friend")
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

    private static func createSearchFriendLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.text = localized("search_friend_code")
        return label
    }

    private static func createSearchFriendTextFieldView() -> ActionTextFieldView {
        let textFieldView = ActionTextFieldView()
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        textFieldView.setPlaceholderText(placeholder: localized("friend_code"))
        textFieldView.setActionButtonTitle(title: localized("search"))
        return textFieldView
    }

    private static func createAddContactFriendButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "add_orange_icon"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.setTitle(localized("add_from_contact"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        return button
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

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.titleLabel)
        self.navigationView.addSubview(self.closeButton)

//        self.view.addSubview(self.searchBar)

        self.view.addSubview(self.searchFriendLabel)

        self.view.addSubview(self.searchFriendTextFieldView)

        self.view.addSubview(self.addContactFriendButton)

        self.view.addSubview(self.tableSeparatorLineView)

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.addFriendBaseView)

        self.addFriendBaseView.addSubview(self.addFriendButton)
        self.addFriendBaseView.addSubview(self.addFriendSeparatorLineView)

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

        // Search friend code views
        NSLayoutConstraint.activate([
            self.searchFriendLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
            self.searchFriendLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            self.searchFriendLabel.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 8),

            self.searchFriendTextFieldView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
            self.searchFriendTextFieldView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            self.searchFriendTextFieldView.topAnchor.constraint(equalTo: self.searchFriendLabel.bottomAnchor, constant: 8),
        ])

        // Contact list button
        NSLayoutConstraint.activate([
            self.addContactFriendButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.addContactFriendButton.topAnchor.constraint(equalTo: self.searchFriendTextFieldView.bottomAnchor, constant: 30)
        ])

        // Tableview
        NSLayoutConstraint.activate([

            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.tableSeparatorLineView.bottomAnchor, constant: 25),

            self.tableSeparatorLineView.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor, constant: 25),
            self.tableSeparatorLineView.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor, constant: -25),
            self.tableSeparatorLineView.topAnchor.constraint(equalTo: self.addContactFriendButton.bottomAnchor, constant: 10),
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

    }
}
