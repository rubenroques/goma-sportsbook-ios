//
//  FavoritesManager.swift
//  Sportsbook
//
//  Created by André Lascas on 04/11/2021.
//

import Foundation
import Combine

class FavoritesManager {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var favoriteEventsIdPublisher: CurrentValueSubject<[String], Never>

    // MARK: Lifetime and cycle
    init(eventsId: [String] = []) {
        self.favoriteEventsIdPublisher = .init(eventsId)

    }

    // MARK: Functions
    func getUserFavorites() {
        Env.everyMatrixClient.getUserMetadata()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink { _ in
            } receiveValue: { [weak self] userMetadata in
                if let userMetadataRecords = userMetadata.records[0].value {
                    self?.favoriteEventsIdPublisher.send(userMetadataRecords)
                }
            }
            .store(in: &cancellables)
    }

    private func postUserFavorites(favoriteEvents: [String], favoriteTypeChanged: FavoriteType, eventId: String, favoriteAction: FavoriteAction) {

        Env.everyMatrixClient.postUserMetadata(favoriteEvents: favoriteEvents)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink { _ in
            } receiveValue: { [weak self] _ in

                if favoriteAction == .add {
                    self?.postFavoritesToGoma(eventId: eventId, favoriteType: favoriteTypeChanged)
                }
                else if favoriteAction == .remove {
                    self?.deleteFavoriteFromGoma(eventId: eventId)
                }
            }
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
            }, receiveValue: { response in
                print("ADD FAV GOMA: \(response)")
            })
            .store(in: &cancellables)
    }

    private func deleteFavoriteFromGoma(eventId: String) {

        Env.gomaNetworkClient.removeFavorite(deviceId: Env.deviceId, favorite: eventId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { response in
                print("DELETE FAV GOMA: \(response)")
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

        self.postUserFavorites(favoriteEvents: favoriteEventsId, favoriteTypeChanged: favoriteType, eventId: eventId, favoriteAction: .add)
    }

    func removeFavorite(eventId: String, favoriteType: FavoriteType) {
        var favoriteEventsId = self.favoriteEventsIdPublisher.value
        
        for favoriteEventId in favoriteEventsId where eventId == favoriteEventId {

            favoriteEventsId = favoriteEventsId.filter {$0 != eventId}

            self.favoriteEventsIdPublisher.send(favoriteEventsId)
        }

        self.postUserFavorites(favoriteEvents: favoriteEventsId, favoriteTypeChanged: favoriteType, eventId: eventId, favoriteAction: .remove)
    }

    func isEventFavorite(eventId: String) -> Bool {
         return self.favoriteEventsIdPublisher.value.contains(eventId)
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
