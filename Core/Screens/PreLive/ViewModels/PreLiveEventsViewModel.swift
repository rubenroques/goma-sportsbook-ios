//
//  PreLiveEventsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 10/10/2021.
//

import UIKit
import Combine
import OrderedCollections
import ServicesProvider

class PreLiveEventsViewModel: NSObject {

    var dataChangedPublisher: AnyPublisher<Void, Never> {
        let activeDataSourcesChangedPublisher = Publishers.CombineLatest4(self.popularMatchesDataSource.dataChangedPublisher,
                                                                         self.todayMatchesDataSource.dataChangedPublisher,
                                                                         self.topCompetitionsDataSource.dataChangedPublisher,
                                                                        self.competitionsDataSource.dataChangedPublisher)
        .map({ popularDataChangedPublisher, todayDataChangedPublisher, topCompetitionsDataChangedPublisher, competitionsDataChangedPublisher -> Void? in
            switch self.matchListType {
            case .popular: return popularDataChangedPublisher
            case .upcoming: return todayDataChangedPublisher
            case .topCompetitions: return topCompetitionsDataChangedPublisher
            case .competitions: return competitionsDataChangedPublisher
            }
        })
        .compactMap({ $0 })

        let changedArrayPublisher = self.matchListTypePublisher
            .removeDuplicates()
            .map { _ in }

        return Publishers.Merge(activeDataSourcesChangedPublisher, changedArrayPublisher)
            .dropFirst()
            .eraseToAnyPublisher()
    }

    var competitionGroupsPublisher: CurrentValueSubject<[CompetitionGroup], Never> = .init([])

    //
    // MatchListType
    //
    enum MatchListType: String, Equatable {
        case popular
        case upcoming
        case topCompetitions
        case competitions
    }

    var matchListTypePublisher: CurrentValueSubject<MatchListType, Never> = .init(.popular)

    var matchListType: MatchListType {
        return self.matchListTypePublisher.value
    }

    var activeMatchListTypes: [MatchListType] {
        if self.hasTopCompetitions {
            return [.popular, .upcoming, .topCompetitions, .competitions]
        }
        else {
            return [.popular, .upcoming, .competitions]
        }
    }
    // ----

    //
    //
    var screenStatePublisher: CurrentValueSubject<ScreenState, Never> = .init(.noEmptyNoFilter)
    enum ScreenState: String, Equatable {
        case emptyAndFilter
        case emptyNoFilter
        case noEmptyNoFilter
        case noEmptyAndFilter
    }

    //
    //
    var isLoading: AnyPublisher<Bool, Never> {

        let loadingsPublisher = Publishers.CombineLatest4(self.popularMatchesDataSource.isLoadingInitialDataPublisher,
                                                          self.todayMatchesDataSource.isLoadingInitialDataPublisher,
                                                          self.topCompetitionsDataSource.isLoadingInitialDataPublisher,
                                                          self.competitionsDataSource.isLoadingInitialDataPublisher)

        return Publishers.CombineLatest(self.matchListTypePublisher, loadingsPublisher)
            .map({ matchListType, combinedLoadings in
                let (isLoadingPopular, isLoadingToday, isLoadingTopCompetitions, isLoadingCompetitions) = combinedLoadings
                switch matchListType {
                case .popular: return isLoadingPopular
                case .upcoming: return isLoadingToday
                case .topCompetitions: return isLoadingTopCompetitions
                case .competitions: return isLoadingCompetitions
                }
            })
            .eraseToAnyPublisher()
    }

    //
    // Selected Sport
    //
    var selectedSportPublisher: AnyPublisher<Sport, Never> {
        return self.selectedSportSubject
            .eraseToAnyPublisher()
    }
    var selectedSportSubject: CurrentValueSubject<Sport, Never>

    var selectedSport: Sport {
        return self.selectedSportSubject.value
    }

    var shouldShowCompetitionsIndexBarPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(self.matchListTypePublisher,
                                  self.competitionsDataSource.competitions,
                                  self.topCompetitionsDataSource.competitions)
        .map { matchListType, competitions, topCompetitions in
            switch matchListType {
            case .competitions:
                return competitions.isNotEmpty
            case.topCompetitions:
                return topCompetitions.isNotEmpty
            case .popular, .upcoming:
                return false
            }
        }
        .eraseToAnyPublisher()
    }

    // Proxy from topCompetitionsDataSource
    var hasTopCompetitions: Bool = false
    var hasTopCompetitionsPublisher: AnyPublisher<Bool, Never> {
        return self.topCompetitionsDataSource.hasTopCompetitionsPublisher.eraseToAnyPublisher()
    }

    var homeFilterOptions: HomeFilterOptions? {
        didSet {
            self.popularMatchesDataSource.applyFilters(filtersOptions: self.homeFilterOptions)
            self.todayMatchesDataSource.applyFilters(filtersOptions: self.homeFilterOptions)
//
//            if self.matchListType == .upcoming {
//                if let lowerTimeRange = homeFilterOptions?.lowerBoundTimeRange, var highTimeRange = homeFilterOptions?.highBoundTimeRange {
//
//                    if highTimeRange == 6 {
//                        // The value 6 in the slider is presented as "All" days to the user
//                        // so we convert it to 365 days, to get all the events of the next year
//                        highTimeRange = 365
//                    }
//
//                    let daysRange = TodayMatchesDataSource.DaysRange(startDay: lowerTimeRange, endDay: highTimeRange)
//                    self.todayMatchesDataSource.fetchData(forSport: self.selectedSport, daysRange: daysRange)
//                }
//            }
//            else {
//                // TODO: filters
//                // self.updateContentList()
//            }
        }
    }

    var didSelectMatchAction: ((Match) -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var didSelectCompetitionAction: ((Competition) -> Void)?
    var didLongPressOddAction: ((BettingTicket) -> Void)?
    var resetScrollPositionAction: (() -> Void)?
    var shouldShowSearch: (() -> Void)?

    var sportRegionsPublisher: CurrentValueSubject<[SportRegion], Never> = .init([])
    var regionCompetitionsPublisher: CurrentValueSubject<[String: [SportCompetition]], Never> = .init([:])

    //
    // Private vars
    //
    private var userFavoriteMatches: [Match] = []

    //
    //
    var mainMarkets: OrderedDictionary<String, Market> = [:]

    private var popularMatchesDataSource: PopularMatchesDataSource
    private var todayMatchesDataSource: TodayMatchesDataSource
    private var competitionsDataSource = CompetitionsDataSource()
    private var topCompetitionsDataSource: TopCompetitionsDataSource

    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    private var isLoadingCompetitionMatches: CurrentValueSubject<Bool, Never> = .init(false)
    var isLoadingCompetitionGroups: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingCompetitionsData: AnyPublisher<Bool, Never>
    private var lastCompetitionsMatchesRequested: [String] = []

    private var competitionsMatchesPublisher: AnyCancellable?

    private var cancellables = Set<AnyCancellable>()

    private var competitionsSubscription: ServicesProvider.Subscription?

    init(selectedSport: Sport) {

        self.selectedSportSubject = .init(selectedSport)

        self.popularMatchesDataSource = PopularMatchesDataSource(sport: selectedSport)
        self.todayMatchesDataSource = TodayMatchesDataSource(sport: selectedSport)
        self.topCompetitionsDataSource = TopCompetitionsDataSource(sport: selectedSport)

        self.isLoadingCompetitionsData = Publishers.CombineLatest(isLoadingCompetitionMatches, isLoadingCompetitionGroups)
            .map({ return $0 || $1 })
            .eraseToAnyPublisher()

        super.init()

        self.setupDataSourcesCallbacks()
        self.setupPublishers()
    }

    deinit {
        print("ServerProvider.Subscription.Debug PreLiveEventsViewModel deinit")
    }

    func setupDataSourcesCallbacks() {

        // Match Stats ViewModel for Match
        self.popularMatchesDataSource.matchStatsViewModelForMatch = { [weak self] match in
            return self?.matchStatsViewModel(forMatch: match)
        }
        self.todayMatchesDataSource.matchStatsViewModelForMatch = { [weak self] match in
            return self?.matchStatsViewModel(forMatch: match)
        }
        self.competitionsDataSource.matchStatsViewModelForMatch = { [weak self] match in
            return self?.matchStatsViewModel(forMatch: match)
        }

        // Did Select a Match
        //
        self.popularMatchesDataSource.didSelectMatchAction = { [weak self] match in
            self?.didSelectMatchAction?(match)
        }
        self.todayMatchesDataSource.didSelectMatchAction = { [weak self] match in
            self?.didSelectMatchAction?(match)
        }
        self.competitionsDataSource.didSelectMatchAction = { [weak self] match in
            self?.didSelectMatchAction?(match)
        }

        self.topCompetitionsDataSource.didSelectMatchAction = { [weak self] match in
            self?.didSelectMatchAction?(match)
        }

        // Did Select a Competition
        //
        self.popularMatchesDataSource.didSelectCompetitionAction = { [weak self] competition in
            self?.didSelectCompetitionAction?(competition)
        }
        self.todayMatchesDataSource.didSelectCompetitionAction = { [weak self] competition in
            self?.didSelectCompetitionAction?(competition)
        }
        self.competitionsDataSource.didSelectCompetitionAction = { [weak self] competition in
            self?.didSelectCompetitionAction?(competition)
        }
        self.topCompetitionsDataSource.didSelectCompetitionAction = { [weak self] competition in
            self?.didSelectCompetitionAction?(competition)
        }

        // Did select fav match
        //
        self.competitionsDataSource.didTapFavoriteMatchAction = { [weak self] match in
            self?.didTapFavoriteMatchAction?(match)
        }
        self.todayMatchesDataSource.didTapFavoriteMatchAction = { [weak self] match in
            self?.didTapFavoriteMatchAction?(match)
        }
        self.popularMatchesDataSource.didTapFavoriteMatchAction = { [weak self] match in
            self?.didTapFavoriteMatchAction?(match)
        }
        self.topCompetitionsDataSource.didTapFavoriteMatchAction = { [weak self] match in
            self?.didTapFavoriteMatchAction?(match)
        }

        // Did select odd
        self.popularMatchesDataSource.didLongPressOdd = { [weak self] bettingTicket in
            self?.didLongPressOddAction?(bettingTicket)
        }

        self.todayMatchesDataSource.didLongPressOdd = { [weak self] bettingTicket in
            self?.didLongPressOddAction?(bettingTicket)
        }

        // Clicked search
        self.popularMatchesDataSource.shouldShowSearch = { [weak self] in
            self?.shouldShowSearch?()
        }

        self.todayMatchesDataSource.shouldShowSearch = { [weak self] in
            self?.shouldShowSearch?()
        }

    }

    func setupPublishers() {

        self.topCompetitionsDataSource.hasTopCompetitionsPublisher
            .sink { [weak self] hasTopCompetitions in
                self?.hasTopCompetitions = hasTopCompetitions
            }
            .store(in: &self.cancellables)

        self.matchListTypePublisher
            .removeDuplicates()
            .sink { [weak self] newMatchListType in

                guard let self = self else { return }

                switch newMatchListType {
                case .popular:
                    self.popularMatchesDataSource.fetchData(forSport: self.selectedSport)
                case .upcoming:
                    self.todayMatchesDataSource.fetchData(forSport: self.selectedSport)
                case .topCompetitions:
                    self.topCompetitionsDataSource.fetchData(forSport: self.selectedSport)
                case .competitions:
                    self.fetchCompetitionsMatchesWithIds(self.lastCompetitionsMatchesRequested)
                }

            }
            .store(in: &self.cancellables)

//        Empty screens
//        Publishers.CombineLatest(self.isLoading, self.dataChangedPublisher)
//            .filter({ isLoading, _ in
//                return !isLoading
//            })
//            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
//            .sink { [weak self] _, _  in
//
//                guard let self = self else { return }
//
//                let numberOfFilters = self.homeFilterOptions?.countFilters ?? 0
//                if numberOfFilters > 0 {
//                    if self.hasContentForSelectedListType() {
//                        self.screenStatePublisher.send(.noEmptyAndFilter)
//                    }
//                    else {
//                        // No Content
//                        self.screenStatePublisher.send(.emptyAndFilter)
//                    }
//                }
//                else {
//                    if self.hasContentForSelectedListType() {
//                        self.screenStatePublisher.send(.noEmptyNoFilter)
//                    }
//                    else {
//                        // No Content
//                        self.screenStatePublisher.send(.emptyNoFilter)
//                    }
//                }
//
//            }
//            .store(in: &self.cancellables)

//        self.dataChangedPublisher
//            .sink { [weak self] in
//                guard let self = self else { return }
//
//                let numberOfFilters = self.homeFilterOptions?.countFilters ?? 0
//                if numberOfFilters > 0 {
//                    if self.hasContentForSelectedListType() {
//                        self.screenStatePublisher.send(.noEmptyAndFilter)
//                    }
//                    else {
//                        // No Content
//                        self.screenStatePublisher.send(.emptyAndFilter)
//                    }
//                }
//                else {
//                    if self.hasContentForSelectedListType() {
//                        self.screenStatePublisher.send(.noEmptyNoFilter)
//                    }
//                    else {
//                        // No Content
//                        self.screenStatePublisher.send(.emptyNoFilter)
//                    }
//                }
//
//            }
//            .store(in: &self.cancellables)

        //
        self.selectedSportPublisher
            .removeDuplicates()
            .sink { [weak self] selectedSport in

                // TODO: this resetScrollPositionAction should be on the VC maybe
                if self?.matchListType != .competitions {
                    self?.resetScrollPositionAction?()
                }

                self?.lastCompetitionsMatchesRequested = []
                self?.fetchCompetitionsFilters()

                // Send the new selected sport to topCompetitionsDataSource to check if
                // there are any top competitions for that sport
                self?.topCompetitionsDataSource.setSport(selectedSport)

                self?.homeFilterOptions = nil
                self?.fetchData()
            }
            .store(in: &self.cancellables)

        //
        Publishers.CombineLatest(self.sportRegionsPublisher, self.regionCompetitionsPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] sportRegions, regionCompetitions in
                if sportRegions.isNotEmpty && regionCompetitions.isNotEmpty {
                    self?.setupCompetitionGroups()
                }
            })
            .store(in: &cancellables)

//
//        Publishers.CombineLatest(self.expectedCompetitionsPublisher, self.selectedCompetitionsInfoPublisher)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { [weak self] expectedCompetitions, selectedCompetitionsInfo in
//                if selectedCompetitionsInfo.count == expectedCompetitions {
//                    self?.processCompetitionsInfo()
//                }
//            })
//            .store(in: &cancellables)
//
//        self.competitionsMatchesSubscriptions
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { [weak self] competitionMatchesSubscriptions in
//                guard let self = self else { return }
//
//                if competitionMatchesSubscriptions.count == self.expectedCompetitionsPublisher.value {
//                    self.isLoadingCompetitionMatches.send(false)
//
//                    if self.matchListType == .competitions {
//                        self.updateContentList()
//                    }
//                }
//            })
//            .store(in: &cancellables)

    }

    func selectSport(newSport sport: Sport) {
        self.selectedSportSubject.send(sport)
    }

    func fetchData(forceRefresh: Bool = false) {
        switch self.matchListType {
        case .popular:
            self.popularMatchesDataSource.fetchData(forSport: self.selectedSport, forceRefresh: forceRefresh)
        case .upcoming:
            self.todayMatchesDataSource.fetchData(forSport: self.selectedSport, forceRefresh: forceRefresh)
        case .topCompetitions:
            self.topCompetitionsDataSource.fetchData(forSport: self.selectedSport, forceRefresh: forceRefresh)
        case .competitions:
            self.fetchCompetitionsMatchesWithIds(lastCompetitionsMatchesRequested, forceRefresh: forceRefresh)
        }
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
    
    func setMatchListType(_ matchListType: MatchListType) {
        self.matchListTypePublisher.send(matchListType)
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

    //
    func fetchCompetitionsMatchesWithIds(_ ids: [String], forceRefresh: Bool = false) {
        self.lastCompetitionsMatchesRequested = ids
        self.competitionsDataSource.fetchData(withCompetitionsIds: ids, forceRefresh: forceRefresh)
    }

    func fetchCompetitionsFilters() {

        self.isLoadingCompetitionGroups.send(false)

        guard let sportNumericId = self.selectedSport.numericId else {
            // Thats an incompleted Sport without numericId
            self.sportRegionsPublisher.send([])
            self.competitionGroupsPublisher.send([])
            return
        }

        self.isLoadingCompetitionGroups.send(true)

        Env.servicesProvider.getSportRegions(sportId: sportNumericId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("SPORT REGION FAILURE: \(error)")
                }
            }, receiveValue: { [weak self] response in
                let sportRegions = response.regionNodes

                self?.sportRegionsPublisher.send(sportRegions)
                self?.getFirstRegionCompetitions()
            })
            .store(in: &cancellables)

    }

    func getFirstRegionCompetitions() {
        guard let firstRegion = self.sportRegionsPublisher.value.first else {return}

        self.regionCompetitionsPublisher.value = [:]

        Env.servicesProvider.getRegionCompetitions(regionId: firstRegion.id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("REGION COMPETITION ERROR: \(error)")
                    self?.isLoadingCompetitionGroups.send(false)
                }
            }, receiveValue: { [weak self] sportRegionInfo in
                print("REGION COMPETITIONS: \(sportRegionInfo)")
                
                self?.regionCompetitionsPublisher.value[sportRegionInfo.id] = sportRegionInfo.competitionNodes
            })
            .store(in: &cancellables)
    }

    func getCompetitions() -> [Competition] {
        return self.competitionsDataSource.competitions.value
    }

    func getTopCompetitions() -> [Competition] {
        return self.topCompetitionsDataSource.competitions.value
    }


    func competition(forIndex index: Int) -> Competition? {
        return self.competitionsDataSource.competitions.value[safe: index]
    }

    func topCompetition(forIndex index: Int) -> Competition? {
        return self.competitionsDataSource.competitions.value[safe: index]
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

    //
    // MARK: - Setups
    //
    func loadCompetitionByRegion(regionId: String) {

        Env.servicesProvider.getRegionCompetitions(regionId: regionId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("REGION COMPETITION ERROR: \(error)")
                }
            }, receiveValue: { [weak self] sportRegionInfo in
                self?.regionCompetitionsPublisher.value[sportRegionInfo.id] = sportRegionInfo.competitionNodes
                self?.setupCompetitionGroups()
            })
            .store(in: &cancellables)
    }

    private func setupCompetitionGroups() {
        if self.sportRegionsPublisher.value.isNotEmpty,
           self.regionCompetitionsPublisher.value.isNotEmpty {

            let sportRegions = self.sportRegionsPublisher.value
            let regionCompetitions = self.regionCompetitionsPublisher.value

            let competitionGroups = ServiceProviderModelMapper.competitionGroups(fromSportRegions: sportRegions, withRegionCompetitions: regionCompetitions)
            self.competitionGroupsPublisher.send(competitionGroups)

            self.isLoadingCompetitionGroups.send(false)

            // Refresh
        }
    }

}

extension PreLiveEventsViewModel {

    //
    // MARK: - Filters
    //

    func filterCompetitionMatches (with filtersOptions: HomeFilterOptions?, competitions: [Competition]) -> [Competition] {

        guard let filterOptionsValue = filtersOptions else {
            return competitions
        }

        var filteredMatches: [Match] = []
        var filteredCompetitions: [Competition] = []
        for competition in competitions where competition.matches.isNotEmpty {
            for match in competition.matches {

                if match.markets.isEmpty {
                    continue
                }

                // Check default market order
                var marketSort: [Market] = []
//                let favoriteMarketIndex = match.markets.firstIndex(where: { $0.typeId == filterOptionsValue.defaultMarket.marketId })
                let favoriteMarketIndex = match.markets.firstIndex(where: { $0.marketTypeId == filterOptionsValue.defaultMarket?.id })

                if let newFirstMarket = match.markets[safe: (favoriteMarketIndex ?? 0)] {
                    marketSort.append(newFirstMarket)
                }

                for market in match.markets {
                    if market.typeId != marketSort[0].typeId {
                        marketSort.append(market)
                    }
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
            var newCompetition = competition
            newCompetition.matches = filteredMatches
            filteredCompetitions.append(newCompetition)
        }
        return filteredCompetitions
    }

}

extension PreLiveEventsViewModel: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.matchListType {
        case .popular:
            return self.popularMatchesDataSource.numberOfSections(in: tableView)
        case .upcoming:
            return self.todayMatchesDataSource.numberOfSections(in: tableView)
        case .topCompetitions:
            return self.topCompetitionsDataSource.numberOfSections(in: tableView)
        case .competitions:
            return self.competitionsDataSource.numberOfSections(in: tableView)
        }
    }

    func hasContentForSelectedListType() -> Bool {
        switch self.matchListType {
        case .popular:
            if self.popularMatchesDataSource.allMatches.isEmpty,
               let outrightCompetitions = self.popularMatchesDataSource.allOutrightCompetitionsSubject.value {
                return outrightCompetitions.isNotEmpty
            }
            return self.popularMatchesDataSource.allMatches.isNotEmpty
        case .upcoming:
            if self.todayMatchesDataSource.matches.value.isEmpty,
               let outrightCompetitions = self.todayMatchesDataSource.outrightCompetitions.value {
                return outrightCompetitions.isNotEmpty
            }
            return self.todayMatchesDataSource.matches.value.isNotEmpty
        case .topCompetitions:
            return self.topCompetitionsDataSource.competitions.value.isNotEmpty
        case .competitions:
            return self.competitionsDataSource.competitions.value.isNotEmpty
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.matchListType {
        case .popular:
            return self.popularMatchesDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .upcoming:
            return self.todayMatchesDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .topCompetitions:
            return self.topCompetitionsDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .competitions:
            return self.competitionsDataSource.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch self.matchListType {
        case .popular:
            cell = self.popularMatchesDataSource.tableView(tableView, cellForRowAt: indexPath)
        case .upcoming:
            cell = self.todayMatchesDataSource.tableView(tableView, cellForRowAt: indexPath)
        case .topCompetitions:
            cell = self.topCompetitionsDataSource.tableView(tableView, cellForRowAt: indexPath)
        case .competitions:
            cell = self.competitionsDataSource.tableView(tableView, cellForRowAt: indexPath)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch self.matchListType {
        case .popular:
            return self.popularMatchesDataSource.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        case .upcoming:
            return self.todayMatchesDataSource.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        case .topCompetitions:
            ()
        case .competitions:
            ()
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch self.matchListType {
        case .popular:
            return self.popularMatchesDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .upcoming:
            return self.todayMatchesDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .topCompetitions:
            return self.topCompetitionsDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .competitions:
            return self.competitionsDataSource.tableView(tableView, viewForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.matchListType {
        case .popular:
            return self.popularMatchesDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .upcoming:
            return self.todayMatchesDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .topCompetitions:
            return self.topCompetitionsDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .competitions:
            return self.competitionsDataSource.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.matchListType {
        case .popular:
            return self.popularMatchesDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .upcoming:
            return self.todayMatchesDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .topCompetitions:
            return self.topCompetitionsDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .competitions:
            return self.competitionsDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch self.matchListType {
        case .popular:
            return self.popularMatchesDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .upcoming:
            return self.todayMatchesDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .topCompetitions:
            return self.topCompetitionsDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .competitions:
            return self.competitionsDataSource.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        switch self.matchListType {
        case .popular:
            return self.popularMatchesDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .upcoming:
            return self.todayMatchesDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .topCompetitions:
            return self.topCompetitionsDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .competitions:
            return self.competitionsDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}
