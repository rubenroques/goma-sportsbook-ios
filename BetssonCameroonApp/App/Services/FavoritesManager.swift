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

    // MARK: Lifetime and cycle
    init(eventsId: [String] = []) {
        self.favoriteEventsIdPublisher = .init(eventsId)
    }

    // MARK: Functions
    func getUserFavorites() {
        self.clearFavoritesData()

        Env.servicesProvider.getUserFavorites()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    print("Get user favorites complete!")
                case .failure(let error):
                    print("Get user favorites failure: \(error)")

                }
            }, receiveValue: { [weak self] userFavoritesResponse in
                print("User favorites fetched: \(userFavoritesResponse.favoriteEvents)")
                
                self?.favoriteEventsIdPublisher.send(userFavoritesResponse.favoriteEvents)
            })
            .store(in: &cancellables)
    }

    func clearCachedFavorites() {
        self.favoriteEventsIdPublisher.send([])
    }

    func addUserFavorite(eventId: String) {
        
    }

    func removeUserFavorite(eventId: String) {
    
    }

    func isEventFavorite(eventId: String) -> Bool {
         return self.favoriteEventsIdPublisher.value.contains(eventId)
    }

    func clearFavoritesData() {
        self.favoriteEventsIdPublisher.value = []
    }

}

enum FavoriteType {
    case match
    case competition

    var rawIdentifier: String {
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
