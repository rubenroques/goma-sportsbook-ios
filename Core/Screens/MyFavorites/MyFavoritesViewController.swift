//
//  MyFavoritesViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 10/02/2022.
//

import UIKit
import Combine

class MyFavoritesViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var topSliderCollectionView: UICollectionView = Self.createTopSliderCollectionView()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var loadingScreenBaseView: UIView = Self.createLoadingScreenBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()
    private lazy var betslipButtonView: UIView = Self.createBetslipButtonView()
    private lazy var betslipCountLabel: UILabel = Self.createBetslipCountLabel()
    private lazy var emptyStateView: UIView = Self.createEmptyStateView()
    private lazy var emptyStateImageView: UIImageView = Self.createEmptyStateImageView()
    private lazy var emptyStateTitleLabel: UILabel = Self.createEmptyStateTitleLabel()
    private lazy var emptyStateLoginButton: UIButton = Self.createEmptyStateLoginButton()
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: MyFavoritesViewModel
    var filterSelectedOption: Int = 0

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.loadingScreenBaseView.isHidden = false
                self.tableView.isHidden = true
            }
            else {
                self.loadingScreenBaseView.isHidden = true
                self.tableView.isHidden = false
            }
        }
    }

    var isEmptyState: Bool = false {
        didSet {
            if isEmptyState {
                self.tableView.isHidden = true
                self.emptyStateView.isHidden = false
            }
            else {
                self.tableView.isHidden = false
                self.emptyStateView.isHidden = true
            }
        }
    }

    // MARK: Lifetime and Cycle
    init() {
        self.viewModel = MyFavoritesViewModel()
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
        self.bind(toViewModel: self.viewModel)

        self.isLoading = true
        self.isEmptyState = false

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)

        self.betslipCountLabel.isHidden = true

        let tapBetslipView = UITapGestureRecognizer(target: self, action: #selector(didTapBetslipView))
        betslipButtonView.addGestureRecognizer(tapBetslipView)
        
        self.viewModel.didTapFavoriteMatchAction = { match in
            if !UserSessionStore.isUserLogged() {
                self.presentLoginViewController()
            }
            else {
                self.viewModel.markAsFavorite(match: match)
                self.tableView.reloadData()
            }
        }
        
       self.viewModel.didTapFavoriteCompetitionAction = { competition in
            if !UserSessionStore.isUserLogged() {
                self.presentLoginViewController()
            }
            else {
                self.viewModel.markCompetitionAsFavorite(competition: competition)
                self.tableView.reloadData()
            }
        }
        
        


        self.emptyStateLoginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)

    }

    private func setupEmptyStateView(emptyStateType: EmptyStateType, hasLogin: Bool = false) {

        switch emptyStateType {
        case .noLogin:
            self.emptyStateTitleLabel.text = localized("need_login_favorites")
            self.isEmptyState = true
        case .noGames:
            self.emptyStateTitleLabel.text = localized("empty_my_games")
            if self.viewModel.favoriteListTypePublisher.value == .favoriteGames {
                self.isEmptyState = true
            }
            else {
                self.isEmptyState = false
            }
        case .noCompetitions:
            self.emptyStateTitleLabel.text = localized("empty_my_competitions")
            if self.viewModel.favoriteListTypePublisher.value == .favoriteCompetitions {
                self.isEmptyState = true
            }
            else {
                self.isEmptyState = false
            }
        case .noFavorites:
            if self.viewModel.favoriteListTypePublisher.value == .favoriteGames {
                self.emptyStateTitleLabel.text = localized("empty_my_games")
                self.isEmptyState = true
            }
            else if self.viewModel.favoriteListTypePublisher.value == .favoriteCompetitions {
                self.emptyStateTitleLabel.text = localized("empty_my_competitions")
                self.isEmptyState = true
            }
        case .none:
            self.isEmptyState = false
        }

        if hasLogin {
            self.emptyStateLoginButton.isHidden = false
        }
        else {
            self.emptyStateLoginButton.isHidden = true
        }
    }

    // MARK: Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.betslipButtonView.layer.cornerRadius = self.betslipButtonView.frame.height / 2
        self.betslipCountLabel.layer.cornerRadius = self.betslipCountLabel.frame.height / 2
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topSafeAreaView.backgroundColor = .clear

        self.topView.backgroundColor = .clear

        self.backButton.tintColor = UIColor.App.textHeadlinePrimary

        self.topTitleLabel.textColor = UIColor.App.textPrimary

        self.topSliderCollectionView.backgroundColor = UIColor.App.backgroundSecondary

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary

        self.loadingScreenBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.emptyStateView.backgroundColor = UIColor.App.backgroundPrimary

        self.betslipCountLabel.backgroundColor = UIColor.App.alertError
        self.betslipCountLabel.textColor = UIColor.App.buttonTextPrimary

        self.betslipButtonView.backgroundColor = UIColor.App.highlightPrimary
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: MyFavoritesViewModel) {

        viewModel.dataChangedPublisher
            .receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] in
                self?.tableView.reloadData()
                self?.isLoading = false
            })
            .store(in: &cancellables)

        viewModel.didSelectMatchAction = { match in
            let matchDetailsViewController = MatchDetailsViewController(viewModel: MatchDetailsViewModel(match: match))
            self.present(matchDetailsViewController, animated: true, completion: nil)
        }

        viewModel.emptyStateStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] emptyStateType in
                switch emptyStateType {
                case .noLogin:
                    self?.setupEmptyStateView(emptyStateType: emptyStateType, hasLogin: true)
                case .noGames:
                    self?.setupEmptyStateView(emptyStateType: emptyStateType)
                case .noCompetitions:
                    self?.setupEmptyStateView(emptyStateType: emptyStateType)
                case .noFavorites:
                    self?.setupEmptyStateView(emptyStateType: emptyStateType)
                case .none:
                    ()
                }
            })
            .store(in: &cancellables)

        Env.betslipManager.bettingTicketsPublisher
            .map(\.count)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] betslipValue in
                if betslipValue == 0 {
                    self?.betslipCountLabel.isHidden = true
                }
                else {
                    self?.betslipCountLabel.text = "\(betslipValue)"
                    self?.betslipCountLabel.isHidden = false
                }
            })
            .store(in: &cancellables)

    }

    // MARK: Functions
    func openBetslipModal() {
        let betslipViewController = BetslipViewController()
        betslipViewController.willDismissAction = { [weak self] in
            self?.tableView.reloadData()
        }

        self.present(Router.navigationController(with: betslipViewController), animated: true, completion: nil)
    }
    
    func presentLoginViewController() {
      let loginViewController = Router.navigationController(with: LoginViewController())
      self.present(loginViewController, animated: true, completion: nil)
    }

}

//
// MARK: CollectionView Protocols
extension MyFavoritesViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }

        switch indexPath.row {
        case 0:
            cell.setupWithTitle(localized("my_games"))
        case 1:
            cell.setupWithTitle(localized("my_competitions"))
        default:
            ()
        }

        if filterSelectedOption == indexPath.row {
            cell.setSelectedType(true)
        }
        else {
            cell.setSelectedType(false)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        self.filterSelectedOption = indexPath.row

        switch indexPath.row {
        case 0:
            ()
            self.viewModel.setFavoriteListType(.favoriteGames)

        case 1:
            ()
            self.viewModel.setFavoriteListType(.favoriteCompetitions)

        default:
            ()
        }
        self.topSliderCollectionView.reloadData()
        self.topSliderCollectionView.layoutIfNeeded()
        self.topSliderCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

    }

}

//
// MARK: TableView Protocols
extension MyFavoritesViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections(in: tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.tableView(tableView, numberOfRowsInSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.viewModel.tableView(tableView, cellForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        return self.viewModel.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.viewModel.tableView(tableView, viewForHeaderInSection: section)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.tableView(tableView, heightForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.tableView(tableView, estimatedHeightForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.viewModel.tableView(tableView, heightForHeaderInSection: section)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.viewModel.tableView(tableView, estimatedHeightForHeaderInSection: section)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}

//
// MARK: - Actions
//
extension MyFavoritesViewController {
    @objc private func didTapBackButton() {

        self.navigationController?.popViewController(animated: true)

    }

    @objc func didTapBetslipView() {
        self.openBetslipModal()
    }

    @objc func didTapLoginButton() {
        let loginViewController = LoginViewController()

        self.present(loginViewController, animated: true, completion: nil)

        self.navigationController?.popViewController(animated: true)
    }
}

//
// MARK: Subviews initialization and setup
//
extension MyFavoritesViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

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
        label.text = localized("my_favorites")
        label.font = AppFont.with(type: .bold, size: 17)
        label.textAlignment = .center
        return label
    }

    private static func createTopSliderCollectionView() -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true

        return collectionView
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never

        return tableView
    }

    private static func createLoadingScreenBaseView() -> UIView {
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

    private static func createBetslipButtonView() -> UIView {
        let betslipButtonView = UIView()
        betslipButtonView.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(named: "betslip_button_icon")
        betslipButtonView.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            betslipButtonView.widthAnchor.constraint(equalToConstant: 56),
            betslipButtonView.widthAnchor.constraint(equalTo: betslipButtonView.heightAnchor),

            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: betslipButtonView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: betslipButtonView.centerYAnchor),
        ])

        return betslipButtonView
    }

    private static func createBetslipCountLabel() -> UILabel {
        let betslipCountLabel = UILabel()
        betslipCountLabel.translatesAutoresizingMaskIntoConstraints = false
        betslipCountLabel.textColor = UIColor.App.textPrimary
        betslipCountLabel.backgroundColor = UIColor.App.bubblesPrimary
        betslipCountLabel.font = AppFont.with(type: .semibold, size: 10)
        betslipCountLabel.textAlignment = .center
        betslipCountLabel.clipsToBounds = true
        betslipCountLabel.layer.masksToBounds = true
        betslipCountLabel.text = "0"
        return betslipCountLabel
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

    private static func createEmptyStateTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("empty_my_games")
        label.font = AppFont.with(type: .semibold, size: 20)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    private static func createEmptyStateLoginButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("login"), for: .normal)
        StyleHelper.styleButton(button: button)
        return button
    }

    private func setupSubviews() {
        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)

        self.topView.bringSubviewToFront(self.topTitleLabel)

        self.view.addSubview(self.topSliderCollectionView)

        self.view.addSubview(self.tableView)
        self.view.addSubview(self.loadingScreenBaseView)
        self.loadingScreenBaseView.addSubview(self.activityIndicatorView)
        self.loadingScreenBaseView.bringSubviewToFront(self.activityIndicatorView)

        self.topSliderCollectionView.register(ListTypeCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)
        self.topSliderCollectionView.delegate = self
        self.topSliderCollectionView.dataSource = self

        tableView.register(MatchLineTableViewCell.nib, forCellReuseIdentifier: MatchLineTableViewCell.identifier)
        tableView.register(BannerScrollTableViewCell.nib, forCellReuseIdentifier: BannerScrollTableViewCell.identifier)
        tableView.register(LoadingMoreTableViewCell.nib, forCellReuseIdentifier: LoadingMoreTableViewCell.identifier)
        tableView.register(TitleTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TitleTableViewHeader.identifier)
        tableView.register(TournamentTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TournamentTableViewHeader.identifier)
        tableView.register(ActivationAlertScrollableTableViewCell.nib, forCellReuseIdentifier: ActivationAlertScrollableTableViewCell.identifier)
        tableView.register(EmptyCardTableViewCell.nib, forCellReuseIdentifier: EmptyCardTableViewCell.identifier)

        tableView.register(SportSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SportSectionHeaderView.identifier)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.betslipButtonView.addSubview(self.betslipCountLabel)

        self.view.addSubview(self.betslipButtonView)

        self.view.addSubview(self.emptyStateView)

        self.emptyStateView.addSubview(self.emptyStateImageView)
        self.emptyStateView.addSubview(self.emptyStateTitleLabel)
        self.emptyStateView.addSubview(self.emptyStateLoginButton)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top Safe Area View
        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.topAnchor)
        ])

        // Top bar
        NSLayoutConstraint.activate([
            self.topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.topView.heightAnchor.constraint(equalToConstant: 70),

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 16),
            self.backButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 20),
            self.backButton.widthAnchor.constraint(equalToConstant: 15),

            self.topTitleLabel.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 30),
            self.topTitleLabel.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -30),
            self.topTitleLabel.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),

        ])

        NSLayoutConstraint.activate([
            self.topSliderCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSliderCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSliderCollectionView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 8),
            self.topSliderCollectionView.heightAnchor.constraint(equalToConstant: 50)
        ])

        // TableView
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.topSliderCollectionView.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        // Loading Screen
        NSLayoutConstraint.activate([
            self.loadingScreenBaseView.topAnchor.constraint(equalTo: self.topView.bottomAnchor),
            self.loadingScreenBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingScreenBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingScreenBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingScreenBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingScreenBaseView.centerYAnchor)
        ])

        // Betslip
        NSLayoutConstraint.activate([
            self.betslipCountLabel.trailingAnchor.constraint(equalTo: self.betslipButtonView.trailingAnchor, constant: 2),
            self.betslipCountLabel.topAnchor.constraint(equalTo: self.betslipButtonView.topAnchor, constant: -3),

            self.betslipButtonView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.betslipButtonView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40),

            self.betslipCountLabel.widthAnchor.constraint(equalToConstant: 20),
            self.betslipCountLabel.widthAnchor.constraint(equalTo: self.betslipCountLabel.heightAnchor),
        ])

        // Empty state view
        NSLayoutConstraint.activate([
            self.emptyStateView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.emptyStateView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.emptyStateView.topAnchor.constraint(equalTo: self.topSliderCollectionView.bottomAnchor),
            self.emptyStateView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.emptyStateImageView.widthAnchor.constraint(equalToConstant: 160),
            self.emptyStateImageView.heightAnchor.constraint(equalToConstant: 160),
            self.emptyStateImageView.topAnchor.constraint(equalTo: self.emptyStateView.topAnchor, constant: 30),
            self.emptyStateImageView.centerXAnchor.constraint(equalTo: self.emptyStateView.centerXAnchor),

            self.emptyStateTitleLabel.leadingAnchor.constraint(equalTo: self.emptyStateView.leadingAnchor, constant: 30),
            self.emptyStateTitleLabel.trailingAnchor.constraint(equalTo: self.emptyStateView.trailingAnchor, constant: -30),
            self.emptyStateTitleLabel.topAnchor.constraint(equalTo: self.emptyStateImageView.bottomAnchor, constant: 30),

            self.emptyStateLoginButton.leadingAnchor.constraint(equalTo: self.emptyStateView.leadingAnchor, constant: 30),
            self.emptyStateLoginButton.trailingAnchor.constraint(equalTo: self.emptyStateView.trailingAnchor, constant: -30),
            self.emptyStateLoginButton.topAnchor.constraint(equalTo: self.emptyStateTitleLabel.bottomAnchor, constant: 30),
            self.emptyStateLoginButton.heightAnchor.constraint(equalToConstant: 50)

        ])
    }

}

enum EmptyStateType {
    case noLogin
    case noGames
    case noCompetitions
    case noFavorites
    case none
}
