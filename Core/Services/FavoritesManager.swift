//
//  FavoritesManager.swift
//  Sportsbook
//
//  Created by André Lascas on 04/11/2021.
//

import Foundation
import Combine

class FavoritesManager {

    var favoriteEventsIdPublisher: CurrentValueSubject<[String], Never>
    var favoriteEventsWithTypePublisher: CurrentValueSubject<[Event], Never>
    var requestGomaFavoritesEndpointsPublisher: CurrentValueSubject<Bool, Never>
    var cancellables = Set<AnyCancellable>()
    var favoriteIdToRemove: String = ""
    var favoriteTypeCheckPublisher: CurrentValueSubject<FavoriteType, Never> = .init(.none)

    init(eventsId: [String] = []) {
        self.favoriteEventsIdPublisher = .init(eventsId)
        self.favoriteEventsWithTypePublisher = .init([])
        self.requestGomaFavoritesEndpointsPublisher = .init(false)
        self.favoriteEventsIdPublisher
            .filter(\.isNotEmpty)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { value in
                self.getEvents(events: value)
            })
            .store(in: &cancellables)

        Publishers.CombineLatest(self.favoriteEventsWithTypePublisher, self.requestGomaFavoritesEndpointsPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] favoriteEvents, postGoma in
                if postGoma && (favoriteEvents.count == self?.favoriteEventsIdPublisher.value.count) && self?.favoriteIdToRemove == "" {
                    self?.postFavoritesToGoma()
                    self?.requestGomaFavoritesEndpointsPublisher.send(false)
                }
                else if postGoma && (favoriteEvents.count == self?.favoriteEventsIdPublisher.value.count) && self?.favoriteIdToRemove != "" {
                    self?.deleteFavoriteFromGoma()
                    self?.requestGomaFavoritesEndpointsPublisher.send(false)
                    self?.favoriteIdToRemove = ""
                }
            })
            .store(in: &cancellables)
    }

    func getEvents(events: [String]) {
        Env.everyMatrixClient.getEvents(payload: ["lang": "en",
                                                     "eventIds": events,
                                                     "dataWithoutOdds": true])
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in

            }, receiveValue: { value in
                if let eventValues = value.records {
                    self.favoriteEventsWithTypePublisher.send(eventValues)
                }
            })
            .store(in: &cancellables)
    }

    func getUserMetadata() {
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

    private func postUserMetadata(favoriteEvents: [String], favoriteTypeChanged: FavoriteType) {
        Env.everyMatrixClient.postUserMetadata(favoriteEvents: favoriteEvents)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink { _ in
            } receiveValue: { _ in
                if favoriteTypeChanged == .match {
                    self.favoriteTypeCheckPublisher.send(.match)
                }
                else if favoriteTypeChanged == .competition {
                    self.favoriteTypeCheckPublisher.send(.competition)
                }
                self.requestGomaFavoritesEndpointsPublisher.send(true)
            }
            .store(in: &cancellables)
    }

    private func postFavoritesToGoma() {
        var gomaFavorites: String = ""

        for (index, favorite) in self.favoriteEventsWithTypePublisher.value.enumerated() {

            switch favorite {
            case .match(let match):
                let favoriteGoma = FavoriteGoma(favoriteId: match.id, type: "event")
                if index == self.favoriteEventsWithTypePublisher.value.endIndex-1 {
                    gomaFavorites += """
                    {
                    "favorite_id": \(favoriteGoma.favoriteId),\n "type": "\(favoriteGoma.type)"
                    }\n
                    """
                }
                else {
                    gomaFavorites += """
                    {
                    "favorite_id": \(favoriteGoma.favoriteId),\n "type": "\(favoriteGoma.type)"
                    },\n
                    """
                }

            case .tournament(let tournament):
                let favoriteGoma = FavoriteGoma(favoriteId: tournament.id, type: "competition")
                if index == self.favoriteEventsWithTypePublisher.value.endIndex-1 {
                    gomaFavorites += """
                    {
                    "favorite_id": \(favoriteGoma.favoriteId),\n "type": "\(favoriteGoma.type)"
                    }\n
                    """
                }
                else {
                    gomaFavorites += """
                    {
                    "favorite_id": \(favoriteGoma.favoriteId),\n "type": "\(favoriteGoma.type)"
                    },\n
                    """
                }
            default:
                break
            }

        }

        Env.gomaNetworkClient.addFavorites(deviceId: Env.deviceId, favorites: gomaFavorites)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { response in
                print("ADD FAV GOMA: \(response)")
            })
            .store(in: &cancellables)

    }

    private func deleteFavoriteFromGoma() {
        let favorite = self.favoriteIdToRemove
        Env.gomaNetworkClient.removeFavorite(deviceId: Env.deviceId, favorite: favorite)
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

    // TODO: Code Review - Isto ficou por corrigir, o check faz tudo, e não pode, tem que haver um addFavorite, um removeFavorite e é isso. O postUserMetadata tem que ser private, não pode ser chamado fora do manager. UPDATE: Corrigido

    func addFavorite(eventId: String, favoriteType: FavoriteType) {
        var favoriteEventsId = self.favoriteEventsIdPublisher.value
        favoriteEventsId.append(eventId)
        self.favoriteEventsIdPublisher.send(favoriteEventsId)

        self.postUserMetadata(favoriteEvents: favoriteEventsId, favoriteTypeChanged: favoriteType)

    }

    func removeFavorite(eventId: String, favoriteType: FavoriteType) {
        var favoriteEventsId = self.favoriteEventsIdPublisher.value
        
        for favoriteEventId in favoriteEventsId where eventId == favoriteEventId {

            favoriteEventsId = favoriteEventsId.filter {$0 != eventId}

            self.favoriteEventsIdPublisher.send(favoriteEventsId)
        }

        self.favoriteIdToRemove = eventId

        self.postUserMetadata(favoriteEvents: favoriteEventsId, favoriteTypeChanged: favoriteType)

    }

}

enum FavoriteType {
    case match
    case competition
    case none
}
