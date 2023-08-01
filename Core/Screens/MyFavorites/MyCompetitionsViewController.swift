//
//  MyCompetitionsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 31/07/2023.
//

import UIKit
import Combine
import ServicesProvider

class MyCompetitionsViewModel {

    var competitions: [Competition] = []
    var outrightCompetitions: [Competition] = []
    var collapsedCompetitionsSections: Set<Int> = []
    var cachedMatchWidgetCellViewModels: [String: MatchWidgetCellViewModel] = [:]

    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?

    var favoriteEventsIds: [String] = []
    var favoriteCompetitionsDataPublisher: CurrentValueSubject<[Competition], Never> = .init([])
    var favoriteOutrightCompetitionsDataPublisher: CurrentValueSubject<[Competition], Never> = .init([])

    var fetchedEventSummaryPublisher: CurrentValueSubject<[String], Never> = .init([])
    var selectedCompetitionsInfoPublisher: CurrentValueSubject<[String: SportCompetitionInfo], Never> = .init([:])
    var expectedCompetitionsPublisher: CurrentValueSubject<Int, Never> = .init(0)

    var dataChangedPublisher = PassthroughSubject<Void, Never>.init()
    var emptyStateStatusPublisher: CurrentValueSubject<EmptyStateType, Never> = .init(.none)

    var initialLoading: Bool = true

    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    private var cancellables = Set<AnyCancellable>()
    private var subscriptions = Set<ServicesProvider.Subscription>()

    // Callbacks
    var didSelectMatchAction: ((Match) -> Void)?
    var didTapFavoriteCompetitionAction: ((Competition) -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var didSelectCompetitionAction: ((Competition) -> Void)?
    var matchWentLiveAction: (() -> Void)?

    init() {

        Env.favoritesManager.favoriteEventsIdPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] favoriteEvents in
                if Env.userSessionStore.isUserLogged() {
                    if self?.initialLoading == true {
                     self?.isLoadingPublisher.send(true)
                        self?.initialLoading = false
                    }
                    self?.favoriteEventsIds = favoriteEvents
                    self?.fetchFavoriteCompetitionMatches()

                }
                else {
                    self?.isLoadingPublisher.send(false)
                    self?.dataChangedPublisher.send()
                    self?.emptyStateStatusPublisher.send(.noLogin)
                }
            })
            .store(in: &cancellables)

        self.fetchedEventSummaryPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self]  fetchedEventsSummmary in

                print("FETCHED COUNT: \(fetchedEventsSummmary.count)")

                if fetchedEventsSummmary.count == self?.favoriteEventsIds.count && fetchedEventsSummmary.isNotEmpty {
                    self?.updateContentList()
                }
            })
            .store(in: &cancellables)

        Publishers.CombineLatest(self.expectedCompetitionsPublisher, self.selectedCompetitionsInfoPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] expectedCompetitions, selectedCompetitionsInfo in

                if selectedCompetitionsInfo.count == expectedCompetitions {
                    print("ALL COMPETITIONS DATA")
                    self?.processCompetitionsInfo()
                }
            })
            .store(in: &cancellables)

    }

    private func fetchFavoriteCompetitionMatches() {
        if self.favoriteCompetitionsDataPublisher.value.isNotEmpty {
            self.favoriteCompetitionsDataPublisher.value = []
        }

        let favoriteCompetitionIds = Env.favoritesManager.favoriteCompetitionsIdPublisher.value

        self.expectedCompetitionsPublisher.value = favoriteCompetitionIds.count

        self.fetchFavoriteCompetitionsMatchesWithIds(favoriteCompetitionIds)
    }

    func fetchFavoriteCompetitionsMatchesWithIds(_ ids: [String]) {

        self.selectedCompetitionsInfoPublisher.value = [:]

        for competitionId in ids {
            Env.servicesProvider.getCompetitionMarketGroups(competitionId: competitionId)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        ()
                    case .failure(let error):
                        print("COMPETITION INFO ERROR: \(error)")
                        self?.selectedCompetitionsInfoPublisher.value[competitionId] = nil
                    }

                }, receiveValue: { [weak self] competitionInfo in

                    self?.selectedCompetitionsInfoPublisher.value[competitionInfo.id] = competitionInfo
                })
                .store(in: &cancellables)
        }

    }

    func processCompetitionsInfo() {

        let competitionInfos = self.selectedCompetitionsInfoPublisher.value.map({$0.value})

        self.favoriteCompetitionsDataPublisher.value = []

        for competitionInfo in competitionInfos {

            if let marketGroup = competitionInfo.marketGroups.filter({
                $0.name.lowercased().contains("main")
            }).first {
                self.subscribeCompetitionMatches(forMarketGroupId: marketGroup.id, competitionInfo: competitionInfo)

            }
            else {
                self.fetchedEventSummaryPublisher.value.append(competitionInfo.id)
            }
        }
    }

    func subscribeCompetitionMatches(forMarketGroupId marketGroupId: String, competitionInfo: SportCompetitionInfo) {

        Env.servicesProvider.subscribeCompetitionMatches(forMarketGroupId: marketGroupId)
        .sink { [weak self] (completion: Subscribers.Completion<ServiceProviderError>) in
            switch completion {
            case .finished:
                ()
            case .failure:
                print("SUBSCRIPTION COMPETITION MATCHES ERROR")
            }
        } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
            switch subscribableContent {
            case .connected(let subscription):
                self?.subscriptions.insert(subscription)
            case .contentUpdate(let eventsGroups):
                let matches = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups)
                self?.processCompetitionMatches(matches: matches, competitionInfo: competitionInfo)
            case .disconnected:
                ()
            }
        }
        .store(in: &cancellables)
    }

    private func processCompetitionMatches(matches: [Match], competitionInfo: SportCompetitionInfo) {

        let newCompetition = Competition(id: competitionInfo.id,
                                         name: competitionInfo.name,
                                         matches: matches,
                                         sport: nil,
                                         numberOutrightMarkets: Int(competitionInfo.numberOutrightMarkets) ?? 0,
        competitionInfo: competitionInfo)

        self.favoriteCompetitionsDataPublisher.value.append(newCompetition)

        self.fetchedEventSummaryPublisher.value.append(competitionInfo.id)

    }

    private func updateContentList() {

        if Env.userSessionStore.isUserLogged() {
            if self.favoriteCompetitionsDataPublisher.value.isEmpty &&
                self.favoriteOutrightCompetitionsDataPublisher.value.isEmpty {

                self.emptyStateStatusPublisher.send(.noCompetitions)
            }
            else if self.favoriteCompetitionsDataPublisher.value.isNotEmpty {
                self.emptyStateStatusPublisher.send(.none)
            }

        }
        else {
            self.emptyStateStatusPublisher.send(.noLogin)
        }

        self.competitions = self.favoriteCompetitionsDataPublisher.value

        self.outrightCompetitions = self.favoriteOutrightCompetitionsDataPublisher.value

        self.isLoadingPublisher.send(false)
        self.dataChangedPublisher.send()

    }
}

class MyCompetitionsViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var containerView: GradientView = Self.createContainerView()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var loadingScreenBaseView: UIView = Self.createLoadingScreenBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()

    private lazy var emptyStateView: UIView = Self.createEmptyStateView()
    private lazy var emptyStateImageView: UIImageView = Self.createEmptyStateImageView()
    private lazy var emptyStateTitleLabel: UILabel = Self.createEmptyStateTitleLabel()
    private lazy var emptyStateLoginButton: UIButton = Self.createEmptyStateLoginButton()

    private var cancellables = Set<AnyCancellable>()

    private var myFavoriteCompetitionsDataSource = MyFavoriteCompetitionsDataSource(favoriteCompetitions: [], favoriteOutrightCompetitions: [])

    // MARK: Public Properties
    var viewModel: MyCompetitionsViewModel

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
        self.viewModel = MyCompetitionsViewModel()
        super.init(nibName: nil, bundle: nil)

        self.title = localized("my_competitions")

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

//        self.myFavoriteCompetitionsDataSource.didSelectCompetitionAction = { competition in
//            let viewModel = OutrightMarketDetailsViewModel(competition: competition, store: OutrightMarketDetailsStore())
//            let outrightMarketDetailsViewController = OutrightMarketDetailsViewController(viewModel: viewModel)
//            self.navigationController?.pushViewController(outrightMarketDetailsViewController, animated: true)
//        }

        self.isEmptyState = false

        self.emptyStateLoginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)

    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary

        if TargetVariables.shouldUseGradientBackgrounds {
            self.containerView.colors = [(UIColor.App.backgroundGradient1, NSNumber(0.0)),
                                         (UIColor.App.backgroundGradient2, NSNumber(1.0))]
        }
        else {
            self.containerView.colors = []
            self.containerView.backgroundColor = UIColor.App.backgroundPrimary
        }

        self.tableView.backgroundColor = .clear

        self.loadingScreenBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)
        self.emptyStateView.backgroundColor = .clear

    }

    // MARK: Binding
    private func bind(toViewModel viewModel: MyCompetitionsViewModel) {

        viewModel.didSelectMatchAction = { [weak self] match in
            let matchDetailsViewController = MatchDetailsViewController(viewModel: MatchDetailsViewModel(match: match))
            self?.navigationController?.pushViewController(matchDetailsViewController, animated: true)
        }

        viewModel.didSelectMatchAction = { [weak self] match in
            let matchDetailsViewController = MatchDetailsViewController(viewModel: MatchDetailsViewModel(match: match))
            self?.navigationController?.pushViewController(matchDetailsViewController, animated: true)
        }

        viewModel.matchWentLiveAction = { [weak self] in
            self?.tableView.reloadData()
        }

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

    }

    // MARK: Functions
    private func setupEmptyStateView(emptyStateType: EmptyStateType, hasLogin: Bool = false) {

        switch emptyStateType {
        case .noLogin:
            self.emptyStateTitleLabel.text = localized("need_login_favorites")
            self.isEmptyState = true
        case .noGames:
            ()
        case .noCompetitions:
            self.emptyStateTitleLabel.text = localized("empty_my_competitions")

            self.isEmptyState = true

        case .noFavorites:
            ()
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

    // MARK: Actions
    @objc func didTapLoginButton() {
        let loginViewController = LoginViewController()

        self.present(loginViewController, animated: true, completion: nil)

        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: TableView Protocols
extension MyCompetitionsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {

        let outrightsSections = 1
        let competitionsCount = self.viewModel.competitions.count
        return  outrightsSections + competitionsCount
    }

    func hasContentForSelectedListType() -> Bool {

        self.viewModel.competitions.isNotEmpty

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return self.viewModel.outrightCompetitions.count
        }
        if let competition = self.viewModel.competitions[safe: section-1] {
            return competition.matches.count
        }
        else {
            return 0
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: OutrightCompetitionLargeLineTableViewCell.identifier)
                    as? OutrightCompetitionLargeLineTableViewCell,
                let competition = self.viewModel.outrightCompetitions[safe: indexPath.row]
            else {
                fatalError()
            }

            cell.configure(withViewModel: OutrightCompetitionLargeLineViewModel(competition: competition))
            cell.didSelectCompetitionAction = { [weak self] competition in
                self?.viewModel.didSelectCompetitionAction?(competition)
            }
            return cell
        }
        else {
            guard
                let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
                let competition = self.viewModel.competitions[safe: indexPath.section-1],
                let match = competition.matches[safe: indexPath.row]
            else {
                fatalError()
            }

            if let matchStatsViewModel = self.viewModel.matchStatsViewModelForMatch?(match) {
                cell.matchStatsViewModel = matchStatsViewModel
            }

            if !self.viewModel.collapsedCompetitionsSections.contains(indexPath.section) {

                let viewModel = MatchLineTableCellViewModel(match: match)
                cell.viewModel = viewModel

                cell.shouldShowCountryFlag(false)
                cell.tappedMatchLineAction = { [weak self] match in
                    self?.viewModel.didSelectMatchAction?(match)
                }
                cell.matchWentLive = { [weak self] in
                    self?.viewModel.matchWentLiveAction?()
                }
            }

            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if section == 0 {
            return nil
        }
        else {

            guard
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TournamentTableViewHeader.identifier)
                    as? TournamentTableViewHeader,
                let competition = self.viewModel.competitions[safe: section-1]
            else {
                if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier)
                    as? TitleTableViewHeader {
                    headerView.configureWithTitle(localized("my_competitions"))
                    return headerView
                }
                return UIView()
            }

            headerView.nameTitleLabel.text = competition.name
            headerView.countryFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: competition.venue?.isoCode ?? ""))
            headerView.sectionIndex = section
            headerView.competition = competition
            headerView.didToggleHeaderViewAction = { [weak self, weak tableView] section in
                guard
                    let weakSelf = self,
                    let weakTableView = tableView
                else { return }

                if weakSelf.viewModel.collapsedCompetitionsSections.contains(section) {
                    weakSelf.viewModel.collapsedCompetitionsSections.remove(section)
                }
                else {
                    weakSelf.viewModel.collapsedCompetitionsSections.insert(section)
                }

                weakSelf.needReloadSection(section, tableView: weakTableView)

                if weakSelf.viewModel.collapsedCompetitionsSections.contains(section) {
                    headerView.collapseImageView.image = UIImage(named: "arrow_down_icon")
                }
                else {
                    headerView.collapseImageView.image = UIImage(named: "arrow_up_icon")
                }
            }
            if self.viewModel.collapsedCompetitionsSections.contains(section) {
                headerView.collapseImageView.image = UIImage(named: "arrow_down_icon")
            }
            else {
                headerView.collapseImageView.image = UIImage(named: "arrow_up_icon")
            }

            headerView.didTapFavoriteCompetitionAction = {[weak self] competition in
                self?.viewModel.didTapFavoriteCompetitionAction?(competition)
            }

            return headerView
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.section == 0 {
            switch StyleHelper.cardsStyleActive() {
            case .small: return  125
            case .normal: return 154
            }
        }
        else if self.viewModel.collapsedCompetitionsSections.contains(indexPath.section) {
            return .leastNormalMagnitude
        }
        else if self.viewModel.competitions.isEmpty {
            return 600
        }
        else {
            return UITableView.automaticDimension
        }

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.section == 0 {
            switch StyleHelper.cardsStyleActive() {
            case .small: return  125
            case .normal: return 154
            }
        }
        else if self.viewModel.collapsedCompetitionsSections.contains(indexPath.section) {
            return .leastNormalMagnitude
        }
        else if self.viewModel.competitions.isEmpty {
            return 600
        }
        else {
            return StyleHelper.cardsStyleHeight() + 20
        }

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if section == 0 {
            if self.viewModel.outrightCompetitions.isEmpty {
                return 0.01
            }

            return .leastNormalMagnitude
        }
        else {
            return 54
        }

    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

        if section == 0 {
            if self.viewModel.outrightCompetitions.isEmpty {
                return 0.01
            }
            
            return .leastNormalMagnitude
        }
        else {
            return 54
        }

    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func needReloadSection(_ section: Int, tableView: UITableView) {

        guard let competition = self.viewModel.competitions[safe: section-1] else { return }

        let rows = (0 ..< competition.matches.count).map({ IndexPath(row: $0, section: section) }) // all section rows

        tableView.beginUpdates()
        tableView.reloadRows(at: rows, with: .automatic)
        tableView.endUpdates()
    }

}

//
// MARK: Subviews initialization and setup
//
extension MyCompetitionsViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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

        self.view.addSubview(self.containerView)

        self.containerView.addSubview(self.tableView)

        self.containerView.addSubview(self.loadingScreenBaseView)

        self.loadingScreenBaseView.addSubview(self.activityIndicatorView)
        self.loadingScreenBaseView.bringSubviewToFront(self.activityIndicatorView)

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

        // TableView
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
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

        // Empty state view
        NSLayoutConstraint.activate([
            self.emptyStateView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.emptyStateView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.emptyStateView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
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
