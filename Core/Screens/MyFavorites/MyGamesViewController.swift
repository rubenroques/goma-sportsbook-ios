//
//  MyGamesViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 01/08/2023.
//

import UIKit
import Combine
import ServicesProvider

class MyGamesViewModel {

    // MARK: Private Properties
    private var favoriteEventsIds: [String] = []

    private var cancellables = Set<AnyCancellable>()
    private var subscriptions = Set<ServicesProvider.Subscription>()

    // MARK: Public Properties
    var userFavoriteMatches: [Match] = []
    var userFavoritesBySportsArray: [FavoriteSportMatches] = []
    var matchesBySportList: [String: [Match]] = [:]

    var favoriteMatchesDataPublisher: CurrentValueSubject<[Match], Never> = .init([])
    var fetchedEventSummaryPublisher: CurrentValueSubject<[String], Never> = .init([])
    var dataChangedPublisher = PassthroughSubject<Void, Never>.init()
    var emptyStateStatusPublisher: CurrentValueSubject<EmptyStateType, Never> = .init(.none)
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    var initialLoading: Bool = true

    // Callbacks
    var didSelectMatchAction: ((Match) -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var matchWentLiveAction: (() -> Void)?
    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?

    var collapsedSportSections: Set<Int> = []

    var myGamesTypeList: MyGamesTypeList
    var myGamesFilterType: MyGamesFilterType

    // MARK: Caches
    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    enum MyGamesFilterType {
        case time
        case highOdds
    }

    init(myGamesTypeList: MyGamesTypeList, myGamesFilterType: MyGamesFilterType = .time) {

        self.myGamesTypeList = myGamesTypeList

        self.myGamesFilterType = myGamesFilterType

        Env.favoritesManager.favoriteMatchesIdPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] favoriteEvents in
                if Env.userSessionStore.isUserLogged() {
                    if self?.initialLoading == true {
                     self?.isLoadingPublisher.send(true)
                        self?.initialLoading = false
                    }
                    print("FAVORITE MATCHES: \(favoriteEvents)")
                    self?.favoriteEventsIds = favoriteEvents
                    self?.fetchFavoriteMatches()

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

                    self?.userFavoriteMatches = self?.favoriteMatchesDataPublisher.value ?? []

                    self?.filterMatchesByTypeList(matches: self?.userFavoriteMatches ?? [])

                }
            })
            .store(in: &cancellables)
    }

    func filterMatchesByTypeList(matches: [Match]) {

        var listMatches = [Match]()

        switch self.myGamesTypeList {
        case .all:
            listMatches = matches
        case .live:
            let filteredMatches = matches.filter({
                $0.status == .inProgress("")
            })

            listMatches = filteredMatches
        case .today:
            let filteredMatches = matches.filter({
                self.isDateToday($0.date ?? Date())
            })

            listMatches = filteredMatches
        case .tomorrow:
            let filteredMatches = matches.filter({
                self.isDateTomorrow($0.date ?? Date())
            })

            listMatches = filteredMatches
        case .thisWeek:
            let filteredMatches = matches.filter({
                self.isDateInThisWeek($0.date ?? Date())
            })

            listMatches = filteredMatches
        case .nextWeek:
            let filteredMatches = matches.filter({
                self.isDateInNextWeek($0.date ?? Date())
            })

            listMatches = filteredMatches
        }

        self.setupMatchesBySport(favoriteMatches: listMatches)
        self.updateContentList()

    }

    func matchStatsViewModel(forMatch match: Match) -> MatchStatsViewModel {
        if let viewModel = cachedMatchStatsViewModels[match.id] {
            return viewModel
        }
        else {
            let viewModel = MatchStatsViewModel(match: match)
            cachedMatchStatsViewModels[match.id] = viewModel
            return viewModel
        }
    }

    private func fetchFavoriteMatches() {

        if self.favoriteMatchesDataPublisher.value.isNotEmpty {
            self.favoriteMatchesDataPublisher.value = []
            self.fetchedEventSummaryPublisher.value = []
        }

        if self.favoriteEventsIds.isEmpty {
            self.updateContentList()
        }
        else {
            let favoriteMatchesIds = Env.favoritesManager.favoriteMatchesIdPublisher.value

            for eventId in favoriteMatchesIds {

                Env.servicesProvider.getEventSummary(eventId: eventId)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { [weak self] completion in
                        switch completion {
                        case .finished:
                            ()
                        case .failure(let error):
                            print("EVENT SUMMARY FAV ERROR: \(error)")

                            //Env.favoritesManager.removeFavorite(eventId: eventId, favoriteType: .match)
                        }

                        self?.fetchedEventSummaryPublisher.value.append(eventId)

                    }, receiveValue: { [weak self] eventSummary in
                        guard let self = self else { return }

                        if eventSummary.homeTeamName != "" || eventSummary.awayTeamName != "" {
                            let match = ServiceProviderModelMapper.match(fromEvent: eventSummary)
                            self.favoriteMatchesDataPublisher.value.append(match)
                            //self.fetchedEventSummaryPublisher.value.append(eventSummary.id)
                        }

                    })
                    .store(in: &cancellables)
            }

        }
    }

    private func updateContentList() {

        if Env.userSessionStore.isUserLogged() {
            if self.userFavoritesBySportsArray.isEmpty {

                self.emptyStateStatusPublisher.send(.noGames)
            }
            else if self.userFavoritesBySportsArray.isNotEmpty {
                self.emptyStateStatusPublisher.send(.none)
            }

        }
        else {
            self.emptyStateStatusPublisher.send(.noLogin)
        }

        self.isLoadingPublisher.send(false)
        self.dataChangedPublisher.send()

    }

    func setupMatchesBySport(favoriteMatches: [Match]) {

        self.matchesBySportList = [:]
        self.userFavoritesBySportsArray = []

        for match in favoriteMatches {
            if self.matchesBySportList[match.sport.name] != nil {
                self.matchesBySportList[match.sport.name]?.append(match)
            }
            else {
                self.matchesBySportList[match.sport.name] = [match]
            }
        }

        for (key, matches) in matchesBySportList {
                let favoriteSportMatch = FavoriteSportMatches(sportType: key, matches: matches)
            self.userFavoritesBySportsArray.append(favoriteSportMatch)
        }

        // Sort by sportId
        self.userFavoritesBySportsArray.sort {
            $0.sportType < $1.sportType
        }

        for index in 0..<self.userFavoritesBySportsArray.count {
            self.userFavoritesBySportsArray[index].matches.sort {
                $0.date ?? Date() < $1.date ?? Date()
            }
        }

    }

    // Helpers
    func isDateToday(_ date: Date) -> Bool {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return true
        }

        return false
    }

    func isDateTomorrow(_ date: Date) -> Bool {
        let calendar = Calendar.current
        if calendar.isDateInTomorrow(date) {
            return true
        }

        return false

    }

    func isDateInThisWeek(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let currentDate = Date()

        return calendar.isDate(date, equalTo: currentDate, toGranularity: .weekOfYear)
    }

    func isDateInNextWeek(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let currentDate = Date()

        if let nextSunday = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: (8 - calendar.component(.weekday, from: currentDate)), to: currentDate)!),
            let nextSaturday = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: calendar.date(byAdding: .day, value: 6, to: nextSunday)!) {

            return date >= nextSunday && date <= nextSaturday
        }

        return false
    }
}

class MyGamesViewController: UIViewController {

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

    // MARK: Public Properties
    var viewModel: MyGamesViewModel

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
    init(viewModel: MyGamesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        self.title = localized("my_games")

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
    private func bind(toViewModel viewModel: MyGamesViewModel) {

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
            self.emptyStateTitleLabel.text = localized("empty_my_games")

            self.isEmptyState = true
        case .noCompetitions:
            ()
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

    func reloadData() {
        self.tableView.reloadData()
    }

    // MARK: Actions
    @objc func didTapLoginButton() {
        let loginViewController = LoginViewController()

        self.present(loginViewController, animated: true, completion: nil)

        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: TableView Protocols
extension MyGamesViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {

        if self.viewModel.userFavoritesBySportsArray.isEmpty {
            return 1
        }
        else {
            return self.viewModel.userFavoritesBySportsArray.count
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let userFavorites = self.viewModel.userFavoritesBySportsArray[safe: section] {
            return userFavorites.matches.count
        }
        else {
            return 1
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if !self.viewModel.userFavoritesBySportsArray.isEmpty {
            if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
               let match = self.viewModel.userFavoritesBySportsArray[safe: indexPath.section]?.matches[indexPath.row] {

                if let matchStatsViewModel = self.viewModel.matchStatsViewModelForMatch?(match) {
                    cell.matchStatsViewModel = matchStatsViewModel
                }

                let viewModel = MatchLineTableCellViewModel(match: match)
                cell.viewModel = viewModel

                cell.tappedMatchLineAction = { [weak self] match in
                    self?.viewModel.didSelectMatchAction?(match)
                }
                cell.matchWentLive = { [weak self] in
                    self?.viewModel.matchWentLiveAction?()
                }

                return cell
            }
        }
        else {
            return UITableViewCell()
        }

        fatalError()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if !self.viewModel.userFavoritesBySportsArray.isEmpty {
            guard
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SportSectionHeaderView.identifier) as? SportSectionHeaderView
            else {
                fatalError()
            }

            if let favoriteMatch = self.viewModel.userFavoritesBySportsArray[section].matches.first {

                let sportName = favoriteMatch.sport.name
                let sportTypeId = favoriteMatch.sport.id

                headerView.configureHeader(title: sportName, sportTypeId: sportTypeId)

                headerView.sectionIndex = section

                headerView.didToggleHeaderViewAction = { [weak self, weak tableView] section in
                    guard
                        let weakSelf = self,
                        let weakTableView = tableView
                    else { return }

                    if weakSelf.viewModel.collapsedSportSections.contains(section) {
                        weakSelf.viewModel.collapsedSportSections.remove(section)
                    }
                    else {
                        weakSelf.viewModel.collapsedSportSections.insert(section)
                    }
                    weakSelf.needReloadSection(section, tableView: weakTableView)

                    if weakSelf.viewModel.collapsedSportSections.contains(section) {
                        headerView.setCollapseImage(isCollapsed: true)
                    }
                    else {
                        headerView.setCollapseImage(isCollapsed: false)
                    }

                }
                if self.viewModel.collapsedSportSections.contains(section) {
                    headerView.setCollapseImage(isCollapsed: true)
                }
                else {
                    headerView.setCollapseImage(isCollapsed: false)
                }

            }

            return headerView
        }
        else {
            return UIView()
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if self.viewModel.collapsedSportSections.contains(indexPath.section) {
            return 0
        }
        if self.viewModel.userFavoritesBySportsArray.isEmpty {
            return 600
        }
        else {
            return UITableView.automaticDimension
        }

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        if self.viewModel.collapsedSportSections.contains(indexPath.section) {
            return 0
        }
        if self.viewModel.userFavoritesBySportsArray.isEmpty {
            return 600
        }
        else {
            return StyleHelper.cardsStyleHeight() + 20
        }

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if !self.viewModel.userFavoritesBySportsArray.isEmpty {
            return 50
        }
        return 0.01

    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

        if !self.viewModel.userFavoritesBySportsArray.isEmpty {
            return 50
        }
        return 0.01

    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func needReloadSection(_ section: Int, tableView: UITableView) {

        guard let sportsSection = self.viewModel.userFavoritesBySportsArray[safe: section] else { return }

        let rows = (0 ..< sportsSection.matches.count).map({ IndexPath(row: $0, section: section) }) // all section rows

        tableView.beginUpdates()
        tableView.reloadRows(at: rows, with: .automatic)
        tableView.endUpdates()
    }

}

//
// MARK: Subviews initialization and setup
//
extension MyGamesViewController {

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
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
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
