//
//  OutrightMarketDetailsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 21/02/2022.
//

import UIKit
import Combine
import OrderedCollections
import LinkPresentation

class OutrightMarketDetailsViewController: UIViewController {

    // MARK: - Public Properties

    // MARK: - Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backgroundGradientView: GradientView = Self.createBackgroundGradientView()

    private lazy var flagImageView: UIImageView = Self.createFlagImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var headerView: UIView = Self.createHeaderView()
    private lazy var separatorHeaderView: UIView = Self.createSeparatorHeaderView()
    private lazy var outrightsLabel: UILabel = Self.createOutrightsLabel()
    private lazy var marketsLabel: UILabel = Self.createMarketsLabel()
    private lazy var tableView: UITableView = Self.createTableView()

    private let expandCollapseButton = UIButton(type: .system)

    private lazy var floatingShortcutsView: FloatingShortcutsView = Self.createFloatingShortcutsView()
    
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var moreOptionsButton: UIButton = Self.createMoreOptionsButton()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private lazy var accountValueView: UIView = Self.createAccountValueView()
    private lazy var accountPlusView: UIView = Self.createAccountPlusView()
    private lazy var accountPlusImageView: UIImageView = Self.createAccountPlusImageView()
    private lazy var accountValueLabel: UILabel = Self.createAccountValueLabel()

    private lazy var unavailableMarketsView: UIView = Self.createUnavailableMarketsView()
    private lazy var unavailableMarketsLabel: UILabel = Self.createUnavailableMarketsLabel()
    
    private var seeAllOutcomesMarketGroupIds: Set<String> = []
    private var isCollapsedMarketGroupIds: Set<String> = []

    private var viewModel: OutrightMarketDetailsViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifetime and Cycle
    init(viewModel: OutrightMarketDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var sharedGameCardView: SharedGameCardView = {
        let gameCard = SharedGameCardView()
        gameCard.translatesAutoresizingMaskIntoConstraints = false
        gameCard.isHidden = true

        return gameCard
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.loadingBaseView.isHidden = true

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(SimpleListMarketDetailTableViewCell.nib, forCellReuseIdentifier: SimpleListMarketDetailTableViewCell.identifier)
        self.tableView.register(ThreeAwayMarketDetailTableViewCell.nib, forCellReuseIdentifier: ThreeAwayMarketDetailTableViewCell.identifier)
        self.tableView.register(OverUnderMarketDetailTableViewCell.nib, forCellReuseIdentifier: OverUnderMarketDetailTableViewCell.identifier)

        //
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 186, height: 20))
        headerView.backgroundColor = UIColor.clear

        self.expandCollapseButton.setTitle(localized("collapse_all"), for: .normal)
        self.expandCollapseButton.setTitleColor(UIColor.App.textSecondary, for: .normal)
        self.expandCollapseButton.titleLabel?.textAlignment = .right
        self.expandCollapseButton.titleLabel?.font = AppFont.with(type: .medium, size: 11)
        self.expandCollapseButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(self.expandCollapseButton)
        self.expandCollapseButton.addTarget(self, action: #selector(toggleExpandAll), for: .primaryActionTriggered)

        // Set constraints
        NSLayoutConstraint.activate([
            self.expandCollapseButton.widthAnchor.constraint(equalToConstant: 60),
            self.expandCollapseButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            self.expandCollapseButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            self.expandCollapseButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 1),
        ])

        self.tableView.contentInset.top = 18
        self.tableView.tableHeaderView = headerView

        //
        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)
        self.moreOptionsButton.addTarget(self, action: #selector(didTapMoreOptionsButton), for: .allEvents)

        self.floatingShortcutsView.didTapBetslipButtonAction = { [weak self] in
            self?.didTapBetslipView()
        }
        self.floatingShortcutsView.didTapChatButtonAction = { [weak self] in
            self?.didTapChatView()
        }
        
        let accountValueTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAccountValue))
        self.accountValueView.addGestureRecognizer(accountValueTapGesture)
        self.accountValueView.isHidden = true

        self.unavailableMarketsView.isHidden = true
        
        self.showLoading()

        self.bind(toViewModel: self.viewModel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.floatingShortcutsView.resetAnimations()
    }
    
    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        self.flagImageView.layer.cornerRadius = self.flagImageView.frame.size.height/2
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary
        self.headerView.backgroundColor = UIColor.App.backgroundPrimary
        self.separatorHeaderView.backgroundColor = UIColor.App.separatorLine

        self.titleLabel.backgroundColor = .clear
        self.titleLabel.textColor = UIColor.App.textPrimary

        self.tableView.backgroundColor = .clear
        
        self.titleLabel.backgroundColor = .clear
        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.loadingActivityIndicatorView.tintColor = .gray

        self.accountValueView.backgroundColor = UIColor.App.backgroundSecondary
        self.accountValueLabel.textColor = UIColor.App.textPrimary
        self.accountPlusView.backgroundColor = UIColor.App.highlightSecondary
        self.accountPlusImageView.setImageColor(color: UIColor.App.buttonTextPrimary)

        if TargetVariables.shouldUseGradientBackgrounds {
            self.backgroundGradientView.colors = [(UIColor.App.backgroundGradient1, NSNumber(0.0)),
                                                  (UIColor.App.backgroundGradient2, NSNumber(1.0))]
        }
        else {
            self.backgroundGradientView.colors = []
            self.backgroundGradientView.backgroundColor = UIColor.App.backgroundPrimary
        }

        self.unavailableMarketsView.backgroundColor = UIColor.App.backgroundPrimary
        self.unavailableMarketsLabel.textColor = UIColor.App.textPrimary
    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: OutrightMarketDetailsViewModel) {

        Env.userSessionStore.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                if userProfile != nil { // Is Logged In
                    self?.accountValueView.isHidden = false
                }
                else {
                    self?.accountValueView.isHidden = true
                }
            }
            .store(in: &cancellables)
        
        // Env.userSessionStore.userWalletPublisher
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
/*
        Env.userSessionStore.userBalanceWallet
            .compactMap({$0})
            .map(\.amount)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if let bonusWallet = Env.userSessionStore.userBonusBalanceWallet.value {
                    let accountValue = bonusWallet.amount + value
                    self?.accountValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: accountValue)) ?? "-.--€"

                }
                else {
                    self?.accountValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: value)) ?? "-.--€"
                }
            }
            .store(in: &cancellables)

        Env.userSessionStore.userBonusBalanceWallet
            .compactMap({$0})
            .map(\.amount)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if let currentWallet = Env.userSessionStore.userBalanceWallet.value {
                    let accountValue = currentWallet.amount + value
                    self?.accountValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: accountValue)) ?? "-.--€"
                }
            }
            .store(in: &cancellables)
*/
        
        self.viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                }
                else {
                    self?.hideLoading()
                }
            }.store(in: &cancellables)

        self.viewModel.isCompetitionBettingAvailablePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isCompetitionBettingAvailable in
                if isCompetitionBettingAvailable {
                    self?.unavailableMarketsView.isHidden = true
                }
                else {
                    self?.unavailableMarketsView.isHidden = false
                }
            }.store(in: &cancellables)
        
        self.viewModel.refreshPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.reloadTableView()
            })
            .store(in: &self.cancellables)

        self.titleLabel.text = self.viewModel.competitionName
        self.flagImageView.image = UIImage(named: viewModel.countryImageName)

    }

    private func reloadTableView() {
        self.tableView.reloadData()

        if self.isCollapsedMarketGroupIds.isEmpty {
            self.expandCollapseButton.setTitle(localized("collapse_all"), for: .normal)
        }
        else {
            self.expandCollapseButton.setTitle(localized("expand_all"), for: .normal)
        }
    }

    private func showLoading() {
        self.loadingBaseView.isHidden = false
        self.loadingActivityIndicatorView.startAnimating()
    }

    private func hideLoading() {
        self.loadingBaseView.isHidden = true
        self.loadingActivityIndicatorView.stopAnimating()
    }

    // MARK: - Actions
    @objc func toggleExpandAll(sender: UIButton) {
        if self.isCollapsedMarketGroupIds.isEmpty {
            // Add all to collapsed
            for section in 0..<self.viewModel.numberOfSections() {
                for row in 0..<self.viewModel.numberOfRows(forSection: section) {
                    if let marketGroupOrganizer = self.viewModel.marketGroupOrganizer(forIndex: row) {
                        self.isCollapsedMarketGroupIds.insert(marketGroupOrganizer.marketId)
                    }
                }
            }
        }
        else {
            // Clear collapsed
            self.isCollapsedMarketGroupIds = []
        }

        self.reloadTableView()
    }

    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func didTapMoreOptionsButton() {
      
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if Env.userSessionStore.isUserLogged(){
            if Env.favoritesManager.isEventFavorite(eventId: self.viewModel.competition.id) {
                let favoriteAction: UIAlertAction = UIAlertAction(title: "Remove from favorites", style: .default) { _ in
                    Env.favoritesManager.removeFavorite(eventId: self.viewModel.competition.id, favoriteType: .match)
                    
                }
                actionSheetController.addAction(favoriteAction)
            }
            else {
                let favoriteAction: UIAlertAction = UIAlertAction(title: localized("add_to_favorites"), style: .default) { _ in
                    Env.favoritesManager.addFavorite(eventId: self.viewModel.competition.id, favoriteType: .match)
                    
                }
                actionSheetController.addAction(favoriteAction)
            }
        }

        let shareAction: UIAlertAction = UIAlertAction(title: localized("share_event"), style: .default) { [weak self] _ in
            self?.didTapShareButton()
        }
        actionSheetController.addAction(shareAction)

        let cancelAction: UIAlertAction = UIAlertAction(title: localized("cancel"), style: .cancel) { _ in }
        actionSheetController.addAction(cancelAction)

        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        self.present(actionSheetController, animated: true, completion: nil)
    }

    @objc  func didTapShareButton() {

        let matchId = self.viewModel.competition.id
        self.sharedGameCardView.isHidden = false

        let renderer = UIGraphicsImageRenderer(size: self.sharedGameCardView.bounds.size)
        let snapshot = renderer.image { _ in
            self.sharedGameCardView.drawHierarchy(in: self.sharedGameCardView.bounds, afterScreenUpdates: true)
        }

        let metadata = LPLinkMetadata()

        let matchSlugUrl = self.generateUrlSlug(competition: self.viewModel.competition)
        
        if let matchUrl = URL(string: matchSlugUrl) {

            let imageProvider = NSItemProvider(object: snapshot)
            metadata.imageProvider = imageProvider
            metadata.url = matchUrl
            metadata.originalURL = matchUrl
            metadata.title = localized("check_this_game")
        }

        let metadataItemSource = LinkPresentationItemSource(metaData: metadata)

        let shareActivityViewController = UIActivityViewController(activityItems: [metadataItemSource, snapshot], applicationActivities: nil)
        if let popoverController = shareActivityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        shareActivityViewController.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.sharedGameCardView.isHidden = true
        }
        self.present(shareActivityViewController, animated: true, completion: nil)
    }
    
    @objc func didTapBetslipView() {
        self.openBetslipModal()
    }

    func openBetslipModal() {
        let betslipViewModel = BetslipViewModel()
        
        let betslipViewController = BetslipViewController(viewModel: betslipViewModel)
        
        betslipViewController.willDismissAction = { [weak self] in
            self?.tableView.reloadData()
        }
        self.present(Router.navigationController(with: betslipViewController), animated: true, completion: nil)
    }

    @objc private func didTapAccountValue() {
        let depositViewController = DepositViewController()
        let navigationViewController = Router.navigationController(with: depositViewController)

        depositViewController.shouldRefreshUserWallet = { [weak self] in
            Env.userSessionStore.refreshUserWallet()
        }

        self.present(navigationViewController, animated: true, completion: nil)
    }
    
    @objc func didTapChatView() {
        self.openChatModal()
    }
    
    func openChatModal() {
        if Env.userSessionStore.isUserLogged() {
            let socialViewController = SocialViewController()
            self.present(Router.navigationController(with: socialViewController), animated: true, completion: nil)
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.present(loginViewController, animated: true, completion: nil)
        }
    }

    private func generateUrlSlug(competition: Competition) -> String {
        // https://betsson.fr/fr/competitions/cyclisme/tour-de-france-international/3059212.1/outrights

        var sportName = competition.sport?.name.lowercased() ?? ""

        if let realSportName = Env.sportsStore.getActiveSports().filter({
            $0.alphaId == competition.sport?.alphaId
        }).compactMap({
            return $0.name
        }).first {
            sportName = realSportName.lowercased()
        }

        let competitionName = competition.name.slugify()

        let fullString = "\(TargetVariables.clientBaseUrl)/\(Locale.current.languageCode ?? "fr")/competitions/\(sportName)/\(competitionName)/\(competition.id)/outrights"

        return fullString
    }
    
}

// MARK: - TableView Protocols
//
extension OutrightMarketDetailsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows(forSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard
            let marketGroupOrganizer = self.viewModel.marketGroupOrganizer(forIndex: indexPath.row)
        else {
            return UITableViewCell()
        }

        if marketGroupOrganizer.numberOfColumns == 3 {
            guard
                let cell = tableView.dequeueCellType(ThreeAwayMarketDetailTableViewCell.self)
            else {
                return UITableViewCell()
            }

            cell.competitionName = self.viewModel.competition.name
            cell.marketId = marketGroupOrganizer.marketId

            cell.didExpandCellAction = { marketGroupOrganizerId in
                self.seeAllOutcomesMarketGroupIds.insert(marketGroupOrganizerId)
                self.reloadTableView()
            }
            cell.didColapseCellAction = { marketGroupOrganizerId in
                self.seeAllOutcomesMarketGroupIds.remove(marketGroupOrganizerId)
                self.reloadTableView()
            }

            cell.didExpandAllCellAction = { [weak self] marketGroupOrganizerId in
                self?.isCollapsedMarketGroupIds.remove(marketGroupOrganizerId)
                self?.reloadTableView()
            }
            cell.didColapseAllCellAction = {  [weak self] marketGroupOrganizerId in
                self?.isCollapsedMarketGroupIds.insert(marketGroupOrganizerId)
                self?.reloadTableView()
            }

            cell.configure(withMarketGroupOrganizer: marketGroupOrganizer,
                           seeAllOutcomes: self.seeAllOutcomesMarketGroupIds.contains(marketGroupOrganizer.marketId),
                           isExpanded: !self.isCollapsedMarketGroupIds.contains(marketGroupOrganizer.marketId),
                           betBuilderGrayoutsState: BetBuilderGrayoutsState())
            return cell
        }
        else if marketGroupOrganizer.numberOfColumns == 2 {
            guard
                let cell = tableView.dequeueCellType(OverUnderMarketDetailTableViewCell.self)
            else {
                return UITableViewCell()
            }
            cell.competitionName = self.viewModel.competition.name
            cell.marketId = marketGroupOrganizer.marketId

            cell.didExpandCellAction = { marketGroupOrganizerId in
                self.seeAllOutcomesMarketGroupIds.insert(marketGroupOrganizerId)
                self.reloadTableView()
            }
            cell.didColapseCellAction = { marketGroupOrganizerId in
                self.seeAllOutcomesMarketGroupIds.remove(marketGroupOrganizerId)
                self.reloadTableView()
            }

            cell.didExpandAllCellAction = { [weak self] marketGroupOrganizerId in
                self?.isCollapsedMarketGroupIds.remove(marketGroupOrganizerId)
                self?.reloadTableView()
            }
            cell.didColapseAllCellAction = {  [weak self] marketGroupOrganizerId in
                self?.isCollapsedMarketGroupIds.insert(marketGroupOrganizerId)
                self?.reloadTableView()
            }

            cell.configure(withMarketGroupOrganizer: marketGroupOrganizer,
                           seeAllOutcomes: self.seeAllOutcomesMarketGroupIds.contains(marketGroupOrganizer.marketId),
                           isExpanded: !self.isCollapsedMarketGroupIds.contains(marketGroupOrganizer.marketId),
                           betBuilderGrayoutsState: BetBuilderGrayoutsState())
            return cell
        }
        else if marketGroupOrganizer.numberOfColumns == 1 {
            guard
                let cell = tableView.dequeueCellType(OverUnderMarketDetailTableViewCell.self)
            else {
                return UITableViewCell()
            }
            cell.competitionName = self.viewModel.competition.name
            cell.marketId = marketGroupOrganizer.marketId
            cell.didExpandCellAction = { marketGroupOrganizerId in
                self.seeAllOutcomesMarketGroupIds.insert(marketGroupOrganizerId)
                self.reloadTableView()
            }
            cell.didColapseCellAction = { marketGroupOrganizerId in
                self.seeAllOutcomesMarketGroupIds.remove(marketGroupOrganizerId)
                self.reloadTableView()
            }

            cell.didExpandAllCellAction = { [weak self] marketGroupOrganizerId in
                self?.isCollapsedMarketGroupIds.remove(marketGroupOrganizerId)
                self?.reloadTableView()
            }
            cell.didColapseAllCellAction = {  [weak self] marketGroupOrganizerId in
                self?.isCollapsedMarketGroupIds.insert(marketGroupOrganizerId)
                self?.reloadTableView()
            }

            cell.configure(withMarketGroupOrganizer: marketGroupOrganizer,
                           seeAllOutcomes: self.seeAllOutcomesMarketGroupIds.contains(marketGroupOrganizer.marketId),
                           isExpanded: !self.isCollapsedMarketGroupIds.contains(marketGroupOrganizer.marketId),
                           betBuilderGrayoutsState: BetBuilderGrayoutsState())
            return cell
        }
        else {
            guard
                let cell = tableView.dequeueCellType(SimpleListMarketDetailTableViewCell.self)
            else {
                return UITableViewCell()
            }
            cell.competitionName = self.viewModel.competition.name
            cell.configure(withMarketGroupOrganizer: marketGroupOrganizer)
            return cell
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

extension OutrightMarketDetailsViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createFlagImageView() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }
    
    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.App.textPrimary
        titleLabel.font = AppFont.with(type: .semibold, size: 14)
        titleLabel.textAlignment = .left
        titleLabel.text = ""
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return titleLabel
    }

    private static func createBackButton() -> UIButton {
        let backButton = UIButton.init(type: .custom)
        backButton.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        backButton.setTitle(nil, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        return backButton
    }
    
    private static func createMoreOptionsButton() -> UIButton {
        let moreOptionsButton = UIButton.init(type: .custom)
        moreOptionsButton.setImage(UIImage(named: "more_options_icon"), for: .normal)
        moreOptionsButton.setTitle(nil, for: .normal)
        moreOptionsButton.translatesAutoresizingMaskIntoConstraints = false
        return moreOptionsButton
    
    }

    private static func createHeaderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    private static func createSeparatorHeaderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createOutrightsLabel() -> UILabel {
        let outrightsLabel = UILabel()
        outrightsLabel.translatesAutoresizingMaskIntoConstraints = false
        outrightsLabel.textColor = UIColor.App.textPrimary
        outrightsLabel.font = AppFont.with(type: .semibold, size: 12)
        outrightsLabel.textAlignment = .center
        outrightsLabel.numberOfLines = 1
        outrightsLabel.text = localized("outrights")
        return outrightsLabel
    }

    private static func createMarketsLabel() -> UILabel {
        let marketsLabel = UILabel()
        marketsLabel.translatesAutoresizingMaskIntoConstraints = false
        marketsLabel.textColor = UIColor.App.textPrimary
        marketsLabel.font = AppFont.with(type: .bold, size: 17)
        marketsLabel.textAlignment = .center
        marketsLabel.numberOfLines = 1
        marketsLabel.text = localized("competition_markets")
        return marketsLabel
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        tableView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }
    
    private static func createFloatingShortcutsView() -> FloatingShortcutsView {
        let floatingShortcutsView = FloatingShortcutsView()
        floatingShortcutsView.translatesAutoresizingMaskIntoConstraints = false
        return floatingShortcutsView
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
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }
    
    private static func createUnavailableMarketsView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createUnavailableMarketsLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 18)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = localized("competition_no_longer")
        return label
    }

    private static func createBackgroundGradientView() -> GradientView {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.navigationView)
        self.view.addSubview(self.backgroundGradientView)

        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.flagImageView)
        self.navigationView.addSubview(self.titleLabel)
        self.navigationView.addSubview(self.moreOptionsButton)
        
        self.accountValueView.addSubview(self.accountPlusView)
        self.accountPlusView.addSubview(self.accountPlusImageView)
        self.accountValueView.addSubview(self.accountValueLabel)
        self.navigationView.addSubview(self.accountValueView)
        self.navigationView.addSubview(self.moreOptionsButton)

        self.view.addSubview(self.headerView)
        self.headerView.addSubview(self.outrightsLabel)
        self.headerView.addSubview(self.marketsLabel)
        self.headerView.addSubview(self.separatorHeaderView)

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.floatingShortcutsView)
        
        self.view.addSubview(self.loadingBaseView)
        self.view.addSubview(self.sharedGameCardView)
        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)
        
        self.view.addSubview(self.unavailableMarketsView)
        self.unavailableMarketsView.addSubview(self.unavailableMarketsLabel)
        
        self.initConstraints()

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        ])

        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 40),

            self.backgroundGradientView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.backgroundGradientView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.backgroundGradientView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.backgroundGradientView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.backButton.widthAnchor.constraint(equalTo: self.backButton.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 8),
            
            self.flagImageView.widthAnchor.constraint(equalTo: self.flagImageView.heightAnchor),
            self.flagImageView.widthAnchor.constraint(equalToConstant: 18),
            self.flagImageView.leadingAnchor.constraint(equalTo: self.backButton.trailingAnchor, constant: 1),
            self.flagImageView.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.flagImageView.trailingAnchor, constant: 6),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.accountValueView.leadingAnchor),

            self.moreOptionsButton.heightAnchor.constraint(equalToConstant: 40),
            self.moreOptionsButton.widthAnchor.constraint(equalToConstant: 36),
            self.moreOptionsButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.moreOptionsButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -8),

            self.accountValueView.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.accountValueView.heightAnchor.constraint(equalToConstant: 24),
            self.accountValueView.trailingAnchor.constraint(equalTo: self.moreOptionsButton.leadingAnchor, constant: -3),

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
            self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.headerView.heightAnchor.constraint(equalToConstant: 50),

            self.outrightsLabel.centerXAnchor.constraint(equalTo: self.headerView.centerXAnchor),
            self.outrightsLabel.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor, constant: 12),
            self.outrightsLabel.topAnchor.constraint(equalTo: self.headerView.topAnchor, constant: 6),

            self.marketsLabel.centerXAnchor.constraint(equalTo: self.headerView.centerXAnchor),
            self.marketsLabel.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor, constant: 12),
            self.marketsLabel.bottomAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: -9),

            self.separatorHeaderView.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor),
            self.separatorHeaderView.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor),
            self.separatorHeaderView.bottomAnchor.constraint(equalTo: self.headerView.bottomAnchor),
            self.separatorHeaderView.heightAnchor.constraint(equalToConstant: 1)
        ])

        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.floatingShortcutsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.floatingShortcutsView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
        ])

        NSLayoutConstraint.activate([
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
        ])

        NSLayoutConstraint.activate([
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.sharedGameCardView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.sharedGameCardView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            self.sharedGameCardView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.sharedGameCardView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.unavailableMarketsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.unavailableMarketsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.unavailableMarketsView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.unavailableMarketsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            self.unavailableMarketsLabel.leadingAnchor.constraint(equalTo: self.unavailableMarketsView.leadingAnchor, constant: 24),
            self.unavailableMarketsLabel.centerXAnchor.constraint(equalTo: self.unavailableMarketsView.centerXAnchor),
            self.unavailableMarketsLabel.centerYAnchor.constraint(equalTo: self.unavailableMarketsView.centerYAnchor, constant: -32),
        ])
        
    }
}
