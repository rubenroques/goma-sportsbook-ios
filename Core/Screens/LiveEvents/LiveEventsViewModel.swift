//
//  LiveEventsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/10/2021.
//

import UIKit
import Combine
import OrderedCollections
import ServicesProvider

class LiveEventsViewModel: NSObject {

    enum ScreenState {
        case emptyAndFilter
        case emptyNoFilter
        case contentNoFilter
        case contentAndFilter
    }
    
    var screenStatePublisher: CurrentValueSubject<ScreenState, Never> = .init(.emptyNoFilter)

    var isLoading: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest(self.isLoadingLiveSubject, self.isLoadingUpcomingSubject)
            .map({ isLoadingLive, isLoadingUpcoming in
                return isLoadingLive || isLoadingUpcoming
            })
            .eraseToAnyPublisher()
    }

    var liveEventsCountPublisher: CurrentValueSubject<Int, Never> = .init(0)
    var liveSportsCancellable: AnyCancellable?

    var resetScrollPosition: (() -> Void)?

    var dataDidChangedAction: (() -> Void)?
    var didSelectMatchAction: ((Match) -> Void)?

    var didSelectCompetitionAction: ((Competition) -> Void) = { _ in }
    
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var didLongPressOdd: ((BettingTicket) -> Void)?

    var shouldShowSearch: (() -> Void)?

    //
    // Selected Sport
    private var selectedSportSubject: CurrentValueSubject<Sport, Never>

    public var selectedSportPublisher: AnyPublisher<Sport, Never> {
        return self.selectedSportSubject.eraseToAnyPublisher()
    }

    public var selectedSport: Sport {
        return self.selectedSportSubject.value
    }
    //

    var liveSports: [Sport] = [] {
        didSet {
            self.configureWithSports(self.liveSports)
        }
    }

    var homeFilterOptions: HomeFilterOptions? {
        didSet {
            self.updateContentList()
        }
    }

    var mainMarkets: OrderedDictionary<String, Market> = [:]

    private var liveMatchesViewModelDataSource = LiveMatchesViewModelDataSource(liveMatches: [], upcomingMatches: [])

    private var liveMatches: [Match] = [] {
        didSet {
            print("LiveMatchesViewModel liveMatches did set")
        }
    }
    private var upcomingMatches: [Match] = []
    private var outrightCompetitions: [Competition] = []
    
    private var isLoadingLiveSubject: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingUpcomingSubject: CurrentValueSubject<Bool, Never> = .init(true)

    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    private var liveMatchesSubscriber: AnyCancellable?
    private var upcomingMatchesSubscriber: AnyCancellable?

    private var liveMatchesHasMorePages = true

    private var cancellables = Set<AnyCancellable>()

    private var liveMatchesSubscription: ServicesProvider.Subscription?
    private var upcomingMatchesSubscription: ServicesProvider.Subscription?

    private var sportsSubscription: ServicesProvider.Subscription?
    private var matchLineTableCellViewModelCache: [String: MatchLineTableCellViewModel] = [:]

    init(selectedSport: Sport) {

        self.selectedSportSubject = .init(selectedSport)

        super.init()

        self.connectPublishers()
        self.subscribeToLiveSports()

        self.liveMatchesViewModelDataSource.didSelectMatchAction = { [weak self] match in
            self?.didSelectMatchAction?(match)
        }

        self.liveMatchesViewModelDataSource.matchStatsViewModelForMatch = { [weak self] match in
            return self?.matchStatsViewModel(forMatch: match)
        }

        self.liveMatchesViewModelDataSource.didLongPressOdd = {[weak self] bettingTicket in
            self?.didLongPressOdd?(bettingTicket)
        }

        self.liveMatchesViewModelDataSource.shouldShowSearch = { [weak self] in
            self?.shouldShowSearch?()
        }

        self.liveMatchesViewModelDataSource.didSelectCompetitionAction = { [weak self] competition in
            self?.didSelectCompetitionAction(competition)
        }
        
    }

    func connectPublishers() {

        self.selectedSportPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newSport in
                self?.resetScrollPosition?()
                self?.fetchLiveMatches()
                self?.fetchUpcomingMatches()
                self?.configureWithSports(self?.liveSports ?? [])
            }
            .store(in: &self.cancellables)
        
        self.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.updateContentList()
                }
            }
            .store(in: &self.cancellables)

    }

    func subscribeToLiveSports() {

        self.sportsSubscription = nil

        Env.sportsStore.activeSportsPublisher
            .map({ loadableContent -> [Sport]? in
                switch loadableContent {
                case .loading, .idle, .failed: return nil
                case .loaded(let sports): return sports
                }
            })
            .filter({ $0 != nil })
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] allSports in
                let liveSports = allSports.filter({
                    $0.liveEventsCount > 0
                })
                print("LIVE SPORTS UPDATE: \(liveSports)")
                
                self?.liveSports = liveSports
            })
            .store(in: &cancellables)
        

    }

    func selectedSport(_ sport: Sport) {
        self.selectedSportSubject.send(sport)
    }

    func configureWithSports(_ liveSports: [Sport]) {
        var liveEventsCount: Int = 0
        for sport in liveSports {
            if sport.id == self.selectedSport.id {
                liveEventsCount = sport.liveEventsCount
                break
            }
        }
        self.liveEventsCountPublisher.send(liveEventsCount)
    }

    func getFirstMarketType() -> Market? {
        return self.mainMarkets.values.first
    }

    func getMarketType(marketTypeId: String) -> Market? {
        if self.mainMarkets.contains(where: {
            $0.value.marketTypeId == marketTypeId
        }) {
            return self.mainMarkets.values.first(where: {
                $0.marketTypeId == marketTypeId
            })
        }

        return nil
    }

    func markAsFavorite(match: Match) {
        
        var isFavorite = false
        for matchId in Env.favoritesManager.favoriteEventsIdPublisher.value where matchId == match.id {
            isFavorite = true
        }
        if isFavorite {
            Env.favoritesManager.removeFavorite(eventId: match.id, favoriteType: .match)
        }
        else {
            Env.favoritesManager.addFavorite(eventId: match.id, favoriteType: .match)
        }
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
    
    func filterLiveMatches(with filtersOptions: HomeFilterOptions?, matches: [Match]) -> [Match] {
        guard let filterOptionsValue = filtersOptions else {
            return matches
        }

        var filteredMatches: [Match] = []
        for match in matches {
            if match.markets.isEmpty {
                continue
            }
            // Check default market order
            var marketSort: [Market] = []
//            let favoriteMarketIndex = match.markets.firstIndex(where: { $0.typeId == filterOptionsValue.defaultMarket.marketId })
            let favoriteMarketIndex = match.markets.firstIndex(where: { $0.typeId == filterOptionsValue.defaultMarket?.id })
            marketSort.append(match.markets[favoriteMarketIndex ?? 0])
            for market in match.markets where market.typeId != marketSort[0].typeId {
                marketSort.append(market)
            }

            // Check odds filter
            let matchOdds = marketSort[0].outcomes
            let oddsRange = filterOptionsValue.lowerBoundOddsRange...filterOptionsValue.highBoundOddsRange
            for odd in matchOdds {
                let oddValue = CGFloat(odd.bettingOffer.decimalOdd)
                if oddsRange.contains(oddValue) {
                    var newMatch = match
                    newMatch.markets = marketSort

                    filteredMatches.append(newMatch)
                    break
                }
            }

        }
        return filteredMatches
    }

    private func updateContentList() {

        self.liveMatchesViewModelDataSource.liveMatches = filterLiveMatches(with: self.homeFilterOptions, matches: self.liveMatches)
        self.liveMatchesViewModelDataSource.upcomingMatches = filterLiveMatches(with: self.homeFilterOptions, matches: self.upcomingMatches)
        self.liveMatchesViewModelDataSource.outrightCompetitions = self.outrightCompetitions
        
        if let numberOfFilters = self.homeFilterOptions?.countFilters {
            if numberOfFilters > 0 {
                if self.liveMatchesViewModelDataSource.isEmpty {
                    self.screenStatePublisher.send(.emptyAndFilter)
                }
                else {
                    self.screenStatePublisher.send(.contentAndFilter)
                }
            }
            else {
                if !self.liveMatchesViewModelDataSource.liveMatches.isNotEmpty {
                    self.screenStatePublisher.send(.emptyNoFilter)
                }
                else {
                    self.screenStatePublisher.send(.contentNoFilter)
                }
            }
        }
        else {
            if self.liveMatchesViewModelDataSource.isEmpty {
                self.screenStatePublisher.send(.emptyNoFilter)
            }
            else {
                self.screenStatePublisher.send(.contentNoFilter)
            }
        }
        
        self.dataDidChangedAction?()
    }

    //
    // MARK: - Fetches
    //
    //

    func fetchLiveMatches() {

        self.liveMatchesHasMorePages = true
        self.liveMatchesSubscriber?.cancel()

        self.liveMatchesSubscription = nil

        // Clear old data from the array of liveMatches
        self.liveMatches = []

        self.isLoadingLiveSubject.send(true)

        let sportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.selectedSport)

        self.liveMatchesSubscriber = Env.servicesProvider.subscribeLiveMatches(forSportType: sportType)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                // TODO: subscribeLiveMatches receiveCompletion
                switch completion {
                case .finished:
                    Logger.log("subscribeLiveMatches finished")
                case .failure(let error):
                    Logger.log("subscribeLiveMatches error \(error)")
                    self?.liveMatches = []
                }
                self?.isLoadingLiveSubject.send(false)
            }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
                switch subscribableContent {
                case .connected(let subscription):
                    Logger.log("subscribeLiveMatches connected")
                    self?.liveMatchesSubscription = subscription
                case .contentUpdate(let eventsGroups):
                    Logger.log("subscribeLiveMatches content")
                    self?.liveMatches = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups)
                    if let liveMatches = self?.liveMatches {
                        self?.setMainMarkets(matches: liveMatches)
                    }
                    self?.isLoadingLiveSubject.send(false)
                case .disconnected:
                    Logger.log("subscribeLiveMatches disconnected")
                }
            })
    }

    private func fetchUpcomingMatches() {

        // Clear old data from the array of upcomingMatches
        self.upcomingMatches = []
        self.outrightCompetitions = []
        
        self.isLoadingUpcomingSubject.send(true)

        let selectedSportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.selectedSport)

        // We need to clear old subscriptions and publisher cancellables
        self.upcomingMatchesSubscriber = nil
        self.upcomingMatchesSubscriber?.cancel()

        self.upcomingMatchesSubscriber = Env.servicesProvider.subscribePreLiveMatches(forSportType: selectedSportType,
                                                                                  initialDate: nil,
                                                                                  endDate: nil,
                                                                                  sortType: .date)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("TodayMatchesDataSource fetchUpcomingMatches error: \(error)")
                    self?.upcomingMatches = []
                    self?.outrightCompetitions = []
                }
                self?.isLoadingUpcomingSubject.send(false)
            }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
                switch subscribableContent {
                case .connected(let subscription):
                    self?.upcomingMatchesSubscription = subscription

                case .contentUpdate(let eventsGroups):
                    guard let self = self else { return }

                    let splittedEventGroups = self.splitEventsGroups(eventsGroups)

                    let mappedOutrights: [Competition]? = ServiceProviderModelMapper.competitions(fromEventsGroups: splittedEventGroups.competitionsEventGroups)
                    self.outrightCompetitions = mappedOutrights ?? []
                    
                    let mappedMatches = ServiceProviderModelMapper.matches(fromEventsGroups: splittedEventGroups.matchesEventGroups)
                    self.upcomingMatches = mappedMatches

                    self.isLoadingUpcomingSubject.send(false)
                case .disconnected:
                    print("TodayMatchesDataSource fetchUpcomingMatches disconnected")
                }
            })
    }

    func setMainMarkets(matches: [Match]) {
        self.mainMarkets = [:]

        for match in matches {

            for market in match.markets {
                if let marketTypeId = market.marketTypeId {
                    self.mainMarkets[marketTypeId] = market
                }
            }
        }
    }

}

extension LiveEventsViewModel: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.liveMatchesViewModelDataSource.numberOfSections(in: tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.liveMatchesViewModelDataSource.tableView(tableView, numberOfRowsInSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.liveMatchesViewModelDataSource.tableView(tableView, cellForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        return self.liveMatchesViewModelDataSource.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.liveMatchesViewModelDataSource.tableView(tableView, viewForHeaderInSection: section)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.liveMatchesViewModelDataSource.tableView(tableView, heightForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.liveMatchesViewModelDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.liveMatchesViewModelDataSource.tableView(tableView, heightForHeaderInSection: section)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.liveMatchesViewModelDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}

// Helpers
extension LiveEventsViewModel {

    func matchLineTableCellViewModel(forMatch match: Match) -> MatchLineTableCellViewModel {
        if let matchLineTableCellViewModel = self.matchLineTableCellViewModelCache[match.id] {
            return matchLineTableCellViewModel
        }
        else {
            let matchLineTableCellViewModel = MatchLineTableCellViewModel(match: match, withFullMarkets: false)
            self.matchLineTableCellViewModelCache[match.id] = matchLineTableCellViewModel
            return matchLineTableCellViewModel
        }
    }

    private func splitEventsGroups(_ eventsGroups: [EventsGroup]) -> (matchesEventGroups: [EventsGroup], competitionsEventGroups: [EventsGroup]) {

        var matchEventsGroups: [EventsGroup] = []
        for eventGroup in eventsGroups {
            let matchEvents = eventGroup.events.filter { event in
                event.type == .match
            }
            matchEventsGroups.append(EventsGroup(events: matchEvents, marketGroupId: eventGroup.marketGroupId))
        }

        //
        var competitionEventsGroups: [EventsGroup] = []
        for eventGroup in eventsGroups {
            let competitionEvents = eventGroup.events.filter { event in
                event.type == .competition
            }
            competitionEventsGroups.append(EventsGroup(events: competitionEvents, marketGroupId: eventGroup.marketGroupId))
        }

        return (matchEventsGroups, competitionEventsGroups)
    }

}

class LiveMatchesViewModelDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var liveMatches: [Match] = [] {
        didSet {
            print("LiveMatchesViewModelDataSource liveMatches did set")
        }
    }
    
    var upcomingMatches: [Match] = []
    
    var outrightCompetitions: [Competition] = []
    
    var didSelectMatchAction: ((Match) -> Void)?
    
    var didTapFavoriteAction: ((Match) -> Void)?
    var didLongPressOdd: ((BettingTicket) -> Void)?
    var shouldShowSearch: (() -> Void)?
    
    var didSelectCompetitionAction: ((Competition) -> Void) = { _ in }
    
    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?
        
    var isEmpty: Bool {
        return self.liveMatches.isEmpty && self.upcomingMatches.isEmpty && self.outrightCompetitions.isEmpty
    }
    
    init(liveMatches: [Match], upcomingMatches: [Match]) {
        self.liveMatches = liveMatches
        self.upcomingMatches = upcomingMatches
        
        super.init()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.liveMatches.count
        case 1:
            return self.liveMatches.isEmpty ? 1 : 0
        case 2:
            return 0 // LoadingMoreTableViewCell
        case 3:
            return self.upcomingMatches.count
        case 4:
            return self.shouldShowOutrightMarkets() ? self.outrightCompetitions.count : 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
               let match = self.liveMatches[safe: indexPath.row] {
                
                if let matchStatsViewModel = self.matchStatsViewModelForMatch?(match) {
                    cell.matchStatsViewModel = matchStatsViewModel
                }
                
                let viewModel = MatchLineTableCellViewModel(match: match)
                cell.viewModel = viewModel
                
                cell.tappedMatchLineAction = { [weak self] match in
                    self?.didSelectMatchAction?(match)
                }
                cell.didLongPressOdd = { [weak self] bettingTicket in
                    self?.didLongPressOdd?(bettingTicket)
                }
                
                return cell
            }
        case 1:
            if let cell = tableView.dequeueCellType(EmptyLiveMessageBannerTableViewCell.self) {
                return cell
            }
        case 2:
            if let cell = tableView.dequeueCellType(LoadingMoreTableViewCell.self) {
                return cell
            }
        case 3:
            if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
               let match = self.upcomingMatches[safe: indexPath.row] {
                
                if let matchStatsViewModel = self.matchStatsViewModelForMatch?(match) {
                    cell.matchStatsViewModel = matchStatsViewModel
                }
                
                let viewModel = MatchLineTableCellViewModel(match: match)
                cell.viewModel = viewModel
                
                cell.tappedMatchLineAction = { [weak self] match in
                    self?.didSelectMatchAction?(match)
                }
                cell.didLongPressOdd = { [weak self] bettingTicket in
                    self?.didLongPressOdd?(bettingTicket)
                }
                
                return cell
            }
        case 4:
            if let cell = tableView.dequeueReusableCell(withIdentifier: OutrightCompetitionLargeLineTableViewCell.identifier)
                as? OutrightCompetitionLargeLineTableViewCell,
               let competition = self.outrightCompetitions[safe: indexPath.row] {
                
                cell.configure(withViewModel: OutrightCompetitionLargeLineViewModel(competition: competition))
                cell.didSelectCompetitionAction = { [weak self] competition in
                    self?.didSelectCompetitionAction(competition)
                }
                return cell
            }
            
        default:
            fatalError()
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case 0:
            if self.liveMatches.isEmpty {
                return nil // No live events -> No header
            }
            
            guard
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier) as? TitleTableViewHeader
            else {
                fatalError()
            }
            headerView.configureWithTitle(localized("all_live_events"))
            headerView.setSearchIcon(hasSearch: true)
            headerView.shouldShowSearch = { [weak self] in
                self?.shouldShowSearch?()
            }
            return headerView
        case 3:
            if self.upcomingMatches.isEmpty {
                return nil
            }
            guard
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier) as? TitleTableViewHeader
            else {
                fatalError()
            }
            headerView.configureWithTitle(localized("upcoming"))
            headerView.setSearchIcon(hasSearch: false)
            headerView.shouldShowSearch = { [weak self] in
                self?.shouldShowSearch?()
            }
            return headerView
        case 4:
            if self.upcomingMatches.isNotEmpty || self.outrightCompetitions.isEmpty {
                return nil
            }
            guard
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier) as? TitleTableViewHeader
            else {
                fatalError()
            }
            headerView.configureWithTitle(localized("upcoming"))
            headerView.setSearchIcon(hasSearch: false)
            headerView.shouldShowSearch = { [weak self] in
                self?.shouldShowSearch?()
            }
            return headerView
        default:
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return self.liveMatches.isEmpty ? 0.001 : 54
        case 3:
            return self.upcomingMatches.isEmpty ? 0.001 : 54
        case 4:
            return self.outrightCompetitions.isEmpty ? 0.001 : 54
        default:
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return self.liveMatches.isEmpty ? 0.001 : 54
        case 3:
            return self.upcomingMatches.isEmpty ? 0.001 : 54
        case 4:
            return self.outrightCompetitions.isEmpty ? 0.001 : 54
        default:
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 2:
            return 70 // Loading cell
        case 4:
            return 145 // Outrights
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 2:
            return 70 // Loading cell
        case 4:
            return 145 // Outrights
        default:
            return StyleHelper.cardsStyleHeight() + 20
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
}

extension LiveMatchesViewModelDataSource {
    
    private func shouldShowOutrightMarkets() -> Bool {
        return self.upcomingMatches.isEmpty
    }

}
