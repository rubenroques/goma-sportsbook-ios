//
//  ConversationDetailViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 06/04/2022.
//

import UIKit

class ConversationDetailViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconView: UIView = Self.createIconView()
    private lazy var iconIdentifierLabel: UILabel = Self.createIconIdentifierLabel()
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

    private var viewModel: ConversationDetailViewModel

    // MARK: - Lifetime and Cycle
    init(viewModel: ConversationDetailViewModel = ConversationDetailViewModel()) {
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
        self.tableView.register(SentMessageTableViewCell.self,
                                forCellReuseIdentifier: SentMessageTableViewCell.identifier)
        tableView.register(DateHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: DateHeaderFooterView.identifier)

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.sendButton.addTarget(self, action: #selector(didTapSendButton), for: .primaryActionTriggered)

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(backgroundTapGesture)

        if self.viewModel.isChatOnline {
            self.iconStateView.isHidden = false
        }
        else {
            self.iconStateView.isHidden = true
        }

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2
        self.iconView.layer.cornerRadius = self.iconView.frame.height / 2
        self.iconStateView.layer.cornerRadius = self.iconStateView.frame.height / 2

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
    }

    // MARK: Functions
    func scrollToBottomTableView() {
        DispatchQueue.main.async {
            let section = self.viewModel.dateMessages.count - 1
            let row = self.viewModel.dateMessages[section].messages.count - 1

            let indexPath = IndexPath(row: row, section: section)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    // MARK: Actions
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func didTapSendButton() {
        // TEST SEND MESSAGE
        let dateNow = Date()
        let dateNowString = self.viewModel.getDefaultDateFormatted(date: dateNow)

        let message = self.messageInputView.getTextViewValue()

        if message != "" {

            let messageData = MessageData(messageType: .sentNotSeen, messageText: message, messageDate: dateNowString)

            self.viewModel.addMessage(message: messageData)
            self.messageInputView.clearTextView()
            self.tableView.reloadData()
            self.scrollToBottomTableView()
        }
        else {
            print("NO TEXT!")
        }
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.messageInputView.resignFirstResponder()
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y = 0
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y -= keyboardSize.height
            }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
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
        if let messageData = self.viewModel.dateMessages[safe: indexPath.section]?.messages[indexPath.row] {
            if messageData.messageType == .sentNotSeen || messageData.messageType == .sentSeen {
            guard
                let cell = tableView.dequeueCellType(SentMessageTableViewCell.self)
            else {
                fatalError()
            }

                cell.setupMessage(messageData: messageData)

            return cell
        }
        else {
            guard
                let cell = tableView.dequeueCellType(ReceivedMessageTableViewCell.self)
            else {
                fatalError()
            }

            cell.setupMessage(messageData: messageData)

            return cell
        }
        }
        else {
            fatalError()
        }
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
        label.font = AppFont.with(type: .regular, size: 12)
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

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)

        self.navigationView.addSubview(self.iconBaseView)

        self.iconBaseView.addSubview(self.iconView)
        self.iconBaseView.addSubview(self.iconStateView)

        self.iconView.addSubview(self.iconIdentifierLabel)

        self.navigationView.addSubview(self.titleLabel)
        self.navigationView.addSubview(self.subtitleLabel)
        self.navigationView.addSubview(self.navigationLineSeparatorView)

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.messageInputBaseView)

        self.messageInputBaseView.addSubview(self.messageInputLineSeparatorView)
        self.messageInputBaseView.addSubview(self.messageInputView)
        self.messageInputBaseView.addSubview(self.sendButton)

        self.view.addSubview(self.bottomSafeAreaView)

        self.initConstraints()

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
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
            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 10),

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
            self.messageInputBaseView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),
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

    }
}

class ConversationDetailViewModel {

    var messages: [MessageData] = []
    var sectionMessages: [String: [MessageData]] = [:]
    var dateMessages: [DateMessages] = []

    var isChatOnline: Bool = false

    init() {
        // TESTING CHAT MESSAGES
        let message1 = MessageData(messageType: .receivedOffline, messageText: "Yo, I have a proposal for you! 😎", messageDate: "06/04/2022 15:45")
        let message2 = MessageData(messageType: .sentSeen, messageText: "Oh what is it? And how are you?", messageDate: "06/04/2022 16:00")
        let message3 = MessageData(messageType: .receivedOnline, messageText: "All fine here! What about: Lorem ipsum dolor sit amet," +
                                   "consectetur adipiscing elit. Curabitur porttitor mi eget pharetra eleifend. Nam vel finibus nibh, nec ullamcorper elit.", messageDate: "07/04/2022 01:50")
        let message4 = MessageData(messageType: .sentSeen, messageText: "I'm up for it! 👀", messageDate: "07/04/2022 02:32")
        let message5 = MessageData(messageType: .receivedOnline, messageText: "Alright! Then I'll send you the details: " +
                                   "Curabitur porttitor mi eget pharetra eleifend. Nam vel finibus nibh, nec ullamcorper elit.", messageDate: "07/04/2022 17:35")
        let message6 = MessageData(messageType: .sentNotSeen, messageText: "This seems like a nice deal. looking forward to it! 🤪", messageDate: "08/04/2022 10:01")

        messages.append(message1)
        messages.append(message2)
        messages.append(message3)
        messages.append(message4)
        messages.append(message5)
        messages.append(message6)

        self.sortAllMessages()

        self.isChatOnline = true

    }

    func sortAllMessages() {

        sectionMessages = [:]
        dateMessages = []

        for message in messages {
            let messageDate = getDateFormatted(dateString: message.messageDate)

            if sectionMessages[messageDate] != nil {
                sectionMessages[messageDate]?.append(message)
            }
            else {
                sectionMessages[messageDate] = [message]
            }
        }

        for (key, messages) in sectionMessages {
                let dateMessage = DateMessages(date: key, messages: messages)
            self.dateMessages.append(dateMessage)
        }

        // Sort by date
        self.dateMessages.sort {
            $0.date < $1.date
        }
    }

    func addMessage(message: MessageData) {
        self.messages.append(message)

        self.sortAllMessages()
    }

    func getDateFormatted(dateString: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyyy HH:mm"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd-MM-yyyy"

        let date = dateString

        if let formattedDate = dateFormatterGet.date(from: date) {

            return dateFormatterPrint.string(from: formattedDate)
        }

        return ""
    }

    func getDefaultDateFormatted(date: Date) -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd-MM-yyyy HH:mm"

        return dateFormatterPrint.string(from: date)
    }
}

extension ConversationDetailViewModel {

    func numberOfSections() -> Int {
        if self.dateMessages.isEmpty {
            return 1
        }
        else {
            return self.dateMessages.count
        }
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        if let dateMessages = self.dateMessages[safe: section] {
            return dateMessages.messages.count
        }
        else {
            return 1
        }

    }

    func sectionTitle(forSectionIndex section: Int) -> String {
        if self.dateMessages.isEmpty {
            return ""
        }
        else {
            return self.dateMessages[section].date
        }
    }

}

struct MessageData {

    var messageType: MessageType
    var messageText: String
    var messageDate: String
}

enum MessageType {
    case receivedOffline
    case receivedOnline
    case sentNotSeen
    case sentSeen
}

struct DateMessages {
    var date: String
    var messages: [MessageData]
}
