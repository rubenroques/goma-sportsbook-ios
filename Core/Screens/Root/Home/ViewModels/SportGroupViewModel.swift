//
//  SportGroupViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 23/02/2022.
//

import Foundation
import Combine

class SportGroupViewModel {

    var requestRefreshPublisher = PassthroughSubject<Void, Never>.init()

    private var store: HomeStore
    private var sport: Sport

    private var cachedViewModels: [SportMatchLineViewModel.MatchesType: SportMatchLineViewModel] = [:]
    private var cachedViewModelStates: [SportMatchLineViewModel.MatchesType: SportMatchLineViewModel.LoadingState] = [:]

    private var cancellables: Set<AnyCancellable> = []

    init(sport: Sport, store: HomeStore) {
        self.sport = sport
        self.store = store
//
//        for type in SportMatchLineViewModel.MatchesType.allCases {
//            _ = self.sportMatchLineViewModel(forType: type)
//        }
    }

    func numberOfRows() -> Int {
        return 3
    }

    func sportMatchLineViewModel(forIndex index: Int) -> SportMatchLineViewModel? {
        if let matchType = SportMatchLineViewModel.matchesType(forIndex: index) {
            return self.sportMatchLineViewModel(forType: matchType)
        }
        return nil
    }

    func sportMatchLineViewModel(forType type: SportMatchLineViewModel.MatchesType) -> SportMatchLineViewModel {

        if let sportMatchLineViewModel = cachedViewModels[type] {
            print("HomeDebug cached - \(self.sport.name);\(type)")
            return sportMatchLineViewModel
        }
        else {

            print("HomeDebug create - \(self.sport.name);\(type)")

            let sportMatchLineViewModel = SportMatchLineViewModel(sport: self.sport, matchesType: type, store: self.store)

            sportMatchLineViewModel.loadingPublisher
                .removeDuplicates()
                .sink { [weak self] loadingState in
                    self?.updateLoadingState(loadingState: loadingState, forMatchType: type)
                }
                .store(in: &cancellables)
            cachedViewModels[type] = sportMatchLineViewModel

            return sportMatchLineViewModel
        }

    }

    private func updateLoadingState(loadingState: SportMatchLineViewModel.LoadingState,
                                    forMatchType matchType: SportMatchLineViewModel.MatchesType) {

        print("HomeDebug updateLoading - \(self.sport.name);\(matchType);\(loadingState)")

        self.cachedViewModelStates[matchType] = loadingState
        self.requestRefreshPublisher.send()
    }

}
