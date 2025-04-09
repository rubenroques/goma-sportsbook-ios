//
//  ConversationDetailViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 06/04/2022.
//

import UIKit
import Combine

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
    private lazy var assistantLabel: UILabel = Self.createTitleLabel()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var navigationLineSeparatorView: UIView = Self.createNavigationLineSeparatorView()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var messageInputBaseView: UIView = Self.createMessageInputBaseView()
    private lazy var messageInputLineSeparatorView: UIView = Self.createMessageInputLineSeparatorView()
    private lazy var messageInputView: ChatMessageView = Self.createMessageInputView()
    private lazy var sendButton: UIButton = Self.createSendButton()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private lazy var listLoadingBaseView: UIView = Self.createListLoadingBaseView()
    private lazy var listLoadingActivityIndicatorView: UIActivityIndicatorView = Self.createListLoadingActivityIndicatorView()

    // Constraints
    private lazy var viewHeightConstraint: NSLayoutConstraint = Self.createViewHeightConstraint()
//    private lazy var avatarCenterConstraint: NSLayoutConstraint = Self.createAvatarCenterConstraint()

    private lazy var messageViewToTableConstraint: NSLayoutConstraint = Self.createMessageViewToTableConstraint()
    private lazy var messageViewToListLoadingConstraint: NSLayoutConstraint = Self.createMessageViewToListLoadingConstraint()

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
    var cameFromProfile: Bool = false
    
    var isChatAssistant: Bool = false {
        didSet {
            self.messageInputView.hasTicketButton = !isChatAssistant
            self.titleLabel.isHidden = isChatAssistant
            self.subtitleLabel.isHidden = isChatAssistant
            self.assistantLabel.isHidden = !isChatAssistant
        }
    }
    
    var isListLoading: Bool = false {
        didSet {
            if isListLoading {
                self.listLoadingActivityIndicatorView.startAnimating()
            }
            else {
                self.listLoadingActivityIndicatorView.stopAnimating()
            }
            self.listLoadingBaseView.isHidden = !isListLoading
            
            self.messageViewToTableConstraint.isActive = !isListLoading
            self.messageViewToListLoadingConstraint.isActive = isListLoading
        }
    }

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

        self.tableView.register(DateHeaderFooterView.self,
                                forHeaderFooterViewReuseIdentifier: DateHeaderFooterView.identifier)

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.sendButton.addTarget(self, action: #selector(didTapSendButton), for: .primaryActionTriggered)

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(backgroundTapGesture)

        if !self.isChatAssistant {
            let contactTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapContactInfo))
            self.navigationView.addGestureRecognizer(contactTapGesture)
        }

        self.bind(toViewModel: self.viewModel)

        self.setupPublishers()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        self.tableView.isDirectionalLockEnabled = true 
        self.tableView.alwaysBounceHorizontal = false
        self.tableView.alwaysBounceVertical = false

        // Delegate the interactivePopGesture for gesture verification
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // Constraint
//        self.avatarCenterConstraint.constant = self.isChatAssistant ? 0 : 3
        
        self.isListLoading = false
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Env.gomaSocialClient.showChatroomOnForeground(withId: String(self.viewModel.conversationId))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.presentationController?.presentedView?.gestureRecognizers?.first?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Env.gomaSocialClient.hideChatroomOnForeground()
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2

        self.iconView.layer.cornerRadius = self.iconView.frame.height / 2
        self.iconView.clipsToBounds = true

        self.iconStateView.layer.cornerRadius = self.iconStateView.frame.height / 2

        self.iconUserImageView.layer.cornerRadius = self.iconUserImageView.frame.height / 2

        self.sendButton.layer.cornerRadius = CornerRadius.checkBox
        self.sendButton.clipsToBounds = true
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

        self.iconBaseView.backgroundColor = UIColor.App.highlightTertiary

        self.iconView.backgroundColor = UIColor.App.backgroundSecondary

        self.iconIdentifierLabel.textColor = UIColor.App.highlightTertiary

        self.iconStateView.backgroundColor = UIColor.App.alertSuccess

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.assistantLabel.textColor = UIColor.App.textPrimary

        self.navigationLineSeparatorView.backgroundColor = UIColor.App.separatorLine

        self.tableView.backgroundColor = .clear

        self.messageInputBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.messageInputLineSeparatorView.backgroundColor = UIColor.App.separatorLine

        self.sendButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        self.sendButton.setBackgroundColor(UIColor.App.buttonDisablePrimary, for: .disabled)

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.8)
        
        self.listLoadingBaseView.backgroundColor = UIColor.App.backgroundSecondary

    }

    // MARK: Binding
    private func bind(toViewModel viewModel: ConversationDetailViewModel) {

        viewModel.titlePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] title in
                self?.titleLabel.text = title
                self?.assistantLabel.text = title
            })
            .store(in: &cancellables)

        viewModel.usersPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] users in
                self?.subtitleLabel.text = users
                
                if let isChatAssistant = self?.isChatAssistant,
                    isChatAssistant {
                    self?.iconUserImageView.image = UIImage(named: "ai_assistant_icon")
                }
                else if let avatar = viewModel.getConversationData()?.avatar {
                    self?.iconUserImageView.image = UIImage(named: avatar)
                }
            })
            .store(in: &cancellables)

        viewModel.isChatGroupPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isChatGroup in
                self?.isChatGroup = isChatGroup
            })
            .store(in: &cancellables)

        viewModel.groupInitialsPublisher
            .receive(on: DispatchQueue.main)
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
                self?.scrollToTopTableView()
            })
            .store(in: &cancellables)

        viewModel.isLoadingConversationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                }
                else {
                    self?.hideLoading()
                }
            }.store(in: &cancellables)

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

        viewModel.isChatOnlinePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isOnline in
                self?.iconStateView.isHidden = !isOnline
            })
            .store(in: &cancellables)
        
        if self.isChatAssistant {
            viewModel.isAIMessageLoading
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] isLoading in
                    self?.isListLoading = isLoading
                })
                .store(in: &cancellables)
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

    func scrollToTopTableView(animated: Bool = true) {
        if self.viewModel.dateMessages.isNotEmpty {

            let section = 0
            let row = 0

            if let dateMessages = self.viewModel.dateMessages[safe: section] {

                let indexPath = IndexPath(row: row, section: section)

                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)

            }

        }

    }

    private func showBetSelectionScreen() {

        if let conversationData = self.viewModel.getConversationData() {
            let conversationBetSelectionRootViewModel = ConversationBetSelectionRootViewModel(startTabIndex: 0, conversationData: conversationData)

            let conversationBetSelectionRootViewController = ConversationBetSelectionRootViewController(viewModel: conversationBetSelectionRootViewModel)

            self.present(conversationBetSelectionRootViewController, animated: true, completion: nil)
        }
    }

    private func addTicketToBetslip(ticket: BetHistoryEntry) {
        if let betShareToken = ticket.betShareToken {
            
            if let eventId = ticket.selections?.first?.eventId {
                let bettingTickets = ServiceProviderModelMapper.bettingTicket(fromBetHistoryEntry: ticket)
                
                self.viewModel.addBettingTicketsToBetslip(bettingTickets: bettingTickets)
                
                self.openBetslip()
            }
            else {
                self.viewModel.addBetTicketToBetslip(withBetToken: betShareToken)
            }
            

        }
    }
    
    private func openBetslip() {
        let betslipViewModel = BetslipViewModel()
        
        let betslipViewController = BetslipViewController(viewModel: betslipViewModel)
        
        self.present(Router.navigationController(with: betslipViewController), animated: true, completion: nil)
    }

    private func sendPromptMessage(message: String) {
        let dateNow = Date()
        let dateNowString = self.viewModel.getDefaultDateFormatted(date: dateNow)
        let dateNowTimestamp = Int(Date().timeIntervalSince1970)
        
        let messageData = MessageData(type: .sentNotSeen, text: message, date: dateNowString, timestamp: dateNowTimestamp)
        
        self.viewModel.addMessage(message: messageData, toAI: true)
        
    }
    
    // MARK: Actions
    @objc func didTapBackButton() {

        if !self.cameFromProfile {
            Env.gomaSocialClient.reloadChatroomsList.send()

            self.navigationController?.popToRootViewController(animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }

    }

    @objc func didTapSendButton() {

        let dateNow = Date()
        let dateNowString = self.viewModel.getDefaultDateFormatted(date: dateNow)
        let dateNowTimestamp = Int(Date().timeIntervalSince1970)

        let message = self.messageInputView.getTextViewValue()

        if message != "" {

            let messageData = MessageData(type: .sentNotSeen, text: message, date: dateNowString, timestamp: dateNowTimestamp)
            if self.isChatAssistant {
                self.viewModel.addMessage(message: messageData, toAI: true)
            }
            else {
                self.viewModel.addMessage(message: messageData)
            }
            self.messageInputView.clearTextView()
        }

    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.messageInputView.resignFirstResponder()
    }

    @objc func didTapContactInfo() {
        
        guard
            let conversationData = self.viewModel.getConversationData()
        else {
            return
        }
        
        if self.isChatGroup {
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

            if let userBasicInfo = self.viewModel.userBasicInfo {

                let userProfileViewModel = UserProfileViewModel(userBasicInfo: userBasicInfo)

                let userProfileViewController = UserProfileViewController(viewModel: userProfileViewModel)

                userProfileViewController.isChatProfile = true

                userProfileViewController.shouldCloseChat = { [weak self] in
                    self?.shouldCloseChat?()
                }

                self.navigationController?.pushViewController(userProfileViewController, animated: true)
            }

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
        let betslipViewModel = BetslipViewModel()
        
        let betslipViewController = BetslipViewController(viewModel: betslipViewModel)
        
        self.present(Router.navigationController(with: betslipViewController), animated: true, completion: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
//        self.scrollToTopTableView()

    }

    @objc func keyboardWillHide(notification: NSNotification) {
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

                    cell.isReversedCell(isReversed: true)

                    return cell
                }
                else {
                    guard
                        let cell = tableView.dequeueCellType(SentMessageTableViewCell.self)
                    else {
                        fatalError()
                    }

                    cell.setupMessage(messageData: messageData)

                    cell.isReversedCell(isReversed: true)

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
                        cell.setupMessage(messageData: messageData, username: username, avatarName: self.viewModel.getAvatarForUserId(userId: userId), chatroomId: self.viewModel.conversationId)
                        cell.didTapBetNowAction = { [weak self] viewModel in
                            self?.addTicketToBetslip(ticket: viewModel.ticket)
                        }
                    }

                    cell.isReversedCell(isReversed: true)

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
                        
                        let isAssistantMessage = self.isChatAssistant
                        
                        cell.setupMessage(messageData: messageData,
                                          username: username,
                                          avatarName: self.viewModel.getAvatarForUserId(userId: userId) ,
                                          chatroomId: self.viewModel.conversationId,
                                          isAssistantMessage: isAssistantMessage)
                        
                        cell.shouldSendPromptMessage = { [weak self] text in
                            self?.sendPromptMessage(message: text)
                        }
                    }

                    cell.isReversedCell(isReversed: true)

                    return cell
                }
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard
//            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: DateHeaderFooterView.identifier) as? DateHeaderFooterView
//        else {
//            fatalError()
//        }
//
//        let headerDate = self.viewModel.sectionTitle(forSectionIndex: section)
//        headerView.configureHeader(title: headerDate)
//
//        return headerView
        return UIView()
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard
            let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: DateHeaderFooterView.identifier) as? DateHeaderFooterView
        else {
            fatalError()
        }

        let footerDate = self.viewModel.sectionTitle(forSectionIndex: section)

        footerView.configureHeader(title: footerDate)

        footerView.isReversedContent(isReversed: true)

        return footerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // return 20
        return 0.1
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        // return 20
        return 0.1
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 20
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isModalInPresentation = true

    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isModalInPresentation = false

    }

}

extension ConversationDetailViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer && otherGestureRecognizer == self.tableView.panGestureRecognizer {
            return false
        }
       return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer && otherGestureRecognizer == self.tableView.panGestureRecognizer {
            return true
        }
        return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer && otherGestureRecognizer == self.tableView.panGestureRecognizer {
            return true
        }
        return false
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
    
    private static func createAssistantLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = "Assistant"
        label.isHidden = true
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
    
    private static func createListLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createListLoadingActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.stopAnimating()
        return activityIndicatorView
    }


    // Constraints
    private static func createViewHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private static func createAvatarCenterConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private static func createMessageViewToTableConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private static func createMessageViewToListLoadingConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
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
        self.navigationView.addSubview(self.assistantLabel)
        self.navigationView.addSubview(self.navigationLineSeparatorView)

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.messageInputBaseView)

        self.messageInputBaseView.addSubview(self.messageInputLineSeparatorView)
        self.messageInputBaseView.addSubview(self.messageInputView)
        self.messageInputBaseView.addSubview(self.sendButton)

        self.view.addSubview(self.bottomSafeAreaView)

        self.view.addSubview(self.loadingBaseView)
        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)
        
        self.view.addSubview(self.listLoadingBaseView)
        self.listLoadingBaseView.addSubview(self.listLoadingActivityIndicatorView)

        self.initConstraints()

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

        self.messageInputView.shouldShowBetSelection = { [weak self] in
            self?.showBetSelectionScreen()
        }

        self.messageInputView.shouldResizeView = { [weak self] newHeight in
            self?.viewHeightConstraint.constant = newHeight
//            self?.view.layoutIfNeeded()
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
            
            self.iconView.leadingAnchor.constraint(equalTo: self.iconBaseView.leadingAnchor, constant: 2),
            self.iconView.trailingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: -2),
            self.iconView.topAnchor.constraint(equalTo: self.iconBaseView.topAnchor, constant: 2),
            self.iconView.bottomAnchor.constraint(equalTo: self.iconBaseView.bottomAnchor, constant: -2),

            self.iconIdentifierLabel.centerXAnchor.constraint(equalTo: self.iconView.centerXAnchor),
            self.iconIdentifierLabel.centerYAnchor.constraint(equalTo: self.iconView.centerYAnchor),

            self.iconUserImageView.centerXAnchor.constraint(equalTo: self.iconView.centerXAnchor),
            self.iconUserImageView.centerYAnchor.constraint(equalTo: self.iconView.centerYAnchor),
            self.iconUserImageView.widthAnchor.constraint(equalToConstant: 27),
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
            
            self.assistantLabel.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 16),
            self.assistantLabel.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -10),
            self.assistantLabel.centerYAnchor.constraint(equalTo: self.iconBaseView.centerYAnchor),

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
//            self.messageInputBaseView.topAnchor.constraint(equalTo: self.tableView.bottomAnchor),
            self.messageInputBaseView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),

            self.messageInputLineSeparatorView.leadingAnchor.constraint(equalTo: self.messageInputBaseView.leadingAnchor),
            self.messageInputLineSeparatorView.trailingAnchor.constraint(equalTo: self.messageInputBaseView.trailingAnchor),
            self.messageInputLineSeparatorView.topAnchor.constraint(equalTo: self.messageInputBaseView.topAnchor),
            self.messageInputLineSeparatorView.heightAnchor.constraint(equalToConstant: 1),

            self.messageInputView.leadingAnchor.constraint(equalTo: self.messageInputBaseView.leadingAnchor, constant: 15),
            self.messageInputView.topAnchor.constraint(equalTo: self.messageInputLineSeparatorView.bottomAnchor, constant: 10),
            self.messageInputView.bottomAnchor.constraint(equalTo: self.messageInputBaseView.bottomAnchor, constant: -10),

            self.sendButton.leadingAnchor.constraint(equalTo: self.messageInputView.trailingAnchor, constant: 16),
            self.sendButton.trailingAnchor.constraint(equalTo: self.messageInputBaseView.trailingAnchor, constant: -15),
            self.sendButton.bottomAnchor.constraint(equalTo: self.messageInputBaseView.bottomAnchor, constant: -12),
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
        
        // List load
        NSLayoutConstraint.activate([
            self.listLoadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.listLoadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.listLoadingBaseView.topAnchor.constraint(equalTo: self.tableView.bottomAnchor),
            self.listLoadingBaseView.heightAnchor.constraint(equalToConstant: 60),
            
            self.listLoadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.listLoadingBaseView.centerYAnchor),
            self.listLoadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.listLoadingBaseView.centerXAnchor)
        ])
        
        self.viewHeightConstraint = self.messageInputBaseView.heightAnchor.constraint(equalToConstant: 70)
        self.viewHeightConstraint.isActive = true

//        self.avatarCenterConstraint = self.iconUserImageView.centerYAnchor.constraint(equalTo: self.iconView.centerYAnchor, constant: 3)
//        self.avatarCenterConstraint.isActive = true

        self.messageViewToTableConstraint = self.messageInputBaseView.topAnchor.constraint(equalTo: self.tableView.bottomAnchor)
        self.messageViewToTableConstraint.isActive = true
        
        self.messageViewToListLoadingConstraint = self.messageInputBaseView.topAnchor.constraint(equalTo: self.listLoadingBaseView.bottomAnchor)
        self.messageViewToListLoadingConstraint.isActive = false

    }
}

extension ConversationDetailViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {

        return false
    }
}
