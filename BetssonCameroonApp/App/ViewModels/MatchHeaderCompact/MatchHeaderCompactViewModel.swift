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
            competition: currentData.competition,
            league: currentData.league,
            hasStatistics: currentData.hasStatistics,
            isStatisticsCollapsed: !currentData.isStatisticsCollapsed,
            statisticsCollapsedTitle: currentData.statisticsCollapsedTitle,
            statisticsExpandedTitle: currentData.statisticsExpandedTitle
        )
        headerDataSubject.send(updatedData)
        
        // Also call the callback
        onStatisticsTapped?()
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
        
        // Extract competition/league information
        let competitionName = match.competitionName
        let leagueName = match.venue?.name ?? competitionName
        
        return MatchHeaderCompactData(
            homeTeamName: match.homeParticipant.name,
            awayTeamName: match.awayParticipant.name,
            sport: sportName,
            competition: competitionName,
            league: leagueName,
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
            competition: currentData.competition,
            league: currentData.league,
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
            competition: currentData.competition,
            league: currentData.league,
            hasStatistics: hasStatistics,
            isStatisticsCollapsed: currentData.isStatisticsCollapsed,
            statisticsCollapsedTitle: currentData.statisticsCollapsedTitle,
            statisticsExpandedTitle: currentData.statisticsExpandedTitle
        )
        
        headerDataSubject.send(updatedData)
    }
}
