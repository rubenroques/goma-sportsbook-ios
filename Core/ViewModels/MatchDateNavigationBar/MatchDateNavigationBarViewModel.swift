//
//  MatchDateNavigationBarViewModel.swift
//  Sportsbook
//
//  Created on 2025-07-16.
//

import Foundation
import Combine
import GomaUI

final class MatchDateNavigationBarViewModel: MatchDateNavigationBarViewModelProtocol {
    
    // MARK: - Private Properties
    
    private let dataSubject: CurrentValueSubject<MatchDateNavigationBarData, Never>
    private let match: Match
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    
    var dataPublisher: AnyPublisher<MatchDateNavigationBarData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    var data: MatchDateNavigationBarData {
        dataSubject.value
    }
    
    // MARK: - Initialization
    
    init(match: Match) {
        self.match = match
        
        // Create initial data from match
        let initialData = Self.createNavigationBarData(from: match)
        self.dataSubject = CurrentValueSubject(initialData)
        
        // Subscribe to live data updates if match is live
        if match.status.isLive {
            subscribeToLiveUpdates()
        }
    }
    
    // MARK: - MatchDateNavigationBarViewModelProtocol
    
    func configure(with data: MatchDateNavigationBarData) {
        dataSubject.send(data)
    }
    
    // MARK: - Private Methods
    
    private func subscribeToLiveUpdates() {
        // Subscribe to live match updates
        // This would integrate with the existing live data service
        // For now, we'll set up the structure
        
        // TODO: Integrate with Env.servicesProvider.subscribeToLiveDataUpdates
        // This would update the match status in real-time
    }
    
    private static func createNavigationBarData(from match: Match) -> MatchDateNavigationBarData {
        let matchStatus = createMatchStatus(from: match)
        
        return MatchDateNavigationBarData(
            id: match.id,
            matchStatus: matchStatus,
            backButtonText: "Back",
            isBackButtonHidden: false,
            dateFormat: "dd MMMM,hh:mm"
        )
    }
    
    private static func createMatchStatus(from match: Match) -> MatchStatus {
        switch match.status {
        case .notStarted:
            // Use match date for pre-match display
            if let date = match.date {
                return .preMatch(date: date)
            } else {
                // Fallback to current time if no date available
                return .preMatch(date: Date())
            }
            
        case .inProgress(let period):
            // For live matches, use the period and match time
            let time = match.matchTime ?? ""
            return .live(period: period, time: time)
            
        case .ended:
            // Show ended status as live with "Ended" period
            return .live(period: "Ended", time: "")
            
        case .unknown:
            // Default to current time for unknown status
            return .preMatch(date: Date())
        }
    }
}

// MARK: - Live Data Updates
extension MatchDateNavigationBarViewModel {
    
    /// Updates the navigation bar with new match status information
    /// This would be called when live data updates are received
    public func updateMatchStatus(period: String, time: String) {
        let currentData = dataSubject.value
        let newMatchStatus = MatchStatus.live(period: period, time: time)
        
        let updatedData = MatchDateNavigationBarData(
            id: currentData.id,
            matchStatus: newMatchStatus,
            backButtonText: currentData.backButtonText,
            isBackButtonHidden: currentData.isBackButtonHidden,
            dateFormat: currentData.dateFormat
        )
        
        dataSubject.send(updatedData)
    }
    
    /// Updates the navigation bar for match end
    public func updateMatchEnded() {
        let currentData = dataSubject.value
        let endedStatus = MatchStatus.live(period: "Ended", time: "")
        
        let updatedData = MatchDateNavigationBarData(
            id: currentData.id,
            matchStatus: endedStatus,
            backButtonText: currentData.backButtonText,
            isBackButtonHidden: currentData.isBackButtonHidden,
            dateFormat: currentData.dateFormat
        )
        
        dataSubject.send(updatedData)
    }
}
