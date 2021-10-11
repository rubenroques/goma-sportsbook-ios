//
//  SportsTypeStore.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/10/2021.
//

import Foundation
import Combine

class SportsTypeStore {

    var sports: AnyPublisher<LoadableContent<SportTypes>, Never>

    init() {
        sports = CurrentValueSubject<LoadableContent<SportTypes>, Never>(.idle).eraseToAnyPublisher()

        self.fetchSports()
    }

    private func fetchSports() {

        sports = CurrentValueSubject<LoadableContent<SportTypes>, Never>(.loading).eraseToAnyPublisher()

        sports = Just(LoadableContent<SportTypes>.loaded([]))
            .delay(for: .seconds(4), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func forceRefresh() {
        self.fetchSports()
    }

}


