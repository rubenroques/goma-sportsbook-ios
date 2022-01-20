//
//  PreLiveEventsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 10/10/2021.
//

import UIKit
import Combine
import OrderedCollections

class PreLiveEventsViewModel: NSObject {

    var dataChangedPublisher = PassthroughSubject<Void, Never>.init()

    var competitionGroupsPublisher: CurrentValueSubject<[CompetitionGroup], Never> = .init([])

    var matchListTypePublisher: CurrentValueSubject<MatchListType, Never> = .init(.myGames)
    enum MatchListType {
        case myGames
        case today
        case competitions
        case favoriteGames
        case favoriteCompetitions
    }

    var screenStatePublisher: CurrentValueSubject<ScreenState, Never> = .init(.noEmptyNoFilter)
    enum ScreenState {
        case emptyAndFilter
        case emptyNoFilter
        case noEmptyNoFilter
        case noEmptyAndFilter
    }

    //
    // Private vars
    //
    private var banners: [EveryMatrix.BannerInfo] = []

    private var userFavoriteMatches: [Match] = []
    private var popularMatches: [Match] = []

    private var todayMatches: [Match] = []

    private var competitionsMatches: [Match] = []
    private var competitions: [Competition] = []

    private var favoriteMatches: [Match] = []
    private var favoriteCompetitions: [Competition] = []

    private var popularMatchesDataSource = PopularMatchesDataSource(banners: [], matches: [])
    private var todayMatchesDataSource = TodayMatchesDataSource(todayMatches: [])
    private var competitionsDataSource = CompetitionsDataSource(competitions: [])
    private var favoriteMatchesDataSource = FavoriteMatchesDataSource(userFavoriteMatches: [])
    private var favoriteCompetitionsDataSource = FavoriteCompetitionsDataSource(favoriteCompetitions: [])

    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    private var isLoadingPopularList: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingTodayList: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingCompetitions: CurrentValueSubject<Bool, Never> = .init(true)

    var isLoadingCompetitionGroups: CurrentValueSubject<Bool, Never> = .init(true)

    var isLoading: AnyPublisher<Bool, Never>

    var didChangeSport = false

    var selectedSport: Sport {
        willSet {
            if newValue.id != self.selectedSport.id {
                didChangeSport = true
            }
        }
        didSet {
            self.fetchData()
        }
    }

    var homeFilterOptions: HomeFilterOptions? {
        didSet {
            if let lowerTimeRange = homeFilterOptions?.lowerBoundTimeRange, let highTimeRange = homeFilterOptions?.highBoundTimeRange {
                let timeRange = "\(Int(lowerTimeRange))-\(Int(highTimeRange))"
                self.fetchTodayMatches(withFilter: true, timeRange: timeRange)
            }
            else {
                self.updateContentList()
            }

        }
    }

    var didSelectActivationAlertAction: ((ActivationAlertType) -> Void)?
    var didSelectMatchAction: ((Match) -> Void)?

    private var cancellables = Set<AnyCancellable>()

    private var zip3Publisher: AnyCancellable?

    private var tournamentsPublisher: AnyPublisher<[EveryMatrix.Tournament], EveryMatrix.APIError>?
    private var locationsPublisher: AnyPublisher<[EveryMatrix.Location], EveryMatrix.APIError>?

    private var popularMatchesPublisher: AnyCancellable?
    private var todayMatchesPublisher: AnyCancellable?
    private var competitionsMatchesPublisher: AnyCancellable?
    private var bannersInfoPublisher: AnyCancellable?
    private var favoriteMatchesPublisher: AnyCancellable?
    private var favoriteCompetitionsMatchesPublisher: AnyCancellable?

    private var popularMatchesRegister: EndpointPublisherIdentifiable?
    private var todayMatchesRegister: EndpointPublisherIdentifiable?
    private var tournamentsRegister: EndpointPublisherIdentifiable?
    private var locationsRegister: EndpointPublisherIdentifiable?
    private var competitionsMatchesRegister: EndpointPublisherIdentifiable?
    private var bannersInfoRegister: EndpointPublisherIdentifiable?
    private var favoriteMatchesRegister: EndpointPublisherIdentifiable?
    private var favoriteCompetitionsMatchesRegister: EndpointPublisherIdentifiable?

    private var popularMatchesCount = 10
    private var popularMatchesPage = 1
    private var popularMatchesHasNextPage = true {
        didSet {

        }
    }
    private var todayMatchesCount = 10
    private var todayMatchesPage = 1
    private var todayMatchesHasNextPage = true {
        didSet {

        }
    }
    
    var isUserLoggedPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    init(selectedSport: Sport) {
        self.selectedSport = selectedSport
        
        isLoading = Publishers.CombineLatest4(matchListTypePublisher, isLoadingTodayList, isLoadingPopularList, isLoadingCompetitions)
            .map({ matchListType, isLoadingTodayList, isLoadingPopularList, isLoadingCompetitions in
                switch matchListType {
                case .myGames: return isLoadingPopularList
                case .today: return isLoadingTodayList
                case .competitions: return isLoadingCompetitions
                case .favoriteGames: return false
                case .favoriteCompetitions: return false
                }
            })
            .eraseToAnyPublisher()

        super.init()

        // ActivationAlertAction
        //
        self.popularMatchesDataSource.didSelectActivationAlertAction = { [weak self] alertType in
            self?.didSelectActivationAlertAction?(alertType)
        }

        // Match Stats ViewModel for Match
//        self.popularMatchesDataSource.matchStatsViewModelForMatch = { [weak self] match in
//            return self?.matchStatsViewModel(forMatch: match)
//        }

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
        self.favoriteMatchesDataSource.didSelectMatchAction = { [weak self] match in
            self?.didSelectMatchAction?(match)
        }
        self.favoriteCompetitionsDataSource.didSelectMatchAction = { [weak self] match in
            self?.didSelectMatchAction?(match)
        }

        // Did Select a Match
        //
        self.favoriteMatchesDataSource.matchWentLiveAction = { [weak self] in
            self?.dataChangedPublisher.send()
        }
        self.favoriteCompetitionsDataSource.matchWentLiveAction = { [weak self] in
            self?.dataChangedPublisher.send()
        }

        self.setupPublishers()
    }

    func setupPublishers() {
        Env.favoritesManager.favoriteEventsIdPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] favoriteEvents in
                self?.fetchFavoriteMatches()
                self?.fetchFavoriteCompetitionsMatchesWithIds(favoriteEvents)
            })
            .store(in: &cancellables)

        Env.userSessionStore.isUserProfileIncomplete
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                self.popularMatchesDataSource.refetchAlerts()
            })
            .store(in: &cancellables)
    }

    func fetchData() {
        self.isLoadingPopularList.send(true)
        self.isLoadingTodayList.send(true)
        self.isLoadingCompetitions.send(true)
        self.isLoadingCompetitionGroups.send(true)

        self.popularMatchesPage = 1
        self.todayMatchesPage = 1

        self.popularMatchesHasNextPage = true
        self.todayMatchesHasNextPage = true

        self.competitionsMatches = []
        self.competitions = []

        self.competitionGroupsPublisher.send([])

        self.fetchBanners()

        self.fetchPopularMatches()
        self.fetchTodayMatches()
        self.fetchCompetitionsFilters()

        self.isUserLoggedPublisher.send(UserSessionStore.isUserLogged())
    }

    func setMatchListType(_ matchListType: MatchListType) {
        self.matchListTypePublisher.send(matchListType)
        self.updateContentList()
    }

    private func updateContentList() {

        self.popularMatchesDataSource.matches = filterPopularMatches(with: self.homeFilterOptions,
                                                                              matches: self.popularMatches)

        self.popularMatchesDataSource.banners = self.banners

        self.todayMatchesDataSource.todayMatches = filterTodayMatches(with: self.homeFilterOptions,
                                                                              matches: self.todayMatches)

        self.competitionsDataSource.competitions = filterCompetitionMatches(with: self.homeFilterOptions,
                                                                                          competitions: self.competitions)

        self.favoriteMatchesDataSource.userFavoriteMatches = self.favoriteMatches

        self.favoriteCompetitionsDataSource.competitions = self.favoriteCompetitions

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
            let favoriteMarketIndex = match.markets.firstIndex(where: { $0.typeId == filterOptionsValue.defaultMarket.marketId })
            marketSort.append(match.markets[favoriteMarketIndex ?? 0])
            for market in match.markets {
                if market.typeId != marketSort[0].typeId {
                    marketSort.append(market)
                }
            }

            // Check odds filter
            let matchOdds = marketSort[0].outcomes
            let oddsRange = filterOptionsValue.lowerBoundOddsRange...filterOptionsValue.highBoundOddsRange
            for odd in matchOdds {
                let oddValue = CGFloat(odd.bettingOffer.value)
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

        // Check time
//        let timeOptionMin = Int(filterOptionsValue.lowerBoundTimeRange) * 3600
//        let timeOptionMax = Int(filterOptionsValue.highBoundTimeRange) * 3600
//        let dateOptionMin = Date().addingTimeInterval(TimeInterval(timeOptionMin))
//        let dateOptionMax = Date().addingTimeInterval(TimeInterval(timeOptionMax))
//        let dateRange = dateOptionMin...dateOptionMax

        var filteredMatches: [Match] = []

        for match in matches {
            // Check default market order
            var marketSort: [Market] = []
            let favoriteMarketIndex = match.markets.firstIndex(where: { $0.typeId == filterOptionsValue.defaultMarket.marketId })
            marketSort.append(match.markets[favoriteMarketIndex ?? 0])
            for market in match.markets where market.typeId != marketSort[0].typeId {
                marketSort.append(market)
            }
            // Check time range
//            var timeInRange = false
//            if dateRange.contains(match.date!) {
//                timeInRange = true
//            }

            // Check odds filter
            let matchOdds = marketSort[0].outcomes
            let oddsRange = filterOptionsValue.lowerBoundOddsRange...filterOptionsValue.highBoundOddsRange
            var oddsInRange = false
            for odd in matchOdds {
                let oddValue = CGFloat(odd.bettingOffer.value)
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
                // Check default market order
                var marketSort: [Market] = []
                let favoriteMarketIndex = match.markets.firstIndex(where: { $0.typeId == filterOptionsValue.defaultMarket.marketId })
                marketSort.append(match.markets[favoriteMarketIndex ?? 0])
                for market in match.markets {
                    if market.typeId != marketSort[0].typeId {
                        marketSort.append(market)
                    }
                }

                // Check odds filter
                let matchOdds = marketSort[0].outcomes
                let oddsRange = filterOptionsValue.lowerBoundOddsRange...filterOptionsValue.highBoundOddsRange
                for odd in matchOdds {
                    let oddValue = CGFloat(odd.bettingOffer.value)
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
        if !popularMatchesHasNextPage {
            return
        }
        self.popularMatchesPage += 1
        self.fetchPopularMatches()
    }

    private func fetchPopularMatches() {

        if let popularMatchesRegister = popularMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: popularMatchesRegister)
        }

        let matchesCount = self.popularMatchesCount * self.popularMatchesPage

        let endpoint = TSRouter.popularMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                        language: "en",
                                                        sportId: self.selectedSport.id,
                                                        matchesCount: matchesCount)
        self.popularMatchesPublisher?.cancel()
        self.popularMatchesPublisher = nil
        
        self.popularMatchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
                self?.isLoadingPopularList.send(false)
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("PreLiveEventsViewModel popularMatchesPublisher connect")
                    self?.popularMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("PreLiveEventsViewModel popularMatchesPublisher initialContent")
                    self?.setupPopularAggregatorProcessor(aggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    print("PreLiveEventsViewModel popularMatchesPublisher updatedContent")
                    self?.updatePopularAggregatorProcessor(aggregator: aggregatorUpdates)
                case .disconnect:
                    print("PreLiveEventsViewModel popularMatchesPublisher disconnect")
                }
            })
        
    }

    private func fetchTodayMatchesNextPage() {
        if !todayMatchesHasNextPage {
            return
        }
        self.todayMatchesPage += 1
        self.fetchTodayMatches()
    }

    private func fetchTodayMatches(withFilter: Bool = false, timeRange: String = "") {

        if let todayMatchesRegister = todayMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: todayMatchesRegister)
        }

        let matchesCount = self.todayMatchesCount * self.todayMatchesPage

        var endpoint = TSRouter.todayMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                      language: "en",
                                                      sportId: self.selectedSport.id,
                                                      matchesCount: matchesCount)

        if withFilter {
            endpoint = TSRouter.todayMatchesFilterPublisher(operatorId: Env.appSession.operatorId,
                                                          language: "en",
                                                            sportId: self.selectedSport.id,
                                                          matchesCount: matchesCount, timeRange: timeRange)
        }

        self.todayMatchesPublisher?.cancel()
        self.todayMatchesPublisher = nil

        self.todayMatchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")

                case .finished:
                    print("Data retrieved!")
                }
                self?.isLoadingTodayList.send(false)
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("PreLiveEventsViewModel todayMatchesPublisher connect")
                    self?.todayMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("PreLiveEventsViewModel todayMatchesPublisher initialContent")
                    self?.setupTodayAggregatorProcessor(aggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    self?.updateTodayAggregatorProcessor(aggregator: aggregatorUpdates)
                case .disconnect:
                    print("PreLiveEventsViewModel todayMatchesPublisher disconnect")
                }
            })
    }

    func fetchCompetitionsFilters() {

        let language = "en"
        let sportId = self.selectedSport.id

        let popularTournamentsPublisher = Env.everyMatrixClient.manager
            .getModel(router: TSRouter.getCustomTournaments(language: language, sportId: sportId),
                      decodingType: EveryMatrixSocketResponse<EveryMatrix.Tournament>.self)
            .eraseToAnyPublisher()

        if let tournamentsRegister = tournamentsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: tournamentsRegister)
        }

        self.tournamentsPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(TSRouter.tournamentsPublisher(operatorId: Env.appSession.operatorId,
                                                              language: language,
                                                              sportId: sportId),
                      decodingType: EveryMatrixSocketResponse<EveryMatrix.Tournament>.self)
            .handleEvents(receiveCompletion: { completion in
                print("completion \(completion)")
            })
            .map({ [weak self] (subscriptionContent: TSSubscriptionContent<EveryMatrixSocketResponse<EveryMatrix.Tournament>>) -> [EveryMatrix.Tournament]? in
                if case .connect(let publisherIdentifiable) = subscriptionContent {
                    self?.tournamentsRegister = publisherIdentifiable
                }
                else if case let .initialContent(initialDumpContent) = subscriptionContent {
                    return initialDumpContent.records ?? []
                }
                return nil
            })
            .compactMap({$0})
            .eraseToAnyPublisher()

        if let locationsRegister = locationsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: locationsRegister)
        }

        self.locationsPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(TSRouter.locationsPublisher(operatorId: Env.appSession.operatorId,
                                                          language: language,
                                                          sportId: sportId),
                      decodingType: EveryMatrixSocketResponse<EveryMatrix.Location>.self)
            .handleEvents(receiveCompletion: { completion in
                print("completion \(completion)")
            })
            .map({ [weak self] (subscriptionContent: TSSubscriptionContent<EveryMatrixSocketResponse<EveryMatrix.Location>>) -> [EveryMatrix.Location]? in
                if case .connect(let publisherIdentifiable) = subscriptionContent {
                    self?.locationsRegister = publisherIdentifiable
                }
                else if case let .initialContent(initialDumpContent) = subscriptionContent {
                    return initialDumpContent.records ?? []
                }
                return nil
            })
            .compactMap({$0})
            .eraseToAnyPublisher()

        guard
            let locationsPublisher = self.locationsPublisher,
            let tournamentsPublisher = self.tournamentsPublisher
        else {
            return
        }

        self.zip3Publisher?.cancel()
        self.zip3Publisher = nil

        self.zip3Publisher = Publishers.Zip3(popularTournamentsPublisher, tournamentsPublisher, locationsPublisher)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }

                self?.isLoadingCompetitionGroups.send(false)

                self?.zip3Publisher?.cancel()
                self?.zip3Publisher = nil

                if let locationsRegister = self?.locationsRegister {
                    Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: locationsRegister)
                }

                if let tournamentsRegister = self?.tournamentsRegister {
                    Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: tournamentsRegister)
                }

            }, receiveValue: { [weak self] popularTournaments, tournaments, locations in
                Env.everyMatrixStorage.storePopularTournaments(tournaments: popularTournaments.records ?? [])
                Env.everyMatrixStorage.storeTournaments(tournaments: tournaments)
                Env.everyMatrixStorage.storeLocations(locations: locations)

                self?.setupCompetitionGroups()
            })
        //
        //
    }

    func fetchCompetitionsMatchesWithIds(_ ids: [String]) {

        self.isLoadingCompetitions.send(true)

        if let competitionsMatchesRegister = competitionsMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: competitionsMatchesRegister)
        }

        let endpoint = TSRouter.competitionsMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                             language: "en",
                                                             sportId: self.selectedSport.id,
                                                             events: ids)

        self.competitionsMatchesPublisher?.cancel()
        self.competitionsMatchesPublisher = nil

        self.competitionsMatchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
                self?.isLoadingCompetitions.send(false)
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("PreLiveEventsViewModel competitionsMatchesPublisher connect")
                    self?.competitionsMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("PreLiveEventsViewModel competitionsMatchesPublisher initialContent")
                    self?.setupCompetitionsAggregatorProcessor(aggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    self?.updateCompetitionsAggregatorProcessor(aggregator: aggregatorUpdates)
                    print("PreLiveEventsViewModel competitionsMatchesPublisher updatedContent")
                case .disconnect:
                    print("PreLiveEventsViewModel competitionsMatchesPublisher disconnect")
                }
            })
    }

    func fetchFavoriteCompetitionsMatchesWithIds(_ ids: [String]) {

        if let favoriteCompetitionsMatchesRegister = favoriteCompetitionsMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: favoriteCompetitionsMatchesRegister)
        }

        let endpoint = TSRouter.competitionsMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                             language: "en",
                                                             sportId: self.selectedSport.id,
                                                             events: ids)

        self.favoriteCompetitionsMatchesPublisher?.cancel()
        self.favoriteCompetitionsMatchesPublisher = nil

        self.favoriteCompetitionsMatchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("PreLiveEventsViewModel favoriteCompetitionsMatchesPublisher connect")
                    self?.favoriteCompetitionsMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("PreLiveEventsViewModel favoriteCompetitionsMatchesPublisher initialContent")
                    self?.setupFavoriteCompetitionsAggregatorProcessor(aggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    self?.updateFavoriteCompetitionsAggregatorProcessor(aggregator: aggregatorUpdates)
                    print("PreLiveEventsViewModel favoriteCompetitionsMatchesPublisher updatedContent")
                case .disconnect:
                    print("PreLiveEventsViewModel favoriteCompetitionsMatchesPublisher disconnect")
                }
            })
    }

    private func fetchFavoriteMatches() {

        if let favoriteMatchesRegister = favoriteMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: favoriteMatchesRegister)
        }

        guard let userId = Env.userSessionStore.userSessionPublisher.value?.userId else { return }

        let endpoint = TSRouter.favoriteMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                      language: "en",
                                                      userId: userId)

        self.favoriteMatchesPublisher?.cancel()
        self.favoriteMatchesPublisher = nil

        self.favoriteMatchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving Favorite data!")

                case .finished:
                    print("Favorite Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("PreLiveEventsViewModel favoriteMatchesPublisher connect")
                    self?.favoriteMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("PreLiveEventsViewModel favoriteMatchesPublisher initialContent")
                    self?.setupFavoriteMatchesAggregatorProcessor(aggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    print("PreLiveEventsViewModel favoriteMatchesPublisher updatedContent")
                    self?.updateFavoriteMatchesAggregatorProcessor(aggregator: aggregatorUpdates)
                case .disconnect:
                    print("PreLiveEventsViewModel favoriteMatchesPublisher disconnect")
                }

            })
    }

    func fetchBanners() {

        if let bannersInfoRegister = bannersInfoRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: bannersInfoRegister)
        }

        let endpoint = TSRouter.bannersInfoPublisher(operatorId: Env.appSession.operatorId, language: "en")

        self.bannersInfoPublisher?.cancel()
        self.bannersInfoPublisher = nil

        self.bannersInfoPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrixSocketResponse<EveryMatrix.BannerInfo>.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("BannersInfoPublisher Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    self?.bannersInfoRegister = publisherIdentifiable
                case .initialContent(let responde):
                    print("PreLiveEventsViewModel bannersInfoPublisher initialContent")
                    let sortedBanners = (responde.records ?? []).sorted {
                        $0.priorityOrder ?? 0 < $1.priorityOrder ?? 1
                    }
                    self?.banners = sortedBanners

                case .updatedContent:
                    print("PreLiveEventsViewModel bannersInfoPublisher updatedContent")
                case .disconnect:
                    print("PreLiveEventsViewModel bannersInfoPublisher disconnect")
                }
                self?.updateContentList()
            })
    }

    //
    //
    // MARK: - Setups
    //

    private func setupFavoriteMatchesAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processAggregator(aggregator, withListType: .favoriteMatchEvents,
                                                 shouldClear: true)
        self.favoriteMatches = Env.everyMatrixStorage.matchesForListType(.favoriteMatchEvents)

        self.favoriteMatches = self.favoriteMatches.filter({
            $0.sportType == self.selectedSport.id
        })

        self.updateContentList()
    }

    private func setupPopularAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processAggregator(aggregator, withListType: .popularEvents,
                                                 shouldClear: true)

        let localPopularMatches = Env.everyMatrixStorage.matchesForListType(.popularEvents)
        if localPopularMatches.count < self.popularMatchesCount * self.popularMatchesPage {
            self.popularMatchesHasNextPage = false
        }

        self.popularMatches = localPopularMatches

        self.isLoadingPopularList.send(false)
        self.updateContentList()
    }

    private func setupTodayAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processAggregator(aggregator, withListType: .todayEvents,
                                                 shouldClear: true)

        let localTodayMatches = Env.everyMatrixStorage.matchesForListType(.todayEvents)
        if localTodayMatches.count < self.todayMatchesCount * self.todayMatchesPage {
            self.todayMatchesHasNextPage = false
        }
        self.todayMatches = localTodayMatches

        self.isLoadingTodayList.send(false)

        self.updateContentList()

    }

    private func setupCompetitionGroups() {
        var addedCompetitionIds: [String] = []

        var popularCompetitions = [Competition]()
        for popularCompetition in Env.everyMatrixStorage.popularTournaments.values where (popularCompetition.sportId ?? "") == self.selectedSport.id {

            let competition = Competition(id: popularCompetition.id, name: popularCompetition.name ?? "")
            addedCompetitionIds.append(popularCompetition.id)
            popularCompetitions.append(competition)
        }

        let popularCompetitionGroup = CompetitionGroup(id: "0",
                                                        name: localized("string_popular_competitions"),
                                                        aggregationType: CompetitionGroup.AggregationType.popular,
                                                        competitions: popularCompetitions)
        var popularCompetitionGroups = [popularCompetitionGroup]

        var competitionsGroups = [CompetitionGroup]()
        for location in Env.everyMatrixStorage.locations.values {

            var locationCompetitions = [Competition]()

            for rawCompetitionId in (Env.everyMatrixStorage.tournamentsForLocation[location.id] ?? []) {

                guard
                    let rawCompetition = Env.everyMatrixStorage.tournaments[rawCompetitionId],
                    (rawCompetition.sportId ?? "") == self.selectedSport.id
                else {
                    continue
                }

                let competition = Competition(id: rawCompetition.id, name: rawCompetition.name ?? "")
                addedCompetitionIds.append(rawCompetition.id)
                locationCompetitions.append(competition)
            }

            let locationCompetitionGroup = CompetitionGroup(id: location.id,
                                                            name: location.name ?? "",
                                                            aggregationType: CompetitionGroup.AggregationType.region,
                                                            competitions: locationCompetitions)

            if locationCompetitions.isNotEmpty {
                competitionsGroups.append(locationCompetitionGroup)
            }
        }

        popularCompetitionGroups.append(contentsOf: competitionsGroups)

        self.competitionGroupsPublisher.send(popularCompetitionGroups)

        self.updateContentList()
    }

    private func setupCompetitionsAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processAggregator(aggregator, withListType: .competitions,
                                                 shouldClear: true)

        let appMatches = Env.everyMatrixStorage.matchesForListType(.competitions)

        self.competitionsMatches = appMatches

        var competitionsMatches = OrderedDictionary<String, [Match]>()
        for match in appMatches {
            if let matchesForId = competitionsMatches[match.competitionId] {
                var newMatchesForId = matchesForId
                newMatchesForId.append(match)
                competitionsMatches[match.competitionId] = newMatchesForId
            }
            else {
                competitionsMatches[match.competitionId] = [match]
            }
        }

        var processedCompetitions: [Competition] = []
        for competitionId in competitionsMatches.keys {
            if let tournament = Env.everyMatrixStorage.tournaments[competitionId] {

                var location: Location?
                if let rawLocation = Env.everyMatrixStorage.location(forId: tournament.venueId ?? "") {
                    location = Location(id: rawLocation.id,
                                    name: rawLocation.name ?? "",
                                    isoCode: rawLocation.code ?? "")
                }

                let competition = Competition(id: competitionId,
                                              name: tournament.name ?? "",
                                              matches: (competitionsMatches[competitionId] ?? []),
                                              venue: location)
                processedCompetitions.append(competition)
            }
        }

        self.competitions = processedCompetitions

        self.isLoadingCompetitions.send(false)

        self.updateContentList()
    }

    private func setupFavoriteCompetitionsAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processAggregator(aggregator, withListType: .favoriteCompetitionEvents,
                                                 shouldClear: true)

        let appMatches = Env.everyMatrixStorage.matchesForListType(.favoriteCompetitionEvents)

        var competitionsMatches = OrderedDictionary<String, [Match]>()
        for match in appMatches {
            if let matchesForId = competitionsMatches[match.competitionId] {
                var newMatchesForId = matchesForId
                newMatchesForId.append(match)
                competitionsMatches[match.competitionId] = newMatchesForId
            }
            else {
                competitionsMatches[match.competitionId] = [match]
            }
        }

        var processedCompetitions: [Competition] = []
        for competitionId in competitionsMatches.keys {
            if let tournament = Env.everyMatrixStorage.tournaments[competitionId], let tournamentSportTypeId = tournament.sportId {

                if tournamentSportTypeId == self.selectedSport.id {

                    var location: Location?
                    if let rawLocation = Env.everyMatrixStorage.location(forId: tournament.venueId ?? "") {
                        location = Location(id: rawLocation.id,
                                        name: rawLocation.name ?? "",
                                        isoCode: rawLocation.code ?? "")
                    }

                    let competition = Competition(id: competitionId,
                                                  name: tournament.name ?? "",
                                                  matches: (competitionsMatches[competitionId] ?? []),
                                                  venue: location)
                    processedCompetitions.append(competition)
                }

            }
        }

        self.favoriteCompetitions = processedCompetitions

        self.updateContentList()
    }

    private func updatePopularAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processContentUpdateAggregator(aggregator)
    }

    private func updateTodayAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processContentUpdateAggregator(aggregator)
    }

    private func updateCompetitionsAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processContentUpdateAggregator(aggregator)
    }

    private func updateFavoriteMatchesAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processContentUpdateAggregator(aggregator)
    }

    private func updateFavoriteCompetitionsAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processContentUpdateAggregator(aggregator)
    }


}

extension PreLiveEventsViewModel: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.matchListTypePublisher.value {
        case .myGames:
            return self.popularMatchesDataSource.numberOfSections(in: tableView)
        case .today:
            return self.todayMatchesDataSource.numberOfSections(in: tableView)
        case .competitions:
            return self.competitionsDataSource.numberOfSections(in: tableView)
        case .favoriteGames:
            return self.favoriteMatchesDataSource.numberOfSections(in: tableView)
        case .favoriteCompetitions:
            return self.favoriteCompetitionsDataSource.numberOfSections(in: tableView)
        }
    }

    func hasContentForSelectedListType() -> Bool {
       switch self.matchListTypePublisher.value {
       case .myGames:
           return self.popularMatchesDataSource.matches.isNotEmpty
       case .today:
           return self.todayMatchesDataSource.todayMatches.isNotEmpty
       case .competitions:
           return self.competitionsDataSource.competitions.isNotEmpty
       case .favoriteGames:
           return self.favoriteMatchesDataSource.userFavoriteMatches.isNotEmpty
       case .favoriteCompetitions:
          return self.favoriteCompetitionsDataSource.competitions.isNotEmpty
       }
   }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.matchListTypePublisher.value {
        case .myGames:
            return self.popularMatchesDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .today:
            return self.todayMatchesDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .competitions:
            return self.competitionsDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .favoriteGames:
            return self.favoriteMatchesDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .favoriteCompetitions:
            return self.favoriteCompetitionsDataSource.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch self.matchListTypePublisher.value {
        case .myGames:
            cell = self.popularMatchesDataSource.tableView(tableView, cellForRowAt: indexPath)
        case .today:
            cell = self.todayMatchesDataSource.tableView(tableView, cellForRowAt: indexPath)
        case .competitions:
            cell = self.competitionsDataSource.tableView(tableView, cellForRowAt: indexPath)
        case .favoriteGames:
            cell = self.favoriteMatchesDataSource.tableView(tableView, cellForRowAt: indexPath)
        case .favoriteCompetitions:
            cell = self.favoriteCompetitionsDataSource.tableView(tableView, cellForRowAt: indexPath)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch self.matchListTypePublisher.value {
        case .myGames:
            return self.popularMatchesDataSource.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        case .today:
            return self.todayMatchesDataSource.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        case .competitions:
            ()
        case .favoriteGames:
            ()
        case .favoriteCompetitions:
            ()
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch self.matchListTypePublisher.value {
        case .myGames:
            return self.popularMatchesDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .today:
            return self.todayMatchesDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .competitions:
            return self.competitionsDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .favoriteGames:
            return self.favoriteMatchesDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .favoriteCompetitions:
            return self.favoriteCompetitionsDataSource.tableView(tableView, viewForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .myGames:
            return self.popularMatchesDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .today:
            return self.todayMatchesDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .competitions:
            return self.competitionsDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .favoriteGames:
            return self.favoriteMatchesDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .favoriteCompetitions:
            return self.favoriteCompetitionsDataSource.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .myGames:
            return self.popularMatchesDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .today:
            return self.todayMatchesDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .competitions:
            return self.competitionsDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .favoriteGames:
            return self.favoriteMatchesDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .favoriteCompetitions:
            return self.favoriteCompetitionsDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .myGames:
            return self.popularMatchesDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .today:
            return self.todayMatchesDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .competitions:
            return self.competitionsDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .favoriteGames:
            return self.favoriteMatchesDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .favoriteCompetitions:
            return self.favoriteCompetitionsDataSource.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .myGames:
            return self.popularMatchesDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .today:
            return self.todayMatchesDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .competitions:
            return self.competitionsDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .favoriteGames:
            return self.favoriteMatchesDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .favoriteCompetitions:
            return self.favoriteCompetitionsDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}
