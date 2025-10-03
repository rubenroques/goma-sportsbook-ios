//
//  MatchBannerViewModel.swift
//  BetssonCameroonApp
//
//  Created on 23/09/2025.
//

import Foundation
import ServicesProvider
import GomaUI
import Combine

/// Production ViewModel for MatchBannerView that displays sport carousel banners
final class MatchBannerViewModel: MatchBannerViewModelProtocol {

    // MARK: - Properties
    private let match: Match
    private let imageURL: String?

    // Store the market outcomes ViewModel to maintain state and subscriptions
    var marketOutcomesViewModel: MarketOutcomesLineViewModelProtocol

    // MARK: - Callbacks
    var onMatchTap: ((String) -> Void)?
    var onOutcomeSelected: ((String) -> Void)?
    var onOutcomeDeselected: ((String) -> Void)?

    // MARK: - Initialization
    init(match: Match, imageURL: String?) {
        self.match = match
        self.imageURL = imageURL

        // Create market outcomes ViewModel once during initialization
        // MatchBannerMarketOutcomesLineViewModel handles its own betslip subscription
        self.marketOutcomesViewModel = Self.createMarketOutcomesViewModel(from: match)
    }

    // MARK: - MatchBannerViewModelProtocol
    var currentMatchData: MatchBannerModel {
        return Self.createMatchBannerModel(from: match, imageURL: imageURL)
    }

    func userDidTapBanner() {
        onMatchTap?(match.id)
    }

    // MARK: - Outcome Selection
    func onOutcomeSelected(outcomeId: String) {
        // Find the outcome from the match markets
        guard let firstMarket = match.markets.first else { return }

        let outcome = firstMarket.outcomes.first { $0.id == outcomeId }
        guard let outcome = outcome else { return }

        // Create BettingTicket
        let bettingTicket = BettingTicket(
            id: outcome.bettingOffer.id,
            outcomeId: outcomeId,
            marketId: firstMarket.id,
            matchId: match.id,
            decimalOdd: outcome.bettingOffer.decimalOdd,
            isAvailable: outcome.bettingOffer.isAvailable,
            matchDescription: "\(match.homeParticipant.name) - \(match.awayParticipant.name)",
            marketDescription: firstMarket.name,
            outcomeDescription: outcome.translatedName,
            homeParticipantName: match.homeParticipant.name,
            awayParticipantName: match.awayParticipant.name,
            sportIdCode: match.sportIdCode,
            competition: match.competitionName,
            date: match.date
        )

        // Add to betslip
        Env.betslipManager.addBettingTicket(bettingTicket)

        // Notify callback if set
        onOutcomeSelected?(outcomeId)
    }

    func onOutcomeDeselected(outcomeId: String) {
        // Find and remove from betslip
        guard let firstMarket = match.markets.first else { return }

        let outcome = firstMarket.outcomes.first { $0.id == outcomeId }
        guard let outcome = outcome else { return }

        // Remove from betslip using the betting offer ID
        Env.betslipManager.removeBettingTicket(withId: outcome.bettingOffer.id)

        // Notify callback if set
        onOutcomeDeselected?(outcomeId)
    }

    // MARK: - Private Helper Methods
    private static func createMarketOutcomesViewModel(from match: Match) -> MarketOutcomesLineViewModelProtocol {
        // Extract market data from match if available
        guard let firstMarket = match.markets.first,
              !firstMarket.outcomes.isEmpty else {
            // Return empty outcomes if no market data is available
            return MockMarketOutcomesLineViewModel(displayMode: .triple)
        }

        // Use production ViewModel that has built-in betslip subscription
        print("[BETSLIP_SYNC] MatchBannerViewModel: Creating MatchBannerMarketOutcomesLineViewModel for match \(match.id)")
        return MatchBannerMarketOutcomesLineViewModel(match: match, market: firstMarket)
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
