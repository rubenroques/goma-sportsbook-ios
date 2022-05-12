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

    private var matchTypes: [SportMatchLineViewModel.MatchesType]
    private var feedContents: [SportSectionFeedContent]?

    private var cachedViewModels: [String: SportMatchLineViewModel] = [:]
    private var cachedViewModelStates: [String: SportMatchLineViewModel.LoadingState] = [:]

    private var cancellables: Set<AnyCancellable> = []

    init(sport: Sport, store: HomeStore) {
        self.sport = sport
        self.store = store

        self.matchTypes = [.popular, .live, .topCompetition]
    }

    init(sport: Sport, contents: [SportSectionFeedContent], store: HomeStore) {

        self.sport = sport
        self.store = store
        self.feedContents = contents

        self.matchTypes = []
        for content in contents {
            switch content {
            case .popular:
                self.matchTypes.append(.popular)
            case .popularVideos(let title, let contents):
                self.matchTypes.append(.popularVideo(title: title, contents: contents))
            case .live:
                self.matchTypes.append(.live)
            case .liveVideos(let title, let contents):
                self.matchTypes.append(.liveVideo(title: title, contents: contents))
            case .competitions:
                self.matchTypes.append(.topCompetition)
            case .competitionsVideos(let title, let contents):
                self.matchTypes.append(.topCompetitionVideo(title: title, contents: contents))
            case .unknown:
                ()
            }
        }
    }

    func numberOfRows() -> Int {
        return self.matchTypes.count
    }

    func sportMatchLineViewModel(forIndex index: Int) -> SportMatchLineViewModel? {
        if let matchType = self.matchTypes[safe: index] {
            return self.sportMatchLineViewModel(forType: matchType)
        }
        return nil
    }

    func sportMatchLineViewModel(forType type: SportMatchLineViewModel.MatchesType) -> SportMatchLineViewModel {

        if let sportMatchLineViewModel = cachedViewModels[type.identifier] {
            return sportMatchLineViewModel
        }
        else {
            let sportMatchLineViewModel = SportMatchLineViewModel(sport: self.sport, matchesType: type, store: self.store)
            sportMatchLineViewModel.loadingPublisher
                .removeDuplicates()
                .sink { [weak self] loadingState in
                    self?.updateLoadingState(loadingState: loadingState, forMatchType: type)
                }
                .store(in: &cancellables)
            cachedViewModels[type.identifier] = sportMatchLineViewModel
            return sportMatchLineViewModel
        }

    }

    private func updateLoadingState(loadingState: SportMatchLineViewModel.LoadingState,
                                    forMatchType matchType: SportMatchLineViewModel.MatchesType) {
        self.cachedViewModelStates[matchType.identifier] = loadingState
        self.requestRefreshPublisher.send()
    }

}
