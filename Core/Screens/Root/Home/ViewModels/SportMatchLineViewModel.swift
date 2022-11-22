//
//  SportMatchLineViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/02/2022.
//

import Foundation
import ServiceProvider
import Combine

class SportMatchLineViewModel {

    enum MatchesType {
        case popular
        case popularVideo(title: String, contents: [VideoItemFeedContent])
        case live
        case liveVideo(title: String, contents: [VideoItemFeedContent])
        case topCompetition
        case topCompetitionVideo(title: String, contents: [VideoItemFeedContent])

        var identifier: String {
            switch self {
            case .popular: return "popular"
            case .popularVideo(let title, let contents): return "popularVideo\(title)\(contents.count)"
            case .live: return "live"
            case .liveVideo(let title, let contents): return "liveVideo\(title)\(contents.count)"
            case .topCompetition: return "topCompetition"
            case .topCompetitionVideo(let title, let contents): return "topCompetitionVideo\(title)\(contents.count)"

            }
        }
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
        case video
    }

    var refreshPublisher = PassthroughSubject<Void, Never>.init()

    var titlePublisher: CurrentValueSubject<String, Never> = .init("")

    var loadingPublisher: CurrentValueSubject<LoadingState, Never> = .init(.loading)
    var layoutTypePublisher: CurrentValueSubject<LayoutType, Never> = .init(.doubleLine)

    var store: HomeStore

    var sport: Sport
    var topCompetitions: [Competition]?

    var outrightCompetitions: [Competition] = []

    private var videoItemContents: [VideoItemFeedContent]?

    private var matchesType: MatchesType

    private var popularMatchesPublisher: AnyCancellable?
    private var liveMatchesPublisher: AnyCancellable?
    private var competitionsMatchesPublisher: AnyCancellable?
    private var outrightCompetitionsPublisher: AnyCancellable?

    private var popularMatchesRegister: EndpointPublisherIdentifiable?
    private var liveMatchesRegister: EndpointPublisherIdentifiable?
    private var competitionMatchesRegister: EndpointPublisherIdentifiable?
    private var outrightCompetitionsRegister: EndpointPublisherIdentifiable?

    // private var matchesIds: [String] = []

    private var matches: [Match] = []
    
    private var cancellables: Set<AnyCancellable> = []

    init(sport: Sport, matchesType: MatchesType, store: HomeStore) {

        self.sport = sport
        self.matchesType = matchesType
        self.store = store

        switch matchesType {

        case .popular:
            self.titlePublisher = .init( localized("Popular").uppercased())
            self.requestMatches()
        case .live:
            self.titlePublisher = .init( localized("Live").uppercased())
            self.requestMatches()
        case .topCompetition:
            self.titlePublisher = .init( localized("Popular Competitions").uppercased())
            self.layoutTypePublisher.send(.competition)
            self.requestMatches()

        case .popularVideo(let title, let contents):
            self.videoItemContents = contents
            self.titlePublisher = .init(title)
            self.layoutTypePublisher.send(.video)
            self.requestMatches()
            self.loadingPublisher.send(.loaded)
            self.refreshPublisher.send()
        case .liveVideo(let title, let contents):
            self.videoItemContents = contents
            self.titlePublisher = .init(title)
            self.layoutTypePublisher.send(.video)
            self.loadingPublisher.send(.loaded)
            self.refreshPublisher.send()
        case .topCompetitionVideo(let title, let contents):
            self.videoItemContents = contents
            self.titlePublisher = .init(title)
            self.layoutTypePublisher.send(.video)
            self.loadingPublisher.send(.loaded)
            self.refreshPublisher.send()
        }
    }

}

extension SportMatchLineViewModel {

    func isVideoLine() -> Bool {
        switch self.matchesType {
        case .topCompetitionVideo, .liveVideo, .popularVideo:
            return true
        default:
            return false
        }
    }

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

    func numberOfSections(forLine lineIndex: Int) -> Int {
        if self.isVideoLine() {
            return 1
        }
        else if self.isCompetitionLine() {
            if self.topCompetitions != nil {
                return 2
            }
            return 0
        }
        else if self.isOutrightCompetitionLine() {
            return 2
        }
        else if self.matches[safe: lineIndex] != nil {
            return 2
        }
        else {
            return 0
        }
    }

    func numberOfItems(forLine lineIndex: Int, forSection section: Int) -> Int {
        if self.isVideoLine() {
            return self.videoItemContents?.count ?? 0
        }
        else if lineIndex == 0 && self.isCompetitionLine() {
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
        else if self.isOutrightCompetitionLine() {
            if section == 1 {
                return 1 // see all
            }
            else {
                if self.outrightCompetitions.count == 2 {
                    return 1
                }
                else if outrightCompetitions.count == 1 {
                    return lineIndex == 0 ? 1 : 0
                }
            }
        }
        else if let lineMatch = self.matches[safe: lineIndex] {
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
        if let lineMatch = self.matches[safe: lineIndex] {
            return lineMatch.numberTotalOfMarkets
        }
        return 0
    }

    func match(forLine lineIndex: Int = 0) -> Match? {
        if let lineMatch = self.matches[safe: lineIndex] {
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

    func allTopCompetitions() -> [Competition] {
        return self.topCompetitions ?? []
    }

    func isOutrightCompetitionLine() -> Bool {
        return outrightCompetitions.isNotEmpty
    }

    func outrightCompetition(forLine lineIndex: Int = 0) -> Competition? {
        return outrightCompetitions[safe: lineIndex]
    }

    func videoPreviewLineCellViewModel() -> VideoPreviewLineCellViewModel? {
        if let videoItemContents = self.videoItemContents {
            return VideoPreviewLineCellViewModel(title: self.titlePublisher.value, videoItemFeedContents: videoItemContents)
        }
        else {
            return nil
        }
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
        case .popularVideo, .liveVideo, .topCompetitionVideo:
            self.loadingPublisher.send(.loaded)
        }
    }

    private func fetchPopularMatches() {
        
        guard
            let serviceProviderSportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.sport)
        else {
            return
        }
        
        Env.serviceProvider.subscribePreLiveMatches(forSportType: serviceProviderSportType,
                                                    pageIndex: 0,
                                                    eventCount: 2,
                                                    sortType: .popular)
        .sink {  [weak self] (completion: Subscribers.Completion<ServiceProviderError>) in
            switch completion {
            case .finished:
                ()
            case .failure:
                self?.finishedWithError()
            }
        } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
            switch subscribableContent {
            case .connected:
                self?.storeMatches([])
            case .content(let eventsGroups):
                let matches = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups)
                self?.storeMatches(matches)
            case .disconnected:
                self?.storeMatches([])
            }
            self?.updatedContent()
        }
        .store(in: &cancellables)

//
//        if let popularMatchesRegister = popularMatchesRegister {
//            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: popularMatchesRegister)
//        }
//
//        let endpoint = TSRouter.popularMatchesPublisher(operatorId: Env.appSession.operatorId,
//                                                        language: "en",
//                                                        sportId: self.sport.id,
//                                                        matchesCount: 2)
//        self.popularMatchesPublisher?.cancel()
//        self.popularMatchesPublisher = nil
//
//        self.popularMatchesPublisher = Env.everyMatrixClient.manager
//            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure:
//                    self?.finishedWithError()
//                case .finished:
//                    print("Data retrieved!")
//                }
//
//            }, receiveValue: { [weak self] state in
//                switch state {
//                case .connect(let publisherIdentifiable):
//                    self?.popularMatchesRegister = publisherIdentifiable
//                case .initialContent(let aggregator):
//                    self?.storeMatches(fromAggregator: aggregator)
//                    self?.updatedContent()
//                case .updatedContent(let aggregatorUpdates):
//                    self?.updateMatches(fromAggregator: aggregatorUpdates)
//                case .disconnect:
//                    ()
//                }
//            })
    }

    private func fetchLiveMatches() {
        
        guard
            let serviceProviderSportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.sport)
        else {
            return
        }
        
        Env.serviceProvider.subscribeLiveMatches(forSportType: serviceProviderSportType)
            .sink {  [weak self] (completion: Subscribers.Completion<ServiceProviderError>) in
                switch completion {
                case .finished:
                    ()
                case .failure:
                    self?.finishedWithError()
                }
            } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
                switch subscribableContent {
                case .connected:
                    self?.storeMatches([])
                case .content(let eventsGroups):
                    let matches = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups)
                    self?.storeMatches(matches)
                case .disconnected:
                    self?.storeMatches([])
                }
                self?.updatedContent()
            }
            .store(in: &cancellables)
        
//        if let liveMatchesRegister = liveMatchesRegister {
//            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: liveMatchesRegister)
//        }
//
//        let endpoint = TSRouter.liveMatchesPublisher(operatorId: Env.appSession.operatorId,
//                                                     language: "en",
//                                                     sportId: self.sport.id,
//                                                     matchesCount: 2)
//        self.liveMatchesPublisher?.cancel()
//        self.liveMatchesPublisher = nil
//
//        self.liveMatchesPublisher = Env.everyMatrixClient.manager
//            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure:
//                    self?.finishedWithError()
//                case .finished:
//                    print("Data retrieved!")
//                }
//            }, receiveValue: { [weak self] state in
//                switch state {
//                case .connect(let publisherIdentifiable):
//                    self?.popularMatchesRegister = publisherIdentifiable
//                case .initialContent(let aggregator):
//                    self?.storeMatches(fromAggregator: aggregator)
//                    self?.updatedContent()
//                case .updatedContent(let aggregatorUpdates):
//                    self?.updateMatches(fromAggregator: aggregatorUpdates)
//                case .disconnect:
//                    ()
//                }
//            })
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

    private func fetchOutrightCompetitions() {

        if let outrightCompetitionsRegister = outrightCompetitionsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: outrightCompetitionsRegister)
        }

        let endpoint = TSRouter.popularTournamentsPublisher(operatorId: Env.appSession.operatorId,
                                                        language: "en",
                                                            sportId: self.sport.id,
                                                        tournamentsCount: 2)
        self.outrightCompetitionsPublisher?.cancel()
        self.outrightCompetitionsPublisher = nil

        self.outrightCompetitionsPublisher = Env.everyMatrixClient.manager
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
                    self?.outrightCompetitionsRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    self?.storeOutrightCompetitions(aggregator: aggregator)
                case .updatedContent: // (let aggregatorUpdates):
                    ()
                case .disconnect:
                    ()
                }
            })
    }

    func storeOutrightCompetitions(aggregator: EveryMatrix.Aggregator) {

        self.store.storeOutrightTournaments(aggregator)

        let localOutrightCompetitions = self.store.outrightTournaments.values.map { rawTournament -> Competition in
            var location: Location?
            if let rawLocation = self.store.location(forId: rawTournament.venueId ?? "") {
                location = Location(id: rawLocation.id,
                                    name: rawLocation.name ?? "",
                                    isoCode: rawLocation.code ?? "")
            }

            return Competition.init(id: rawTournament.id,
                             name: rawTournament.name ?? "",
                             venue: location,
                             outrightMarkets: rawTournament.numberOfOutrightMarkets ?? 0)
        }

        self.outrightCompetitions = Array(localOutrightCompetitions.prefix(2))
        self.updatedContent()
    }

    func storeMatches(_ matches: [Match]) {
        if case .popular = self.matchesType, matches.isEmpty, self.outrightCompetitions.isEmpty {
            self.fetchOutrightCompetitions()
            return
        }
        
        self.matches = Array(matches.prefix(2))
    }
    
//    func storeMatches(fromAggregator aggregator: EveryMatrix.Aggregator) {
//        var matchesIds: [String] = []
//        for content in aggregator.content ?? [] {
//            switch content {
//            case .match(let matchContent):
//                matchesIds.append(matchContent.id)
//            default:
//                ()
//            }
//        }
//        self.store.storeContent(fromAggregator: aggregator)
//        self.matchesIds = Array(matchesIds.prefix(2))
//
//        // Request outright if no popular matches found
//        if case .popular = self.matchesType {
//            if self.matchesIds.isEmpty && self.outrightCompetitions.isEmpty {
//                self.fetchOutrightCompetitions()
//            }
//        }
//
//    }

    private func finishedWithError() {
        self.loadingPublisher.send(.empty)
    }
    
    private func updatedContent() {

        if self.isOutrightCompetitionLine() {
            self.loadingPublisher.send(.loaded)

            if self.outrightCompetitions.count == 2 {
                self.layoutTypePublisher.send(.doubleLine)
            }
            else if outrightCompetitions.count == 1 {
                self.layoutTypePublisher.send(.singleLine)
            }

            self.titlePublisher.send("Outright Markets")
        }
        else {
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
                if self.matches.count == 2 {
                    self.layoutTypePublisher.send(.doubleLine)
                }
                else if matches.count == 1 {
                    self.layoutTypePublisher.send(.singleLine)
                }

                if self.matches.isEmpty {
                    self.loadingPublisher.send(.empty)
                }
                else {
                    self.loadingPublisher.send(.loaded)
                }
            case .popularVideo, .liveVideo, .topCompetitionVideo:
                self.layoutTypePublisher.send(.video)
            }
        }

        self.refreshPublisher.send()
    }

    func updateMatches(fromAggregator aggregator: EveryMatrix.Aggregator) {
        self.store.updateContent(fromAggregator: aggregator)
    }

}
