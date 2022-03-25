//
//  ConversationsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/03/2022.
//

import UIKit

class ChatViewModel {

}

class ChatTableViewCell: UITableViewCell {

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var photoImageView: UIImageView = Self.createPhotoImageView()
    private lazy var nameLabel: UILabel = Self.createNameLabel()
    private lazy var messageLineStackView: UIStackView = Self.createMessageLineStackView()
    private lazy var feedbackImageView: UIImageView = Self.createFeedbackImageView()
    private lazy var messageLabel: UILabel = Self.createMessageLabel()
    private lazy var dateLabel: UILabel = Self.createDateLabel()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()

    private var viewModel: ChatViewModel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.setNeedsLayout()
        self.layoutIfNeeded()
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

        self.photoImageView.layer.cornerRadius = self.photoImageView.frame.size.width / 2
    }

    func setupWithTheme() {
        self.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        self.backgroundColor = UIColor.App.backgroundPrimary

        self.photoImageView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
        self.photoImageView.backgroundColor = UIColor.App.backgroundSecondary

        self.feedbackImageView.backgroundColor = UIColor.App.backgroundSecondary
        self.messageLineStackView.backgroundColor = UIColor.App.backgroundPrimary

        self.nameLabel.textColor = UIColor.App.textPrimary
        self.messageLabel.textColor = UIColor.App.textPrimary
        self.dateLabel.textColor = UIColor.App.textPrimary

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine
    }

    func configure(withViewModel viewModel: ChatViewModel) {
        self.viewModel = viewModel
    }

}

extension ChatTableViewCell {

    private static func createBaseView() -> UIView {
        let baseView = UIView()
        baseView.translatesAutoresizingMaskIntoConstraints = false
        return baseView
    }

    private static func createPhotoImageView() -> UIImageView {
        let photoImageView = UIImageView()
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.clipsToBounds = true
        photoImageView.layer.masksToBounds = true
        photoImageView.layer.borderWidth = 2.5
        photoImageView.layer.borderColor = UIColor.brown.cgColor
        return photoImageView
    }

    private static func createNameLabel() -> UILabel {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = AppFont.with(type: .bold, size: 14)
        nameLabel.text = "Suspendisse potenti. Cras a suscipit mi. Nam et mi ac ipsum luctus maximus."
        return nameLabel
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
        return dateLabel
    }

    private static func createSeparatorLineView() -> UIView {
        let headerSeparatorLine = UIView()
        headerSeparatorLine.translatesAutoresizingMaskIntoConstraints = false
        return headerSeparatorLine
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.baseView)

        self.dateLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.vertical)
        self.dateLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)

        self.baseView.addSubview(self.photoImageView)
        self.baseView.addSubview(self.nameLabel)

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

            self.photoImageView.heightAnchor.constraint(equalTo: self.photoImageView.widthAnchor),
            self.photoImageView.heightAnchor.constraint(equalToConstant: 40),

            self.photoImageView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 24),
            self.photoImageView.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),

            self.nameLabel.leadingAnchor.constraint(equalTo: self.photoImageView.trailingAnchor, constant: 12),
            self.nameLabel.topAnchor.constraint(equalTo: self.photoImageView.topAnchor),
            self.nameLabel.trailingAnchor.constraint(equalTo: self.dateLabel.leadingAnchor, constant: 4),

            self.dateLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -23),
            self.dateLabel.centerYAnchor.constraint(equalTo: self.nameLabel.centerYAnchor),

            self.feedbackImageView.heightAnchor.constraint(equalTo: self.feedbackImageView.widthAnchor),
            self.feedbackImageView.heightAnchor.constraint(equalToConstant: 17),

            self.messageLineStackView.leadingAnchor.constraint(equalTo: self.nameLabel.leadingAnchor),
            self.messageLineStackView.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 8),
            self.messageLineStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -23),

            self.baseView.bottomAnchor.constraint(equalTo: self.separatorLineView.bottomAnchor, constant: 0),
            self.baseView.leadingAnchor.constraint(equalTo: self.separatorLineView.leadingAnchor, constant: -23),
            self.baseView.trailingAnchor.constraint(equalTo: self.separatorLineView.trailingAnchor, constant: 23),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

}

class ConversationsViewModel {

}

extension ConversationsViewModel {

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        return 100
    }

}

class ConversationsViewController: UIViewController {

    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var tableViewHeader: UIView = Self.createTableViewHeader()
    private lazy var searchBar: UISearchBar = Self.createSearchBar()

    private lazy var newGroupButton: UIButton = Self.createNewGroupButton()
    private lazy var newMessageButton: UIButton = Self.createNewMessageButton()
    private lazy var headerSeparatorLineView: UIView = Self.createHeaderSeparatorLineView()

    private var viewModel: ConversationsViewModel

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

        self.tableView.register(ChatTableViewCell.self,
                                forCellReuseIdentifier: ChatTableViewCell.identifier)

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

    // MARK: - Bindings
    private func bind(toViewModel viewModel: ConversationsViewModel) {

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
            let cell = tableView.dequeueCellType(ChatTableViewCell.self)
        else {
            fatalError()
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

