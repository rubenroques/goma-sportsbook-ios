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

    func hash(into hasher: inout Hasher) {
        hasher.combine(match.id)
    }

    static func == (lhs: FilteredMatchData, rhs: FilteredMatchData) -> Bool {
        return lhs.match.id == rhs.match.id
    }
}

// MARK: - MatchCardData
struct MatchCardData: Hashable {
    let filteredData: FilteredMatchData
    let tallOddsViewModel: TallOddsMatchCardViewModelProtocol
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(filteredData.match.id)
    }
    
    static func == (lhs: MatchCardData, rhs: MatchCardData) -> Bool {
        return lhs.filteredData.match.id == rhs.filteredData.match.id
    }
}

// MARK: - MarketGroupCardsViewModel
class MarketGroupCardsViewModel: ObservableObject {
    @Published var filteredMatches: [FilteredMatchData] = []
    @Published var matchCardData: [MatchCardData] = []
    @Published var scrollPosition: CGPoint = .zero

    private let marketTypeId: String
    private var allMatches: [Match] = []
    private var cancellables = Set<AnyCancellable>()
    private weak var scrollPositionCoordinator: ScrollPositionCoordinator?
    private var isReceivingExternalScrollUpdate = false
    
    // MARK: - Logging Properties
    private var updateCount: Int = 0
    private let creationTime: CFAbsoluteTime
    private var lastUpdateTime: CFAbsoluteTime = 0
    
    // Mock TallOddsMatchCardViewModels for testing
    private let mockTallOddsViewModels: [TallOddsMatchCardViewModelProtocol] = [
        MockTallOddsMatchCardViewModel.premierLeagueMock,
        MockTallOddsMatchCardViewModel.compactMock,
        MockTallOddsMatchCardViewModel.bundesliegaMock,
        MockTallOddsMatchCardViewModel.liveMock
    ]

    init(marketTypeId: String, scrollPositionCoordinator: ScrollPositionCoordinator? = nil) {
        self.creationTime = CFAbsoluteTimeGetCurrent()
        print("[MarketGroupCards] Creating MarketGroupCardsViewModel for marketType: \(marketTypeId) at time: \(String(format: "%.3f", creationTime))")
        self.marketTypeId = marketTypeId
        self.scrollPositionCoordinator = scrollPositionCoordinator

        // Register with coordinator if available
        if let coordinator = scrollPositionCoordinator {
            coordinator.addSubscriber(self)
        }
        print("[MarketGroupCards] Initialized MarketGroupCardsViewModel for marketType: \(marketTypeId)")
    }

    deinit {
        // Unregister from coordinator
        if let coordinator = scrollPositionCoordinator {
            coordinator.removeSubscriber(self)
        }
    }

    // MARK: - Public Methods
    func updateMatches(_ matches: [Match]) {
        updateCount += 1
        let currentTime = CFAbsoluteTimeGetCurrent()
        let timeSinceLastUpdate = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        let timeSinceCreation = currentTime - creationTime
        
        let longLog = """
            [MarketGroupCards] updateMatches called with \(matches.count) matches
            for marketType: \(marketTypeId) | Update #\(updateCount) | 
            Time since creation: \(String(format: "%.3f", timeSinceCreation))s |
            Time since last update: \(String(format: "%.3f", timeSinceLastUpdate))s
        """
        
        print("updateMatches: \(longLog)")
              
        allMatches = matches
        let filtered = filterMatches()
        print("[MarketGroupCards] Filtered to \(filtered.count) matches for marketType: \(marketTypeId)")
        filteredMatches = filtered
        
        let startTime = CFAbsoluteTimeGetCurrent()
        matchCardData = createMatchCardData(from: filtered)
        let viewModelCreationTime = CFAbsoluteTimeGetCurrent() - startTime
        
        lastUpdateTime = currentTime
        print("[MarketGroupCards] Created \(matchCardData.count) match card view models in \(String(format: "%.3f", viewModelCreationTime))s for marketType: \(marketTypeId)")
    }

    func updateScrollPosition(_ position: CGPoint) {
        // Only update coordinator if this is not an external update
        guard !isReceivingExternalScrollUpdate else { return }

        scrollPosition = position
        scrollPositionCoordinator?.updateScrollPosition(position, from: self)
    }

    func setScrollPosition(_ position: CGPoint) {
        // This is called by the coordinator, mark as external update
        isReceivingExternalScrollUpdate = true
        scrollPosition = position
        isReceivingExternalScrollUpdate = false
    }

    // MARK: - Private Methods
    private func filterMatches() -> [FilteredMatchData] {
        return allMatches.compactMap { match in
            let relevantMarkets = match.markets.filter { $0.marketTypeId == marketTypeId }
            guard !relevantMarkets.isEmpty else { return nil }
            return FilteredMatchData(match: match, relevantMarkets: relevantMarkets)
        }
    }
    
    private func createMatchCardData(from filteredMatches: [FilteredMatchData]) -> [MatchCardData] {
        return filteredMatches.enumerated().map { index, filteredData in
            print("[MarketGroupCards] Creating view model \(index + 1)/\(filteredMatches.count) for match: \(filteredData.match.id)")
            
            // Create production view model from real match data
            let tallOddsViewModel = createTallOddsViewModel(from: filteredData)
            
            return MatchCardData(
                filteredData: filteredData,
                tallOddsViewModel: tallOddsViewModel
            )
        }
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
