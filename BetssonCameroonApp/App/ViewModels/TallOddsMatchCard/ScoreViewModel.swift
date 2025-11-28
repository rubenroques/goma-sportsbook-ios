import UIKit
import Combine
import GomaUI
import ServicesProvider
import GomaLogger

/// Production implementation of ScoreViewModelProtocol for live match scores
/// Handles transformation of raw match score data into displayable score cells
final class ScoreViewModel: ScoreViewModelProtocol {

    // MARK: - Publishers
    private let scoreCellsSubject = CurrentValueSubject<[ScoreDisplayData], Never>([])
    private let visualStateSubject = CurrentValueSubject<ScoreDisplayData.VisualState, Never>(.idle)

    public var scoreCellsPublisher: AnyPublisher<[ScoreDisplayData], Never> {
        scoreCellsSubject.eraseToAnyPublisher()
    }

    public var visualStatePublisher: AnyPublisher<ScoreDisplayData.VisualState, Never> {
        visualStateSubject.eraseToAnyPublisher()
    }

    public var currentVisualState: ScoreDisplayData.VisualState {
        visualStateSubject.value
    }

    // MARK: - Initialization

    /// Simple initializer for manual score cell creation (testing/mocking)
    init(scoreCells: [ScoreDisplayData] = [], visualState: ScoreDisplayData.VisualState = .idle) {
        scoreCellsSubject.send(scoreCells)
        visualStateSubject.send(visualState)
    }

    /// Failable initializer that transforms raw match data into score cells
    /// Returns nil if no scores are available to display
    convenience init?(
        detailedScores: [String: Score]?,
        activePlayerServing: ServicesProvider.ActivePlayerServe?,
        homeScore: Int?,
        awayScore: Int?,
        sportId: String
    ) {
        let scoreCells = Self.transformScores(
            detailedScores: detailedScores,
            activePlayerServing: activePlayerServing,
            homeScore: homeScore,
            awayScore: awayScore,
            sportId: sportId
        )

        guard !scoreCells.isEmpty else {
            return nil
        }

        self.init(scoreCells: scoreCells, visualState: .display)
    }

    /// Convenience initializer that creates ScoreViewModel from a Match object
    convenience init?(from match: Match) {
        // Map Match.ActivePlayerServe to ServicesProvider.ActivePlayerServe
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
    func updateScoreCells(_ cells: [ScoreDisplayData]) {
        scoreCellsSubject.send(cells)
        if cells.isEmpty {
            visualStateSubject.send(.empty)
        } else {
            visualStateSubject.send(.display)
        }
    }

    func setVisualState(_ state: ScoreDisplayData.VisualState) {
        visualStateSubject.send(state)
    }

    func clearScores() {
        scoreCellsSubject.send([])
        visualStateSubject.send(.empty)
    }

    func setLoading() {
        visualStateSubject.send(.loading)
    }

    func setEmpty() {
        scoreCellsSubject.send([])
        visualStateSubject.send(.empty)
    }

    // MARK: - Score Transformation Logic

    /// Transforms raw match score data into displayable ScoreDisplayData cells
    private static func transformScores(
        detailedScores: [String: Score]?,
        activePlayerServing: ServicesProvider.ActivePlayerServe?,
        homeScore: Int?,
        awayScore: Int?,
        sportId: String
    ) -> [ScoreDisplayData] {

        // Determine if this is a Type C sport (Tennis, Volleyball, etc.)
        let isTypeCsport = ["3", "20", "64", "63", "14"].contains(sportId)

        // Debug: Log Type C detection details
        GomaLogger.debug(.realtime, category: "SPORT_DEBUG", "Score Transformation")
        GomaLogger.debug(.realtime, category: "SPORT_DEBUG", "   sportId used: '\(sportId)'")
        GomaLogger.debug(.realtime, category: "SPORT_DEBUG", "   isTypeCsport: \(isTypeCsport)")
        GomaLogger.debug(.realtime, category: "SPORT_DEBUG", "   Expected Type C IDs: [3=Tennis, 20=Volleyball, 14=Badminton, 63=TableTennis, 64=BeachVolley]")

        var scoreCells: [ScoreDisplayData] = []

        // Process detailed scores if available
        if let detailedScores = detailedScores, !detailedScores.isEmpty {
            GomaLogger.debug(.realtime, category: "LIVE_SCORE", "Transforming \(detailedScores.count) detailed scores for sport ID: \(sportId) (Type C: \(isTypeCsport))")

            // Sort scores by sortValue to ensure correct ordering
            let sortedScores = detailedScores.sorted(by: { $0.value.sortValue < $1.value.sortValue })

            // For Type C sports (Tennis), separate game parts from sets to ensure correct layout:
            // Layout: [Serving Indicator] [Game Part] | [Set1] [Set2] [Set3]
            if isTypeCsport {
                // Separate game parts and sets
                let gameParts = sortedScores.filter { entry in
                    if case .gamePart = entry.value { return true }
                    return false
                }

                let sets = sortedScores.filter { entry in
                    if case .set = entry.value { return true }
                    return false
                }

                let matchFulls = sortedScores.filter { entry in
                    if case .matchFull = entry.value { return true }
                    return false
                }

                // Find the last set index to determine current set
                let lastSetIndex = sets.compactMap { entry -> Int? in
                    if case .set(let index, _, _) = entry.value {
                        return index
                    }
                    return nil
                }.max()

                // Map serving player for first cell only
                let servingPlayer = mapServingPlayer(from: activePlayerServing)

                // Process game parts FIRST (with serving indicator and separator)
                for (scoreName, score) in gameParts {
                    if case .gamePart(_, let home, let away) = score {
                        GomaLogger.debug(.realtime, category: "LIVE_SCORE", "   - GamePart '\(scoreName)': \(home?.description ?? "-") - \(away?.description ?? "-") [FIRST]")
                        let scoreCell = ScoreDisplayData(
                            id: "game-\(scoreName)",
                            homeScore: home != nil ? "\(home!)" : "-",
                            awayScore: away != nil ? "\(away!)" : "-",
                            style: .simple,
                            highlightingMode: .bothHighlight,
                            showsTrailingSeparator: true,  // Always true for game parts in Type C
                            servingPlayer: scoreCells.isEmpty ? servingPlayer : nil  // Only first cell gets serving indicator
                        )
                        scoreCells.append(scoreCell)
                    }
                }

                // Then process sets in order
                for (scoreName, score) in sets {
                    if case .set(let index, let home, let away) = score {
                        let isCurrentSet = (index == lastSetIndex)
                        let highlighting: ScoreDisplayData.HighlightingMode = isCurrentSet ? .bothHighlight : .winnerLoser

                        GomaLogger.debug(.realtime, category: "LIVE_SCORE", "   - Set \(index) '\(scoreName)': \(home?.description ?? "-") - \(away?.description ?? "-") (current: \(isCurrentSet))")
                        let scoreCell = ScoreDisplayData(
                            id: "set-\(scoreName)",
                            homeScore: home != nil ? "\(home!)" : "-",
                            awayScore: away != nil ? "\(away!)" : "-",
                            index: index,
                            style: .simple,
                            highlightingMode: highlighting,
                            showsTrailingSeparator: false,
                            servingPlayer: nil  // Only game part gets serving indicator
                        )
                        scoreCells.append(scoreCell)
                    }
                }

                // Skip matchFull for Type C sports (Tennis doesn't show total score)
                if !matchFulls.isEmpty {
                    GomaLogger.debug(.realtime, category: "LIVE_SCORE", "   - MatchFull entries SKIPPED for Type C sport")
                }
            } else {
                // Non-Type C sports: Use original ordering logic
                // Find the last set index to determine current set
                let lastSetIndex = sortedScores.compactMap { entry -> Int? in
                    if case .set(let index, _, _) = entry.value {
                        return index
                    }
                    return nil
                }.max()

                // Map serving player for first cell only
                let servingPlayer = mapServingPlayer(from: activePlayerServing)
                var isFirstCell = true

                for (scoreName, score) in sortedScores {
                    let scoreCell: ScoreDisplayData

                    switch score {
                    case .gamePart(_, let home, let away):
                        // Current game points - always highlighted
                        GomaLogger.debug(.realtime, category: "LIVE_SCORE", "   - GamePart '\(scoreName)': \(home?.description ?? "-") - \(away?.description ?? "-")")
                        scoreCell = ScoreDisplayData(
                            id: "game-\(scoreName)",
                            homeScore: home != nil ? "\(home!)" : "-",
                            awayScore: away != nil ? "\(away!)" : "-",
                            style: .simple,
                            highlightingMode: .winnerLoser,
                            showsTrailingSeparator: false,
                            servingPlayer: isFirstCell ? servingPlayer : nil
                        )
                        scoreCells.append(scoreCell)
                        isFirstCell = false

                    case .set(let index, let home, let away):
                        // Set scores - determine if current or completed
                        let isCurrentSet = (index == lastSetIndex)
                        let highlighting: ScoreDisplayData.HighlightingMode = isCurrentSet ? .bothHighlight : .winnerLoser

                        GomaLogger.debug(.realtime, category: "LIVE_SCORE", "   - Set \(index) '\(scoreName)': \(home?.description ?? "-") - \(away?.description ?? "-") (current: \(isCurrentSet))")
                        scoreCell = ScoreDisplayData(
                            id: "set-\(scoreName)",
                            homeScore: home != nil ? "\(home!)" : "-",
                            awayScore: away != nil ? "\(away!)" : "-",
                            index: index,
                            style: .simple,
                            highlightingMode: highlighting,
                            showsTrailingSeparator: false,
                            servingPlayer: isFirstCell ? servingPlayer : nil
                        )
                        scoreCells.append(scoreCell)
                        isFirstCell = false

                    case .matchFull(let home, let away):
                        GomaLogger.debug(.realtime, category: "LIVE_SCORE", "   - MatchFull '\(scoreName)': \(home?.description ?? "-") - \(away?.description ?? "-")")
                        scoreCell = ScoreDisplayData(
                            id: "match-\(scoreName)",
                            homeScore: home != nil ? "\(home!)" : "-",
                            awayScore: away != nil ? "\(away!)" : "-",
                            style: .simple,
                            highlightingMode: .bothHighlight,
                            showsTrailingSeparator: false,
                            servingPlayer: isFirstCell ? servingPlayer : nil
                        )
                        scoreCells.append(scoreCell)
                        isFirstCell = false
                    }
                }
            }
        }

        // Fallback to main score if no detailed scores
        if scoreCells.isEmpty {
            if let homeScore = homeScore, let awayScore = awayScore {
                GomaLogger.debug(.realtime, category: "LIVE_SCORE", "   Adding main score (no detailed scores): \(homeScore) - \(awayScore)")
                let mainScoreCell = ScoreDisplayData(
                    id: "match",
                    homeScore: "\(homeScore)",
                    awayScore: "\(awayScore)",
                    style: .simple,
                    highlightingMode: .bothHighlight
                )
                scoreCells.append(mainScoreCell)
            }
        }

        if scoreCells.isEmpty {
            GomaLogger.debug(.realtime, category: "LIVE_SCORE", "   No score cells created")
        } else {
            GomaLogger.debug(.realtime, category: "LIVE_SCORE", "   Created \(scoreCells.count) score cells")
        }

        return scoreCells
    }

    /// Maps ServicesProvider ActivePlayerServe to ScoreDisplayData ServingPlayer
    private static func mapServingPlayer(from serving: ServicesProvider.ActivePlayerServe?) -> ScoreDisplayData.ServingPlayer? {
        switch serving {
        case .home:
            return .home
        case .away:
            return .away
        case .none:
            return nil
        }
    }
}
