//
//  SportBannerViewModel.swift
//  BetssonCameroonApp
//
//  Created by Claude on 22/09/2025.
//

import Foundation
import Combine
import ServicesProvider
import GomaUI

/// Production ViewModel for sport banners that can work with both MatchBannerView and SingleButtonBannerView
final class SportBannerViewModel {

    // MARK: - Properties
    private let bannerData: SportBannerData
    private let match: Match

    // MARK: - Callbacks
    var onBannerAction: ((SportBannerAction) -> Void) = { _ in }

    // MARK: - Initialization
    init(bannerData: SportBannerData) {
        self.bannerData = bannerData
        self.match = bannerData.match
    }

    /// Create appropriate view model based on banner type
    func createBannerViewModel() -> Any {
        switch bannerData.bannerType {
        case .matchBanner:
            return createMatchBannerViewModel()
        case .singleButtonBanner:
            return createSingleButtonBannerViewModel()
        }
    }

    /// Create MatchBannerViewModelProtocol implementation
    private func createMatchBannerViewModel() -> MatchBannerViewModelProtocol {
        let viewModel = SportMatchBannerViewModel(
            bannerData: bannerData,
            match: match,
            onBannerAction: onBannerAction
        )
        return viewModel
    }

    /// Create SingleButtonBannerViewModelProtocol implementation
    private func createSingleButtonBannerViewModel() -> SingleButtonBannerViewModelProtocol {
        let viewModel = SportSingleButtonBannerViewModel(
            bannerData: bannerData,
            match: match,
            onBannerAction: onBannerAction
        )
        return viewModel
    }
}

// MARK: - Match Banner ViewModel Implementation
final class SportMatchBannerViewModel: MatchBannerViewModelProtocol {

    private let bannerData: SportBannerData
    private let match: Match
    private let onBannerAction: ((SportBannerAction) -> Void)

    // MARK: - Publishers
    private let matchDataSubject: CurrentValueSubject<MatchBannerModel, Never>
    private let liveStatusSubject: CurrentValueSubject<Bool, Never>

    init(bannerData: SportBannerData, match: Match, onBannerAction: @escaping (SportBannerAction) -> Void) {
        self.bannerData = bannerData
        self.match = match
        self.onBannerAction = onBannerAction

        // Create match banner model from match data
        let matchData = Self.createMatchBannerModel(from: match, bannerData: bannerData)
        self.matchDataSubject = CurrentValueSubject(matchData)

        let isLive = match.status.isLive
        self.liveStatusSubject = CurrentValueSubject(isLive)
    }

    // MARK: - MatchBannerViewModelProtocol
    var currentMatchData: MatchBannerModel {
        return matchDataSubject.value
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

    var scoreViewModel: ScoreViewModelProtocol? {
        return nil // Not implemented for banners
    }

    var matchDataPublisher: AnyPublisher<MatchBannerModel, Never> {
        return matchDataSubject.eraseToAnyPublisher()
    }

    var matchLiveStatusChangedPublisher: AnyPublisher<Bool, Never> {
        return liveStatusSubject.eraseToAnyPublisher()
    }

    func userDidTapBanner() {
        let action = SportBannerAction.openMatchDetails(eventId: match.id)
        onBannerAction(action)
    }

    func userDidTapOutcome(outcomeId: String, isSelected: Bool) {
        // Handle outcome tap if needed
    }

    func userDidLongPressOutcome(outcomeId: String) {
        // Handle long press if needed
    }

    func loadMatchData() {
        // Match data is already loaded from event
    }

    func refreshMatchData() {
        // Refresh could trigger event update in real implementation
    }

    // MARK: - Helper Methods
    private static func createMatchBannerModel(from match: Match, bannerData: SportBannerData) -> MatchBannerModel {
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
            id: bannerData.bannerId,
            isLive: match.status.isLive,
            dateTime: match.date ?? Date(),
            leagueName: match.competitionName,
            homeTeam: match.homeParticipant.name.isEmpty ? "Home Team" : match.homeParticipant.name,
            awayTeam: match.awayParticipant.name.isEmpty ? "Away Team" : match.awayParticipant.name,
            backgroundImageURL: bannerData.customImageUrl ?? match.promoImageURL,
            matchTime: match.matchTime,
            homeScore: match.homeParticipantScore,
            awayScore: match.awayParticipantScore,
            outcomes: outcomes
        )
    }
}

// MARK: - Single Button Banner ViewModel Implementation
final class SportSingleButtonBannerViewModel: SingleButtonBannerViewModelProtocol {

    private let bannerData: SportBannerData
    private let match: Match
    private let onBannerAction: ((SportBannerAction) -> Void)

    // MARK: - Publishers
    private let displayStateSubject: CurrentValueSubject<SingleButtonBannerDisplayState, Never>

    init(bannerData: SportBannerData, match: Match, onBannerAction: @escaping (SportBannerAction) -> Void) {
        self.bannerData = bannerData
        self.match = match
        self.onBannerAction = onBannerAction

        // Create display state from banner data
        let displayState = Self.createDisplayState(from: match, bannerData: bannerData)
        self.displayStateSubject = CurrentValueSubject(displayState)
    }

    // MARK: - SingleButtonBannerViewModelProtocol
    var currentDisplayState: SingleButtonBannerDisplayState {
        return displayStateSubject.value
    }

    var displayStatePublisher: AnyPublisher<SingleButtonBannerDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }

    func userDidTapBanner() {
        if let ctaUrl = bannerData.ctaUrl {
            let action = SportBannerAction.openExternalUrl(url: ctaUrl)
            onBannerAction(action)
        } else {
            let action = SportBannerAction.openMatchDetails(eventId: match.id)
            onBannerAction(action)
        }
    }

    func buttonTapped() {
        userDidTapBanner()
    }

    // MARK: - Helper Methods
    private static func createDisplayState(from match: Match, bannerData: SportBannerData) -> SingleButtonBannerDisplayState {
        let messageText = "\(match.competitionName) - \(match.homeParticipant.name) vs \(match.awayParticipant.name)"

        let buttonConfig = ButtonConfig(
            title: "View Match",
            backgroundColor: StyleProvider.Color.primaryColor,
            textColor: StyleProvider.Color.textPrimary,
            cornerRadius: 8.0
        )

        let singleButtonBannerData = SingleButtonBannerData(
            type: "sport_event",
            isVisible: bannerData.isVisible,
            backgroundImageURL: bannerData.customImageUrl ?? match.promoImageURL,
            messageText: messageText,
            buttonConfig: buttonConfig
        )

        return SingleButtonBannerDisplayState(
            bannerData: singleButtonBannerData,
            isButtonEnabled: true
        )
    }
}
