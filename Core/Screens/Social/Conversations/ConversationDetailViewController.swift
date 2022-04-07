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
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconView: UIView = Self.createIconView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var tableView: UITableView = Self.createTableView()

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

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2
        self.iconView.layer.cornerRadius = self.iconView.frame.height / 2
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topSafeAreaView.backgroundColor = .clear

        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary

        self.iconBaseView.backgroundColor = UIColor.App.buttonBackgroundSecondary

        self.iconView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.tableView.backgroundColor = .clear
    }

    // MARK: Actions
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
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
        if let messageData = self.viewModel.messages[safe: indexPath.row] {
            if messageData.messageType == .sentNotSeen || messageData.messageType == .sentSeen{
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
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

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)

        self.navigationView.addSubview(self.iconBaseView)
        self.iconBaseView.addSubview(self.iconView)

        self.navigationView.addSubview(self.titleLabel)
        self.navigationView.addSubview(self.subtitleLabel)

        self.view.addSubview(self.tableView)

        self.initConstraints()

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    private func initConstraints() {

        // Top Safe Area View
        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
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
        ])

        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

    }
}

class ConversationDetailViewModel {

    var messages: [MessageData] = []

    init() {
        let message1 = MessageData(messageType: .receivedOffline, messageText: "Yo, I have a proposal for you! 😎", messageDate: "07/04/2022 15:45")
        let message2 = MessageData(messageType: .sentSeen, messageText: "Oh what is it? And how are you?", messageDate: "07/04/2022 16:00")
        let message3 = MessageData(messageType: .receivedOnline, messageText: "All fine here! What about: Lorem ipsum dolor sit amet," +
                                   "consectetur adipiscing elit. Curabitur porttitor mi eget pharetra eleifend. Nam vel finibus nibh, nec ullamcorper elit.", messageDate: "07/04/2022 16:50")
        let message4 = MessageData(messageType: .sentNotSeen, messageText: "I'm up for it! 👀", messageDate: "07/04/2022 17:32")

        messages.append(message1)
        messages.append(message2)
        messages.append(message3)
        messages.append(message4)

    }
}

extension ConversationDetailViewModel {

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        return messages.count
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
