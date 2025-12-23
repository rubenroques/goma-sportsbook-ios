import UIKit
import Combine
import GomaUI
import ServicesProvider
import GomaLogger

/// Production implementation of InlineScoreViewModelProtocol for horizontal live match scores
/// Transforms raw match score data into horizontal inline score columns
final class InlineScoreViewModel: InlineScoreViewModelProtocol {

    // MARK: - Publishers
    private let displayStateSubject: CurrentValueSubject<InlineScoreDisplayState, Never>

    public var displayStatePublisher: AnyPublisher<InlineScoreDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }

    public var currentDisplayState: InlineScoreDisplayState {
        displayStateSubject.value
    }

    // MARK: - Initialization

    /// Simple initializer for manual column creation (testing/mocking)
    init(columns: [InlineScoreColumnData] = [], isVisible: Bool = true) {
        self.displayStateSubject = CurrentValueSubject(
            InlineScoreDisplayState(columns: columns, isVisible: isVisible)
        )
    }

    /// Failable initializer that transforms raw match data into score columns
    /// Returns nil if no scores are available to display
    convenience init?(
        detailedScores: [String: Score]?,
        activePlayerServing: ServicesProvider.ActivePlayerServe?,
        homeScore: Int?,
        awayScore: Int?,
        sportId: String
    ) {
        let columns = Self.transformScores(
            detailedScores: detailedScores,
            activePlayerServing: activePlayerServing,
            homeScore: homeScore,
            awayScore: awayScore,
            sportId: sportId
        )

        guard !columns.isEmpty else {
            return nil
        }

        self.init(columns: columns, isVisible: true)
    }

    /// Convenience initializer that creates InlineScoreViewModel from a Match object
    convenience init?(from match: Match) {
        let mappedServing: ServicesProvider.ActivePlayerServe?
        switch match.activePlayerServe {
        case .home:
            mappedServing = .home
        case .away:
            mappedServing = .away
        case .none:
            mappedServing = nil
        }

        self.init(
            detailedScores: match.detailedScores,
            activePlayerServing: mappedServing,
            homeScore: match.homeParticipantScore,
            awayScore: match.awayParticipantScore,
            sportId: match.sport.id
        )
    }

    // MARK: - Protocol Methods

    func updateColumns(_ columns: [InlineScoreColumnData]) {
        let newState = InlineScoreDisplayState(
            columns: columns,
            isVisible: displayStateSubject.value.isVisible
        )
        displayStateSubject.send(newState)
    }

    func setVisible(_ visible: Bool) {
        let newState = InlineScoreDisplayState(
            columns: displayStateSubject.value.columns,
            isVisible: visible
        )
        displayStateSubject.send(newState)
    }

    func clearScores() {
        displayStateSubject.send(.empty)
    }

    // MARK: - Update from EventLiveData

    /// Updates the score display from live data updates
    func update(from eventLiveData: EventLiveData, sportId: String) {
        let mappedScores = eventLiveData.detailedScores.map {
            ServiceProviderModelMapper.scoresDictionary(fromInternalScoresDictionary: $0)
        }

        let columns = Self.transformScores(
            detailedScores: mappedScores,
            activePlayerServing: eventLiveData.activePlayerServing,
            homeScore: eventLiveData.homeScore,
            awayScore: eventLiveData.awayScore,
            sportId: sportId
        )

        let newState = InlineScoreDisplayState(columns: columns, isVisible: !columns.isEmpty)
        displayStateSubject.send(newState)
    }

    // MARK: - Score Transformation Logic

    /// Transforms raw match score data into horizontal InlineScoreColumnData
    private static func transformScores(
        detailedScores: [String: Score]?,
        activePlayerServing: ServicesProvider.ActivePlayerServe?,
        homeScore: Int?,
        awayScore: Int?,
        sportId: String
    ) -> [InlineScoreColumnData] {

        // Type C sports: Tennis, Volleyball, Badminton, Table Tennis, Beach Volleyball
        let isTypeCsport = ["3", "20", "64", "63", "14"].contains(sportId)

        GomaLogger.debug(.realtime, category: "INLINE_SCORE", "Transforming scores for sport: \(sportId) (Type C: \(isTypeCsport))")

        var columns: [InlineScoreColumnData] = []

        if let detailedScores = detailedScores, !detailedScores.isEmpty {
            let sortedScores = detailedScores.sorted(by: { $0.value.sortValue < $1.value.sortValue })

            if isTypeCsport {
                // Tennis-like sports: [Game Points] | [Set1] [Set2] [Set3]
                let gameParts = sortedScores.filter { entry in
                    if case .gamePart = entry.value { return true }
                    return false
                }

                let sets = sortedScores.filter { entry in
                    if case .set = entry.value { return true }
                    return false
                }

                let lastSetIndex = sets.compactMap { entry -> Int? in
                    if case .set(let index, _, _) = entry.value {
                        return index
                    }
                    return nil
                }.max()

                // Game parts FIRST (with separator after)
                for (scoreName, score) in gameParts {
                    if case .gamePart(_, let home, let away) = score {
                        let column = InlineScoreColumnData(
                            id: "game-\(scoreName)",
                            homeScore: home != nil ? "\(home!)" : "-",
                            awayScore: away != nil ? "\(away!)" : "-",
                            highlightingMode: .bothHighlight,
                            showsTrailingSeparator: true
                        )
                        columns.append(column)
                    }
                }

                // Then sets in order
                for (scoreName, score) in sets {
                    if case .set(let index, let home, let away) = score {
                        let isCurrentSet = (index == lastSetIndex)
                        let highlighting: InlineScoreColumnData.HighlightingMode = isCurrentSet ? .bothHighlight : .winnerLoser

                        let column = InlineScoreColumnData(
                            id: "set-\(scoreName)",
                            homeScore: home != nil ? "\(home!)" : "-",
                            awayScore: away != nil ? "\(away!)" : "-",
                            highlightingMode: highlighting,
                            showsTrailingSeparator: false
                        )
                        columns.append(column)
                    }
                }
            } else {
                // Non-Type C sports (Football, Basketball): Process all in order
                let lastSetIndex = sortedScores.compactMap { entry -> Int? in
                    if case .set(let index, _, _) = entry.value {
                        return index
                    }
                    return nil
                }.max()

                for (scoreName, score) in sortedScores {
                    let column: InlineScoreColumnData

                    switch score {
                    case .gamePart(_, let home, let away):
                        column = InlineScoreColumnData(
                            id: "game-\(scoreName)",
                            homeScore: home != nil ? "\(home!)" : "-",
                            awayScore: away != nil ? "\(away!)" : "-",
                            highlightingMode: .bothHighlight,
                            showsTrailingSeparator: false
                        )
                        columns.append(column)

                    case .set(let index, let home, let away):
                        let isCurrentSet = (index == lastSetIndex)
                        let highlighting: InlineScoreColumnData.HighlightingMode = isCurrentSet ? .bothHighlight : .winnerLoser

                        column = InlineScoreColumnData(
                            id: "set-\(scoreName)",
                            homeScore: home != nil ? "\(home!)" : "-",
                            awayScore: away != nil ? "\(away!)" : "-",
                            highlightingMode: highlighting,
                            showsTrailingSeparator: false
                        )
                        columns.append(column)

                    case .matchFull(let home, let away):
                        // For Basketball: Total | Q1 Q2 Q3 Q4
                        // Show total first with separator
                        column = InlineScoreColumnData(
                            id: "match-\(scoreName)",
                            homeScore: home != nil ? "\(home!)" : "-",
                            awayScore: away != nil ? "\(away!)" : "-",
                            highlightingMode: .bothHighlight,
                            showsTrailingSeparator: columns.isEmpty // Separator only if it's first (total)
                        )
                        // Insert at beginning if this is the main score
                        if columns.isEmpty {
                            columns.append(column)
                        } else {
                            columns.insert(column, at: 0)
                        }
                    }
                }
            }
        }

        // Fallback to main score if no detailed scores
        if columns.isEmpty {
            if let homeScore = homeScore, let awayScore = awayScore {
                GomaLogger.debug(.realtime, category: "INLINE_SCORE", "Using main score: \(homeScore) - \(awayScore)")
                let mainColumn = InlineScoreColumnData(
                    id: "match",
                    homeScore: "\(homeScore)",
                    awayScore: "\(awayScore)",
                    highlightingMode: .bothHighlight,
                    showsTrailingSeparator: false
                )
                columns.append(mainColumn)
            }
        }

        GomaLogger.debug(.realtime, category: "INLINE_SCORE", "Created \(columns.count) score columns")
        return columns
    }
}
