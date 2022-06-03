//
//  CompetitionDetailsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/03/2022.
//

import Foundation
import Combine
import OrderedCollections

class CompetitionDetailsViewModel {

    enum ContentType {
        case outrightMarket(Competition)
        case match(Match)
    }

    var store: AggregatorsRepository

    var refreshPublisher = PassthroughSubject<Void, Never>.init()

    var isLoadingCompetitions: CurrentValueSubject<Bool, Never> = .init(true)

    private var competitionsMatchesPublisher: AnyCancellable?
    private var competitionsMatchesRegister: EndpointPublisherIdentifiable?

    private var competitionsPublisher: AnyCancellable?
    private var competitionsRegister: EndpointPublisherIdentifiable?

    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    private var sport: Sport
    private var competitionsIds: [String]
    private var loadedCompetitions: [Competition] = []

    private var cancellables: Set<AnyCancellable> = []

    init(competitionsIds: [String], sport: Sport, store: AggregatorsRepository) {
        self.store = store
        self.sport = sport
        self.competitionsIds = competitionsIds

        self.refresh()
    }

    func refresh() {

        self.isLoadingCompetitions.send(true)

        self.fetchLocations()
            .sink { [weak self] locations in
                self?.store.storeLocations(locations: locations)
                self?.fetchCompetitions()
            }
            .store(in: &cancellables)
    }

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

    func fetchLocations() -> AnyPublisher<[EveryMatrix.Location], Never> {

        let router = TSRouter.getLocations(language: "en", sortByPopularity: false)
        return Env.everyMatrixClient.manager.getModel(router: router, decodingType: EveryMatrixSocketResponse<EveryMatrix.Location>.self)
            .map(\.records)
            .compactMap({$0})
            .replaceError(with: [EveryMatrix.Location]())
            .eraseToAnyPublisher()

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

    func fetchCompetitions() {

        let language = "en"
        let sportId = self.sport.id

        if let competitionsRegister = competitionsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: competitionsRegister)
        }

        self.competitionsPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(TSRouter.tournamentsPublisher(operatorId: Env.appSession.operatorId,
                                                              language: language,
                                                              sportId: sportId),
                      decodingType: EveryMatrixSocketResponse<EveryMatrix.Tournament>.self)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                    self?.isLoadingCompetitions.send(false)
                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    self?.competitionsRegister = publisherIdentifiable
                case .initialContent(let initialDumpContent):
                    self?.storeCompetitions(initialDumpContent.records ?? [] )
                case .updatedContent:
                    ()
                case .disconnect:
                    ()
                }
            })
    }

    func storeCompetitions(_ competitions: [EveryMatrix.Tournament] ) {
        if let competitionsRegister = competitionsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: competitionsRegister)
        }
        self.competitionsPublisher?.cancel()

        self.store.storeTournaments(tournaments: competitions)

        self.fetchCompetitionsMatchesWithIds(self.competitionsIds)
    }

    func fetchCompetitionsMatchesWithIds(_ ids: [String]) {

        if let competitionsMatchesRegister = competitionsMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: competitionsMatchesRegister)
        }

        let endpoint = TSRouter.competitionsMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                             language: "en",
                                                             sportId: self.sport.id,
                                                             events: ids)

        self.competitionsMatchesPublisher?.cancel()
        self.competitionsMatchesPublisher = nil

        self.competitionsMatchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
                self?.isLoadingCompetitions.send(false)
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    self?.competitionsMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    self?.storeCompetitionsAggregatorProcessor(aggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    self?.updateCompetitionsAggregatorProcessor(aggregator: aggregatorUpdates)
                case .disconnect:
                    ()
                }
            })
    }

    private func storeCompetitionsAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {

        self.store.processAggregator(aggregator, withListType: .competitions, shouldClear: true)

        let appMatches = self.store.matchesForListType(.competitions)

        var competitionsMatches = OrderedDictionary<String, [Match]>()
        for match in appMatches {
            if let matchesForId = competitionsMatches[match.competitionId] {
                var newMatchesForId = matchesForId
                newMatchesForId.append(match)
                competitionsMatches[match.competitionId] = newMatchesForId
            }
            else {
                competitionsMatches[match.competitionId] = [match]
            }
        }

        var processedCompetitions: [Competition] = []
        for competitionId in competitionsMatches.keys {
            if let rawCompetition = self.store.tournaments[competitionId] {

                var location: Location?
                if let rawLocation = self.store.location(forId: rawCompetition.venueId ?? "") {
                    location = Location(id: rawLocation.id,
                                    name: rawLocation.name ?? "",
                                    isoCode: rawLocation.code ?? "")
                }

                let competition = Competition(id: competitionId,
                                              name: rawCompetition.name ?? "",
                                              matches: (competitionsMatches[competitionId] ?? []),
                                              venue: location,
                                              outrightMarkets: rawCompetition.numberOfOutrightMarkets ?? 0)
                processedCompetitions.append(competition)
            }
        }
        
        if processedCompetitions.isEmpty {
                  for competitionId in self.competitionsIds {
                      if let rawCompetition = self.store.tournaments[competitionId] {

                          var location: Location?
                          if let rawLocation = self.store.location(forId: rawCompetition.venueId ?? "") {
                              location = Location(id: rawLocation.id,
                                              name: rawLocation.name ?? "",
                                              isoCode: rawLocation.code ?? "")
                          }

                          let competition = Competition(id: competitionId,
                                                        name: rawCompetition.name ?? "",
                                                        matches: (competitionsMatches[competitionId] ?? []),
                                                        venue: location,
                                                        outrightMarkets: rawCompetition.numberOfOutrightMarkets ?? 0)
                          processedCompetitions.append(competition)
                      }
                  }
              }

        if processedCompetitions.isEmpty {
            for competitionId in self.competitionsIds {
                if let rawCompetition = self.store.tournaments[competitionId] {

                    var location: Location?
                    if let rawLocation = self.store.location(forId: rawCompetition.venueId ?? "") {
                        location = Location(id: rawLocation.id,
                                        name: rawLocation.name ?? "",
                                        isoCode: rawLocation.code ?? "")
                    }

                    let competition = Competition(id: competitionId,
                                                  name: rawCompetition.name ?? "",
                                                  matches: (competitionsMatches[competitionId] ?? []),
                                                  venue: location,
                                                  outrightMarkets: rawCompetition.numberOfOutrightMarkets ?? 0)
                    processedCompetitions.append(competition)
                }
            }
        }

        self.loadedCompetitions = processedCompetitions

        self.isLoadingCompetitions.send(false)

        self.refreshPublisher.send()
    }

    private func updateCompetitionsAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        self.store.processContentUpdateAggregator(aggregator)
    }

}

extension CompetitionDetailsViewModel {

    func isMatchLive(withMatchId matchId: String) -> Bool {
        return self.store.hasMatchesInfoForMatch(withId: matchId)
    }

}

extension CompetitionDetailsViewModel {

    func shouldShowOutrightMarkets(forSection section: Int) -> Bool {
        return self.loadedCompetitions[safe: section]?.outrightMarkets ?? 0 > 0
    }

    func numberOfSection() -> Int {
        return self.loadedCompetitions.count
    }

    func numberOfItems(forSection section: Int) -> Int {
        guard let competition = self.loadedCompetitions[safe: section] else {
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
        return self.loadedCompetitions[safe: section]
    }

    func contentType(forIndexPath indexPath: IndexPath) -> ContentType? {

        guard let competition = self.loadedCompetitions[safe: indexPath.section] else {
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
