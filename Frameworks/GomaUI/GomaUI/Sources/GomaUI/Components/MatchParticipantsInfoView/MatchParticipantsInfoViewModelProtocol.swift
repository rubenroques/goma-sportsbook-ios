import Combine
import UIKit

// MARK: - Data Models

/// Represents the display layout mode for the match participants info
public enum MatchDisplayMode: Equatable, Hashable {
    case horizontal
    case vertical
}

/// Represents the current state of the match
public enum MatchState: Equatable, Hashable {
    case preLive(date: String, time: String)
    case live(score: String, matchTime: String?)
    case ended(score: String)
}

/// Indicates which participant is currently serving (tennis, volleyball, etc.)
public enum ServingIndicator: Equatable, Hashable {
    case none
    case home
    case away
}

/// Contains match participants data and current match status
public struct MatchParticipantsData: Equatable, Hashable {
    public let homeParticipantName: String
    public let awayParticipantName: String
    public let matchState: MatchState
    public let servingIndicator: ServingIndicator
    
    public init(
        homeParticipantName: String,
        awayParticipantName: String,
        matchState: MatchState,
        servingIndicator: ServingIndicator = .none
    ) {
        self.homeParticipantName = homeParticipantName
        self.awayParticipantName = awayParticipantName
        self.matchState = matchState
        self.servingIndicator = servingIndicator
    }
}


// MARK: - Display State

/// Represents the complete display state for the match participants info component
public struct MatchParticipantsDisplayState: Equatable {
    public let displayMode: MatchDisplayMode
    public let matchData: MatchParticipantsData
    
    public init(displayMode: MatchDisplayMode, matchData: MatchParticipantsData) {
        self.displayMode = displayMode
        self.matchData = matchData
    }
}

// MARK: - View Model Protocol

/// Protocol defining the interface for MatchParticipantsInfoView view model
public protocol MatchParticipantsInfoViewModelProtocol {
    /// Publisher for reactive display state updates
    var displayStatePublisher: AnyPublisher<MatchParticipantsDisplayState, Never> { get }
    
    /// Publisher for the ScoreView model (used in vertical layout)
    var scoreViewModelPublisher: AnyPublisher<ScoreViewModelProtocol?, Never> { get }
    
    /// Sets the display mode (horizontal or vertical)
    func setDisplayMode(_ mode: MatchDisplayMode)
    
    /// Updates match data
    func updateMatchData(_ data: MatchParticipantsData)
    
    /// Updates complete display state
    func updateDisplayState(_ state: MatchParticipantsDisplayState)
}