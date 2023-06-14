//
//  SportMatchLineViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/02/2022.
//

import Foundation
import ServicesProvider
import Combine

class SportMatchLineViewModel {

    enum MatchesType {
        case popular
        case popularVideo(title: String, contents: [VideoItemFeedContent])
        case live
        case liveVideo(title: String, contents: [VideoItemFeedContent])
        case topCompetition
        case topCompetitionVideo(title: String, contents: [VideoItemFeedContent])
        case mixedEvents(title: String?)

        var identifier: String {
            switch self {
            case .popular: return "popular"
            case .popularVideo(let title, let contents): return "popularVideo\(title)\(contents.count)"
            case .live: return "live"
            case .liveVideo(let title, let contents): return "liveVideo\(title)\(contents.count)"
            case .topCompetition: return "topCompetition"
            case .topCompetitionVideo(let title, let contents): return "topCompetitionVideo\(title)\(contents.count)"
            case .mixedEvents(let title): return "mixedEvents\(title ?? "nil")"
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

    var sport: Sport
    var topCompetitions: [Competition]?

    var outrightCompetitions: [Competition] = []

    private var videoItemContents: [VideoItemFeedContent]?

    private var matchesType: MatchesType

    private var matches: [Match] = []

    private var cancellables: Set<AnyCancellable> = []
    private var subscriptions = Set<ServicesProvider.Subscription>()

    init(sport: Sport, matchesType: MatchesType) {

        self.sport = sport
        self.matchesType = matchesType

        switch matchesType {

        case .popular:
            self.titlePublisher = .init( localized("popular").uppercased())
            self.requestMatches()
        case .live:
            self.titlePublisher = .init( localized("live").uppercased())
            self.requestMatches()
        case .topCompetition:
            self.titlePublisher = .init( localized("popular_competitions").uppercased())
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
        case .mixedEvents(let title):
            self.titlePublisher = .init(title ?? "")
            self.requestMatches()
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
        else if let lineOutright = self.outrightCompetitions[safe: lineIndex] {
            return lineOutright.numberOutrightMarkets
        }
        return 0
    }

    func match(forLine lineIndex: Int = 0) -> Match? {
        if let lineMatch = self.matches[safe: lineIndex] {
            return lineMatch
        }
        return nil
    }

    func shouldShowLine() -> Bool {
        return !self.matches.isEmpty || !self.outrightCompetitions.isEmpty
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
        case .mixedEvents:
            ()
        }
    }

    private func fetchPopularMatches() {

        let serviceProviderSportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.sport)

        Env.servicesProvider.subscribePreLiveMatches(forSportType: serviceProviderSportType,
                                                    eventCount: 5,
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
            case .connected(let subscription):
                self?.subscriptions.insert(subscription)
                self?.matches = []
            case .contentUpdate(let eventsGroups):
                guard let self = self else { return }

                let splittedEventGroups = self.splitEventsGroups(eventsGroups)

                self.processEvents(matchesEventsGroups: splittedEventGroups.matchesEventGroups, competitionsEventsGroups: splittedEventGroups.competitionsEventGroups)

            case .disconnected:
                self?.matches = []
            }
            self?.updatedContent()
        }
        .store(in: &cancellables)

    }

    private func fetchLiveMatches() {

        let serviceProviderSportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: self.sport)

        Env.servicesProvider.subscribeLiveMatches(forSportType: serviceProviderSportType)
            .sink {  [weak self] (completion: Subscribers.Completion<ServiceProviderError>) in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    self?.finishedWithError()
                }
            } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
                switch subscribableContent {
                case .connected(let subscription):
                    self?.subscriptions.insert(subscription)
                    self?.matches = []
                case .contentUpdate(let eventsGroups):
                    let matches = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups)
                    self?.matches = matches
                case .disconnected:
                    self?.matches = []
                }
                self?.updatedContent()
            }
            .store(in: &cancellables)

    }

    func fetchTopCompetitionMatches() {

        return

    }

    private func fetchOutrightCompetitions(eventsGroups: [EventsGroup]) {
        let competitions = ServiceProviderModelMapper.competitions(fromEventsGroups: eventsGroups)
        self.outrightCompetitions = Array(competitions.prefix(2))
        self.updatedContent()
    }

    func processEvents(matchesEventsGroups: [EventsGroup], competitionsEventsGroups: [EventsGroup]) {

        let matches = ServiceProviderModelMapper.matches(fromEventsGroups: matchesEventsGroups)

        if case .popular = self.matchesType, matches.isEmpty, self.outrightCompetitions.isEmpty {
            self.fetchOutrightCompetitions(eventsGroups: competitionsEventsGroups)
            return
        }

        self.matches = Array(matches.prefix(2))


    }

    private func splitEventsGroups(_ eventsGroups: [EventsGroup]) -> (matchesEventGroups: [EventsGroup], competitionsEventGroups: [EventsGroup]) {

        var matchEventsGroups: [EventsGroup] = []
        for eventGroup in eventsGroups {
            let matchEvents = eventGroup.events.filter { event in
                event.type == .match
            }
            matchEventsGroups.append(EventsGroup(events: matchEvents, marketGroupId: eventGroup.marketGroupId))
        }

        //
        var competitionEventsGroups: [EventsGroup] = []
        for eventGroup in eventsGroups {
            let competitionEvents = eventGroup.events.filter { event in
                event.type == .competition
            }
            competitionEventsGroups.append(EventsGroup(events: competitionEvents, marketGroupId: eventGroup.marketGroupId))
        }

        return (matchEventsGroups, competitionEventsGroups)
    }

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

            case .mixedEvents:
                self.loadingPublisher.send(.empty)
            }
        }

        self.refreshPublisher.send()
    }

}

