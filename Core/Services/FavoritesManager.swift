//
//  FavoritesManager.swift
//  Sportsbook
//
//  Created by André Lascas on 04/11/2021.
//

import Foundation
import Combine

class FavoritesManager {

    var favoriteMatchesId: [String]
    var favoriteCompetitionsId: [String]
    var cancellables = Set<AnyCancellable>()

    init(matchesId: [String] = [], competitionsId: [String] = []) {
        self.favoriteMatchesId = matchesId
        self.favoriteCompetitionsId = competitionsId

    }

    func getUserMetadata() {
        Env.everyMatrixAPIClient.getUserMetadata()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink { _ in
            } receiveValue: { [weak self] userMetadata in
                print("GET METADATA: \(userMetadata)")
                self!.favoriteMatchesId = userMetadata.records[0].value!
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
