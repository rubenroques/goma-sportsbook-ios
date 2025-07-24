//
//  NewGroupViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 21/04/2022.
//

import UIKit
import Combine

class NewGroupViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var searchBar: UISearchBar = Self.createSearchBar()
    private lazy var headerTitleLabel: UILabel = Self.createHeaderTitleLabel()
    private lazy var headerSubtitleLabel: UILabel = Self.createHeaderSubtitleLabel()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var nextBaseView: UIView = Self.createNextBaseView()
    private lazy var nextButton: UIButton = Self.createNextButton()
    private lazy var nextSeparatorLineView: UIView = Self.createNextSeparatorLineView()
    
    private lazy var alphabetCollectionView: UICollectionView = Self.createAlphabetCollectionView()
    
    private lazy var emptyStateView: UIView = Self.createEmptyStateView()
    private lazy var emptyStateImageView: UIImageView = Self.createEmptyStateImageView()
    private lazy var emptyStateLabel: UILabel = Self.createEmptyStateLabel()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()

    private var cancellables = Set<AnyCancellable>()
    
    private let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

    // MARK: Public Properties
    var viewModel: NewGroupViewModel

    var isEmptyState: Bool = false {
        didSet {
            self.emptyStateView.isHidden = !isEmptyState
        }
    }

    var isLoading: Bool = false {
        didSet {
            self.loadingBaseView.isHidden = !isLoading
        }
    }

    var isSharedTicketNewGroup: Bool = false

    var chatListNeedReload: (() -> Void)?
    var shareChatroomsNeedReload: (() -> Void)?

    // MARK: - Lifetime and Cycle
    init(viewModel: NewGroupViewModel) {
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

        self.searchBar.delegate = self

        self.tableView.delegate = self
        self.tableView.dataSource = self

//        self.tableView.register(NewGroupHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: NewGroupHeaderFooterView.identifier)
        self.tableView.register(ListTitleHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: ListTitleHeaderFooterView.identifier)

        self.tableView.register(GroupFriendTableViewCell.self,
                                forCellReuseIdentifier: GroupFriendTableViewCell.identifier)
        
        self.alphabetCollectionView.delegate = self
        self.alphabetCollectionView.dataSource = self
        
        self.alphabetCollectionView.register(LetterCollectionViewCell.self, forCellWithReuseIdentifier: LetterCollectionViewCell.identifier)

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)

        self.nextButton.addTarget(self, action: #selector(didTapNextButton), for: .primaryActionTriggered)

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(backgroundTapGesture)

        self.bind(toViewModel: self.viewModel)

        // TableView top padding fix
        if #available(iOS 15.0, *) {
          tableView.sectionHeaderTopPadding = 0
        }
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
        self.view.backgroundColor = UIColor.App.backgroundSecondary

        self.topSafeAreaView.backgroundColor = .clear

        self.bottomSafeAreaView.backgroundColor = .clear

        self.navigationView.backgroundColor = UIColor.App.backgroundSecondary

        self.backButton.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.closeButton.backgroundColor = .clear
        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.setupSearchBarStyle()
        
        self.headerTitleLabel.textColor = UIColor.App.textPrimary
        
        self.headerSubtitleLabel.textColor = UIColor.App.textSecondary

        self.tableView.backgroundColor = UIColor.App.backgroundSecondary

        self.nextBaseView.backgroundColor = UIColor.App.backgroundSecondary

        StyleHelper.styleButton(button: self.nextButton)

        self.nextSeparatorLineView.backgroundColor = UIColor.App.separatorLine

        self.emptyStateView.backgroundColor = UIColor.App.backgroundSecondary

        self.emptyStateImageView.backgroundColor = .clear

        self.emptyStateLabel.textColor = UIColor.App.textPrimary

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundSecondary

    }

    // MARK: Binding

    private func bind(toViewModel viewModel: NewGroupViewModel) {

        viewModel.dataNeedsReload
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        viewModel.canAddFriendPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isEnabled in
                self?.nextButton.isEnabled = isEnabled
            })
            .store(in: &cancellables)

        viewModel.usersPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] users in
                self?.isEmptyState = users.isEmpty
            })
            .store(in: &cancellables)

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                self?.isLoading = isLoading
            })
            .store(in: &cancellables)
    }

    // MARK: Functions
    private func setupSearchBarStyle() {
        self.searchBar.searchBarStyle = UISearchBar.Style.prominent
        self.searchBar.sizeToFit()
        self.searchBar.isTranslucent = false
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.tintColor = .white
        self.searchBar.barTintColor = .white
        self.searchBar.backgroundImage = UIColor.App.backgroundSecondary.image()
        self.searchBar.placeholder = localized("search")

        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.App.inputBackground
            textfield.textColor = UIColor.App.textPrimary
            textfield.tintColor = UIColor.App.textPrimary
            textfield.attributedPlaceholder = NSAttributedString(string: localized("search_by_username"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor:
                                                                                UIColor.App.inputTextTitle,
                                                                              NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 14)])

            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = UIColor.App.iconSecondary
            }
            
            textfield.layer.borderWidth = 1
            textfield.layer.borderColor = UIColor.App.separatorLineSecondary.cgColor
            textfield.layer.cornerRadius = 10
        }

    }

    // MARK: Actions
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func didTapCloseButton() {

        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc func didTapNextButton() {
        var selectedUsers: [UserContact] = []
//        if let loggedUser = Env.userSessionStore.loggedUserProfile,
//           let loggedUserId = Env.userSessionStore.userProfilePublisher.value?.userIdentifier {
//            let adminUser = UserContact(id: "\(loggedUserId)", username: loggedUser.username, phones: [], avatar: loggedUser.avatarName)
//
//            selectedUsers.append(adminUser)
//        }

        selectedUsers.append(contentsOf: self.viewModel.selectedUsers) 

        let newGroupManagementViewModel = NewGroupManagementViewModel(users: selectedUsers)

        let newGroupManagementViewController = NewGroupManagementViewController(viewModel: newGroupManagementViewModel)

        newGroupManagementViewController.chatListNeedReload = { [weak self] in
            self?.chatListNeedReload?()
        }

        if self.isSharedTicketNewGroup {
            
            newGroupManagementViewController.isSharedTicketNewGroup = true

            newGroupManagementViewController.shareChatroomsNeedReload = { [weak self] in
                self?.shareChatroomsNeedReload?()
            }
        }

        self.navigationController?.pushViewController(newGroupManagementViewController, animated: true)
    }

    @objc func didTapBackground() {
        self.searchBar.resignFirstResponder()
    }
}

//
// MARK: Delegates
//
extension NewGroupViewController: UISearchBarDelegate {

    func searchUsers(searchQuery: String = "") {

        if searchQuery != "" && searchQuery.count >= 3 {
            self.viewModel.filterSearch(searchQuery: searchQuery)
        }
        else {
            self.viewModel.resetUsers()
        }

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if let searchText = searchBar.text {
            self.searchUsers(searchQuery: searchText)
        }

    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let recentSearch = searchBar.text {

           // Do something if needed
        }

        self.searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        self.searchUsers()
    }
}

extension NewGroupViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.listUsersPublisher.value.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.viewModel.usersPublisher.value.count
            let keys = Array(self.viewModel.listUsersPublisher.value.keys)
            
            let keyForSection = keys[section]
            
            return self.viewModel.listUsersPublisher.value[keyForSection]?.count ?? 0

    }

//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        guard let cell = tableView.dequeueCellType(AddFriendTableViewCell.self)
//        else {
//            fatalError()
//        }
//
//        if let userContact = self.viewModel.usersPublisher.value[safe: indexPath.row] {
//
//            if let cellViewModel = self.viewModel.cachedFriendCellViewModels[userContact.id] {
//              
//                cell.configure(viewModel: cellViewModel)
//
//                cell.didTapCheckboxAction = { [weak self] in
//                    self?.viewModel.checkSelectedUserContact(cellViewModel: cellViewModel)
//                }
//            }
//            else {
//                let cellViewModel = AddFriendCellViewModel(userContact: userContact)
//                self.viewModel.cachedFriendCellViewModels[userContact.id] = cellViewModel
//              
//                cell.configure(viewModel: cellViewModel)
//
//                cell.didTapCheckboxAction = { [weak self] in
//                    self?.viewModel.checkSelectedUserContact(cellViewModel: cellViewModel)
//                }
//            }
//
//        }
//
//        if indexPath.row == self.viewModel.usersPublisher.value.count - 1 {
//            cell.hasSeparatorLine = false
//        }
//
//        return cell
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueCellType(GroupFriendTableViewCell.self) else {
            fatalError("Failed to dequeue GroupFriendTableViewCell")
        }

        // Get the key for the current section
        let keys = Array(self.viewModel.listUsersPublisher.value.keys)
        let keyForSection = keys[indexPath.section]

        // Get the UserContact array for this section key
        if let usersInSection = self.viewModel.listUsersPublisher.value[keyForSection],
           let userContact = usersInSection[safe: indexPath.row] {
            
            // Determine the corner type for the cell
            let cornerType: RoundCornerType
            if usersInSection.count == 1 {
                cornerType = .all
            } else if indexPath.row == 0 {
                cornerType = .top
            } else if indexPath.row == usersInSection.count - 1 {
                cornerType = .bottom
            } else {
                cornerType = .none
            }
            
            cell.roundCornerType = cornerType

            if let cellViewModel = self.viewModel.cachedFriendCellViewModels[userContact.id] {
                cell.configure(viewModel: cellViewModel)
                cell.didTapCheckboxAction = { [weak self] in
                    self?.viewModel.checkSelectedUserContact(cellViewModel: cellViewModel)
                }
            } else {
                let cellViewModel = AddFriendCellViewModel(userContact: userContact)
                self.viewModel.cachedFriendCellViewModels[userContact.id] = cellViewModel
                cell.configure(viewModel: cellViewModel)
                cell.didTapCheckboxAction = { [weak self] in
                    self?.viewModel.checkSelectedUserContact(cellViewModel: cellViewModel)
                }
            }

            if indexPath.row == usersInSection.count - 1 {
                cell.hasSeparatorLine = false
            } else {
                cell.hasSeparatorLine = true
            }
        }
                
        return cell
    }

//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        guard
//            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewGroupHeaderFooterView.identifier) as? NewGroupHeaderFooterView
//        else {
//            fatalError()
//        }
//
//        headerView.configureHeader(title: localized("add_friends_to_group"),
//                                   subtitle: localized("select_at_least_2_friends"))
//
//        return headerView
//
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ListTitleHeaderFooterView.identifier) as? ListTitleHeaderFooterView else {
            fatalError("Failed to dequeue ListTitleHeaderFooterView")
        }

        let keys = Array(self.viewModel.listUsersPublisher.value.keys)
        let titleForSection = keys[section]

        headerView.configureHeader(title: titleForSection)

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

       return 62

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return 62

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return UITableView.automaticDimension

    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

       return 40
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

}

extension NewGroupViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.alphabet.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(LetterCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }
        
        cell.configure(title: String(self.alphabet[indexPath.row]))
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 15, height: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedLetter = self.alphabet[indexPath.item]
        
        if let section = self.viewModel.listUsersPublisher.value.keys.sorted().firstIndex(of: String(selectedLetter)) {
            let indexPath = IndexPath(row: 0, section: section)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension NewGroupViewController {
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
        label.text = localized("new_group")
        return label
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("close"), for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        return button
    }

    private static func createSearchBar() -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }
    
    private static func createHeaderTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 18)
        label.textAlignment = .left
        label.text = localized("create_a_group")
        return label
    }
    
    private static func createHeaderSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textAlignment = .left
        label.text = localized("select_2_friends_for_group")
        return label
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }

    private static func createNextBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNextButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("next"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        return button
    }

    private static func createNextSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createAlphabetCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }

    private static func createEmptyStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createEmptyStateImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "no_content_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("no_friends_to_display")
        label.numberOfLines = 0
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .center
        return label
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
        self.navigationView.addSubview(self.titleLabel)
        self.navigationView.addSubview(self.closeButton)

        self.view.addSubview(self.searchBar)
        
        self.view.addSubview(self.headerTitleLabel)
        
        self.view.addSubview(self.headerSubtitleLabel)

        self.view.addSubview(self.tableView)
        
        self.view.addSubview(self.alphabetCollectionView)

        self.view.addSubview(self.nextBaseView)

        self.nextBaseView.addSubview(self.nextButton)
        self.nextBaseView.addSubview(self.nextSeparatorLineView)

        self.view.addSubview(self.emptyStateView)

        self.emptyStateView.addSubview(self.emptyStateImageView)
        self.emptyStateView.addSubview(self.emptyStateLabel)

        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.activityIndicatorView)

        self.view.addSubview(self.bottomSafeAreaView)
        
        self.view.bringSubviewToFront(self.alphabetCollectionView)

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
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

            self.closeButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -16),
            self.closeButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.closeButton.heightAnchor.constraint(equalToConstant: 40)

        ])

        // Searchbar
        NSLayoutConstraint.activate([
            self.searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8),
            self.searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8),
            self.searchBar.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 8),
            self.searchBar.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Header
        NSLayoutConstraint.activate([
            self.headerTitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            self.headerTitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            self.headerTitleLabel.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 10),
            
            self.headerSubtitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            self.headerSubtitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            self.headerSubtitleLabel.topAnchor.constraint(equalTo: self.headerTitleLabel.bottomAnchor, constant: 5)
            
        ])

        // Tableview
        NSLayoutConstraint.activate([

            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.headerSubtitleLabel.bottomAnchor, constant: 15),
            self.tableView.bottomAnchor.constraint(equalTo: self.nextBaseView.topAnchor)
        ])
        
        // Alphabet Collection View
        
        NSLayoutConstraint.activate([
            self.alphabetCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.alphabetCollectionView.topAnchor.constraint(greaterThanOrEqualTo: self.view.topAnchor, constant: 50),
            self.alphabetCollectionView.bottomAnchor.constraint(lessThanOrEqualTo: self.view.bottomAnchor, constant: -50),
            self.alphabetCollectionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.alphabetCollectionView.widthAnchor.constraint(equalToConstant: 15),
            self.alphabetCollectionView.heightAnchor.constraint(equalToConstant: CGFloat(15*self.alphabet.count))
        ])

        // Add Friend Button View
        NSLayoutConstraint.activate([
            self.nextBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.nextBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.nextBaseView.topAnchor.constraint(equalTo: self.tableView.bottomAnchor, constant: 8),
            self.nextBaseView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),
            self.nextBaseView.heightAnchor.constraint(equalToConstant: 105),

            self.nextButton.leadingAnchor.constraint(equalTo: self.nextBaseView.leadingAnchor, constant: 33),
            self.nextButton.trailingAnchor.constraint(equalTo: self.nextBaseView.trailingAnchor, constant: -33),
            self.nextButton.heightAnchor.constraint(equalToConstant: 55),
            self.nextButton.centerYAnchor.constraint(equalTo: self.nextBaseView.centerYAnchor),

            self.nextSeparatorLineView.leadingAnchor.constraint(equalTo: self.nextBaseView.leadingAnchor),
            self.nextSeparatorLineView.trailingAnchor.constraint(equalTo: self.nextBaseView.trailingAnchor),
            self.nextSeparatorLineView.topAnchor.constraint(equalTo: self.nextBaseView.topAnchor),
            self.nextSeparatorLineView.heightAnchor.constraint(equalToConstant: 1),
        ])

        // Empty state view
        NSLayoutConstraint.activate([
            self.emptyStateView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.emptyStateView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.emptyStateView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor),
            self.emptyStateView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.emptyStateImageView.topAnchor.constraint(equalTo: self.emptyStateView.topAnchor, constant: 60),
            self.emptyStateImageView.widthAnchor.constraint(equalToConstant: 120),
            self.emptyStateImageView.heightAnchor.constraint(equalTo: self.emptyStateImageView.widthAnchor),
            self.emptyStateImageView.centerXAnchor.constraint(equalTo: self.emptyStateView.centerXAnchor),

            self.emptyStateLabel.leadingAnchor.constraint(equalTo: self.emptyStateView.leadingAnchor, constant: 80),
            self.emptyStateLabel.trailingAnchor.constraint(equalTo: self.emptyStateView.trailingAnchor, constant: -80),
            self.emptyStateLabel.topAnchor.constraint(equalTo: self.emptyStateImageView.bottomAnchor, constant: 30)
        ])

        // Loading Screen
        NSLayoutConstraint.activate([
            self.loadingBaseView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor),
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor)
        ])
    }
}
