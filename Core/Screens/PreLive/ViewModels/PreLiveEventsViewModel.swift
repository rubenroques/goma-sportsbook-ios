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
    enum MatchListType: String, Equatable {
        case popular
        case upcoming
        case competitions
    }

    var screenStatePublisher: CurrentValueSubject<ScreenState, Never> = .init(.noEmptyNoFilter)
    enum ScreenState: String, Equatable {
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
                if self.matchListTypePublisher.value != .competitions {
                    self.resetScrollPositionAction?()
                }
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

    private var popularMatchesDataSource = PopularMatchesDataSource()
    private var todayMatchesDataSource = TodayMatchesDataSource()
    private var competitionsDataSource = CompetitionsDataSource()

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

    private var popularSubscription: ServicesProvider.Subscription?
    private var todaySubscription: ServicesProvider.Subscription?
    private var competitionsSubscription: ServicesProvider.Subscription?

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
                    self?.processCompetitionsInfo()
                }
            })
            .store(in: &cancellables)

        self.competitionsMatchesSubscriptions
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] competitionMatchesSubscriptions in

                if competitionMatchesSubscriptions.count == self?.expectedCompetitionsPublisher.value {

                    self?.isLoadingCompetitionMatches.send(false)
                    self?.isLoadingEvents.send(false)
                    self?.updateContentList()
                }
            })
            .store(in: &cancellables)
    }

    func fetchData() {

        if didChangeSport {
            self.clearOldSportData()
            self.didChangeSport = false
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

    private func clearOldSportData() {
        self.competitions = []
        self.competitionsDataSource.competitions = []

        self.lastCompetitionsMatchesRequested = []

        self.popularMatchesDataSource.outrightCompetitions = nil
        self.popularOutrightCompetitions = nil
        self.popularMatches = []

        self.todayMatchesDataSource.todayMatches = []
        self.todayMatches = []
        self.todayOutrightCompetitions = nil
        self.todayMatchesDataSource.outrightCompetitions = nil

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
            self.fetchPopularMatches()
        case .upcoming:
            self.fetchTodayMatches()
        case .competitions:
            self.fetchCompetitionsFilters()
            if let matches = self.competitionsDataSource.competitions.first?.matches {
                self.setMainMarkets(matches: matches)
            }
        }
    }

    private func updateContentList() {

        self.popularMatchesDataSource.matches = filterPopularMatches(with: self.homeFilterOptions, matches: self.popularMatches)

        self.popularMatchesDataSource.outrightCompetitions = self.popularOutrightCompetitions

        //
        self.todayMatchesDataSource.todayMatches = filterTodayMatches(with: self.homeFilterOptions, matches: self.todayMatches)

        self.todayMatchesDataSource.outrightCompetitions = self.todayOutrightCompetitions

        //
        self.competitionsDataSource.competitions = filterCompetitionMatches(with: self.homeFilterOptions, competitions: self.competitions)

        //
        //
        let numberOfFilters = self.homeFilterOptions?.countFilters ?? 0
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
    // MARK: - Fetches
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

        // self.isLoadingPopularList.send(true)
        self.isLoadingEvents.send(true)

        let sportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.selectedSport)

        self.popularMatchesPublisher?.cancel()
        self.popularMatchesPublisher = Env.servicesProvider.subscribePreLiveMatches(forSportType: sportType, sortType: .popular)
            .sink(receiveCompletion: { [weak self] completion in
                print("Prelive subscribePopularMatches completed \(completion)")
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("Prelive subscribePopularMatches error: \(error)")
                    self?.popularMatches = []
                    self?.isLoadingPopularList.send(false)
                    self?.isLoadingEvents.send(false)
                    self?.updateContentList()
                }
            }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
                switch subscribableContent {
                case .connected(let subscription):
                    self?.popularSubscription = subscription
                case .contentUpdate(let eventsGroups):
                    guard let self = self else { return }
                    let splittedEventGroups = self.splitEventsGroups(eventsGroups)

                    self.popularOutrightCompetitions = ServiceProviderModelMapper.competitions(fromEventsGroups: splittedEventGroups.competitionsEventGroups)

                    let popularMatches = ServiceProviderModelMapper.matches(fromEventsGroups: splittedEventGroups.matchesEventGroups)
                    self.popularMatches = popularMatches
                    self.setMainMarkets(matches: popularMatches)

                    self.updateContentList()
                    self.isLoadingPopularList.send(false)
                    self.isLoadingEvents.send(false)
                case .disconnected:
                    self?.popularMatches = []
                    self?.updateContentList()
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

        self.isLoadingEvents.send(true)

        let selectedSportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.selectedSport)
        let datesFilter = Env.servicesProvider.getDatesFilter(timeRange: timeRange)

        self.todayMatchesPublisher?.cancel()
        self.todayMatchesPublisher = Env.servicesProvider.subscribePreLiveMatches(forSportType: selectedSportType,
                                                                                  initialDate: datesFilter[safe: 0],
                                                                                  endDate: datesFilter[safe: 1],
                                                                                  sortType: .date)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    self?.todayMatches = []
                    self?.isLoadingTodayList.send(false)
                    self?.isLoadingEvents.send(false)
                    self?.updateContentList()
                }
            }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
                switch subscribableContent {
                case .connected(let subscription):
                    self?.todaySubscription = subscription
                case .contentUpdate(let eventsGroups):

                    guard let self = self else { return }

                    let splittedEventGroups = self.splitEventsGroups(eventsGroups)
                    self.todayOutrightCompetitions = ServiceProviderModelMapper.competitions(fromEventsGroups: splittedEventGroups.competitionsEventGroups)

                    let todayMatches = ServiceProviderModelMapper.matches(fromEventsGroups: splittedEventGroups.matchesEventGroups)
                    self.todayMatches = todayMatches
                    self.setMainMarkets(matches: todayMatches)

                    //
                    self.updateContentList()
                    self.isLoadingTodayList.send(false)
                    self.isLoadingEvents.send(false)
                case .disconnected:
                    self?.todayMatches = []
                    self?.updateContentList()
                }
            })
    }

    private func processCompetitionsInfo() {

        let competitionInfos = self.selectedCompetitionsInfoPublisher.value.map({ $0.value })

        self.competitions = []
        self.competitionsDataSource.competitions = []

        // TODO: André, esta é a unica forma de fazer isto? parece demasiado hardcoded
        for competitionInfo in competitionInfos {
            if let marketGroup = competitionInfo.marketGroups.filter({ $0.name == "Main" }).first {
                self.subscribeCompetitionMatches(forMarketGroupId: marketGroup.id, competitionInfo: competitionInfo)
            }
            else {
                if let marketGroup = competitionInfo.marketGroups.filter({
                    $0.name == "Outright"
                }).first {
                    self.subscribeCompetitionOutright(forMarketGroupId: marketGroup.id, competitionInfo: competitionInfo)
                    //self.processCompetitionOutrights(competitionInfo: competitionInfo)
                }
            }
        }
    }

    private func splitEventsGroups(_ eventsGroups: [EventsGroup]) -> (matchesEventGroups: [EventsGroup], competitionsEventGroups: [EventsGroup]) {

        var matchEventsGroups: [EventsGroup] = []
        for eventGroup in eventsGroups {
            let matchEvents = eventGroup.events.filter { event in
                event.type == .match
            }
            matchEventsGroups.append(EventsGroup(events: matchEvents))
        }

        //
        var competitionEventsGroups: [EventsGroup] = []
        for eventGroup in eventsGroups {
            let competitionEvents = eventGroup.events.filter { event in
                event.type == .competition
            }
            competitionEventsGroups.append(EventsGroup(events: competitionEvents))
        }

        return (matchEventsGroups, competitionEventsGroups)
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

    func fetchCompetitionsFilters() {

        self.isLoadingCompetitionGroups.send(false)
        self.isLoadingEvents.send(false)
        self.updateContentList()

        guard let sportNumericId = self.selectedSport.numericId else {
            // Thats an incompleted Sport without numericId
            self.sportRegionsPublisher.send([])
            self.competitionGroupsPublisher.send([])
            return
        }

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
                ()
            }
        } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
            switch subscribableContent {
            case .connected(let subscription):
                self?.competitionsSubscription = subscription
            case .contentUpdate(let eventsGroups):
                let matches = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups)
                self?.processCompetitionMatches(matches: matches, competitionInfo: competitionInfo)
            case .disconnected:
                self?.updateContentList()
            }
        }
        .store(in: &cancellables)
    }

    private func processCompetitionMatches(matches: [Match], competitionInfo: SportCompetitionInfo) {

        let newCompetition = Competition(id: competitionInfo.id,
                                         name: competitionInfo.name,
                                         matches: matches,
                                         venue: matches.first?.venue, numberOutrightMarkets: Int(competitionInfo.numberOutrightMarkets) ?? 0,
                                         competitionInfo: competitionInfo)

        self.setMainMarkets(matches: matches)
        self.competitions.append(newCompetition)
        self.competitionsDataSource.competitions = self.competitions
        self.competitionsMatchesSubscriptions.value[competitionInfo.id] = competitionInfo

    }

    func subscribeCompetitionOutright(forMarketGroupId marketGroupId: String, competitionInfo: SportCompetitionInfo) {

        Env.servicesProvider.subscribeCompetitionMatches(forMarketGroupId: marketGroupId)
        .sink {  [weak self] (completion: Subscribers.Completion<ServiceProviderError>) in
            switch completion {
            case .finished:
                ()
            case .failure:
                ()
            }
        } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
            switch subscribableContent {
            case .connected(let subscription):
                self?.competitionsSubscription = subscription
            case .contentUpdate(let eventsGroups):
                if let outrightMatch = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups).first {
                    self?.processCompetitionOutrights(outrightMatch: outrightMatch, competitionInfo: competitionInfo)
                }
            case .disconnected:
                self?.updateContentList()
            }
        }
        .store(in: &cancellables)
    }

    private func processCompetitionOutrights(outrightMatch: Match, competitionInfo: SportCompetitionInfo) {

        let numberOutrightMarkets = competitionInfo.numberOutrightMarkets == "0" ? 1 : Int(competitionInfo.numberOutrightMarkets) ?? 0

        let newCompetition = Competition(id: competitionInfo.id,
                                         name: competitionInfo.name,
                                         matches: [],
                                         venue: outrightMatch.venue,
                                         numberOutrightMarkets: numberOutrightMarkets,
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

            let competitionGroups = ServiceProviderModelMapper.competitionGroups(fromSportRegions: sportRegions, withRegionCompetitions: regionCompetitions)
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

extension PreLiveEventsViewModel {

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

}

extension PreLiveEventsViewModel: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.matchListTypePublisher.value {
        case .popular:
            return self.popularMatchesDataSource.numberOfSections(in: tableView)
        case .upcoming:
            return self.todayMatchesDataSource.numberOfSections(in: tableView)
        case .competitions:
            return self.competitionsDataSource.numberOfSections(in: tableView)
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
            return self.competitionsDataSource.competitions.isNotEmpty
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.matchListTypePublisher.value {
        case .popular:
            return self.popularMatchesDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .upcoming:
            return self.todayMatchesDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .competitions:
            return self.competitionsDataSource.tableView(tableView, numberOfRowsInSection: section)
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
            cell = self.competitionsDataSource.tableView(tableView, cellForRowAt: indexPath)
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
            return self.competitionsDataSource.tableView(tableView, viewForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .popular:
            return self.popularMatchesDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .upcoming:
            return self.todayMatchesDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .competitions:
            return self.competitionsDataSource.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .popular:
            return self.popularMatchesDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .upcoming:
            return self.todayMatchesDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .competitions:
            return self.competitionsDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .popular:
            return self.popularMatchesDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .upcoming:
            return self.todayMatchesDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .competitions:
            return self.competitionsDataSource.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .popular:
            return self.popularMatchesDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .upcoming:
            return self.todayMatchesDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
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
