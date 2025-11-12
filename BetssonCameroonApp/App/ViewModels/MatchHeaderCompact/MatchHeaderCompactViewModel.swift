//
//  MatchHeaderCompactViewModel.swift
//  Sportsbook
//
//  Created on 2025-07-16.
//

import Foundation
import Combine
import GomaUI

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
        
        // Subscribe to live data updates if match is live
        if match.status.isLive {
            subscribeToLiveUpdates()
        }
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
            statisticsExpandedTitle: currentData.statisticsExpandedTitle
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
    
    private func subscribeToLiveUpdates() {
        // Subscribe to live match updates
        // This would integrate with the existing live data service
        // For now, we'll set up the structure
        
        // TODO: Integrate with Env.servicesProvider.subscribeToLiveDataUpdates
        // This would update the match information in real-time
    }
    
    private static func createHeaderData(from match: Match) -> MatchHeaderCompactData {
        // Extract sport name with fallback
        let sportName = match.sport.name ?? match.sportName ?? "Unknown Sport"

        // Extract country information from venue
        let countryName = match.venue?.name ?? "Unknown"
        let countryId = match.venue?.id

        // Extract league information from competition
        let leagueName = match.competitionName
        let leagueId = match.competitionId

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
            statisticsExpandedTitle: localized("close_statistics")
        )
    }
}

// MARK: - Live Data Updates
extension MatchHeaderCompactViewModel {
    
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
            statisticsExpandedTitle: currentData.statisticsExpandedTitle
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
            statisticsExpandedTitle: currentData.statisticsExpandedTitle
        )

        headerDataSubject.send(updatedData)
    }
}
