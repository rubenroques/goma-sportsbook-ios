//
//  HomeViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/02/2022.
//

import UIKit
import Combine

class HomeViewController: UIViewController {

    // MARK: - Public Properties
    var didTapBetslipButtonAction: (() -> Void)?
    var didTapExternalVideoAction: ((URL) -> Void) = { _ in }

    var didTapExternalLinkAction: ((URL) -> Void) = { _ in }

    var didTapChatButtonAction: (() -> Void)?
    var didSelectMatchAction: ((Match) -> Void)?
    var didSelectActivationAlertAction: ((ActivationAlertType) -> Void)?

    var didTapUserProfileAction: ((UserBasicInfo) -> Void)?

    // MARK: - Private Properties
    // Sub Views
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private lazy var floatingShortcutsView: FloatingShortcutsView = Self.createFloatingShortcutsView()
    
    private let refreshControl = UIRefreshControl()

    // Logic
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: HomeViewModel

    private var shortcutSelectedOption: Int = -1
    
    private var featuredTipsCenterIndex: Int = 0
    
    // MARK: - Lifetime and Cycle
    init(viewModel: HomeViewModel = HomeViewModel()) {
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

        self.tableView.register(SportMatchDoubleLineTableViewCell.self, forCellReuseIdentifier: SportMatchDoubleLineTableViewCell.identifier)
        self.tableView.register(SportMatchSingleLineTableViewCell.self, forCellReuseIdentifier: SportMatchSingleLineTableViewCell.identifier)
        self.tableView.register(TopCompetitionLineTableViewCell.self, forCellReuseIdentifier: TopCompetitionLineTableViewCell.identifier)
        self.tableView.register(BannerScrollTableViewCell.nib, forCellReuseIdentifier: BannerScrollTableViewCell.identifier)
        self.tableView.register(MatchLineTableViewCell.nib, forCellReuseIdentifier: MatchLineTableViewCell.identifier)
        self.tableView.register(SuggestedBetLineTableViewCell.self, forCellReuseIdentifier: SuggestedBetLineTableViewCell.identifier)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        self.tableView.register(ActivationAlertScrollableTableViewCell.nib, forCellReuseIdentifier: ActivationAlertScrollableTableViewCell.identifier)
        self.tableView.register(VideoPreviewLineTableViewCell.self, forCellReuseIdentifier: VideoPreviewLineTableViewCell.identifier)
        self.tableView.register(FeaturedTipLineTableViewCell.self, forCellReuseIdentifier: FeaturedTipLineTableViewCell.identifier)

        self.refreshControl.tintColor = UIColor.lightGray
        self.refreshControl.addTarget(self, action: #selector(self.refreshControllPulled), for: .valueChanged)
        self.tableView.addSubview(self.refreshControl)

        self.loadingBaseView.isHidden = true

        self.floatingShortcutsView.didTapBetslipButtonAction = { [weak self] in
            self?.didTapBetslipView()
        }
        
        self.floatingShortcutsView.didTapChatButtonAction = { [weak self] in
            self?.didTapChatView()
        }
        
        self.bind(toViewModel: self.viewModel)

        self.didSelectActivationAlertAction = { alertType in
            if alertType == ActivationAlertType.email {
                let emailVerificationViewController = EmailVerificationViewController()
                self.present(emailVerificationViewController, animated: true, completion: nil)
            }
            else if alertType == ActivationAlertType.profile {
                let fullRegisterViewController = FullRegisterPersonalInfoViewController(isBackButtonDisabled: true)
                self.navigationController?.pushViewController(fullRegisterViewController, animated: true)
            }
        }

        self.showLoading()

        executeDelayed(2.0) {
            self.hideLoading()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.floatingShortcutsView.resetAnimations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.floatingShortcutsView.resetAnimations()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary
        self.tableView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.loadingActivityIndicatorView.tintColor = UIColor.gray

    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: HomeViewModel) {

        NotificationCenter.default.publisher(for: .cardsStyleChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadData()
            }
            .store(in: &cancellables)

        viewModel.refreshPublisher
            .debounce(for: .milliseconds(600), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.reloadData()
                self?.refreshControl.endRefreshing()
            })
            .store(in: &self.cancellables)

    }

    // MARK: - Convenience
    @objc func refreshControllPulled() {
        self.viewModel.refresh()
    }

    func reloadData() {
        self.tableView.reloadData()
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
    private func openCompetitionsDetails(competitionsIds: [String], sport: Sport) {
        let competitionDetailsViewModel = CompetitionDetailsViewModel(competitionsIds: competitionsIds, sport: sport, store: AggregatorsRepository())
        let competitionDetailsViewController = CompetitionDetailsViewController(viewModel: competitionDetailsViewModel)
        self.navigationController?.pushViewController(competitionDetailsViewController, animated: true)
    }

    private func openOutrightCompetition(competition: Competition) {
        let viewModel = OutrightMarketDetailsViewModel(competition: competition, store: OutrightMarketDetailsStore())
        let outrightMarketDetailsViewController = OutrightMarketDetailsViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(outrightMarketDetailsViewController, animated: true)
    }

    private func openMatchDetails(matchId: String) {
        let matchDetailsViewController = MatchDetailsViewController(viewModel: MatchDetailsViewModel(matchId: matchId))
        self.navigationController?.pushViewController(matchDetailsViewController, animated: true)
    }

    private func openPopularDetails(_ sport: Sport) {
        let viewModel = PopularDetailsViewModel(sport: sport, store: AggregatorsRepository())
        let popularDetailsViewController = PopularDetailsViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(popularDetailsViewController, animated: true)
    }

    private func openLiveDetails(_ sport: Sport) {
        let viewModel = LiveDetailsViewModel(sport: sport, store: AggregatorsRepository())
        let liveDetailsViewController = LiveDetailsViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(liveDetailsViewController, animated: true)
    }

    private func openBonusView() {
        let bonusRootViewController = BonusRootViewController(viewModel: BonusRootViewModel(startTabIndex: 0))
        self.navigationController?.pushViewController(bonusRootViewController, animated: true)
    }

    private func openFeaturedTipSlider(featuredTips: [FeaturedTip], atIndex index: Int = 0) {
        let tipsSliderViewController = TipsSliderViewController(viewModel: TipsSliderViewModel(featuredTips: featuredTips, startIndex: index))
        
        tipsSliderViewController.shift.enable()

        self.present(tipsSliderViewController, animated: true)
    }

    @objc private func didTapOpenFavorites() {
        self.openFavorites()
    }

    @objc private func didTapOpenFeaturedTips() {
        let tips = self.viewModel.featuredTipLineViewModel()?.featuredTips ?? []
        self.openFeaturedTipSlider(featuredTips: tips, atIndex: self.featuredTipsCenterIndex)
    }
    
    private func openFavorites() {
        let myFavoritesViewController = MyFavoritesViewController()
        self.navigationController?.pushViewController(myFavoritesViewController, animated: true)
    }

    private func openQuickbet(_ bettingTicket: BettingTicket) {

        if let userSession = UserSessionStore.loggedUserSession() {
            let quickbetViewModel = QuickBetViewModel(bettingTicket: bettingTicket)

            let quickbetViewController = QuickBetViewController(viewModel: quickbetViewModel)

            quickbetViewController.modalPresentationStyle = .overCurrentContext
            quickbetViewController.modalTransitionStyle = .crossDissolve

            self.present(quickbetViewController, animated: true)
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.present(loginViewController, animated: true, completion: nil)
        }
    }
}

//
// MARK: - TableView Protocols
//
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows(forSectionIndex: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard
            let contentType = self.viewModel.contentType(forSection: indexPath.section)
        else {
            fatalError()
        }

        switch contentType {
        case .userMessage:
            return UITableViewCell()
        case .bannerLine:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: BannerScrollTableViewCell.identifier) as? BannerScrollTableViewCell,
                let sportMatchLineViewModel = self.viewModel.bannerLineViewModel()
            else {
                fatalError()
            }
            cell.configure(withViewModel: sportMatchLineViewModel)

            cell.didTapBannerViewAction = { [weak self] presentationType in
                switch presentationType {
                case .image:
                    self?.openBonusView()
                case .match(let matchId):
                    self?.openMatchDetails(matchId: matchId)
                case .externalMatch(let matchId, _, _, _):
                    self?.openMatchDetails(matchId: matchId)
                case .externalLink(_, let linkURLString):
                    if let linkURL =  URL(string: linkURLString) {
                        self?.didTapExternalLinkAction(linkURL)
                    }
                case .externalStream(_, let streamURLString):
                    if let streamURL =  URL(string: streamURLString) {
                        self?.didTapExternalVideoAction(streamURL)
                    }
                }
            }

            cell.didLongPressOdd = { [weak self] bettingTicket in
                self?.openQuickbet(bettingTicket)
            }
            
            return cell

        case .userFavorites:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: MatchLineTableViewCell.identifier) as? MatchLineTableViewCell,
                let match = self.viewModel.favoriteMatch(forIndex: indexPath.row)
            else {
                fatalError()
            }

            cell.matchStatsViewModel = self.viewModel.matchStatsViewModel(forMatch: match)
            cell.setupWithMatch(match, store: self.viewModel.store)
            cell.setupFavoriteMatchInfoPublisher(match: match)
            cell.tappedMatchLineAction = { [weak self] in
                self?.openMatchDetails(matchId: match.id)
            }

            cell.didLongPressOdd = { [weak self] bettingTicket in
                self?.openQuickbet(bettingTicket)
            }
           
            return cell
        case .featuredTips:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: FeaturedTipLineTableViewCell.identifier) as? FeaturedTipLineTableViewCell,
                    let featuredBetLineViewModel = self.viewModel.featuredTipLineViewModel()
            else {
                fatalError()
            }

            cell.openFeaturedTipDetailAction = { [weak self] featuredTip in
                let firstIndex = featuredBetLineViewModel.featuredTips.firstIndex(where: { tipIterator in
                    tipIterator.betId == featuredTip.betId
                })
                let firstIndexValue: Int = Int(firstIndex ?? 0)
                
                self?.openFeaturedTipSlider(featuredTips: featuredBetLineViewModel.featuredTips, atIndex: firstIndexValue)
            }

            cell.currentIndexChangedAction = { [weak self] newIndex in
                self?.featuredTipsCenterIndex = newIndex
            }
            cell.configure(withViewModel: featuredBetLineViewModel)

            cell.shouldShowBetslip = { [weak self] in
                self?.didTapBetslipButtonAction?()
            }

            cell.shouldShowUserProfile = { [weak self] userBasicInfo in
                self?.didTapUserProfileAction?(userBasicInfo)
            }

            return cell
        case .suggestedBets:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: SuggestedBetLineTableViewCell.identifier) as? SuggestedBetLineTableViewCell,
                let suggestedBetLineViewModel = self.viewModel.suggestedBetLineViewModel()
            else {
                fatalError()
            }
            cell.configure(withViewModel: suggestedBetLineViewModel)
            cell.betNowCallbackAction = { [weak self] in
                self?.didTapBetslipButtonAction?()
            }
            return cell

        case .sport:
            guard
                let sportGroupViewModel = self.viewModel.sportGroupViewModel(forSection: indexPath.section),
                let sportMatchLineViewModel = sportGroupViewModel.sportMatchLineViewModel(forIndex: indexPath.row)
            else {
                fatalError()
            }
            
            switch sportMatchLineViewModel.loadingPublisher.value {
            case .loading, .empty:
                let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
                return cell
            case.loaded:
                ()
            }
            
            switch sportMatchLineViewModel.layoutTypePublisher.value {
            case .doubleLine:
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: SportMatchDoubleLineTableViewCell.identifier)
                        as? SportMatchDoubleLineTableViewCell
                else {
                    fatalError()
                }

                cell.matchStatsViewModelForMatch = { [weak self] match in
                    self?.viewModel.matchStatsViewModel(forMatch: match)
                }
                cell.configure(withViewModel: sportMatchLineViewModel)
                cell.tappedMatchLineAction = { [weak self] match in
                    self?.openMatchDetails(matchId: match.id)
                }
                cell.didSelectSeeAllLive = { [weak self] sport in
                    self?.openLiveDetails(sport)
                }
                cell.didSelectSeeAllPopular = { [weak self] sport in
                    self?.openPopularDetails(sport)
                }
                cell.didSelectSeeAllCompetitionAction = { [weak self] competition in
                    self?.openOutrightCompetition(competition: competition)
                }

                cell.didLongPressOdd = { [weak self] bettingTicket in
                    self?.openQuickbet(bettingTicket)
                }

                return cell

            case .singleLine:
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: SportMatchSingleLineTableViewCell.identifier) as? SportMatchSingleLineTableViewCell
                else {
                    fatalError()
                }
                cell.matchStatsViewModelForMatch = { [weak self] match in
                    self?.viewModel.matchStatsViewModel(forMatch: match)
                }
                cell.configure(withViewModel: sportMatchLineViewModel)
                cell.tappedMatchLineAction = { [weak self] match in
                    self?.openMatchDetails(matchId: match.id)
                }
                cell.didSelectSeeAllLive = { [weak self] sport in
                    self?.openLiveDetails(sport)
                }
                cell.didSelectSeeAllPopular = { [weak self] sport in
                    self?.openPopularDetails(sport)
                }
                cell.didSelectSeeAllCompetitionAction = { [weak self] competition in
                    self?.openOutrightCompetition(competition: competition)
                }

                cell.didLongPressOdd = { [weak self] bettingTicket in
                    self?.openQuickbet(bettingTicket)
                }

                return cell
                
            case .competition:
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: TopCompetitionLineTableViewCell.identifier) as? TopCompetitionLineTableViewCell
                else {
                    fatalError()
                }
                cell.configure(withViewModel: sportMatchLineViewModel)
                cell.didSelectSeeAllCompetitionsAction = { [weak self] sport, competitions in
                    self?.openCompetitionsDetails(competitionsIds: competitions.map(\.id), sport: sport)
                }
                return cell

            case .video:
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: VideoPreviewLineTableViewCell.identifier) as? VideoPreviewLineTableViewCell
                else {
                    fatalError()
                }
                if let videoPreviewLineCellViewModel = sportMatchLineViewModel.videoPreviewLineCellViewModel() {
                    cell.configure(withViewModel: videoPreviewLineCellViewModel)
                    cell.didTapVideoPreviewLineCellAction = { [weak self] viewModel in
                        if let externalStreamURL = viewModel.externalStreamURL {
                            self?.didTapExternalVideoAction(externalStreamURL)
                        }
                    }
                }
                return cell
            }

        case .userProfile:
            guard let cell = tableView.dequeueCellType(ActivationAlertScrollableTableViewCell.self)
            else {
                fatalError()
            }
            cell.activationAlertCollectionViewCellLinkLabelAction = { alertType in
                self.didSelectActivationAlertAction?(alertType)
            }
            cell.setAlertArrayData(arrayData: self.viewModel.alertsArrayViewModel())

            return cell

        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard
            let contentType = self.viewModel.contentType(forSection: indexPath.section)
        else {
            return UITableView.automaticDimension
        }

        switch contentType {
        case .userMessage:
            return .leastNormalMagnitude
        case .bannerLine:
            return 180
        case .userFavorites:
            return UITableView.automaticDimension
        case .featuredTips:
            return 420
        case .suggestedBets:
            return 336
        case .sport:
            guard
                let sportGroupViewModel = self.viewModel.sportGroupViewModel(forSection: indexPath.section),
                let sportMatchLineViewModel = sportGroupViewModel.sportMatchLineViewModel(forIndex: indexPath.row)
            else {
                return UITableView.automaticDimension
            }
            
            if sportMatchLineViewModel.loadingPublisher.value == .empty {
                return .leastNormalMagnitude
            }
            else if sportMatchLineViewModel.loadingPublisher.value == .loading {
                return .leastNormalMagnitude
            }
            else {
                switch sportMatchLineViewModel.layoutTypePublisher.value {
                case .doubleLine: return UITableView.automaticDimension
                case .singleLine: return UITableView.automaticDimension
                case .competition: return UITableView.automaticDimension
                case .video: return 258
                }
            }
        case .userProfile:
            return 140
        }

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard
            let contentType = self.viewModel.contentType(forSection: indexPath.section)
        else {
            return 356
        }

        switch contentType {
        case .userMessage:
            return .leastNormalMagnitude
        case .bannerLine:
            return 180
        case .userFavorites:
            return StyleHelper.cardsStyleHeight() + 20
        case .featuredTips:
            return 420
        case .suggestedBets:
            return 336
        case .sport:
            guard
                let sportGroupViewModel = self.viewModel.sportGroupViewModel(forSection: indexPath.section),
                let sportMatchLineViewModel = sportGroupViewModel.sportMatchLineViewModel(forIndex: indexPath.row)
            else {
                return UITableView.automaticDimension
            }

            if sportMatchLineViewModel.loadingPublisher.value == .empty {
                return .leastNormalMagnitude
            }
            else if sportMatchLineViewModel.loadingPublisher.value == .loading {
                return .leastNormalMagnitude
            }
            else {
                switch sportMatchLineViewModel.layoutTypePublisher.value {
                case .doubleLine: return StyleHelper.cardsStyleHeight() * 2 + 79 // 400
                case .singleLine: return StyleHelper.cardsStyleHeight() + 79 // 226
                case .competition: return StyleHelper.competitionCardsStyleHeight() + 20
                case .video: return 258
                }
            }
        case .userProfile:
            return 140
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let titleView = UIView()
        titleView.backgroundColor = UIColor.App.backgroundPrimary

        let titleStackView = UIStackView()
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.axis = .horizontal
        titleStackView.distribution = .fill
        titleStackView.alignment = .fill
        titleStackView.spacing = 8

        let sportImageView = UIImageView()
        sportImageView.translatesAutoresizingMaskIntoConstraints = false
        sportImageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.with(type: .bold, size: 17)

        let seeAllLabel = UILabel()
        seeAllLabel.translatesAutoresizingMaskIntoConstraints = false
        seeAllLabel.font = AppFont.with(type: .semibold, size: 12)
        seeAllLabel.textColor = UIColor.App.highlightPrimary
        seeAllLabel.text = "See All"
        seeAllLabel.isUserInteractionEnabled = true

        titleView.addSubview(titleStackView)
        titleView.addSubview(seeAllLabel)

        titleStackView.addArrangedSubview(sportImageView)
        titleStackView.addArrangedSubview(titleLabel)

        NSLayoutConstraint.activate([
            sportImageView.widthAnchor.constraint(equalTo: sportImageView.heightAnchor, multiplier: 1),
            sportImageView.widthAnchor.constraint(equalToConstant: 17),

            titleStackView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 18),
            titleStackView.topAnchor.constraint(equalTo: titleView.topAnchor),
            titleStackView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),

            seeAllLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -18),
            seeAllLabel.topAnchor.constraint(equalTo: titleView.topAnchor),
            seeAllLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
        ])

        if let title = self.viewModel.title(forSection: section) {
            titleLabel.text = title
        }

        if let imageName = self.viewModel.iconName(forSection: section) {
            sportImageView.image = UIImage(named: "sport_type_icon_\(imageName)")
        }
        else {
            sportImageView.isHidden = true
        }

        if case .userFavorites = self.viewModel.contentType(forSection: section) {
            seeAllLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOpenFavorites)))
        }
        else if case .featuredTips = self.viewModel.contentType(forSection: section) {
            seeAllLabel.text = "Expand"
            seeAllLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOpenFeaturedTips)))
        }
        else {
            seeAllLabel.isHidden = true
        }

        return titleView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.viewModel.shouldShowTitle(forSection: section) ? 40 : CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.viewModel.shouldShowTitle(forSection: section) ? 40 : CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return self.viewModel.shouldShowFooter(forSection: section) ? 40 : CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.viewModel.shouldShowFooter(forSection: section) ? 40 : CGFloat.leastNormalMagnitude
    }

}

extension HomeViewController: UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {

        for indexPath in indexPaths {
            guard
                let contentType = self.viewModel.contentType(forSection: indexPath.section)
            else {
                return
            }

            switch contentType {
            case .userMessage:
                ()
            case .bannerLine:
                _ = self.viewModel.bannerLineViewModel()
            case .userFavorites:
                ()
            case .featuredTips:
                ()
            case .suggestedBets:
                _ = self.viewModel.suggestedBetLineViewModel()
            case .sport:
                _ = self.viewModel.sportGroupViewModel(forSection: indexPath.section)
            case .userProfile:
                ()
            }
        }
    }
}

//
// MARK: - Actions
//
extension HomeViewController {

    @objc func didTapBetslipView() {
        self.didTapBetslipButtonAction?()
    }

    @objc func didTapChatView() {
        self.didTapChatButtonAction?()
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension HomeViewController {

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
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

    private func setupSubviews() {

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.loadingBaseView)
        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.view.addSubview(self.floatingShortcutsView)

        // Initialize constraints
        self.initConstraints()

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            self.floatingShortcutsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.floatingShortcutsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -12),
        ])

    }

}
