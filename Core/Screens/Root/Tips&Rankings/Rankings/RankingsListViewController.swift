//
//  RankingsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 05/09/2022.
//

import UIKit
import Combine

class RankingsListViewController: UIViewController {

    // MARK: Private properties
    private lazy var hidenPickerPlaceholderTextField: UITextField = Self.createPickerPlaceholderTextField()
    
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()
    private lazy var emptyStateBaseView: UIView = Self.createEmptyStateBaseView()
    private lazy var emptyStateImageView: UIImageView = Self.createEmptyStateImageView()
    private lazy var emptyStateLabel: UILabel = Self.createEmptyStateLabel()
    private lazy var emptyStateSecondaryLabel: UILabel = Self.createEmptyStateSecondaryLabel()

    private lazy var emptyFriendsBaseView: UIView = Self.createEmptyFriendsBaseView()
    private lazy var emptyFriendsImageView: UIImageView = Self.createEmptyFriendsImageView()
    private lazy var emptyFriendsTitleLabel: UILabel = Self.createEmptyFriendsTitleLabel()
    private lazy var emptyFriendsSubtitleLabel: UILabel = Self.createEmptyFriendsSubtitleLabel()
    private lazy var emptyFriendsButton: UIButton = Self.createEmptyFriendsButton()

    private lazy var pickerBaseView: UIView = Self.createPickerBaseView()
    private lazy var pickerDoneButton: UIButton = Self.createPickerDoneButton()
    private lazy var pickerView: UIPickerView = Self.createPickerView()
    
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: RankingsListViewModel
    private var filterSelectedOption: Int = 0

    private let pickerOptionsArray = RankingsListViewModel.SortType.allCases
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.loadingBaseView.isHidden = false
                self.loadingActivityIndicatorView.startAnimating()
            }
            else {
                self.loadingBaseView.isHidden = true
                self.loadingActivityIndicatorView.stopAnimating()
            }
        }
    }

    var isEmptyState: Bool = false {
        didSet {
            self.emptyStateBaseView.isHidden = !isEmptyState
        }
    }

    var isEmptyFriends: Bool = false {
        didSet {
            self.emptyFriendsBaseView.isHidden = !isEmptyFriends
        }
    }

    // MARK: - Lifetime and Cycle
    init(viewModel: RankingsListViewModel = RankingsListViewModel(rankingsType: .topTipsters)) {
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
        
        self.hidenPickerPlaceholderTextField.inputView = self.pickerView
        
        self.tableView.register(UserRankingPositionTableViewCell.self, forCellReuseIdentifier: UserRankingPositionTableViewCell.identifier)
        self.tableView.register(RankingTypeTableHeaderView.self, forHeaderFooterViewReuseIdentifier: RankingTypeTableHeaderView.identifier)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.isHidden = false
        self.emptyStateBaseView.isHidden = true

        self.isLoading = false
        self.isEmptyState = false
        self.isEmptyFriends = false

        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerBaseView.alpha = 0.0
        
        self.configure(withViewModel: self.viewModel)

        self.emptyFriendsButton.addTarget(self, action: #selector(didTapAddFriendButton), for: .primaryActionTriggered)
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
        self.tableView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary

        self.emptyStateBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.emptyStateLabel.textColor = UIColor.App.textPrimary
        self.emptyStateSecondaryLabel.textColor = UIColor.App.textPrimary

        self.loadingBaseView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.loadingActivityIndicatorView.color = UIColor.lightGray

        self.pickerView.backgroundColor = UIColor.App.backgroundSecondary
     
        StyleHelper.styleButton(button: self.pickerDoneButton)

        self.emptyFriendsBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.emptyFriendsTitleLabel.textColor = UIColor.App.textPrimary

        self.emptyFriendsSubtitleLabel.textColor = UIColor.App.textPrimary

        StyleHelper.styleButton(button: self.emptyFriendsButton)
    }

    func configure(withViewModel viewModel: RankingsListViewModel) {
        
        viewModel
            .sortTypePublisher
            .sink {[weak self] _ in
                self?.viewModel.reloadRankings()
            }
            .store(in: &cancellables)

        viewModel.rankingsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] rankings in
                self?.isEmptyState = rankings.isEmpty
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                self?.isLoading = isLoading
            })
            .store(in: &cancellables)

        viewModel.hasFriendsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] hasFriends in
                if viewModel.rankingsType == .friends {
                    self?.isEmptyFriends = !hasFriends
                }
            })
            .store(in: &cancellables)
    }

    // MARK: Actions
    @objc private func didTapAddFriendButton() {
        let addFriendViewModel = AddFriendViewModel()

        let addFriendViewController = AddFriendViewController(viewModel: addFriendViewModel)

        self.navigationController?.pushViewController(addFriendViewController, animated: true)

    }
    
}

//
// MARK: - TableView Protocols
//
extension RankingsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueCellType(UserRankingPositionTableViewCell.self),
            let cellViewModel = self.viewModel.viewModel(forIndex: indexPath.row)
        else {
            fatalError()
        }

        cell.configure(viewModel: cellViewModel)
        
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: RankingTypeTableHeaderView.identifier)
                as? RankingTypeTableHeaderView
        else {
            fatalError()
        }
        
        let sortType = self.viewModel.sortTypePublisher.value.title
        headerView.configureWithTitle(sortType)
        
        headerView.tapAction = { [weak self] in
            self?.showFilterOptions()
        }
        
        return headerView
    }
}

extension RankingsListViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func showFilterOptions() {
        
        let pickerAccessory = UIToolbar()
        pickerAccessory.autoresizingMask = .flexibleHeight
        pickerAccessory.barStyle = .default
        pickerAccessory.isTranslucent = false
        pickerAccessory.barStyle = .default
        pickerAccessory.barTintColor = UIColor.App.backgroundPrimary
        pickerAccessory.backgroundColor = UIColor.App.backgroundPrimary
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.hideFilterOptions))
        doneButton.tintColor = UIColor.App.textPrimary

        pickerAccessory.items = [flexSpace, doneButton]
                                         
        self.hidenPickerPlaceholderTextField.inputAccessoryView = pickerAccessory
        
        self.pickerBaseView.alpha = 1.0
        self.hidenPickerPlaceholderTextField.becomeFirstResponder()
    }
    
    @objc func hideFilterOptions() {
        self.pickerBaseView.alpha = 0.0
        self.hidenPickerPlaceholderTextField.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerOptionsArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerOptionsArray[safe: row]?.title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.viewModel.selectSortTypeForIndex(row)
    }
    
}

//
// MARK: - Subviews Initialization and Setup
//
extension RankingsListViewController {

    private static func createPickerPlaceholderTextField() -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
 
        return textField
    }
    
    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.allowsSelection = false
        return tableView
    }

    private static func createEmptyStateBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createEmptyStateImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "no_content_icon")
        return imageView
    }

    private static func createEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 22)
        label.numberOfLines = 4
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("no_rankings")
        return label
    }

    private static func createEmptyStateSecondaryLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 16)
        label.numberOfLines = 4
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("no_rankings_to_display")
        return label
    }

    private static func createEmptyFriendsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createEmptyFriendsImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "add_friend_empty_icon")
        return imageView
    }

    private static func createEmptyFriendsTitleLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("time_add_friends")
        label.textAlignment = .center
        return label
    }

    private static func createEmptyFriendsSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = AppFont.with(type: .semibold, size: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("add_friends_tip")
        label.textAlignment = .center
        return label
    }

    private static func createEmptyFriendsButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        button.setTitle(localized("add_friends"), for: .normal)
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
    
    private static func createPickerBaseView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createPickerView() -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }
    
    private static func createPickerDoneButton() -> UIButton {
        let button = UIButton.init()
        
        button.setTitle("Select", for: .normal)
        return button
    }
    
    private func setupSubviews() {

        self.view.addSubview(self.hidenPickerPlaceholderTextField)
        
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.emptyStateBaseView)
        self.view.addSubview(self.pickerBaseView)
        
        self.view.addSubview(self.loadingBaseView)

        self.emptyStateBaseView.addSubview(self.emptyStateImageView)
        self.emptyStateBaseView.addSubview(self.emptyStateLabel)
        self.emptyStateBaseView.addSubview(self.emptyStateSecondaryLabel)

        self.view.addSubview(self.emptyFriendsBaseView)

        self.emptyFriendsBaseView.addSubview(self.emptyFriendsImageView)
        self.emptyFriendsBaseView.addSubview(self.emptyFriendsTitleLabel)
        self.emptyFriendsBaseView.addSubview(self.emptyFriendsSubtitleLabel)
        self.emptyFriendsBaseView.addSubview(self.emptyFriendsButton)

        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)
        
        // self.pickerBaseView.addSubview(self.pickerView)
        // self.pickerBaseView.addSubview(self.pickerDoneButton)
        
        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.hidenPickerPlaceholderTextField.widthAnchor.constraint(equalToConstant: 20),
            self.hidenPickerPlaceholderTextField.heightAnchor.constraint(equalToConstant: 20),
            self.hidenPickerPlaceholderTextField.leadingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 20),
        ])
            
        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.emptyStateBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.emptyStateBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.emptyStateBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.emptyStateBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.emptyStateLabel.centerXAnchor.constraint(equalTo: self.emptyStateBaseView.centerXAnchor),
            self.emptyStateLabel.topAnchor.constraint(equalTo: self.emptyStateImageView.bottomAnchor, constant: 24),

            self.emptyStateSecondaryLabel.centerYAnchor.constraint(equalTo: self.emptyStateBaseView.centerYAnchor),

            self.emptyStateImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.emptyStateImageView.widthAnchor.constraint(equalToConstant: 120),
            self.emptyStateImageView.heightAnchor.constraint(equalToConstant: 120),

            self.emptyStateSecondaryLabel.centerXAnchor.constraint(equalTo: self.emptyStateBaseView.centerXAnchor),
            self.emptyStateSecondaryLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.emptyStateSecondaryLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            self.emptyStateSecondaryLabel.topAnchor.constraint(equalTo: self.emptyStateLabel.bottomAnchor, constant: 16)
        ])

        NSLayoutConstraint.activate([
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),

            self.view.leadingAnchor.constraint(equalTo: self.loadingBaseView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.loadingBaseView.trailingAnchor),
            self.view.topAnchor.constraint(equalTo: self.loadingBaseView.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.loadingBaseView.bottomAnchor)
        ])
 
        NSLayoutConstraint.activate([
            self.pickerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.pickerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.pickerBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.pickerBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            /*
            self.pickerDoneButton.leadingAnchor.constraint(equalTo: self.pickerBaseView.leadingAnchor, constant: 22),
            self.pickerDoneButton.trailingAnchor.constraint(equalTo: self.pickerBaseView.trailingAnchor, constant: -22),
            self.pickerDoneButton.widthAnchor.constraint(equalToConstant: 50),
            self.pickerDoneButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            self.pickerView.leadingAnchor.constraint(equalTo: self.pickerBaseView.leadingAnchor),
            self.pickerView.trailingAnchor.constraint(equalTo: self.pickerBaseView.trailingAnchor),
            self.pickerView.bottomAnchor.constraint(equalTo: self.pickerDoneButton.topAnchor, constant: 8),
            */
        ])

        // Empty friends view
        NSLayoutConstraint.activate([
            self.emptyFriendsBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.emptyFriendsBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.emptyFriendsBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.emptyFriendsBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.emptyFriendsImageView.centerXAnchor.constraint(equalTo: self.emptyFriendsBaseView.centerXAnchor),
            self.emptyFriendsImageView.widthAnchor.constraint(equalToConstant: 112),
            self.emptyFriendsImageView.heightAnchor.constraint(equalToConstant: 112),
            self.emptyFriendsImageView.topAnchor.constraint(equalTo: self.emptyFriendsBaseView.topAnchor, constant: 45),

            self.emptyFriendsTitleLabel.leadingAnchor.constraint(equalTo: self.emptyFriendsBaseView.leadingAnchor, constant: 35),
            self.emptyFriendsTitleLabel.trailingAnchor.constraint(equalTo: self.emptyFriendsBaseView.trailingAnchor, constant: -35),
            self.emptyFriendsTitleLabel.topAnchor.constraint(equalTo: self.emptyFriendsImageView.bottomAnchor, constant: 40),

            self.emptyFriendsSubtitleLabel.leadingAnchor.constraint(equalTo: self.emptyFriendsBaseView.leadingAnchor, constant: 35),
            self.emptyFriendsSubtitleLabel.trailingAnchor.constraint(equalTo: self.emptyFriendsBaseView.trailingAnchor, constant: -35),
            self.emptyFriendsSubtitleLabel.topAnchor.constraint(equalTo: self.emptyFriendsTitleLabel.bottomAnchor, constant: 18),

            self.emptyFriendsButton.leadingAnchor.constraint(equalTo: self.emptyFriendsBaseView.leadingAnchor, constant: 35),
            self.emptyFriendsButton.trailingAnchor.constraint(equalTo: self.emptyFriendsBaseView.trailingAnchor, constant: -35),
            self.emptyFriendsButton.topAnchor.constraint(equalTo: self.emptyFriendsSubtitleLabel.bottomAnchor, constant: 30),
            self.emptyFriendsButton.heightAnchor.constraint(equalToConstant: 50)
        ])

    }

}
