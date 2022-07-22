//
//  EditGroupViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 09/05/2022.
//

import UIKit
import Combine

class EditGroupViewController: UIViewController {
    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var notificationsButton: UIButton = Self.createNotificationsButton()
    private lazy var editButton: UIButton = Self.createEditButton()
    private lazy var newGroupInfoBaseView: UIView = Self.createNewGroupInfoBaseView()
    private lazy var newGroupIconBaseView: UIView = Self.createNewGroupIconBaseView()
    private lazy var newGroupIconInnerView: UIView = Self.createNewGroupIconInnerBaseView()
    private lazy var newGroupIconLabel: UILabel = Self.createNewGroupIconLabel()
    private lazy var textFieldBaseView: UIView = Self.createTextFieldBaseView()
    private lazy var newGroupTextField: UITextField = Self.createNewGroupTextField()
    private lazy var newGroupLineSeparatorView: UIView = Self.createNewGroupLineSeparatorView()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var leaveButton: UIButton = Self.createLeaveButton()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: EditGroupViewModel

    var isNotificationMuted: Bool = true {
        didSet {
            if isNotificationMuted {
                self.notificationsButton.setImage(UIImage(named: "notifications_status_on_icon"), for: UIControl.State.normal)
            }
            else {
                self.notificationsButton.setImage(UIImage(named: "notifications_status_icon"), for: UIControl.State.normal)
            }
        }
    }

    var isLoading: Bool = false {
        didSet {
            self.loadingBaseView.isHidden = !isLoading
        }
    }

    var shouldCloseChat: (() -> Void)?
    var shouldReloadData: (() -> Void)?
    var shouldUpdateGroupInfo: ((GroupInfo) -> Void)?

    // MARK: - Lifetime and Cycle
    init(viewModel: EditGroupViewModel) {
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

        self.newGroupTextField.delegate = self

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(ResultsHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: ResultsHeaderFooterView.identifier)
        self.tableView.register(GroupUserManagementTableViewCell.self,
                                forCellReuseIdentifier: GroupUserManagementTableViewCell.identifier)
        self.tableView.register(ActionButtonTableViewCell.self,
                                forCellReuseIdentifier: ActionButtonTableViewCell.identifier)

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.notificationsButton.addTarget(self, action: #selector(didTapNotificationButton), for: .primaryActionTriggered)

        self.editButton.addTarget(self, action: #selector(didTapEditButton), for: .primaryActionTriggered)

        self.leaveButton.addTarget(self, action: #selector(didTapLeaveButton), for: .primaryActionTriggered)

        self.isNotificationMuted = false

        self.isLoading = false

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(backgroundTapGesture)

        self.bind(toViewModel: self.viewModel)

        self.newGroupTextField.textPublisher
            .map { text in
                let groupName = self.viewModel.groupNamePublisher.value
                if text != groupName {
                    return true
                }
                return false
            }
            .assign(to: \.isEnabled, on: self.editButton)
            .store(in: &cancellables)

        if let loggedUserId = Env.gomaNetworkClient.getCurrentToken()?.userId,
           loggedUserId != self.viewModel.getAdminUserId() {
            self.newGroupTextField.isUserInteractionEnabled = false
            self.newGroupTextField.textColor = UIColor.App.textDisablePrimary
        }

    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        self.newGroupIconBaseView.layer.cornerRadius = self.newGroupIconBaseView.frame.height / 2

        self.newGroupIconInnerView.layer.cornerRadius = self.newGroupIconInnerView.frame.height / 2
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

        self.backButton.backgroundColor = .clear

        self.notificationsButton.backgroundColor = .clear

        self.editButton.backgroundColor = .clear
        self.editButton.tintColor = UIColor.App.highlightPrimary
        self.editButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        self.editButton.setTitleColor(UIColor.App.textDisablePrimary, for: .disabled)

        self.newGroupIconBaseView.backgroundColor = UIColor.App.backgroundOdds

        self.newGroupIconInnerView.backgroundColor = UIColor.App.backgroundPrimary

        self.newGroupIconLabel.textColor = UIColor.App.backgroundOdds

        self.textFieldBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.newGroupTextField.backgroundColor = UIColor.App.backgroundSecondary

        self.newGroupLineSeparatorView.backgroundColor = UIColor.App.separatorLine

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary

        self.leaveButton.backgroundColor = .clear
        self.leaveButton.tintColor = UIColor.App.inputError
        self.leaveButton.setTitleColor(UIColor.App.inputError, for: .normal)

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary

    }

    // MARK: Binding
    private func bind(toViewModel viewModel: EditGroupViewModel) {

        viewModel.groupNamePublisher
            .sink(receiveValue: { [weak self] groupName in
                self?.newGroupTextField.text = groupName
            })
            .store(in: &cancellables)

        viewModel.groupInitialsPublisher
            .sink(receiveValue: { [weak self] groupInitials in
                self?.newGroupIconLabel.text = groupInitials
            })
            .store(in: &cancellables)

        viewModel.shouldCloseChat
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] shouldCloseChat in
                if shouldCloseChat {
                    self?.shouldCloseChat?()
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            })
            .store(in: &cancellables)

        viewModel.needReloadData
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        viewModel.showErrorAlert
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.showErrorAlert()
            })
            .store(in: &cancellables)

        viewModel.editGroupFinished
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                if let groupInfo = self?.viewModel.getGroupInfo() {
                    self?.shouldUpdateGroupInfo?(groupInfo)
                }

                self?.shouldReloadData?()

                self?.navigationController?.popViewController(animated: true)
            })
            .store(in: &cancellables)

//        viewModel.isLoadingPublisher
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { [weak self] isLoading in
//                self?.isLoading = isLoading
//            })
//            .store(in: &cancellables)

        viewModel.hasLeftGroupPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] hasLeftGroup in
                if hasLeftGroup {
                    Env.gomaSocialClient.reloadChatroomsList.send()

                    self?.navigationController?.popToRootViewController(animated: true)
                }
            })
            .store(in: &cancellables)
    }

    // MARK: Functions
    private func showAddFriend() {
        let chatroomId = self.viewModel.getChatroomId()

        let addFriendsviewModel = EditGroupAddFriendViewModel(groupUsers: self.viewModel.users, chatroomId: chatroomId)

        let addFriendsViewController = EditGroupAddUserViewController(viewModel: addFriendsviewModel)

        addFriendsViewController.addSelectedUsersToGroupList = { [weak self] selectedUsers in
            self?.viewModel.addSelectedUsers(selectedUsers: selectedUsers)
        }

        self.present(addFriendsViewController, animated: true, completion: nil)
    }

    private func removeUser(userId: String, userIndex: Int) {

        if self.viewModel.users.count > 3 {
            let removeAlert = UIAlertController(title: localized("remove_user"),
                                                message: localized("remove_user_message"),
                                                preferredStyle: UIAlertController.Style.alert)

            removeAlert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { [weak self] _ in

                self?.viewModel.removeUser(userId: userId, userIndex: userIndex)

            }))

            removeAlert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel))

            self.present(removeAlert, animated: true, completion: nil)
        }
        else {
            let notAllowedAlert = UIAlertController(title: localized("not_allowed"),
                                                message: localized("minimum_users_message"),
                                                preferredStyle: UIAlertController.Style.alert)

            notAllowedAlert.addAction(UIAlertAction(title: localized("ok"), style: .default))

            self.present(notAllowedAlert, animated: true, completion: nil)
        }

    }

    private func showErrorAlert() {
        let errorAlert = UIAlertController(title: localized("server_error_title"),
                                            message: localized("server_error_message"),
                                            preferredStyle: UIAlertController.Style.alert)

        errorAlert.addAction(UIAlertAction(title: localized("ok"), style: .default))

        self.present(errorAlert, animated: true, completion: nil)
    }

    // MARK: Actions
    @objc func didTapBackButton() {

        if self.viewModel.isGroupEdited {
            let groupInfo = self.viewModel.getGroupInfo()

            self.shouldUpdateGroupInfo?(groupInfo)

            self.shouldReloadData?()
        }
        
        self.navigationController?.popViewController(animated: true)
    }

    @objc func didTapNotificationButton() {

        if self.isNotificationMuted == false {
            let alert = UIAlertController(
                title: "Mute notifications",
                message: nil,
                preferredStyle: .actionSheet
            )
            alert.addAction(UIAlertAction(
                title: "For 15 minutes",
                style: .default,
                handler: { _ in
                    print("15MIN")
                    self.isNotificationMuted = true
            }))
            alert.addAction(UIAlertAction(
                title: "For 1 hour",
                style: .default,
                handler: { _ in
                    print("1H")
                    self.isNotificationMuted = true

            }))
            alert.addAction(UIAlertAction(
                title: "For 8 hours",
                style: .default,
                handler: { _ in
                    print("8H")
                    self.isNotificationMuted = true

            }))
            alert.addAction(UIAlertAction(
                title: "For 24 hours",
                style: .default,
                handler: { _ in
                    print("24H")
                    self.isNotificationMuted = true

            }))
            alert.addAction(UIAlertAction(
                title: "Until I turn it back on",
                style: .default,
                handler: { _ in
                    print("ALWAYS")
                    self.isNotificationMuted = true
            }))
            alert.addAction(UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: { _ in
                print("CANCEL")
            }))
            present(alert,
                    animated: true,
                    completion: nil
            )
        }
        else {
            self.isNotificationMuted = false
        }
    }

    @objc func didTapEditButton() {
        let groupName = self.newGroupTextField.text ?? ""
        self.viewModel.editGroupInfo(groupName: groupName)
    }

    @objc func didTapLeaveButton() {
        print("LEAVE GROUP")

        let leaveGroupAlert = UIAlertController(title: localized("leave_group"),
                                            message: localized("leave_group_message"),
                                            preferredStyle: UIAlertController.Style.alert)

        leaveGroupAlert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { [weak self] _ in

            self?.viewModel.leaveGroup()

        }))

        leaveGroupAlert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel))

        self.present(leaveGroupAlert, animated: true, completion: nil)
    }

    @objc func didTapBackground() {
        self.newGroupTextField.resignFirstResponder()
    }
}

//
// MARK: Delegates
//
extension EditGroupViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.users.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == self.viewModel.users.count {
            guard let cell = tableView.dequeueCellType(ActionButtonTableViewCell.self)
            else {
                fatalError()
            }

            cell.didTapActionButtonCallback = { [weak self] in
                self?.showAddFriend()
            }

            return cell
        }
        else {
            guard let cell = tableView.dequeueCellType(GroupUserManagementTableViewCell.self)
            else {
                fatalError()
            }

            if let userContact = self.viewModel.users[safe: indexPath.row] {

                let adminUserId = self.viewModel.getAdminUserId()

                if let cellViewModel = self.viewModel.cachedUserCellViewModels[userContact.id] {

                    if userContact.id == "\(adminUserId)" {
                        cellViewModel.isAdmin = true
                    }

                    cell.configure(viewModel: cellViewModel)

                }
                else {
                    let cellViewModel = GroupUserManagementCellViewModel(userContact: userContact, chatroomId: self.viewModel.getChatroomId())
                    self.viewModel.cachedUserCellViewModels[userContact.id] = cellViewModel

                    if userContact.id == "\(adminUserId)" {
                        cellViewModel.isAdmin = true
                    }
                    
                    cell.configure(viewModel: cellViewModel)

                }

                if let loggedUserId = Env.gomaNetworkClient.getCurrentToken()?.userId,
                   loggedUserId == self.viewModel.getAdminUserId() {

                    cell.didTapDeleteAction = { [weak self] in
                        self?.removeUser(userId: userContact.id, userIndex: indexPath.row)
                    }

                    cell.canDeleteUser = true
                }
                else {
                    cell.canDeleteUser = false
                }

            }

            if indexPath.row == self.viewModel.users.count - 1 {
                cell.hasSeparatorLine = false
            }

            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

       return 70

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return 70

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 0

    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

       return 0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

}

extension EditGroupViewController: UITextFieldDelegate {

    func textFieldDidChangeSelection(_ textField: UITextField) {

        if let text = textField.text, text != "" {
            self.newGroupIconLabel.text = self.viewModel.getGroupInitials(text: text)
        }
        else {
            self.newGroupIconLabel.text = "G"
        }
    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension EditGroupViewController {
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

    private static func createBackButton() -> UIButton {
        let button = UIButton.init(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        button.setTitle(nil, for: .normal)
        return button
    }

    private static func createNotificationsButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "notifications_status_on_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }

    private static func createEditButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("save"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = localized("edit_group")
        return label
    }

    private static func createNewGroupInfoBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNewGroupIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNewGroupIconInnerBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNewGroupIconLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "G"
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        return label
    }

    private static func createTextFieldBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNewGroupTextField() -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = localized("group_name")
        textField.layer.cornerRadius = CornerRadius.view
        return textField
    }

    private static func createNewGroupLineSeparatorView() -> UIView {
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

    private static func createLeaveButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "leave_group_icon"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: -3, left: -15, bottom: 0, right: 0)
        button.setTitle(localized("leave_group"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        return button
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

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.notificationsButton)
        self.navigationView.addSubview(self.titleLabel)
        self.navigationView.addSubview(self.editButton)

        self.view.addSubview(self.newGroupInfoBaseView)

        self.newGroupInfoBaseView.addSubview(self.newGroupIconBaseView)

        self.newGroupIconBaseView.addSubview(self.newGroupIconInnerView)

        self.newGroupIconInnerView.addSubview(self.newGroupIconLabel)

        self.newGroupInfoBaseView.addSubview(self.textFieldBaseView)

        self.textFieldBaseView.addSubview(self.newGroupTextField)

        self.view.addSubview(self.newGroupLineSeparatorView)

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.leaveButton)

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

            self.backButton.heightAnchor.constraint(equalTo: self.navigationView.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 10),

            self.notificationsButton.leadingAnchor.constraint(equalTo: self.backButton.trailingAnchor, constant: 8),
            self.notificationsButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.notificationsButton.widthAnchor.constraint(equalToConstant: 40),
            self.notificationsButton.heightAnchor.constraint(equalTo: self.notificationsButton.widthAnchor),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -60),

            self.editButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -10),
            self.editButton.widthAnchor.constraint(equalToConstant: 40),
            self.editButton.heightAnchor.constraint(equalTo: self.editButton.widthAnchor),
            self.editButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor)
        ])

        // New Group Top View
        NSLayoutConstraint.activate([
            self.newGroupInfoBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.newGroupInfoBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.newGroupInfoBaseView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.newGroupInfoBaseView.heightAnchor.constraint(equalToConstant: 70),

            self.newGroupIconBaseView.leadingAnchor.constraint(equalTo: self.newGroupInfoBaseView.leadingAnchor, constant: 25),
            self.newGroupIconBaseView.widthAnchor.constraint(equalToConstant: 40),
            self.newGroupIconBaseView.heightAnchor.constraint(equalTo: self.newGroupIconBaseView.widthAnchor),
            self.newGroupIconBaseView.centerYAnchor.constraint(equalTo: self.newGroupInfoBaseView.centerYAnchor),

            self.newGroupIconInnerView.widthAnchor.constraint(equalToConstant: 37),
            self.newGroupIconInnerView.heightAnchor.constraint(equalTo: self.newGroupIconInnerView.widthAnchor),
            self.newGroupIconInnerView.centerXAnchor.constraint(equalTo: self.newGroupIconBaseView.centerXAnchor),
            self.newGroupIconInnerView.centerYAnchor.constraint(equalTo: self.newGroupIconBaseView.centerYAnchor),

            self.newGroupIconLabel.leadingAnchor.constraint(equalTo: self.newGroupIconInnerView.leadingAnchor, constant: 4),
            self.newGroupIconLabel.trailingAnchor.constraint(equalTo: self.newGroupIconInnerView.trailingAnchor, constant: -4),
            self.newGroupIconLabel.centerYAnchor.constraint(equalTo: self.newGroupIconInnerView.centerYAnchor),

            self.textFieldBaseView.leadingAnchor.constraint(equalTo: self.newGroupIconBaseView.trailingAnchor, constant: 8),
            self.textFieldBaseView.trailingAnchor.constraint(equalTo: self.newGroupInfoBaseView.trailingAnchor, constant: -25),
            self.textFieldBaseView.centerYAnchor.constraint(equalTo: self.newGroupInfoBaseView.centerYAnchor),
            self.textFieldBaseView.heightAnchor.constraint(equalToConstant: 50),

            self.newGroupTextField.leadingAnchor.constraint(equalTo: self.textFieldBaseView.leadingAnchor, constant: 10),
            self.newGroupTextField.trailingAnchor.constraint(equalTo: self.textFieldBaseView.trailingAnchor, constant: -10),
            self.newGroupTextField.topAnchor.constraint(equalTo: self.textFieldBaseView.topAnchor, constant: 5),
            self.newGroupTextField.bottomAnchor.constraint(equalTo: self.textFieldBaseView.bottomAnchor, constant: -5),

            self.newGroupLineSeparatorView.leadingAnchor.constraint(equalTo: self.newGroupIconBaseView.leadingAnchor),
            self.newGroupLineSeparatorView.trailingAnchor.constraint(equalTo: self.textFieldBaseView.trailingAnchor),
            self.newGroupLineSeparatorView.topAnchor.constraint(equalTo: self.newGroupInfoBaseView.bottomAnchor, constant: 15),
            self.newGroupLineSeparatorView.heightAnchor.constraint(equalToConstant: 1)

        ])

        // Tableview
        NSLayoutConstraint.activate([

            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.newGroupLineSeparatorView.bottomAnchor, constant: 15),
            self.tableView.bottomAnchor.constraint(equalTo: self.leaveButton.topAnchor)
        ])

        NSLayoutConstraint.activate([
            self.leaveButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
            self.leaveButton.heightAnchor.constraint(equalToConstant: 30),
            self.leaveButton.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor, constant: -10)
        ])

        // Loading Screen
        NSLayoutConstraint.activate([
            self.loadingBaseView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor)
        ])
    }
}
