import Foundation
import Combine

/// Result state for bet detail result summary
public enum BetDetailResultState: Equatable {
    case won
    case lost
    case draw
    case open
}

/// Data model for bet detail result summary
public struct BetDetailResultSummaryData: Equatable {
    public let matchDetails: String
    public let betType: String
    public let resultState: BetDetailResultState
    
    public init(
        matchDetails: String,
        betType: String,
        resultState: BetDetailResultState
    ) {
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
