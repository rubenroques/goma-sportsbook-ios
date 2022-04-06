//
//  PopularDetailsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 14/03/2022.
//

import Foundation
import Combine

class PopularDetailsViewModel {

    var store: AggregatorsRepository

    var refreshPublisher = PassthroughSubject<Void, Never>.init()

    var isLoading: CurrentValueSubject<Bool, Never> = .init(true)

    var titlePublisher: CurrentValueSubject<String, Never>

    private var matchesPublisher: AnyCancellable?
    private var matchesRegister: EndpointPublisherIdentifiable?

    private var outrightCompetitionsPublisher: AnyCancellable?
    private var outrightCompetitionsRegister: EndpointPublisherIdentifiable?

    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    private var sport: Sport
    private var matches: [Match] = []
    private var outrightCompetitions: [Competition]?

    private var matchesCount = 10
    private var matchesPage = 1
    private var matchesHasNextPage = true

    private var cancellables: Set<AnyCancellable> = []

    init(sport: Sport, store: AggregatorsRepository) {
        self.store = store
        self.sport = sport

        self.titlePublisher = .init(self.sport.name)

        self.refresh()
    }

    func refresh() {
        self.resetPageCount()

        self.isLoading.send(true)

        self.fetchLocations()
            .sink { [weak self] locations in
                self?.store.storeLocations(locations: locations)
                self?.fetchMatches()
            }
            .store(in: &cancellables)
    }

    func fetchLocations() -> AnyPublisher<[EveryMatrix.Location], Never> {

        let router = TSRouter.getLocations(language: "en", sortByPopularity: false)
        return Env.everyMatrixClient.manager.getModel(router: router, decodingType: EveryMatrixSocketResponse<EveryMatrix.Location>.self)
            .map(\.records)
            .compactMap({$0})
            .replaceError(with: [EveryMatrix.Location]())
            .eraseToAnyPublisher()

    }

    func requestNextPage() {
        self.fetchNextPage()
    }

    private func resetPageCount() {
        self.matchesCount = 10
        self.matchesPage = 1
        self.matchesHasNextPage = true
    }

    private func fetchNextPage() {
        if !matchesHasNextPage {
            return
        }
        self.matchesPage += 1
        self.fetchMatches()
    }

    private func fetchMatches() {

        if let matchesRegister = matchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: matchesRegister)
        }

        let matchesCount = self.matchesCount * self.matchesPage

        let endpoint = TSRouter.popularMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                        language: "en",
                                                        sportId: self.sport.id,
                                                        matchesCount: matchesCount)
        self.matchesPublisher?.cancel()
        self.matchesPublisher = nil

        self.matchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    print("matchesPublisher Error retrieving data!")
                case .finished:
                    print("matchesPublisher Data retrieved!")
                }
                self?.isLoading.send(false)
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    self?.matchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    self?.storeAggregatorProcessor(aggregator)
                case .updatedContent(let aggregatorUpdates):
                    self?.updateWithAggregatorProcessor(aggregatorUpdates)
                case .disconnect:
                    ()
                }
            })
    }

    private func closeOutrightCompetitionsConnection() {
        if let outrightCompetitionsRegister = outrightCompetitionsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: outrightCompetitionsRegister)
        }

        self.outrightCompetitionsPublisher?.cancel()
        self.outrightCompetitionsPublisher = nil
    }

    private func fetchOutrightCompetitions() {

        if let outrightCompetitionsRegister = outrightCompetitionsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: outrightCompetitionsRegister)
        }

        let sportId = self.sport.id

        let endpoint = TSRouter.popularTournamentsPublisher(operatorId: Env.appSession.operatorId,
                                                        language: "en",
                                                        sportId: sportId,
                                                        tournamentsCount: 20)
        self.outrightCompetitionsPublisher?.cancel()
        self.outrightCompetitionsPublisher = nil

        self.outrightCompetitionsPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    print("outrightCompetitionsPublisher Error retrieving data!")
                case .finished:
                    print("outrightCompetitionsPublisher Data retrieved!")
                }
                self?.isLoading.send(false)
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    self?.outrightCompetitionsRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    self?.storeOutrightCompetitionsAggregatorProcessor(aggregator: aggregator)
                case .updatedContent: // (let aggregatorUpdates):
                    ()
                case .disconnect:
                    ()
                }
            })
    }

    private func storeAggregatorProcessor(_ aggregator: EveryMatrix.Aggregator) {
        self.store.processAggregator(aggregator, withListType: .popularEvents,
                                                 shouldClear: true)

        let matches = self.store.matchesForListType(.popularEvents)
        if matches.count < self.matchesCount * self.matchesPage {
            self.matchesHasNextPage = false
        }

        if matches.isNotEmpty {
            self.matches = matches

            self.titlePublisher.send("\(self.sport.name) - Popular Matches")
            
            self.isLoading.send(false)
            self.refreshPublisher.send()
        }
        else {
            self.fetchOutrightCompetitions()
        }
    }

    private func updateWithAggregatorProcessor(_ aggregator: EveryMatrix.Aggregator) {
        self.store.processContentUpdateAggregator(aggregator)
    }

    private func storeOutrightCompetitionsAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        self.store.processOutrightTournamentsAggregator(aggregator)

        let localOutrightCompetitions = self.store.outrightTournaments.values.map { rawCompetition -> Competition in

            var location: Location?
            if let rawLocation = self.store.location(forId: rawCompetition.venueId ?? "") {
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

        self.titlePublisher.send("\(self.sport.name) - Markets")

        self.outrightCompetitions = localOutrightCompetitions
        self.isLoading.send(false)
        self.refreshPublisher.send()

        self.closeOutrightCompetitionsConnection()
    }

}

extension PopularDetailsViewModel {

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

    func isMatchLive(withMatchId matchId: String) -> Bool {
        return self.store.hasMatchesInfoForMatch(withId: matchId)
    }

}

extension PopularDetailsViewModel {

    func shouldShowLoadingCell() -> Bool {
        return self.matches.isNotEmpty && matchesHasNextPage
    }

    func numberOfSection() -> Int {
        return 3
    }

    func numberOfItems(forSection section: Int) -> Int {
        switch section {
        case 0:
            return self.matches.count
        case 1:
            return self.outrightCompetitions?.count ?? 0
        case 2:
            return self.shouldShowLoadingCell() ? 1 : 0
        default:
            return 0
        }
    }

    func match(forRow row: Int) -> Match? {
        return self.matches[safe: row]
    }

    func outrightCompetition(forRow row: Int) -> Competition? {
        return self.outrightCompetitions?[safe: row]
    }

    func outrightCompetition(forIndexPath indexPath: IndexPath) -> Match? {
        return self.matches[safe: indexPath.row]
    }

}
