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
            }
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

    var didSelectMatchAction: ((Match) -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var didSelectCompetitionAction: ((Competition) -> Void)?
    var didLongPressOddAction: ((BettingTicket) -> Void)?
    var resetScrollPositionAction: (() -> Void)?

    var isUserLoggedPublisher: CurrentValueSubject<Bool, Never> = .init(true)

    var selectedCompetitionsInfoPublisher: CurrentValueSubject<[String: SportCompetitionInfo], Never> = .init([:])
    var expectedCompetitionsPublisher: CurrentValueSubject<Int, Never> = .init(0)

    var competitionsMatchesSubscriptions: CurrentValueSubject<[String: SportCompetitionInfo], Never> = .init([:])

    //
    // Private vars
    //
    private var banners: [EveryMatrix.BannerInfo] = []

    private var userFavoriteMatches: [Match] = []
    private var popularMatches: [Match] = []
    private var popularOutrightCompetitions: [Competition]?

    private var todayMatches: [Match] = []
    private var todayOutrightCompetitions: [Competition]?

    private var competitionsMatches: [Match] = []
    private var competitions: [Competition] = []
    private var filteredOutrightCompetitions: [Competition]?

    private var favoriteMatches: [Match] = []
    private var favoriteCompetitions: [Competition] = []

    private var popularMatchesDataSource = PopularMatchesDataSource(matches: [], outrightCompetitions: nil)
    private var todayMatchesDataSource = TodayMatchesDataSource(todayMatches: [])
    private var competitionsDataSource = CompetitionsDataSource(competitions: [])
    private var filteredOutrightCompetitionsDataSource = FilteredOutrightCompetitionsDataSource(outrightCompetitions: [])

    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    private var isLoadingPopularList: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingTodayList: CurrentValueSubject<Bool, Never> = .init(true)

    private var lastCompetitionsMatchesRequested: [String] = []
    private var isLoadingCompetitionMatches: CurrentValueSubject<Bool, Never> = .init(false)
    var isLoadingCompetitionGroups: CurrentValueSubject<Bool, Never> = .init(true)
    private var isLoadingCompetitionsData: AnyPublisher<Bool, Never>

    private var competitionsFilterPublisher: AnyCancellable?

    private var tournamentsPublisher: AnyPublisher<[EveryMatrix.Tournament], EveryMatrix.APIError>?
    private var locationsPublisher: AnyPublisher<[EveryMatrix.Location], EveryMatrix.APIError>?

    private var popularMatchesPublisher: AnyCancellable?
    private var popularTournamentsPublisher: AnyCancellable?
    private var todayMatchesPublisher: AnyCancellable?
    private var competitionsMatchesPublisher: AnyCancellable?
    private var bannersInfoPublisher: AnyCancellable?

    private var popularMatchesRegister: EndpointPublisherIdentifiable?
    private var popularOutrightCompetitionsRegister: EndpointPublisherIdentifiable?

    private var todayMatchesRegister: EndpointPublisherIdentifiable?
    private var todayOutrightCompetitionsRegister: EndpointPublisherIdentifiable?

    private var tournamentsRegister: EndpointPublisherIdentifiable?
    private var locationsRegister: EndpointPublisherIdentifiable?
    private var competitionsMatchesRegister: EndpointPublisherIdentifiable?

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

    var sportRegionsPublisher: CurrentValueSubject<[SportRegion], Never> = .init([])
    var regionCompetitionsPublisher: CurrentValueSubject<[String: [SportCompetition]], Never> = .init([:])
    
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
        
        if let popularMatchesRegister = self.popularMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: popularMatchesRegister)
        }
        if let popularOutrightCompetitionsRegister = self.popularOutrightCompetitionsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: popularOutrightCompetitionsRegister)
        }
        if let todayMatchesRegister = self.todayMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: todayMatchesRegister)
        }
        if let tournamentsRegister = self.tournamentsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: tournamentsRegister)
        }
        if let locationsRegister = self.locationsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: locationsRegister)
        }
        if let competitionsMatchesRegister = self.competitionsMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: competitionsMatchesRegister)
        }

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
                //self.competitionsMatchesSubscriptions.value[competitionInfo.id] = competitionInfo
            }
            //self.subscribeCompetitionMatches(forMarketGroupId: competitionInfo.id, competitionInfo: competitionInfo)
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

            self.competitionsDataSource.competitions = []
            self.competitions = []
            self.filteredOutrightCompetitionsDataSource.outrightCompetitions = []

            self.dataChangedPublisher.send()
        }

        // myGames:
            //self.isLoadingPopularList.send(true)
            self.popularMatchesHasNextPage = true
            self.popularMatchesPage = 1
            //self.fetchPopularMatches()

        // today:
            //self.isLoadingTodayList.send(true)
            self.todayMatchesPage = 1
            self.todayMatchesHasNextPage = true
            //self.fetchTodayMatches()

        // competitions:
            // EM TEMP SHUTDOWN
//            self.fetchCompetitionsFilters()
//            if self.lastCompetitionsMatchesRequested.isNotEmpty {
//                self.fetchCompetitionsMatchesWithIds(lastCompetitionsMatchesRequested)
//            }

        self.isLoadingEvents.send(true)

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
    
    func setMatchListType(_ matchListType: MatchListType) {
        switch matchListType {
        case .popular:
            // self.unsubscribeUpcomingMatches()
            self.fetchPopularMatches()
        case .upcoming:
            // self.unsubscribePopularMatches()
            self.fetchTodayMatches()
        case .competitions:
            self.fetchCompetitionsFilters()
        }
        self.matchListTypePublisher.send(matchListType)
        // self.updateContentList()
    }

    private func updateContentList() {

        self.popularMatchesDataSource.matches = filterPopularMatches(with: self.homeFilterOptions,
                                                                              matches: self.popularMatches)

        self.popularMatchesDataSource.outrightCompetitions = self.popularOutrightCompetitions

        if self.popularMatches.isEmpty && self.popularOutrightCompetitions == nil {
            self.fetchOutrightCompetitions()
        }

        //
        self.todayMatchesDataSource.todayMatches = filterTodayMatches(with: self.homeFilterOptions,
                                                                              matches: self.todayMatches)

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

        var filteredMatches: [Match] = []

        for match in matches {
            if match.markets.isEmpty {
                continue
            }
            
            // Check default market order
            var marketSort: [Market] = []
            let favoriteMarketIndex = match.markets.firstIndex(where: { $0.typeId == filterOptionsValue.defaultMarket.marketId })
            
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
                
                if match.markets.isEmpty {
                    continue
                }
                
                // Check default market order
                var marketSort: [Market] = []
                let favoriteMarketIndex = match.markets.firstIndex(where: { $0.typeId == filterOptionsValue.defaultMarket.marketId })
                
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

        self.isLoadingPopularList.send(true)
        self.isLoadingEvents.send(true)

        let sport = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.selectedSport)

        self.popularMatchesPublisher = Env.servicesProvider.subscribePreLiveMatches(forSportType: sport, sortType: .popular)
            .sink(receiveCompletion: { completion in
                print("Prelive subscribePopularMatches completed \(completion)")
                switch completion {
                case .finished:
                    ()
                case .failure:
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
                    self.popularMatches = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups)
                    self.isLoadingPopularList.send(false)
                    self.isLoadingEvents.send(false)
                    self.updateContentList()
                case .disconnected:
                    self.popularMatches = []
                    // self.isLoadingPopularList.send(false)
                    // self.isLoadingEvents.send(false)
                    self.updateContentList()
                    // self.unsubscribePopularMatches()
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

        self.isLoadingTodayList.send(true)
        self.isLoadingEvents.send(true)

        let sportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.selectedSport)

        self.todayMatchesPublisher = Env.servicesProvider.subscribePreLiveMatches(forSportType: sportType, sortType: .date)
            .sink(receiveCompletion: { completion in
                print("Env.servicesProvider.subscribeUpcomingMatches completed \(completion)")
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
                print("Env.servicesProvider.subscribeUpcomingMatches value \(subscribableContent)")
                switch subscribableContent {
                case .connected(let subscription):
                    self.subscriptions.insert(subscription)
                    print("Connected to ws")
                case .contentUpdate(let eventsGroups):
                    self.todayMatches = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups)
                    self.isLoadingTodayList.send(false)
                    self.isLoadingEvents.send(false)
                    self.updateContentList()
                case .disconnected:
                    print("Disconnected from ws")
                    self.todayMatches = []
                    //self.isLoadingTodayList.send(false)
                    //self.isLoadingEvents.send(false)
                    self.updateContentList()
                }
            })

    }

    private func fetchOutrightCompetitions() {
        self.popularOutrightCompetitions = []
        self.isLoadingPopularList.send(false)
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

//        let language = "en"
//        let sportId = self.selectedSport.id
//        let shouldShowEventCategory = self.selectedSport.showEventCategory
//
//        let popularTournamentsPublisher = Env.everyMatrixClient.manager
//            .getModel(router: TSRouter.getCustomTournaments(language: language, sportId: sportId),
//                      decodingType: EveryMatrixSocketResponse<EveryMatrix.Tournament>.self)
//            .eraseToAnyPublisher()
//
//        if let tournamentsRegister = tournamentsRegister {
//            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: tournamentsRegister)
//        }
//
//        self.tournamentsPublisher = Env.everyMatrixClient.manager
//            .registerOnEndpoint(TSRouter.tournamentsPublisher(operatorId: Env.appSession.operatorId,
//                                                              language: language,
//                                                              sportId: sportId),
//                      decodingType: EveryMatrixSocketResponse<EveryMatrix.Tournament>.self)
//            .handleEvents(receiveCompletion: { completion in
//                print("TournamentsPublisher completion \(completion)")
//            })
//            .map({ [weak self] (subscriptionContent: TSSubscriptionContent<EveryMatrixSocketResponse<EveryMatrix.Tournament>>) -> [EveryMatrix.Tournament]? in
//                if case .connect(let publisherIdentifiable) = subscriptionContent {
//                    self?.tournamentsRegister = publisherIdentifiable
//                }
//                else if case let .initialContent(initialDumpContent) = subscriptionContent {
//                    return initialDumpContent.records ?? []
//                }
//                return nil
//            })
//            .compactMap({$0})
//            .eraseToAnyPublisher()
//
//        if shouldShowEventCategory {
//            if let locationsRegister = locationsRegister {
//                Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: locationsRegister)
//            }
//
//            self.locationsPublisher = Env.everyMatrixClient.manager
//                .registerOnEndpoint(TSRouter.eventCategoryBySport(operatorId: Env.appSession.operatorId,
//                                                                language: language,
//                                                                sportId: sportId),
//                                    decodingType: EveryMatrixSocketResponse<EveryMatrix.EventCategory>.self)
//                .handleEvents(receiveCompletion: { completion in
//                    print("EventCategoryBySport completion \(completion)")
//                })
//                .map({ [weak self] (subscriptionContent: TSSubscriptionContent<EveryMatrixSocketResponse<EveryMatrix.EventCategory>>) -> [EveryMatrix.Location]? in
//
//                    if case .connect(let publisherIdentifiable) = subscriptionContent {
//                        self?.locationsRegister = publisherIdentifiable
//                    }
//                    else if case let .initialContent(initialDumpContent) = subscriptionContent {
//
//                        let eventCategoryData = initialDumpContent.records ?? []
//                        let migratedLocation = eventCategoryData.map { eventCategory in
//                            return EveryMatrix.Location.init(id: eventCategory.id,
//                                                             type: "",
//                                                             typeId: nil,
//                                                             name: eventCategory.name,
//                                                             shortName: eventCategory.shortName,
//                                                             code: nil)
//                        }
//                        return migratedLocation
//                    }
//                    return nil
//                })
//                .compactMap({$0})
//                .eraseToAnyPublisher()
//        }
//        else {
//            if let locationsRegister = locationsRegister {
//                Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: locationsRegister)
//            }
//
//            self.locationsPublisher = Env.everyMatrixClient.manager
//                .registerOnEndpoint(TSRouter.locationsPublisher(operatorId: Env.appSession.operatorId,
//                                                                language: language,
//                                                                sportId: sportId),
//                                    decodingType: EveryMatrixSocketResponse<EveryMatrix.Location>.self)
//                .handleEvents(receiveCompletion: { completion in
//                    print("LocationsPublisher completion \(completion)")
//                })
//                .map({ [weak self] (subscriptionContent: TSSubscriptionContent<EveryMatrixSocketResponse<EveryMatrix.Location>>) -> [EveryMatrix.Location]? in
//                    if case .connect(let publisherIdentifiable) = subscriptionContent {
//                        self?.locationsRegister = publisherIdentifiable
//                    }
//                    else if case let .initialContent(initialDumpContent) = subscriptionContent {
//                        return initialDumpContent.records ?? []
//                    }
//                    return nil
//                })
//                .compactMap({$0})
//                .eraseToAnyPublisher()
//
//        }
//
//        guard
//            let locationsPublisher = self.locationsPublisher,
//            let tournamentsPublisher = self.tournamentsPublisher
//        else {
//            return
//        }
//
//        self.competitionsFilterPublisher?.cancel()
//        self.competitionsFilterPublisher = nil
//
//        self.competitionsFilterPublisher = Publishers.Zip3(popularTournamentsPublisher, tournamentsPublisher, locationsPublisher)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure:
//                    print("Error retrieving data!")
//                case .finished:
//                    print("Data retrieved!")
//                }
//
//                self?.isLoadingCompetitionGroups.send(false)
//
//                self?.competitionsFilterPublisher?.cancel()
//                self?.competitionsFilterPublisher = nil
//
//                if let locationsRegister = self?.locationsRegister {
//                    Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: locationsRegister)
//                }
//
//                if let tournamentsRegister = self?.tournamentsRegister {
//                    Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: tournamentsRegister)
//                }
//
//            }, receiveValue: { [weak self] popularTournaments, tournaments, locations in
//                Env.everyMatrixStorage.storePopularTournaments(tournaments: popularTournaments.records ?? [])
//                Env.everyMatrixStorage.storeTournaments(tournaments: tournaments)
//                Env.everyMatrixStorage.storeLocations(locations: locations)
//
//                self?.setupCompetitionGroups()
//            })
        //
        //
    }

    func fetchCompetitionsMatchesWithIds(_ ids: [String]) {

        let sportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.selectedSport)

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

//        self.competitionsMatchesPublisher = Env.serviceProvider.subscribeCompetitionMatches(forSportType: sportType)
//            .sink(receiveCompletion: { completion in
//                print("Env.serviceProvider.subscribeCompetitionMatches completed \(completion)")
//            }, receiveValue: { (subscribableContent: SubscribableContent<[EventsGroup]>) in
//                print("Env.serviceProvider.subscribeCompetitionMatches value \(subscribableContent)")
//                switch subscribableContent {
//                case .connected:
//                    print("Connected to ws")
//                case .contentUpdate(let eventsGroups):
//                    self.competitions = ServiceProviderModelMapper.competitions(fromEventsGroups: eventsGroups)
//                    self.competitionsDataSource.competitions = ServiceProviderModelMapper.competitions(fromEventsGroups: eventsGroups)
//                    self.filteredOutrightCompetitionsDataSource.outrightCompetitions = ServiceProviderModelMapper.competitions(fromEventsGroups: eventsGroups)
//                    self.isLoadingCompetitionMatches.send(false)
//                    self.updateContentList()
//                case .disconnected:
//                    print("Disconnected from ws")
//                }
//            })

//        self.competitionsDataSource.competitions = []
//        self.competitions = []
//        self.filteredOutrightCompetitionsDataSource.outrightCompetitions = []
        //self.isLoadingCompetitionMatches.send(false)

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
                                         outrightMarkets: Int(competitionInfo.numberOutrightMarkets) ?? 0,
        competitionInfo: competitionInfo)

        self.competitions.append(newCompetition)
        self.competitionsDataSource.competitions = self.competitions
        self.competitionsMatchesSubscriptions.value[competitionInfo.id] = competitionInfo

    }

    private func processCompetitionOutrights(competitionInfo: SportCompetitionInfo) {
        let newCompetition = Competition(id: competitionInfo.id,
                                         name: competitionInfo.name,
                                         matches: [],
                                         outrightMarkets: Int(competitionInfo.numberOutrightMarkets) ?? 0,
        competitionInfo: competitionInfo)

        self.competitions.append(newCompetition)
        self.competitionsDataSource.competitions = self.competitions
        self.competitionsMatchesSubscriptions.value[competitionInfo.id] = competitionInfo
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

    private func setupPopularTournamentsAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processOutrightTournamentsAggregator(aggregator)

        let localOutrightCompetitions = Env.everyMatrixStorage.outrightTournaments.values.map { rawCompetition -> Competition in

            var location: Location?
            if let rawLocation = Env.everyMatrixStorage.location(forId: rawCompetition.venueId ?? "") {
                location = Location(id: rawLocation.id,
                                name: rawLocation.name ?? "",
                                isoCode: rawLocation.code ?? "")
            }

            let competition = Competition(id: rawCompetition.id,
                                               name: rawCompetition.name ?? "",
                                               venue: location,
                                               outrightMarkets: rawCompetition.numberOfOutrightMarkets ?? 0)
            return competition
        }

        self.popularOutrightCompetitions = localOutrightCompetitions

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

//        let shouldShowEventCategory = self.selectedSport.showEventCategory
//
//        var addedCompetitionIds: [String] = []
//
//        var popularCompetitions = [Competition]()
//        for popularCompetition in Env.everyMatrixStorage.popularTournaments.values where (popularCompetition.sportId ?? "") == self.selectedSport.id {
//
//            let competition = Competition(id: popularCompetition.id,
//                                          name: popularCompetition.name ?? "",
//                                          outrightMarkets: popularCompetition.numberOfOutrightMarkets ?? 0)
//            addedCompetitionIds.append(popularCompetition.id)
//            popularCompetitions.append(competition)
//        }
//
//        let popularCompetitionGroup = CompetitionGroup(id: "0",
//                                                       name: localized("popular_competitions"),
//                                                       aggregationType: CompetitionGroup.AggregationType.popular,
//                                                       competitions: popularCompetitions)
//        var popularCompetitionGroups = [popularCompetitionGroup]
//
//        var competitionsGroups = [CompetitionGroup]()
//        for location in Env.everyMatrixStorage.locations.values {
//
//            var locationCompetitions = [Competition]()
//            var tournamentIds = (Env.everyMatrixStorage.tournamentsForLocation[location.id] ?? [])
//
//            if shouldShowEventCategory {
//                tournamentIds = (Env.everyMatrixStorage.tournamentsForCategory[location.id] ?? [])
//            }
//
//            for rawCompetitionId in tournamentIds {
//
//                guard
//                    let rawCompetition = Env.everyMatrixStorage.tournaments[rawCompetitionId],
//                    (rawCompetition.sportId ?? "") == self.selectedSport.id
//                else {
//                    continue
//                }
//
//                let competition = Competition(id: rawCompetition.id,
//                                              name: rawCompetition.name ?? "",
//                                              outrightMarkets: rawCompetition.numberOfOutrightMarkets ?? 0)
//                addedCompetitionIds.append(rawCompetition.id)
//                locationCompetitions.append(competition)
//            }
//
//            let locationCompetitionGroup = CompetitionGroup(id: location.id,
//                                                            name: location.name ?? "",
//                                                            aggregationType: CompetitionGroup.AggregationType.region,
//                                                            competitions: locationCompetitions)
//
//            if locationCompetitions.isNotEmpty {
//                competitionsGroups.append(locationCompetitionGroup)
//            }
//        }
        if self.sportRegionsPublisher.value.isNotEmpty,
           self.regionCompetitionsPublisher.value.isNotEmpty {

            let sportRegions = self.sportRegionsPublisher.value
            let regionCompetitions = self.regionCompetitionsPublisher.value

            var competitionGroups = ServiceProviderModelMapper.competitionGroups(fromSportRegions: sportRegions, withRegionCompetitions: regionCompetitions)

            //popularCompetitionGroups.append(contentsOf: competitionsGroups)

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
                                              outrightMarkets: rawCompetition.numberOfOutrightMarkets ?? 0)
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
                                              outrightMarkets: rawCompetition.numberOfOutrightMarkets ?? 0)
                outrightCompetitions.append(competition)
            }
        }

        return outrightCompetitions
    }

    private func setupCompetitionsAggregatorProcessor(aggregator: EveryMatrix.Aggregator, withCompetitionsIds ids: [String]) {
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
            if let rawCompetition = Env.everyMatrixStorage.tournaments[competitionId] {

                var location: Location?
                if let rawLocation = Env.everyMatrixStorage.location(forId: rawCompetition.venueId ?? "") {
                    location = Location(id: rawLocation.id,
                                    name: rawLocation.name ?? "",
                                    isoCode: rawLocation.code ?? "")
                }

                let competition = Competition(id: competitionId,
                                              name: rawCompetition.name ?? "",
                                              matches: (competitionsMatches[competitionId] ?? []),
                                              venue: location,
                                              outrightMarkets: rawCompetition.numberOfOutrightMarkets ?? 0)
                processedCompetitions.append(competition)
            }
        }

        self.competitions = processedCompetitions

        self.filteredOutrightCompetitionsDataSource.outrightCompetitions = self.outrightCompetitions(forIds: ids)

        self.isLoadingCompetitionMatches.send(false)

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
            if let rawCompetition = Env.everyMatrixStorage.tournaments[competitionId], let tournamentSportTypeId = rawCompetition.sportId {

                if tournamentSportTypeId == self.selectedSport.id {

                    var location: Location?
                    if let rawLocation = Env.everyMatrixStorage.location(forId: rawCompetition.venueId ?? "") {
                        location = Location(id: rawLocation.id,
                                        name: rawLocation.name ?? "",
                                        isoCode: rawLocation.code ?? "")
                    }

                    let competition = Competition(id: competitionId,
                                                  name: rawCompetition.name ?? "",
                                                  matches: (competitionsMatches[competitionId] ?? []),
                                                  venue: location,
                                                  outrightMarkets: rawCompetition.numberOfOutrightMarkets ?? 0)
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
