//
//  SportMatchLineViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/02/2022.
//

import Foundation
import Combine

class SportMatchLineViewModel {

    enum MatchesType: String, CaseIterable {
        case popular
        case live
        case topCompetition
    }

    enum LoadingState {
        case loading
        case loaded
        case empty
    }

    enum LayoutType {
        case doubleLine
        case singleLine
        case competition
    }

    var refreshPublisher = PassthroughSubject<Void, Never>.init()

    var titlePublisher: CurrentValueSubject<String, Never> = .init("")

    var loadingPublisher: CurrentValueSubject<LoadingState, Never> = .init(.loading)
    var layoutTypePublisher: CurrentValueSubject<LayoutType, Never> = .init(.doubleLine)

    var store: HomeStore

    var sport: Sport
    var topCompetitions: [Competition]?

    private var matchesType: MatchesType

    private var popularMatchesPublisher: AnyCancellable?
    private var liveMatchesPublisher: AnyCancellable?
    private var competitionsMatchesPublisher: AnyCancellable?

    private var popularMatchesRegister: EndpointPublisherIdentifiable?
    private var liveMatchesRegister: EndpointPublisherIdentifiable?
    private var competitionMatchesRegister: EndpointPublisherIdentifiable?

    private var matchesIds: [String] = []

    private var cancellables: Set<AnyCancellable> = []

    init(sport: Sport, matchesType: MatchesType, store: HomeStore) {

        self.sport = sport
        self.matchesType = matchesType
        self.store = store

        switch matchesType {
        case .popular:
            self.titlePublisher = .init( localized("Popular").uppercased() )
        case .live:
            self.titlePublisher = .init( localized("Live").uppercased() )
        case .topCompetition:
            self.titlePublisher = .init( localized("Popular Competitions").uppercased() )
            self.layoutTypePublisher.send(.competition)
        }

        self.requestMatches()
    }

}

extension SportMatchLineViewModel {

    func isCompetitionLine() -> Bool {
        if case .topCompetition = self.matchesType {
            return true
        }
        else {
            return false
        }
    }

    func isMatchLineLive() -> Bool {
        if case .live = self.matchesType {
            return true
        }
        else {
            return false
        }
    }

    static func matchesType(forIndex index: Int) -> MatchesType? {
        switch index {
        case 0: return .popular
        case 1: return .live
        case 2: return .topCompetition
        default: return nil
        }
    }

    func numberOfSections(forLine lineIndex: Int) -> Int {
        if self.isCompetitionLine() {
            if self.topCompetitions != nil {
                return 1
            }
            return 0
        }
        else if let lineMatchId = matchesIds[safe: lineIndex],
            self.store.matchWithId(id: lineMatchId) != nil {
            return 2
        }
        else {
            return 0
        }
    }

    func numberOfItems(forLine lineIndex: Int, forSection section: Int) -> Int {

        if lineIndex == 0 && self.isCompetitionLine() {
            if let topCompetitions = self.topCompetitions {
                if section == 1 {
                    return 1 // see all
                }
                else {
                    return topCompetitions.count
                }
            }
            return 0
        }
        else if let lineMatchId = matchesIds[safe: lineIndex],
           let lineMatch = self.store.matchWithId(id: lineMatchId) {
            if section == 0 {
                return lineMatch.markets.isEmpty ? 1 : lineMatch.markets.count
            }
            else if section == 1 {
                return 1
            }
        }
        return 0
    }

    func numberOfMatchMarket(forLine lineIndex: Int = 0) -> Int {
        if let lineMatchId = matchesIds[safe: lineIndex],
           let lineMatch = self.store.matchWithId(id: lineMatchId) {
            return lineMatch.numberTotalOfMarkets
        }
        return 0
    }

    func match(forLine lineIndex: Int = 0) -> Match? {
        if let lineMatchId = matchesIds[safe: lineIndex],
           let lineMatch = self.store.matchWithId(id: lineMatchId) {
            return lineMatch
        }
        return nil
    }

    func competitionViewModel(forIndex index: Int) -> CompetitionWidgetViewModel? {
        if let competition = self.topCompetitions?[safe: index] {
            return CompetitionWidgetViewModel(competition: competition)
        }
        return nil
    }

}

extension SportMatchLineViewModel {

    private func requestMatches() {

        self.loadingPublisher.send(.loading)

        switch self.matchesType {
        case .popular:
            self.fetchPopularMatches()
        case .live:
            self.fetchLiveMatches()
        case .topCompetition:
            self.fetchTopCompetitionMatches()
        }
    }

    private func fetchPopularMatches() {

        if let popularMatchesRegister = popularMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: popularMatchesRegister)
        }

        let endpoint = TSRouter.popularMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                        language: "en",
                                                        sportId: self.sport.id,
                                                        matchesCount: 2)
        self.popularMatchesPublisher?.cancel()
        self.popularMatchesPublisher = nil

        self.popularMatchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    self?.finishedWithError()
                case .finished:
                    print("Data retrieved!")
                }
                
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    self?.popularMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    self?.storeMatches(fromAggregator: aggregator)
                    self?.updatedContent()
                case .updatedContent(let aggregatorUpdates):
                    self?.updateMatches(fromAggregator: aggregatorUpdates)
                case .disconnect:
                    ()
                }
            })
    }

    private func fetchLiveMatches() {

        if let liveMatchesRegister = liveMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: liveMatchesRegister)
        }

        let endpoint = TSRouter.liveMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                     language: "en",
                                                     sportId: self.sport.id,
                                                     matchesCount: 2)
        self.liveMatchesPublisher?.cancel()
        self.liveMatchesPublisher = nil

        self.liveMatchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    self?.finishedWithError()
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    self?.popularMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    self?.storeMatches(fromAggregator: aggregator)
                    self?.updatedContent()
                case .updatedContent(let aggregatorUpdates):
                    self?.updateMatches(fromAggregator: aggregatorUpdates)
                case .disconnect:
                    ()
                }
            })
    }

    func fetchTopCompetitionMatches() {

        let language = "en"
        let endpoint = TSRouter.getCustomTournaments(language: language, sportId: self.sport.id)

        Env.everyMatrixClient.manager
            .getModel(router: endpoint, decodingType: EveryMatrixSocketResponse<EveryMatrix.Tournament>.self)
            .map(\.records)
            .compactMap({ $0 })
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    self?.finishedWithError()
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: {  [weak self] tournaments in
                self?.topCompetitions = nil

                let rawTopCompetitions = tournaments.filter({ $0.sportId == self?.sport.id })
                let topCompetitions = rawTopCompetitions.map { topCompetition -> Competition in
                    var location: Location?
                    if let rawLocation = self?.store.location(forId: topCompetition.venueId ?? "") {
                        location = Location(id: rawLocation.id,
                                            name: rawLocation.name ?? "",
                                            isoCode: rawLocation.code ?? "")
                    }
                    return Competition(id: topCompetition.id,
                                       name: topCompetition.name ?? "",
                                       venue: location,
                                       outrightMarkets: topCompetition.numberOfOutrightMarkets ?? 0)
                }

                if topCompetitions.isNotEmpty {
                    self?.topCompetitions = topCompetitions
                }

                self?.updatedContent()
            })
            .store(in: &cancellables)

    }

    func storeMatches(fromAggregator aggregator: EveryMatrix.Aggregator) {
        var matchesIds: [String] = []
        for content in aggregator.content ?? [] {
            switch content {
            case .match(let matchContent):
                matchesIds.append(matchContent.id)
            default:
                ()
            }
        }
        self.store.storeContent(fromAggregator: aggregator)
        self.matchesIds = Array(matchesIds.prefix(2))
    }

    private func finishedWithError() {
        self.loadingPublisher.send(.empty)
    }
    
    private func updatedContent() {

        switch self.matchesType {
        case .topCompetition:
            self.layoutTypePublisher.send(.competition)

            if self.topCompetitions == nil {
                self.loadingPublisher.send(.empty)
            }
            else {
                self.loadingPublisher.send(.loaded)
            }
        case .live, .popular:
            if self.matchesIds.count == 2 {
                self.layoutTypePublisher.send(.doubleLine)
            }
            else if matchesIds.count == 1 {
                self.layoutTypePublisher.send(.singleLine)
            }

            if self.matchesIds.isEmpty {
                self.loadingPublisher.send(.empty)
            }
            else {
                self.loadingPublisher.send(.loaded)
            }
        }

        self.refreshPublisher.send()
    }

    func updateMatches(fromAggregator aggregator: EveryMatrix.Aggregator) {
        self.store.updateContent(fromAggregator: aggregator)
    }

}
