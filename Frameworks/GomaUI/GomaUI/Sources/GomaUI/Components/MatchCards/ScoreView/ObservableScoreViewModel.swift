import UIKit
import Observation

/// @Observable ViewModel for ScoreView - iOS 18+ automatic observation tracking.
///
/// This is a proof of concept demonstrating the simpler pattern compared to Combine:
/// - No publishers, no subscriptions, no setupBindings()
/// - Just @Observable and direct property access in layoutSubviews()
///
/// Reference: https://steipete.me/posts/2025/automatic-observation-tracking-uikit-appkit
@Observable
@MainActor
public final class ObservableScoreViewModel {

    // MARK: - Observable Properties

    /// Current visual state of the score view
    public var visualState: ScoreDisplayData.VisualState = .idle

    /// Score cells to display
    public var scoreCells: [ScoreDisplayData] = []

    // MARK: - Initialization

    public init(
        visualState: ScoreDisplayData.VisualState = .idle,
        scoreCells: [ScoreDisplayData] = []
    ) {
        self.visualState = visualState
        self.scoreCells = scoreCells
    }

    // MARK: - Mutation Methods

    public func updateScoreCells(_ cells: [ScoreDisplayData]) {
        scoreCells = cells
        visualState = cells.isEmpty ? .empty : .display
    }

    public func setLoading() {
        visualState = .loading
    }

    public func setEmpty() {
        scoreCells = []
        visualState = .empty
    }
}

// MARK: - Factory Methods

extension ObservableScoreViewModel {

    // MARK: - Sport Variants

    /// Tennis match with serving indicator, separator, and multiple sets
    public static var tennisMatch: ObservableScoreViewModel {
        ObservableScoreViewModel(
            visualState: .display,
            scoreCells: [
                ScoreDisplayData(
                    id: "current",
                    homeScore: "15",
                    awayScore: "30",
                    style: .background,
                    highlightingMode: .bothHighlight,
                    showsTrailingSeparator: true,
                    servingPlayer: .away
                ),
                ScoreDisplayData(id: "set1", homeScore: "6", awayScore: "4", style: .simple, highlightingMode: .winnerLoser),
                ScoreDisplayData(id: "set2", homeScore: "4", awayScore: "6", style: .simple, highlightingMode: .winnerLoser),
                ScoreDisplayData(id: "set3", homeScore: "7", awayScore: "6", style: .simple, highlightingMode: .bothHighlight)
            ]
        )
    }

    /// Tennis match with advantage scoring (home serving)
    public static var tennisAdvantage: ObservableScoreViewModel {
        ObservableScoreViewModel(
            visualState: .display,
            scoreCells: [
                ScoreDisplayData(
                    id: "current",
                    homeScore: "A",
                    awayScore: "40",
                    style: .background,
                    highlightingMode: .bothHighlight,
                    showsTrailingSeparator: true,
                    servingPlayer: .home
                ),
                ScoreDisplayData(id: "set1", homeScore: "6", awayScore: "3", style: .simple, highlightingMode: .winnerLoser),
                ScoreDisplayData(id: "set2", homeScore: "5", awayScore: "6", style: .simple, highlightingMode: .winnerLoser)
            ]
        )
    }

    /// Basketball match with quarters and total
    public static var basketballMatch: ObservableScoreViewModel {
        ObservableScoreViewModel(
            visualState: .display,
            scoreCells: [
                ScoreDisplayData(id: "q1", homeScore: "25", awayScore: "22", style: .simple, highlightingMode: .winnerLoser),
                ScoreDisplayData(id: "q2", homeScore: "18", awayScore: "28", style: .simple, highlightingMode: .winnerLoser),
                ScoreDisplayData(id: "q3", homeScore: "31", awayScore: "24", style: .simple, highlightingMode: .winnerLoser),
                ScoreDisplayData(id: "q4", homeScore: "26", awayScore: "30", style: .simple, highlightingMode: .winnerLoser),
                ScoreDisplayData(id: "total", homeScore: "100", awayScore: "104", style: .background, highlightingMode: .bothHighlight)
            ]
        )
    }

    /// Simple football match
    public static var footballMatch: ObservableScoreViewModel {
        ObservableScoreViewModel(
            visualState: .display,
            scoreCells: [
                ScoreDisplayData(id: "total", homeScore: "2", awayScore: "1", style: .background, highlightingMode: .bothHighlight)
            ]
        )
    }

    /// Hockey match with periods
    public static var hockeyMatch: ObservableScoreViewModel {
        ObservableScoreViewModel(
            visualState: .display,
            scoreCells: [
                ScoreDisplayData(id: "p1", homeScore: "1", awayScore: "0", style: .simple),
                ScoreDisplayData(id: "p2", homeScore: "2", awayScore: "3", style: .simple),
                ScoreDisplayData(id: "p3", homeScore: "1", awayScore: "1", style: .border),
                ScoreDisplayData(id: "total", homeScore: "4", awayScore: "4", style: .background)
            ]
        )
    }

    // MARK: - Visual States

    /// Loading state
    public static var loading: ObservableScoreViewModel {
        ObservableScoreViewModel(visualState: .loading, scoreCells: [])
    }

    /// Empty state
    public static var empty: ObservableScoreViewModel {
        ObservableScoreViewModel(visualState: .empty, scoreCells: [])
    }

    /// Idle state
    public static var idle: ObservableScoreViewModel {
        ObservableScoreViewModel(visualState: .idle, scoreCells: [])
    }

    /// Simple example for display state
    public static var simpleExample: ObservableScoreViewModel {
        ObservableScoreViewModel(
            visualState: .display,
            scoreCells: [
                ScoreDisplayData(id: "set1", homeScore: "6", awayScore: "4", style: .simple),
                ScoreDisplayData(id: "set2", homeScore: "4", awayScore: "6", style: .simple),
                ScoreDisplayData(id: "current_set", homeScore: "3", awayScore: "2", style: .border),
                ScoreDisplayData(id: "current_game", homeScore: "30", awayScore: "15", style: .background)
            ]
        )
    }

    // MARK: - Style Variants

    /// Mixed styles example
    public static var mixedStyles: ObservableScoreViewModel {
        ObservableScoreViewModel(
            visualState: .display,
            scoreCells: [
                ScoreDisplayData(id: "border1", homeScore: "25", awayScore: "23", style: .border),
                ScoreDisplayData(id: "simple1", homeScore: "21", awayScore: "25", style: .simple),
                ScoreDisplayData(id: "background1", homeScore: "2", awayScore: "1", style: .background),
                ScoreDisplayData(id: "border2", homeScore: "15", awayScore: "12", style: .border)
            ]
        )
    }

    /// Factory for simple style only
    public static func simpleStyle() -> ObservableScoreViewModel {
        ObservableScoreViewModel(
            visualState: .display,
            scoreCells: [
                ScoreDisplayData(id: "s1", homeScore: "6", awayScore: "4", style: .simple),
                ScoreDisplayData(id: "s2", homeScore: "3", awayScore: "6", style: .simple)
            ]
        )
    }

    /// Factory for border style only
    public static func borderStyle() -> ObservableScoreViewModel {
        ObservableScoreViewModel(
            visualState: .display,
            scoreCells: [
                ScoreDisplayData(id: "b1", homeScore: "25", awayScore: "23", style: .border),
                ScoreDisplayData(id: "b2", homeScore: "21", awayScore: "25", style: .border)
            ]
        )
    }

    /// Factory for background style only
    public static func backgroundStyle() -> ObservableScoreViewModel {
        ObservableScoreViewModel(
            visualState: .display,
            scoreCells: [
                ScoreDisplayData(id: "bg1", homeScore: "100", awayScore: "98", style: .background),
                ScoreDisplayData(id: "bg2", homeScore: "89", awayScore: "112", style: .background)
            ]
        )
    }
}
