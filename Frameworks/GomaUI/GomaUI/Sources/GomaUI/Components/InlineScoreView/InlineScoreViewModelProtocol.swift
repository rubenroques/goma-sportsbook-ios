import UIKit
import Combine

// MARK: - Data Models

/// Represents display data for a single inline score column
public struct InlineScoreColumnData: Equatable, Hashable {
    public let id: String
    public let homeScore: String
    public let awayScore: String
    public let highlightingMode: HighlightingMode
    public let showsTrailingSeparator: Bool

    public init(
        id: String,
        homeScore: String,
        awayScore: String,
        highlightingMode: HighlightingMode = .bothHighlight,
        showsTrailingSeparator: Bool = false
    ) {
        self.id = id
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.highlightingMode = highlightingMode
        self.showsTrailingSeparator = showsTrailingSeparator
    }

    /// Defines how scores should be visually highlighted
    public enum HighlightingMode: Equatable, Hashable {
        case winnerLoser    // Winner in primary color, loser dimmed (for completed sets)
        case bothHighlight  // Both scores in highlight color (for current game/points)
        case noHighlight    // Both scores in default text color
    }
}

/// Display state for InlineScoreView
public struct InlineScoreDisplayState: Equatable, Hashable {
    public let columns: [InlineScoreColumnData]
    public let isVisible: Bool
    public let isEmpty: Bool

    public init(columns: [InlineScoreColumnData], isVisible: Bool = true) {
        self.columns = columns
        self.isVisible = isVisible
        self.isEmpty = columns.isEmpty
    }

    public static let hidden = InlineScoreDisplayState(columns: [], isVisible: false)
    public static let empty = InlineScoreDisplayState(columns: [], isVisible: true)
}

// MARK: - Protocol

/// Protocol defining the interface for InlineScoreView ViewModels
public protocol InlineScoreViewModelProtocol: AnyObject {
    /// Publisher for the display state
    var displayStatePublisher: AnyPublisher<InlineScoreDisplayState, Never> { get }

    /// Current display state (for synchronous access)
    var currentDisplayState: InlineScoreDisplayState { get }

    /// Update the score columns data
    func updateColumns(_ columns: [InlineScoreColumnData])

    /// Set visibility
    func setVisible(_ visible: Bool)

    /// Clear all scores
    func clearScores()
}
