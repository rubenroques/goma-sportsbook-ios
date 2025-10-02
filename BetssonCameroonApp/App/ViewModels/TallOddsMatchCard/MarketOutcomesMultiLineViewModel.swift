import GomaUI
import Combine
import UIKit

final class MarketOutcomesMultiLineViewModel: MarketOutcomesMultiLineViewModelProtocol {
    
    // MARK: - Publishers
    private let lineViewModelsSubject: CurrentValueSubject<[MarketOutcomesLineViewModelProtocol], Never>
    private let displayStateSubject: CurrentValueSubject<MarketOutcomesMultiLineDisplayState, Never>
    
    // MARK: - Protocol Conformance
    // Current Values (Synchronous Access)
    public var lineViewModels: [MarketOutcomesLineViewModelProtocol] {
        lineViewModelsSubject.value
    }

    public var currentDisplayState: MarketOutcomesMultiLineDisplayState {
        displayStateSubject.value
    }

    // Publishers (Asynchronous Updates)
    public var lineViewModelsPublisher: AnyPublisher<[MarketOutcomesLineViewModelProtocol], Never> {
        lineViewModelsSubject.eraseToAnyPublisher()
    }

    public var displayStatePublisher: AnyPublisher<MarketOutcomesMultiLineDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }
    
    var matchCardContext: MatchCardContext = .lists
    
    // MARK: - Initialization
    init(groupTitle: String? = nil, lineViewModels: [MarketOutcomesLineViewModelProtocol] = [], emptyStateMessage: String? = nil) {
        self.lineViewModelsSubject = CurrentValueSubject(lineViewModels)
        
        let isEmpty = lineViewModels.isEmpty
        let finalEmptyMessage = isEmpty ? (emptyStateMessage ?? "No markets available") : nil
        
        self.displayStateSubject = CurrentValueSubject(
            MarketOutcomesMultiLineDisplayState(
                groupTitle: groupTitle,
                lineCount: lineViewModels.count,
                isEmpty: isEmpty,
                emptyStateMessage: finalEmptyMessage
            )
        )
    }
    
    /// Convenience initializer from MarketGroupData (maintains backward compatibility)
    convenience init(marketGroupData: MarketGroupData, matchCardContext: MatchCardContext = .lists) {
        let lineViewModels = marketGroupData.marketLines.map { lineData in
            Self.createLineViewModel(from: lineData, with: matchCardContext)
        }
        
        self.init(groupTitle: marketGroupData.groupTitle, lineViewModels: lineViewModels)
    }
}

// MARK: - Helper Methods
extension MarketOutcomesMultiLineViewModel {
    
    private static func createLineViewModel(from lineData: MarketLineData, with matchCardContext: MatchCardContext) -> MarketOutcomesLineViewModelProtocol {
        let lineDisplayState = MarketOutcomesLineDisplayState(
            displayMode: lineData.displayMode,
            leftOutcome: lineData.leftOutcome,
            middleOutcome: lineData.middleOutcome,
            rightOutcome: lineData.rightOutcome
        )
        
        // Create production line view model with real-time connections
        return MarketOutcomesLineViewModel(
            marketId: lineData.id,
            initialDisplayState: lineDisplayState,
            matchCardContext: matchCardContext
        )
    }
}

// MARK: - Factory for Creating from Real Market Data (Simplified)
extension MarketOutcomesMultiLineViewModel {
    
    /// Creates line view models directly from market data (production pattern)
    static func createWithDirectLineViewModels(
        from markets: [Market],
        marketTypeId: String,
        with matchCardContext: MatchCardContext
    ) -> MarketOutcomesMultiLineViewModel {
        let lineViewModels = markets.compactMap { market -> MarketOutcomesLineViewModelProtocol? in
            guard !market.outcomes.isEmpty else { return nil }
            
            // Create production line view model directly from Market
            return MarketOutcomesLineViewModel.create(from: market, with: matchCardContext)
        }

        return MarketOutcomesMultiLineViewModel(
            lineViewModels: lineViewModels,
            emptyStateMessage: "-"
        )
    }
    
    private static func extractMarketGroupData(
        from markets: [Market],
        marketTypeId: String
    ) -> MarketGroupData {
        
        let marketLines = createMarketLinesFromMarkets(markets)
        
        return MarketGroupData(
            id: marketTypeId,
            groupTitle: determineGroupTitle(for: marketTypeId),
            marketLines: marketLines
        )
    }
    
    private static func createMarketLinesFromMarkets(_ markets: [Market]) -> [MarketLineData] {
        return markets.compactMap { market in
            guard !market.outcomes.isEmpty else { return nil }
            
            let outcomes = market.outcomes.map { outcome in
                MarketOutcomeData(
                    id: outcome.id,
                    bettingOfferId: outcome.bettingOffer.id,
                    title: outcome.translatedName,
                    value: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd),
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: !outcome.bettingOffer.isAvailable
                )
            }
            
            // Determine line structure based on number of outcomes
            let lineType: MarketLineType = outcomes.count == 3 ? .threeColumn : .twoColumn
            let displayMode: MarketDisplayMode = outcomes.count == 3 ? .triple : .double
            
            return MarketLineData(
                id: market.id,
                leftOutcome: outcomes.first,
                middleOutcome: outcomes.count == 3 ? outcomes[1] : nil,
                rightOutcome: outcomes.last,
                displayMode: displayMode,
                lineType: lineType
            )
        }
    }
    
    private static func determineGroupTitle(for marketTypeId: String) -> String? {
        // Basic mapping of common market type IDs to readable names
        // This could be enhanced with a proper localization system
        switch marketTypeId.lowercased() {
        case "1x2", "home_draw_away":
            return "Match Result"
        case "total_goals", "over_under":
            return "Total Goals"
        case "both_teams_to_score":
            return "Both Teams to Score"
        case "asian_handicap":
            return "Asian Handicap"
        case "double_chance":
            return "Double Chance"
        default:
            return "Markets"
        }
    }
}
