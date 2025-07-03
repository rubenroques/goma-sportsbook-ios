//
//  MarketGroupCardsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/06/2025.
//

import UIKit
import Combine
import GomaUI

// MARK: - FilteredMatchData
struct FilteredMatchData: Hashable {
    let match: Match
    let relevantMarkets: [Market]
}

// MARK: - MatchCardData
struct MatchCardData: Hashable {
    let filteredData: FilteredMatchData
    let tallOddsViewModel: TallOddsMatchCardViewModelProtocol
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(filteredData)
    }
    
    static func == (lhs: MatchCardData, rhs: MatchCardData) -> Bool {
        return lhs.filteredData == rhs.filteredData
    }
}

// MARK: - MarketGroupCardsViewModel
class MarketGroupCardsViewModel: ObservableObject {
    @Published var filteredMatches: [FilteredMatchData] = []
    @Published var matchCardsData: [MatchCardData] = []

    private let marketTypeId: String
    private var allMatches: [Match] = []
    private var cancellables = Set<AnyCancellable>()
    
    init(marketTypeId: String) {
        print("[MarketGroupCardsViewModel] 🟢 init for marketType: \(marketTypeId)")
        self.marketTypeId = marketTypeId
    }

    deinit {
        print("[MarketGroupCardsViewModel] 🔴 deinit")
    }

    // MARK: - Public Methods
    func updateMatches(_ matches: [Match]) {
        print("[MarketGroupCardsViewModel] ♻️ updated with new Matches")

        self.allMatches = matches
        let filtered = filterMatches()

        self.filteredMatches = filtered
        
        self.matchCardsData = self.createMatchCardsData(from: filtered)
    }

    // MARK: - Private Methods
    private func filterMatches() -> [FilteredMatchData] {
        return allMatches.map { match in
            let relevantMarkets = match.markets.filter { $0.marketTypeId == marketTypeId }
            // Include ALL matches, even those without markets for this market type
            return FilteredMatchData(match: match, relevantMarkets: relevantMarkets)
        }
    }
    
    private func createMatchCardsData(from filteredMatches: [FilteredMatchData]) -> [MatchCardData] {
        let matchCardsData = filteredMatches.enumerated().map { index, filteredData in
            // Create production view model from real match data
            let tallOddsViewModel = createTallOddsViewModel(from: filteredData)
            return MatchCardData(
                filteredData: filteredData,
                tallOddsViewModel: tallOddsViewModel
            )
        }
        
        return matchCardsData
    }
    
    // MARK: - Production Implementation
    private func createTallOddsViewModel(from filteredData: FilteredMatchData) -> TallOddsMatchCardViewModelProtocol {
        // Use the factory method from TallOddsMatchCardViewModel
        return TallOddsMatchCardViewModel.create(
            from: filteredData.match,
            relevantMarkets: filteredData.relevantMarkets,
            marketTypeId: marketTypeId
        )
    }
}
