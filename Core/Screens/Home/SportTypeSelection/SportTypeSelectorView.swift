//
//  SportTypeSelectorView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 06/10/2021.
//

import Foundation
import SwiftUI
import Combine

class SportTypeSelectorViewModel: ObservableObject {

    private var cancellable: Set<AnyCancellable> = []
    private var sportsTypeStore: SportsTypeStore

    var sports: [SportType] = []

    init(sportsTypeStore: SportsTypeStore) {
        self.sportsTypeStore = sportsTypeStore

        self.sportsTypeStore.sports
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sportsState in
                switch sportsState {
                case .idle:
                    ()
                case .loading:
                    ()
                case .loaded(let sports):
                    self?.sports = sports
                }
            }
            .store(in: &cancellable)
    }

}

