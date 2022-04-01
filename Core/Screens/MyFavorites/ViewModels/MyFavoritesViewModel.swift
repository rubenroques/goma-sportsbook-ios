//
//  MyFavoritesViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 10/02/2022.
//

import Foundation
import Combine
import OrderedCollections

class MyFavoritesViewModel: NSObject {

    private var favoriteMatches: [Match] = []
    private var favoriteCompetitions: [Competition] = []

    private var favoriteMatchesRegister: EndpointPublisherIdentifiable?
    private var favoriteCompetitionsMatchesRegister: EndpointPublisherIdentifiable?
    private var favoriteMatchesPublisher: AnyCancellable?
    private var favoriteCompetitionsMatchesPublisher: AnyCancellable?

    private var cancellables = Set<AnyCancellable>()
    var dataChangedPublisher = PassthroughSubject<Void, Never>.init()
    var didSelectMatchAction: ((Match) -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var didTapFavoriteCompetitionAction: ((Competition) -> Void)?
    var favoriteListTypePublisher: CurrentValueSubject<FavoriteListType, Never> = .init(.favoriteGames)

    var emptyStateStatusPublisher: CurrentValueSubject<EmptyStateType, Never> = .init(.none)

    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    private var favoriteEventsIds: [String] = []

    enum FavoriteListType {
        case favoriteGames
        case favoriteCompetitions
    }

    // Caches
    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    // Data Sources
    var myFavoriteMatchesDataSourcePublisher: CurrentValueSubject<MyFavoriteMatchesDataSource, Never> =
        .init(MyFavoriteMatchesDataSource(userFavoriteMatches: [], store: FavoritesAggregatorsRepository()))
    var myFavoriteCompetitionsDataSourcePublisher: CurrentValueSubject<MyFavoriteCompetitionsDataSource, Never> =
        .init(MyFavoriteCompetitionsDataSource(favoriteCompetitions: [], store: FavoritesAggregatorsRepository()))

    var store: FavoritesAggregatorsRepository = FavoritesAggregatorsRepository()

    override init() {
        super.init()

        self.store.getLocations()

        self.myFavoriteMatchesDataSourcePublisher.value.store = self.store

        self.myFavoriteCompetitionsDataSourcePublisher.value.store = self.store

        self.myFavoriteMatchesDataSourcePublisher.value.matchStatsViewModelForMatch = { [weak self] match in
            return self?.matchStatsViewModel(forMatch: match)
        }

        self.myFavoriteCompetitionsDataSourcePublisher.value.matchStatsViewModelForMatch = { [weak self] match in
            return self?.matchStatsViewModel(forMatch: match)
        }

        // Match Select
        self.myFavoriteMatchesDataSourcePublisher.value.didSelectMatchAction = { [weak self] match in
            self?.didSelectMatchAction?(match)
        }
        self.myFavoriteCompetitionsDataSourcePublisher.value.didSelectMatchAction = { [weak self] match in
            self?.didSelectMatchAction?(match)
        }

        // Match went live
        self.myFavoriteMatchesDataSourcePublisher.value.matchWentLiveAction = { [weak self] in
            self?.dataChangedPublisher.send()
        }
        self.myFavoriteCompetitionsDataSourcePublisher.value.matchWentLiveAction = { [weak self] in
            self?.dataChangedPublisher.send()
        }

        self.myFavoriteMatchesDataSourcePublisher.value.didTapFavoriteMatchAction = { [weak self] match in
            self?.didTapFavoriteMatchAction?(match)
        }
        
        self.myFavoriteCompetitionsDataSourcePublisher.value.didTapFavoriteCompetitionAction = { [weak self] competition in
            self?.didTapFavoriteCompetitionAction?(competition)
        }

        self.myFavoriteCompetitionsDataSourcePublisher.value.didTapFavoriteMatchAction = { [weak self] match in
            self?.didTapFavoriteMatchAction?(match)
        }

        self.setupPublishers()

    }

    deinit {
        print("VM DEINIT")
        self.unregisterEndpoints()
    }
    
    func unregisterEndpoints() {

        if let favoriteMatchesRegister = self.favoriteMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: favoriteMatchesRegister)
        }

        self.favoriteMatchesPublisher?.cancel()
        self.favoriteMatchesPublisher = nil

        if let favoriteCompetitionsMatchesRegister = self.favoriteCompetitionsMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: favoriteCompetitionsMatchesRegister)
        }

        self.favoriteCompetitionsMatchesPublisher?.cancel()
        self.favoriteCompetitionsMatchesPublisher = nil

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

    func setFavoriteListType(_ favoriteListType: FavoriteListType) {
        self.favoriteListTypePublisher.send(favoriteListType)
        self.updateContentList()
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
    
    func markCompetitionAsFavorite(competition: Competition) {
        
        var isFavorite = false
        for competitionId in Env.favoritesManager.favoriteEventsIdPublisher.value where competitionId == competition.id {
            isFavorite = true
        }
        
        if isFavorite {
            Env.favoritesManager.removeFavorite(eventId: competition.id, favoriteType: .competition)
        }
        else {
            Env.favoritesManager.addFavorite(eventId: competition.id, favoriteType: .competition)
        }
   
    }
    
    private func setupPublishers() {

        Env.favoritesManager.favoriteEventsIdPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] favoriteEvents in
                if UserSessionStore.isUserLogged() {
                    self?.isLoadingPublisher.send(true)
                    self?.favoriteEventsIds = favoriteEvents
                    self?.fetchFavoriteMatches()

                }
                else {
                    self?.dataChangedPublisher.send()
                    self?.emptyStateStatusPublisher.send(.noLogin)
                }
            })
            .store(in: &cancellables)
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
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    print("Error retrieving Favorite data!")
                    self?.dataChangedPublisher.send()
                case .finished:
                    print("Favorite Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("MyFavoritesViewModel favoriteMatchesPublisher connect")
                    self?.favoriteMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("MyFavoritesViewModel favoriteMatchesPublisher initialContent")
                    self?.setupFavoriteMatchesAggregatorProcessor(aggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    print("MyFavoritesViewModel favoriteMatchesPublisher updatedContent")
                    self?.updateFavoriteMatchesAggregatorProcessor(aggregator: aggregatorUpdates)
                case .disconnect:
                    print("MyFavoritesViewModel favoriteMatchesPublisher disconnect")
                }

            })
    }

    private func setupFavoriteMatchesAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {

        self.store.processAggregator(aggregator, withListType: .favoriteMatchEvents, shouldClear: true)

        self.favoriteMatches = self.store.matchesForListType(.favoriteMatchEvents)

        if self.favoriteEventsIds.isNotEmpty {
            self.fetchFavoriteCompetitionsMatchesWithIds(self.favoriteEventsIds)
        }
        else {
            self.favoriteMatches = []
            self.favoriteCompetitions = []
            self.updateContentList()
        }
    }

    private func updateFavoriteMatchesAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {

        self.store.processContentUpdateAggregator(aggregator)

    }

    func fetchFavoriteCompetitionsMatchesWithIds(_ ids: [String]) {

        if let favoriteCompetitionsMatchesRegister = favoriteCompetitionsMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: favoriteCompetitionsMatchesRegister)
        }

        let endpoint = TSRouter.competitionsMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                             language: "en", sportId: "",
                                                             events: ids)

        self.favoriteCompetitionsMatchesPublisher?.cancel()
        self.favoriteCompetitionsMatchesPublisher = nil

        self.favoriteCompetitionsMatchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                    self?.dataChangedPublisher.send()
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("MyFavoritesViewModel favoriteCompetitionsMatchesPublisher connect")
                    self?.favoriteCompetitionsMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("MyFavoritesViewModel favoriteCompetitionsMatchesPublisher initialContent")
                    self?.setupFavoriteCompetitionsAggregatorProcessor(aggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    self?.updateFavoriteCompetitionsAggregatorProcessor(aggregator: aggregatorUpdates)
                    print("MyFavoritesViewModel favoriteCompetitionsMatchesPublisher updatedContent")
                case .disconnect:
                    print("MyFavoritesViewModel favoriteCompetitionsMatchesPublisher disconnect")
                }
            })
    }

    private func setupFavoriteCompetitionsAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {

        self.store.processAggregator(aggregator, withListType: .favoriteCompetitionEvents, shouldClear: true)

        var appMatches = self.store.matchesForListType(.favoriteCompetitionEvents)

        // Sort competitions by sport type
        appMatches.sort {
            $0.sportType < $1.sportType
        }

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
            if let rawCompetition = self.store.tournaments[competitionId] {

                var location: Location?
                if let rawLocation = self.store.location(forId: rawCompetition.venueId ?? "") {
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

        self.favoriteCompetitions = processedCompetitions

        self.updateContentList()
    }

    private func updateFavoriteCompetitionsAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        
        self.store.processContentUpdateAggregator(aggregator)

    }

    private func updateContentList() {

        self.myFavoriteMatchesDataSourcePublisher.value.setupMatchesBySport(favoriteMatches: self.favoriteMatches)

        self.myFavoriteCompetitionsDataSourcePublisher.value.competitions = self.favoriteCompetitions

        if UserSessionStore.isUserLogged() {
            if self.favoriteMatches.isEmpty && self.favoriteCompetitions.isEmpty {
                self.emptyStateStatusPublisher.send(.noFavorites)
            }
            else if self.favoriteMatches.isNotEmpty && self.favoriteCompetitions.isNotEmpty {
                self.emptyStateStatusPublisher.send(.none)
            }
            else {
                if self.favoriteMatches.isEmpty {
                    self.emptyStateStatusPublisher.send(.noGames)
                }
                else if self.favoriteCompetitions.isEmpty {
                    self.emptyStateStatusPublisher.send(.noCompetitions)
                }
            }

        }
        else {
            self.emptyStateStatusPublisher.send(.noLogin)
        }
        self.isLoadingPublisher.send(false)
        self.dataChangedPublisher.send()

    }
}
