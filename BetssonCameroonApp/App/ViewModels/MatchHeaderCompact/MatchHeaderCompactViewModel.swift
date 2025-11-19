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
    private let matchTimeSubject: CurrentValueSubject<String?, Never>
    private let isLiveSubject: CurrentValueSubject<Bool, Never>
    private let match: Match
    private var cancellables = Set<AnyCancellable>()
    private var liveDataCancellable: AnyCancellable?
    
    // MARK: - Public Properties

    var headerDataPublisher: AnyPublisher<MatchHeaderCompactData, Never> {
        headerDataSubject.eraseToAnyPublisher()
    }

    var matchTimePublisher: AnyPublisher<String?, Never> {
        matchTimeSubject.eraseToAnyPublisher()
    }

    var isLivePublisher: AnyPublisher<Bool, Never> {
        isLiveSubject.eraseToAnyPublisher()
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

        // Initialize match time and live state
        let initialMatchTime = Self.formatMatchTime(from: match)
        self.matchTimeSubject = CurrentValueSubject(initialMatchTime)
        self.isLiveSubject = CurrentValueSubject(match.status.isLive)

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
            statisticsExpandedTitle: currentData.statisticsExpandedTitle,
            matchTime: currentData.matchTime,
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
    
    private func subscribeToLiveUpdates() {
        liveDataCancellable = Env.servicesProvider.subscribeToLiveDataUpdates(forEventWithId: match.id)
            .removeDuplicates()
            .sink(receiveCompletion: { completion in
                print("[MatchHeaderCompactVM] Live data subscription completed: \(completion)")
            }, receiveValue: { [weak self] subscribableContent in
                guard let self = self else { return }

                switch subscribableContent {
                case .connected(let subscription):
                    print("[MatchHeaderCompactVM] Connected to live data: \(subscription.id)")

                case .contentUpdate(let eventLiveData):
                    self.updateFromLiveData(eventLiveData)

                case .disconnected:
                    print("[MatchHeaderCompactVM] Disconnected from live data")
                }
            })
    }

    private func updateFromLiveData(_ eventLiveData: EventLiveData) {
        // Update match time/status display
        if let matchTime = eventLiveData.matchTime {
            // Has match time (Football, Basketball, etc.)
            if let status = eventLiveData.status, case .inProgress(let details) = status {
                // Combine status + time: "1st Half, 10 min"
                updateMatchTime(details + ", " + matchTime + " min")
            } else {
                // Just show time
                updateMatchTime(matchTime)
            }
        } else if let status = eventLiveData.status, case .inProgress(let details) = status {
            // No match time but has status (Tennis, etc.)
            // Show current game/set info: "6th Game (1st Set)"
            updateMatchTime(details)
        }

        // Update live status based on event status
        if let status = eventLiveData.status {
            updateIsLive(status.isInProgress)
        }
    }

    func updateMatchTime(_ time: String?) {
        matchTimeSubject.send(time)
    }

    func updateIsLive(_ isLive: Bool) {
        isLiveSubject.send(isLive)
    }

    deinit {
        liveDataCancellable?.cancel()
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

        // Format match time and live state
        let matchTime = formatMatchTime(from: match)
        let isLive = match.status.isLive

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
            matchTime: matchTime,
            isLive: isLive
        )
    }

    private static func formatMatchTime(from match: Match) -> String? {
        // If match has matchTime AND is in progress, combine status + time
        if let matchTime = match.matchTime,
           case .inProgress(let details) = match.status {
            return details + ", " + matchTime + " min"
        }
        // If no match time but has in-progress status (e.g., Tennis)
        else if case .inProgress(let details) = match.status {
            return details
        }
        // If has match time but not in progress
        else if let matchTime = match.matchTime {
            return matchTime
        }
        return nil
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
            statisticsExpandedTitle: currentData.statisticsExpandedTitle,
            matchTime: currentData.matchTime,
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
            matchTime: currentData.matchTime,
            isLive: currentData.isLive
        )

        headerDataSubject.send(updatedData)
    }
}
