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

    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    private var sport: Sport
    private var matches: [Match] = []

    private var matchesCount = 10
    private var matchesPage = 1
    private var matchesHasNextPage = true

    private var cancellables: Set<AnyCancellable> = []
    private var subscriptions: Set<ServiceProvider.Subscription> = []

    init(sport: Sport, store: AggregatorsRepository) {
        self.store = store
        self.sport = sport

        self.titlePublisher = .init("\(self.sport.name) - Live Matches")

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

        print("subscribeLiveMatches fetchData called")

        self.matchesPublisher = Env.serviceProvider.subscribeLiveMatches(forSportType: sportType, pageIndex: 0)
            .sink(receiveCompletion: { [weak self] completion in
                // TODO: subscribeLiveMatches receiveCompletion
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    Logger.log("subscribeLiveMatches error \(error)")
                    self?.setupWithError()
                }
            }, receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
                switch subscribableContent {
                case .connected(let subscription):
                    self?.subscriptions.insert(subscription)
                case .contentUpdate(let eventsGroups):
                    let allMatches = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups)
                    self?.setupWithMatches(allMatches)
                case .disconnected:
                    Logger.log("subscribeLiveMatches subscribableContent disconnected")
                }
            })

    }

    private func setupWithMatches(_ matches: [Match]) {
        self.matches = matches

        self.isLoading.send(false)

        self.refreshPublisher.send()
    }

    private func setupWithError() {
        self.isLoading.send(false)
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
