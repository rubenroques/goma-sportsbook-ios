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
    private lazy var containerView: GradientView = Self.createContainerView()
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var topSliderCollectionView: UICollectionView = Self.createTopSliderCollectionView()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var loadingScreenBaseView: UIView = Self.createLoadingScreenBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()

    private lazy var floatingShortcutsView: FloatingShortcutsView = Self.createFloatingShortcutsView()
    
    private lazy var emptyStateView: UIView = Self.createEmptyStateView()
    private lazy var emptyStateImageView: UIImageView = Self.createEmptyStateImageView()
    private lazy var emptyStateTitleLabel: UILabel = Self.createEmptyStateTitleLabel()
    private lazy var emptyStateLoginButton: UIButton = Self.createEmptyStateLoginButton()

    private lazy var accountValueView: UIView = Self.createAccountValueView()
    private lazy var accountPlusView: UIView = Self.createAccountPlusView()
    private lazy var accountPlusImageView: UIImageView = Self.createAccountPlusImageView()
    private lazy var accountValueLabel: UILabel = Self.createAccountValueLabel()

    private var cancellables = Set<AnyCancellable>()

    // Data Sources
    private var myFavoriteMatchesDataSource = MyFavoriteMatchesDataSource(userFavoriteMatches: [], store: FavoritesAggregatorsRepository())
    private var myFavoriteCompetitionsDataSource = MyFavoriteCompetitionsDataSource(favoriteCompetitions: [],
                                                                                    favoriteOutrightCompetitions: [],
                                                                                    store: FavoritesAggregatorsRepository())

    // MARK: Public Properties
    var viewModel: MyFavoritesViewModel
    var filterSelectedOption: Int = 0

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.loadingScreenBaseView.isHidden = false
            }
            else {
                self.loadingScreenBaseView.isHidden = true
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

    deinit {
        print("VC DEINIT")
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

        self.myFavoriteCompetitionsDataSource.didSelectCompetitionAction = { competition in
            let viewModel = OutrightMarketDetailsViewModel(competition: competition, store: OutrightMarketDetailsStore())
            let outrightMarketDetailsViewController = OutrightMarketDetailsViewController(viewModel: viewModel)
            self.navigationController?.pushViewController(outrightMarketDetailsViewController, animated: true)
        }
        
        self.isEmptyState = false

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)

        self.floatingShortcutsView.didTapBetslipButtonAction = { [weak self] in
            self?.didTapBetslipView()
        }
        self.floatingShortcutsView.didTapChatButtonAction = { [weak self] in
            self?.didTapChatView()
        }
        
        let accountValueTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAccountValue))
        self.accountValueView.addGestureRecognizer(accountValueTapGesture)
        self.accountValueView.isHidden = true

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
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topSafeAreaView.backgroundColor = .clear

        self.containerView.colors = [(UIColor.App.backgroundGradient1, NSNumber(value: 0.0)),
                                     (UIColor.App.backgroundGradient2, NSNumber(value: 1.0))]

        self.topView.backgroundColor = .clear

        self.backButton.tintColor = UIColor.App.textHeadlinePrimary

        self.topTitleLabel.textColor = UIColor.App.textPrimary
        self.topSliderCollectionView.backgroundColor = UIColor.App.pillNavigation

        //        self.tableView.backgroundColor = UIColor.App.backgroundPrimary
        self.tableView.backgroundColor = .clear
        
        self.loadingScreenBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)
        self.emptyStateView.backgroundColor = .clear

        self.accountValueView.backgroundColor = UIColor.App.backgroundSecondary
        self.accountValueLabel.textColor = UIColor.App.textPrimary
        self.accountPlusView.backgroundColor = UIColor.App.highlightSecondary
        self.accountPlusImageView.setImageColor(color: UIColor.App.buttonTextPrimary)

    }

    // MARK: Binding
    private func bind(toViewModel viewModel: MyFavoritesViewModel) {

        self.myFavoriteMatchesDataSource.store = viewModel.store

        self.myFavoriteCompetitionsDataSource.store = viewModel.store

        self.myFavoriteMatchesDataSource.matchStatsViewModelForMatch = { [weak self] match in
            return self?.viewModel.matchStatsViewModel(forMatch: match)
        }

        self.myFavoriteCompetitionsDataSource.matchStatsViewModelForMatch = { [weak self] match in
            return self?.viewModel.matchStatsViewModel(forMatch: match)
        }

        self.myFavoriteMatchesDataSource.didSelectMatchAction = { [weak self] match in
            let matchDetailsViewController = MatchDetailsViewController(viewModel: MatchDetailsViewModel(match: match))
            self?.navigationController?.pushViewController(matchDetailsViewController, animated: true)
        }

        self.myFavoriteCompetitionsDataSource.didSelectMatchAction = { [weak self] match in
            let matchDetailsViewController = MatchDetailsViewController(viewModel: MatchDetailsViewModel(match: match))
            self?.navigationController?.pushViewController(matchDetailsViewController, animated: true)
        }

        self.myFavoriteMatchesDataSource.matchWentLiveAction = { [weak self] in
            self?.tableView.reloadData()
        }

        self.myFavoriteCompetitionsDataSource.matchWentLiveAction = { [weak self] in
            self?.tableView.reloadData()
        }

//        self.myFavoriteMatchesDataSource.didTapFavoriteMatchAction = { [weak self] match in
//            if !UserSessionStore.isUserLogged() {
//                self?.presentLoginViewController()
//            }
//            else {
//                self?.viewModel.markAsFavorite(match: match)
//            }
//        }
//
//        self.myFavoriteCompetitionsDataSource.didTapFavoriteCompetitionAction = { [weak self] competition in
//            if !UserSessionStore.isUserLogged() {
//                self?.presentLoginViewController()
//            }
//            else {
//                self?.viewModel.markCompetitionAsFavorite(competition: competition)
//            }
//        }
//
//        self.myFavoriteCompetitionsDataSource.didTapFavoriteMatchAction = { [weak self] match in
//            if !UserSessionStore.isUserLogged() {
//                self?.presentLoginViewController()
//            }
//            else {
//                self?.viewModel.markAsFavorite(match: match)
//            }
//        }


        Env.userSessionStore.userSessionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userSession in
                if userSession != nil { // Is Logged In
                    self?.accountValueView.isHidden = false
                }
                else {
                    self?.accountValueView.isHidden = true
                }
            }
            .store(in: &cancellables)

        Env.userSessionStore.userWalletPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userWallet in
                if let userWallet = userWallet,
                   let formattedTotalString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: userWallet.total))
                {
                    self?.accountValueLabel.text = formattedTotalString
                }
                else {
                    self?.accountValueLabel.text = "-.--€"
                }
            }
            .store(in: &cancellables)
        
//        Env.userSessionStore.userBalanceWallet
//            .compactMap({$0})
//            .map(\.amount)
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] value in
//                if let bonusWallet = Env.userSessionStore.userBonusBalanceWallet.value {
//                    let accountValue = bonusWallet.amount + value
//                    self?.accountValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: accountValue)) ?? "-.--€"
//
//                }
//                else {
//                    self?.accountValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: value)) ?? "-.--€"
//                }
//            }
//            .store(in: &cancellables)
//
//        Env.userSessionStore.userBonusBalanceWallet
//            .compactMap({$0})
//            .map(\.amount)
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] value in
//                if let currentWallet = Env.userSessionStore.userBalanceWallet.value {
//                    let accountValue = currentWallet.amount + value
//                    self?.accountValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: accountValue)) ?? "-.--€"
//                }
//            }
//            .store(in: &cancellables)

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                self?.isLoading = isLoading
            })
            .store(in: &cancellables)

        viewModel.dataChangedPublisher
            .receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

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

        viewModel.favoriteMatchesDataPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] matches in
                self?.myFavoriteMatchesDataSource.setupMatchesBySport(favoriteMatches: matches)
            })
            .store(in: &cancellables)

        viewModel.favoriteCompetitionsDataPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] competitions in
                self?.myFavoriteCompetitionsDataSource.competitions = competitions
            })
            .store(in: &cancellables)

        viewModel.favoriteOutrightCompetitionsDataPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] competitions in
                self?.myFavoriteCompetitionsDataSource.outrightCompetitions = competitions
            })
            .store(in: &cancellables)
        
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
        switch self.viewModel.favoriteListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.numberOfSections(in: tableView)
        case .favoriteCompetitions:
            return self.myFavoriteCompetitionsDataSource.numberOfSections(in: tableView)
        }
    }

    func hasContentForSelectedListType() -> Bool {
        switch self.viewModel.favoriteListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.userFavoriteMatches.isNotEmpty
        case .favoriteCompetitions:
            return self.myFavoriteCompetitionsDataSource.competitions.isNotEmpty
        }
   }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.viewModel.favoriteListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .favoriteCompetitions:
            return self.myFavoriteCompetitionsDataSource.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch self.viewModel.favoriteListTypePublisher.value {
        case .favoriteGames:
            cell = self.myFavoriteMatchesDataSource.tableView(tableView, cellForRowAt: indexPath)
        case .favoriteCompetitions:
            cell = self.myFavoriteCompetitionsDataSource.tableView(tableView, cellForRowAt: indexPath)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch self.viewModel.favoriteListTypePublisher.value {
        case .favoriteGames:
            ()
        case .favoriteCompetitions:
            ()
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch self.viewModel.favoriteListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .favoriteCompetitions:
            return self.myFavoriteCompetitionsDataSource.tableView(tableView, viewForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.viewModel.favoriteListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .favoriteCompetitions:
            return self.myFavoriteCompetitionsDataSource.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.viewModel.favoriteListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .favoriteCompetitions:
            return self.myFavoriteCompetitionsDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch self.viewModel.favoriteListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .favoriteCompetitions:
            return self.myFavoriteCompetitionsDataSource.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        switch self.viewModel.favoriteListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .favoriteCompetitions:
            return self.myFavoriteCompetitionsDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        }
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
    
    func openBetslipModal() {
        let betslipViewController = BetslipViewController()
        betslipViewController.willDismissAction = { [weak self] in
            self?.tableView.reloadData()
        }
        self.present(Router.navigationController(with: betslipViewController), animated: true, completion: nil)
    }
    
    @objc func didTapChatView() {
        self.openChatModal()
    }
    
    func openChatModal() {
        if UserSessionStore.isUserLogged() {
            let socialViewController = SocialViewController()
            self.present(Router.navigationController(with: socialViewController), animated: true, completion: nil)
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.present(loginViewController, animated: true, completion: nil)
        }
    }

    @objc private func didTapAccountValue() {
        let depositViewController = DepositViewController()
        let navigationViewController = Router.navigationController(with: depositViewController)

        depositViewController.shouldRefreshUserWallet = { [weak self] in
            Env.userSessionStore.refreshUserWallet()
        }
        
        self.present(navigationViewController, animated: true, completion: nil)
    }

    func presentLoginViewController() {
      let loginViewController = Router.navigationController(with: LoginViewController())
      self.present(loginViewController, animated: true, completion: nil)
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
        label.textAlignment = .left
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

    private static func createContainerView() -> GradientView {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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

    private static func createFloatingShortcutsView() -> FloatingShortcutsView {
        let floatingShortcutsView = FloatingShortcutsView()
        floatingShortcutsView.translatesAutoresizingMaskIntoConstraints = false
        return floatingShortcutsView
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

    private static func createAccountValueView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }

    private static func createAccountPlusView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.squareView
        view.layer.masksToBounds = true
        return view
    }

    private static func createAccountPlusImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "plus_small_icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createAccountValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 12)
        label.text = localized("loading")
        return label
    }
    
    private func setupSubviews() {
        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.containerView)

        self.containerView.addSubview(self.topView)

        self.accountValueView.addSubview(self.accountPlusView)
        self.accountPlusView.addSubview(self.accountPlusImageView)
        self.accountValueView.addSubview(self.accountValueLabel)
        self.topView.addSubview(self.accountValueView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)

        self.topView.bringSubviewToFront(self.topTitleLabel)

        self.containerView.addSubview(self.topSliderCollectionView)

        self.containerView.addSubview(self.tableView)

        self.containerView.addSubview(self.loadingScreenBaseView)

        self.loadingScreenBaseView.addSubview(self.activityIndicatorView)
        self.loadingScreenBaseView.bringSubviewToFront(self.activityIndicatorView)

        self.topSliderCollectionView.register(ListTypeCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)
        self.topSliderCollectionView.delegate = self
        self.topSliderCollectionView.dataSource = self

        tableView.register(MatchLineTableViewCell.nib, forCellReuseIdentifier: MatchLineTableViewCell.identifier)
        tableView.register(OutrightCompetitionLargeLineTableViewCell.self, forCellReuseIdentifier: OutrightCompetitionLargeLineTableViewCell.identifier)
        tableView.register(BannerScrollTableViewCell.nib, forCellReuseIdentifier: BannerScrollTableViewCell.identifier)
        tableView.register(LoadingMoreTableViewCell.nib, forCellReuseIdentifier: LoadingMoreTableViewCell.identifier)
        tableView.register(TitleTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TitleTableViewHeader.identifier)
        tableView.register(TournamentTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: TournamentTableViewHeader.identifier)
        
        tableView.register(ActivationAlertScrollableTableViewCell.nib, forCellReuseIdentifier: ActivationAlertScrollableTableViewCell.identifier)
        tableView.register(EmptyCardTableViewCell.nib, forCellReuseIdentifier: EmptyCardTableViewCell.identifier)

        tableView.register(SportSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SportSectionHeaderView.identifier)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.view.addSubview(self.floatingShortcutsView)
        
        self.containerView.addSubview(self.emptyStateView)

        self.emptyStateView.addSubview(self.emptyStateImageView)
        self.emptyStateView.addSubview(self.emptyStateTitleLabel)
        self.emptyStateView.addSubview(self.emptyStateLoginButton)

        self.initConstraints()

        self.containerView.layoutSubviews()
    }

    private func initConstraints() {

        // Top Safe Area View
        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.topAnchor)
        ])

        // ContainerView
        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        // Top bar
        NSLayoutConstraint.activate([
            self.topView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.topView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.topView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.topView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor),
            self.backButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.topTitleLabel.leadingAnchor.constraint(equalTo: self.backButton.trailingAnchor, constant: 8),
            self.topTitleLabel.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),

            self.accountValueView.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.accountValueView.heightAnchor.constraint(equalToConstant: 24),
            self.accountValueView.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -12),

            self.accountPlusView.widthAnchor.constraint(equalTo: self.accountPlusView.heightAnchor),
            self.accountPlusView.leadingAnchor.constraint(equalTo: self.accountValueView.leadingAnchor, constant: 4),
            self.accountPlusView.topAnchor.constraint(equalTo: self.accountValueView.topAnchor, constant: 4),
            self.accountPlusView.bottomAnchor.constraint(equalTo: self.accountValueView.bottomAnchor, constant: -4),

            self.accountPlusImageView.widthAnchor.constraint(equalToConstant: 12),
            self.accountPlusImageView.heightAnchor.constraint(equalToConstant: 12),
            self.accountPlusImageView.centerXAnchor.constraint(equalTo: self.accountPlusView.centerXAnchor),
            self.accountPlusImageView.centerYAnchor.constraint(equalTo: self.accountPlusView.centerYAnchor),

            self.accountValueLabel.centerYAnchor.constraint(equalTo: self.accountValueView.centerYAnchor),
            self.accountValueLabel.leadingAnchor.constraint(equalTo: self.accountPlusView.trailingAnchor, constant: 4),
            self.accountValueLabel.trailingAnchor.constraint(equalTo: self.accountValueView.trailingAnchor, constant: -4),
        ])

        NSLayoutConstraint.activate([
            self.topSliderCollectionView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.topSliderCollectionView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.topSliderCollectionView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 8),
            self.topSliderCollectionView.heightAnchor.constraint(equalToConstant: 50)
        ])

        // TableView
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.topSliderCollectionView.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
        ])

        // Loading Screen
        NSLayoutConstraint.activate([
            self.loadingScreenBaseView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.loadingScreenBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.loadingScreenBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.loadingScreenBaseView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingScreenBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingScreenBaseView.centerYAnchor)
        ])

        // Betslip
        NSLayoutConstraint.activate([
            self.floatingShortcutsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.floatingShortcutsView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
        ])

        // Empty state view
        NSLayoutConstraint.activate([
            self.emptyStateView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.emptyStateView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.emptyStateView.topAnchor.constraint(equalTo: self.topSliderCollectionView.bottomAnchor),
            self.emptyStateView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

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
