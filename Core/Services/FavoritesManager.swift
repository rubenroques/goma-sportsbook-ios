//
//  FavoritesManager.swift
//  Sportsbook
//
//  Created by André Lascas on 04/11/2021.
//

import Foundation
import Combine
import ServicesProvider

class FavoritesManager {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var favoriteEventsIdPublisher: CurrentValueSubject<[String], Never>

    var favoriteMatchesIdPublisher: CurrentValueSubject<[String], Never> = .init([])
    var favoriteCompetitionsIdPublisher: CurrentValueSubject<[String], Never> = .init([])

    var finishedCompetitionsIds: CurrentValueSubject<Bool, Never> = .init(false)
    var finishedMatchesIds: CurrentValueSubject<Bool, Never> = .init(false)

    var fetchedFavoriteEventIds: [String] = []
    var fetchedMatchesListIds: [String: Int] = [:]
    var fetchedCompetitionsListsIds: [String: Int] = [:]
    var competitionListId: Int?

    // MARK: Lifetime and cycle
    init(eventsId: [String] = []) {
        self.favoriteEventsIdPublisher = .init(eventsId)

        Publishers.CombineLatest(self.finishedCompetitionsIds, self.finishedMatchesIds)
            .sink(receiveValue: { [weak self] finishedCompetitionsids, finishedMatchesIds in
                guard let self = self else {return}
                if finishedCompetitionsids && finishedMatchesIds {
                    self.favoriteEventsIdPublisher.send(self.fetchedFavoriteEventIds)

                    let fetchedMatches = Array(self.fetchedMatchesListIds.keys)
                    let fetchedCompetitions = Array(self.fetchedCompetitionsListsIds.keys)

                    self.favoriteMatchesIdPublisher.send(fetchedMatches)
                    self.favoriteCompetitionsIdPublisher.send(fetchedCompetitions)
                }
            })
            .store(in: &cancellables)

    }

    // MARK: Functions
    func getUserFavorites() {
        self.clearFavoritesData()

        Env.servicesProvider.getFavoritesList()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    switch error {
                    case .userSessionNotFound:
                        self?.getUserFavorites()
                    default: ()
                    }
                }

            }, receiveValue: { [weak self] favoritesListResponse in
                print("FAVORITES LIST: \(favoritesListResponse)")

                if !favoritesListResponse.favoritesList.contains(where: {
                    $0.name == "Competitions"
                }) {
                    self?.createCompetitionsList()
                }
                else {
                    if let competitionListId = favoritesListResponse.favoritesList.first(where: {
                        $0.name == "Competitions"
                    }) {
                        self?.competitionListId = competitionListId.id
                        self?.getCompetitionsIds(competitionListId: competitionListId.id, favoritesList: favoritesListResponse.favoritesList)
                    }
                    self?.processFavoritesLists(favoritesLists: favoritesListResponse.favoritesList)
                }
            })
            .store(in: &cancellables)
    }

    private func getCompetitionsIds(competitionListId: Int, favoritesList: [FavoriteList]) {

        Env.servicesProvider.getFavoritesFromList(listId: competitionListId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("FAVORITE EVENTS ERROR: \(error)")
                    self?.finishedCompetitionsIds.send(true)
                }

            }, receiveValue: { [weak self] favoriteEventsResponse in

                print("FAVORITE EVENTS RESPONSE: \(favoriteEventsResponse)")

                for favoriteEvent in favoriteEventsResponse.favoriteEvents {
                    self?.fetchedFavoriteEventIds.append(favoriteEvent.id)
                    self?.fetchedCompetitionsListsIds[favoriteEvent.id] = favoriteEvent.accountFavoriteId
                }

                self?.finishedCompetitionsIds.send(true)

            })
            .store(in: &cancellables)
    }

    private func processFavoritesLists(favoritesLists: [FavoriteList]) {

        var favoriteIds = [String]()

        for favoriteList in favoritesLists {

            if favoriteList.name == "Competitions" || !favoriteList.name.contains("Match") {
                continue
            }

            let favoriteListSplit = favoriteList.name.components(separatedBy: ":")
            
            if let favoriteId = favoriteListSplit[safe: 1]
            {

                if !favoriteIds.contains(favoriteId) {
                    favoriteIds.append(favoriteId)

                    self.fetchedMatchesListIds[favoriteId] = favoriteList.id
                }
            }
        }

        self.fetchedFavoriteEventIds.append(contentsOf: favoriteIds)

        self.finishedMatchesIds.send(true)
    }

    private func createCompetitionsList() {

        Env.servicesProvider.addFavoritesList(name: "Competitions")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("FAVORITES LIST ADD ERROR: \(error)")
                }

            }, receiveValue: { [weak self] favoritesListAddResponse in

                self?.competitionListId = favoritesListAddResponse.listId

                self?.getUserFavorites()

            })
            .store(in: &cancellables)
    }

    private func postUserFavorites(favoriteEvents: [String], favoriteTypeChanged: FavoriteType, eventId: String, favoriteAction: FavoriteAction) {

        if favoriteTypeChanged == .match {

            if favoriteAction == .add {
                Env.servicesProvider.addFavoritesList(name: "Match:\(eventId)")
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { [weak self] completion in
                        switch completion {
                        case .finished:
                            ()
                        case .failure(let error):
                            print("FAVORITES LIST ADD ERROR: \(error)")
                        }

                    }, receiveValue: { [weak self] favoritesListAddResponse in

                        let favoriteListId = favoritesListAddResponse.listId

                        if let defaultEventId = Env.sportsStore.defaultSportWithCodeId.numericId {
                            self?.addFavoriteToList(listId: favoriteListId, eventId: defaultEventId)
                        }

                        self?.fetchedMatchesListIds["Match:\(eventId)"] = favoriteListId

                    })
                    .store(in: &cancellables)
            }
            else if favoriteAction == .remove {

                if let listId = self.fetchedMatchesListIds["Match:\(eventId)"] {
                    Env.servicesProvider.deleteFavoritesList(listId: listId)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { [weak self] completion in
                            switch completion {
                            case .finished:
                                ()
                            case .failure(let error):
                                print("FAVORITES LIST DELETE ERROR: \(error)")

                                if "\(error)" == "emptyData"  {
                                    print("EMPTY DATA SUCCESS")
                                    self?.fetchedMatchesListIds.removeValue(forKey: "Match:\(eventId)")
                                }
                            }

                        }, receiveValue: { [weak self] favoritesListDeleteResponse in

                            self?.fetchedMatchesListIds.removeValue(forKey: "Match:\(eventId)")

                        })
                        .store(in: &cancellables)
                }
            }
        }
        else if favoriteTypeChanged == .competition {

            if favoriteAction == .add {

                if let competitionListId = self.competitionListId {

                    self.addFavoriteToList(listId: competitionListId, eventId: eventId, isCompetitionFavorite: true)
                }
            }
            else if favoriteAction == .remove {

                if let eventListId = self.fetchedCompetitionsListsIds[eventId] {
                    Env.servicesProvider.deleteFavoriteFromList(eventId: eventListId)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { [weak self] completion in
                            switch completion {
                            case .finished:
                                ()
                            case .failure(let error):
                                print("FAVORITE EVENT DELETE ERROR: \(error)")

                                if "\(error)" == "emptyData"  {
                                    print("EMPTY DATA SUCCESS")
                                    self?.fetchedCompetitionsListsIds.removeValue(forKey: eventId)
                                }
                            }
                        }, receiveValue: { [weak self] favoritesListDeleteResponse in

                            self?.fetchedCompetitionsListsIds.removeValue(forKey: eventId)
                        })
                        .store(in: &cancellables)
                }
            }
        }

//        Env.everyMatrixClient.postUserMetadata(favoriteEvents: favoriteEvents)
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//            .sink { _ in
//            } receiveValue: { [weak self] _ in
//
//                if favoriteAction == .add {
//                    self?.postFavoritesToGoma(eventId: eventId, favoriteType: favoriteTypeChanged)
//                }
//                else if favoriteAction == .remove {
//                    self?.deleteFavoriteFromGoma(eventId: eventId)
//                }
//            }
//            .store(in: &cancellables)
    }

    private func addFavoriteToList(listId: Int, eventId: String, isCompetitionFavorite: Bool = false) {

        Env.servicesProvider.addFavoritesToList(listId: listId, eventId: eventId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("FAVORITE ADD ERROR: \(error)")
                }

            }, receiveValue: { [weak self] favoriteAddResponse in

                print("FAVORITE ADD RESPONSE: \(favoriteAddResponse)")

                if isCompetitionFavorite {
                    if var fetchedFavoriteEventIds = self?.fetchedFavoriteEventIds {

                        fetchedFavoriteEventIds.append(eventId)

                        self?.favoriteEventsIdPublisher.send(fetchedFavoriteEventIds)

                    }

                }

            })
            .store(in: &cancellables)
    }

    private func postFavoritesToGoma(eventId: String, favoriteType: FavoriteType) {

        let gomaFavorites = """
        {
        "favorite_id": \(eventId),
        "type": "\(favoriteType.gomaIdentifier)"
        }
        """

        Env.gomaNetworkClient.addFavorites(deviceId: Env.deviceId, favorites: gomaFavorites)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { _ in
            })
            .store(in: &cancellables)
    }

    private func deleteFavoriteFromGoma(eventId: String) {

        Env.gomaNetworkClient.removeFavorite(deviceId: Env.deviceId, favorite: eventId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { _ in
            })
            .store(in: &cancellables)
    }

    func clearCachedFavorites() {
        self.favoriteEventsIdPublisher.send([])
    }

    func addFavorite(eventId: String, favoriteType: FavoriteType) {
        var favoriteEventsId = self.favoriteEventsIdPublisher.value
        favoriteEventsId.append(eventId)
        self.favoriteEventsIdPublisher.send(favoriteEventsId)

        if favoriteType == .match {
            var favoriteMatchesId = self.favoriteMatchesIdPublisher.value
            favoriteMatchesId.append(eventId)
            self.favoriteMatchesIdPublisher.send(favoriteMatchesId)
        }
        else if favoriteType == .competition {
            var favoriteCompetitionsId = self.favoriteCompetitionsIdPublisher.value
            favoriteCompetitionsId.append(eventId)
            self.favoriteCompetitionsIdPublisher.send(favoriteCompetitionsId)
        }

        self.postUserFavorites(favoriteEvents: favoriteEventsId, favoriteTypeChanged: favoriteType, eventId: eventId, favoriteAction: .add)
    }

    func removeFavorite(eventId: String, favoriteType: FavoriteType) {
        var favoriteEventsId = self.favoriteEventsIdPublisher.value
        
        for favoriteEventId in favoriteEventsId where eventId == favoriteEventId {

            favoriteEventsId = favoriteEventsId.filter {$0 != eventId}

            self.favoriteEventsIdPublisher.send(favoriteEventsId)
        }

        if favoriteType == .match {
            var favoriteMatchesId = self.favoriteMatchesIdPublisher.value

            favoriteMatchesId = favoriteMatchesId.filter {$0 != eventId}

            self.favoriteMatchesIdPublisher.send(favoriteMatchesId)
        }
        else if favoriteType == .competition {
            var favoriteCompetitionsId = self.favoriteCompetitionsIdPublisher.value

            favoriteCompetitionsId = favoriteCompetitionsId.filter {$0 != eventId}

            self.favoriteCompetitionsIdPublisher.send(favoriteCompetitionsId)
        }

        self.postUserFavorites(favoriteEvents: favoriteEventsId, favoriteTypeChanged: favoriteType, eventId: eventId, favoriteAction: .remove)
    }

    func isEventFavorite(eventId: String) -> Bool {
         return self.favoriteEventsIdPublisher.value.contains(eventId)
    }

    func clearFavoritesData() {
        self.favoriteEventsIdPublisher.value = []
        self.fetchedMatchesListIds = [:]
        self.fetchedCompetitionsListsIds = [:]
        self.fetchedFavoriteEventIds = []
    }

}

enum FavoriteType {
    case match
    case competition

    var gomaIdentifier: String {
        switch self {
        case .match:
            return "event"
        case .competition:
            return "competition"
        }
    }
}

enum FavoriteAction {
    case add
    case remove
}
