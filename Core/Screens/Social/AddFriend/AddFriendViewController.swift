//
//  AddFriendViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 14/04/2022.
//

import UIKit
import Contacts
import Combine

class AddFriendViewController: UIViewController {
    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var userInfoHeaderView: UIView = Self.createUserInfoHeaderView()
    private lazy var userIconView: UIView = Self.createUserIconView()
    private lazy var userIconImageView: UIImageView = Self.createUserIconImageView()
    private lazy var usernameLabel: UILabel = Self.createUsernameLabel()
    private lazy var userCodeTitleLabel: UILabel = Self.createUserCodeTitleLabel()
    private lazy var shareCodeButton: UIButton = Self.createShareCodeButton()
    private lazy var qrCodeButton: UIButton = Self.createQRCodeButton()
    private lazy var searchFriendLabel: UILabel = Self.createSearchFriendLabel()
    private lazy var searchFriendTextFieldView: ActionSearchTextFieldView = Self.createSearchFriendTextFieldView()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var scanFriendBaseView: UIView = Self.createScanFriendBaseView()
    private lazy var scanFriendTitleLabel: UILabel = Self.createScanFriendTitleLabel()
    private lazy var scanFriendIconView: UIView = Self.createScanFriendIconView()
    private lazy var scanFriendImageView: UIImageView = Self.createScanFriendImageView()
    private lazy var scanFriendSubtitleLabel: UILabel = Self.createScanFriendSubtitleLabel()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: AddFriendViewModel

    var isEmptySearch: Bool = true {
        didSet {
            self.tableView.isHidden = isEmptySearch
        }
    }

    var chatListNeedsReload: (() -> Void)?

    // MARK: - Lifetime and Cycle
    init(viewModel: AddFriendViewModel) {
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

        self.tableView.register(ResultsHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: ResultsHeaderFooterView.identifier)
        self.tableView.register(AddFriendTableViewCell.self,
                                forCellReuseIdentifier: AddFriendTableViewCell.identifier)
        self.tableView.register(SearchFriendTableViewCell.self,
                                forCellReuseIdentifier: SearchFriendTableViewCell.identifier)

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)
        
        self.shareCodeButton.addTarget(self, action: #selector(didTapShareCodeButton), for: .primaryActionTriggered)
        
        self.qrCodeButton.addTarget(self, action: #selector(didTapQRCodeButton), for: .primaryActionTriggered)

        let scanQRCodeGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScanQRCode))
        self.scanFriendIconView.addGestureRecognizer(scanQRCodeGesture)

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(backgroundTapGesture)

        self.bind(toViewModel: self.viewModel)

        self.setupPublishers()

        // TableView top padding fix
        if #available(iOS 15.0, *) {
          tableView.sectionHeaderTopPadding = 0
        }
    }
    
    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()
        
        self.userInfoHeaderView.layer.cornerRadius = CornerRadius.button

        self.userIconView.layer.cornerRadius = self.userIconView.frame.height / 2
        self.userIconView.clipsToBounds = true
        
        self.userIconImageView.layer.cornerRadius = self.userIconImageView.frame.height / 2
        
        self.scanFriendIconView.layer.cornerRadius = CornerRadius.button

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

        self.backButton.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary
        
        self.userInfoHeaderView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.userIconView.backgroundColor = .clear
        self.userIconView.layer.borderColor = UIColor.App.highlightTertiary.cgColor
        
        self.userIconImageView.backgroundColor = .clear
        
        self.usernameLabel.textColor = UIColor.App.highlightTertiary
                        
        self.shareCodeButton.tintColor = UIColor.App.iconPrimary
        
        self.qrCodeButton.tintColor = UIColor.App.iconPrimary
        
        self.searchFriendLabel.textColor = UIColor.App.textPrimary

        self.tableView.backgroundColor = UIColor.App.backgroundSecondary

        self.scanFriendBaseView.backgroundColor = .clear

        self.scanFriendTitleLabel.textColor = UIColor.App.textSecondary
        
        self.scanFriendIconView.backgroundColor = UIColor.App.backgroundTertiary
        
        self.scanFriendImageView.backgroundColor = .clear
        
        self.scanFriendSubtitleLabel.textColor = UIColor.App.textPrimary
    }

    // MARK: binding

    private func bind(toViewModel viewModel: AddFriendViewModel) {

        viewModel.dataNeedsReload
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        viewModel.canAddFriendPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isEnabled in
//                self?.addFriendButton.isEnabled = isEnabled
            })
            .store(in: &cancellables)

        viewModel.friendsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] users in
                self?.isEmptySearch = users.isEmpty
            })
            .store(in: &cancellables)

        viewModel.friendCodeInvalidPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.showInvalidCodeAlert()
            })
            .store(in: &cancellables)

        viewModel.shouldShowAlert
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] showAlert in
                if showAlert, let friendAlertType = viewModel.friendAlertType {
                    self?.showAddFriendAlert(friendAlertType: friendAlertType)
                }
            })
            .store(in: &cancellables)

        viewModel.userContactSection
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] userContacts in
                self?.isEmptySearch = userContacts.isEmpty
            })
            .store(in: &cancellables)

        // Close screen after chatroom list and last message are updated
        Env.gomaSocialClient.allDataSubscribed
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                guard let self = self else {return}

                if self.viewModel.chatroomsResponse.count > 1 {
                    self.navigationController?.popViewController(animated: true)

                }
                else {
                    if let chatroomId = self.viewModel.chatroomsResponse[safe: 0] {

                        self.showChatroom(chatroomId: chatroomId)

                    }
                }

            })
            .store(in: &cancellables)
    }

    // MARK: Functions
    private func setupPublishers() {
        self.searchFriendTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                if text != "" {
                    self?.searchFriendTextFieldView.isActionDisabled = false
                }
                else {
                    self?.searchFriendTextFieldView.isActionDisabled = true
                }
            })
            .store(in: &cancellables)

        self.searchFriendTextFieldView.didTapButtonAction = { [weak self] in
            let friendCode = self?.searchFriendTextFieldView.getTextFieldValue() ?? ""
            self?.viewModel.getUserInfo(friendCode: friendCode)
        }
    }

    private func showInvalidCodeAlert() {
        let invalidCodeAlert = UIAlertController(title: localized("invalid_code"),
                                                   message: localized("invalid_code_message"),
                                                   preferredStyle: UIAlertController.Style.alert)

        invalidCodeAlert.addAction(UIAlertAction(title: localized("ok"), style: .default))

        self.present(invalidCodeAlert, animated: true, completion: nil)
    }

    private func showAddFriendAlert(friendAlertType: FriendAlertType) {
        switch friendAlertType {
        case .success:

            self.chatListNeedsReload?()
            
            self.navigationController?.popViewController(animated: true)
        case .error:
            let errorFriendAlert = UIAlertController(title: localized("friend_added_error"),
                                                       message: localized("friend_added_message_error"),
                                                       preferredStyle: UIAlertController.Style.alert)

            errorFriendAlert.addAction(UIAlertAction(title: localized("ok"), style: .default))

            self.present(errorFriendAlert, animated: true, completion: nil)
        }

    }

    private func showChatroom(friendId: Int? = nil, chatroomId: Int? = nil) {

        if let friendId = friendId {
            let conversationData = self.viewModel.getConversationData(userId: "\(friendId)")

            let conversationDetailViewModel = ConversationDetailViewModel(conversationData: conversationData)

            let conversationDetailViewController = ConversationDetailViewController(viewModel: conversationDetailViewModel)

            self.navigationController?.pushViewController(conversationDetailViewController, animated: true)
        }

        if let chatroomId = chatroomId {
            let chatId = chatroomId

            let conversationDetailViewModel = ConversationDetailViewModel(chatId: chatId)

            let conversationDetailViewController = ConversationDetailViewController(viewModel: conversationDetailViewModel)

            self.navigationController?.pushViewController(conversationDetailViewController, animated: true)
        }

    }

    // MARK: Actions
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapShareCodeButton() {
        
        let urlMobile = TargetVariables.clientBaseUrl
        
        let userCode = Env.userSessionStore.userProfilePublisher.value?.godfatherCode ?? ""
        
        let shareLink = "\(urlMobile)/en/friend-code/\(userCode)"
        
        let shareActivityViewController = UIActivityViewController(activityItems: [shareLink],
                                                                   applicationActivities: nil)
        if let popoverController = shareActivityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        self.present(shareActivityViewController, animated: true, completion: nil)
    }
    
    @objc private func didTapQRCodeButton() {
        let socialUserQRCodeViewModel = SocialUserQRCodeViewModel()
        
        let socialUserQRCodeViewController = SocialUserQRCodeViewController(viewModel: socialUserQRCodeViewModel)
        
        socialUserQRCodeViewController.chatListNeedsReload = { [weak self] in
            self?.chatListNeedsReload?()
        }
        
        self.navigationController?.pushViewController(socialUserQRCodeViewController, animated: true)
    }

//    @objc func didTapAddContactButton() {
//
//        let contactStore = CNContactStore()
//
//        switch CNContactStore.authorizationStatus(for: .contacts) {
//        case .authorized:
//            print("Authorized")
//            let addContactViewModel = AddContactViewModel()
//            let addContactViewController = AddContactViewController(viewModel: addContactViewModel)
//
//            addContactViewController.chatListNeedsReload = { [weak self] in
//                self?.chatListNeedsReload?()
//            }
//
//            self.navigationController?.pushViewController(addContactViewController, animated: true)
//
//        case .notDetermined:
//            print("Not determined")
//            contactStore.requestAccess(for: .contacts) { succeeded, error in
//                guard succeeded && error == nil else {
//                    return
//                }
//
//                if succeeded {
//                    DispatchQueue.main.async {
//                        let addContactViewModel = AddContactViewModel()
//                        let addContactViewController = AddContactViewController(viewModel: addContactViewModel)
//
//                        addContactViewController.chatListNeedsReload = { [weak self] in
//                            self?.chatListNeedsReload?()
//                        }
//
//                        self.navigationController?.pushViewController(addContactViewController, animated: true)
//                    }
//
//                }
//            }
//
//        case .denied:
//            print("Not handled")
//
//        case .restricted:
//            print("Not handled")
//
//        @unknown default:
//            print("Not handled")
//        }
//
//    }

    @objc private func didTapAddFriendButton() {
        print("FRIENDS SELECTED: \(self.viewModel.selectedUsers)")

        self.viewModel.sendFriendRequest()
    }

    @objc private func didTapBackground() {
        self.searchFriendTextFieldView.resignFirstResponder()
    }
    
    @objc private func didTapScanQRCode() {
        let scannerVC = QRScannerViewController()
        let navigationController = UINavigationController(rootViewController: scannerVC)
        navigationController.modalPresentationStyle = .fullScreen
        
        scannerVC.didScanQRCode = { [weak self] code in
            print("SCANNED: \(code)")
            self?.viewModel.processQRCode(code: code)
        }
        
        present(navigationController, animated: true)
    }

}

//
// MARK: Delegates
//
extension AddFriendViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.userContactSection.value.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return self.viewModel.usersPublisher.value.count
        return self.viewModel.userContactSection.value[section].userContacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if self.viewModel.userContactSection.value[indexPath.section].contactSectionType == .search {

            guard let cell = tableView.dequeueCellType(SearchFriendTableViewCell.self)
            else {
                fatalError()
            }

            if let userContact = self.viewModel.usersPublisher.value[safe: indexPath.row] {

                if let cellViewModel = self.viewModel.cachedSearchCellViewModels[userContact.id] {
                    cell.configure(viewModel: cellViewModel)

                }
                else {
                    let cellViewModel = AddFriendCellViewModel(userContact: userContact)
                    self.viewModel.cachedSearchCellViewModels[userContact.id] = cellViewModel
                    cell.configure(viewModel: cellViewModel)

                }

            }
            
            cell.roundCornerType = .all
            
            cell.errorAddingFriend = { [weak self] in
                self?.showAddFriendAlert(friendAlertType: .error)
            }
            
            cell.chatListNeedsReload = { [weak self] in
                self?.chatListNeedsReload?()
            }

            return cell
        }
        else if self.viewModel.userContactSection.value[indexPath.section].contactSectionType == .friends {
            guard
                let cell = tableView.dequeueCellType(FriendStatusTableViewCell.self)
            else {
                fatalError()
            }

            if let friend = self.viewModel.friendsPublisher.value[safe: indexPath.row] {

                if let cellViewModel = self.viewModel.cachedFriendsCellViewModels[friend.id] {
                    cell.configure(withViewModel: cellViewModel)
                }
                else {
                    let cellViewModel = FriendStatusCellViewModel(friend: friend)
                    self.viewModel.cachedFriendsCellViewModels[friend.id] = cellViewModel

                    cell.configure(withViewModel: cellViewModel)
                }

                if indexPath.row == self.viewModel.userContactSection.value[indexPath.section].userContacts.count - 1 {
                    cell.hasSeparatorLine = false
                }
                else {
                    cell.hasSeparatorLine = true
                }

                cell.shouldShowChatroom = { [weak self] in
                    self?.showChatroom(friendId: friend.id)
                }

            }

            return cell
        }

        else {
            return UITableViewCell()
        }

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if self.viewModel.userContactSection.value[section].contactSectionType == .search {

//            if self.viewModel.usersPublisher.value.isNotEmpty {
//                guard
//                    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ResultsHeaderFooterView.identifier) as? ResultsHeaderFooterView
//                else {
//                    fatalError()
//                }
//
//                let resultsLabel = "Results (\(self.viewModel.usersPublisher.value.count))"
//
//                headerView.configureHeader(title: resultsLabel)
//
//                return headerView
//            }
//            else {
//                return UIView()
//            }
            
            return UIView()
        }
        else if self.viewModel.userContactSection.value[section].contactSectionType == .friends {
            if self.viewModel.friendsPublisher.value.isNotEmpty {
                guard
                    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ResultsHeaderFooterView.identifier) as? ResultsHeaderFooterView
                else {
                    fatalError()
                }

                let resultsLabel = localized("my_friends")

                headerView.configureHeader(title: resultsLabel)

                return headerView
            }
            else {
                return UIView()
            }

        }
        else {
            return UIView()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if self.viewModel.userContactSection.value.isNotEmpty {
            return 70
        }
        else {
            return 0
        }

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        if self.viewModel.userContactSection.value.isNotEmpty {
            return 70
        }
        else {
            return 0
        }

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if self.viewModel.userContactSection.value.isNotEmpty {
            if self.viewModel.userContactSection.value[section].contactSectionType == .search {
                return 0
            }
            return 30
        }
        else {
            return 0
        }

    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

        if self.viewModel.userContactSection.value.isNotEmpty {
            if self.viewModel.userContactSection.value[section].contactSectionType == .search {
                return 0
            }
            return 30
        }
        else {
            return 0
        }
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
extension AddFriendViewController {
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

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = localized("add_friend")
        return label
    }
    
    private static func createUserInfoHeaderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createUserIconView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 2
        return view
    }
    
    private static func createUserIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        if let avatar = Env.userSessionStore.userProfilePublisher.value?.avatarName {
            if let avatarImage = UIImage(named: avatar) {
                imageView.image = avatarImage
            }
            else {
                imageView.image = UIImage(named: "empty_user_image")
            }
        }
        else {
            imageView.image = UIImage(named: "empty_user_image")
        }
        
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createUsernameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .left
        label.text = "\(Env.userSessionStore.userProfilePublisher.value?.username ?? "")"
        return label
    }
    
    private static func createUserCodeTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left

        let code = Env.userSessionStore.userProfilePublisher.value?.godfatherCode ?? ""
        
        let fullText = localized("user_code_dynamic").replacingFirstOccurrence(of: "{code_str}", with: code)
        
        let range = (fullText as NSString).range(of: code)
        
        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: [.foregroundColor: UIColor.App.textPrimary,
                         .font: AppFont.with(type: .bold, size: 16)]
        )
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.textSecondary, range: range)
        
        label.attributedText = attributedString
        return label
    }
    
    private static func createShareCodeButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "share_code_icon")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        return button
    }
    
    private static func createQRCodeButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "qr_code_icon")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        return button
    }

    private static func createSearchFriendLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 18)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.text = localized("search_friend_code")
        return label
    }

    private static func createSearchFriendTextFieldView() -> ActionSearchTextFieldView {
        let textFieldView = ActionSearchTextFieldView()
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        textFieldView.setPlaceholderText(placeholder: localized("friend_code"))
        textFieldView.setActionButtonTitle(title: localized("search"))
        return textFieldView
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }

    private static func createScanFriendBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createScanFriendTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        label.text = localized("do_you_have_a_friends_qr_code")
        return label
    }
    
    private static func createScanFriendIconView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createScanFriendImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "scan_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createScanFriendSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 12)
        label.textAlignment = .center
        label.text = localized("add_via_qr_code")
        return label
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.titleLabel)
        
        self.view.addSubview(self.userInfoHeaderView)
        
        self.userInfoHeaderView.addSubview(self.userIconView)
        
        self.userIconView.addSubview(self.userIconImageView)
        
        self.userInfoHeaderView.addSubview(self.usernameLabel)
        self.userInfoHeaderView.addSubview(self.userCodeTitleLabel)
        self.userInfoHeaderView.addSubview(self.shareCodeButton)
        self.userInfoHeaderView.addSubview(self.qrCodeButton)
        
        self.view.addSubview(self.searchFriendLabel)

        self.view.addSubview(self.searchFriendTextFieldView)

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.scanFriendBaseView)

        self.scanFriendBaseView.addSubview(self.scanFriendTitleLabel)
        
        self.scanFriendBaseView.addSubview(self.scanFriendIconView)
        
        self.scanFriendIconView.addSubview(self.scanFriendImageView)
        
        self.scanFriendBaseView.addSubview(self.scanFriendSubtitleLabel)

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
            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 0),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor)

        ])
        
        // User Header Info View
        NSLayoutConstraint.activate([
            self.userInfoHeaderView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            self.userInfoHeaderView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            self.userInfoHeaderView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 10),
            
            self.userIconView.leadingAnchor.constraint(equalTo: self.userInfoHeaderView.leadingAnchor, constant: 18),
            self.userIconView.topAnchor.constraint(equalTo: self.userInfoHeaderView.topAnchor, constant: 24),
            self.userIconView.bottomAnchor.constraint(equalTo: self.userInfoHeaderView.bottomAnchor, constant: -24),
            self.userIconView.widthAnchor.constraint(equalToConstant: 40),
            self.userIconView.heightAnchor.constraint(equalTo: self.userIconView.widthAnchor),
            
            self.userIconImageView.leadingAnchor.constraint(equalTo: self.userIconView.leadingAnchor),
            self.userIconImageView.trailingAnchor.constraint(equalTo: self.userIconView.trailingAnchor),
            self.userIconImageView.topAnchor.constraint(equalTo: self.userIconView.topAnchor),
            self.userIconImageView.bottomAnchor.constraint(equalTo: self.userIconView.bottomAnchor),
            
            self.usernameLabel.leadingAnchor.constraint(equalTo: self.userIconView.trailingAnchor, constant: 10),
            self.usernameLabel.trailingAnchor.constraint(equalTo: self.userInfoHeaderView.trailingAnchor, constant: -18),
            self.usernameLabel.topAnchor.constraint(equalTo: self.userIconView.topAnchor, constant: -4),
            
            self.userCodeTitleLabel.leadingAnchor.constraint(equalTo: self.usernameLabel.leadingAnchor, constant: 0),
            self.userCodeTitleLabel.bottomAnchor.constraint(equalTo: self.userIconView.bottomAnchor, constant: 4),
            
            self.shareCodeButton.leadingAnchor.constraint(equalTo: self.userCodeTitleLabel.trailingAnchor, constant: 8),
            self.shareCodeButton.centerYAnchor.constraint(equalTo: self.userCodeTitleLabel.centerYAnchor),
            self.shareCodeButton.widthAnchor.constraint(equalToConstant: 25),
            self.shareCodeButton.heightAnchor.constraint(equalTo: self.shareCodeButton.widthAnchor),
            
            self.qrCodeButton.leadingAnchor.constraint(equalTo: self.shareCodeButton.trailingAnchor, constant: 2),
            self.qrCodeButton.centerYAnchor.constraint(equalTo: self.userCodeTitleLabel.centerYAnchor),
            self.qrCodeButton.widthAnchor.constraint(equalToConstant: 25),
            self.qrCodeButton.heightAnchor.constraint(equalTo: self.shareCodeButton.widthAnchor)
            
        ])

        // Search friend code views
        NSLayoutConstraint.activate([
            self.searchFriendLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
            self.searchFriendLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            self.searchFriendLabel.topAnchor.constraint(equalTo: self.userInfoHeaderView.bottomAnchor, constant: 35),

            self.searchFriendTextFieldView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
            self.searchFriendTextFieldView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            self.searchFriendTextFieldView.topAnchor.constraint(equalTo: self.searchFriendLabel.bottomAnchor, constant: 8)
        ])

        // Tableview
        NSLayoutConstraint.activate([

            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.searchFriendTextFieldView.bottomAnchor, constant: 20)

        ])

        // Add Friend Button View
        NSLayoutConstraint.activate([
            self.scanFriendBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scanFriendBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scanFriendBaseView.topAnchor.constraint(equalTo: self.tableView.bottomAnchor, constant: 8),
            self.scanFriendBaseView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),
            
            self.scanFriendTitleLabel.leadingAnchor.constraint(equalTo: self.scanFriendBaseView.leadingAnchor, constant: 15),
            self.scanFriendTitleLabel.trailingAnchor.constraint(equalTo: self.scanFriendBaseView.trailingAnchor, constant: -15),
            self.scanFriendTitleLabel.topAnchor.constraint(equalTo: self.scanFriendBaseView.topAnchor, constant: 2),
            
            self.scanFriendIconView.topAnchor.constraint(equalTo: self.scanFriendTitleLabel.bottomAnchor, constant: 15),
            self.scanFriendIconView.widthAnchor.constraint(equalToConstant: 55),
            self.scanFriendIconView.heightAnchor.constraint(equalTo: self.scanFriendIconView.widthAnchor),
            self.scanFriendIconView.centerXAnchor.constraint(equalTo: self.scanFriendBaseView.centerXAnchor),
            
            self.scanFriendImageView.centerXAnchor.constraint(equalTo: self.scanFriendIconView.centerXAnchor),
            self.scanFriendImageView.centerYAnchor.constraint(equalTo: self.scanFriendIconView.centerYAnchor),
            self.scanFriendImageView.widthAnchor.constraint(equalToConstant: 32),
            self.scanFriendImageView.heightAnchor.constraint(equalTo: self.scanFriendImageView.widthAnchor),
            
            self.scanFriendSubtitleLabel.leadingAnchor.constraint(equalTo: self.scanFriendBaseView.leadingAnchor, constant: 15),
            self.scanFriendSubtitleLabel.trailingAnchor.constraint(equalTo: self.scanFriendBaseView.trailingAnchor, constant: -15),
            self.scanFriendSubtitleLabel.topAnchor.constraint(equalTo: self.scanFriendIconView.bottomAnchor, constant: 8),
            self.scanFriendSubtitleLabel.bottomAnchor.constraint(equalTo: self.scanFriendBaseView.bottomAnchor, constant: -15)
            
        ])

    }
}
