//
//  ShareTicketFriendGroupViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 05/07/2022.
//

import UIKit
import Combine

class ShareTicketFriendGroupViewModel {
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var chatroomsPublisher: CurrentValueSubject<[ChatroomData], Never> = .init([])
    var initialChatrooms: [ChatroomData] = []
    var cachedChatroomsCellsViewModels: [Int: SelectChatroomCellViewModel] = [:]
    var selectedChatrooms: [ChatroomData] = []
    var sharedTicketInfo: ClickedShareTicketInfo

    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()
    var canSendToChatroomPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var messageSentAction: (() -> Void)?

    init(sharedTicketInfo: ClickedShareTicketInfo) {
        self.sharedTicketInfo = sharedTicketInfo

        self.getChatrooms()

        self.canSendToChatroomPublisher.send(false)
    }

    func filterSearch(searchQuery: String) {

        let filteredChatrooms = self.initialChatrooms.filter({ $0.chatroom.name.localizedCaseInsensitiveContains(searchQuery)})

        self.chatroomsPublisher.value = filteredChatrooms

        self.dataNeedsReload.send()

    }

    func resetUsers() {

        self.chatroomsPublisher.value = self.initialChatrooms

        self.dataNeedsReload.send()
    }

    func getChatrooms() {

        self.isLoadingPublisher.send(true)

        Env.gomaNetworkClient.requestChatrooms(deviceId: Env.deviceId, page: 1)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("CHATROOMS ERROR: \(error)")
                    self?.isLoadingPublisher.send(false)
                    self?.dataNeedsReload.send()

                case .finished:
                    ()
                }

                self?.isLoadingPublisher.send(false)
                self?.dataNeedsReload.send()
            }, receiveValue: { [weak self] response in
                if let chatrooms = response.data {
                    self?.initialChatrooms = chatrooms
                    self?.chatroomsPublisher.value = chatrooms
                }
            })
            .store(in: &cancellables)

    }

    func refetchChatrooms() {
        self.initialChatrooms = []
        self.chatroomsPublisher.value = []
        self.cachedChatroomsCellsViewModels = [:]

        self.getChatrooms()
    }

    func checkSelectedChatrooms(cellViewModel: SelectChatroomCellViewModel) {

        if cellViewModel.isCheckboxSelected {
            self.selectedChatrooms.append(cellViewModel.chatroomData)
        }
        else {
            let chatroomsArray = self.selectedChatrooms.filter {$0.chatroom.id != cellViewModel.chatroomData.chatroom.id}
            self.selectedChatrooms = chatroomsArray
        }

        if self.selectedChatrooms.isEmpty {
            self.canSendToChatroomPublisher.send(false)
        }
        else {
            self.canSendToChatroomPublisher.send(true)
        }

    }

    func sendTicketMessage(message: String) {

        if self.selectedChatrooms.isNotEmpty {

            guard
                let ticket = self.sharedTicketInfo.ticket
            else {
                return
            }

            let betTokenRoute = TSRouter.getSharedBetTokens(betId: ticket.betId)

            Env.everyMatrixClient.manager.getModel(router: betTokenRoute, decodingType: SharedBetToken.self)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure:
                        ()
                        //self?.isLoadingSharedBetPublisher.send(false)
                    case .finished:
                        ()
                    }
                },
                      receiveValue: { [weak self] betToken in
                    guard let self = self else { return }

                    let attachment = self.generateAttachmentString(ticket: ticket,
                                                                   withToken: betToken.sharedBetTokens.betTokenWithAllInfo)

                    for chatroomData in self.selectedChatrooms {

                        Env.gomaSocialClient.sendMessage(chatroomId: chatroomData.chatroom.id,
                                                         message: message,
                                                         attachment: attachment)
                    }

                    //self.isLoadingSharedBetPublisher.send(false)
                    self.messageSentAction?()
                })
                .store(in: &cancellables)
        }
    }

    func generateAttachmentString(ticket: BetHistoryEntry, withToken betShareToken: String) -> [String: AnyObject]? {

        guard let token = Env.gomaNetworkClient.getCurrentToken() else {
            return nil
        }

        let attachment = SharedBetTicketAttachment(id: ticket.betId,
                                                   type: "bet",
                                                   fromUser: "\(token.userId)",
                                                   content: SharedBetTicket(betHistoryEntry: ticket,
                                                                            betShareToken: betShareToken))

        if let jsonData = try? JSONEncoder().encode(attachment) {
            let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: AnyObject]
            return dictionary
        }
        else {
            return nil
        }
    }
}

class ShareTicketFriendGroupViewController: UIViewController {

    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var cancelButton: UIButton = Self.createCancelButton()
    private lazy var searchBar: UISearchBar = Self.createSearchBar()
    private lazy var newGroupButton: UIButton = Self.createNewGroupButton()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var commentBaseView: UIView = Self.createCommentBaseView()
    private lazy var commentTextView: UITextView = Self.createCommentTextView()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()
    private lazy var sendButton: UIButton = Self.createSendButton()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()

    // Constraints
    private lazy var commentInputBottomConstraint: NSLayoutConstraint = Self.createCommentInputBottomConstraint()
    private lazy var commentInputKeyboardConstraint: NSLayoutConstraint = Self.createCommentInputKeyboardConstraint()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: ShareTicketFriendGroupViewModel

    var showPlaceholder: Bool = false {
        didSet {
            if showPlaceholder {
                self.commentTextView.text = localized("comment")
            }
            else {
                self.commentTextView.text = nil
            }
        }
    }

    var isLoading: Bool = false {
        didSet {
            self.loadingBaseView.isHidden = !isLoading
        }
    }

    var canCloseParentViewController: Bool = false

    var textPublisher: CurrentValueSubject<String, Never> = .init("")
    var shouldCloseParentViewController: (() -> Void)?

    // MARK: - Lifetime and Cycle
    init(viewModel: ShareTicketFriendGroupViewModel) {
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

        self.tableView.register(SelectChatroomTableViewCell.self,
                                forCellReuseIdentifier: SelectChatroomTableViewCell.identifier)

        self.commentTextView.delegate = self

        self.cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .primaryActionTriggered)

        self.sendButton.addTarget(self, action: #selector(didTapSendButton), for: .primaryActionTriggered)

        self.newGroupButton.addTarget(self, action: #selector(didTapNewGroup), for: .primaryActionTriggered)

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(backgroundTapGesture)

        self.bind(toViewModel: self.viewModel)

        self.showPlaceholder = true

        // TableView top padding fix
        if #available(iOS 15.0, *) {
          tableView.sectionHeaderTopPadding = 0
        }

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        if canCloseParentViewController{
            self.shouldCloseParentViewController?()
        }
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        self.commentBaseView.layer.cornerRadius = CornerRadius.view

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

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.cancelButton.backgroundColor = .clear
        self.cancelButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.setupSearchBarStyle()

        self.newGroupButton.backgroundColor = .clear
        self.newGroupButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary

        StyleHelper.styleButton(button: self.sendButton)

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

        self.commentBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.commentTextView.backgroundColor = .clear

        self.commentTextView.textColor = UIColor.App.textSecondary

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary

    }

    // MARK: Binding
    private func bind(toViewModel viewModel: ShareTicketFriendGroupViewModel) {

        viewModel.dataNeedsReload
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        viewModel.canSendToChatroomPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isEnabled in
                self?.sendButton.isEnabled = isEnabled
            })
            .store(in: &cancellables)

//        viewModel.chatroomsPublisher
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { [weak self] users in
//                self?.isEmptyState = users.isEmpty
//            })
//            .store(in: &cancellables)

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                self?.isLoading = isLoading
            })
            .store(in: &cancellables)

        viewModel.messageSentAction = { [weak self] in
            guard let self = self else {return}

            //self.shouldCloseParentViewController?()
            self.canCloseParentViewController = true
            self.dismiss(animated: true, completion: nil)

        }
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

    // MARK: Actions

    @objc func didTapCancelButton() {

        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc func didTapSendButton() {
        if !self.showPlaceholder {
            let comment = self.commentTextView.text ?? ""
            self.viewModel.sendTicketMessage(message: comment)
        }
        else {
            self.viewModel.sendTicketMessage(message: localized("check_this_bet_made"))
        }
    }

    @objc func didTapNewGroup() {
        let newGroupViewModel = NewGroupViewModel()
        let newGroupViewController = NewGroupViewController(viewModel: newGroupViewModel)

        newGroupViewController.isSharedTicketNewGroup = true

        newGroupViewController.shareChatroomsNeedReload = { [weak self] in
            self?.viewModel.refetchChatrooms()
        }

        self.navigationController?.pushViewController(newGroupViewController, animated: true)
    }

    @objc func didTapBackground() {
        self.searchBar.resignFirstResponder()

        self.commentTextView.resignFirstResponder()
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        self.commentInputKeyboardConstraint.isActive = false
        self.commentInputBottomConstraint.isActive = true

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height - self.bottomSafeAreaView.frame.height

            self.commentInputKeyboardConstraint =
            NSLayoutConstraint(item: self.sendButton,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: self.bottomSafeAreaView,
                               attribute: .top,
                               multiplier: 1,
                               constant: -keyboardHeight)
            self.commentInputBottomConstraint.isActive = false
            self.commentInputKeyboardConstraint.isActive = true
            }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.commentInputKeyboardConstraint.isActive = false
        self.commentInputBottomConstraint.isActive = true
    }

}

extension ShareTicketFriendGroupViewController: UISearchBarDelegate {

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

        }

        self.searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        self.searchUsers()
    }
}

extension ShareTicketFriendGroupViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.showPlaceholder == true {
            self.showPlaceholder = false
        }

    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.commentTextView.text.isEmpty {
            self.showPlaceholder = true
        }

    }

    func textViewDidChangeSelection(_ textView: UITextView) {

        if !self.showPlaceholder {
            self.textPublisher.send(textView.text)
        }

    }
}

extension ShareTicketFriendGroupViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.chatroomsPublisher.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueCellType(SelectChatroomTableViewCell.self)
        else {
            fatalError()
        }

        if let chatroomData = self.viewModel.chatroomsPublisher.value[safe: indexPath.row] {

            if let cellViewModel = self.viewModel.cachedChatroomsCellsViewModels[chatroomData.chatroom.id] {

                cell.configure(viewModel: cellViewModel)

                cell.didTapCheckboxAction = { [weak self] in
                    self?.viewModel.checkSelectedChatrooms(cellViewModel: cellViewModel)
                }
            }
            else {
                let cellViewModel = SelectChatroomCellViewModel(chatroomData: chatroomData)
                self.viewModel.cachedChatroomsCellsViewModels[chatroomData.chatroom.id] = cellViewModel

                cell.configure(viewModel: cellViewModel)

                cell.didTapCheckboxAction = { [weak self] in
                    self?.viewModel.checkSelectedChatrooms(cellViewModel: cellViewModel)
                }
            }

        }

        if indexPath.row == self.viewModel.chatroomsPublisher.value.count - 1 {
            cell.hasSeparatorLine = false
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

       return 70

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return 70

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 0.01

    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension ShareTicketFriendGroupViewController {
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

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = localized("send_friends_groups")
        return label
    }

    private static func createCancelButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("cancel"), for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        return button
    }

    private static func createSearchBar() -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }

    private static func createNewGroupButton() -> UIButton {
        let button = UIButton()
        button.setTitle(localized("new_group"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 13)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }

    private static func createCommentBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCommentTextView() -> UITextView {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = true
        textView.font = AppFont.with(type: .semibold, size: 16)
        textView.text = localized("comment")
        return textView
    }

    private static func createSendButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("send"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        return button
    }

    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

//    private static func createEmptyStateView() -> UIView {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }
//
//    private static func createEmptyStateImageView() -> UIImageView {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.image = UIImage(named: "no_content_icon")
//        imageView.contentMode = .scaleAspectFit
//        return imageView
//    }
//
//    private static func createEmptyStateLabel() -> UILabel {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = localized("no_friends")
//        label.numberOfLines = 0
//        label.font = AppFont.with(type: .bold, size: 18)
//        label.textAlignment = .center
//        return label
//    }
//
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

    private static func createCommentInputBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createCommentInputKeyboardConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.titleLabel)
        self.navigationView.addSubview(self.cancelButton)

        self.view.addSubview(self.searchBar)

        self.view.addSubview(self.newGroupButton)

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.commentBaseView)

        self.commentBaseView.addSubview(self.commentTextView)

        self.view.addSubview(self.separatorLineView)

        self.view.addSubview(self.sendButton)

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

            //self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationView.centerXAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 56),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -56),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

            self.cancelButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -16),
            self.cancelButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.cancelButton.heightAnchor.constraint(equalToConstant: 40)

        ])

        // Searchbar
        NSLayoutConstraint.activate([
            self.searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            self.searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            self.searchBar.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 0),
            self.searchBar.heightAnchor.constraint(equalToConstant: 60)
        ])

        // New Group Button
        NSLayoutConstraint.activate([
            self.newGroupButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            self.newGroupButton.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 0)
        ])

        // Tableview
        NSLayoutConstraint.activate([

            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.newGroupButton.bottomAnchor, constant: 17),
            self.tableView.bottomAnchor.constraint(equalTo: self.commentTextView.topAnchor, constant: -15)
        ])

        // Bottom views
        NSLayoutConstraint.activate([
            self.commentBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.commentBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.commentBaseView.heightAnchor.constraint(equalToConstant: 43),
            self.commentBaseView.bottomAnchor.constraint(equalTo: self.separatorLineView.topAnchor, constant: -10),

            self.commentTextView.leadingAnchor.constraint(equalTo: self.commentBaseView.leadingAnchor, constant: 20),
            self.commentTextView.trailingAnchor.constraint(equalTo: self.commentBaseView.trailingAnchor, constant: -20),
            self.commentTextView.heightAnchor.constraint(equalToConstant: 37),
            self.commentTextView.centerYAnchor.constraint(equalTo: self.commentBaseView.centerYAnchor),

            self.separatorLineView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),
            self.separatorLineView.bottomAnchor.constraint(equalTo: self.sendButton.topAnchor, constant: -10),

            self.sendButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.sendButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.sendButton.heightAnchor.constraint(equalToConstant: 55),
            self.sendButton.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor, constant: -17),

        ])

        // Empty state view
//        NSLayoutConstraint.activate([
//            self.emptyStateView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            self.emptyStateView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//            self.emptyStateView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor),
//            self.emptyStateView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//
//            self.emptyStateImageView.topAnchor.constraint(equalTo: self.emptyStateView.topAnchor, constant: 60),
//            self.emptyStateImageView.widthAnchor.constraint(equalToConstant: 120),
//            self.emptyStateImageView.heightAnchor.constraint(equalTo: self.emptyStateImageView.widthAnchor),
//            self.emptyStateImageView.centerXAnchor.constraint(equalTo: self.emptyStateView.centerXAnchor),
//
//            self.emptyStateLabel.leadingAnchor.constraint(equalTo: self.emptyStateView.leadingAnchor, constant: 80),
//            self.emptyStateLabel.trailingAnchor.constraint(equalTo: self.emptyStateView.trailingAnchor, constant: -80),
//            self.emptyStateLabel.topAnchor.constraint(equalTo: self.emptyStateImageView.bottomAnchor, constant: 30)
//        ])

        // Loading Screen
        NSLayoutConstraint.activate([
            self.loadingBaseView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor),
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.commentTextView.topAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor)
        ])

        self.commentInputBottomConstraint = NSLayoutConstraint(item: self.sendButton,
                                                               attribute: .bottom,
                                                               relatedBy: .equal,
                                                               toItem: self.bottomSafeAreaView,
                                                               attribute: .top,
                                                               multiplier: 1,
                                                               constant: 0)
        self.commentInputBottomConstraint.isActive = true

        self.commentInputKeyboardConstraint.isActive = false
    }

}
