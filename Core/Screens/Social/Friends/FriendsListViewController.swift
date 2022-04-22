//
//  FriendsListViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/03/2022.
//

import UIKit

class FriendStatusViewModel {

}

class FriendStatusTableViewCell: UITableViewCell {

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var photoImageView: UIImageView = Self.createPhotoImageView()
    private lazy var nameLabel: UILabel = Self.createNameLabel()
    private lazy var statusView: UIView = Self.createStatusView()
    private lazy var notificationEnabledButton: UIButton = Self.createNotificationEnabledButton()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()

    private var viewModel: FriendStatusViewModel?

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
        self.statusView.layer.cornerRadius = self.statusView.frame.size.width / 2
    }

    func setupWithTheme() {
        self.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        self.backgroundColor = UIColor.App.backgroundPrimary

        self.photoImageView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
        self.photoImageView.backgroundColor = UIColor.App.backgroundSecondary

        self.nameLabel.textColor = UIColor.App.textPrimary
        self.statusView.backgroundColor = .systemGreen

        if let image = self.notificationEnabledButton.imageView?.image?.withRenderingMode(.alwaysTemplate) {
            self.notificationEnabledButton.setImage(image, for: .normal)
            self.notificationEnabledButton.tintColor = UIColor.App.highlightSecondary
        }

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine
    }

    func configure(withViewModel viewModel: FriendStatusViewModel) {
        self.viewModel = viewModel
    }

}

extension FriendStatusTableViewCell {

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
        nameLabel.text = "@NameSurname"
        return nameLabel
    }

    private static func createStatusView() -> UIView {
        let statusView = UIView()
        statusView.translatesAutoresizingMaskIntoConstraints = false
        return statusView
    }

    private static func createMessageLineStackView() -> UIStackView {
        let messageLineStackView = UIStackView()
        messageLineStackView.axis = .horizontal
        messageLineStackView.distribution = .fill
        messageLineStackView.spacing = 6
        messageLineStackView.translatesAutoresizingMaskIntoConstraints = false
        return messageLineStackView
    }

    private static func createNotificationEnabledButton() -> UIButton {
        let notificationEnabledButton = UIButton(type: .custom)
        notificationEnabledButton.setImage(UIImage(named: "notifications_status_icon"), for: .normal)
        notificationEnabledButton.translatesAutoresizingMaskIntoConstraints = false
        return notificationEnabledButton
    }

    private static func createSeparatorLineView() -> UIView {
        let headerSeparatorLine = UIView()
        headerSeparatorLine.translatesAutoresizingMaskIntoConstraints = false
        return headerSeparatorLine
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.baseView)

        self.baseView.addSubview(self.photoImageView)
        self.baseView.addSubview(self.nameLabel)
        self.baseView.addSubview(self.statusView)
        self.baseView.addSubview(self.notificationEnabledButton)

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
            self.nameLabel.centerYAnchor.constraint(equalTo: self.photoImageView.centerYAnchor),

            self.statusView.heightAnchor.constraint(equalTo: self.statusView.widthAnchor),
            self.statusView.heightAnchor.constraint(equalToConstant: 8),
            self.statusView.centerYAnchor.constraint(equalTo: self.nameLabel.centerYAnchor),
            self.statusView.leadingAnchor.constraint(equalTo: self.nameLabel.trailingAnchor, constant: 8),

            self.notificationEnabledButton.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -23),
            self.notificationEnabledButton.centerYAnchor.constraint(equalTo: self.nameLabel.centerYAnchor),
            self.notificationEnabledButton.heightAnchor.constraint(equalTo: self.notificationEnabledButton.widthAnchor),
            self.notificationEnabledButton.heightAnchor.constraint(equalToConstant: 44),

            self.baseView.bottomAnchor.constraint(equalTo: self.separatorLineView.bottomAnchor, constant: 0),
            self.baseView.leadingAnchor.constraint(equalTo: self.separatorLineView.leadingAnchor, constant: -23),
            self.baseView.trailingAnchor.constraint(equalTo: self.separatorLineView.trailingAnchor, constant: 23),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

}


class FriendsListViewModel {

}

extension FriendsListViewModel {

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        return 100
    }

}

class FriendsListViewController: UIViewController {

    private lazy var tableView: UITableView = Self.createTableView()

    private var viewModel: FriendsListViewModel

    // MARK: - Lifetime and Cycle
    init(viewModel: FriendsListViewModel = FriendsListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Friends"

        self.setupSubviews()
        self.setupWithTheme()

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(FriendStatusTableViewCell.self,
                                forCellReuseIdentifier: FriendStatusTableViewCell.identifier)

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
        self.tableView.backgroundColor = UIColor.App.backgroundPrimary
    }

}

//
// MARK: - TableView Protocols
//
extension FriendsListViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows(forSectionIndex: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueCellType(FriendStatusTableViewCell.self)
        else {
            fatalError()
        }
        return cell
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension FriendsListViewController {

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }

    private func setupSubviews() {

        self.view.addSubview(self.tableView)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
    }

}
