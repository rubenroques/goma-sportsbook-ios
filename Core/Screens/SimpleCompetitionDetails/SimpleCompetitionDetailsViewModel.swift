//
//  SimpleCompetitionDetailsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/03/2024.
//

import Foundation
import Combine
import OrderedCollections
import ServicesProvider

class SimpleCompetitionDetailsViewModel {

    enum ContentType {
        case outrightMarket(Competition)
        case match(Match)
    }

    var refreshPublisher: AnyPublisher<Void, Never> {
        let changedArrayPublisher = self.competitionSubject
            .removeDuplicates()
            .map { _ in }
            .eraseToAnyPublisher()

        return Publishers.Merge(changedArrayPublisher, self.forcedRefreshPassthroughSubject)
            .map({ _ in })
            .eraseToAnyPublisher()
    }

    var competition: Competition? {
        return self.competitionSubject.value
    }
    var competitionSubject: CurrentValueSubject<Competition?, Never> = .init(nil)

    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        return self.isLoadingCurrentValueSubject.eraseToAnyPublisher()
    }

    private var sport: Sport
    private var competitionId: String

    private var forcedRefreshPassthroughSubject: PassthroughSubject<Void, Never> = .init()
    private var competitionMatchesSubscription: ServicesProvider.Subscription?

    private var isLoadingCurrentValueSubject: CurrentValueSubject<Bool, Never> = .init(false)
    private var activeNetworkRequestCount = 0 {
        didSet {
            print("CompetitionsDataSource activeNetworkRequestCount: \(self.activeNetworkRequestCount)")
            self.isLoadingCurrentValueSubject.send(activeNetworkRequestCount > 0)
        }
    }

    private var matchLineTableCellViewModelCache: [String: MatchLineTableCellViewModel] = [:]

    private var cancellables: Set<AnyCancellable> = []

    init(competitionId: String, sport: Sport) {
        self.sport = sport
        self.competitionId = competitionId

        self.refresh()
    }

    func refresh() {
        self.fetchCompetitionMatches(self.competitionId)
    }

    private func fetchCompetitionMatches(_ competitionId: String) {
        self.activeNetworkRequestCount += 1

        Env.servicesProvider.getCompetitionMarketGroups(competitionId: competitionId)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("SimpleCompetitionDetailsViewModel fetchCompetitionMatches - Finished")
                case .failure(let error):
                    print("SimpleCompetitionDetailsViewModel fetchCompetitionMatches - Error: \(error)")
                }
                self?.activeNetworkRequestCount -= 1
            } receiveValue: { [weak self] competitionInfo in
                self?.processCompetitionInfo(competitionInfo)
            }
            .store(in: &self.cancellables)
    }

    private func processCompetitionInfo(_ competitionInfo: SportCompetitionInfo) {
        if let marketGroup = competitionInfo.marketGroups.filter({ $0.name.lowercased().contains("main") }).first {
            self.subscribeCompetitionMatches(forMarketGroupId: marketGroup.id, competitionInfo: competitionInfo)
        }
        else if let marketGroup = competitionInfo.marketGroups.filter({ $0.name.lowercased().contains("outright") }).first {
            self.subscribeCompetitionOutright(forMarketGroupId: marketGroup.id, competitionInfo: competitionInfo)
        }
    }

    private func subscribeCompetitionMatches(forMarketGroupId marketGroupId: String, competitionInfo: SportCompetitionInfo) {
        self.activeNetworkRequestCount += 1

        Env.servicesProvider.subscribeCompetitionMatches(forMarketGroupId: marketGroupId)
        .sink { [weak self] completion  in
            switch completion {
            case .finished:
                print("SimpleCompetitionDetailsViewModel subscribeCompetitionMatches - completed")
            case .failure(let error):
                print("SimpleCompetitionDetailsViewModel subscribeCompetitionMatches - completed with error \(error)")
            }
            self?.activeNetworkRequestCount -= 1
        } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
            switch subscribableContent {
            case .connected(let subscription):
                self?.competitionMatchesSubscription = subscription
            case .contentUpdate(let eventsGroups):
                let matches = ServiceProviderModelMapper.matches(fromEventsGroups: eventsGroups)
                self?.processCompetitionMatches(matches: matches, competitionInfo: competitionInfo)
                self?.activeNetworkRequestCount -= 1
            case .disconnected:
                self?.competitionMatchesSubscription = nil
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

        self.competitionSubject.send(newCompetition)
    }

    private func subscribeCompetitionOutright(forMarketGroupId marketGroupId: String, competitionInfo: SportCompetitionInfo) {
        self.activeNetworkRequestCount += 1

        Env.servicesProvider.subscribeCompetitionMatches(forMarketGroupId: marketGroupId)
        .sink { [weak self] completion in
            switch completion {
            case .finished:
                print("SimpleCompetitionDetailsViewModel subscribeCompetitionOutright - completed")
            case .failure(let error):
                print("SimpleCompetitionDetailsViewModel subscribeCompetitionOutright - completed with error \(error)")
            }
            self?.activeNetworkRequestCount -= 1
        } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
            switch subscribableContent {
            case .connected(let subscription):
                self?.competitionMatchesSubscription = subscription
            case .contentUpdate(let eventsGroups):
                if let outrightCompetition = ServiceProviderModelMapper.competitions(fromEventsGroups: eventsGroups).first {
                    self?.processCompetitionOutrights(outrightCompetition: outrightCompetition, competitionInfo: competitionInfo)
                }
                self?.activeNetworkRequestCount -= 1
            case .disconnected:
                self?.competitionMatchesSubscription = nil
            }
        }
        .store(in: &cancellables)
    }

    private func processCompetitionOutrights(outrightCompetition: Competition, competitionInfo: SportCompetitionInfo) {
        let numberOutrightMarkets = competitionInfo.numberOutrightMarkets == "0" ? 1 : Int(competitionInfo.numberOutrightMarkets) ?? 0
        let newCompetition = Competition(id: competitionInfo.id,
                                         name: competitionInfo.name,
                                         matches: [],
                                         venue: outrightCompetition.venue,
                                         sport: nil,
                                         numberOutrightMarkets: numberOutrightMarkets,
                                         competitionInfo: competitionInfo)
        self.competitionSubject.send(newCompetition)
    }
    
}

extension SimpleCompetitionDetailsViewModel {
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

extension SimpleCompetitionDetailsViewModel {
    func shouldShowOutrightMarkets() -> Bool {
        return self.competition?.numberOutrightMarkets ?? 0 > 0
    }

    func numberOfItems() -> Int {
        guard let competition = self.competition else {
            return 0
        }

        if self.shouldShowOutrightMarkets() {
            return competition.matches.count + 1
        }
        else {
            return competition.matches.count
        }
    }

    func contentType(forIndexPath indexPath: IndexPath) -> ContentType? {
        guard let competition = self.competition else {
            return nil
        }

        if shouldShowOutrightMarkets() {
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
