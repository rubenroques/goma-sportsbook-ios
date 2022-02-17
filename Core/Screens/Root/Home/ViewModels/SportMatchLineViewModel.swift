//
//  SportMatchLineViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/02/2022.
//

import Foundation
import Combine

class SportGroupViewModel {

}

class SportMatchLineViewModel {

    enum MatchesType: String, CaseIterable {
        case popular
        case live
        case topCompetition
    }

    var redrawPublisher = PassthroughSubject<Void, Never>.init()
    var refreshPublisher = PassthroughSubject<Void, Never>.init()

    var titlePublisher: CurrentValueSubject<String, Never> = .init("")

    var numberOfLoadedMatchedPublisher = CurrentValueSubject<Int, Never>.init(0)

    var store: HomeStore

    private var sport: Sport
    private var matchesType: MatchesType

    private var competition: Competition?

    private var popularMatchesPublisher: AnyCancellable?
    private var liveMatchesPublisher: AnyCancellable?
    private var competitionsMatchesPublisher: AnyCancellable?

    private var popularMatchesRegister: EndpointPublisherIdentifiable?
    private var liveMatchesRegister: EndpointPublisherIdentifiable?
    private var competitionMatchesRegister: EndpointPublisherIdentifiable?

    private var matchesIds: [String] = [] {
        didSet {
            self.numberOfLoadedMatchedPublisher.send(self.matchesIds.count)
        }
    }

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
            self.titlePublisher = .init( localized("Popular Competition").uppercased() )
        }

        self.requestMatches()
    }

}

extension SportMatchLineViewModel {

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
        if let lineMatchId = matchesIds[safe: lineIndex],
            self.store.matchWithId(id: lineMatchId) != nil {
            return 2
        }
        else {
            return 0
        }
    }

    func numberOfItems(forLine lineIndex: Int, forSection section: Int) -> Int {
        if let lineMatchId = matchesIds[safe: lineIndex],
           let lineMatch = self.store.matchWithId(id: lineMatchId) {
            if section == 0 {
                return lineMatch.markets.count
            }
            else if section == 1 {
                return 1
            }
        }
        return 0
    }

    func numberOfMatchMarket(forLine lineIndex: Int) -> Int {
        if let lineMatchId = matchesIds[safe: lineIndex],
           let lineMatch = self.store.matchWithId(id: lineMatchId) {
            return lineMatch.numberTotalOfMarkets
        }
        return 0
    }

    func match(forLine lineIndex: Int) -> Match? {
        if let lineMatchId = matchesIds[safe: lineIndex],
           let lineMatch = self.store.matchWithId(id: lineMatchId) {
            return lineMatch
        }
        return nil
    }

}

extension SportMatchLineViewModel {

    private func requestMatches() {
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
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    self?.popularMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    self?.storeMatches(fromAggregator: aggregator)
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
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }

            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    self?.popularMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    self?.storeMatches(fromAggregator: aggregator)
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
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: {  [weak self] tournaments in
                if let topCompetition = tournaments.first(where: { $0.sportId == self?.sport.id }) {
                    self?.competition = Competition(id: topCompetition.id, name: topCompetition.name ?? "")
                    self?.fetchCompetitionsWithId(topCompetition.id)
                }
            })
            .store(in: &cancellables)

    }

    func fetchCompetitionsWithId(_ id: String) {

        if let competitionMatchesRegister = competitionMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: competitionMatchesRegister)
        }

        let language = "en"
        let endpoint = TSRouter.competitionsMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                             language: language,
                                                             sportId: self.sport.id,
                                                             events: [id])

        self.competitionsMatchesPublisher?.cancel()
        self.competitionsMatchesPublisher = nil

        self.competitionsMatchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("fetchCompetitionsWithIds competitionsMatchesPublisher connect")
                    self?.competitionMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("fetchCompetitionsWithIds competitionsMatchesPublisher initialContent")
                    self?.storeMatches(fromAggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    self?.updateMatches(fromAggregator: aggregatorUpdates)
                    print("fetchCompetitionsWithIds competitionsMatchesPublisher updatedContent")
                case .disconnect:
                    print("fetchCompetitionsWithIds competitionsMatchesPublisher disconnect")
                }
            })
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
        self.refreshPublisher.send()
    }

    func updateMatches(fromAggregator aggregator: EveryMatrix.Aggregator) {
        self.store.updateContent(fromAggregator: aggregator)
    }

}
