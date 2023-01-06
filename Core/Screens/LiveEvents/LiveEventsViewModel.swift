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

    private var liveMatches: [Match] = []

    var mainMarkets: OrderedDictionary<String, Market> = [:]

    var matchListTypePublisher: CurrentValueSubject<MatchListType, Never> = .init(.liveMatches)
   
    enum MatchListType {
        case liveMatches
    }

    enum ScreenState {
        case emptyAndFilter
        case emptyNoFilter
        case contentNoFilter
        case contentAndFilter
    }
    
    var screenStatePublisher: CurrentValueSubject<ScreenState, Never> = .init(.emptyNoFilter)
    
    private var liveMatchesViewModelDataSource = LiveMatchesViewModelDataSource(matches: [])

    private var isLoadingAllEventsList: CurrentValueSubject<Bool, Never> = .init(true)

    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    var isLoading: AnyPublisher<Bool, Never>
    var isUserLoggedPublisher: CurrentValueSubject<Bool, Never> = .init(true)

    var liveEventsCountPublisher: CurrentValueSubject<Int, Never> = .init(0)
    var liveSportsCancellable: AnyCancellable?

    var resetScrollPosition: (() -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var didLongPressOdd: ((BettingTicket) -> Void)?

    var didChangeSportType = false
    var selectedSport: Sport {
        willSet {
            if newValue.id != self.selectedSport.id {
                self.didChangeSportType = true
            }
        }
        didSet {
            if didChangeSportType {
                self.resetScrollPosition?()
                self.fetchLiveMatches()
                self.configureWithSports(self.liveSports)
                self.didChangeSportType = false
            }
        }
    }

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
    var dataDidChangedAction: (() -> Void)?
    var didSelectMatchAction: ((Match) -> Void)?

    private var liveMatchesSubscriber: AnyCancellable?

    private var liveMatchesHasMorePages = true

    private var cancellables = Set<AnyCancellable>()
    private var subscriptions = Set<ServicesProvider.Subscription>()
    
    init(selectedSport: Sport) {

        self.selectedSport = selectedSport
        self.isLoading = isLoadingAllEventsList.eraseToAnyPublisher()

        super.init()

        self.subscribeToLiveSports()

        self.liveMatchesViewModelDataSource.requestNextPage = { [weak self] in
            self?.fetchLiveMatchesNextPage()
        }

        self.liveMatchesViewModelDataSource.didSelectMatchAction = { [weak self] match in
            self?.didSelectMatchAction?(match)
        }
        
//        self.liveMatchesViewModelDataSource.didTapFavoriteAction = { [weak self] match in
//            self?.didTapFavoriteMatchAction?(match)
//        }

        self.liveMatchesViewModelDataSource.matchStatsViewModelForMatch = { [weak self] match in
            return self?.matchStatsViewModel(forMatch: match)
        }

        self.liveMatchesViewModelDataSource.isUserLoggedPublisher.receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLogged in
                self?.isUserLoggedPublisher.send(isLogged)
            })
            .store(in: &self.cancellables)

        self.liveMatchesViewModelDataSource.didLongPressOdd = {[weak self] bettingTicket in
            self?.didLongPressOdd?(bettingTicket)
        }

    }

    func subscribeToLiveSports() {

        self.liveSportsCancellable = Env.servicesProvider.subscribeLiveSportTypes()
            .sink(receiveCompletion: { completion in
                print("LiveEventsViewModel subscribeLiveSportTypes completed \(completion)")
            }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[SportType]>) in
                switch subscribableContent {
                case .connected(let subscription):
                    self?.subscriptions.insert(subscription)
                    self?.liveSports = []
                case .contentUpdate(let sportTypes):
                    let sports = sportTypes.map(ServiceProviderModelMapper.sport(fromServiceProviderSportType:))
                    self?.liveSports = sports
                case .disconnected:
                    self?.liveSports = []
                }
            })
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

    func setMatchListType(_ matchListType: MatchListType) {
        self.matchListTypePublisher.send(matchListType)
        self.updateContentList()
    }

    private func updateContentList() {

        self.liveMatchesViewModelDataSource.matches = filterLiveMatches(with: self.homeFilterOptions, matches: self.liveMatches)

        if let numberOfFilters = self.homeFilterOptions?.countFilters {
            if numberOfFilters > 0 {
                if self.liveMatchesViewModelDataSource.matches.isEmpty {
                    self.screenStatePublisher.send(.emptyAndFilter)
                }
                else {
                    self.screenStatePublisher.send(.contentAndFilter)
                }
            }
            else {
                if !self.liveMatchesViewModelDataSource.matches.isNotEmpty {
                    self.screenStatePublisher.send(.emptyNoFilter)
                }
                else {
                    self.screenStatePublisher.send(.contentNoFilter)
                }
            }
        }
        else {
            if self.liveMatchesViewModelDataSource.matches.isEmpty {
                self.screenStatePublisher.send(.emptyNoFilter)
            }
            else {
                self.screenStatePublisher.send(.contentNoFilter)
            }
        }

        self.liveMatchesViewModelDataSource.shouldShowLoadingCell = false

        // TODO: - Code Review
        DispatchQueue.main.async {
            self.dataDidChangedAction?()
        }
    }

    //
    // MARK: - Fetches
    //
    //
    private func fetchLiveMatchesNextPage() {
        let sportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.selectedSport)
        Env.servicesProvider.requestLiveMatchesNextPage(forSportType: sportType)
            .sink { completion in
                print("requestPreLiveMatchesNextPage completion \(completion)")
            } receiveValue: { [weak self] hasNextPage in
                self?.liveMatchesHasMorePages = hasNextPage
                self?.liveMatchesViewModelDataSource.shouldShowLoadingCell = hasNextPage
                if !hasNextPage {
                    self?.updateContentList()
                }
            }
            .store(in: &cancellables)
    }


    func fetchLiveMatches() {

        self.liveMatchesHasMorePages = true
        self.liveMatchesSubscriber?.cancel()

        self.isLoadingAllEventsList.send(true)

        let sportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.selectedSport)
        
        print("subscribeLiveMatches called")
        
        self.liveMatchesSubscriber = Env.servicesProvider.subscribeLiveMatches(forSportType: sportType)
            .sink(receiveCompletion: { completion in
                // TODO: subscribeLiveMatches receiveCompletion
                switch completion {
                case .finished:
                    Logger.log("subscribeLiveMatches finished")
                case .failure(let error):
                    Logger.log("subscribeLiveMatches error \(error)")
                }
            }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
                switch subscribableContent {
                case .connected(let subscription):
                    Logger.log("subscribeLiveMatches connected")
                    self?.subscriptions.insert(subscription)
                case .contentUpdate(let eventsGroups):
                    Logger.log("subscribeLiveMatches content")
                    self?.liveMatches = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups)
                    if let liveMatches = self?.liveMatches {
                        self?.setMainMarkets(matches: liveMatches)
                    }
                    self?.isLoadingAllEventsList.send(false)
                    self?.updateContentList()
                case .disconnected:
                    Logger.log("subscribeLiveMatches disconnected")
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
        switch self.matchListTypePublisher.value {
        case .liveMatches:
            return self.liveMatchesViewModelDataSource.numberOfSections(in: tableView)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.matchListTypePublisher.value {
        case .liveMatches:
            return self.liveMatchesViewModelDataSource.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch self.matchListTypePublisher.value {
        case .liveMatches:
            cell = self.liveMatchesViewModelDataSource.tableView(tableView, cellForRowAt: indexPath)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch self.matchListTypePublisher.value {
        case .liveMatches:
            return self.liveMatchesViewModelDataSource.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch self.matchListTypePublisher.value {
        case .liveMatches:
            return self.liveMatchesViewModelDataSource.tableView(tableView, viewForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .liveMatches:
            return self.liveMatchesViewModelDataSource.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .liveMatches:
            return self.liveMatchesViewModelDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .liveMatches:
            return self.liveMatchesViewModelDataSource.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .liveMatches:
            return self.liveMatchesViewModelDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}

class LiveMatchesViewModelDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var matches: [Match] = []
    var requestNextPage: (() -> Void)?
    var didSelectMatchAction: ((Match) -> Void)?
    var didTapFavoriteAction: ((Match) -> Void)?
    var didLongPressOdd: ((BettingTicket) -> Void)?

    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?

    var isUserLoggedPublisher: CurrentValueSubject<Bool, Never> = .init(true)
    
    var shouldShowLoadingCell = true

    init(matches: [Match]) {
        self.matches = matches
        super.init()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.matches.count
        case 1:
            return self.shouldShowLoadingCell ? 1 : 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
               let match = self.matches[safe: indexPath.row] {

                if let matchStatsViewModel = self.matchStatsViewModelForMatch?(match) {
                    cell.matchStatsViewModel = matchStatsViewModel
                }

                let store = Env.everyMatrixStorage as AggregatorStore

                cell.setupWithMatch(match, liveMatch: true, store: store)
                cell.tappedMatchLineAction = {
                    self.didSelectMatchAction?(match)
                }
                
//                cell.didTapFavoriteMatchAction = { [weak self] match in
//                    self?.didTapFavoriteAction?(match)
//                }

                cell.didLongPressOdd = { bettingTicket in
                    self.didLongPressOdd?(bettingTicket)
                }
                
                return cell
            }
        case 1:
            if let cell = tableView.dequeueCellType(LoadingMoreTableViewCell.self) {
                return cell
            }
        default:
            fatalError()
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier) as? TitleTableViewHeader
        else {
            fatalError()
        }
        headerView.configureWithTitle(localized("all_live_events"))
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 54
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 54
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            return 70 // Loading cell
        default:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            return 70 // Loading cell
        default:
            return StyleHelper.cardsStyleHeight() + 20
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1, self.matches.isNotEmpty {
            if let typedCell = cell as? LoadingMoreTableViewCell {
                typedCell.startAnimating()
            }
            self.requestNextPage?()
        }
    }
}
