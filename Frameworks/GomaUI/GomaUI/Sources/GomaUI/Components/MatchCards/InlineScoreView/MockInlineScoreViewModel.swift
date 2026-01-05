import UIKit
import Combine

/// Mock implementation of InlineScoreViewModelProtocol for testing and previews
public final class MockInlineScoreViewModel: InlineScoreViewModelProtocol {

    // MARK: - Private Properties
    private let displayStateSubject: CurrentValueSubject<InlineScoreDisplayState, Never>

    // MARK: - Protocol Properties
    public var displayStatePublisher: AnyPublisher<InlineScoreDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }

    public var currentDisplayState: InlineScoreDisplayState {
        displayStateSubject.value
    }

    // MARK: - Initialization
    public init(columns: [InlineScoreColumnData], isVisible: Bool = true) {
        let state = InlineScoreDisplayState(columns: columns, isVisible: isVisible)
        self.displayStateSubject = CurrentValueSubject(state)
    }

    // MARK: - Protocol Methods
    public func updateColumns(_ columns: [InlineScoreColumnData]) {
        let newState = InlineScoreDisplayState(
            columns: columns,
            isVisible: displayStateSubject.value.isVisible
        )
        displayStateSubject.send(newState)
    }

    public func setVisible(_ visible: Bool) {
        let newState = InlineScoreDisplayState(
            columns: displayStateSubject.value.columns,
            isVisible: visible
        )
        displayStateSubject.send(newState)
    }

    public func clearScores() {
        displayStateSubject.send(.empty)
    }
}

// MARK: - Factory Methods
extension MockInlineScoreViewModel {

    /// Tennis match with current points and set scores
    /// Format: [30|15] | [6] [4] [0] (points separator sets)
    public static var tennisMatch: MockInlineScoreViewModel {
        let columns: [InlineScoreColumnData] = [
            // Current game points (with separator)
            InlineScoreColumnData(
                id: "points",
                homeScore: "30",
                awayScore: "15",
                highlightingMode: .bothHighlight,
                showsTrailingSeparator: true
            ),
            // Set 1 (home won)
            InlineScoreColumnData(
                id: "set1",
                homeScore: "6",
                awayScore: "4",
                highlightingMode: .winnerLoser
            ),
            // Set 2 (away won)
            InlineScoreColumnData(
                id: "set2",
                homeScore: "4",
                awayScore: "6",
                highlightingMode: .winnerLoser
            ),
            // Set 3 (in progress)
            InlineScoreColumnData(
                id: "set3",
                homeScore: "2",
                awayScore: "1",
                highlightingMode: .bothHighlight
            )
        ]
        return MockInlineScoreViewModel(columns: columns)
    }

    /// Tennis match in second set
    public static var tennisSecondSet: MockInlineScoreViewModel {
        let columns: [InlineScoreColumnData] = [
            InlineScoreColumnData(
                id: "points",
                homeScore: "0",
                awayScore: "15",
                highlightingMode: .bothHighlight,
                showsTrailingSeparator: true
            ),
            InlineScoreColumnData(
                id: "set1",
                homeScore: "6",
                awayScore: "4",
                highlightingMode: .winnerLoser
            ),
            InlineScoreColumnData(
                id: "set2",
                homeScore: "3",
                awayScore: "2",
                highlightingMode: .bothHighlight
            )
        ]
        return MockInlineScoreViewModel(columns: columns)
    }

    /// Football match with single score
    public static var footballMatch: MockInlineScoreViewModel {
        let columns: [InlineScoreColumnData] = [
            InlineScoreColumnData(
                id: "score",
                homeScore: "2",
                awayScore: "1",
                highlightingMode: .bothHighlight
            )
        ]
        return MockInlineScoreViewModel(columns: columns)
    }

    /// Football match tied
    public static var footballMatchTied: MockInlineScoreViewModel {
        let columns: [InlineScoreColumnData] = [
            InlineScoreColumnData(
                id: "score",
                homeScore: "1",
                awayScore: "1",
                highlightingMode: .bothHighlight
            )
        ]
        return MockInlineScoreViewModel(columns: columns)
    }

    /// Basketball match with quarter scores
    public static var basketballMatch: MockInlineScoreViewModel {
        let columns: [InlineScoreColumnData] = [
            // Total (highlighted)
            InlineScoreColumnData(
                id: "total",
                homeScore: "78",
                awayScore: "82",
                highlightingMode: .bothHighlight,
                showsTrailingSeparator: true
            ),
            // Q1
            InlineScoreColumnData(
                id: "q1",
                homeScore: "22",
                awayScore: "18",
                highlightingMode: .winnerLoser
            ),
            // Q2
            InlineScoreColumnData(
                id: "q2",
                homeScore: "19",
                awayScore: "24",
                highlightingMode: .winnerLoser
            ),
            // Q3
            InlineScoreColumnData(
                id: "q3",
                homeScore: "21",
                awayScore: "22",
                highlightingMode: .winnerLoser
            ),
            // Q4 (current)
            InlineScoreColumnData(
                id: "q4",
                homeScore: "16",
                awayScore: "18",
                highlightingMode: .bothHighlight
            )
        ]
        return MockInlineScoreViewModel(columns: columns)
    }

    /// Volleyball match with set scores
    public static var volleyballMatch: MockInlineScoreViewModel {
        let columns: [InlineScoreColumnData] = [
            // Current set points
            InlineScoreColumnData(
                id: "points",
                homeScore: "15",
                awayScore: "12",
                highlightingMode: .bothHighlight,
                showsTrailingSeparator: true
            ),
            // Set 1
            InlineScoreColumnData(
                id: "set1",
                homeScore: "25",
                awayScore: "22",
                highlightingMode: .winnerLoser
            ),
            // Set 2
            InlineScoreColumnData(
                id: "set2",
                homeScore: "23",
                awayScore: "25",
                highlightingMode: .winnerLoser
            ),
            // Set 3 (current)
            InlineScoreColumnData(
                id: "set3",
                homeScore: "1",
                awayScore: "0",
                highlightingMode: .noHighlight
            )
        ]
        return MockInlineScoreViewModel(columns: columns)
    }

    /// Hidden score (pre-live state)
    public static var hidden: MockInlineScoreViewModel {
        MockInlineScoreViewModel(columns: [], isVisible: false)
    }

    /// Empty score (no data)
    public static var empty: MockInlineScoreViewModel {
        MockInlineScoreViewModel(columns: [], isVisible: true)
    }

    /// Custom score with flexible columns
    public static func custom(columns: [InlineScoreColumnData], isVisible: Bool = true) -> MockInlineScoreViewModel {
        MockInlineScoreViewModel(columns: columns, isVisible: isVisible)
    }
}
