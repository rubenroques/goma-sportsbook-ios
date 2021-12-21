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
    var cancellables = Set<AnyCancellable>()

    init(eventsId: [String] = []) {
        self.favoriteEventsIdPublisher = .init(eventsId)
    }

    func getUserMetadata() {
        Env.everyMatrixAPIClient.getUserMetadata()
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

    func postUserMetadata(favoriteEvents: [String]) {
        Env.everyMatrixAPIClient.postUserMetadata(favoriteEvents: favoriteEvents)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink { _ in
            } receiveValue: { _ in

            }
            .store(in: &cancellables)
    }

    // TODO: Code Review - Isto ficou por corrigir, o check faz tudo, e não pode, tem que haver um addFavorite, um removeFavorite e é isso. O postUserMetadata tem que ser private, não pode ser chamado fora do manager.

    func checkFavorites(eventId: String) {
        var favoriteMatchExists = false
        var favoriteEventsId = self.favoriteEventsIdPublisher.value

        for favoriteEventId in favoriteEventsId where eventId == favoriteEventId {
            // Remove from favorite
            favoriteMatchExists = true
            favoriteEventsId = favoriteEventsId.filter {$0 != eventId}

            self.favoriteEventsIdPublisher.send(favoriteEventsId)
        }

        // Add to favorite
        if !favoriteMatchExists {
            favoriteEventsId.append(eventId)
            self.favoriteEventsIdPublisher.send(favoriteEventsId)
        }

        self.postUserMetadata(favoriteEvents: favoriteEventsId)
    }
}
