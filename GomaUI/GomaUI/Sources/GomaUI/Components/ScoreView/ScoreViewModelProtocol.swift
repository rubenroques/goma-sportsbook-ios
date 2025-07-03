import UIKit
import Combine

// MARK: - Data Models

/// Represents display data for a single score cell
public struct ScoreDisplayData: Equatable, Hashable {
    public let id: String
    public let homeScore: String
    public let awayScore: String
    public let index: Int
    public let style: ScoreCellStyle

    public init(id: String, homeScore: String, awayScore: String, index: Int = 0, style: ScoreCellStyle) {
        self.id = id
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.index = index
        self.style = style
    }
}

/// Visual styles for score cells
public enum ScoreCellStyle: Equatable, CaseIterable {
    case simple    // Plain text with winner highlighting
    case border    // Text with border outline
    case background // Text with background fill
}

/// Visual states for the entire ScoreView
public enum ScoreViewVisualState: Equatable {
    case idle
    case loading
    case display
    case empty
}

// MARK: - Protocol

/// Protocol defining the interface for ScoreView ViewModels
public protocol ScoreViewModelProtocol {
    /// Publisher for the array of score cells to display
    var scoreCellsPublisher: AnyPublisher<[ScoreDisplayData], Never> { get }

    /// Publisher for the overall visual state
    var visualStatePublisher: AnyPublisher<ScoreViewVisualState, Never> { get }

    /// Current visual state (for immediate access)
    var currentVisualState: ScoreViewVisualState { get }

    /// Update the score cells data
    func updateScoreCells(_ cells: [ScoreDisplayData])

    /// Set the visual state
    func setVisualState(_ state: ScoreViewVisualState)

    /// Convenience method to clear all scores
    func clearScores()

    /// Convenience method to set loading state
    func setLoading()

    /// Convenience method to set empty state
    func setEmpty()
}
