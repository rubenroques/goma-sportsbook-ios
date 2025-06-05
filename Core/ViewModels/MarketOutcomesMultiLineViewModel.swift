import GomaUI
import Combine
import UIKit

final class MarketOutcomesMultiLineViewModel: MarketOutcomesMultiLineViewModelProtocol {
    // MARK: - Private Properties
    private let marketStateSubject: CurrentValueSubject<MarketOutcomesMultiLineDisplayState, Never>
    private let oddsChangeEventSubject: PassthroughSubject<MarketLineOddsChangeEvent, Never>
    
    // MARK: - Published Properties
    public var marketStatePublisher: AnyPublisher<MarketOutcomesMultiLineDisplayState, Never> {
        marketStateSubject
            .handleEvents(receiveOutput: { state in
                print("[MarketOutcomes] marketStatePublisher sending update for group: \(state.marketGroup.id), lines: \(state.marketGroup.marketLines.count)")
            })
            .eraseToAnyPublisher()
    }
    
    public var oddsChangeEventPublisher: AnyPublisher<MarketLineOddsChangeEvent, Never> {
        oddsChangeEventSubject
            .handleEvents(receiveOutput: { event in
                print("[MarketOutcomes] oddsChangeEventPublisher sending event for line: \(event.lineId), outcome: \(event.outcomeType)")
            })
            .eraseToAnyPublisher()
    }
    
    private var marketGroupData: MarketGroupData
    
    // MARK: - Initialization
    init(marketGroupData: MarketGroupData) {
        print("[MarketOutcomes] Creating MarketOutcomesMultiLineViewModel for group: \(marketGroupData.id), lines: \(marketGroupData.marketLines.count)")
        self.marketGroupData = marketGroupData
        
        // Create initial display state
        let initialDisplayState = MarketOutcomesMultiLineDisplayState(
            marketGroup: marketGroupData,
            isLoading: false,
            errorMessage: nil
        )
        
        print("[MarketOutcomes] Created initial display state")
        
        // Initialize subjects
        self.marketStateSubject = CurrentValueSubject(initialDisplayState)
        self.oddsChangeEventSubject = PassthroughSubject()
        
        print("[MarketOutcomes] Initialized subjects for group: \(marketGroupData.id)")
    }
    
    // MARK: - MarketOutcomesMultiLineViewModelProtocol
    func toggleOutcome(lineId: String, outcomeType: OutcomeType) -> Bool {
        var updatedMarketGroup = marketGroupData
        var wasToggled = false
        
        // Find and toggle the specific outcome
        if let lineIndex = updatedMarketGroup.marketLines.firstIndex(where: { $0.id == lineId }) {
            var updatedLine = updatedMarketGroup.marketLines[lineIndex]
            
            switch outcomeType {
            case .left:
                if var leftOutcome = updatedLine.leftOutcome {
                    leftOutcome = MarketOutcomeData(
                        id: leftOutcome.id,
                        title: leftOutcome.title,
                        value: leftOutcome.value,
                        oddsChangeDirection: leftOutcome.oddsChangeDirection,
                        isSelected: !leftOutcome.isSelected,
                        isDisabled: leftOutcome.isDisabled,
                        previousValue: leftOutcome.previousValue,
                        changeTimestamp: leftOutcome.changeTimestamp
                    )
                    updatedLine = MarketLineData(
                        id: updatedLine.id,
                        leftOutcome: leftOutcome,
                        middleOutcome: updatedLine.middleOutcome,
                        rightOutcome: updatedLine.rightOutcome,
                        displayMode: updatedLine.displayMode,
                        lineType: updatedLine.lineType,
                        isLineDisabled: updatedLine.isLineDisabled
                    )
                    wasToggled = true
                }
            case .middle:
                if var middleOutcome = updatedLine.middleOutcome {
                    middleOutcome = MarketOutcomeData(
                        id: middleOutcome.id,
                        title: middleOutcome.title,
                        value: middleOutcome.value,
                        oddsChangeDirection: middleOutcome.oddsChangeDirection,
                        isSelected: !middleOutcome.isSelected,
                        isDisabled: middleOutcome.isDisabled,
                        previousValue: middleOutcome.previousValue,
                        changeTimestamp: middleOutcome.changeTimestamp
                    )
                    updatedLine = MarketLineData(
                        id: updatedLine.id,
                        leftOutcome: updatedLine.leftOutcome,
                        middleOutcome: middleOutcome,
                        rightOutcome: updatedLine.rightOutcome,
                        displayMode: updatedLine.displayMode,
                        lineType: updatedLine.lineType,
                        isLineDisabled: updatedLine.isLineDisabled
                    )
                    wasToggled = true
                }
            case .right:
                if var rightOutcome = updatedLine.rightOutcome {
                    rightOutcome = MarketOutcomeData(
                        id: rightOutcome.id,
                        title: rightOutcome.title,
                        value: rightOutcome.value,
                        oddsChangeDirection: rightOutcome.oddsChangeDirection,
                        isSelected: !rightOutcome.isSelected,
                        isDisabled: rightOutcome.isDisabled,
                        previousValue: rightOutcome.previousValue,
                        changeTimestamp: rightOutcome.changeTimestamp
                    )
                    updatedLine = MarketLineData(
                        id: updatedLine.id,
                        leftOutcome: updatedLine.leftOutcome,
                        middleOutcome: updatedLine.middleOutcome,
                        rightOutcome: rightOutcome,
                        displayMode: updatedLine.displayMode,
                        lineType: updatedLine.lineType,
                        isLineDisabled: updatedLine.isLineDisabled
                    )
                    wasToggled = true
                }
            }
            
            if wasToggled {
                updatedMarketGroup = MarketGroupData(
                    id: updatedMarketGroup.id,
                    groupTitle: updatedMarketGroup.groupTitle,
                    marketLines: Array(updatedMarketGroup.marketLines.prefix(lineIndex)) + [updatedLine] + Array(updatedMarketGroup.marketLines.suffix(from: lineIndex + 1)),
                    defaultLineType: updatedMarketGroup.defaultLineType,
                    isExpanded: updatedMarketGroup.isExpanded,
                    maxVisibleLines: updatedMarketGroup.maxVisibleLines
                )
                
                // Update internal state
                marketGroupData = updatedMarketGroup
                
                // Publish updated state
                let newDisplayState = MarketOutcomesMultiLineDisplayState(
                    marketGroup: updatedMarketGroup,
                    isLoading: false,
                    errorMessage: nil
                )
                marketStateSubject.send(newDisplayState)
                
                print("[MarketOutcomes] Toggled outcome \(outcomeType) for line \(lineId), sending state update")
            }
        }
        
        return wasToggled
    }
    
    func updateOddsValue(lineId: String, outcomeType: OutcomeType, newValue: String) {
        // Find the line and outcome to update
        guard let lineIndex = marketGroupData.marketLines.firstIndex(where: { $0.id == lineId }) else { return }
        
        var updatedLine = marketGroupData.marketLines[lineIndex]
        var oldValue: String = ""
        var updatedOutcome: MarketOutcomeData?
        
        switch outcomeType {
        case .left:
            guard let leftOutcome = updatedLine.leftOutcome else { return }
            oldValue = leftOutcome.value
            updatedOutcome = leftOutcome.withUpdatedOdds(newValue)
            updatedLine = MarketLineData(
                id: updatedLine.id,
                leftOutcome: updatedOutcome,
                middleOutcome: updatedLine.middleOutcome,
                rightOutcome: updatedLine.rightOutcome,
                displayMode: updatedLine.displayMode,
                lineType: updatedLine.lineType,
                isLineDisabled: updatedLine.isLineDisabled
            )
        case .middle:
            guard let middleOutcome = updatedLine.middleOutcome else { return }
            oldValue = middleOutcome.value
            updatedOutcome = middleOutcome.withUpdatedOdds(newValue)
            updatedLine = MarketLineData(
                id: updatedLine.id,
                leftOutcome: updatedLine.leftOutcome,
                middleOutcome: updatedOutcome,
                rightOutcome: updatedLine.rightOutcome,
                displayMode: updatedLine.displayMode,
                lineType: updatedLine.lineType,
                isLineDisabled: updatedLine.isLineDisabled
            )
        case .right:
            guard let rightOutcome = updatedLine.rightOutcome else { return }
            oldValue = rightOutcome.value
            updatedOutcome = rightOutcome.withUpdatedOdds(newValue)
            updatedLine = MarketLineData(
                id: updatedLine.id,
                leftOutcome: updatedLine.leftOutcome,
                middleOutcome: updatedLine.middleOutcome,
                rightOutcome: updatedOutcome,
                displayMode: updatedLine.displayMode,
                lineType: updatedLine.lineType,
                isLineDisabled: updatedLine.isLineDisabled
            )
        }
        
        // Update market group data
        var updatedMarketLines = marketGroupData.marketLines
        updatedMarketLines[lineIndex] = updatedLine
        
        marketGroupData = MarketGroupData(
            id: marketGroupData.id,
            groupTitle: marketGroupData.groupTitle,
            marketLines: updatedMarketLines,
            defaultLineType: marketGroupData.defaultLineType,
            isExpanded: marketGroupData.isExpanded,
            maxVisibleLines: marketGroupData.maxVisibleLines
        )
        
        // Publish updated state
        let newDisplayState = MarketOutcomesMultiLineDisplayState(
            marketGroup: marketGroupData,
            isLoading: false,
            errorMessage: nil
        )
        marketStateSubject.send(newDisplayState)
        
        // Emit odds change event
        if let outcome = updatedOutcome {
            let changeEvent = MarketLineOddsChangeEvent(
                lineId: lineId,
                outcomeType: outcomeType,
                oldValue: oldValue,
                newValue: newValue,
                direction: outcome.oddsChangeDirection,
                timestamp: Date()
            )
            oddsChangeEventSubject.send(changeEvent)
        }
    }
    
    func setLineDisplayMode(lineId: String, mode: MarketDisplayMode) {
        guard let lineIndex = marketGroupData.marketLines.firstIndex(where: { $0.id == lineId }) else { return }
        
        var updatedLine = marketGroupData.marketLines[lineIndex]
        updatedLine = MarketLineData(
            id: updatedLine.id,
            leftOutcome: updatedLine.leftOutcome,
            middleOutcome: updatedLine.middleOutcome,
            rightOutcome: updatedLine.rightOutcome,
            displayMode: mode,
            lineType: updatedLine.lineType,
            isLineDisabled: updatedLine.isLineDisabled
        )
        
        var updatedMarketLines = marketGroupData.marketLines
        updatedMarketLines[lineIndex] = updatedLine
        
        marketGroupData = MarketGroupData(
            id: marketGroupData.id,
            groupTitle: marketGroupData.groupTitle,
            marketLines: updatedMarketLines,
            defaultLineType: marketGroupData.defaultLineType,
            isExpanded: marketGroupData.isExpanded,
            maxVisibleLines: marketGroupData.maxVisibleLines
        )
        
        let newDisplayState = MarketOutcomesMultiLineDisplayState(
            marketGroup: marketGroupData,
            isLoading: false,
            errorMessage: nil
        )
        marketStateSubject.send(newDisplayState)
    }
    
    func clearOddsChangeIndicator(lineId: String, outcomeType: OutcomeType) {
        updateOddsChangeDirection(lineId: lineId, outcomeType: outcomeType, direction: .none)
    }
    
    func suspendLine(lineId: String, message: String) {
        setLineDisplayMode(lineId: lineId, mode: .suspended(text: message))
    }
    
    func resumeLine(lineId: String) {
        // Determine appropriate display mode based on line type
        guard let lineIndex = marketGroupData.marketLines.firstIndex(where: { $0.id == lineId }) else { return }
        let line = marketGroupData.marketLines[lineIndex]
        let mode: MarketDisplayMode = line.lineType == .threeColumn ? .triple : .double
        setLineDisplayMode(lineId: lineId, mode: mode)
    }
    
    func disableLine(lineId: String) {
        guard let lineIndex = marketGroupData.marketLines.firstIndex(where: { $0.id == lineId }) else { return }
        
        var updatedLine = marketGroupData.marketLines[lineIndex]
        updatedLine = MarketLineData(
            id: updatedLine.id,
            leftOutcome: updatedLine.leftOutcome,
            middleOutcome: updatedLine.middleOutcome,
            rightOutcome: updatedLine.rightOutcome,
            displayMode: updatedLine.displayMode,
            lineType: updatedLine.lineType,
            isLineDisabled: true
        )
        
        updateLineInMarketGroup(updatedLine, at: lineIndex)
    }
    
    func enableLine(lineId: String) {
        guard let lineIndex = marketGroupData.marketLines.firstIndex(where: { $0.id == lineId }) else { return }
        
        var updatedLine = marketGroupData.marketLines[lineIndex]
        updatedLine = MarketLineData(
            id: updatedLine.id,
            leftOutcome: updatedLine.leftOutcome,
            middleOutcome: updatedLine.middleOutcome,
            rightOutcome: updatedLine.rightOutcome,
            displayMode: updatedLine.displayMode,
            lineType: updatedLine.lineType,
            isLineDisabled: false
        )
        
        updateLineInMarketGroup(updatedLine, at: lineIndex)
    }
}

// MARK: - Private Helper Methods
extension MarketOutcomesMultiLineViewModel {
    
    private func updateOddsChangeDirection(lineId: String, outcomeType: OutcomeType, direction: OddsChangeDirection) {
        guard let lineIndex = marketGroupData.marketLines.firstIndex(where: { $0.id == lineId }) else { return }
        
        var updatedLine = marketGroupData.marketLines[lineIndex]
        
        switch outcomeType {
        case .left:
            if let leftOutcome = updatedLine.leftOutcome {
                let clearedOutcome = leftOutcome.withClearedOddsChange()
                updatedLine = MarketLineData(
                    id: updatedLine.id,
                    leftOutcome: clearedOutcome,
                    middleOutcome: updatedLine.middleOutcome,
                    rightOutcome: updatedLine.rightOutcome,
                    displayMode: updatedLine.displayMode,
                    lineType: updatedLine.lineType,
                    isLineDisabled: updatedLine.isLineDisabled
                )
            }
        case .middle:
            if let middleOutcome = updatedLine.middleOutcome {
                let clearedOutcome = middleOutcome.withClearedOddsChange()
                updatedLine = MarketLineData(
                    id: updatedLine.id,
                    leftOutcome: updatedLine.leftOutcome,
                    middleOutcome: clearedOutcome,
                    rightOutcome: updatedLine.rightOutcome,
                    displayMode: updatedLine.displayMode,
                    lineType: updatedLine.lineType,
                    isLineDisabled: updatedLine.isLineDisabled
                )
            }
        case .right:
            if let rightOutcome = updatedLine.rightOutcome {
                let clearedOutcome = rightOutcome.withClearedOddsChange()
                updatedLine = MarketLineData(
                    id: updatedLine.id,
                    leftOutcome: updatedLine.leftOutcome,
                    middleOutcome: updatedLine.middleOutcome,
                    rightOutcome: clearedOutcome,
                    displayMode: updatedLine.displayMode,
                    lineType: updatedLine.lineType,
                    isLineDisabled: updatedLine.isLineDisabled
                )
            }
        }
        
        updateLineInMarketGroup(updatedLine, at: lineIndex)
    }
    
    private func updateLineInMarketGroup(_ updatedLine: MarketLineData, at index: Int) {
        var updatedMarketLines = marketGroupData.marketLines
        updatedMarketLines[index] = updatedLine
        
        marketGroupData = MarketGroupData(
            id: marketGroupData.id,
            groupTitle: marketGroupData.groupTitle,
            marketLines: updatedMarketLines,
            defaultLineType: marketGroupData.defaultLineType,
            isExpanded: marketGroupData.isExpanded,
            maxVisibleLines: marketGroupData.maxVisibleLines
        )
        
        let newDisplayState = MarketOutcomesMultiLineDisplayState(
            marketGroup: marketGroupData,
            isLoading: false,
            errorMessage: nil
        )
        marketStateSubject.send(newDisplayState)
    }
}

// MARK: - Factory for Creating from Real Market Data
extension MarketOutcomesMultiLineViewModel {
    
    /// Creates a MarketOutcomesMultiLineViewModel from real Market and Outcome data
    static func create(
        from markets: [Market],
        marketTypeId: String
    ) -> MarketOutcomesMultiLineViewModel {
        
        let marketGroupData = extractMarketGroupData(from: markets, marketTypeId: marketTypeId)
        return MarketOutcomesMultiLineViewModel(marketGroupData: marketGroupData)
    }
    
    private static func extractMarketGroupData(
        from markets: [Market],
        marketTypeId: String
    ) -> MarketGroupData {
        
        let marketLines = createMarketLinesFromMarkets(markets)
        let lineType = determineLineType(for: marketTypeId)
        
        return MarketGroupData(
            id: marketTypeId,
            groupTitle: nil,
            marketLines: marketLines,
            defaultLineType: lineType,
            isExpanded: true,
            maxVisibleLines: nil
        )
    }
    
    private static func createMarketLinesFromMarkets(_ markets: [Market]) -> [MarketLineData] {
        return markets.compactMap { market in
            guard !market.outcomes.isEmpty else { return nil }
            
            let outcomes = market.outcomes.map { outcome in
                MarketOutcomeData(
                    id: outcome.id,
                    title: outcome.translatedName,
                    value: String(format: "%.2f", outcome.bettingOffer.decimalOdd),
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
                lineType: lineType,
                isLineDisabled: !market.isAvailable
            )
        }
    }
    
    private static func determineLineType(for marketTypeId: String) -> MarketLineType {
        switch marketTypeId {
        case "1", "1x2", "double_chance":
            return .threeColumn
        case "over_under", "both_teams_score", "handicap":
            return .twoColumn
        default:
            return .twoColumn
        }
    }
    
    // MARK: - Sample Market Line Creators
    private static func createHomeDrawAwayMarketLines() -> [MarketLineData] {
        let homeOutcome = MarketOutcomeData(id: "home", title: "1", value: "2.10")
        let drawOutcome = MarketOutcomeData(id: "draw", title: "X", value: "3.40")
        let awayOutcome = MarketOutcomeData(id: "away", title: "2", value: "3.20")
        
        return [
            MarketLineData(
                id: "1x2_main",
                leftOutcome: homeOutcome,
                middleOutcome: drawOutcome,
                rightOutcome: awayOutcome,
                displayMode: .triple,
                lineType: .threeColumn
            )
        ]
    }
    
    private static func createOverUnderMarketLines() -> [MarketLineData] {
        return [
            MarketLineData(
                id: "over_under_2_5",
                leftOutcome: MarketOutcomeData(id: "over_2_5", title: "Over 2.5", value: "1.85"),
                rightOutcome: MarketOutcomeData(id: "under_2_5", title: "Under 2.5", value: "1.95"),
                displayMode: .double,
                lineType: .twoColumn
            ),
            MarketLineData(
                id: "over_under_3_5",
                leftOutcome: MarketOutcomeData(id: "over_3_5", title: "Over 3.5", value: "2.80"),
                rightOutcome: MarketOutcomeData(id: "under_3_5", title: "Under 3.5", value: "1.40"),
                displayMode: .double,
                lineType: .twoColumn
            )
        ]
    }
    
    private static func createBothTeamsScoreMarketLines() -> [MarketLineData] {
        return [
            MarketLineData(
                id: "both_teams_score",
                leftOutcome: MarketOutcomeData(id: "bts_yes", title: "Yes", value: "1.72"),
                rightOutcome: MarketOutcomeData(id: "bts_no", title: "No", value: "2.10"),
                displayMode: .double,
                lineType: .twoColumn
            )
        ]
    }
    
    private static func createGenericMarketLines() -> [MarketLineData] {
        return [
            MarketLineData(
                id: "generic_market",
                leftOutcome: MarketOutcomeData(id: "option_1", title: "Option 1", value: "1.90"),
                rightOutcome: MarketOutcomeData(id: "option_2", title: "Option 2", value: "1.90"),
                displayMode: .double,
                lineType: .twoColumn
            )
        ]
    }
}