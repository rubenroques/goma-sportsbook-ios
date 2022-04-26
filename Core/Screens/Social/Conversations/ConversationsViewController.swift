//
//  ConversationsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/03/2022.
//

import UIKit
import Combine

class PreviewChatCellViewModel {
    var cellData: ConversationData

    init(cellData: ConversationData) {
        self.cellData = cellData
    }
}

class PreviewChatTableViewCell: UITableViewCell {

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconInnerView: UIView = Self.createIconInnerView()
    private lazy var photoImageView: UIImageView = Self.createPhotoImageView()
    private lazy var initialLabel: UILabel = Self.createInitialLabel()
    private lazy var nameLineStackView: UIStackView = Self.createNameLineStackView()
    private lazy var nameLabel: UILabel = Self.createNameLabel()
    private lazy var numberMessagesLabel: UILabel = Self.createNumberMessagesLabel()
    private lazy var messageLineStackView: UIStackView = Self.createMessageLineStackView()
    private lazy var feedbackImageView: UIImageView = Self.createFeedbackImageView()
    private lazy var messageLabel: UILabel = Self.createMessageLabel()
    private lazy var dateLabel: UILabel = Self.createDateLabel()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()

    private var viewModel: PreviewChatCellViewModel?

    var didTapConversationAction: (() -> Void)?

    var isSeen: Bool = false {
        didSet {
            if isSeen {
                self.dateLabel.textColor = UIColor.App.textSecondary
            }
            else {
                self.dateLabel.textColor = UIColor.App.highlightPrimary
            }
            self.feedbackImageView.isHidden = !isSeen
            self.numberMessagesLabel.isHidden = isSeen
        }
    }

    var isOnline: Bool = false {
        didSet {
            if isOnline {
                self.iconBaseView.backgroundColor = UIColor.App.highlightPrimary
            }
            else {
                self.iconBaseView.backgroundColor = UIColor.App.backgroundSecondary
            }
        }
    }

    var isGroup: Bool = false {
        didSet {
            if isGroup {
                self.photoImageView.isHidden = true
                self.initialLabel.isHidden = false
            }
            else {
                self.photoImageView.isHidden = false
                self.initialLabel.isHidden = true
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.setNeedsLayout()
        self.layoutIfNeeded()

        let tapConversationGesture = UITapGestureRecognizer(target: self, action: #selector(didTapConversationView))
        self.addGestureRecognizer(tapConversationGesture)

        self.isSeen = false

        self.isGroup = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.viewModel = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.size.width / 2

        self.iconInnerView.layer.cornerRadius = self.iconInnerView.frame.size.width / 2

        self.photoImageView.layer.cornerRadius = self.photoImageView.frame.size.width / 2
    }

    func setupWithTheme() {
        self.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        self.backgroundColor = UIColor.App.backgroundPrimary

        self.iconBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.iconInnerView.backgroundColor = UIColor.App.backgroundSecondary

        self.photoImageView.backgroundColor = UIColor.App.backgroundSecondary

        self.initialLabel.textColor = UIColor.App.textSecondary

        self.feedbackImageView.backgroundColor = UIColor.App.backgroundPrimary
        self.messageLineStackView.backgroundColor = UIColor.App.backgroundPrimary
        self.nameLineStackView.backgroundColor = UIColor.App.backgroundPrimary

        self.nameLabel.textColor = UIColor.App.textPrimary
        self.numberMessagesLabel.textColor = UIColor.App.highlightPrimary
        self.messageLabel.textColor = UIColor.App.textPrimary
        self.dateLabel.textColor = UIColor.App.textSecondary

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine
    }

    func configure(withViewModel viewModel: PreviewChatCellViewModel) {
        self.viewModel = viewModel

        // TEST
        self.nameLabel.text = viewModel.cellData.name

        self.messageLabel.text = viewModel.cellData.lastMessage

        if viewModel.cellData.conversationType == .user {
            self.isGroup = false
        }
        else if viewModel.cellData.conversationType == .group {
            self.isGroup = true
        }

        self.dateLabel.text = viewModel.cellData.date

        self.isSeen = viewModel.cellData.isLastMessageSeen

        self.isOnline = !viewModel.cellData.isLastMessageSeen

    }

    @objc func didTapConversationView() {
        self.didTapConversationAction?()
    }

}

extension PreviewChatTableViewCell {

    private static func createBaseView() -> UIView {
        let baseView = UIView()
        baseView.translatesAutoresizingMaskIntoConstraints = false
        return baseView
    }

    private static func createIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconInnerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createPhotoImageView() -> UIImageView {
        let photoImageView = UIImageView()
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.image = UIImage(named: "my_account_profile_icon")
        photoImageView.contentMode = .scaleAspectFit
        return photoImageView
    }

    private static func createInitialLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "G"
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .center
        return label
    }

    private static func createNameLineStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 6
        return stackView
    }

    private static func createNameLabel() -> UILabel {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = AppFont.with(type: .bold, size: 14)
        nameLabel.text = "Suspendisse potenti. Cras a suscipit mi. Nam et mi ac ipsum luctus maximus."
        nameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return nameLabel
    }

    private static func createNumberMessagesLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.text = "(1)"
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }

    private static func createMessageLineStackView() -> UIStackView {
        let messageLineStackView = UIStackView()
        messageLineStackView.axis = .horizontal
        messageLineStackView.distribution = .fill
        messageLineStackView.spacing = 6
        messageLineStackView.translatesAutoresizingMaskIntoConstraints = false
        return messageLineStackView
    }

    private static func createFeedbackImageView() -> UIImageView {
        let feedbackImageView = UIImageView()
        feedbackImageView.translatesAutoresizingMaskIntoConstraints = false
        feedbackImageView.image = UIImage(named: "seen_message_icon")
        feedbackImageView.contentMode = .scaleAspectFit
        return feedbackImageView
    }

    private static func createMessageLabel() -> UILabel {
        let messageLabel = UILabel()
        messageLabel.font = AppFont.with(type: .medium, size: 12)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = "Suspendisse potenti. Cras a suscipit mi. Nam et mi ac ipsum luctus maximus."
        return messageLabel
    }
    private static func createDateLabel() -> UILabel {
        let dateLabel = UILabel()
        dateLabel.font = AppFont.with(type: .medium, size: 12)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.text = "Yesterday"
        dateLabel.textAlignment = .right
        return dateLabel
    }

    private static func createSeparatorLineView() -> UIView {
        let headerSeparatorLine = UIView()
        headerSeparatorLine.translatesAutoresizingMaskIntoConstraints = false
        return headerSeparatorLine
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.baseView)

        self.baseView.addSubview(self.iconBaseView)

        self.iconBaseView.addSubview(self.iconInnerView)

        self.iconInnerView.addSubview(self.photoImageView)
        self.iconInnerView.addSubview(self.initialLabel)

        self.baseView.addSubview(self.nameLineStackView)

        self.nameLineStackView.addArrangedSubview(self.nameLabel)
        self.nameLineStackView.addArrangedSubview(self.numberMessagesLabel)

        self.messageLineStackView.addArrangedSubview(self.feedbackImageView)
        self.messageLineStackView.addArrangedSubview(self.messageLabel)
        self.baseView.addSubview(self.messageLineStackView)

        self.baseView.addSubview(self.dateLabel)
        self.baseView.addSubview(self.separatorLineView)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.baseView.heightAnchor.constraint(equalToConstant: 66),

            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

            self.iconBaseView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 24),
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 40),
            self.iconBaseView.heightAnchor.constraint(equalTo: self.iconBaseView.widthAnchor),
            self.iconBaseView.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),

            self.iconInnerView.widthAnchor.constraint(equalToConstant: 37),
            self.iconInnerView.heightAnchor.constraint(equalTo: self.iconInnerView.widthAnchor),
            self.iconInnerView.centerXAnchor.constraint(equalTo: self.iconBaseView.centerXAnchor),
            self.iconInnerView.centerYAnchor.constraint(equalTo: self.iconBaseView.centerYAnchor),

            self.photoImageView.widthAnchor.constraint(equalToConstant: 25),
            self.photoImageView.heightAnchor.constraint(equalTo: self.photoImageView.widthAnchor),
            self.photoImageView.centerXAnchor.constraint(equalTo: self.iconInnerView.centerXAnchor),
            self.photoImageView.centerYAnchor.constraint(equalTo: self.iconInnerView.centerYAnchor),

            self.initialLabel.centerXAnchor.constraint(equalTo: self.iconInnerView.centerXAnchor),
            self.initialLabel.centerYAnchor.constraint(equalTo: self.iconInnerView.centerYAnchor),

            self.nameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),

            self.nameLineStackView.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 12),
            self.nameLineStackView.topAnchor.constraint(equalTo: self.iconBaseView.topAnchor),

            self.dateLabel.leadingAnchor.constraint(equalTo: self.nameLineStackView.trailingAnchor, constant: 8),
            self.dateLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -24),
            self.dateLabel.centerYAnchor.constraint(equalTo: self.nameLineStackView.centerYAnchor),

            self.feedbackImageView.widthAnchor.constraint(equalToConstant: 20),
            self.feedbackImageView.heightAnchor.constraint(equalTo: self.feedbackImageView.widthAnchor),

            self.messageLineStackView.leadingAnchor.constraint(equalTo: self.nameLineStackView.leadingAnchor),
            self.messageLineStackView.topAnchor.constraint(equalTo: self.nameLineStackView.bottomAnchor, constant: 8),
            self.messageLineStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -23),

            self.baseView.bottomAnchor.constraint(equalTo: self.separatorLineView.bottomAnchor, constant: 0),
            self.baseView.leadingAnchor.constraint(equalTo: self.separatorLineView.leadingAnchor, constant: -23),
            self.baseView.trailingAnchor.constraint(equalTo: self.separatorLineView.trailingAnchor, constant: 23),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

}

struct ConversationData {
    var conversationType: ConversationType
    var name: String
    var lastMessage: String
    var date: String
    var lastMessageUser: String?
    var isLastMessageSeen: Bool
}

enum ConversationType {
    case user
    case group
}

class ConversationsViewController: UIViewController {

    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var tableViewHeader: UIView = Self.createTableViewHeader()
    private lazy var searchBar: UISearchBar = Self.createSearchBar()

    private lazy var newGroupButton: UIButton = Self.createNewGroupButton()
    private lazy var newMessageButton: UIButton = Self.createNewMessageButton()
    private lazy var headerSeparatorLineView: UIView = Self.createHeaderSeparatorLineView()

    private var viewModel: ConversationsViewModel
    private var cancellables = Set<AnyCancellable>()

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
                                                                                UIColor.App.inputTextTitle])

            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = UIColor.App.inputTextTitle
            }
        }

    }

    // MARK: Functions

    private func showConversationDetail() {
        let conversationDetailViewController = ConversationDetailViewController()

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
        print("NEW GROUP")
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

        //TEST STATES
        if indexPath.row <= 2 {
            cell.isSeen = false
            cell.isOnline = true
        }
        if let cellData = self.viewModel.conversations[safe: indexPath.row] {
            let cellViewModel = PreviewChatCellViewModel(cellData: cellData)
            cell.configure(withViewModel: cellViewModel)
        }

        cell.didTapConversationAction = { [weak self] in
            self?.showConversationDetail()
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

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
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
        newGroupButton.setTitle("New Group", for: .normal)
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

    private func setupSubviews() {

        self.tableViewHeader.addSubview(self.searchBar)
        self.tableViewHeader.addSubview(self.newGroupButton)
        self.tableViewHeader.addSubview(self.newMessageButton)
        self.tableViewHeader.addSubview(self.headerSeparatorLineView)

        self.view.addSubview(self.tableView)

        self.tableView.tableHeaderView = self.tableViewHeader

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

        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])

    }
}
