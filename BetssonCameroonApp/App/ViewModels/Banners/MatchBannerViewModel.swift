//
//  MatchBannerViewModel.swift
//  BetssonCameroonApp
//
//  Created by Claude on 23/09/2025.
//

import Foundation
import ServicesProvider
import GomaUI

/// Production ViewModel for MatchBannerView that displays sport carousel banners
final class MatchBannerViewModel: MatchBannerViewModelProtocol {

    // MARK: - Properties
    private let match: Match
    private let imageURL: String?

    // MARK: - Callbacks
    var onMatchTap: ((String) -> Void)?

    // MARK: - Initialization
    init(match: Match, imageURL: String?) {
        self.match = match
        self.imageURL = imageURL
    }

    // MARK: - MatchBannerViewModelProtocol
    var currentMatchData: MatchBannerModel {
        return Self.createMatchBannerModel(from: match, imageURL: imageURL)
    }

    var marketOutcomesViewModel: MarketOutcomesLineViewModelProtocol {
        // Extract market data from match if available
        guard let firstMarket = match.markets.first,
              !firstMarket.outcomes.isEmpty else {
            // Return empty outcomes if no market data is available
            return MockMarketOutcomesLineViewModel(displayMode: .triple)
        }

        let outcomes = firstMarket.outcomes

        // Determine display mode based on number of outcomes
        let displayMode: MarketDisplayMode
        if outcomes.count == 2 {
            displayMode = .double
        } else if outcomes.count >= 3 {
            displayMode = .triple
        } else {
            // Single outcome - use triple with only left outcome
            displayMode = .triple
        }

        // Create outcome data from app's Outcome model
        let leftOutcome = outcomes.count > 0 ? createOutcomeDataFromAppModel(outcomes[0]) : nil
        let middleOutcome = outcomes.count > 2 ? createOutcomeDataFromAppModel(outcomes[1]) : nil
        let rightOutcome = outcomes.count > 1 ? createOutcomeDataFromAppModel(outcomes[outcomes.count >= 3 ? 2 : 1]) : nil

        return MockMarketOutcomesLineViewModel(
            displayMode: displayMode,
            leftOutcome: leftOutcome,
            middleOutcome: middleOutcome,
            rightOutcome: rightOutcome
        )
    }

    func userDidTapBanner() {
        onMatchTap?(match.id)
    }

    // MARK: - Private Helper Methods
    private func createOutcomeDataFromAppModel(_ outcome: Outcome) -> MarketOutcomeData {
        return MarketOutcomeData(
            id: outcome.id,
            bettingOfferId: outcome.bettingOffer.id,
            title: outcome.translatedName,
            value: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd),
            oddsChangeDirection: .none,
            isSelected: false,
            isDisabled: !outcome.bettingOffer.isAvailable
        )
    }

    private static func createMatchBannerModel(from match: Match, imageURL: String?) -> MatchBannerModel {
        // Extract real odds from match markets
        var outcomes: [MatchOutcome] = []

        if let firstMarket = match.markets.first, !firstMarket.outcomes.isEmpty {
            let marketOutcomes = firstMarket.outcomes

            // Create outcomes from real market data
            for (index, outcome) in marketOutcomes.enumerated() {
                guard index < 3 else { break } // Limit to first 3 outcomes for banner display

                let matchOutcome = MatchOutcome(
                    id: outcome.id,
                    displayName: outcome.translatedName,
                    odds: outcome.bettingOffer.decimalOdd
                )
                outcomes.append(matchOutcome)
            }
        }

        return MatchBannerModel(
            id: match.id,
            isLive: match.status.isLive,
            dateTime: match.date ?? Date(),
            leagueName: match.competitionName,
            homeTeam: match.homeParticipant.name.isEmpty ? "Home Team" : match.homeParticipant.name,
            awayTeam: match.awayParticipant.name.isEmpty ? "Away Team" : match.awayParticipant.name,
            backgroundImageURL: imageURL ?? match.promoImageURL, // Use CMS image first, fallback to event image
            matchTime: match.matchTime,
            homeScore: match.homeParticipantScore,
            awayScore: match.awayParticipantScore,
            outcomes: outcomes
        )
    }
}