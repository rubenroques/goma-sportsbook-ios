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

    var dataChangedPublisher = PassthroughSubject<Void, Never>.init()

    var competitionGroupsPublisher: CurrentValueSubject<[CompetitionGroup], Never> = .init([])

    var matchListTypePublisher: CurrentValueSubject<MatchListType, Never> = .init(.popular)
    enum MatchListType {
        case popular
        case upcoming
        case competitions
    }

    var screenStatePublisher: CurrentValueSubject<ScreenState, Never> = .init(.noEmptyNoFilter)
    enum ScreenState {
        case emptyAndFilter
        case emptyNoFilter
        case noEmptyNoFilter
        case noEmptyAndFilter
    }

    //
    //
    var isLoading: AnyPublisher<Bool, Never>
    var didChangeSport = false

    var isLoadingEvents: CurrentValueSubject<Bool, Never> = .init(false)

    var selectedSport: Sport {
        willSet {
            if newValue.id != self.selectedSport.id {
                didChangeSport = true
            }
        }
        didSet {
            if didChangeSport {
                self.resetScrollPositionAction?()
                self.homeFilterOptions = nil
            }
            self.fetchData()
        }
    }

    var homeFilterOptions: HomeFilterOptions? {
        didSet {
            if self.matchListTypePublisher.value == .upcoming {
                if let lowerTimeRange = homeFilterOptions?.lowerBoundTimeRange, let highTimeRange = homeFilterOptions?.highBoundTimeRange {
                    let timeRange = "\(Int(lowerTimeRange))-\(Int(highTimeRange))"
                    self.fetchTodayMatches(withFilter: true, timeRange: timeRange)
                }
            }
            else {
                self.updateContentList()
            }

        }
    }

    var didSelectMatchAction: ((Match) -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var didSelectCompetitionAction: ((Competition) -> Void)?
    var didLongPressOddAction: ((BettingTicket) -> Void)?
    var resetScrollPositionAction: (() -> Void)?

    var isUserLoggedPublisher: CurrentValueSubject<Bool, Never> = .init(true)

    var selectedCompetitionsInfoPublisher: CurrentValueSubject<[String: SportCompetitionInfo], Never> = .init([:])
    var expectedCompetitionsPublisher: CurrentValueSubject<Int, Never> = .init(0)

    var competitionsMatchesSubscriptions: CurrentValueSubject<[String: SportCompetitionInfo], Never> = .init([:])

    var sportRegionsPublisher: CurrentValueSubject<[SportRegion], Never> = .init([])
    var regionCompetitionsPublisher: CurrentValueSubject<[String: [SportCompetition]], Never> = .init([:])

    //
    // Private vars
    //
    private var userFavoriteMatches: [Match] = []
    private var popularMatches: [Match] = []
    private var popularOutrightCompetitions: [Competition]?

    private var todayMatches: [Match] = []
    private var todayOutrightCompetitions: [Competition]?

    var mainMarkets: OrderedDictionary<String, Market> = [:]

    private var competitionsMatches: [Match] = []
    private var competitions: [Competition] = []
    private var filteredOutrightCompetitions: [Competition]?

    private var favoriteMatches: [Match] = []
    private var favoriteCompetitions: [Competition] = []

    private var popularMatchesDataSource = PopularMatchesDataSource(matches: [], outrightCompetitions: nil)
    private var todayMatchesDataSource = TodayMatchesDataSource(todayMatches: [], outrightCompetitions: nil)
    private var competitionsDataSource = CompetitionsDataSource(competitions: [])
    private var filteredOutrightCompetitionsDataSource = FilteredOutrightCompetitionsDataSource(outrightCompetitions: [])

    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    private var isLoadingPopularList: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingTodayList: CurrentValueSubject<Bool, Never> = .init(true)

    private var isLoadingCompetitionMatches: CurrentValueSubject<Bool, Never> = .init(false)
    var isLoadingCompetitionGroups: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingCompetitionsData: AnyPublisher<Bool, Never>
    private var lastCompetitionsMatchesRequested: [String] = []

    private var popularMatchesPublisher: AnyCancellable?
    private var popularTournamentsPublisher: AnyCancellable?
    private var todayMatchesPublisher: AnyCancellable?
    private var competitionsMatchesPublisher: AnyCancellable?

    private var popularMatchesHasNextPage = true
    private var todayMatchesHasNextPage = true

    private var cancellables = Set<AnyCancellable>()
    private var subscriptions = Set<ServicesProvider.Subscription>()

    init(selectedSport: Sport) {
        self.selectedSport = selectedSport

        isLoadingCompetitionsData = Publishers.CombineLatest(isLoadingCompetitionMatches, isLoadingCompetitionGroups)
            .map({ return $0 || $1 })
            .eraseToAnyPublisher()

        isLoading = Publishers.CombineLatest4(matchListTypePublisher, isLoadingTodayList, isLoadingPopularList, isLoadingCompetitionsData)
            .map({ matchListType, isLoadingTodayList, isLoadingPopularList, isLoadingCompetitionsData in
                switch matchListType {
                case .popular: return isLoadingPopularList
                case .upcoming: return isLoadingTodayList
                case .competitions: return isLoadingCompetitionsData
                }
            })
            .eraseToAnyPublisher()

        super.init()

        self.setupCallbacks()
        self.setupPublishers()
    }

    deinit { 
        print("ServerProvider.Subscription.Debug PreLiveEventsViewModel deinit")

    }

    func setupCallbacks() {

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

        // NextPage
        //
        self.popularMatchesDataSource.canRequestNextPageAction = { [weak self] in
            return self?.popularMatchesHasNextPage ?? false
        }
        self.todayMatchesDataSource.canRequestNextPageAction = { [weak self] in
            return self?.todayMatchesHasNextPage ?? false
        }

        self.popularMatchesDataSource.requestNextPageAction = { [weak self] in
            self?.fetchPopularMatchesNextPage()
        }
        self.todayMatchesDataSource.requestNextPageAction = { [weak self] in
            self?.fetchTodayMatchesNextPage()
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
        self.filteredOutrightCompetitionsDataSource.didSelectCompetitionAction = { [weak self] competition in
            self?.didSelectCompetitionAction?(competition)
        }

        //Did select fav match
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

        // Did select odd
        self.popularMatchesDataSource.didLongPressOdd = { [weak self] bettingTicket in
            self?.didLongPressOddAction?(bettingTicket)
        }

        self.todayMatchesDataSource.didLongPressOdd = { [weak self] bettingTicket in
            self?.didLongPressOddAction?(bettingTicket)
        }

    }

    func setupPublishers() {

        Env.userSessionStore.userSessionPublisher
            .receive(on: DispatchQueue.main)
            .map({ $0 != nil })
            .sink(receiveValue: { [weak self] isUserLoggedIn in
                self?.isUserLoggedPublisher.send(isUserLoggedIn)
            })
            .store(in: &cancellables)

        Publishers.CombineLatest(self.sportRegionsPublisher, self.regionCompetitionsPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] sportRegions, regionCompetitions in

                if sportRegions.isNotEmpty && regionCompetitions.isNotEmpty {
                    self?.setupCompetitionGroups()
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

        self.competitionsMatchesSubscriptions
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] competitionMatchesSubscriptions in

                if competitionMatchesSubscriptions.count == self?.expectedCompetitionsPublisher.value {
                    print("ALL COMPETITIONS SUBSCRIPTIONS")

                    self?.isLoadingCompetitionMatches.send(false)
                    self?.isLoadingEvents.send(false)
                    self?.updateContentList()
                }
            })
            .store(in: &cancellables)

    }

    func processCompetitionsInfo() {

        let competitionInfos = self.selectedCompetitionsInfoPublisher.value.map({$0.value})

        self.competitions = []
        self.competitionsDataSource.competitions = []

        for competitionInfo in competitionInfos {
            if let marketGroup = competitionInfo.marketGroups.filter({
                $0.name == "Main"
            }).first {
                self.subscribeCompetitionMatches(forMarketGroupId: marketGroup.id, competitionInfo: competitionInfo)
            }
            else {
                self.processCompetitionOutrights(competitionInfo: competitionInfo)
            }
        }
    }

    func fetchData() {

        if didChangeSport {

            self.lastCompetitionsMatchesRequested = []

            self.popularMatchesDataSource.outrightCompetitions = nil
            self.popularOutrightCompetitions = nil
            self.popularMatches = []

            self.todayMatchesDataSource.todayMatches = []
            self.todayMatches = []
            self.todayOutrightCompetitions = nil
            self.todayMatchesDataSource.outrightCompetitions = nil

            self.competitionsDataSource.competitions = []
            self.competitions = []
            self.filteredOutrightCompetitionsDataSource.outrightCompetitions = []

            self.dataChangedPublisher.send()
        }

        self.popularMatchesHasNextPage = true
        self.todayMatchesHasNextPage = true


        switch self.matchListTypePublisher.value {
        case .popular:
            self.fetchPopularMatches()
        case .upcoming:
            self.fetchTodayMatches()
        case .competitions:
            self.fetchCompetitionsFilters()
            if self.lastCompetitionsMatchesRequested.isNotEmpty {
                self.fetchCompetitionsMatchesWithIds(lastCompetitionsMatchesRequested)
            }
        }
    }

    private func clearData() {
        self.lastCompetitionsMatchesRequested = []

        self.popularMatchesDataSource.outrightCompetitions = nil
        self.popularOutrightCompetitions = nil
        self.popularMatches = []

        self.todayMatchesDataSource.todayMatches = []
        self.todayMatches = []
        self.todayOutrightCompetitions = nil
        self.todayMatchesDataSource.outrightCompetitions = nil

        self.competitionsDataSource.competitions = []
        self.competitions = []
        self.filteredOutrightCompetitionsDataSource.outrightCompetitions = []

        self.dataChangedPublisher.send()
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

        switch matchListType {
        case .popular:
            // self.unsubscribeUpcomingMatches()
            self.fetchPopularMatches()
        case .upcoming:
            // self.unsubscribePopularMatches()
            self.fetchTodayMatches()
        case .competitions:
            self.fetchCompetitionsFilters()
            if let matches = self.competitionsDataSource.competitions.first?.matches {
                self.setMainMarkets(matches: matches)
            }
        }
        // self.updateContentList()
    }

    private func updateContentList(eventsGroups: [EventsGroup]? = nil) {

        self.popularMatchesDataSource.matches = filterPopularMatches(with: self.homeFilterOptions,
                                                                              matches: self.popularMatches)

        self.popularMatchesDataSource.outrightCompetitions = self.popularOutrightCompetitions

        if self.matchListTypePublisher.value == .popular {
            if self.popularMatches.isEmpty && self.popularOutrightCompetitions == nil {
                self.fetchOutrightCompetitions(eventsGroups: eventsGroups)
            }
        }

        //
        self.todayMatchesDataSource.todayMatches = filterTodayMatches(with: self.homeFilterOptions,
                                                                              matches: self.todayMatches)

        self.todayMatchesDataSource.outrightCompetitions = self.todayOutrightCompetitions

        if self.matchListTypePublisher.value == .upcoming {
            if self.todayMatches.isEmpty && self.todayOutrightCompetitions == nil {
                self.fetchOutrightCompetitions(eventsGroups: eventsGroups)
            }
        }

        //
        self.competitionsDataSource.competitions = filterCompetitionMatches(with: self.homeFilterOptions,
                                                                                          competitions: self.competitions)

        //
        //
        if let numberOfFilters = self.homeFilterOptions?.countFilters {
            if numberOfFilters > 0 {
                if !self.hasContentForSelectedListType() {
                    self.screenStatePublisher.send(.emptyAndFilter)
                }
                else {
                    self.screenStatePublisher.send(.noEmptyAndFilter)
                }
            }
            else {
                if !self.hasContentForSelectedListType() {
                    self.screenStatePublisher.send(.emptyNoFilter)
                }
                else {
                    self.screenStatePublisher.send(.noEmptyNoFilter)
                }
            }
        }
        else {
            if !self.hasContentForSelectedListType() {
                self.screenStatePublisher.send(.emptyNoFilter)
            }
            else {
                self.screenStatePublisher.send(.noEmptyNoFilter)
            }
        }

        //self.isLoadingEvents.send(false)

        self.dataChangedPublisher.send()
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
    // MARK: - Filters
    //
    func filterPopularMatches(with filtersOptions: HomeFilterOptions?, matches: [Match]) -> [Match] {
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
        return filteredMatches
    }

    func filterTodayMatches(with filtersOptions: HomeFilterOptions?, matches: [Match]) -> [Match] {
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
            let favoriteMarketIndex = match.markets.firstIndex(where: { $0.marketTypeId == filterOptionsValue.defaultMarket?.id })
            
            if let newFirstMarket = match.markets[safe: (favoriteMarketIndex ?? 0)] {
                marketSort.append(newFirstMarket)
            }
            
            for market in match.markets where market.typeId != marketSort[0].typeId {
                marketSort.append(market)
            }

            // Check odds filter
            let matchOdds = marketSort[0].outcomes
            let oddsRange = filterOptionsValue.lowerBoundOddsRange...filterOptionsValue.highBoundOddsRange
            var oddsInRange = false
            for odd in matchOdds {
                let oddValue = CGFloat(odd.bettingOffer.decimalOdd)
                if oddsRange.contains(oddValue) {
                    oddsInRange = true
                    break
                }
            }

            if oddsInRange {
                var newMatch = match
                newMatch.markets = marketSort

                filteredMatches.append(newMatch)
            }
        }
        return filteredMatches
    }

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

    //
    // MARK: - Fetches
    //
    //
    private func fetchPopularMatchesNextPage() {
        let sportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.selectedSport)
        Env.servicesProvider.requestPreLiveMatchesNextPage(forSportType: sportType, sortType: .popular)
            .sink { completion in
                print("requestPreLive fetchPopularMatchesNextPage completion \(completion)")
            } receiveValue: { [weak self] hasNextPage in
                self?.popularMatchesHasNextPage = hasNextPage
                if  !hasNextPage {
                    self?.updateContentList()
                }
            }
            .store(in: &cancellables)
    }

    private func fetchPopularMatches() {

        //self.isLoadingPopularList.send(true)
        self.isLoadingEvents.send(true)

        let sport = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.selectedSport)

        self.popularMatchesPublisher?.cancel()

        self.popularMatchesPublisher = Env.servicesProvider.subscribePreLiveMatches(forSportType: sport, sortType: .popular)
            .sink(receiveCompletion: { completion in
                print("Prelive subscribePopularMatches completed \(completion)")
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("Prelive subscribePopularMatches error: \(error)")
                    self.popularMatches = []
                    self.isLoadingPopularList.send(false)
                    self.isLoadingEvents.send(false)
                    self.updateContentList()
                }
            }, receiveValue: { (subscribableContent: SubscribableContent<[EventsGroup]>) in
                switch subscribableContent {
                case .connected(let subscription):
                    self.subscriptions.insert(subscription)
                case .contentUpdate(let eventsGroups):
                    self.processEvents(eventsGroups: eventsGroups)
//                    self.popularMatches = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups)
//                    self.isLoadingPopularList.send(false)
//                    self.isLoadingEvents.send(false)
//                    self.updateContentList(eventsGroups: eventsGroups)
                case .disconnected:
                    self.popularMatches = []
                    self.updateContentList()
                }
            })

    }

    //
    private func fetchTodayMatchesNextPage() {
        let sportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.selectedSport)
        Env.servicesProvider.requestPreLiveMatchesNextPage(forSportType: sportType, sortType: .date)
            .sink { completion in
                print("requestPreLiveMatchesNextPage completion \(completion)")
            } receiveValue: { [weak self] hasNextPage in
                self?.todayMatchesHasNextPage = hasNextPage
                if !hasNextPage {
                    self?.updateContentList()
                }
            }
            .store(in: &cancellables)
    }

    private func fetchTodayMatches(withFilter: Bool = false, timeRange: String = "") {

        //self.isLoadingTodayList.send(true)
        self.isLoadingEvents.send(true)

        let sportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.selectedSport)
        let datesFilter = Env.servicesProvider.getDatesFilter(timeRange: timeRange)

        self.todayMatchesPublisher?.cancel()
        self.todayMatchesPublisher = Env.servicesProvider.subscribePreLiveMatches(forSportType: sportType,
                                                                                  initialDate: datesFilter[safe: 0],
                                                                                  endDate: datesFilter[safe: 1],
                                                                                  sortType: .date)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    self.todayMatches = []
                    self.isLoadingTodayList.send(false)
                    self.isLoadingEvents.send(false)
                    self.updateContentList()
                }
            }, receiveValue: { (subscribableContent: SubscribableContent<[EventsGroup]>) in
                switch subscribableContent {
                case .connected(let subscription):
                    self.subscriptions.insert(subscription)
                case .contentUpdate(let eventsGroups):
                    self.processEvents(eventsGroups: eventsGroups)
                case .disconnected:
                    self.todayMatches = []
                    self.updateContentList()
                }
            })
    }

    private func fetchOutrightCompetitions(eventsGroups: [EventsGroup]? = nil) {
        self.isLoadingPopularList.send(true)
        self.isLoadingTodayList.send(true)
        self.isLoadingEvents.send(true)

        if let eventsGroups {
            let competitions = ServiceProviderModelMapper.competitions(fromEventsGroups: eventsGroups)

            if self.matchListTypePublisher.value == .popular {
                self.popularOutrightCompetitions = competitions
                self.popularMatchesDataSource.outrightCompetitions = self.popularOutrightCompetitions
            }
            else if self.matchListTypePublisher.value == .upcoming {
                self.todayOutrightCompetitions = competitions
                self.todayMatchesDataSource.outrightCompetitions = self.todayOutrightCompetitions

            }
        }

        self.isLoadingPopularList.send(false)
        self.isLoadingTodayList.send(false)
        self.isLoadingEvents.send(false)

    }

    private func processEvents(eventsGroups: [EventsGroup]) {

        // TODO: Recheck with isMainOutright when data is available to test
        if let event = eventsGroups.first?.events.first,
           event.homeTeamName == "" || event.awayTeamName == "" {
            self.isLoadingEvents.send(false)
            self.updateContentList(eventsGroups: eventsGroups)
        }
        else {
            switch self.matchListTypePublisher.value {
            case .popular:
                self.popularMatches = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups)
                self.setMainMarkets(matches: self.popularMatches)
                self.isLoadingPopularList.send(false)
                self.isLoadingEvents.send(false)
                self.updateContentList()
            case .upcoming:
                self.todayMatches = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups)
                self.setMainMarkets(matches: self.popularMatches)
                self.isLoadingTodayList.send(false)
                self.isLoadingEvents.send(false)
                self.updateContentList()
            default:
                ()
            }

        }
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

    func getFirstRegionCompetitions() {
        guard let firstRegion = self.sportRegionsPublisher.value.first else {return}

        Env.servicesProvider.getRegionCompetitions(regionId: firstRegion.id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("REGION COMPETITION ERROR: \(error)")
                }
            }, receiveValue: { [weak self] sportRegionInfo in
                let sportRegion = sportRegionInfo
                self?.regionCompetitionsPublisher.value[sportRegionInfo.id] = sportRegionInfo.competitionNodes
            })
            .store(in: &cancellables)
    }

    func fetchCompetitionsFilters() {

        // EM TEMP SHUTDOWN
//        self.competitions = []
//        self.popularOutrightCompetitions = []
        self.isLoadingCompetitionGroups.send(false)
        self.isLoadingEvents.send(false)
        self.updateContentList()

        guard let sportNumericId = self.selectedSport.numericId else { return }

        Env.servicesProvider.getSportRegions(sportId: sportNumericId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
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

    func fetchCompetitionsMatchesWithIds(_ ids: [String]) {

        if ids.isEmpty {
            self.competitions = []
            self.competitionsDataSource.competitions = []
            self.updateContentList()
            self.isLoadingCompetitionMatches.send(false)
            self.isLoadingEvents.send(false)
        }
        else {
            self.isLoadingCompetitionMatches.send(true)
            self.isLoadingEvents.send(true)
        }

        self.selectedCompetitionsInfoPublisher.value = [:]
        self.competitionsMatchesSubscriptions.value = [:]

        self.expectedCompetitionsPublisher.send(ids.count)

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

    func subscribeCompetitionMatches(forMarketGroupId marketGroupId: String, competitionInfo: SportCompetitionInfo) {

        Env.servicesProvider.subscribeCompetitionMatches(forMarketGroupId: marketGroupId)
        .sink {  [weak self] (completion: Subscribers.Completion<ServiceProviderError>) in
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
                                         numberOutrightMarkets: Int(competitionInfo.numberOutrightMarkets) ?? 0,
        competitionInfo: competitionInfo)

        self.setMainMarkets(matches: matches)
        self.competitions.append(newCompetition)
        self.competitionsDataSource.competitions = self.competitions
        self.competitionsMatchesSubscriptions.value[competitionInfo.id] = competitionInfo

    }

    private func processCompetitionOutrights(competitionInfo: SportCompetitionInfo) {
        let newCompetition = Competition(id: competitionInfo.id,
                                         name: competitionInfo.name,
                                         matches: [],
                                         numberOutrightMarkets: Int(competitionInfo.numberOutrightMarkets) ?? 0,
        competitionInfo: competitionInfo)

        self.competitions.append(newCompetition)
        self.competitionsDataSource.competitions = self.competitions
        self.competitionsMatchesSubscriptions.value[competitionInfo.id] = competitionInfo
    }

    //
    //
    // MARK: - Setups
    //

    private func setupCompetitionGroups() {

        if self.sportRegionsPublisher.value.isNotEmpty,
           self.regionCompetitionsPublisher.value.isNotEmpty {

            let sportRegions = self.sportRegionsPublisher.value
            let regionCompetitions = self.regionCompetitionsPublisher.value

            var competitionGroups = ServiceProviderModelMapper.competitionGroups(fromSportRegions: sportRegions, withRegionCompetitions: regionCompetitions)

            self.competitionGroupsPublisher.send(competitionGroups)

            self.updateContentList()
        }
    }

    func loadCompetitionByRegion(regionId: String) {

        Env.servicesProvider.getRegionCompetitions(regionId: regionId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("REGION COMPETITION ERROR: \(error)")
                }
            }, receiveValue: { [weak self] sportRegionInfo in
                print("REGION COMPETITION RESPONSE: \(sportRegionInfo)")
                self?.regionCompetitionsPublisher.value[sportRegionInfo.id] = sportRegionInfo.competitionNodes
                self?.setupCompetitionGroups()

            })
            .store(in: &cancellables)
    }

    func outrightCompetitions(forIds ids: [String]) -> [Competition] {

        var outrightCompetitions: [Competition] = []

        for id in ids {
            if let rawCompetition = Env.everyMatrixStorage.tournaments[id] {

                var location: Location?
                if let rawLocation = Env.everyMatrixStorage.location(forId: rawCompetition.venueId ?? "") {
                    location = Location(id: rawLocation.id,
                                    name: rawLocation.name ?? "",
                                    isoCode: rawLocation.code ?? "")
                }

                let competition = Competition(id: rawCompetition.id,
                                              name: rawCompetition.name ?? "",
                                              venue: location,
                                              numberOutrightMarkets: rawCompetition.numberOfOutrightMarkets ?? 0)
                outrightCompetitions.append(competition)
            }
            else if let rawCompetition = Env.everyMatrixStorage.popularTournaments[id] {

                var location: Location?
                if let rawLocation = Env.everyMatrixStorage.location(forId: rawCompetition.venueId ?? "") {
                    location = Location(id: rawLocation.id,
                                    name: rawLocation.name ?? "",
                                    isoCode: rawLocation.code ?? "")
                }

                let competition = Competition(id: rawCompetition.id,
                                              name: rawCompetition.name ?? "",
                                              venue: location,
                                              numberOutrightMarkets: rawCompetition.numberOfOutrightMarkets ?? 0)
                outrightCompetitions.append(competition)
            }
        }

        return outrightCompetitions
    }

}

extension PreLiveEventsViewModel: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.matchListTypePublisher.value {
        case .popular:
            return self.popularMatchesDataSource.numberOfSections(in: tableView)
        case .upcoming:
            return self.todayMatchesDataSource.numberOfSections(in: tableView)
        case .competitions:
            if self.competitions.isEmpty {
                return self.filteredOutrightCompetitionsDataSource.numberOfSections(in: tableView)
            }
            else {
                return self.competitionsDataSource.numberOfSections(in: tableView)
            }
        }
    }

    func hasContentForSelectedListType() -> Bool {
       switch self.matchListTypePublisher.value {
       case .popular:
           if self.popularMatchesDataSource.matches.isEmpty,
              let outrightCompetitions = self.popularMatchesDataSource.outrightCompetitions {
               return outrightCompetitions.isNotEmpty
           }
           return self.popularMatchesDataSource.matches.isNotEmpty
       case .upcoming:
           if self.todayMatchesDataSource.todayMatches.isEmpty,
              let outrightCompetitions = self.todayMatchesDataSource.outrightCompetitions {
               return outrightCompetitions.isNotEmpty
           }
           return self.todayMatchesDataSource.todayMatches.isNotEmpty
       case .competitions:
           if self.competitions.isEmpty {
               return self.filteredOutrightCompetitionsDataSource.outrightCompetitions.isNotEmpty
           }
           else {
               return self.competitionsDataSource.competitions.isNotEmpty
           }
       }
   }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.matchListTypePublisher.value {
        case .popular:
            return self.popularMatchesDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .upcoming:
            return self.todayMatchesDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .competitions:
            if self.competitions.isEmpty {
                return self.filteredOutrightCompetitionsDataSource.tableView(tableView, numberOfRowsInSection: section)
            }
            else {
                return self.competitionsDataSource.tableView(tableView, numberOfRowsInSection: section)
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch self.matchListTypePublisher.value {
        case .popular:
            cell = self.popularMatchesDataSource.tableView(tableView, cellForRowAt: indexPath)
        case .upcoming:
            cell = self.todayMatchesDataSource.tableView(tableView, cellForRowAt: indexPath)
        case .competitions:
            if self.competitions.isEmpty {
                cell = self.filteredOutrightCompetitionsDataSource.tableView(tableView, cellForRowAt: indexPath)
            }
            else {
                cell = self.competitionsDataSource.tableView(tableView, cellForRowAt: indexPath)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch self.matchListTypePublisher.value {
        case .popular:
            return self.popularMatchesDataSource.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        case .upcoming:
            return self.todayMatchesDataSource.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        case .competitions:
            ()
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch self.matchListTypePublisher.value {
        case .popular:
            return self.popularMatchesDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .upcoming:
            return self.todayMatchesDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .competitions:
            if self.competitions.isEmpty {
                return self.filteredOutrightCompetitionsDataSource.tableView(tableView, viewForHeaderInSection: section)
            }
            else {
                return self.competitionsDataSource.tableView(tableView, viewForHeaderInSection: section)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .popular:
            return self.popularMatchesDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .upcoming:
            return self.todayMatchesDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .competitions:
            if self.competitions.isEmpty {
                return self.filteredOutrightCompetitionsDataSource.tableView(tableView, heightForRowAt: indexPath)
            }
            else {
                return self.competitionsDataSource.tableView(tableView, heightForRowAt: indexPath)
            }
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .popular:
            return self.popularMatchesDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .upcoming:
            return self.todayMatchesDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .competitions:
            if self.competitions.isEmpty {
                return self.filteredOutrightCompetitionsDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
            }
            else {
                return self.competitionsDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .popular:
            return self.popularMatchesDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .upcoming:
            return self.todayMatchesDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .competitions:
            if self.competitions.isEmpty {
                return self.filteredOutrightCompetitionsDataSource.tableView(tableView, heightForHeaderInSection: section)
            }
            else {
                return self.competitionsDataSource.tableView(tableView, heightForHeaderInSection: section)
            }
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .popular:
            return self.popularMatchesDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .upcoming:
            return self.todayMatchesDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .competitions:
            if self.competitions.isEmpty {
                return self.filteredOutrightCompetitionsDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
            }
            else {
                return self.competitionsDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}
