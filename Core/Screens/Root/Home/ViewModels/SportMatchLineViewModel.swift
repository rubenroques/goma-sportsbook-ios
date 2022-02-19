//
//  SportMatchLineViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/02/2022.
//

import Foundation
import Combine

class SportGroupViewModel {

    var requestRefreshPublisher = PassthroughSubject<Void, Never>.init()

    private var store: HomeStore
    private var sport: Sport

    private var cachedViewModels: [SportMatchLineViewModel.MatchesType: SportMatchLineViewModel] = [:]
    private var cachedViewModelStates: [SportMatchLineViewModel.MatchesType: SportMatchLineViewModel.LoadingState] = [:]

    private var cancellables: Set<AnyCancellable> = []

    init(sport: Sport, store: HomeStore) {
        self.sport = sport
        self.store = store
//
//        for type in SportMatchLineViewModel.MatchesType.allCases {
//            _ = self.sportMatchLineViewModel(forType: type)
//        }
    }

    func numberOfRows() -> Int {
        var count = 3

//        let popularState = self.cachedViewModelStates[.popular]
//        if popularState == .loaded {
//            count += 1
//        }
//
//        let liveState = self.cachedViewModelStates[.live]
//        if liveState  == .loaded {
//            count += 1
//        }
//
//        let competitionState = self.cachedViewModelStates[.topCompetition]
//        if competitionState  == .loaded {
//            count += 1
//        }

        return count
    }

    func sportMatchLineViewModel(forIndex index: Int) -> SportMatchLineViewModel? {
        if let matchType = SportMatchLineViewModel.matchesType(forIndex: index) {
            return self.sportMatchLineViewModel(forType: matchType)
        }
        return nil
    }

    func sportMatchLineViewModel(forType type: SportMatchLineViewModel.MatchesType) -> SportMatchLineViewModel {

        if let sportMatchLineViewModel = cachedViewModels[type] {
            print("HomeDebug cached - \(self.sport.name);\(type)")
            return sportMatchLineViewModel
        }
        else {

            print("HomeDebug create - \(self.sport.name);\(type)")

            let sportMatchLineViewModel = SportMatchLineViewModel(sport: self.sport, matchesType: type, store: self.store)

            sportMatchLineViewModel.loadingPublisher
                .removeDuplicates()
                .sink { [weak self] loadingState in
                    self?.updateLoadingState(loadingState: loadingState, forMatchType: type)
                }
                .store(in: &cancellables)
            cachedViewModels[type] = sportMatchLineViewModel

            return sportMatchLineViewModel
        }

    }

    private func updateLoadingState(loadingState: SportMatchLineViewModel.LoadingState,
                                    forMatchType matchType: SportMatchLineViewModel.MatchesType) {

        print("HomeDebug updateLoading - \(self.sport.name);\(matchType);\(loadingState)")

        self.cachedViewModelStates[matchType] = loadingState
        self.requestRefreshPublisher.send()
    }

}

class SportMatchLineViewModel {

    enum MatchesType: String, CaseIterable {
        case popular
        case live
        case topCompetition
    }

    enum LoadingState {
        case idle
        case loaded
        case loading
        case empty
    }

    enum LayoutType {
        case doubleLine
        case singleLine
        case competition
    }

    var refreshPublisher = PassthroughSubject<Void, Never>.init()

    var titlePublisher: CurrentValueSubject<String, Never> = .init("")

    var loadingPublisher: CurrentValueSubject<LoadingState, Never> = .init(.idle)
    var layoutTypePublisher: CurrentValueSubject<LayoutType, Never> = .init(.doubleLine)

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
            self.titlePublisher = .init( localized("Popular Competition").uppercased() )
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
            if self.competition != nil {
                return 2
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
            if self.competition != nil {
                if section == 1 {
                    return 1 // see all
                }
                else {
                    return 1 // competition card
                }
            }
            return 0
        }
        else if let lineMatchId = matchesIds[safe: lineIndex],
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

    func competitionViewModel() -> CompetitionLineViewModel? {
        if let competition = self.competition {
            return CompetitionLineViewModel(competition: competition)
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
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
                self?.finishedLoading()
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
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
                self?.finishedLoading()
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
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
                self?.finishedLoading()
            }, receiveValue: {  [weak self] tournaments in
                if let topCompetition = tournaments.first(where: { $0.sportId == self?.sport.id }) {
                    var location: Location?
                    if let rawLocation = self?.store.location(forId: topCompetition.venueId ?? "") {
                        location = Location(id: rawLocation.id,
                                        name: rawLocation.name ?? "",
                                        isoCode: rawLocation.code ?? "")
                    }
                    self?.competition = Competition(id: topCompetition.id,
                                                    name: topCompetition.name ?? "",
                                                    venue: location,
                                                    outrightMarkets: topCompetition.numberOfOutrightMarkets ?? 0)
                    // self?.fetchCompetitionsWithId(topCompetition.id)
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

        self.updatedContent()
    }

    private func finishedLoading() {
        self.loadingPublisher.send(.loaded)
    }

    private func updatedContent() {

        switch self.matchesType {
        case .topCompetition:
            self.layoutTypePublisher.send(.competition)

            if self.competition == nil {
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
