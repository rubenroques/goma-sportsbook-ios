//
//  MyFavoritesViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 10/02/2022.
//

import Foundation
import Combine
import UIKit
import OrderedCollections

class MyFavoritesViewModel: NSObject {

    private var favoriteMatches: [Match] = []
    private var favoriteCompetitions: [Competition] = []

    private var favoriteMatchesRegister: EndpointPublisherIdentifiable?
    private var favoriteCompetitionsMatchesRegister: EndpointPublisherIdentifiable?
    private var favoriteMatchesPublisher: AnyCancellable?
    private var favoriteCompetitionsMatchesPublisher: AnyCancellable?

    private var cancellables = Set<AnyCancellable>()
    var dataChangedPublisher = PassthroughSubject<Void, Never>.init()
    var didSelectMatchAction: ((Match, UIImage?) -> Void)?

    var favoriteListTypePublisher: CurrentValueSubject<FavoriteListType, Never> = .init(.favoriteGames)

    enum FavoriteListType {
        case favoriteGames
        case favoriteCompetitions
    }

    // Caches
    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    // Data Sources
    private var myFavoriteMatchesDataSource = MyFavoriteMatchesDataSource(userFavoriteMatches: [])
    private var myFavoriteCompetitionsDataSource = MyFavoriteCompetitionsDataSource(favoriteCompetitions: [])

    // Favorites Repository
    private var favoritesRepository: FavoritesAggregatorsRepository = FavoritesAggregatorsRepository()

    override init() {
        super.init()

        self.myFavoriteMatchesDataSource.matchStatsViewModelForMatch = { [weak self] match in
            return self?.matchStatsViewModel(forMatch: match)
        }

        self.myFavoriteCompetitionsDataSource.matchStatsViewModelForMatch = { [weak self] match in
            return self?.matchStatsViewModel(forMatch: match)
        }

        // Match Select
        self.myFavoriteMatchesDataSource.didSelectMatchAction = { [weak self] match, image in
            self?.didSelectMatchAction?(match, image)
        }
        self.myFavoriteCompetitionsDataSource.didSelectMatchAction = { [weak self] match, image in
            self?.didSelectMatchAction?(match, image)
        }

        // Match went live
        // Did Select a Match
        //
        self.myFavoriteMatchesDataSource.matchWentLiveAction = { [weak self] in
            self?.dataChangedPublisher.send()
        }
        self.myFavoriteCompetitionsDataSource.matchWentLiveAction = { [weak self] in
            self?.dataChangedPublisher.send()
        }

        self.setupPublishers()

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

    func setFavoriteListType(_ favoriteListType: FavoriteListType) {
        self.favoriteListTypePublisher.send(favoriteListType)
        self.updateContentList()
    }

    private func setupPublishers() {
        Env.favoritesManager.favoriteEventsIdPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] favoriteEvents in
                self?.fetchFavoriteMatches()
                self?.fetchFavoriteCompetitionsMatchesWithIds(favoriteEvents)
            })
            .store(in: &cancellables)
    }

    private func fetchFavoriteMatches() {

        if let favoriteMatchesRegister = favoriteMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: favoriteMatchesRegister)
        }

        guard let userId = Env.userSessionStore.userSessionPublisher.value?.userId else { return }

        let endpoint = TSRouter.favoriteMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                      language: "en",
                                                      userId: userId)

        self.favoriteMatchesPublisher?.cancel()
        self.favoriteMatchesPublisher = nil

        self.favoriteMatchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.FavoritesAggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving Favorite data!")

                case .finished:
                    print("Favorite Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("PreLiveEventsViewModel favoriteMatchesPublisher connect")
                    self?.favoriteMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("PreLiveEventsViewModel favoriteMatchesPublisher initialContent")
                    self?.setupFavoriteMatchesAggregatorProcessor(aggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    print("PreLiveEventsViewModel favoriteMatchesPublisher updatedContent")
                    //self?.updateFavoriteMatchesAggregatorProcessor(aggregator: aggregatorUpdates)
                case .disconnect:
                    print("PreLiveEventsViewModel favoriteMatchesPublisher disconnect")
                }

            })
    }

    private func setupFavoriteMatchesAggregatorProcessor(aggregator: EveryMatrix.FavoritesAggregator) {
        // Env.everyMatrixStorage.processAggregator(aggregator, withListType: .favoriteMatchEvents, shouldClear: true)
        self.favoritesRepository.processAggregator(aggregator, withListType: .favoriteMatchEvents, shouldClear: true)

        self.favoriteMatches = self.favoritesRepository.matchesForListType(.favoriteMatchEvents)

        self.updateContentList()
    }

    func fetchFavoriteCompetitionsMatchesWithIds(_ ids: [String]) {

        if let favoriteCompetitionsMatchesRegister = favoriteCompetitionsMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: favoriteCompetitionsMatchesRegister)
        }

        let endpoint = TSRouter.competitionsMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                             language: "en", sportId: "",
                                                             events: ids)

        self.favoriteCompetitionsMatchesPublisher?.cancel()
        self.favoriteCompetitionsMatchesPublisher = nil

        self.favoriteCompetitionsMatchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.FavoritesAggregator.self)
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
                    print("PreLiveEventsViewModel favoriteCompetitionsMatchesPublisher connect")
                    self?.favoriteCompetitionsMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("PreLiveEventsViewModel favoriteCompetitionsMatchesPublisher initialContent")
                    self?.setupFavoriteCompetitionsAggregatorProcessor(aggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    //self?.updateFavoriteCompetitionsAggregatorProcessor(aggregator: aggregatorUpdates)
                    print("PreLiveEventsViewModel favoriteCompetitionsMatchesPublisher updatedContent")
                case .disconnect:
                    print("PreLiveEventsViewModel favoriteCompetitionsMatchesPublisher disconnect")
                }
            })
    }

    private func setupFavoriteCompetitionsAggregatorProcessor(aggregator: EveryMatrix.FavoritesAggregator) {
        //Env.everyMatrixStorage.processAggregator(aggregator, withListType: .favoriteCompetitionEvents, shouldClear: true)

        self.favoritesRepository.processAggregator(aggregator, withListType: .favoriteCompetitionEvents, shouldClear: true)

        let appMatches = self.favoritesRepository.matchesForListType(.favoriteCompetitionEvents)

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
            if let tournament = self.favoritesRepository.tournaments[competitionId] {

                var location: Location?
                if let rawLocation = self.favoritesRepository.location(forId: tournament.venueId ?? "") {
                    location = Location(id: rawLocation.id,
                                        name: rawLocation.name ?? "",
                                        isoCode: rawLocation.code ?? "")
                }

                let competition = Competition(id: competitionId,
                                              name: tournament.name ?? "",
                                              matches: (competitionsMatches[competitionId] ?? []),
                                              venue: location)
                processedCompetitions.append(competition)

            }
        }

        self.favoriteCompetitions = processedCompetitions

        self.updateContentList()
    }

    private func updateContentList() {

        //self.myFavoriteMatchesDataSource.userFavoriteMatches = self.favoriteMatches
        self.myFavoriteMatchesDataSource.setupMatchesBySport(favoriteMatches: self.favoriteMatches)
        self.myFavoriteCompetitionsDataSource.competitions = self.favoriteCompetitions

        self.dataChangedPublisher.send()
    }
}

extension MyFavoritesViewModel: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.favoriteListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.numberOfSections(in: tableView)
        case .favoriteCompetitions:
            return self.myFavoriteCompetitionsDataSource.numberOfSections(in: tableView)
        }
    }

    func hasContentForSelectedListType() -> Bool {
       switch self.favoriteListTypePublisher.value {
       case .favoriteGames:
           return self.myFavoriteMatchesDataSource.userFavoriteMatches.isNotEmpty
       case .favoriteCompetitions:
          return self.myFavoriteCompetitionsDataSource.competitions.isNotEmpty
       }
   }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.favoriteListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .favoriteCompetitions:
            return self.myFavoriteCompetitionsDataSource.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch self.favoriteListTypePublisher.value {
        case .favoriteGames:
            cell = self.myFavoriteMatchesDataSource.tableView(tableView, cellForRowAt: indexPath)
        case .favoriteCompetitions:
            cell = self.myFavoriteCompetitionsDataSource.tableView(tableView, cellForRowAt: indexPath)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch self.favoriteListTypePublisher.value {
        case .favoriteGames:
            ()
        case .favoriteCompetitions:
            ()
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch self.favoriteListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .favoriteCompetitions:
            return self.myFavoriteCompetitionsDataSource.tableView(tableView, viewForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.favoriteListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .favoriteCompetitions:
            return self.myFavoriteCompetitionsDataSource.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.favoriteListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .favoriteCompetitions:
            return self.myFavoriteCompetitionsDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch self.favoriteListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .favoriteCompetitions:
            return self.myFavoriteCompetitionsDataSource.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        switch self.favoriteListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .favoriteCompetitions:
            return self.myFavoriteCompetitionsDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}
