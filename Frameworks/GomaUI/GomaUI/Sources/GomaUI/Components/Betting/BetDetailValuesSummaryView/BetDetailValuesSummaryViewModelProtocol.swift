import Foundation
import Combine

/// Data model for bet detail values summary
public struct BetDetailValuesSummaryData: Equatable {
    public let headerRow: BetDetailRowData?     // Optional header (date)
    public let contentRows: [BetDetailRowData]  // Main value rows
    public let footerRow: BetDetailRowData?     // Optional footer (result)
    
    public init(
        headerRow: BetDetailRowData? = nil,
        contentRows: [BetDetailRowData],
        footerRow: BetDetailRowData? = nil
    ) {
        self.headerRow = headerRow
        self.contentRows = contentRows
        self.footerRow = footerRow
    }
}

/// Protocol defining the interface for BetDetailValuesSummaryView ViewModels
public protocol BetDetailValuesSummaryViewModelProtocol {
    /// Publisher for the bet detail values summary data
    var dataPublisher: AnyPublisher<BetDetailValuesSummaryData, Never> { get }
}
