import Foundation
import Combine

/// Mock implementation of MatchBannerViewModelProtocol for testing and previews
public final class MockMatchBannerViewModel: MatchBannerViewModelProtocol {

    // MARK: - Publishers
    @Published private var matchData: MatchBannerModel
    private let matchLiveStatusChangedSubject = PassthroughSubject<Bool, Never>()

    public var matchDataPublisher: AnyPublisher<MatchBannerModel, Never> {
        $matchData.eraseToAnyPublisher()
    }

    public var matchLiveStatusChangedPublisher: AnyPublisher<Bool, Never> {
        matchLiveStatusChangedSubject.eraseToAnyPublisher()
    }

    // MARK: - Synchronous Data Access
    public var currentMatchData: MatchBannerModel {
        return matchData
    }

    public var marketOutcomesViewModel: MarketOutcomesLineViewModelProtocol {
        return mockMarketOutcomesViewModel
    }

    public var scoreViewModel: ScoreViewModelProtocol? {
        guard matchData.isLive else { return nil }
        return mockScoreViewModel
    }

    // MARK: - Private Properties
    private let mockMarketOutcomesViewModel: MockMarketOutcomesLineViewModel
    private let mockScoreViewModel: MockScoreViewModel
    private var onBannerTappedCallback: (() -> Void)?
    private var onOutcomeTappedCallback: ((String, Bool) -> Void)?

    // MARK: - Initialization
    public init(
        matchData: MatchBannerModel,
        onBannerTapped: (() -> Void)? = nil,
        onOutcomeTapped: ((String, Bool) -> Void)? = nil
    ) {
        self.matchData = matchData
        self.onBannerTappedCallback = onBannerTapped
        self.onOutcomeTappedCallback = onOutcomeTapped

        // Create market outcomes view model from match outcomes
        self.mockMarketOutcomesViewModel = Self.createMarketOutcomesViewModel(from: matchData.outcomes)

        // Create score view model for live matches
        self.mockScoreViewModel = Self.createScoreViewModel(from: matchData)
    }

    // MARK: - MatchBannerViewModelProtocol
    public func userDidTapBanner() {
        print("🏟️ Mock: Banner tapped for match: \(matchData.homeTeam) vs \(matchData.awayTeam)")
        onBannerTappedCallback?()
    }

    public func userDidTapOutcome(outcomeId: String, isSelected: Bool) {
        print("⚽ Mock: Outcome tapped - ID: \(outcomeId), Selected: \(isSelected)")

        // Update the outcome selection
        let updatedOutcomes = matchData.outcomes.map { outcome in
            if outcome.id == outcomeId {
                return MatchOutcome(
                    id: outcome.id,
                    displayName: outcome.displayName,
                    odds: outcome.odds,
                    isSelected: isSelected,
                    isEnabled: outcome.isEnabled
                )
            } else {
                // Deselect other outcomes (single selection)
                return MatchOutcome(
                    id: outcome.id,
                    displayName: outcome.displayName,
                    odds: outcome.odds,
                    isSelected: false,
                    isEnabled: outcome.isEnabled
                )
            }
        }

        // Update match data
        matchData = MatchBannerModel(
            id: matchData.id,
            isLive: matchData.isLive,
            dateTime: matchData.dateTime,
            leagueName: matchData.leagueName,
            homeTeam: matchData.homeTeam,
            awayTeam: matchData.awayTeam,
            backgroundImageURL: matchData.backgroundImageURL,
            matchTime: matchData.matchTime,
            homeScore: matchData.homeScore,
            awayScore: matchData.awayScore,
            outcomes: updatedOutcomes
        )

        onOutcomeTappedCallback?(outcomeId, isSelected)
    }

    public func userDidLongPressOutcome(outcomeId: String) {
        print("⚽ Mock: Outcome long pressed - ID: \(outcomeId)")

        // Simulate showing outcome details
        if let outcome = matchData.outcomes.first(where: { $0.id == outcomeId }) {
            print("📊 Mock: Showing details for \(outcome.displayName) - Odds: \(outcome.odds)")
        }
    }

    public func loadMatchData() {
        print("📡 Mock: Loading match data...")

        // Simulate loading with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            print("✅ Mock: Match data loaded")
        }
    }

    public func refreshMatchData() {
        print("🔄 Mock: Refreshing match data...")

        // Simulate refresh with new odds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Slightly modify odds to simulate live updates
            let updatedOutcomes = self.matchData.outcomes.map { outcome in
                let newOdds = outcome.odds + Double.random(in: -0.1...0.1)
                return MatchOutcome(
                    id: outcome.id,
                    displayName: outcome.displayName,
                    odds: max(1.0, newOdds), // Ensure odds don't go below 1.0
                    isSelected: outcome.isSelected,
                    isEnabled: outcome.isEnabled
                )
            }

            self.matchData = MatchBannerModel(
                id: self.matchData.id,
                isLive: self.matchData.isLive,
                dateTime: self.matchData.dateTime,
                leagueName: self.matchData.leagueName,
                homeTeam: self.matchData.homeTeam,
                awayTeam: self.matchData.awayTeam,
                backgroundImageURL: self.matchData.backgroundImageURL,
                matchTime: self.matchData.matchTime,
                homeScore: self.matchData.homeScore,
                awayScore: self.matchData.awayScore,
                outcomes: updatedOutcomes
            )

            print("✅ Mock: Match data refreshed with updated odds")
        }
    }

    // MARK: - Private Helpers
    private static func createMarketOutcomesViewModel(from outcomes: [MatchOutcome]) -> MockMarketOutcomesLineViewModel {
        // Convert MatchOutcome to MarketOutcome format expected by MarketOutcomesLineView
        // This is a simplified conversion - in real implementation, this would be more sophisticated
        return MockMarketOutcomesLineViewModel.threeWayMarket
    }

    private static func createScoreViewModel(from matchData: MatchBannerModel) -> MockScoreViewModel {
        // Create score view model for live matches
        // This would contain the actual score data in a real implementation
        return MockScoreViewModel.footballMatch
    }
    
    public func onOutcomeSelected(outcomeId: String) {
        print("Mock: onOutcomeSelected")
    }
    
    public func onOutcomeDeselected(outcomeId: String) {
        print("Mock: onOutcomeDeselected")
    }
}

// MARK: - Static Factory Methods
extension MockMatchBannerViewModel {

    /// Empty state for cell reuse
    public static var emptyState: MockMatchBannerViewModel {
        MockMatchBannerViewModel(matchData: .empty)
    }

    /// Prelive match example
    public static var preliveMatch: MockMatchBannerViewModel {
        let dateTime = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let outcomes = [
            MatchOutcome(id: "home", displayName: "Man City", odds: 1.55),
            MatchOutcome(id: "draw", displayName: "Draw", odds: 5.00),
            MatchOutcome(id: "away", displayName: "Arsenal", odds: 5.00)
        ]

        let matchData = MatchBannerModel(
            id: "match_001",
            isLive: false,
            dateTime: dateTime,
            leagueName: "Premier League",
            homeTeam: "Man City",
            awayTeam: "Arsenal",
            backgroundImageURL: "https://example.com/match_bg.jpg",
            outcomes: outcomes
        )

        return MockMatchBannerViewModel(
            matchData: matchData,
            onBannerTapped: {
                print("🎯 Prelive Mock: Banner tapped - opening match details")
            },
            onOutcomeTapped: { outcomeId, isSelected in
                print("🎯 Prelive Mock: Outcome \(outcomeId) \(isSelected ? "selected" : "deselected")")
            }
        )
    }

    /// Live match example
    public static var liveMatch: MockMatchBannerViewModel {
        let outcomes = [
            MatchOutcome(id: "home", displayName: "Man City", odds: 1.55),
            MatchOutcome(id: "draw", displayName: "Draw", odds: 5.00),
            MatchOutcome(id: "away", displayName: "Arsenal", odds: 5.00)
        ]

        let matchData = MatchBannerModel(
            id: "match_002",
            isLive: true,
            dateTime: Date(),
            leagueName: "Premier League",
            homeTeam: "Man City",
            awayTeam: "Arsenal",
            backgroundImageURL: "https://example.com/live_match_bg.jpg",
            matchTime: "1st Half, 44 Min",
            homeScore: 1,
            awayScore: 1,
            outcomes: outcomes
        )

        return MockMatchBannerViewModel(
            matchData: matchData,
            onBannerTapped: {
                print("🎯 Live Mock: Banner tapped - opening live match view")
            },
            onOutcomeTapped: { outcomeId, isSelected in
                print("🎯 Live Mock: Live betting - Outcome \(outcomeId) \(isSelected ? "selected" : "deselected")")
            }
        )
    }

    /// Interactive mock for demo with comprehensive feedback
    public static var interactiveMatch: MockMatchBannerViewModel {
        let outcomes = [
            MatchOutcome(id: "home", displayName: "Barcelona", odds: 2.10),
            MatchOutcome(id: "draw", displayName: "Draw", odds: 3.40),
            MatchOutcome(id: "away", displayName: "Real Madrid", odds: 3.20)
        ]

        let matchData = MatchBannerModel(
            id: "match_003",
            isLive: true,
            dateTime: Date(),
            leagueName: "La Liga",
            homeTeam: "Barcelona",
            awayTeam: "Real Madrid",
            backgroundImageURL: "https://example.com/el_clasico_bg.jpg",
            matchTime: "2nd Half, 67 Min",
            homeScore: 2,
            awayScore: 1,
            outcomes: outcomes
        )

        return MockMatchBannerViewModel(
            matchData: matchData,
            onBannerTapped: {
                print("🎯 Interactive Mock: El Clásico banner tapped!")
                print("📱 Mock: Opening live match experience...")
                print("🔥 Mock: Live statistics, commentary, and betting available")
            },
            onOutcomeTapped: { outcomeId, isSelected in
                print("🎯 Interactive Mock: El Clásico betting - \(outcomeId)")
                print("💰 Mock: \(isSelected ? "Added to betslip" : "Removed from betslip")")
                print("🎲 Mock: Live odds updating in real-time")
            }
        )
    }
}
