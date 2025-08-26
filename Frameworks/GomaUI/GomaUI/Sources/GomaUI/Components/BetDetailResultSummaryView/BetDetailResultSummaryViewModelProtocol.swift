import Foundation
import Combine

/// Result state for bet detail result summary
public enum BetDetailResultState: Equatable {
    case won
    case lost
    case draw
}

/// Data model for bet detail result summary
public struct BetDetailResultSummaryData: Equatable {
    public let betPlacedDate: String
    public let matchDetails: String
    public let betType: String
    public let resultState: BetDetailResultState
    
    public init(
        betPlacedDate: String,
        matchDetails: String,
        betType: String,
        resultState: BetDetailResultState
    ) {
        self.betPlacedDate = betPlacedDate
        self.matchDetails = matchDetails
        self.betType = betType
        self.resultState = resultState
    }
}

/// Protocol defining the interface for BetDetailResultSummaryView ViewModels
public protocol BetDetailResultSummaryViewModelProtocol {
    /// Publisher for the bet detail result summary data
    var dataPublisher: AnyPublisher<BetDetailResultSummaryData, Never> { get }
}
