//
//  LiveDetailsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 17/03/2022.
//

import Foundation
import Combine
import ServiceProvider

class LiveDetailsViewModel {

    var store: AggregatorsRepository

    var refreshPublisher = PassthroughSubject<Void, Never>.init()
    var isLoading: CurrentValueSubject<Bool, Never> = .init(true)
    var titlePublisher: CurrentValueSubject<String, Never>

    private var matchesPublisher: AnyCancellable?
    private var matchesRegister: EndpointPublisherIdentifiable?

    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    private var sport: Sport
    private var matches: [Match] = []

    private var matchesCount = 10
    private var matchesPage = 1
    private var matchesHasNextPage = true

    private var cancellables: Set<AnyCancellable> = []

    init(sport: Sport, store: AggregatorsRepository) {
        self.store = store
        self.sport = sport

        self.titlePublisher = .init("\(self.sport.name) - Live Matches")

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

        let endpoint = TSRouter.liveMatchesPublisher(operatorId: Env.appSession.operatorId,
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
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
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

    private func storeAggregatorProcessor(_ aggregator: EveryMatrix.Aggregator) {
        self.store.processAggregator(aggregator, withListType: .popularEvents,
                                                 shouldClear: true)

        let matches = self.store.matchesForListType(.popularEvents)
        if matches.count < self.matchesCount * self.matchesPage {
            self.matchesHasNextPage = false
        }

        self.matches = matches

        self.isLoading.send(false)

        self.refreshPublisher.send()
    }

    private func updateWithAggregatorProcessor(_ aggregator: EveryMatrix.Aggregator) {
        self.store.processContentUpdateAggregator(aggregator)
    }

}

extension LiveDetailsViewModel {

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

extension LiveDetailsViewModel {

    func shouldShowLoadingCell() -> Bool {
        return self.matches.isNotEmpty && matchesHasNextPage
    }

    func numberOfSection() -> Int {
        return 2
    }

    func numberOfItems(forSection section: Int) -> Int {
        switch section {
        case 0:
            return self.matches.count
        case 1:
            return self.shouldShowLoadingCell() ? 1 : 0
        default:
            return 0
        }
    }

    func match(forIndexPath indexPath: IndexPath) -> Match? {
        return self.matches[safe: indexPath.row]
    }

}
