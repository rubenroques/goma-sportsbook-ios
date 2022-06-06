//
//  ConversationDetailViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 06/04/2022.
//

import UIKit
import Combine
import Nuke

class ConversationDetailViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconView: UIView = Self.createIconView()
    private lazy var iconIdentifierLabel: UILabel = Self.createIconIdentifierLabel()
    private lazy var iconUserImageView: UIImageView = Self.createIconUserImageView()
    private lazy var iconStateView: UIView = Self.createIconStateView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var navigationLineSeparatorView: UIView = Self.createNavigationLineSeparatorView()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var messageInputBaseView: UIView = Self.createMessageInputBaseView()
    private lazy var messageInputLineSeparatorView: UIView = Self.createMessageInputLineSeparatorView()
    private lazy var messageInputView: ChatMessageView = Self.createMessageInputView()
    private lazy var sendButton: UIButton = Self.createSendButton()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    // Constraints
    private lazy var messageInputBottomConstraint: NSLayoutConstraint = Self.createMessageInputBottomConstraint()
    private lazy var messageInputKeyboardConstraint: NSLayoutConstraint = Self.createMessageInputKeyboardConstraint()

    private var viewModel: ConversationDetailViewModel

    private var cancellables = Set<AnyCancellable>()

    private var isChatGroup: Bool = false {
        didSet {
            self.iconIdentifierLabel.isHidden = !isChatGroup
            self.iconUserImageView.isHidden = isChatGroup
        }
    }

    // MARK: Public Properties
    var shouldCloseChat: (() -> Void)?
    var shouldReloadData: (() -> Void)?

    // MARK: - Lifetime and Cycle
    init(viewModel: ConversationDetailViewModel) {
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
        
        self.tableView.register(ReceivedMessageTableViewCell.self,
                                forCellReuseIdentifier: ReceivedMessageTableViewCell.identifier)
        self.tableView.register(ReceivedTicketMessageTableViewCell.self,
                                forCellReuseIdentifier: ReceivedTicketMessageTableViewCell.identifier)

        self.tableView.register(SentMessageTableViewCell.self,
                                forCellReuseIdentifier: SentMessageTableViewCell.identifier)
        self.tableView.register(SentTicketMessageTableViewCell.self,
                                forCellReuseIdentifier: SentTicketMessageTableViewCell.identifier)

        tableView.register(DateHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: DateHeaderFooterView.identifier)

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.sendButton.addTarget(self, action: #selector(didTapSendButton), for: .primaryActionTriggered)

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(backgroundTapGesture)

        let contactTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapContactInfo))
        self.navigationView.addGestureRecognizer(contactTapGesture)

        if self.viewModel.isChatOnline {
            self.iconStateView.isHidden = false
        }
        else {
            self.iconStateView.isHidden = true
        }

        self.isChatGroup = self.viewModel.isChatGroup

        self.bind(toViewModel: self.viewModel)

        self.setupPublishers()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.scrollToBottomTableView()

    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2

        self.iconView.layer.cornerRadius = self.iconView.frame.height / 2

        self.iconStateView.layer.cornerRadius = self.iconStateView.frame.height / 2

        self.iconUserImageView.layer.cornerRadius = self.iconUserImageView.frame.height / 2

        self.sendButton.layer.cornerRadius = self.sendButton.frame.height / 2
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

        self.iconBaseView.backgroundColor = UIColor.App.buttonBackgroundSecondary

        self.iconView.backgroundColor = UIColor.App.backgroundPrimary

        self.iconIdentifierLabel.textColor = UIColor.App.buttonBackgroundSecondary

        self.iconStateView.backgroundColor = UIColor.App.alertSuccess

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.navigationLineSeparatorView.backgroundColor = UIColor.App.separatorLine

        self.tableView.backgroundColor = .clear

        self.messageInputBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.messageInputLineSeparatorView.backgroundColor = UIColor.App.separatorLine

        self.sendButton.backgroundColor = UIColor.App.buttonBackgroundPrimary

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.8)
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: ConversationDetailViewModel) {

        viewModel.titlePublisher
            .sink(receiveValue: { [weak self] title in
                self?.titleLabel.text = title
            })
            .store(in: &cancellables)

        viewModel.usersPublisher
            .sink(receiveValue: { [weak self] users in
                self?.subtitleLabel.text = users
            })
            .store(in: &cancellables)

        viewModel.groupInitialsPublisher
            .sink(receiveValue: { [weak self] initials in
                self?.iconIdentifierLabel.text = initials
            })
            .store(in: &cancellables)

        viewModel.dataNeedsReload
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        viewModel.shouldScrollToLastMessage
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.scrollToBottomTableView()
            })
            .store(in: &cancellables)

        viewModel.isLoadingSharedBetPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                }
                else {
                    self?.hideLoading()
                }
            }.store(in: &cancellables)

        viewModel.ticketAddedToBetslipAction = { [weak self] addedWithSuccess in
            if addedWithSuccess {
                self?.showBetslipViewController()
            }
        }
        
    }

    // MARK: Functions
    private func setupPublishers() {

        self.messageInputView.textPublisher
            .map { text in
                if text != "" {
                    return true
                }
                return false
            }
            .assign(to: \.isEnabled, on: self.sendButton)
            .store(in: &cancellables)

    }

    func scrollToBottomTableView(animated: Bool = true) {
        if self.viewModel.dateMessages.isNotEmpty {

            let section = self.viewModel.dateMessages.count - 1

            if let dateMessages = self.viewModel.dateMessages[safe: section] {

                let row = dateMessages.messages.count - 1

                let indexPath = IndexPath(row: row, section: section)

                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)

            }

        }

    }

    private func showBetSelectionScreen() {
        print("Show Bet Selection!")

        let conversationData = self.viewModel.getConversationData()

        let betSelectionViewModel = ConversationBetSelectionViewModel(conversationData: conversationData)

        let betSelectionViewController = ConversationBetSelectionViewController(viewModel: betSelectionViewModel)

        self.present(betSelectionViewController, animated: true, completion: nil)
    }

    private func addTicketToBetslip(ticket: BetHistoryEntry) {
        if let betShareToken = ticket.betShareToken {
            self.viewModel.addBetTicketToBetslip(withBetToken: betShareToken)
        }
    }

    // MARK: Actions
    @objc func didTapBackButton() {
        
        self.shouldReloadData?()

        self.navigationController?.popToRootViewController(animated: true)
    }

    @objc func didTapSendButton() {

        let dateNow = Date()
        let dateNowString = self.viewModel.getDefaultDateFormatted(date: dateNow)
        let dateNowTimestamp = Int(Date().timeIntervalSince1970)

        let message = self.messageInputView.getTextViewValue()

        if message != "" {

            let messageData = MessageData(type: .sentNotSeen, text: message, date: dateNowString, timestamp: dateNowTimestamp)

            self.viewModel.addMessage(message: messageData)
            self.messageInputView.clearTextView()
        }

    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.messageInputView.resignFirstResponder()
    }

    @objc func didTapContactInfo() {
        if self.isChatGroup {

            let conversationData = self.viewModel.getConversationData()
            
            // print("GROUP USERS: \(conversationData)")

            let editGroupViewModel = EditGroupViewModel(conversationData: conversationData)

            let editContactViewController = EditGroupViewController(viewModel: editGroupViewModel)

            editContactViewController.shouldCloseChat = { [weak self] in
                self?.shouldCloseChat?()
            }

            editContactViewController.shouldReloadData = { [weak self] in
                self?.shouldReloadData?()
            }

            editContactViewController.shouldUpdateGroupInfo = { [weak self] groupInfo in
                self?.viewModel.updateConversationInfo(groupInfo: groupInfo)
            }

            self.navigationController?.pushViewController(editContactViewController, animated: true)
        }
        else {

            let conversationData = self.viewModel.getConversationData()

            let editContactViewModel = EditContactViewModel(conversationData: conversationData)

            let editContactViewController = EditContactViewController(viewModel: editContactViewModel)

            editContactViewController.shouldCloseChat = { [weak self] in
                self?.shouldCloseChat?()
            }

            self.navigationController?.pushViewController(editContactViewController, animated: true)
        }
    }

    private func showLoading() {
        self.loadingBaseView.isHidden = false
        self.loadingActivityIndicatorView.startAnimating()
    }

    private func hideLoading() {
        self.loadingBaseView.isHidden = true
        self.loadingActivityIndicatorView.stopAnimating()
    }

    private func showBetslipViewController() {
        let betslipViewController = BetslipViewController()
        self.present(Router.navigationController(with: betslipViewController), animated: true, completion: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        self.messageInputKeyboardConstraint.isActive = false
        self.messageInputBottomConstraint.isActive = true
        self.scrollToBottomTableView()

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height - self.bottomSafeAreaView.frame.height

            self.messageInputKeyboardConstraint =
            NSLayoutConstraint(item: self.messageInputBaseView,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: self.bottomSafeAreaView,
                               attribute: .top,
                               multiplier: 1,
                               constant: -keyboardHeight)
            self.messageInputBottomConstraint.isActive = false
            self.messageInputKeyboardConstraint.isActive = true
            }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.messageInputKeyboardConstraint.isActive = false
        self.messageInputBottomConstraint.isActive = true
    }

}

//
// MARK: - TableView Protocols
//
extension ConversationDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows(forSectionIndex: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let messageData = self.viewModel.messageData(forIndexPath: indexPath) {
            if messageData.type == .sentNotSeen || messageData.type == .sentSeen {
                if messageData.attachment != nil {
                    guard
                        let cell = tableView.dequeueCellType(SentTicketMessageTableViewCell.self)
                    else {
                        fatalError()
                    }
                    cell.setupMessage(messageData: messageData)
                    cell.didTapBetNowAction = { [weak self] viewModel in
                        self?.addTicketToBetslip(ticket: viewModel.ticket)
                    }
                    return cell
                }
                else {
                    guard
                        let cell = tableView.dequeueCellType(SentMessageTableViewCell.self)
                    else {
                        fatalError()
                    }
                    cell.setupMessage(messageData: messageData)
                    return cell
                }
            }
            else {

                if messageData.attachment != nil {
                    guard
                        let cell = tableView.dequeueCellType(ReceivedTicketMessageTableViewCell.self)
                    else {
                        fatalError()
                    }
                    if let userId = messageData.userId {
                        let username = self.viewModel.getUsername(userId: userId)
                        cell.setupMessage(messageData: messageData, username: username)
                        cell.didTapBetNowAction = { [weak self] viewModel in
                            self?.addTicketToBetslip(ticket: viewModel.ticket)
                        }
                    }
                    return cell
                }
                else {
                    guard
                        let cell = tableView.dequeueCellType(ReceivedMessageTableViewCell.self)
                    else {
                        fatalError()
                    }
                    if let userId = messageData.userId {
                        let username = self.viewModel.getUsername(userId: userId)
                        cell.setupMessage(messageData: messageData, username: username)
                    }
                    return cell
                }
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: DateHeaderFooterView.identifier) as? DateHeaderFooterView
        else {
            fatalError()
        }
        
        let headerDate = self.viewModel.sectionTitle(forSectionIndex: section)
        headerView.configureHeader(title: headerDate)

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 20
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
extension ConversationDetailViewController {
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

    private static func createIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconIdentifierLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "C"
        label.font = AppFont.with(type: .bold, size: 16)
        return label
    }

    private static func createIconUserImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "my_account_profile_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createIconStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = "Chat Title"
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textSecondary
        label.font = AppFont.with(type: .regular, size: 14)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = "@chattitle"
        return label
    }

    private static func createBackButton() -> UIButton {
        let backButton = UIButton.init(type: .custom)
        backButton.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        backButton.setTitle(nil, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        return backButton
    }

    private static func createNavigationLineSeparatorView() -> UIView {
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

    private static func createMessageInputBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createMessageInputLineSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createMessageInputView() -> ChatMessageView {
        let view = ChatMessageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSendButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "send_message_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        return button
    }

    private static func createMessageInputBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createMessageInputKeyboardConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.stopAnimating()
        return activityIndicatorView
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)

        self.navigationView.addSubview(self.iconBaseView)

        self.iconBaseView.addSubview(self.iconView)
        self.iconBaseView.addSubview(self.iconStateView)

        self.iconView.addSubview(self.iconIdentifierLabel)
        self.iconView.addSubview(self.iconUserImageView)

        self.navigationView.addSubview(self.titleLabel)
        self.navigationView.addSubview(self.subtitleLabel)
        self.navigationView.addSubview(self.navigationLineSeparatorView)

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.messageInputBaseView)

        self.messageInputBaseView.addSubview(self.messageInputLineSeparatorView)
        self.messageInputBaseView.addSubview(self.messageInputView)
        self.messageInputBaseView.addSubview(self.sendButton)

        self.view.addSubview(self.bottomSafeAreaView)

        self.view.addSubview(self.loadingBaseView)
        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.initConstraints()

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

        self.messageInputView.shouldShowBetSelection = { [weak self] in
            self?.showBetSelectionScreen()
        }
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

            self.iconBaseView.leadingAnchor.constraint(equalTo: self.backButton.trailingAnchor, constant: 32),
            self.iconBaseView.heightAnchor.constraint(equalToConstant: 32),
            self.iconBaseView.widthAnchor.constraint(equalTo: self.iconBaseView.heightAnchor),
            self.iconBaseView.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

            self.iconView.widthAnchor.constraint(equalToConstant: 29),
            self.iconView.heightAnchor.constraint(equalTo: self.iconView.widthAnchor),
            self.iconView.centerXAnchor.constraint(equalTo: self.iconBaseView.centerXAnchor),
            self.iconView.centerYAnchor.constraint(equalTo: self.iconBaseView.centerYAnchor),

            self.iconIdentifierLabel.centerXAnchor.constraint(equalTo: self.iconView.centerXAnchor),
            self.iconIdentifierLabel.centerYAnchor.constraint(equalTo: self.iconView.centerYAnchor),

            self.iconUserImageView.centerXAnchor.constraint(equalTo: self.iconView.centerXAnchor),
            self.iconUserImageView.centerYAnchor.constraint(equalTo: self.iconView.centerYAnchor),
            self.iconUserImageView.widthAnchor.constraint(equalToConstant: 26),
            self.iconUserImageView.heightAnchor.constraint(equalTo: self.iconUserImageView.widthAnchor),

            self.iconStateView.trailingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: -1.5),
            self.iconStateView.topAnchor.constraint(equalTo: self.iconBaseView.topAnchor, constant: 1.5),
            self.iconStateView.widthAnchor.constraint(equalToConstant: 8),
            self.iconStateView.heightAnchor.constraint(equalTo: self.iconStateView.widthAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 16),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: 10),
            self.titleLabel.topAnchor.constraint(equalTo: self.iconBaseView.topAnchor),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 16),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: 10),
            self.subtitleLabel.bottomAnchor.constraint(equalTo: self.iconBaseView.bottomAnchor),

            self.backButton.heightAnchor.constraint(equalTo: self.navigationView.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 0),

            self.navigationLineSeparatorView.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor),
            self.navigationLineSeparatorView.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor),
            self.navigationLineSeparatorView.bottomAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.navigationLineSeparatorView.heightAnchor.constraint(equalToConstant: 1)
        ])

        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor)
//            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.messageInputBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.messageInputBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.messageInputBaseView.topAnchor.constraint(equalTo: self.tableView.bottomAnchor),
//            self.messageInputBaseView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),
            self.messageInputBaseView.heightAnchor.constraint(equalToConstant: 70),

            self.messageInputLineSeparatorView.leadingAnchor.constraint(equalTo: self.messageInputBaseView.leadingAnchor),
            self.messageInputLineSeparatorView.trailingAnchor.constraint(equalTo: self.messageInputBaseView.trailingAnchor),
            self.messageInputLineSeparatorView.topAnchor.constraint(equalTo: self.messageInputBaseView.topAnchor),
            self.messageInputLineSeparatorView.heightAnchor.constraint(equalToConstant: 1),

            self.messageInputView.leadingAnchor.constraint(equalTo: self.messageInputBaseView.leadingAnchor, constant: 15),
//            self.messageInputView.trailingAnchor.constraint(equalTo: self.messageInputBaseView.trailingAnchor, constant: -70),
            self.messageInputView.centerYAnchor.constraint(equalTo: self.messageInputBaseView.centerYAnchor),

            self.sendButton.leadingAnchor.constraint(equalTo: self.messageInputView.trailingAnchor, constant: 16),
            self.sendButton.trailingAnchor.constraint(equalTo: self.messageInputBaseView.trailingAnchor, constant: -15),
            self.sendButton.centerYAnchor.constraint(equalTo: self.messageInputBaseView.centerYAnchor),
            self.sendButton.widthAnchor.constraint(equalToConstant: 46),
            self.sendButton.heightAnchor.constraint(equalTo: self.sendButton.widthAnchor)
        ])

        NSLayoutConstraint.activate([
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
        ])

        NSLayoutConstraint.activate([
            self.view.leadingAnchor.constraint(equalTo: self.loadingBaseView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.loadingBaseView.trailingAnchor),
            self.view.topAnchor.constraint(equalTo: self.loadingBaseView.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.loadingBaseView.bottomAnchor)
        ])

        self.messageInputBottomConstraint =
        NSLayoutConstraint(item: self.messageInputBaseView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.bottomSafeAreaView,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0)
        self.messageInputBottomConstraint.isActive = true

        self.messageInputKeyboardConstraint.isActive = false

    }
}
