//
//  MatchHeaderCompactViewModel.swift
//  Sportsbook
//
//  Created on 2025-07-16.
//

import Foundation
import Combine
import GomaUI
import ServicesProvider

final class MatchHeaderCompactViewModel: MatchHeaderCompactViewModelProtocol {
    
    // MARK: - Private Properties

    private let headerDataSubject: CurrentValueSubject<MatchHeaderCompactData, Never>
    private let match: Match
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties

    var headerDataPublisher: AnyPublisher<MatchHeaderCompactData, Never> {
        headerDataSubject.eraseToAnyPublisher()
    }

    var onStatisticsTapped: (() -> Void)?
    var onCountryTapped: ((String) -> Void)?
    var onLeagueTapped: ((String) -> Void)?
    
    // MARK: - Initialization
    
    init(match: Match) {
        self.match = match

        // Create initial header data from match
        let initialData = Self.createHeaderData(from: match)
        self.headerDataSubject = CurrentValueSubject(initialData)
    }
    
    // MARK: - MatchHeaderCompactViewModelProtocol

    func handleStatisticsTap() {
        // Toggle the collapsed state
        let currentData = headerDataSubject.value
        let updatedData = MatchHeaderCompactData(
            homeTeamName: currentData.homeTeamName,
            awayTeamName: currentData.awayTeamName,
            sport: currentData.sport,
            country: currentData.country,
            league: currentData.league,
            countryId: currentData.countryId,
            leagueId: currentData.leagueId,
            hasStatistics: currentData.hasStatistics,
            isStatisticsCollapsed: !currentData.isStatisticsCollapsed,
            statisticsCollapsedTitle: currentData.statisticsCollapsedTitle,
            statisticsExpandedTitle: currentData.statisticsExpandedTitle,
            scoreViewModel: currentData.scoreViewModel,
            isLive: currentData.isLive
        )
        headerDataSubject.send(updatedData)

        // Also call the callback
        onStatisticsTapped?()
    }

    func handleCountryTap() {
        let currentData = headerDataSubject.value
        if let countryId = currentData.countryId {
            onCountryTapped?(countryId)
        }
    }

    func handleLeagueTap() {
        let currentData = headerDataSubject.value
        if let leagueId = currentData.leagueId {
            onLeagueTapped?(leagueId)
        }
    }
    
    // MARK: - Private Methods

    private static func createHeaderData(from match: Match) -> MatchHeaderCompactData {
        // Extract sport name with fallback
        let sportName = match.sport.name ?? match.sportName ?? "Unknown Sport"

        // Extract country information from venue
        let countryName = match.venue?.name ?? "Unknown"
        let countryId = match.venue?.id

        // Extract league information from competition
        let leagueName = match.competitionName
        let leagueId = match.competitionId

        // Determine if match is live
        let isLive = match.status.isLive

        // Create score view model for live matches
        let scoreViewModel: ScoreViewModelProtocol? = isLive ? ScoreViewModel(from: match) : nil

        return MatchHeaderCompactData(
            homeTeamName: match.homeParticipant.name,
            awayTeamName: match.awayParticipant.name,
            sport: sportName,
            country: countryName,
            league: leagueName,
            countryId: countryId,
            leagueId: leagueId,
            hasStatistics: false,
            isStatisticsCollapsed: true,
            statisticsCollapsedTitle: localized("view_statistics"),
            statisticsExpandedTitle: localized("close_statistics"),
            scoreViewModel: scoreViewModel,
            isLive: isLive
        )
    }
}

// MARK: - Live Data Updates
extension MatchHeaderCompactViewModel {

    /// Updates the header with new match data (including live scores)
    public func updateMatch(_ match: Match) {
        let updatedData = Self.createHeaderData(from: match)
        headerDataSubject.send(updatedData)
    }

    /// Updates header with MatchLiveData (scores, status, time)
    public func updateMatchWithLiveData(_ liveData: MatchLiveData) {
        let currentData = headerDataSubject.value

        // Create new ScoreViewModel from live data
        let scoreViewModel: ScoreViewModelProtocol? = ScoreViewModel(
            detailedScores: liveData.detailedScores,
            activePlayerServing: Self.mapActivePlayerServe(from: liveData.activePlayerServing),
            homeScore: liveData.homeScore,
            awayScore: liveData.awayScore,
            sportId: match.sport.id
        )

        let updatedData = MatchHeaderCompactData(
            homeTeamName: currentData.homeTeamName,
            awayTeamName: currentData.awayTeamName,
            sport: currentData.sport,
            country: currentData.country,
            league: currentData.league,
            countryId: currentData.countryId,
            leagueId: currentData.leagueId,
            hasStatistics: currentData.hasStatistics,
            isStatisticsCollapsed: currentData.isStatisticsCollapsed,
            statisticsCollapsedTitle: currentData.statisticsCollapsedTitle,
            statisticsExpandedTitle: currentData.statisticsExpandedTitle,
            scoreViewModel: scoreViewModel,
            isLive: liveData.status?.isLive ?? currentData.isLive
        )

        headerDataSubject.send(updatedData)
    }

    private static func mapActivePlayerServe(from serve: Match.ActivePlayerServe?) -> ServicesProvider.ActivePlayerServe? {
        switch serve {
        case .home:
            return .home
        case .away:
            return .away
        case .none:
            return nil
        }
    }

    /// Updates the header with new match information
    /// This would be called when live data updates are received
    public func updateMatchInfo(homeTeamName: String? = nil, awayTeamName: String? = nil) {
        let currentData = headerDataSubject.value

        let updatedData = MatchHeaderCompactData(
            homeTeamName: homeTeamName ?? currentData.homeTeamName,
            awayTeamName: awayTeamName ?? currentData.awayTeamName,
            sport: currentData.sport,
            country: currentData.country,
            league: currentData.league,
            countryId: currentData.countryId,
            leagueId: currentData.leagueId,
            hasStatistics: currentData.hasStatistics,
            isStatisticsCollapsed: currentData.isStatisticsCollapsed,
            statisticsCollapsedTitle: currentData.statisticsCollapsedTitle,
            statisticsExpandedTitle: currentData.statisticsExpandedTitle,
            scoreViewModel: currentData.scoreViewModel,
            isLive: currentData.isLive
        )

        headerDataSubject.send(updatedData)
    }

    /// Updates the statistics availability
    public func updateStatisticsAvailability(_ hasStatistics: Bool) {
        let currentData = headerDataSubject.value

        let updatedData = MatchHeaderCompactData(
            homeTeamName: currentData.homeTeamName,
            awayTeamName: currentData.awayTeamName,
            sport: currentData.sport,
            country: currentData.country,
            league: currentData.league,
            countryId: currentData.countryId,
            leagueId: currentData.leagueId,
            hasStatistics: hasStatistics,
            isStatisticsCollapsed: currentData.isStatisticsCollapsed,
            statisticsCollapsedTitle: currentData.statisticsCollapsedTitle,
            statisticsExpandedTitle: currentData.statisticsExpandedTitle,
            scoreViewModel: currentData.scoreViewModel,
            isLive: currentData.isLive
        )

        headerDataSubject.send(updatedData)
    }
}
