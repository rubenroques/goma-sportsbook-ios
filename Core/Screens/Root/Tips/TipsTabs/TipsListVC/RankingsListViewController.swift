//
//  RankingsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 05/09/2022.
//

import UIKit
import Combine

class RankingsListViewModel {

    enum RankingsType: Int {
        case all = 0
        case topTipsters = 1
        case friends = 2
        case followers = 3
    }

    var rankingsPublisher: CurrentValueSubject<[Ranking], Never> = .init([])
    var rankingsType: RankingsType = .all
    var rankingsCacheCellViewModel: [Int: RankingCellViewModel] = [:]
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var hasFriendsPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var rankingSelectorOptions: [RankingSelectorOption] = []
    var selectedRankingOptionPublisher: CurrentValueSubject<String, Never> = .init("")

    private var cancellables = Set<AnyCancellable>()

    init(rankingsType: RankingsType) {
        self.rankingsType = rankingsType

        self.loadRankingSelectorOptions()

        self.loadInitialRankings()
    }

    func loadInitialRankings() {

        self.isLoadingPublisher.send(true)

        self.rankingsPublisher.value = []
        self.rankingsCacheCellViewModel = [:]

        switch self.rankingsType {
        case .all:
            self.loadAllRankings()
        case .topTipsters:
            self.loadTopTipstersRankings()
        case .friends:
            self.getFriends()
        case .followers:
            self.loadFollowersRankings()
        }
    }

    private func loadRankingSelectorOptions() {
        let options: [RankingSelectorOption] = [
            RankingSelectorOption(id: 1, name: "By accumulated winning odd"),
            RankingSelectorOption(id: 2, name: "By highest odd")
        ]

        self.rankingSelectorOptions = options

        self.selectedRankingOptionPublisher.send(options[safe: 0]?.name ?? "---")
    }

    private func loadAllRankings() {

        var rankings: [Ranking] = []

        // TESTING SELECTOR

        for i in 0...3 {
            let ranking = Ranking(id: i, ranking: i+1, username: "Player_\(i+1)", score: Double((100-(i+1))))

            rankings.append(ranking)
        }

        self.rankingsPublisher.value = rankings

        self.isLoadingPublisher.send(false)

    }

    private func loadTopTipstersRankings() {

        self.isLoadingPublisher.send(false)
    }

    private func loadFriendsRankings() {

        var rankings: [Ranking] = []

        for i in 0...3 {
            let ranking = Ranking(id: i, ranking: i+1, username: "Player_Friend_\(i+1)", score: Double((100-(i+1))))

            rankings.append(ranking)
        }

        self.rankingsPublisher.value = rankings

        self.isLoadingPublisher.send(false)

    }

    private func loadFollowersRankings() {
        self.isLoadingPublisher.send(false)
    }

    private func getFriends() {

        Env.gomaNetworkClient.requestFriends(deviceId: Env.deviceId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("FRIENDS ERROR: \(error)")
                case .finished:
                    print("FRIENDS FINISHED")
                }
            }, receiveValue: { [weak self] response in
                print("FRIENDS GOMA: \(response)")
                if let friends = response.data {
                    if friends.isEmpty {
                        self?.hasFriendsPublisher.send(false)
                    }
                    else {
                        self?.hasFriendsPublisher.send(true)
                        self?.loadFriendsRankings()
                    }
                }
            })
            .store(in: &cancellables)

    }

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows() -> Int {
        return self.rankingsPublisher.value.count
    }

    func viewModel(forIndex index: Int) -> RankingCellViewModel? {
        guard
            let ranking = self.rankingsPublisher.value[safe: index]
        else {
            return nil
        }

        let rankingId = ranking.id

        if let rankingCellViewModel = rankingsCacheCellViewModel[rankingId] {
            return rankingCellViewModel
        }
        else {
            let rankingCellViewModel = RankingCellViewModel(ranking: ranking)
            self.rankingsCacheCellViewModel[rankingId] = rankingCellViewModel
            return rankingCellViewModel
        }
    }

    func setSelectedRankingOptions(option: String) {
        self.selectedRankingOptionPublisher.send(option)
    }
}

class RankingsListViewController: UIViewController {

    // MARK: Private properties
    private lazy var rankingSelectorBaseView: UIView = Self.createRankingSelectorBaseView()
    private lazy var rankingSelectorLabel: UILabel = Self.createRankingSelectorLabel()
    private lazy var rankingSelectorImageView: UIImageView = Self.createRankingSelectorImageView()
    private lazy var rankingOptionsSelectorBaseView: UIView = Self.createRankingOptionsSelectorBaseView()
    private lazy var rankingOptionsSelectorContainerView: UIView = Self.createRankingOptionsSelectorContainerView()
    private lazy var rankingOptionsPickerView: UIPickerView = Self.createRankingOptionsPickerView()
    private lazy var rankingOptionsSelectButton: UIButton = Self.createRankingOptionsSelectButton()
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

    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: RankingsListViewModel
    private var filterSelectedOption: Int = 0

    var showRankingOptionSelector: Bool = false {
        didSet {
            self.rankingOptionsSelectorBaseView.isHidden = !showRankingOptionSelector
        }
    }

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
    init(viewModel: RankingsListViewModel = RankingsListViewModel(rankingsType: .all)) {
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

        self.tableView.register(RankingTableViewCell.self, forCellReuseIdentifier: RankingTableViewCell.identifier)

        self.rankingOptionsPickerView.delegate = self
        self.rankingOptionsPickerView.dataSource = self

        self.isLoading = false

        self.isEmptyState = false
        self.isEmptyFriends = false
        self.showRankingOptionSelector = false

        self.bind(toViewModel: self.viewModel)

        let tapRankingSelector = UITapGestureRecognizer(target: self, action: #selector(didTapRankingSelector))
        self.rankingSelectorBaseView.addGestureRecognizer(tapRankingSelector)

        self.rankingOptionsSelectButton.addTarget(self, action: #selector(didTapRankingOptionsSelectButton), for: .primaryActionTriggered)

    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.rankingSelectorBaseView.layer.borderWidth = 1
        self.rankingSelectorBaseView.layer.cornerRadius = CornerRadius.button
        self.rankingSelectorBaseView.layer.masksToBounds = true

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.rankingSelectorBaseView.backgroundColor = UIColor.App.inputBackground
        self.rankingSelectorBaseView.layer.borderColor = UIColor.App.inputBorderActive.cgColor

        self.rankingSelectorLabel.textColor = UIColor.App.buttonTextPrimary

        self.rankingSelectorImageView.backgroundColor = .clear

        self.rankingOptionsSelectorBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.8)

        self.rankingOptionsSelectorContainerView.backgroundColor = UIColor.App.backgroundPrimary

        self.rankingOptionsPickerView.backgroundColor = .clear

        StyleHelper.styleButton(button: self.rankingOptionsSelectButton)

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary
        self.tableView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary

        self.emptyStateBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.emptyStateLabel.textColor = UIColor.App.textPrimary

        self.emptyStateSecondaryLabel.textColor = UIColor.App.textPrimary

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.loadingActivityIndicatorView.color = UIColor.lightGray

        self.emptyFriendsBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.emptyFriendsTitleLabel.textColor = UIColor.App.textPrimary

        self.emptyFriendsSubtitleLabel.textColor = UIColor.App.textPrimary

        StyleHelper.styleButton(button: self.emptyFriendsButton)

    }

    // MARK: Functions
    private func showUserProfile() {
        print("SHOW USER PROFILE!")
    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: RankingsListViewModel) {

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

        viewModel.selectedRankingOptionPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] selectedRankingOption in
                self?.rankingSelectorLabel.text = selectedRankingOption
            })
            .store(in: &cancellables)
    }

    // MARK: Actions
    @objc func didTapRankingSelector() {
        self.showRankingOptionSelector = true
    }

    @objc func didTapRankingOptionsSelectButton() {
        self.showRankingOptionSelector = false

        self.viewModel.loadInitialRankings()
    }

    private func handleFollowUserAction(indexPath: IndexPath) {

        print("FOLLOW USER!")

    }

}

//
// MARK: PickerView Protocols
//
extension RankingsListViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return self.viewModel.rankingSelectorOptions.count

    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: self.viewModel.rankingSelectorOptions[safe: row]?.name ?? "--",
                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.App.textPrimary])

    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let selectedRankingOption = self.viewModel.rankingSelectorOptions[safe: row] {

            self.viewModel.setSelectedRankingOptions(option: selectedRankingOption.name)

        }

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
            let cell = tableView.dequeueReusableCell(withIdentifier: RankingTableViewCell.identifier, for: indexPath) as? RankingTableViewCell,
            let cellViewModel = self.viewModel.viewModel(forIndex: indexPath.row)
        else {
            fatalError("RankingTableViewCell not found")
        }

        cell.configure(viewModel: cellViewModel)

        cell.shouldShowUserProfile = { [weak self] in
            self?.showUserProfile()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let followUserAction = UIContextualAction(style: .normal,
                                        title: localized("follow_user")) { [weak self] (action, view, completionHandler) in
            self?.handleFollowUserAction(indexPath: indexPath)
                                            completionHandler(true)
        }

        followUserAction.backgroundColor = UIColor.App.backgroundSecondary

        let configuration = UISwipeActionsConfiguration(actions: [followUserAction])

        configuration.performsFirstActionWithFullSwipe = false

        return configuration
    }

    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension RankingsListViewController {

    private static func createRankingSelectorBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createRankingSelectorLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Select ranking type..."
        label.font = AppFont.with(type: .medium, size: 16)
        label.numberOfLines = 1
        return label
    }

    private static func createRankingSelectorImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "arrow_down_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createRankingOptionsSelectorBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createRankingOptionsSelectorContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createRankingOptionsPickerView() -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }

    private static func createRankingOptionsSelectButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("select"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 18)
        return button
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
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
        label.text = "There’s no rankings here!"
        return label
    }

    private static func createEmptyStateSecondaryLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 16)
        label.numberOfLines = 4
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "There are no rankings currently to be displayed."
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

    private func setupSubviews() {

        self.view.addSubview(self.rankingSelectorBaseView)

        self.rankingSelectorBaseView.addSubview(self.rankingSelectorLabel)
        self.rankingSelectorBaseView.addSubview(self.rankingSelectorImageView)

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.rankingOptionsSelectorBaseView)

        self.rankingOptionsSelectorBaseView.addSubview(self.rankingOptionsSelectorContainerView)

        self.rankingOptionsSelectorContainerView.addSubview(self.rankingOptionsPickerView)
        self.rankingOptionsSelectorContainerView.addSubview(self.rankingOptionsSelectButton)

        self.view.addSubview(self.emptyStateBaseView)

        self.emptyStateBaseView.addSubview(self.emptyStateImageView)
        self.emptyStateBaseView.addSubview(self.emptyStateLabel)
        self.emptyStateBaseView.addSubview(self.emptyStateSecondaryLabel)

        self.view.addSubview(self.emptyFriendsBaseView)

        self.emptyFriendsBaseView.addSubview(self.emptyFriendsImageView)
        self.emptyFriendsBaseView.addSubview(self.emptyFriendsTitleLabel)
        self.emptyFriendsBaseView.addSubview(self.emptyFriendsSubtitleLabel)
        self.emptyFriendsBaseView.addSubview(self.emptyFriendsButton)

        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.rankingSelectorBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            self.rankingSelectorBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            self.rankingSelectorBaseView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20),

            self.rankingSelectorLabel.leadingAnchor.constraint(equalTo: self.rankingSelectorBaseView.leadingAnchor, constant: 19),
            self.rankingSelectorLabel.topAnchor.constraint(equalTo: self.rankingSelectorBaseView.topAnchor, constant: 8),
            self.rankingSelectorLabel.bottomAnchor.constraint(equalTo: self.rankingSelectorBaseView.bottomAnchor, constant: -8),

            self.rankingSelectorImageView.trailingAnchor.constraint(equalTo: self.rankingSelectorBaseView.trailingAnchor, constant: -19),
            self.rankingSelectorImageView.widthAnchor.constraint(equalToConstant: 12),
            self.rankingSelectorImageView.heightAnchor.constraint(equalToConstant: 10),
            self.rankingSelectorImageView.centerYAnchor.constraint(equalTo: self.rankingSelectorLabel.centerYAnchor)
        ])

        NSLayoutConstraint.activate([

            self.rankingOptionsSelectorBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.rankingOptionsSelectorBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.rankingOptionsSelectorBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.rankingOptionsSelectorBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.rankingOptionsSelectorContainerView.leadingAnchor.constraint(equalTo: self.rankingOptionsSelectorBaseView.leadingAnchor),
            self.rankingOptionsSelectorContainerView.trailingAnchor.constraint(equalTo: self.rankingOptionsSelectorBaseView.trailingAnchor),
            self.rankingOptionsSelectorContainerView.bottomAnchor.constraint(equalTo: self.rankingOptionsSelectorBaseView.bottomAnchor),

            self.rankingOptionsPickerView.leadingAnchor.constraint(equalTo: self.rankingOptionsSelectorContainerView.leadingAnchor),
            self.rankingOptionsPickerView.trailingAnchor.constraint(equalTo: self.rankingOptionsSelectorContainerView.trailingAnchor),
            self.rankingOptionsPickerView.topAnchor.constraint(equalTo: self.rankingOptionsSelectorContainerView.topAnchor),
            self.rankingOptionsPickerView.bottomAnchor.constraint(equalTo: self.rankingOptionsSelectButton.topAnchor),

            self.rankingOptionsSelectButton.leadingAnchor.constraint(equalTo: self.rankingOptionsSelectorContainerView.leadingAnchor, constant: 22),
            self.rankingOptionsSelectButton.trailingAnchor.constraint(equalTo: self.rankingOptionsSelectorContainerView.trailingAnchor, constant: -22),
            self.rankingOptionsSelectButton.heightAnchor.constraint(equalToConstant: 50),
            self.rankingOptionsSelectButton.bottomAnchor.constraint(equalTo: self.rankingOptionsSelectorContainerView.bottomAnchor, constant: -8)
        ])

        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.rankingSelectorBaseView.bottomAnchor, constant: 10),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10)
        ])

        // Empty state view
        NSLayoutConstraint.activate([
            self.emptyStateBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.emptyStateBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.emptyStateBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.emptyStateBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.emptyStateImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.emptyStateImageView.topAnchor.constraint(equalTo: self.emptyFriendsBaseView.topAnchor, constant: 45),
            self.emptyStateImageView.widthAnchor.constraint(equalToConstant: 120),
            self.emptyStateImageView.heightAnchor.constraint(equalToConstant: 120),

            self.emptyStateLabel.leadingAnchor.constraint(equalTo: self.emptyStateBaseView.leadingAnchor, constant: 35),
            self.emptyStateLabel.trailingAnchor.constraint(equalTo: self.emptyStateBaseView.trailingAnchor, constant: -35),
            self.emptyStateLabel.topAnchor.constraint(equalTo: self.emptyStateImageView.bottomAnchor, constant: 24),

            self.emptyStateSecondaryLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 35),
            self.emptyStateSecondaryLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -35),
            self.emptyStateSecondaryLabel.topAnchor.constraint(equalTo: self.emptyStateLabel.bottomAnchor, constant: 16)
        ])

        // Loading view
        NSLayoutConstraint.activate([
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),

            self.view.leadingAnchor.constraint(equalTo: self.loadingBaseView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.loadingBaseView.trailingAnchor),
            self.view.topAnchor.constraint(equalTo: self.loadingBaseView.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.loadingBaseView.bottomAnchor)
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

struct RankingSelectorOption {
    var id: Int
    var name: String
}
