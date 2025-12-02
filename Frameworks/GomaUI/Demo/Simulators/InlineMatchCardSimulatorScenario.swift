import Foundation
import GomaUI

// MARK: - Simulation Step

/// Represents a single step in a simulation scenario
enum SimulationStep {
    /// Update odds value for an outcome
    case updateOdds(outcomeType: OutcomeType, newValue: String, direction: OddsChangeDirection)

    /// Lock an outcome (market suspension)
    case lockOutcome(outcomeType: OutcomeType)

    /// Unlock an outcome and restore value
    case unlockOutcome(outcomeType: OutcomeType, value: String)

    /// Update score columns
    case updateScore(columns: [InlineScoreColumnData])

    /// Update header mode (pre-live date or live status)
    case updateHeaderMode(CompactMatchHeaderMode)

    /// Update market count
    case updateMarketCount(Int?)

    /// Select an outcome
    case selectOutcome(outcomeType: OutcomeType)

    /// Deselect an outcome
    case deselectOutcome(outcomeType: OutcomeType)

    /// Clear score (hide)
    case clearScore

    /// Show score
    case showScore
}

// MARK: - Simulation Scenario

/// Defines a complete simulation scenario with steps
struct InlineMatchCardSimulatorScenario {
    let name: String
    let description: String
    let steps: [SimulationStep]
    let repeats: Bool

    init(name: String, description: String, steps: [SimulationStep], repeats: Bool = false) {
        self.name = name
        self.description = description
        self.steps = steps
        self.repeats = repeats
    }
}

// MARK: - Predefined Scenarios

extension InlineMatchCardSimulatorScenario {

    /// Odds fluctuation scenario - random odds movements
    static var oddsFluctuation: InlineMatchCardSimulatorScenario {
        InlineMatchCardSimulatorScenario(
            name: "Odds Fluctuation",
            description: "Simulates random odds changes across all outcomes",
            steps: [
                .updateOdds(outcomeType: .left, newValue: "2.95", direction: .up),
                .updateOdds(outcomeType: .right, newValue: "2.55", direction: .down),
                .updateOdds(outcomeType: .middle, newValue: "3.20", direction: .up),
                .updateOdds(outcomeType: .left, newValue: "2.80", direction: .down),
                .updateOdds(outcomeType: .right, newValue: "2.70", direction: .up),
                .updateOdds(outcomeType: .middle, newValue: "3.05", direction: .down),
                .updateOdds(outcomeType: .left, newValue: "3.10", direction: .up),
                .updateOdds(outcomeType: .right, newValue: "2.40", direction: .down),
                .updateOdds(outcomeType: .middle, newValue: "3.35", direction: .up),
                .updateOdds(outcomeType: .left, newValue: "2.65", direction: .down)
            ],
            repeats: true
        )
    }

    /// Live football match progression with score updates
    static var liveFootballMatch: InlineMatchCardSimulatorScenario {
        InlineMatchCardSimulatorScenario(
            name: "Live Football",
            description: "Simulates a live football match with score updates",
            steps: [
                // Match starts
                .updateHeaderMode(.live(statusText: "0'")),
                .showScore,
                .updateScore(columns: [
                    InlineScoreColumnData(id: "score", homeScore: "0", awayScore: "0", highlightingMode: .bothHighlight)
                ]),

                // Early game
                .updateHeaderMode(.live(statusText: "15'")),
                .updateOdds(outcomeType: .left, newValue: "2.75", direction: .down),

                // First goal
                .updateHeaderMode(.live(statusText: "22'")),
                .updateScore(columns: [
                    InlineScoreColumnData(id: "score", homeScore: "1", awayScore: "0", highlightingMode: .bothHighlight)
                ]),
                .updateOdds(outcomeType: .left, newValue: "1.90", direction: .down),
                .updateOdds(outcomeType: .right, newValue: "4.20", direction: .up),

                // Before halftime
                .updateHeaderMode(.live(statusText: "45'")),
                .updateOdds(outcomeType: .middle, newValue: "3.80", direction: .up),

                // Halftime
                .updateHeaderMode(.live(statusText: "HT")),

                // Second half starts
                .updateHeaderMode(.live(statusText: "46'")),

                // Equalizer
                .updateHeaderMode(.live(statusText: "60'")),
                .updateScore(columns: [
                    InlineScoreColumnData(id: "score", homeScore: "1", awayScore: "1", highlightingMode: .bothHighlight)
                ]),
                .updateOdds(outcomeType: .left, newValue: "2.50", direction: .up),
                .updateOdds(outcomeType: .right, newValue: "2.90", direction: .down),
                .updateOdds(outcomeType: .middle, newValue: "3.10", direction: .down),

                // Late winner
                .updateHeaderMode(.live(statusText: "75'")),
                .updateScore(columns: [
                    InlineScoreColumnData(id: "score", homeScore: "2", awayScore: "1", highlightingMode: .bothHighlight)
                ]),
                .updateOdds(outcomeType: .left, newValue: "1.25", direction: .down),
                .updateOdds(outcomeType: .right, newValue: "8.50", direction: .up),

                // Final minutes
                .updateHeaderMode(.live(statusText: "90'"))
            ],
            repeats: false
        )
    }

    /// Market availability - outcomes locking/unlocking
    static var marketAvailability: InlineMatchCardSimulatorScenario {
        InlineMatchCardSimulatorScenario(
            name: "Market Availability",
            description: "Simulates market suspension and resumption",
            steps: [
                // Suspend all
                .lockOutcome(outcomeType: .left),
                .lockOutcome(outcomeType: .middle),
                .lockOutcome(outcomeType: .right),

                // Resume progressively
                .unlockOutcome(outcomeType: .left, value: "2.85"),
                .unlockOutcome(outcomeType: .middle, value: "3.10"),
                .unlockOutcome(outcomeType: .right, value: "2.60"),

                // Partial suspension
                .lockOutcome(outcomeType: .middle),
                .updateOdds(outcomeType: .left, newValue: "2.95", direction: .up),
                .unlockOutcome(outcomeType: .middle, value: "3.25"),

                // Another suspension cycle
                .lockOutcome(outcomeType: .right),
                .updateOdds(outcomeType: .left, newValue: "2.70", direction: .down),
                .unlockOutcome(outcomeType: .right, value: "2.80")
            ],
            repeats: true
        )
    }

    /// Pre-live to live transition
    static var preLiveToLive: InlineMatchCardSimulatorScenario {
        InlineMatchCardSimulatorScenario(
            name: "Pre-Live to Live",
            description: "Simulates match starting",
            steps: [
                // Countdown
                .updateHeaderMode(.preLive(dateText: "In 5 min")),
                .clearScore,

                .updateHeaderMode(.preLive(dateText: "In 2 min")),

                .updateHeaderMode(.preLive(dateText: "Starting...")),

                // Match starts
                .updateHeaderMode(.live(statusText: "0'")),
                .showScore,
                .updateScore(columns: [
                    InlineScoreColumnData(id: "score", homeScore: "0", awayScore: "0", highlightingMode: .bothHighlight)
                ]),

                // Initial odds adjustment
                .updateOdds(outcomeType: .left, newValue: "2.80", direction: .down),
                .updateOdds(outcomeType: .right, newValue: "2.75", direction: .up),

                // Game progresses
                .updateHeaderMode(.live(statusText: "5'")),
                .updateOdds(outcomeType: .middle, newValue: "3.15", direction: .up)
            ],
            repeats: false
        )
    }

    /// User interaction scenario with selections
    static var userInteraction: InlineMatchCardSimulatorScenario {
        InlineMatchCardSimulatorScenario(
            name: "User Interaction",
            description: "Simulates user selecting and deselecting outcomes",
            steps: [
                // User selects home
                .selectOutcome(outcomeType: .left),
                .updateOdds(outcomeType: .left, newValue: "2.85", direction: .up),

                // User changes mind
                .deselectOutcome(outcomeType: .left),

                // User selects draw
                .selectOutcome(outcomeType: .middle),

                // Market suspends selected outcome
                .lockOutcome(outcomeType: .middle),

                // Market resumes
                .unlockOutcome(outcomeType: .middle, value: "3.15"),

                // User selects away instead
                .deselectOutcome(outcomeType: .middle),
                .selectOutcome(outcomeType: .right),

                // Odds change on selection
                .updateOdds(outcomeType: .right, newValue: "2.55", direction: .down),

                // User deselects
                .deselectOutcome(outcomeType: .right)
            ],
            repeats: true
        )
    }

    /// All scenarios for easy access
    static var allScenarios: [InlineMatchCardSimulatorScenario] {
        [
            .oddsFluctuation,
            .liveFootballMatch,
            .marketAvailability,
            .preLiveToLive,
            .userInteraction
        ]
    }
}
