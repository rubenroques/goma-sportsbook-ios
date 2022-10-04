//
//  UserProfileTipsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 20/09/2022.
//

import UIKit
import Combine

class UserProfileTipsViewController: UIViewController {

    // MARK: Private properties
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()
    private lazy var emptyStateBaseView: UIView = Self.createEmptyStateBaseView()
    private lazy var emptyStateImageView: UIImageView = Self.createEmptyStateImageView()
    private lazy var emptyStateLabel: UILabel = Self.createEmptyStateLabel()
    private lazy var emptyStateSecondaryLabel: UILabel = Self.createEmptyStateSecondaryLabel()

    private var viewModel: UserProfileTipsViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public properties
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

    // MARK: - Lifetime and Cycle
    init(viewModel: UserProfileTipsViewModel) {

        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        self.title = localized("latest_tips")

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

        self.tableView.register(TipsTableViewCell.self, forCellReuseIdentifier: TipsTableViewCell.identifier)
        self.tableView.register(LoadingMoreTableViewCell.nib, forCellReuseIdentifier: LoadingMoreTableViewCell.identifier)

        self.isLoading = false

        self.isEmptyState = false

        self.bind(toViewModel: self.viewModel)

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

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.loadingActivityIndicatorView.color = UIColor.lightGray
    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: UserProfileTipsViewModel) {

        viewModel.userTipsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] tips in
                self?.isEmptyState = tips.isEmpty
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                self?.isLoading = isLoading
            })
            .store(in: &cancellables)

        Env.gomaSocialClient.followingUsersPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)
    }

    // MARK: Functions
    private func showBetslip() {
        let betslipViewController = BetslipViewController()
        let navigationViewController = Router.navigationController(with: betslipViewController)

        self.navigationController?.present(navigationViewController, animated: true, completion: nil)
    }

}

//
// MARK: - TableView Protocols
//
extension UserProfileTipsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.viewModel.numberOfRows()
        case 1:
            return self.viewModel.tipsHasNextPage ? 1 : 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: TipsTableViewCell.identifier, for: indexPath) as? TipsTableViewCell,
                let cellViewModel = self.viewModel.viewModel(forIndex: indexPath.row)
            else {
                fatalError("TipsTableViewCell not found")
            }

            cell.configure(viewModel: cellViewModel, followingUsers: Env.gomaSocialClient.followingUsersPublisher.value)

            cell.shouldShowBetslip = { [weak self] in
                //self?.shouldShowBetslip?()
                self?.showBetslip()
            }

            return cell
        case 1:
            guard
                let cell = tableView.dequeueCellType(LoadingMoreTableViewCell.self)
            else {
                fatalError("LoadingMoreTableViewCell not found")
            }
            return cell
        default:
            fatalError()
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return UITableView.automaticDimension
        case 1:
            return 70
        default:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1, self.viewModel.userTipsPublisher.value.isNotEmpty {
            if let typedCell = cell as? LoadingMoreTableViewCell {
                typedCell.startAnimating()
            }
            self.viewModel.requestNextPageTips()
        }
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension UserProfileTipsViewController {

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
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "There’s no tips here!"
        label.textAlignment = .center
        return label
    }

    private static func createEmptyStateSecondaryLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "There are no tips currently to be displayed."
        label.textAlignment = .center
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

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.emptyStateBaseView)

        self.emptyStateBaseView.addSubview(self.emptyStateImageView)
        self.emptyStateBaseView.addSubview(self.emptyStateLabel)
        self.emptyStateBaseView.addSubview(self.emptyStateSecondaryLabel)

        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.initConstraints()
    }

    private func initConstraints() {

        // Tableview
        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        // Empty state view
        NSLayoutConstraint.activate([
            self.emptyStateBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.emptyStateBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.emptyStateBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.emptyStateBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.emptyStateImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.emptyStateImageView.topAnchor.constraint(equalTo: self.emptyStateBaseView.topAnchor, constant: 45),
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

    }

}
