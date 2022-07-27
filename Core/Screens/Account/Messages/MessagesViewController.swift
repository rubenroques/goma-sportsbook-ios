//
//  MessagesViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 25/07/2022.
//

import UIKit
import Combine

class MessagesViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var markAllReadButton: UIButton = Self.createMarkAllReadButton()
    private lazy var deleteAllButton: UIButton = Self.createDeleteAllButton()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var emptyStateView: UIView = Self.createEmptyStateView()
    private lazy var emptyStateImageView: UIImageView = Self.createEmptyStateImageView()
    private lazy var emptyStateLabel: UILabel = Self.createEmptyStateLabel()

    private var viewModel: MessagesViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var isEmptyState: Bool = false {
        didSet {
            self.emptyStateView.isHidden = !isEmptyState
        }
    }

    // MARK: Lifetime and Cycle
    init(viewModel: MessagesViewModel) {
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

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.markAllReadButton.addTarget(self, action: #selector(didTapMarkAllReadButton), for: .primaryActionTriggered)

        self.deleteAllButton.addTarget(self, action: #selector(didTapDeleteAllButton), for: .primaryActionTriggered)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(InAppMessageTableViewCell.self,
                                forCellReuseIdentifier: InAppMessageTableViewCell.identifier)

        self.bind(toViewModel: self.viewModel)

        self.isEmptyState = false

        // TEMP
        self.deleteAllButton.isHidden = true
    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = UIColor.App.backgroundPrimary

        self.backButton.tintColor = UIColor.App.textPrimary

        self.topTitleLabel.textColor = UIColor.App.textPrimary

        self.markAllReadButton.backgroundColor = .clear
        self.markAllReadButton.setTitleColor(UIColor.App.highlightSecondary, for: .normal)

        self.deleteAllButton.backgroundColor = .clear
        self.deleteAllButton.setTitleColor(UIColor.App.highlightSecondary, for: .normal)

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary

        self.emptyStateView.backgroundColor = UIColor.App.backgroundPrimary

        self.emptyStateImageView.backgroundColor = .clear

        self.emptyStateLabel.textColor = UIColor.App.textPrimary
    }

    // MARK: Functions
    private func openMessageDetail(cellViewModel: InAppMessageCellViewModel) {

        let messageDetailViewController = MessageDetailViewController()

        self.navigationController?.pushViewController(messageDetailViewController, animated: true)
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: MessagesViewModel) {

        viewModel.dataNeedsReload
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        viewModel.inAppMessagesPublisher
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] inAppMessages in
                self?.isEmptyState = inAppMessages.isEmpty
            })
            .store(in: &cancellables)
    }

    // MARK: Actions
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapMarkAllReadButton() {
        print("MARK ALL READ")
        self.viewModel.markAllReadMessages()
    }

    @objc private func didTapDeleteAllButton() {
        print("DELETE ALL")
        self.viewModel.deleteAllMessages()
    }

    private func handleMarkReadAction(indexPath: IndexPath) {
        print("Marked as read message!")
        if let inAppMessage = self.viewModel.inAppMessagesPublisher.value[safe: indexPath.row] {
            self.viewModel.markReadMessage(index: indexPath.row)
        }

    }

    private func handleDeleteAction(indexPath: IndexPath) {
        print("Delete message!")
        self.viewModel.deleteMessage(index: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .left)
    }
}

extension MessagesViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.inAppMessagesPublisher.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueCellType(InAppMessageTableViewCell.self)
        else {
            fatalError()
        }
        
        if let inAppMessage = self.viewModel.inAppMessagesPublisher.value[safe: indexPath.row] {

            if let cellViewModel = self.viewModel.cachedInAppMessagesViewModels[inAppMessage.id] {

                cell.configure(viewModel: cellViewModel)

                cell.tappedContainer = { [weak self] in
                    self?.openMessageDetail(cellViewModel: cellViewModel)
                }
            }
            else {
                let cellViewModel = InAppMessageCellViewModel(inAppMessage: inAppMessage)
                self.viewModel.cachedInAppMessagesViewModels[inAppMessage.id] = cellViewModel

                cell.configure(viewModel: cellViewModel)

                cell.tappedContainer = { [weak self] in
                    self?.openMessageDetail(cellViewModel: cellViewModel)
                }
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return UITableView.automaticDimension

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return 88

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

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let markReadAction = UIContextualAction(style: .normal,
                                        title: "Mark as read") { [weak self] (action, view, completionHandler) in
            self?.handleMarkReadAction(indexPath: indexPath)
                                            completionHandler(true)
        }

        markReadAction.image = UIImage(named: "mark_read_grey_icon")
        markReadAction.backgroundColor = UIColor.App.backgroundSecondary

        // TEMP REMOVE
//        let deleteAction = UIContextualAction(style: .normal,
//                                        title: "Delete") { [weak self] (action, view, completionHandler) in
//            self?.handleDeleteAction(indexPath: indexPath)
//                                            completionHandler(true)
//        }
//
//        deleteAction.image = UIImage(named: "delete_grey_icon")
//        deleteAction.backgroundColor = UIColor.App.backgroundSecondary

        let configuration = UISwipeActionsConfiguration(actions: [markReadAction])

        configuration.performsFirstActionWithFullSwipe = false

        return configuration
    }

    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

}

//
// MARK: Subviews initialization and setup
//
extension MessagesViewController {

    private static func createTopView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        return button
    }

    private static func createTopTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("messages")
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .center
        return label
    }

    private static func createMarkAllReadButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("mark_all_read"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 12)
        return button
    }

    private static func createDeleteAllButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("delete_all"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 12)
        return button
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
        imageView.image = UIImage(named: "no_messages_star_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("no_messages_yet")
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        return label
    }

    private func setupSubviews() {
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)
        self.topView.bringSubviewToFront(self.topTitleLabel)

        self.view.addSubview(self.markAllReadButton)
        self.view.addSubview(self.deleteAllButton)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.emptyStateView)

        self.emptyStateView.addSubview(self.emptyStateImageView)
        self.emptyStateView.addSubview(self.emptyStateLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 0),
            self.backButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.topTitleLabel.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 20),
            self.topTitleLabel.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -20),
            self.topTitleLabel.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor)
        ])

        // Action Buttons
        NSLayoutConstraint.activate([
            self.markAllReadButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
            self.markAllReadButton.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 10),
            self.markAllReadButton.heightAnchor.constraint(equalToConstant: 40),

            self.deleteAllButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            self.deleteAllButton.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 10),
            self.deleteAllButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Tableview
        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            self.tableView.topAnchor.constraint(equalTo: self.markAllReadButton.bottomAnchor, constant: 10),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // Empty State
        NSLayoutConstraint.activate([
            self.emptyStateView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.emptyStateView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.emptyStateView.topAnchor.constraint(equalTo: self.topView.bottomAnchor),
            self.emptyStateView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.emptyStateImageView.topAnchor.constraint(equalTo: self.emptyStateView.topAnchor, constant: 40),
            self.emptyStateImageView.widthAnchor.constraint(equalToConstant: 120),
            self.emptyStateImageView.heightAnchor.constraint(equalToConstant: 90),
            self.emptyStateImageView.centerXAnchor.constraint(equalTo: self.emptyStateView.centerXAnchor),

            self.emptyStateLabel.leadingAnchor.constraint(equalTo: self.emptyStateView.leadingAnchor, constant: 50),
            self.emptyStateLabel.trailingAnchor.constraint(equalTo: self.emptyStateView.trailingAnchor, constant: -50),
            self.emptyStateLabel.topAnchor.constraint(equalTo: self.emptyStateImageView.bottomAnchor, constant: 25)
        ])

    }

}
