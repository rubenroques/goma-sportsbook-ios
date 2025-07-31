import Combine
import UIKit

// MARK: - Data Models
public struct MarketLineData: Equatable, Hashable {
    public let id: String
    public let leftOutcome: MarketOutcomeData?
    public let middleOutcome: MarketOutcomeData?  // For 3-column markets
    public let rightOutcome: MarketOutcomeData?
    public let displayMode: MarketDisplayMode  // .double, .triple, .suspended(text)
    public let lineType: MarketLineType

    public init(id: String,
                leftOutcome: MarketOutcomeData? = nil,
                middleOutcome: MarketOutcomeData? = nil,
                rightOutcome: MarketOutcomeData? = nil,
                displayMode: MarketDisplayMode = .double,
                lineType: MarketLineType = .twoColumn) {
        self.id = id
        self.leftOutcome = leftOutcome
        self.middleOutcome = middleOutcome
        self.rightOutcome = rightOutcome
        self.displayMode = displayMode
        self.lineType = lineType
    }
}

// MARK: - Market Line Type
public enum MarketLineType: Equatable, Hashable {
    case twoColumn   // Left + Right (like Over/Under)
    case threeColumn // Left + Middle + Right (like Home/Draw/Away)
}

// MARK: - Market Group Data
public struct MarketGroupData: Equatable, Hashable {
    public let id: String
    public let groupTitle: String?  // Optional group title
    public let marketLines: [MarketLineData]

    public init(id: String,
                groupTitle: String? = nil,
                marketLines: [MarketLineData] = []) {
        self.id = id
        self.groupTitle = groupTitle
        self.marketLines = marketLines
    }
}

// MARK: - Display State  
public struct MarketOutcomesMultiLineDisplayState: Equatable {
    public let groupTitle: String?
    public let lineCount: Int
    public let isEmpty: Bool
    public let emptyStateMessage: String?

    public init(groupTitle: String? = nil,
                lineCount: Int = 0,
                isEmpty: Bool = false,
                emptyStateMessage: String? = nil) {
        self.groupTitle = groupTitle
        self.lineCount = lineCount
        self.isEmpty = isEmpty
        self.emptyStateMessage = emptyStateMessage
    }
}

// MARK: - View Model Protocol
public protocol MarketOutcomesMultiLineViewModelProtocol {
    // MARK: - Line View Models (Simple Aggregation)
    /// Publisher that emits the array of line view models
    var lineViewModelsPublisher: AnyPublisher<[MarketOutcomesLineViewModelProtocol], Never> { get }
    
    /// Direct access to current line view models
    var lineViewModels: [MarketOutcomesLineViewModelProtocol] { get }
    
    /// Simple display state (title, count)
    var displayStatePublisher: AnyPublisher<MarketOutcomesMultiLineDisplayState, Never> { get }
} 
