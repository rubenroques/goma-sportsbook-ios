//
//  CompetitionDetailsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/03/2022.
//

import Foundation
import Combine
import OrderedCollections

class CompetitionDetailsViewModel {

    enum ContentType {
        case outrightMarket(Competition)
        case match(Match)
    }

    var refreshPublisher = PassthroughSubject<Void, Never>.init()

    var isLoadingCompetitions: CurrentValueSubject<Bool, Never> = .init(true)

    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    private var sport: Sport
    private var competitionsIds: [String]
    private var loadedCompetitions: [Competition] = []

    private var cancellables: Set<AnyCancellable> = []

    init(competitionsIds: [String], sport: Sport) {
        self.sport = sport
        self.competitionsIds = competitionsIds

        self.refresh()
    }

    func refresh() {
        self.isLoadingCompetitions.send(true)
        self.fetchCompetitions()
    }

    func matchStatsViewModel(forMatch match: Match) -> MatchStatsViewModel {
        if let viewModel = cachedMatchStatsViewModels[match.id] {
            return viewModel
        }
        else {
            let viewModel = MatchStatsViewModel(match: match)
            cachedMatchStatsViewModels[match.id] = viewModel
            return viewModel
        }
    }

    func markCompetitionAsFavorite(competition: Competition) {
        
        var isFavorite = false
        for competitionId in Env.favoritesManager.favoriteEventsIdPublisher.value where competitionId == competition.id {
            isFavorite = true
        }
        
        if isFavorite {
            Env.favoritesManager.removeFavorite(eventId: competition.id, favoriteType: .competition)
        }
        else {
            Env.favoritesManager.addFavorite(eventId: competition.id, favoriteType: .competition)
        }
    }

    func fetchCompetitions() {

    }

    func fetchCompetitionsMatchesWithIds(_ ids: [String]) {

    }

}

extension CompetitionDetailsViewModel {

    func shouldShowOutrightMarkets(forSection section: Int) -> Bool {
        return self.loadedCompetitions[safe: section]?.numberOutrightMarkets ?? 0 > 0
    }

    func numberOfSection() -> Int {
        return self.loadedCompetitions.count
    }

    func numberOfItems(forSection section: Int) -> Int {
        guard let competition = self.loadedCompetitions[safe: section] else {
            return 0
        }

        if self.shouldShowOutrightMarkets(forSection: section) {
            return competition.matches.count + 1
        }
        else {
            return competition.matches.count
        }
    }

    func competitionForSection(forSection section: Int) -> Competition? {
        return self.loadedCompetitions[safe: section]
    }

    func contentType(forIndexPath indexPath: IndexPath) -> ContentType? {

        guard let competition = self.loadedCompetitions[safe: indexPath.section] else {
            return nil
        }

        if shouldShowOutrightMarkets(forSection: indexPath.section) {
            if indexPath.row == 0 {
                return ContentType.outrightMarket(competition)
            }
            else if let match = competition.matches[safe: indexPath.row - 1] {
                return ContentType.match(match)
            }
        }
        else if let match = competition.matches[safe: indexPath.row] {
            return ContentType.match(match)
        }

        return nil
    }

}
