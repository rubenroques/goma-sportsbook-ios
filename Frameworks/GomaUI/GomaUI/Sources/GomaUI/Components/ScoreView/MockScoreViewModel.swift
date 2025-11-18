import UIKit
import Combine

/// Mock implementation of ScoreViewModelProtocol for testing and previews
public class MockScoreViewModel: ScoreViewModelProtocol {

    // MARK: - Publishers
    private let scoreCellsSubject = CurrentValueSubject<[ScoreDisplayData], Never>([])
    private let visualStateSubject = CurrentValueSubject<ScoreViewVisualState, Never>(.idle)

    public var scoreCellsPublisher: AnyPublisher<[ScoreDisplayData], Never> {
        scoreCellsSubject.eraseToAnyPublisher()
    }

    public var visualStatePublisher: AnyPublisher<ScoreViewVisualState, Never> {
        visualStateSubject.eraseToAnyPublisher()
    }

    public var currentVisualState: ScoreViewVisualState {
        visualStateSubject.value
    }

    // MARK: - Initialization
    public init(scoreCells: [ScoreDisplayData] = [], visualState: ScoreViewVisualState = .idle) {
        scoreCellsSubject.send(scoreCells)
        visualStateSubject.send(visualState)
    }

    // MARK: - Protocol Methods
    public func updateScoreCells(_ cells: [ScoreDisplayData]) {
        scoreCellsSubject.send(cells)
        if cells.isEmpty {
            visualStateSubject.send(.empty)
        } else {
            visualStateSubject.send(.display)
        }
    }

    public func setVisualState(_ state: ScoreViewVisualState) {
        visualStateSubject.send(state)
    }

    public func clearScores() {
        scoreCellsSubject.send([])
        visualStateSubject.send(.empty)
    }

    public func setLoading() {
        visualStateSubject.send(.loading)
    }

    public func setEmpty() {
        scoreCellsSubject.send([])
        visualStateSubject.send(.empty)
    }
}

// MARK: - Factory Methods
extension MockScoreViewModel {

    /// Simple example showing how easy it is to create score displays
    /// No complex legacy conversion - just create the data you want to show!
    public static var simpleExample: MockScoreViewModel {
        let scoreCells = [
            // Previous sets (simple style with winner highlighting)
            ScoreDisplayData(id: "set1", homeScore: "6", awayScore: "4", style: .simple),
            ScoreDisplayData(id: "set2", homeScore: "4", awayScore: "6", style: .simple),

            // Current set (border style)
            ScoreDisplayData(id: "current_set", homeScore: "3", awayScore: "2", style: .border),

            // Current game (background style)
            ScoreDisplayData(id: "current_game", homeScore: "30", awayScore: "15", style: .background)
        ]
        return MockScoreViewModel(scoreCells: scoreCells, visualState: .display)
    }

    /// Tennis match with multiple sets and current game score
    public static var tennisMatch: MockScoreViewModel {
        let scoreCells = [
            // Current game (both highlighted, separator after, has serving)
            ScoreDisplayData(
                id: "current",
                homeScore: "15",
                awayScore: "30",
                style: .background,
                highlightingMode: .bothHighlight,
                showsTrailingSeparator: true,
                servingPlayer: .away
            ),
            // Set 1 (completed) - winner/loser highlighting
            ScoreDisplayData(
                id: "set1",
                homeScore: "6",
                awayScore: "4",
                style: .simple,
                highlightingMode: .winnerLoser
            ),
            // Set 2 (completed) - winner/loser highlighting
            ScoreDisplayData(
                id: "set2",
                homeScore: "4",
                awayScore: "6",
                style: .simple,
                highlightingMode: .winnerLoser
            ),
            // Set 3 (current) - both highlighted
            ScoreDisplayData(
                id: "set3",
                homeScore: "7",
                awayScore: "6",
                style: .simple,
                highlightingMode: .bothHighlight
            )
        ]
        return MockScoreViewModel(scoreCells: scoreCells, visualState: .display)
    }

    /// Tennis match with advantage scoring (home serving)
    public static var tennisAdvantage: MockScoreViewModel {
        let scoreCells = [
            // Current game with advantage - home serving
            ScoreDisplayData(
                id: "current",
                homeScore: "A",
                awayScore: "40",
                style: .background,
                highlightingMode: .bothHighlight,
                showsTrailingSeparator: true,
                servingPlayer: .home
            ),
            // Set 1 (completed)
            ScoreDisplayData(
                id: "set1",
                homeScore: "6",
                awayScore: "3",
                style: .simple,
                highlightingMode: .winnerLoser
            ),
            // Set 2 (completed)
            ScoreDisplayData(
                id: "set2",
                homeScore: "5",
                awayScore: "6",
                style: .simple,
                highlightingMode: .winnerLoser
            )
        ]
        return MockScoreViewModel(scoreCells: scoreCells, visualState: .display)
    }

    /// Basketball match with quarter scores
    public static var basketballMatch: MockScoreViewModel {
        let scoreCells = [
            // Q1 (completed) - winner/loser highlighting
            ScoreDisplayData(id: "q1", homeScore: "25", awayScore: "22", style: .simple, highlightingMode: .winnerLoser),
            // Q2 (completed) - winner/loser highlighting
            ScoreDisplayData(id: "q2", homeScore: "18", awayScore: "28", style: .simple, highlightingMode: .winnerLoser),
            // Q3 (completed) - winner/loser highlighting
            ScoreDisplayData(id: "q3", homeScore: "31", awayScore: "24", style: .simple, highlightingMode: .winnerLoser),
            // Q4 (current) - winner/loser highlighting
            ScoreDisplayData(id: "q4", homeScore: "26", awayScore: "30", style: .simple, highlightingMode: .winnerLoser),
            // Total - both highlighted
            ScoreDisplayData(id: "total", homeScore: "100", awayScore: "104", style: .background, highlightingMode: .bothHighlight)
        ]
        return MockScoreViewModel(scoreCells: scoreCells, visualState: .display)
    }

    /// Volleyball match with set scores
    public static var volleyballMatch: MockScoreViewModel {
        let scoreCells = [
            ScoreDisplayData(id: "set1", homeScore: "25", awayScore: "21", style: .simple),
            ScoreDisplayData(id: "set2", homeScore: "23", awayScore: "25", style: .simple),
            ScoreDisplayData(id: "set3", homeScore: "22", awayScore: "25", style: .border),
            ScoreDisplayData(id: "total", homeScore: "1", awayScore: "2", style: .background)
        ]
        return MockScoreViewModel(scoreCells: scoreCells, visualState: .display)
    }

    /// Simple football/soccer match
    public static var footballMatch: MockScoreViewModel {
        let scoreCells = [
            ScoreDisplayData(id: "total", homeScore: "2", awayScore: "1", style: .background)
        ]
        return MockScoreViewModel(scoreCells: scoreCells, visualState: .display)
    }

    /// Hockey match with periods
    public static var hockeyMatch: MockScoreViewModel {
        let scoreCells = [
            ScoreDisplayData(id: "p1", homeScore: "1", awayScore: "0", style: .simple),
            ScoreDisplayData(id: "p2", homeScore: "2", awayScore: "3", style: .simple),
            ScoreDisplayData(id: "p3", homeScore: "1", awayScore: "1", style: .border),
            ScoreDisplayData(id: "total", homeScore: "4", awayScore: "4", style: .background)
        ]
        return MockScoreViewModel(scoreCells: scoreCells, visualState: .display)
    }

    /// Large score display (e.g., American football)
    public static var americanFootballMatch: MockScoreViewModel {
        let scoreCells = [
            ScoreDisplayData(id: "q1", homeScore: "7", awayScore: "3", style: .simple),
            ScoreDisplayData(id: "q2", homeScore: "14", awayScore: "10", style: .simple),
            ScoreDisplayData(id: "q3", homeScore: "0", awayScore: "7", style: .simple),
            ScoreDisplayData(id: "q4", homeScore: "6", awayScore: "14", style: .border),
            ScoreDisplayData(id: "total", homeScore: "27", awayScore: "34", style: .background)
        ]
        return MockScoreViewModel(scoreCells: scoreCells, visualState: .display)
    }

    /// Single cell with tied score
    public static var tiedMatch: MockScoreViewModel {
        let scoreCells = [
            ScoreDisplayData(id: "total", homeScore: "2", awayScore: "2", style: .background)
        ]
        return MockScoreViewModel(scoreCells: scoreCells, visualState: .display)
    }

    /// Loading state
    public static var loading: MockScoreViewModel {
        return MockScoreViewModel(scoreCells: [], visualState: .loading)
    }

    /// Empty state
    public static var empty: MockScoreViewModel {
        return MockScoreViewModel(scoreCells: [], visualState: .empty)
    }

    /// Idle state with no scores
    public static var idle: MockScoreViewModel {
        return MockScoreViewModel(scoreCells: [], visualState: .idle)
    }

    /// Maximum cells display test
    public static var maxCells: MockScoreViewModel {
        let scoreCells = [
            ScoreDisplayData(id: "1", homeScore: "6", awayScore: "4", style: .simple),
            ScoreDisplayData(id: "2", homeScore: "3", awayScore: "6", style: .simple),
            ScoreDisplayData(id: "3", homeScore: "6", awayScore: "2", style: .simple),
            ScoreDisplayData(id: "4", homeScore: "4", awayScore: "6", style: .simple),
            ScoreDisplayData(id: "5", homeScore: "7", awayScore: "5", style: .simple),
            ScoreDisplayData(id: "6", homeScore: "3", awayScore: "6", style: .border),
            ScoreDisplayData(id: "current", homeScore: "40", awayScore: "30", style: .background)
        ]
        return MockScoreViewModel(scoreCells: scoreCells, visualState: .display)
    }

    /// Different style combinations
    public static var mixedStyles: MockScoreViewModel {
        let scoreCells = [
            ScoreDisplayData(id: "border1", homeScore: "25", awayScore: "23", style: .border),
            ScoreDisplayData(id: "simple1", homeScore: "21", awayScore: "25", style: .simple),
            ScoreDisplayData(id: "background1", homeScore: "2", awayScore: "1", style: .background),
            ScoreDisplayData(id: "border2", homeScore: "15", awayScore: "12", style: .border)
        ]
        return MockScoreViewModel(scoreCells: scoreCells, visualState: .display)
    }
}

// MARK: - Convenience Helpers
extension MockScoreViewModel {

    /// Simulate updating scores in real-time
    public func simulateScoreUpdate(homeScore: String, awayScore: String, for cellId: String) {
        var currentCells = scoreCellsSubject.value

        if let index = currentCells.firstIndex(where: { $0.id == cellId }) {
            let updatedCell = ScoreDisplayData(
                id: currentCells[index].id,
                homeScore: homeScore,
                awayScore: awayScore,
                style: currentCells[index].style
            )
            currentCells[index] = updatedCell
            updateScoreCells(currentCells)
        }
    }

    /// Add a new score cell
    public func addScoreCell(_ cell: ScoreDisplayData) {
        var currentCells = scoreCellsSubject.value
        currentCells.append(cell)
        updateScoreCells(currentCells)
    }

    /// Remove a score cell by ID
    public func removeScoreCell(withId id: String) {
        var currentCells = scoreCellsSubject.value
        currentCells.removeAll { $0.id == id }
        updateScoreCells(currentCells)
    }
}

// MARK: - Real-World Usage Examples
extension MockScoreViewModel {

    /// Example showing how simple it is to create any sport's score display
    public static func createCustomScoreDisplay() -> MockScoreViewModel {
        // No complex logic needed - just create what you want to show!

        let scores = [
            // Tennis: Show completed sets as simple style
            ScoreDisplayData(id: "set1", homeScore: "7", awayScore: "5", style: .simple),
            ScoreDisplayData(id: "set2", homeScore: "3", awayScore: "6", style: .simple),

            // Current set with border to highlight it's active
            ScoreDisplayData(id: "current_set", homeScore: "4", awayScore: "3", style: .border),

            // Current game score with background for emphasis
            ScoreDisplayData(id: "game", homeScore: "A", awayScore: "40", style: .background)
        ]

        return MockScoreViewModel(scoreCells: scores, visualState: .display)
    }
}
