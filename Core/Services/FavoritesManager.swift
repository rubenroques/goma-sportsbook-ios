//
//  FavoritesManager.swift
//  Sportsbook
//
//  Created by André Lascas on 04/11/2021.
//

import Foundation
import Combine

class FavoritesManager {

    var favoriteEventsId: [String]
    var cancellables = Set<AnyCancellable>()

    init(eventsId: [String] = []) {
        self.favoriteEventsId = eventsId
    }

    func getUserMetadata() {
        Env.everyMatrixAPIClient.getUserMetadata()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink { _ in
            } receiveValue: { [weak self] userMetadata in
                if userMetadata.records[0].value != nil {
                    self!.favoriteEventsId = userMetadata.records[0].value!
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
}
