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

    // MARK: Private Properties
    private var favoriteMatchesRegister: EndpointPublisherIdentifiable?
    private var favoriteCompetitionsMatchesRegister: EndpointPublisherIdentifiable?

    private var favoriteMatchesPublisher: AnyCancellable?
    private var favoriteCompetitionsMatchesPublisher: AnyCancellable?

    private var favoriteEventsIds: [String] = []

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var favoriteMatchesDataPublisher: CurrentValueSubject<[Match], Never> = .init([])
    var favoriteCompetitionsDataPublisher: CurrentValueSubject<[Competition], Never> = .init([])
    var favoriteOutrightCompetitionsDataPublisher: CurrentValueSubject<[Competition], Never> = .init([])

    var dataChangedPublisher = PassthroughSubject<Void, Never>.init()
    var favoriteListTypePublisher: CurrentValueSubject<FavoriteListType, Never> = .init(.favoriteGames)
    var emptyStateStatusPublisher: CurrentValueSubject<EmptyStateType, Never> = .init(.none)
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    var initialLoading: Bool = true

    enum FavoriteListType {
        case favoriteGames
        case favoriteCompetitions
    }

    // MARK: Caches
    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    // MARK: Store
    var store: FavoritesAggregatorsRepository = FavoritesAggregatorsRepository()

    // MARK: Lifetime and Cycle
    override init() {
        super.init()

        self.initialSetup()

    }

    deinit {
        print("VM DEINIT")
        self.unregisterEndpoints()
    }

    // MARK: Functions
    private func initialSetup() {

        self.getLocations()

        Env.favoritesManager.getUserFavorites()
    }
    
    private func unregisterEndpoints() {

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

    private func getLocations() {
        self.isLoadingPublisher.send(true)

        let resolvedRoute = TSRouter.getLocations(language: "en", sortByPopularity: false)
        Env.everyMatrixClient.manager.getModel(router: resolvedRoute, decodingType: EveryMatrixSocketResponse<EveryMatrix.Location>.self)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("LOCATIONS ERROR: \(error)")
                    self?.isLoadingPublisher.send(false)
                case .finished:
                    ()
                }
            },
                  receiveValue: { [weak self] response in

                (response.records ?? []).forEach { location in

                    self?.store.locations[location.id] = location
                }

                self?.setupPublishers()

            })
            .store(in: &cancellables)
    }
    
    private func setupPublishers() {

        Env.favoritesManager.favoriteEventsIdPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] favoriteEvents in
                if UserSessionStore.isUserLogged() {
                    if self?.initialLoading == true {
                     self?.isLoadingPublisher.send(true)
                        self?.initialLoading = false
                    }
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

        self.favoriteMatchesDataPublisher.value = self.store.matchesForListType(.favoriteMatchEvents)

        if self.favoriteEventsIds.isNotEmpty {
            self.fetchFavoriteCompetitionsWithIds(self.favoriteEventsIds)
            
        }
        else {
            self.favoriteMatchesDataPublisher.value = []
            self.favoriteCompetitionsDataPublisher.value = []
            self.updateContentList()
        }
    }

    private func updateFavoriteMatchesAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {

        self.store.processContentUpdateAggregator(aggregator)

    }

    func fetchFavoriteCompetitionsWithIds(_ ids: [String]) {

        if let favoriteCompetitionsMatchesRegister = favoriteCompetitionsMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: favoriteCompetitionsMatchesRegister)
        }

        let endpoint = TSRouter.eventsDetails(operatorId: Env.appSession.operatorId,
                                                             language: "en",
                                                             events: ids)

        self.favoriteCompetitionsMatchesPublisher?.cancel()
        self.favoriteCompetitionsMatchesPublisher = nil

        // "157127366340038656", "168574328789585920", "157127226495651840", "174076994548453376"
        
        self.favoriteCompetitionsMatchesPublisher = Env.everyMatrixClient.manager.getModel(router: endpoint,
                                                                                           decodingType: EveryMatrix.Aggregator.self )
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("Error retrieving data eventsDetails! \(error)")
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: { [weak self] response in
                self?.setupFavoriteCompetitionsAggregatorProcessor(aggregator: response )
            })
    }
    
    func setupFavoriteCompetitionsAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        
        self.fetchFavoriteCompetitionsMatchesWithIds(self.favoriteEventsIds)
        
        self.store.processAggregator(aggregator, withListType: .favoriteOutrightCompetitions, shouldClear: true)

        let outrightCompetitionsIds = self.favoriteEventsIds
        
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
        for competitionId in outrightCompetitionsIds {
            if let rawCompetition = self.store.tournaments[competitionId] {
                
                if rawCompetition.numberOfOutrightMarkets ?? 0 == 0 {
                    continue
                }
                
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
                                              numberOutrightMarkets: rawCompetition.numberOfOutrightMarkets ?? 0)
                processedCompetitions.append(competition)
            }
        }
        
        self.favoriteOutrightCompetitionsDataPublisher.value = processedCompetitions
        self.updateContentList()
        
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
                    self?.setupFavoriteCompetitionsMatchesAggregatorProcessor(aggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    self?.updateFavoriteCompetitionsAggregatorProcessor(aggregator: aggregatorUpdates)
                    print("MyFavoritesViewModel favoriteCompetitionsMatchesPublisher updatedContent")
                case .disconnect:
                    print("MyFavoritesViewModel favoriteCompetitionsMatchesPublisher disconnect")
                }
            })
    }

    private func setupFavoriteCompetitionsMatchesAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {

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
                                              numberOutrightMarkets: rawCompetition.numberOfOutrightMarkets ?? 0)
                processedCompetitions.append(competition)

            }
        }

        self.favoriteCompetitionsDataPublisher.value = processedCompetitions

        self.updateContentList()
    }

    private func updateFavoriteCompetitionsAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        
        self.store.processContentUpdateAggregator(aggregator)

    }

    private func updateContentList() {

        if UserSessionStore.isUserLogged() {
            if self.favoriteMatchesDataPublisher.value.isEmpty &&
                self.favoriteCompetitionsDataPublisher.value.isEmpty &&
                self.favoriteOutrightCompetitionsDataPublisher.value.isEmpty {
                
                self.emptyStateStatusPublisher.send(.noFavorites)
            }
            else if self.favoriteMatchesDataPublisher.value.isNotEmpty && self.favoriteCompetitionsDataPublisher.value.isNotEmpty {
                self.emptyStateStatusPublisher.send(.none)
            }
            else {
                if self.favoriteMatchesDataPublisher.value.isEmpty {
                    self.emptyStateStatusPublisher.send(.noGames)
                }
                else if self.favoriteCompetitionsDataPublisher.value.isEmpty &&
                            self.favoriteOutrightCompetitionsDataPublisher.value.isEmpty {
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
