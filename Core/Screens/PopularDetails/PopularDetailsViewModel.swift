//
//  PopularDetailsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 14/03/2022.
//

import Foundation
import Combine
import ServiceProvider

class PopularDetailsViewModel {

    var store: AggregatorsRepository

    var refreshPublisher = PassthroughSubject<Void, Never>.init()

    var isLoading: CurrentValueSubject<Bool, Never> = .init(true)

    var titlePublisher: CurrentValueSubject<String, Never>

    private var matchesPublisher: AnyCancellable?
    private var matchesRegister: EndpointPublisherIdentifiable?

    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    private var sport: Sport
    private var matches: [Match] = []
    private var outrightCompetitions: [Competition]?

    private var matchesCount = 10
    private var matchesPage = 1
    private var matchesHasNextPage = true

    private var cancellables: Set<AnyCancellable> = []
    private var subscriptions: Set<ServiceProvider.Subscription> = []

    init(sport: Sport, store: AggregatorsRepository) {
        self.store = store
        self.sport = sport

        self.titlePublisher = .init(self.sport.name)

        self.refresh()
    }

    func refresh() {
        self.resetPageCount()
        self.isLoading.send(true)
        self.fetchMatches()
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

        let sportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.sport)

        Logger.log("subscribePreLiveMatches fetchData called")

        self.matchesPublisher = Env.serviceProvider.subscribePreLiveMatches(forSportType: sportType, sortType: .popular)
            .sink(receiveCompletion: { [weak self] completion in
                // TODO: subscribePreLiveMatches receiveCompletion
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    self?.setupWithError()
                    Logger.log("subscribePreLiveMatches error \(error)")
                }
            }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
                switch subscribableContent {
                case .connected(let subscription):
                    self?.subscriptions.insert(subscription)
                case .contentUpdate(let eventsGroups):
                    let allMatches = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups)
                    self?.setupWithMatches(allMatches)
                case .disconnected:
                    Logger.log("subscribePreLiveMatches subscribableContent disconnected")
                }
            })

    }

    private func closeOutrightCompetitionsConnection() {

    }

    private func fetchOutrightCompetitions() {

    }

    private func setupWithMatches(_ matches: [Match]) {
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

    private func setupWithError() {
        self.isLoading.send(false)
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
