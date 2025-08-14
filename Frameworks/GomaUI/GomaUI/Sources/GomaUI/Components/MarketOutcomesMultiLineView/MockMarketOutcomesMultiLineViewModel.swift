import Combine
import UIKit

/// Simple mock implementation that aggregates line view models
final public class MockMarketOutcomesMultiLineViewModel: MarketOutcomesMultiLineViewModelProtocol {
    
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
    public init(groupTitle: String? = nil, lineViewModels: [MarketOutcomesLineViewModelProtocol] = [], emptyStateMessage: String? = nil) {
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
    public convenience init(marketGroup: MarketGroupData) {
        let lineViewModels = marketGroup.marketLines.map { lineData in
            Self.createLineViewModel(from: lineData)
        }
        
        self.init(groupTitle: marketGroup.groupTitle, lineViewModels: lineViewModels)
    }
}

// MARK: - Helper Methods
extension MockMarketOutcomesMultiLineViewModel {
    
    private static func createLineViewModel(from lineData: MarketLineData) -> MarketOutcomesLineViewModelProtocol {
        let lineDisplayState = MarketOutcomesLineDisplayState(
            displayMode: lineData.displayMode,
            leftOutcome: lineData.leftOutcome,
            middleOutcome: lineData.middleOutcome,
            rightOutcome: lineData.rightOutcome
        )
        
        return MockMarketOutcomesLineViewModel(
            displayMode: lineDisplayState.displayMode,
            leftOutcome: lineDisplayState.leftOutcome,
            middleOutcome: lineDisplayState.middleOutcome,
            rightOutcome: lineDisplayState.rightOutcome
        )
    }
}

// MARK: - Factory Methods (Backward Compatibility)
extension MockMarketOutcomesMultiLineViewModel {
    
    /// Over/Under market group matching the provided image (2-column layout)
    public static var overUnderMarketGroup: MockMarketOutcomesMultiLineViewModel {
        let lines = [
            MarketLineData(
                id: "over_under_0_5",
                leftOutcome: MarketOutcomeData(
                    id: "over_0_5",
                    bettingOfferId: nil,
                    title: "Over 0.5",
                    value: "1.80",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                middleOutcome: nil,
                rightOutcome: MarketOutcomeData(
                    id: "under_0_5",
                    bettingOfferId: nil,
                    title: "Under 0.5",
                    value: "3.20",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                displayMode: .double,
                lineType: .twoColumn
            ),
            MarketLineData(
                id: "over_under_1_0",
                leftOutcome: MarketOutcomeData(
                    id: "over_1_0",
                    bettingOfferId: nil,
                    title: "Over 1.0",
                    value: "1.80",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                middleOutcome: nil,
                rightOutcome: MarketOutcomeData(
                    id: "under_1_0",
                    bettingOfferId: nil,
                    title: "Under 1.0",
                    value: "3.20",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                displayMode: .double,
                lineType: .twoColumn
            ),
            MarketLineData(
                id: "over_under_1_5",
                leftOutcome: MarketOutcomeData(
                    id: "over_1_5",
                    bettingOfferId: nil,
                    title: "Over 1.5",
                    value: "1.80",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                middleOutcome: nil,
                rightOutcome: MarketOutcomeData(
                    id: "under_1_5",
                    bettingOfferId: nil,
                    title: "Under 1.5",
                    value: "3.20",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                displayMode: .double,
                lineType: .twoColumn
            )
        ]
        
        let groupData = MarketGroupData(
            id: "over_under_group",
            groupTitle: nil,  // No group title as shown in image
            marketLines: lines
        )
        
        return MockMarketOutcomesMultiLineViewModel(marketGroup: groupData)
    }

    /// 1X2 market group (3-column layout)
    public static var homeDrawAwayMarketGroup: MockMarketOutcomesMultiLineViewModel {
        let lines = [
            MarketLineData(
                id: "full_time_1x2",
                leftOutcome: MarketOutcomeData(
                    id: "home_ft",
                    bettingOfferId: nil,
                    title: "Home",
                    value: "1.85",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                middleOutcome: MarketOutcomeData(
                    id: "draw_ft",
                    bettingOfferId: nil,
                    title: "Draw",
                    value: "3.55",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                rightOutcome: MarketOutcomeData(
                    id: "away_ft",
                    bettingOfferId: nil,
                    title: "Away",
                    value: "4.20",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                displayMode: .triple,
                lineType: .threeColumn
            ),
            MarketLineData(
                id: "half_time_1x2",
                leftOutcome: MarketOutcomeData(
                    id: "home_ht",
                    bettingOfferId: nil,
                    title: "Home",
                    value: "2.10",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                middleOutcome: MarketOutcomeData(
                    id: "draw_ht",
                    bettingOfferId: nil,
                    title: "Draw",
                    value: "2.05",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                rightOutcome: MarketOutcomeData(
                    id: "away_ht",
                    bettingOfferId: nil,
                    title: "Away",
                    value: "5.50",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                displayMode: .triple,
                lineType: .threeColumn
            )
        ]
        
        let groupData = MarketGroupData(
            id: "1x2_group",
            marketLines: lines
        )
        
        return MockMarketOutcomesMultiLineViewModel(marketGroup: groupData)
    }

    /// Over/Under market group with one suspended line
    public static var overUnderWithSuspendedLine: MockMarketOutcomesMultiLineViewModel {
        let lines = [
            MarketLineData(
                id: "over_under_0_5",
                leftOutcome: MarketOutcomeData(
                    id: "over_0_5",
                    bettingOfferId: nil,
                    title: "Over 0.5",
                    value: "1.80",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                middleOutcome: nil,
                rightOutcome: MarketOutcomeData(
                    id: "under_0_5",
                    bettingOfferId: nil,
                    title: "Under 0.5",
                    value: "3.20",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                displayMode: .double,
                lineType: .twoColumn
            ),
            MarketLineData(
                id: "over_under_1_5",
                leftOutcome: MarketOutcomeData(
                    id: "over_1_5",
                    bettingOfferId: nil,
                    title: "Over 1.5",
                    value: "1.80",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: true
                ),
                middleOutcome: nil,
                rightOutcome: MarketOutcomeData(
                    id: "under_1_5",
                    bettingOfferId: nil,
                    title: "Under 1.5",
                    value: "3.20",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: true
                ),
                displayMode: .suspended(text: "Market Suspended"),
                lineType: .twoColumn
            ),
            MarketLineData(
                id: "over_under_2_5",
                leftOutcome: MarketOutcomeData(
                    id: "over_2_5",
                    bettingOfferId: nil,
                    title: "Over 2.5",
                    value: "2.10",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                middleOutcome: nil,
                rightOutcome: MarketOutcomeData(
                    id: "under_2_5",
                    bettingOfferId: nil,
                    title: "Under 2.5",
                    value: "1.75",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                displayMode: .double,
                lineType: .twoColumn
            )
        ]
        
        let groupData = MarketGroupData(
            id: "over_under_suspended_group",
            groupTitle: nil,
            marketLines: lines
        )
        
        return MockMarketOutcomesMultiLineViewModel(marketGroup: groupData)
    }

    /// Mixed layout group (some 2-column, some 3-column)
    public static var mixedLayoutMarketGroup: MockMarketOutcomesMultiLineViewModel {
        let lines = [
            MarketLineData(
                id: "match_result",
                leftOutcome: MarketOutcomeData(
                    id: "home",
                    bettingOfferId: nil,
                    title: "Home",
                    value: "1.85",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                middleOutcome: MarketOutcomeData(
                    id: "draw",
                    bettingOfferId: nil,
                    title: "Draw",
                    value: "3.55",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                rightOutcome: MarketOutcomeData(
                    id: "away",
                    bettingOfferId: nil,
                    title: "Away",
                    value: "4.20",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                displayMode: .triple,
                lineType: .threeColumn
            ),
            MarketLineData(
                id: "both_teams_score",
                leftOutcome: MarketOutcomeData(
                    id: "yes_btts",
                    bettingOfferId: nil,
                    title: "Yes",
                    value: "1.90",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                middleOutcome: nil,
                rightOutcome: MarketOutcomeData(
                    id: "no_btts",
                    bettingOfferId: nil,
                    title: "No",
                    value: "1.85",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                displayMode: .double,
                lineType: .twoColumn
            )
        ]
        
        let groupData = MarketGroupData(
            id: "mixed_group",
            groupTitle: "Popular Markets",
            marketLines: lines
        )
        
        return MockMarketOutcomesMultiLineViewModel(marketGroup: groupData)
    }

    /// Market group with odds changes
    public static var marketGroupWithOddsChanges: MockMarketOutcomesMultiLineViewModel {
        let lines = [
            MarketLineData(
                id: "over_under_2_5",
                leftOutcome: MarketOutcomeData(
                    id: "over_2_5",
                    bettingOfferId: nil,
                    title: "Over 2.5",
                    value: "1.95",
                    oddsChangeDirection: .up,
                    isSelected: false,
                    isDisabled: false
                ),
                middleOutcome: nil,
                rightOutcome: MarketOutcomeData(
                    id: "under_2_5",
                    bettingOfferId: nil,
                    title: "Under 2.5",
                    value: "1.80",
                    oddsChangeDirection: .down,
                    isSelected: false,
                    isDisabled: false
                ),
                displayMode: .double,
                lineType: .twoColumn
            ),
            MarketLineData(
                id: "over_under_3_5",
                leftOutcome: MarketOutcomeData(
                    id: "over_3_5",
                    bettingOfferId: nil,
                    title: "Over 3.5",
                    value: "3.20",
                    oddsChangeDirection: .none,
                    isSelected: true,
                    isDisabled: false
                ),
                middleOutcome: nil,
                rightOutcome: MarketOutcomeData(
                    id: "under_3_5",
                    bettingOfferId: nil,
                    title: "Under 3.5",
                    value: "1.35",
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: false
                ),
                displayMode: .double,
                lineType: .twoColumn
            )
        ]
        
        let groupData = MarketGroupData(
            id: "odds_changes_group",
            groupTitle: nil,
            marketLines: lines
        )
        
        return MockMarketOutcomesMultiLineViewModel(marketGroup: groupData)
    }
    
    /// Empty state market group (no markets available)
    public static var emptyMarketGroupWithTitle: MockMarketOutcomesMultiLineViewModel {
        return MockMarketOutcomesMultiLineViewModel(
            groupTitle: "Total Goals",
            lineViewModels: [],
            emptyStateMessage: "No Total Goals markets available for this match"
        )
    }
    
    /// Empty state without title
    public static var emptyMarketGroup: MockMarketOutcomesMultiLineViewModel {
        return MockMarketOutcomesMultiLineViewModel(
            groupTitle: nil,
            lineViewModels: [],
            emptyStateMessage: "Markets temporarily unavailable"
        )
    }
    
    /// Empty state without title
    public static var loadingMarketGroup: MockMarketOutcomesMultiLineViewModel {
        return MockMarketOutcomesMultiLineViewModel(
            groupTitle: nil,
            lineViewModels: [],
            emptyStateMessage: "Loading markets"
        )
    }
}
