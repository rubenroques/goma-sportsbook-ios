//
//  MockMarketsTabSimpleViewModel.swift
//  Sportsbook
//
//  Created on 2025-07-16.
//

import Foundation
import Combine
import GomaUI

public class MockMarketsTabSimpleViewModel: MarketsTabSimpleViewModelProtocol {
    
    // MARK: - Properties
    
    public let marketGroupId: String
    public let marketGroupTitle: String
    
    // MARK: - Private Properties
    
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let errorSubject = CurrentValueSubject<String?, Never>(nil)
    private let marketGroupsSubject = CurrentValueSubject<[MarketGroupWithIcons], Never>([])
    
    // MARK: - Initialization
    
    public init(marketGroupId: String, marketGroupTitle: String) {
        self.marketGroupId = marketGroupId
        self.marketGroupTitle = marketGroupTitle

    }
    
    // MARK: - Publishers
    
    public var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    public var errorPublisher: AnyPublisher<String?, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    public var marketGroupsPublisher: AnyPublisher<[MarketGroupWithIcons], Never> {
        marketGroupsSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Methods
    
    public func loadMarkets() {
        isLoadingSubject.send(true)
        errorSubject.send(nil)
        
        // Simulate async loading with mock data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Create mock market groups
            let mockMarketGroups = self.createMockMarketGroups()
            self.marketGroupsSubject.send(mockMarketGroups)
            self.isLoadingSubject.send(false)
        }
    }
    
    public func refreshMarkets() {
        loadMarkets()
    }
    
    public func handleOutcomeSelection(marketGroupId: String, lineId: String, outcomeType: OutcomeType) {
        print("Mock: Outcome selected - Group: \(marketGroupId), Line: \(lineId), Type: \(outcomeType)")
    }
    
    // MARK: - Private Methods
    
    private func createMockMarketGroups() -> [MarketGroupWithIcons] {
        // Create mock market groups based on the market group ID
        switch marketGroupId.lowercased() {
        case "match_result", "1x2":
            return [createMatchResultMarketGroup()]
        case "goals", "over_under":
            return [createOverUnderMarketGroup()]
        case "both_teams_to_score":
            return [createBothTeamsToScoreMarketGroup()]
        default:
            return [createDefaultMarketGroup()]
        }
    }
    
    private func createMatchResultMarketGroup() -> MarketGroupWithIcons {
        let marketLines = [
            MarketLineData(
                id: "match_result_ft",
                leftOutcome: MarketOutcomeData(id: "home", title: "Home", value: "1.85", oddsChangeDirection: .none, isSelected: false, isDisabled: false),
                middleOutcome: MarketOutcomeData(id: "draw", title: "Draw", value: "3.40", oddsChangeDirection: .none, isSelected: false, isDisabled: false),
                rightOutcome: MarketOutcomeData(id: "away", title: "Away", value: "4.20", oddsChangeDirection: .none, isSelected: false, isDisabled: false),
                displayMode: .triple,
                lineType: .threeColumn
            )
        ]
        
        let marketGroup = MarketGroupData(
            id: "match_result",
            groupTitle: "Match Result",
            marketLines: marketLines
        )
        
        let icons = [
            MarketInfoIcon(type: .expressPickShort),
            MarketInfoIcon(type: .mostPopular)
        ]
        
        return MarketGroupWithIcons(marketGroup: marketGroup, icons: icons, groupName: "Match Result")
    }
    
    private func createOverUnderMarketGroup() -> MarketGroupWithIcons {
        let marketLines = [
            MarketLineData(
                id: "over_under_0.5",
                leftOutcome: MarketOutcomeData(id: "over_0.5", title: "Over 0.5", value: "1.05", oddsChangeDirection: .none, isSelected: false, isDisabled: false),
                middleOutcome: nil,
                rightOutcome: MarketOutcomeData(id: "under_0.5", title: "Under 0.5", value: "12.00", oddsChangeDirection: .none, isSelected: false, isDisabled: false),
                displayMode: .double,
                lineType: .twoColumn
            ),
            MarketLineData(
                id: "over_under_1.5",
                leftOutcome: MarketOutcomeData(id: "over_1.5", title: "Over 1.5", value: "1.25", oddsChangeDirection: .up, isSelected: false, isDisabled: false),
                middleOutcome: nil,
                rightOutcome: MarketOutcomeData(id: "under_1.5", title: "Under 1.5", value: "3.75", oddsChangeDirection: .down, isSelected: false, isDisabled: false),
                displayMode: .double,
                lineType: .twoColumn
            ),
            MarketLineData(
                id: "over_under_2.5",
                leftOutcome: MarketOutcomeData(id: "over_2.5", title: "Over 2.5", value: "1.90", oddsChangeDirection: .none, isSelected: true, isDisabled: false),
                middleOutcome: nil,
                rightOutcome: MarketOutcomeData(id: "under_2.5", title: "Under 2.5", value: "1.90", oddsChangeDirection: .none, isSelected: false, isDisabled: false),
                displayMode: .double,
                lineType: .twoColumn
            ),
            MarketLineData(
                id: "over_under_3.5",
                leftOutcome: MarketOutcomeData(id: "over_3.5", title: "Over 3.5", value: "3.10", oddsChangeDirection: .none, isSelected: false, isDisabled: false),
                middleOutcome: nil,
                rightOutcome: MarketOutcomeData(id: "under_3.5", title: "Under 3.5", value: "1.35", oddsChangeDirection: .none, isSelected: false, isDisabled: false),
                displayMode: .double,
                lineType: .twoColumn
            )
        ]
        
        let marketGroup = MarketGroupData(
            id: "over_under",
            groupTitle: "Total Goals - Full Time",
            marketLines: marketLines
        )
        
        let icons = [
            MarketInfoIcon(type: .expressPickShort),
            MarketInfoIcon(type: .statistics)
        ]
        
        return MarketGroupWithIcons(marketGroup: marketGroup, icons: icons, groupName: "Total Goals - Full Time")
    }
    
    private func createBothTeamsToScoreMarketGroup() -> MarketGroupWithIcons {
        let marketLines = [
            MarketLineData(
                id: "btts",
                leftOutcome: MarketOutcomeData(id: "yes", title: "Yes", value: "1.72", oddsChangeDirection: .none, isSelected: false, isDisabled: false),
                middleOutcome: nil,
                rightOutcome: MarketOutcomeData(id: "no", title: "No", value: "2.05", oddsChangeDirection: .none, isSelected: false, isDisabled: false),
                displayMode: .double,
                lineType: .twoColumn
            )
        ]
        
        let marketGroup = MarketGroupData(
            id: "btts",
            groupTitle: "Both Teams to Score",
            marketLines: marketLines
        )
        
        let icons = [
            MarketInfoIcon(type: .betBuilder)
        ]
        
        return MarketGroupWithIcons(marketGroup: marketGroup, icons: icons, groupName: "Both Teams to Score")
    }
    
    private func createDefaultMarketGroup() -> MarketGroupWithIcons {
        let marketLines = [
            MarketLineData(
                id: "market_1",
                leftOutcome: MarketOutcomeData(id: "option_1", title: "Option 1", value: "2.10", oddsChangeDirection: .none, isSelected: false, isDisabled: false),
                middleOutcome: nil,
                rightOutcome: MarketOutcomeData(id: "option_2", title: "Option 2", value: "1.70", oddsChangeDirection: .none, isSelected: false, isDisabled: false),
                displayMode: .double,
                lineType: .twoColumn
            )
        ]
        
        let marketGroup = MarketGroupData(
            id: marketGroupId,
            groupTitle: marketGroupTitle,
            marketLines: marketLines
        )
        
        return MarketGroupWithIcons(marketGroup: marketGroup, icons: [], groupName: marketGroupTitle)
    }
    
    // MARK: - Factory Methods
    
    public static func defaultMock(for marketGroupId: String, title: String) -> MockMarketsTabSimpleViewModel {
        return MockMarketsTabSimpleViewModel(marketGroupId: marketGroupId, marketGroupTitle: title)
    }
    
}
