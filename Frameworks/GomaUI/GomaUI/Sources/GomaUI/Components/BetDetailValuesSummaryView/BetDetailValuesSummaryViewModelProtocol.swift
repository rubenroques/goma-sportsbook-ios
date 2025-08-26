import Foundation
import Combine

/// Data model for bet detail values summary
public struct BetDetailValuesSummaryData: Equatable {
    public let rows: [BetDetailRowData]
    
    public init(rows: [BetDetailRowData]) {
        self.rows = rows
    }
}

/// Protocol defining the interface for BetDetailValuesSummaryView ViewModels
public protocol BetDetailValuesSummaryViewModelProtocol {
    /// Publisher for the bet detail values summary data
    var dataPublisher: AnyPublisher<BetDetailValuesSummaryData, Never> { get }
}
