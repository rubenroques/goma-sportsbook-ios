import GomaUI
import Combine
import UIKit

final class MarketOutcomesMultiLineViewModel: MarketOutcomesMultiLineViewModelProtocol {
    
    // MARK: - Publishers
    private let lineViewModelsSubject: CurrentValueSubject<[MarketOutcomesLineViewModelProtocol], Never>
    private let displayStateSubject: CurrentValueSubject<MarketOutcomesMultiLineDisplayState, Never>
    
    // MARK: - Protocol Conformance
    public var lineViewModelsPublisher: AnyPublisher<[MarketOutcomesLineViewModelProtocol], Never> {
        lineViewModelsSubject.eraseToAnyPublisher()
    }
    
    public var lineViewModels: [MarketOutcomesLineViewModelProtocol] {
        lineViewModelsSubject.value
    }
    
    public var displayStatePublisher: AnyPublisher<MarketOutcomesMultiLineDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    init(groupTitle: String? = nil, lineViewModels: [MarketOutcomesLineViewModelProtocol] = []) {
        self.lineViewModelsSubject = CurrentValueSubject(lineViewModels)
        self.displayStateSubject = CurrentValueSubject(
            MarketOutcomesMultiLineDisplayState(
                groupTitle: groupTitle,
                lineCount: lineViewModels.count
            )
        )
    }
    
    /// Convenience initializer from MarketGroupData (maintains backward compatibility)
    convenience init(marketGroupData: MarketGroupData) {
        let lineViewModels = marketGroupData.marketLines.map { lineData in
            Self.createLineViewModel(from: lineData)
        }
        
        self.init(groupTitle: marketGroupData.groupTitle, lineViewModels: lineViewModels)
    }
}

// MARK: - Helper Methods
extension MarketOutcomesMultiLineViewModel {
    
    private static func createLineViewModel(from lineData: MarketLineData) -> MarketOutcomesLineViewModelProtocol {
        let lineDisplayState = MarketOutcomesLineDisplayState(
            displayMode: lineData.displayMode,
            leftOutcome: lineData.leftOutcome,
            middleOutcome: lineData.middleOutcome,
            rightOutcome: lineData.rightOutcome
        )
        
        // Create production line view model with real-time connections
        return MarketOutcomesLineViewModel(
            marketId: lineData.id,
            initialDisplayState: lineDisplayState
        )
    }
}

// MARK: - Factory for Creating from Real Market Data (Simplified)
extension MarketOutcomesMultiLineViewModel {
    
    /// Creates a MarketOutcomesMultiLineViewModel from real Market and Outcome data
    static func create(
        from markets: [Market],
        marketTypeId: String
    ) -> MarketOutcomesMultiLineViewModel {
        let marketGroupData = extractMarketGroupData(from: markets, marketTypeId: marketTypeId)
        return MarketOutcomesMultiLineViewModel(marketGroupData: marketGroupData)
    }
    
    /// Creates line view models directly from market data (production pattern)
    static func createWithDirectLineViewModels(
        from markets: [Market],
        marketTypeId: String
    ) -> MarketOutcomesMultiLineViewModel {
        let lineViewModels = markets.compactMap { market -> MarketOutcomesLineViewModelProtocol? in
            guard !market.outcomes.isEmpty else { return nil }
            
            // Create production line view model directly from Market
            return MarketOutcomesLineViewModel.create(from: market)
        }
        
        // Determine group title based on market type
        let groupTitle = determineGroupTitle(for: marketTypeId)
        
        return MarketOutcomesMultiLineViewModel(
            groupTitle: groupTitle,
            lineViewModels: lineViewModels
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
        // Return nil for now - group titles can be determined based on market type if needed
        return nil
    }
}
