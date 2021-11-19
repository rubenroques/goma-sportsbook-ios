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
                if let userMetadataRecords = userMetadata.records[0].value{

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
            } receiveValue: { [weak self] userMetadata in
                print("POST METADATA: \(userMetadata)")
            }
            .store(in: &cancellables)
    }

    func checkFavorites(eventId: String) {
        var favoriteMatchExists = false
        var favoriteEventsId = self.favoriteEventsIdPublisher.value

        for favoriteEventId in favoriteEventsId {
            // Remove from favorite
            if eventId == favoriteEventId {
                favoriteMatchExists = true
                favoriteEventsId = favoriteEventsId.filter {$0 != eventId}

                self.favoriteEventsIdPublisher.send(favoriteEventsId)
            }
        }

        // Add to favorite
        if !favoriteMatchExists{
            favoriteEventsId.append(eventId)
            self.favoriteEventsIdPublisher.send(favoriteEventsId)
        }

        self.postUserMetadata(favoriteEvents: favoriteEventsId)
    }
}
