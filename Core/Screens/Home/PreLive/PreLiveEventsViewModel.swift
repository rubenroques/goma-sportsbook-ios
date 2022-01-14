//
//  PreLiveEventsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 10/10/2021.
//

import UIKit
import Combine
import OrderedCollections

// swiftlint:disable type_body_length

class PreLiveEventsViewModel: NSObject {

    private var banners: [EveryMatrix.BannerInfo] = []

    private var userFavoriteMatches: [Match] = []
    private var popularMatches: [Match] = []

    private var todayMatches: [Match] = []

    private var competitionsMatches: [Match] = []
    private var competitions: [Competition] = []

    private var favoriteMatches: [Match] = []
    private var favoriteCompetitions: [Competition] = []

    var competitionGroupsPublisher: CurrentValueSubject<[CompetitionGroup], Never> = .init([])

    var matchListTypePublisher: CurrentValueSubject<MatchListType, Never> = .init(.myGames)
    enum MatchListType {
        case myGames
        case today
        case competitions
        case favoriteGames
        case favoriteCompetitions
    }

    enum screenState {
            case emptyAndFilter
            case emptyNoFilter
            case noEmptyNoFilter
            case noEmptyAndFilter
        }
    
    var screenStatePublisher: CurrentValueSubject<screenState, Never> = .init(.noEmptyNoFilter)
   
    private var popularMatchesViewModelDataSource = PopularMatchesViewModelDataSource(banners: [], matches: [])
    private var todaySportsViewModelDataSource = TodaySportsViewModelDataSource(todayMatches: [])
    private var competitionSportsViewModelDataSource = CompetitionSportsViewModelDataSource(competitions: [])
    private var favoriteGamesSportsViewModelDataSource = FavoriteGamesSportsViewModelDataSource(userFavoriteMatches: [])
    private var favoriteCompetitionSportsViewModelDataSource = FavoriteCompetitionSportsViewModelDataSource(favoriteCompetitions: [])

    private var isLoadingPopularList: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingTodayList: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingMyGamesList: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingCompetitions: CurrentValueSubject<Bool, Never> = .init(true)

    var isLoadingCompetitionGroups: CurrentValueSubject<Bool, Never> = .init(true)

    var isLoading: AnyPublisher<Bool, Never>

    var didChangeSportType = false
    var selectedSportId: SportType {
        willSet {
            if newValue != self.selectedSportId {
                didChangeSportType = true
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

    var dataDidChangedAction: (() -> Void)?
    var didSelectActivationAlertAction: ((ActivationAlertType) -> Void)?
    var didSelectMatchAction: ((Match) -> Void)?

    private var cancellables = Set<AnyCancellable>()

    private var zip3Publisher: AnyCancellable?

    private var popularMatchesPublisher: AnyCancellable?
    private var todayMatchesPublisher: AnyCancellable?
    private var tournamentsPublisher: AnyPublisher<[EveryMatrix.Tournament], EveryMatrix.APIError>?
    private var locationsPublisher: AnyPublisher<[EveryMatrix.Location], EveryMatrix.APIError>?
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
    private var todayMatchesCount = 10
    private var todayMatchesPage = 1
    private var favoriteMatchesCount = 10
    private var favoriteMatchesPage = 1
    
    var isUserLoggedPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    init(selectedSportId: SportType) {
        self.selectedSportId = selectedSportId
        
        isLoading = Publishers.CombineLatest4(isLoadingTodayList, isLoadingPopularList, isLoadingMyGamesList, isLoadingCompetitions)
            .map({ isLoadingTodayList, isLoadingPopularList, isLoadingMyGamesList, isLoadingCompetitions in
                let isLoading = isLoadingTodayList || isLoadingPopularList || isLoadingMyGamesList || isLoadingCompetitions
                return isLoading
            })
            .eraseToAnyPublisher()

        super.init()

        // ActivationAlertAction
        //
        self.popularMatchesViewModelDataSource.didSelectActivationAlertAction = { [weak self] alertType in
            self?.didSelectActivationAlertAction?(alertType)
        }

        // NextPage
        //
        self.popularMatchesViewModelDataSource.requestNextPageAction = { [weak self] in
            self?.fetchPopularMatchesNextPage()
        }
        self.todaySportsViewModelDataSource.requestNextPageAction = { [weak self] in
            self?.fetchTodayMatchesNextPage()
        }

        // didSelectMatchA
        //
        self.popularMatchesViewModelDataSource.didSelectMatchAction = { [weak self] match in
            self?.didSelectMatchAction?(match)
        }
        self.todaySportsViewModelDataSource.didSelectMatchAction = { [weak self] match in
            self?.didSelectMatchAction?(match)
        }
        self.competitionSportsViewModelDataSource.didSelectMatchAction = { [weak self] match in
            self?.didSelectMatchAction?(match)
        }
        self.favoriteGamesSportsViewModelDataSource.didSelectMatchAction = { [weak self] match in
            self?.didSelectMatchAction?(match)
        }
        self.favoriteGamesSportsViewModelDataSource.matchDataSourceWentLive = { [weak self] in
            self?.dataDidChangedAction?()
        }

        self.favoriteCompetitionSportsViewModelDataSource.didSelectMatchAction = { [weak self] match in
            self?.didSelectMatchAction?(match)
        }
        self.favoriteCompetitionSportsViewModelDataSource.matchDataSourceWentLive = { [weak self] in
            self?.dataDidChangedAction?()
        }

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
                self.popularMatchesViewModelDataSource.refetchAlerts()
            })
            .store(in: &cancellables)
    }

    func fetchData() {
        self.isLoadingPopularList.send(true)
        self.isLoadingTodayList.send(true)
        self.isLoadingMyGamesList.send(true)
        self.isLoadingCompetitions.send(true)
        self.isLoadingCompetitionGroups.send(true)

        self.popularMatchesPage = 1
        self.todayMatchesPage = 1
        self.favoriteMatchesPage = 1
        
        self.competitionsMatches = []
        self.competitions = []

        self.competitionGroupsPublisher.send([])

        self.fetchBanners()

        self.fetchPopularMatches()
        self.fetchTodayMatches()
        self.fetchCompetitionsFilters()

        self.setupPublishers()

        self.isLoadingCompetitions.send(false)
        self.isLoadingMyGamesList.send(false)
        
        self.isUserLoggedPublisher.send(UserSessionStore.isUserLogged())
    
    }

    func setMatchListType(_ matchListType: MatchListType) {
        self.matchListTypePublisher.send(matchListType)
        self.updateContentList()
    }

    private func updateContentList() {

        self.isLoadingMyGamesList.send(false)

        self.popularMatchesViewModelDataSource.matches = filterPopularMatches(with: self.homeFilterOptions, matches: self.popularMatches)

        self.popularMatchesViewModelDataSource.banners = self.banners

        self.todaySportsViewModelDataSource.todayMatches = filterTodayMatches(with: self.homeFilterOptions, matches: self.todayMatches)

        self.competitionSportsViewModelDataSource.competitions = filterCompetitionMatches(with: self.homeFilterOptions, competitions: self.competitions)

        self.favoriteGamesSportsViewModelDataSource.userFavoriteMatches = self.favoriteMatches

        self.favoriteCompetitionSportsViewModelDataSource.competitions = self.favoriteCompetitions

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
        
        // Todo - Code Review
        DispatchQueue.main.async {
            self.dataDidChangedAction?()
        }
        
    }

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
            for market in match.markets {
                if market.typeId != marketSort[0].typeId {
                    marketSort.append(market)
                }
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
        for competition in competitions {
            if !competition.matches.isEmpty {
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
        }
        return filteredCompetitions
    }

    private func setupFavoriteMatchesAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processAggregator(aggregator, withListType: .favoriteMatchEvents,
                                                 shouldClear: true)
        self.favoriteMatches = Env.everyMatrixStorage.matchesForListType(.favoriteMatchEvents)

        self.favoriteMatches = self.favoriteMatches.filter({
            $0.sportType == self.selectedSportId.id
        })

        self.updateContentList()
    }

    private func setupPopularAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processAggregator(aggregator, withListType: .popularEvents,
                                                 shouldClear: true)
        self.popularMatches = Env.everyMatrixStorage.matchesForListType(.popularEvents)
        self.isLoadingPopularList.send(false)
        self.updateContentList()
    }

    private func setupTodayAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processAggregator(aggregator, withListType: .todayEvents,
                                                 shouldClear: true)
        self.todayMatches = Env.everyMatrixStorage.matchesForListType(.todayEvents)

        self.isLoadingTodayList.send(false)

        self.updateContentList()
       
    }

    private func setupCompetitionGroups() {
        var addedCompetitionIds: [String] = []

        var popularCompetitions = [Competition]()
        for popularCompetition in Env.everyMatrixStorage.popularTournaments.values
        where (popularCompetition.sportId ?? "") == self.selectedSportId.typeId {

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
                    (rawCompetition.sportId ?? "") == self.selectedSportId.typeId
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

                if tournamentSportTypeId == self.selectedSportId.id {

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

//        self.favoriteCompetitions = self.favoriteCompetitions.filter({
//            $0. == self.selectedSportId.id
//        })

        self.isLoadingCompetitions.send(false)

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

    //
    // MARK: - Fetches
    //
    //

    private func fetchPopularMatchesNextPage() {
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
                                                        sportId: self.selectedSportId.typeId,
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
                                                      sportId: self.selectedSportId.typeId,
                                                      matchesCount: matchesCount)

        if withFilter {
            endpoint = TSRouter.todayMatchesFilterPublisher(operatorId: Env.appSession.operatorId,
                                                          language: "en",
                                                          sportId: self.selectedSportId.typeId,
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
        let sportId = self.selectedSportId.typeId

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

        let endpoint = TSRouter.competitionsMatchesPublisher(operatorId: Env.appSession.operatorId, language: "en", sportId: self.selectedSportId.typeId, events: ids)

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

        let endpoint = TSRouter.competitionsMatchesPublisher(operatorId: Env.appSession.operatorId, language: "en", sportId: self.selectedSportId.typeId, events: ids)

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

}

extension PreLiveEventsViewModel: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.matchListTypePublisher.value {
        case .myGames:
            return self.popularMatchesViewModelDataSource.numberOfSections(in: tableView)
        case .today:
            return self.todaySportsViewModelDataSource.numberOfSections(in: tableView)
        case .competitions:
            return self.competitionSportsViewModelDataSource.numberOfSections(in: tableView)
        case .favoriteGames:
            return self.favoriteGamesSportsViewModelDataSource.numberOfSections(in: tableView)
        case .favoriteCompetitions:
            return self.favoriteCompetitionSportsViewModelDataSource.numberOfSections(in: tableView)
        }
    }

    func hasContentForSelectedListType() -> Bool {
       switch self.matchListTypePublisher.value {
       case .myGames:
           return self.popularMatchesViewModelDataSource.matches.isNotEmpty
       case .today:
           return self.todaySportsViewModelDataSource.todayMatches.isNotEmpty
       case .competitions:
           return self.competitionSportsViewModelDataSource.competitions.isNotEmpty
       case .favoriteGames:
           print("favs \(self.favoriteGamesSportsViewModelDataSource.userFavoriteMatches.count)")
           return self.favoriteGamesSportsViewModelDataSource.userFavoriteMatches.isNotEmpty
       case .favoriteCompetitions:
          return self.favoriteCompetitionSportsViewModelDataSource.competitions.isNotEmpty
       }
   }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.matchListTypePublisher.value {
        case .myGames:
            return self.popularMatchesViewModelDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .today:
            return self.todaySportsViewModelDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .competitions:
            return self.competitionSportsViewModelDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .favoriteGames:
            return self.favoriteGamesSportsViewModelDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .favoriteCompetitions:
            return self.favoriteCompetitionSportsViewModelDataSource.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch self.matchListTypePublisher.value {
        case .myGames:
            cell = self.popularMatchesViewModelDataSource.tableView(tableView, cellForRowAt: indexPath)
        case .today:
            cell = self.todaySportsViewModelDataSource.tableView(tableView, cellForRowAt: indexPath)
        case .competitions:
            cell = self.competitionSportsViewModelDataSource.tableView(tableView, cellForRowAt: indexPath)
        case .favoriteGames:
            cell = self.favoriteGamesSportsViewModelDataSource.tableView(tableView, cellForRowAt: indexPath)
        case .favoriteCompetitions:
            cell = self.favoriteCompetitionSportsViewModelDataSource.tableView(tableView, cellForRowAt: indexPath)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch self.matchListTypePublisher.value {
        case .myGames:
            return self.popularMatchesViewModelDataSource.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        case .today:
            return self.todaySportsViewModelDataSource.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        case .competitions:
            return self.competitionSportsViewModelDataSource.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        case .favoriteGames:
            return self.favoriteGamesSportsViewModelDataSource.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        case .favoriteCompetitions:
            return self.favoriteCompetitionSportsViewModelDataSource.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch self.matchListTypePublisher.value {
        case .myGames:
            return self.popularMatchesViewModelDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .today:
            return self.todaySportsViewModelDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .competitions:
            return self.competitionSportsViewModelDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .favoriteGames:
            return self.favoriteGamesSportsViewModelDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .favoriteCompetitions:
            return self.favoriteCompetitionSportsViewModelDataSource.tableView(tableView, viewForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .myGames:
            return self.popularMatchesViewModelDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .today:
            return self.todaySportsViewModelDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .competitions:
            return self.competitionSportsViewModelDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .favoriteGames:
            return self.favoriteGamesSportsViewModelDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .favoriteCompetitions:
            return self.favoriteCompetitionSportsViewModelDataSource.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .myGames:
            return self.popularMatchesViewModelDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .today:
            return self.todaySportsViewModelDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .competitions:
            return self.competitionSportsViewModelDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .favoriteGames:
            return self.favoriteGamesSportsViewModelDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .favoriteCompetitions:
            return self.favoriteCompetitionSportsViewModelDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .myGames:
            return self.popularMatchesViewModelDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .today:
            return self.todaySportsViewModelDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .competitions:
            return self.competitionSportsViewModelDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .favoriteGames:
            return self.favoriteGamesSportsViewModelDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .favoriteCompetitions:
            return self.favoriteCompetitionSportsViewModelDataSource.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .myGames:
            return self.popularMatchesViewModelDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .today:
            return self.todaySportsViewModelDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .competitions:
            return self.competitionSportsViewModelDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .favoriteGames:
            return self.favoriteGamesSportsViewModelDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .favoriteCompetitions:
            return self.favoriteCompetitionSportsViewModelDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}

class PopularMatchesViewModelDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var banners: [EveryMatrix.BannerInfo] = [] {
        didSet {
            self.bannersViewModel = self.createBannersViewModel()
        }
    }

    private var bannersViewModel: BannerLineCellViewModel?
    var cachedBannerCellViewModel: [String: BannerCellViewModel] = [:]
    var cachedBannerLineCellViewModel: BannerLineCellViewModel?
    var didCachedBanners: Bool = false

    var matches: [Match] = []

    var alertsArray: [ActivationAlert] = []

    var requestNextPageAction: (() -> Void)?
    var didSelectActivationAlertAction: ((ActivationAlertType) -> Void)?
    var didSelectMatchAction: ((Match) -> Void)?

    init(banners: [EveryMatrix.BannerInfo], matches: [Match]) {
        self.banners = banners
        self.matches = matches

        if let userSession = UserSessionStore.loggedUserSession() {
            if !userSession.isEmailVerified {

                let emailActivationAlertData = ActivationAlert(title: localized("string_verify_email"), description: localized("string_app_full_potential"), linkLabel: localized("string_verify_my_account"), alertType: .email)

                alertsArray.append(emailActivationAlertData)
            }

            if Env.userSessionStore.isUserProfileIncomplete.value {
                let completeProfileAlertData = ActivationAlert(title: localized("string_complete_your_profile"), description: localized("string_complete_profile_description"), linkLabel: localized("string_finish_up_profile"), alertType: .profile)

                alertsArray.append(completeProfileAlertData)
            }
        }

        super.init()
    }

    func refetchAlerts() {
        alertsArray = []

        if let userSession = UserSessionStore.loggedUserSession() {
            if !userSession.isEmailVerified {

                let emailActivationAlertData = ActivationAlert(title: localized("string_verify_email"), description: localized("string_app_full_potential"), linkLabel: localized("string_verify_my_account"), alertType: .email)

                alertsArray.append(emailActivationAlertData)
            }

            if Env.userSessionStore.isUserProfileIncomplete.value {
                let completeProfileAlertData = ActivationAlert(title: localized("string_complete_your_profile"), description: localized("string_complete_profile_description"), linkLabel: localized("string_finish_up_profile"), alertType: .profile)

                alertsArray.append(completeProfileAlertData)
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if UserSessionStore.isUserLogged(), let loggedUser = UserSessionStore.loggedUserSession() {
                if !loggedUser.isEmailVerified {
                    return 1
                }
                else if Env.userSessionStore.isUserProfileIncomplete.value {
                    return 1
                }
            }
            return 0
        case 1:
            return banners.isEmpty ? 0 : 1
        case 2:
            return self.matches.count
        case 3:
            return 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // return UITableViewCell()
            if let cell = tableView.dequeueCellType(ActivationAlertScrollableTableViewCell.self) {
                cell.activationAlertCollectionViewCellLinkLabelAction = { alertType in
                    self.didSelectActivationAlertAction?(alertType)
                }
                cell.setAlertArrayData(arrayData: alertsArray)
                return cell
            }
        case 1:
            if let cell = tableView.dequeueCellType(BannerScrollTableViewCell.self) {
                if !didCachedBanners {
                    if let cachedViewModel = self.cachedBannerLineCellViewModel {
                        cell.setupWithViewModel(cachedViewModel)

                        cell.tappedBannerMatchAction = { match in
                            self.didSelectMatchAction?(match)
                        }
                        didCachedBanners = true
                    }
                }
//                else {
//                    if let viewModel = self.bannersViewModel {
//                        cell.setupWithViewModel(viewModel)
//
//                        cell.tappedBannerMatchAction = { match in
//                            self.didSelectMatchAction?(match)
//                        }
//                    }
//                }

                return cell
            }
        case 2:
            if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
               let match = self.matches[safe: indexPath.row] {
                cell.setupWithMatch(match)

                cell.tappedMatchLineAction = {
                    self.didSelectMatchAction?(match)
                }
                return cell
            }
        case 3:
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
        headerView.sectionTitleLabel.text = "Popular Games"
        return headerView
    }

    private func createBannersViewModel() -> BannerLineCellViewModel? {
        if self.banners.isEmpty {
            return nil
        }
        var cells = [BannerCellViewModel]()
        for banner in self.banners {
            if let cachedBannerCell = cachedBannerCellViewModel[banner.id] {
                cells.append(cachedBannerCell)
            }
            else {
                cells.append(BannerCellViewModel(matchId: banner.matchID, imageURL: banner.imageURL ?? ""))
            }
        }
        if let cachedBannerLineCellViewModel = cachedBannerLineCellViewModel {
            return cachedBannerLineCellViewModel
        }
        else {
            cachedBannerLineCellViewModel = BannerLineCellViewModel(banners: cells)
            return cachedBannerLineCellViewModel
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 54
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 54
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 132
        case 3:
            // Loading cell
            return 70
        default:
            return 155
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 130
        case 3:
            // Loading cell
            return 70
        default:
            return 155
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 3, self.matches.isNotEmpty {
            if let typedCell = cell as? LoadingMoreTableViewCell {
                typedCell.activityIndicatorView.startAnimating()
            }
            self.requestNextPageAction?()
        }
    }

}

class TodaySportsViewModelDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var todayMatches: [Match] = []

    var requestNextPageAction: (() -> Void)?
    var didSelectMatchAction: ((Match) -> Void)?

    init(todayMatches: [Match]) {
        self.todayMatches = todayMatches
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.todayMatches.count
        case 1:
            return 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
               let match = self.todayMatches[safe: indexPath.row] {
                cell.setupWithMatch(match)
                cell.tappedMatchLineAction = {
                    self.didSelectMatchAction?(match)
                }
                return cell
            }
        case 1:
            if let cell = tableView.dequeueCellType(LoadingMoreTableViewCell.self) {
                cell.activityIndicatorView.startAnimating()
                return cell
            }
        default:
            ()
        }
        fatalError()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier)
            as? TitleTableViewHeader {
            headerView.sectionTitleLabel.text = localized("string_upcoming_highlights")
            return headerView
        }
        return nil
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
            // Loading cell
            return 70
        default:
            return 155
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            // Loading cell
            return 70
        default:
            return 155
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1, self.todayMatches.isNotEmpty {
            if let typedCell = cell as? LoadingMoreTableViewCell {
                typedCell.activityIndicatorView.startAnimating()
            }
            self.requestNextPageAction?()
        }
    }
}

class CompetitionSportsViewModelDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var competitions: [Competition] = [] {
        didSet {
            self.collapsedCompetitionsSections = []
        }
    }
    var collapsedCompetitionsSections: Set<Int> = []

    var didSelectMatchAction: ((Match) -> Void)?

    init(competitions: [Competition]) {
        self.competitions = competitions
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return competitions.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let competition = competitions[safe: section] {
            return competition.matches.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
            let competition = self.competitions[safe: indexPath.section],
            let match = competition.matches[safe: indexPath.row]
        else {
            fatalError()
        }
        cell.setupWithMatch(match)
        cell.shouldShowCountryFlag(false)
        cell.tappedMatchLineAction = {
            self.didSelectMatchAction?(match)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TournamentTableViewHeader.identifier)
                as? TournamentTableViewHeader,
            let competition = self.competitions[safe: section]
        else {
            fatalError()
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

            if weakSelf.collapsedCompetitionsSections.contains(section) {
                weakSelf.collapsedCompetitionsSections.remove(section)
            }
            else {
                weakSelf.collapsedCompetitionsSections.insert(section)
            }
            weakSelf.needReloadSection(section, tableView: weakTableView)
        }
        if self.collapsedCompetitionsSections.contains(section) {
            headerView.collapseImageView.image = UIImage(named: "arrow_down_icon")
        }
        else {
            headerView.collapseImageView.image = UIImage(named: "arrow_up_icon")
        }

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.collapsedCompetitionsSections.contains(indexPath.section) {
            return 0
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.collapsedCompetitionsSections.contains(indexPath.section) {
            return 0
        }
        return 155
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

    }

    func needReloadSection(_ section: Int, tableView: UITableView) {

        guard let competition = self.competitions[safe: section] else { return }

        let rows = (0 ..< competition.matches.count).map({ IndexPath(row: $0, section: section) }) // all section rows

        tableView.beginUpdates()
        tableView.reloadRows(at: rows, with: .automatic)
        tableView.endUpdates()

    }

}

class FavoriteGamesSportsViewModelDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var userFavoriteMatches: [Match] = []

    var requestNextPage: (() -> Void)?
    var didSelectMatchAction: ((Match) -> Void)?
    var matchDataSourceWentLive: (() -> Void)?

    init(userFavoriteMatches: [Match]) {
        self.userFavoriteMatches = userFavoriteMatches

        super.init()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if self.userFavoriteMatches.isEmpty {
                return 1
            }
            return self.userFavoriteMatches.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            if !self.userFavoriteMatches.isEmpty {
                if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
                   let match = self.userFavoriteMatches[safe: indexPath.row] {

                    if Env.everyMatrixStorage.matchesInfoForMatchPublisher.value.contains(match.id) {

                        cell.setupWithMatch(match, liveMatch: true)
                    }
                    else {
                        cell.setupWithMatch(match)

                    }
                    cell.setupFavoriteMatchInfoPublisher(match: match)

                    cell.tappedMatchLineAction = {
                        self.didSelectMatchAction?(match)
                    }

                    cell.matchWentLive = {
                        DispatchQueue.main.async {
                            self.matchDataSourceWentLive?()
                        }
                    }

                    return cell
                }
            }
            else {
                if let cell = tableView.dequeueCellType(EmptyCardTableViewCell.self) {
                    cell.setDescription(primaryText: localized("string_empty_my_games"), secondaryText: localized("second_string_empty_my_games"), userIsLoggedIn: UserSessionStore.isUserLogged() )
                    return cell
                }
                
            }
        default:
            ()
        }
        fatalError()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier)
            as? TitleTableViewHeader {
            headerView.sectionTitleLabel.text = localized("string_my_games")
            return headerView
        }
        return nil
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
            // Loading cell
            return 70
        case 0:
            if self.userFavoriteMatches.isEmpty {
                return 600
            }
            else {
                return 155
            }
        default:
            return 155
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            // Loading cell
            return 70
        default:
            return 155
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

    }

}

class FavoriteCompetitionSportsViewModelDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var competitions: [Competition] = [] {
        didSet {
            self.collapsedCompetitionsSections = []
        }
    }
    var collapsedCompetitionsSections: Set<Int> = []

    var didSelectMatchAction: ((Match) -> Void)?
    var matchDataSourceWentLive: (() -> Void)?

    init(favoriteCompetitions: [Competition]) {
        self.competitions = favoriteCompetitions
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return competitions.isEmpty ? 1 : competitions.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let competition = competitions[safe: section] {
            return competition.matches.count
        }
        else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !competitions.isEmpty {
            guard
                let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
                let competition = self.competitions[safe: indexPath.section],
                let match = competition.matches[safe: indexPath.row]
            else {
                fatalError()
            }
            if let matchInfo = Env.everyMatrixStorage.matchesInfoForMatch[match.id] {
                cell.setupWithMatch(match, liveMatch: true)
            }
            else {
                cell.setupWithMatch(match)
            }

            cell.shouldShowCountryFlag(false)
            cell.tappedMatchLineAction = {
                self.didSelectMatchAction?(match)
            }
            cell.matchWentLive = {
                self.matchDataSourceWentLive?()
            }

            return cell
        }
        else {
            guard
                let cell = tableView.dequeueCellType(EmptyCardTableViewCell.self)
                else {
                    fatalError()
                }
            cell.setDescription(primaryText: localized("string_empty_my_competitions"), secondaryText: localized("string_empty_my_competitions"), userIsLoggedIn: UserSessionStore.isUserLogged() )

            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TournamentTableViewHeader.identifier)
                as? TournamentTableViewHeader,
            let competition = self.competitions[safe: section]
        else {
            // fatalError()
            if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier)
                as? TitleTableViewHeader {
                headerView.sectionTitleLabel.text = localized("string_my_competitions")
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

            if weakSelf.collapsedCompetitionsSections.contains(section) {
                weakSelf.collapsedCompetitionsSections.remove(section)
            }
            else {
                weakSelf.collapsedCompetitionsSections.insert(section)
            }
            weakSelf.needReloadSection(section, tableView: weakTableView)
        }
        if self.collapsedCompetitionsSections.contains(section) {
            headerView.collapseImageView.image = UIImage(named: "arrow_down_icon")
        }
        else {
            headerView.collapseImageView.image = UIImage(named: "arrow_up_icon")
        }

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.collapsedCompetitionsSections.contains(indexPath.section) {
            return 0
        }
        if competitions.isEmpty {
            return 600
        }
        
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.collapsedCompetitionsSections.contains(indexPath.section) {
            return 0
        }
        if competitions.isEmpty {
            return 70
        }
        return 155
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

    }

    func needReloadSection(_ section: Int, tableView: UITableView) {

        guard let competition = self.competitions[safe: section] else { return }

        let rows = (0 ..< competition.matches.count).map({ IndexPath(row: $0, section: section) }) // all section rows

        tableView.beginUpdates()
        tableView.reloadRows(at: rows, with: .automatic)
        tableView.endUpdates()

    }

}
