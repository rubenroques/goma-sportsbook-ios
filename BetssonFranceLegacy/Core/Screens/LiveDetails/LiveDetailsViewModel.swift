//
//  LiveDetailsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 17/03/2022.
//

import Foundation
import Combine
import ServicesProvider

class LiveDetailsViewModel {

    var refreshPublisher = PassthroughSubject<Void, Never>.init()
    var isLoading: CurrentValueSubject<Bool, Never> = .init(true)
    var titlePublisher: CurrentValueSubject<String, Never>

    private var matchesPublisher: AnyCancellable?

    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    private var sport: Sport
    private var matches: [Match] = []

    private var hasNextPage = true

    private var cancellables: Set<AnyCancellable> = []
    private var subscriptions: Set<ServicesProvider.Subscription> = []

    init(sport: Sport) {
        self.sport = sport

        self.titlePublisher = .init("\(self.sport.name) - Live Matches")

        self.refresh()
    }

    func refresh() {
        self.hasNextPage = true
        self.isLoading.send(true)
        self.fetchMatches()
    }

    func requestNextPage() {
        self.fetchMatchesNextPage()
    }

    private func fetchMatchesNextPage() {
        let sportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.sport)
        Env.servicesProvider.requestLiveMatchesNextPage(forSportType: sportType)
            .sink { completion in
                print("requestPreLiveMatchesNextPage completion \(completion)")
            } receiveValue: { [weak self] hasNextPage in
                self?.hasNextPage = hasNextPage
                if !hasNextPage {
                    self?.requestUpdate()
                }
            }
            .store(in: &cancellables)
    }


    private func fetchMatches() {

        let sportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.sport)

        print("subscribeLiveMatches fetchData called")

        self.matchesPublisher = Env.servicesProvider.subscribeLiveMatches(forSportType: sportType)
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
                    self?.requestUpdate()
                case .disconnected:
                    Logger.log("subscribeLiveMatches subscribableContent disconnected")
                }
            })
    }

    private func requestUpdate() {
        self.refreshPublisher.send()
    }

    private func setupWithMatches(_ matches: [Match]) {
        self.matches = matches

        self.isLoading.send(false)
    }

    private func setupWithError() {
        self.isLoading.send(false)
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

}

extension LiveDetailsViewModel {

    func shouldShowLoadingCell() -> Bool {
        return self.matches.isNotEmpty && hasNextPage
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
