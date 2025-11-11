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
    
    init(filteredData: FilteredMatchData, tallOddsViewModel: TallOddsMatchCardViewModelProtocol) {
        self.filteredData = filteredData
        self.tallOddsViewModel = tallOddsViewModel
    }
    
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

    // MARK: - Pagination State (NEW)
    @Published var hasMoreEvents: Bool = true
    @Published var isLoadingMore: Bool = false

    private let marketTypeId: String
    private var allMatches: [Match] = []
    private var cancellables = Set<AnyCancellable>()

    var matchCardContext: MatchCardContext

    // MARK: - Footer ViewModel
    private(set) var footerViewModel: ExtendedListFooterViewModel?

    // MARK: - MVVM-C Navigation Closures
    var onURLOpenRequested: ((URL) -> Void)?
    var onEmailComposeRequested: ((String) -> Void)?

    init(marketTypeId: String, matchCardContext: MatchCardContext = .lists) {
        print("[MarketGroupCardsViewModel] 🟢 init for marketType: \(marketTypeId)")
        self.marketTypeId = marketTypeId
        self.matchCardContext = matchCardContext

        // Setup footer ViewModel
        self.setupFooterViewModel()
    }

    // MARK: - Footer Setup

    private func setupFooterViewModel() {
        let resolver = AppExtendedListFooterImageResolver()
        let footerVM = ExtendedListFooterViewModel(imageResolver: resolver)

        // Wire up footer callbacks to this ViewModel's navigation closures
        footerVM.onURLOpenRequested = { [weak self] url in
            self?.onURLOpenRequested?(url)
        }

        footerVM.onEmailRequested = { [weak self] email in
            self?.onEmailComposeRequested?(email)
        }

        self.footerViewModel = footerVM
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
    private func createTallOddsViewModel(from filteredData: FilteredMatchData) -> TallOddsMatchCardViewModel {
        // Use the factory method from TallOddsMatchCardViewModel
        return TallOddsMatchCardViewModel.create(
            from: filteredData.match,
            relevantMarkets: filteredData.relevantMarkets,
            marketTypeId: marketTypeId,
            matchCardContext: self.matchCardContext
        )
    }
}
enum MatchCardContext {
    case lists
    case search
}
