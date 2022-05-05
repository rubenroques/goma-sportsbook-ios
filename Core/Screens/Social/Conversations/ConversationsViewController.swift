//
//  ConversationsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/03/2022.
//

import UIKit
import Combine

class ConversationsViewController: UIViewController {

    // MAKR: Private Properties
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var tableViewHeader: UIView = Self.createTableViewHeader()
    private lazy var searchBar: UISearchBar = Self.createSearchBar()

    private lazy var newGroupButton: UIButton = Self.createNewGroupButton()
    private lazy var newMessageButton: UIButton = Self.createNewMessageButton()
    private lazy var headerSeparatorLineView: UIView = Self.createHeaderSeparatorLineView()
    private lazy var emptyStateView: UIView = Self.createEmptyStateView()
    private lazy var emptyStateImageView: UIImageView = Self.createEmptyStateImageView()
    private lazy var emptyStateLabel: UILabel = Self.createEmptyStateLabel()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()

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

        self.title = "Messages"

        self.setupSubviews()
        self.setupWithTheme()

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(PreviewChatTableViewCell.self,
                                forCellReuseIdentifier: PreviewChatTableViewCell.identifier)

        self.newGroupButton.addTarget(self, action: #selector(didTapNewGroupButton), for: .primaryActionTriggered)

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(backgroundTapGesture)

        self.bind(toViewModel: self.viewModel)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.tableViewHeader.backgroundColor = UIColor.App.backgroundPrimary
        self.tableView.backgroundColor = UIColor.App.backgroundPrimary

        self.newMessageButton.setTitleColor(UIColor.App.highlightSecondary, for: .normal)
        self.newGroupButton.setTitleColor(UIColor.App.highlightSecondary, for: .normal)

        self.headerSeparatorLineView.backgroundColor = UIColor.App.separatorLine

        self.emptyStateView.backgroundColor = UIColor.App.backgroundPrimary

        self.emptyStateImageView.backgroundColor = .clear

        self.emptyStateLabel.textColor = UIColor.App.textPrimary

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary

        if let image = self.newMessageButton.imageView?.image?.withRenderingMode(.alwaysTemplate) {
            self.newMessageButton.setImage(image, for: .normal)
            self.newMessageButton.tintColor = UIColor.App.highlightSecondary
        }

        self.searchBar.searchBarStyle = UISearchBar.Style.prominent
        self.searchBar.sizeToFit()
        self.searchBar.isTranslucent = false
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.tintColor = .white
        self.searchBar.barTintColor = .white
        self.searchBar.backgroundImage = UIColor.App.backgroundPrimary.image()
        self.searchBar.placeholder = localized("search")

        self.searchBar.delegate = self

        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.App.backgroundSecondary
            textfield.textColor = .white
            textfield.tintColor = .white
            textfield.attributedPlaceholder = NSAttributedString(string: localized("search_field"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor:
                                                                                UIColor.App.inputTextTitle,
                                                                              NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 14)])

            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = UIColor.App.inputTextTitle
            }
        }

    }

    // MARK: Functions

    private func showConversationDetail(conversationData: ConversationData) {
        let conversationDetailViewModel = ConversationDetailViewModel(conversationData: conversationData)

        let conversationDetailViewController = ConversationDetailViewController(viewModel: conversationDetailViewModel)

        self.navigationController?.pushViewController(conversationDetailViewController, animated: true)
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
                self?.isEmptyState = conversations.isEmpty
            })
            .store(in: &cancellables)

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                self?.isLoading = isLoading
            })
            .store(in: &cancellables)
    }
    
}

//
// MARK: - Actions
//
extension ConversationsViewController {

    @objc func didTapBackground() {
        self.searchBar.resignFirstResponder()
    }

    @objc func didTapNewGroupButton() {
        let newGroupViewModel = NewGroupViewModel()
        let newGroupViewController = NewGroupViewController(viewModel: newGroupViewModel)

        self.navigationController?.pushViewController(newGroupViewController, animated: true)
    }
}

//
// MARK: - TableView Protocols
//
extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows(forSectionIndex: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueCellType(PreviewChatTableViewCell.self)
        else {
            fatalError()
        }

        // TEST STATES
        if indexPath.row <= 2 {
            cell.isSeen = false
            cell.isOnline = true
        }
        if let cellData = self.viewModel.conversationsPublisher.value[safe: indexPath.row] {
            let cellViewModel = PreviewChatCellViewModel(cellData: cellData)
            cell.configure(withViewModel: cellViewModel)
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
        return 66
    }
}

extension ConversationsViewController: UISearchBarDelegate {

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
// MARK: - Subviews Initialization and Setup
//
extension ConversationsViewController {

    private static func createTableViewHeader() -> UIView {
        let tableViewHeader = UIView(frame: CGRect(x: 0, y: 0, width: 104, height: 90))
        tableViewHeader.autoresizingMask = .flexibleWidth
        tableViewHeader.translatesAutoresizingMaskIntoConstraints = true
        return tableViewHeader
    }

    private static func createSearchBar() -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }

    private static func createNewGroupButton() -> UIButton {
        let newGroupButton = UIButton(type: .custom)
        newGroupButton.setTitle(localized("new_group"), for: .normal)
        newGroupButton.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        newGroupButton.translatesAutoresizingMaskIntoConstraints = false
        return newGroupButton
    }

    private static func createNewMessageButton() -> UIButton {
        let newMessageButton = UIButton(type: .custom)
        newMessageButton.setImage(UIImage(named: "new_message_icon"), for: .normal)
        newMessageButton.translatesAutoresizingMaskIntoConstraints = false
        return newMessageButton
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
        imageView.image = UIImage(named: "no_content_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("no_chatrooms")
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

        self.tableViewHeader.addSubview(self.searchBar)
        self.tableViewHeader.addSubview(self.newGroupButton)
        self.tableViewHeader.addSubview(self.newMessageButton)
        self.tableViewHeader.addSubview(self.headerSeparatorLineView)

        self.view.addSubview(self.tableView)

        self.tableView.tableHeaderView = self.tableViewHeader

        self.view.addSubview(self.emptyStateView)

        self.emptyStateView.addSubview(self.emptyStateImageView)
        self.emptyStateView.addSubview(self.emptyStateLabel)

        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.activityIndicatorView)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.searchBar.centerXAnchor.constraint(equalTo: self.tableViewHeader.centerXAnchor),
            self.searchBar.leadingAnchor.constraint(equalTo: self.tableViewHeader.leadingAnchor, constant: 14),
            self.searchBar.topAnchor.constraint(equalTo: self.tableViewHeader.topAnchor, constant: 1),

            self.tableViewHeader.bottomAnchor.constraint(equalTo: self.headerSeparatorLineView.bottomAnchor, constant: 0),
            self.tableViewHeader.leadingAnchor.constraint(equalTo: self.headerSeparatorLineView.leadingAnchor, constant: -23),
            self.tableViewHeader.trailingAnchor.constraint(equalTo: self.headerSeparatorLineView.trailingAnchor, constant: 23),
            self.headerSeparatorLineView.heightAnchor.constraint(equalToConstant: 1),

            self.newGroupButton.leadingAnchor.constraint(equalTo: self.tableViewHeader.leadingAnchor, constant: 23),
            self.newGroupButton.bottomAnchor.constraint(equalTo: self.tableViewHeader.bottomAnchor, constant: -9),

            self.newMessageButton.trailingAnchor.constraint(equalTo: self.tableViewHeader.trailingAnchor, constant: -23),
            self.newMessageButton.bottomAnchor.constraint(equalTo: self.tableViewHeader.bottomAnchor, constant: -9),
        ])

        // Table view
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])

        // Empty state view
        NSLayoutConstraint.activate([
            self.emptyStateView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.emptyStateView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.emptyStateView.topAnchor.constraint(equalTo: self.tableViewHeader.bottomAnchor, constant: 8),
            self.emptyStateView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

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
            self.loadingBaseView.topAnchor.constraint(equalTo: self.tableViewHeader.bottomAnchor),
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor)
        ])

    }
}

struct ConversationData {
    var id: Int
    var conversationType: ConversationType
    var name: String
    var lastMessage: String
    var date: String
    var lastMessageUser: String?
    var isLastMessageSeen: Bool
    var groupUsers: [GomaFriend]?
}

enum ConversationType {
    case user
    case group
}
