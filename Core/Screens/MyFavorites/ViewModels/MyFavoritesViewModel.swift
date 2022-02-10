//
//  MyFavoritesViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 10/02/2022.
//

import Foundation
import Combine
import UIKit

class MyFavoritesViewModel: NSObject {

    private var favoriteMatches: [Match] = []

    private var favoriteMatchesRegister: EndpointPublisherIdentifiable?
    private var favoriteMatchesPublisher: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    var dataChangedPublisher = PassthroughSubject<Void, Never>.init()

    var matchListTypePublisher: CurrentValueSubject<MatchListType, Never> = .init(.favoriteGames)
    enum MatchListType {
        case favoriteGames
        //case favoriteCompetitions
    }

    // Data Sources
    private var myFavoriteMatchesDataSource = MyFavoriteMatchesDataSource(userFavoriteMatches: [])

    override init() {
        super.init()

        self.setupPublishers()
        self.fetchFavoriteMatches()
    }

    private func setupPublishers() {
        Env.favoritesManager.favoriteEventsIdPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] favoriteEvents in
                self?.fetchFavoriteMatches()
                //self?.fetchFavoriteCompetitionsMatchesWithIds(favoriteEvents)
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
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
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

    private func setupFavoriteMatchesAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processAggregator(aggregator, withListType: .favoriteMatchEvents,
                                                 shouldClear: true)
        self.favoriteMatches = Env.everyMatrixStorage.matchesForListType(.favoriteMatchEvents)

        self.updateContentList()
    }

    private func updateContentList() {

        //self.myFavoriteMatchesDataSource.userFavoriteMatches = self.favoriteMatches
        self.myFavoriteMatchesDataSource.setupMatchesBySport(favoriteMatches: self.favoriteMatches)
        // self.favoriteCompetitionsDataSource.competitions = self.favoriteCompetitions

        self.dataChangedPublisher.send()
    }
}

extension MyFavoritesViewModel: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.matchListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.numberOfSections(in: tableView)
//        case .favoriteCompetitions:
//            return self.favoriteCompetitionsDataSource.numberOfSections(in: tableView)
        }
    }

    func hasContentForSelectedListType() -> Bool {
       switch self.matchListTypePublisher.value {
       case .favoriteGames:
           return self.myFavoriteMatchesDataSource.userFavoriteMatches.isNotEmpty
//       case .favoriteCompetitions:
//          return self.favoriteCompetitionsDataSource.competitions.isNotEmpty
       }
   }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.matchListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.tableView(tableView, numberOfRowsInSection: section)
//        case .favoriteCompetitions:
//            return self.favoriteCompetitionsDataSource.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch self.matchListTypePublisher.value {
        case .favoriteGames:
            cell = self.myFavoriteMatchesDataSource.tableView(tableView, cellForRowAt: indexPath)
//        case .favoriteCompetitions:
//            cell = self.favoriteCompetitionsDataSource.tableView(tableView, cellForRowAt: indexPath)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch self.matchListTypePublisher.value {
        case .favoriteGames:
            ()
//        case .favoriteCompetitions:
//            ()
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch self.matchListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.tableView(tableView, viewForHeaderInSection: section)
//        case .favoriteCompetitions:
//            return self.favoriteCompetitionsDataSource.tableView(tableView, viewForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.tableView(tableView, heightForRowAt: indexPath)
//        case .favoriteCompetitions:
//            return self.favoriteCompetitionsDataSource.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
//        case .favoriteCompetitions:
//            return self.favoriteCompetitionsDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.tableView(tableView, heightForHeaderInSection: section)
//        case .favoriteCompetitions:
//            return self.favoriteCompetitionsDataSource.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .favoriteGames:
            return self.myFavoriteMatchesDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
//        case .favoriteCompetitions:
//            return self.favoriteCompetitionsDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}
