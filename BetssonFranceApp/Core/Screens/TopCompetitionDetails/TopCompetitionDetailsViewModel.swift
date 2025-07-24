//
//  TopCompetitionDetailsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/03/2022.
//

import Foundation
import Combine
import OrderedCollections
import ServicesProvider

class TopCompetitionDetailsViewModel {

    enum ContentType {
        case outrightMarket(Competition)
        case match(Match)
    }

    var refreshPublisher: AnyPublisher<Void, Never> {
        let changedArrayPublisher = self.competitionsSubject
            .removeDuplicates()
            .map { _ in }
            .eraseToAnyPublisher()

        return Publishers.Merge(changedArrayPublisher, self.forcedRefreshPassthroughSubject)
            .map({ _ in })
            .eraseToAnyPublisher()
    }

    var competitions: [Competition] {
        return self.competitionsSubject.value
    }
    var competitionsSubject: CurrentValueSubject<[Competition], Never> = .init([])

    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        return self.isLoadingCurrentValueSubject.eraseToAnyPublisher()
    }

    private var sport: Sport
    private var competitionsIds: [String]

    private var forcedRefreshPassthroughSubject: PassthroughSubject<Void, Never> = .init()
    private var competitionsMatchesSubscriptions: [String: ServicesProvider.Subscription] = [:]

    private var competitionIdsSubject: CurrentValueSubject<[String], Never> = .init([])
    private var competitionsIdentifiersSubject: CurrentValueSubject<[String: [String]], Never> = .init([:])

    private var isLoadingCurrentValueSubject: CurrentValueSubject<Bool, Never> = .init(false)
    private var activeNetworkRequestCount = 0 {
        didSet {
            print("CompetitionsDataSource activeNetworkRequestCount: \(self.activeNetworkRequestCount)")
            self.isLoadingCurrentValueSubject.send(activeNetworkRequestCount > 0)
        }
    }

    private var matchLineTableCellViewModelCache: [String: MatchLineTableCellViewModel] = [:]

    private var cancellables: Set<AnyCancellable> = []

    init(competitionsIds: [String], sport: Sport) {
        self.sport = sport
        self.competitionsIds = competitionsIds

        self.refresh()
    }

    func refresh() {
        self.fetchCompetitionsMatchesWithIds(self.competitionsIds)
    }

    func markCompetitionAsFavorite(competition: Competition) {
        
        var isFavorite = false
        for competitionId in Env.favoritesManager.favoriteEventsIdPublisher.value where competitionId == competition.id {
            isFavorite = true
        }
        
        if isFavorite {
            Env.favoritesManager.removeFavorite(eventId: competition.id, favoriteType: .competition)
        }
        else {
            Env.favoritesManager.addFavorite(eventId: competition.id, favoriteType: .competition)
        }
    }

    private func fetchCompetitionsMatchesWithIds(_ competitionIds: [String]) {

        self.activeNetworkRequestCount += 1

        let competitionsMatchesPublishers = self.requestForCompetitionsMatchesWithIds(competitionIds)
        Publishers.MergeMany(competitionsMatchesPublishers)
            .compactMap({ $0 })
            .collect()
            .map({ competitionInfos in
                return competitionInfos.reduce(into: [String: SportCompetitionInfo](), { result, competitionInfo in
                    result[competitionInfo.id] = competitionInfo
                })
            })
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("TopCompetitionsDataSource fetchTopCompetitionsMatches - Finished all the requests")
                case .failure(let error):
                    print("TopCompetitionsDataSource fetchTopCompetitionsMatches - Finished all the requests with an error \(error)")
                }
                self?.activeNetworkRequestCount -= 1
            } receiveValue: { competitionInfoDictionsary in
                self.processCompetitionsInfo(competitionInfoDictionsary)
            }
            .store(in: &self.cancellables)

    }

    private func requestForCompetitionsMatchesWithIds(_ competitionIds: [String]) -> [AnyPublisher<SportCompetitionInfo?, Never>] {

        var publishers: [AnyPublisher<SportCompetitionInfo?, Never>] = []
        for competitionId in competitionIds {
            let sportCompetitionInfoPublisher = Env.servicesProvider.getCompetitionMarketGroups(competitionId: competitionId)
                .map({ competitionInfo in return Optional.some(competitionInfo) })
                .replaceError(with: nil)
                .eraseToAnyPublisher()
            publishers.append(sportCompetitionInfoPublisher)
        }
        return publishers

    }

    private func processCompetitionsInfo(_ selectedCompetitionsInfo: [String: SportCompetitionInfo]) {

        let competitionInfos = selectedCompetitionsInfo.map({ $0.value }).filter({
            $0.marketGroups.isNotEmpty
        })

        self.competitionsMatchesSubscriptions = [:]
        self.competitionsSubject.send([])

        for competitionInfo in competitionInfos {
            if let marketGroup = competitionInfo.marketGroups.filter({ $0.name.lowercased().contains("main") }).first {
                self.subscribeCompetitionMatches(forMarketGroupId: marketGroup.id, competitionInfo: competitionInfo)
            }
            else if let marketGroup = competitionInfo.marketGroups.filter({ $0.name.lowercased().contains("outright") }).first {
                self.subscribeCompetitionOutright(forMarketGroupId: marketGroup.id, competitionInfo: competitionInfo)
            }
        }

    }

    private func subscribeCompetitionMatches(forMarketGroupId marketGroupId: String, competitionInfo: SportCompetitionInfo) {

        let competitionId = competitionInfo.id

        self.activeNetworkRequestCount += 1

        Env.servicesProvider.subscribeCompetitionMatches(forMarketGroupId: marketGroupId)
        .sink { [weak self] completion  in
            switch completion {
            case .finished:
                print("CompetitionsDataSource subscribeCompetitionMatches - completed")
            case .failure(let error):
                print("CompetitionsDataSource subscribeCompetitionMatches - completed with error \(error)")
            }
            self?.activeNetworkRequestCount -= 1
        } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
            switch subscribableContent {
            case .connected(let subscription):
                self?.competitionsMatchesSubscriptions[competitionId] = subscription
            case .contentUpdate(let eventsGroups):
                let matches = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups)
                self?.processCompetitionMatches(matches: matches, competitionInfo: competitionInfo)
                self?.activeNetworkRequestCount -= 1
            case .disconnected:
                self?.competitionsMatchesSubscriptions[competitionId] = nil
            }
        }
        .store(in: &cancellables)
    }

    private func processCompetitionMatches(matches: [Match], competitionInfo: SportCompetitionInfo) {

        let newCompetition = Competition(id: competitionInfo.id,
                                         name: competitionInfo.name,
                                         matches: matches,
                                         venue: matches.first?.venue,
                                         sport: nil,
                                         numberOutrightMarkets: Int(competitionInfo.numberOutrightMarkets) ?? 0,
                                         competitionInfo: competitionInfo)

        self.competitionsSubject.value.append(newCompetition)

    }

    private func subscribeCompetitionOutright(forMarketGroupId marketGroupId: String, competitionInfo: SportCompetitionInfo) {

        self.activeNetworkRequestCount += 1

        let competitionId = competitionInfo.id

        Env.servicesProvider.subscribeCompetitionMatches(forMarketGroupId: marketGroupId)
        .sink { [weak self] completion in
            switch completion {
            case .finished:
                print("CompetitionsDataSource subscribeCompetitionOutright - completed")
            case .failure(let error):
                print("CompetitionsDataSource subscribeCompetitionOutright - completed with error \(error)")
            }
            self?.activeNetworkRequestCount -= 1
        } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
            switch subscribableContent {
            case .connected(let subscription):
                self?.competitionsMatchesSubscriptions[competitionId] = subscription
            case .contentUpdate(let eventsGroups):
                if let outrightMatch = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups).first {
                    self?.processCompetitionOutrights(outrightMatch: outrightMatch, competitionInfo: competitionInfo)
                }
                self?.activeNetworkRequestCount -= 1
            case .disconnected:
                self?.competitionsMatchesSubscriptions[competitionId] = nil
            }
        }
        .store(in: &cancellables)
    }

    private func processCompetitionOutrights(outrightMatch: Match, competitionInfo: SportCompetitionInfo) {

        guard
            !self.competitions.contains(where: { $0.id == competitionInfo.id })
        else {
            return
        }

        let numberOutrightMarkets = competitionInfo.numberOutrightMarkets == "0" ? 1 : Int(competitionInfo.numberOutrightMarkets) ?? 0

        let newCompetition = Competition(id: competitionInfo.id,
                                         name: competitionInfo.name,
                                         matches: [],
                                         venue: outrightMatch.venue,
                                         sport: nil,
                                         numberOutrightMarkets: numberOutrightMarkets,
                                         competitionInfo: competitionInfo)

        self.competitionsSubject.value.append(newCompetition)

    }

}

extension TopCompetitionDetailsViewModel {
    func matchLineTableCellViewModel(forMatch match: Match) -> MatchLineTableCellViewModel {
        if let matchLineTableCellViewModel = self.matchLineTableCellViewModelCache[match.id] {
            return matchLineTableCellViewModel
        }
        else {
            let matchLineTableCellViewModel = MatchLineTableCellViewModel(match: match)
            self.matchLineTableCellViewModelCache[match.id] = matchLineTableCellViewModel
            return matchLineTableCellViewModel
        }
    }
}

extension TopCompetitionDetailsViewModel {

    func shouldShowOutrightMarkets(forSection section: Int) -> Bool {
        return self.competitions[safe: section]?.numberOutrightMarkets ?? 0 > 0
    }

    func numberOfSection() -> Int {
        return self.competitions.count
    }

    func numberOfItems(forSection section: Int) -> Int {
        guard let competition = self.competitions[safe: section] else {
            return 0
        }

        if self.shouldShowOutrightMarkets(forSection: section) {
            return competition.matches.count + 1
        }
        else {
            return competition.matches.count
        }
    }

    func competitionForSection(forSection section: Int) -> Competition? {
        return self.competitions[safe: section]
    }

    func contentType(forIndexPath indexPath: IndexPath) -> ContentType? {

        guard let competition = self.competitions[safe: indexPath.section] else {
            return nil
        }

        if shouldShowOutrightMarkets(forSection: indexPath.section) {
            if indexPath.row == 0 {
                return ContentType.outrightMarket(competition)
            }
            else if let match = competition.matches[safe: indexPath.row - 1] {
                return ContentType.match(match)
            }
        }
        else if let match = competition.matches[safe: indexPath.row] {
            return ContentType.match(match)
        }

        return nil
    }

}
