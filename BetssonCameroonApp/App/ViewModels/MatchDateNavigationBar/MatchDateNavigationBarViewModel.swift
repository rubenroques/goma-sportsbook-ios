//
//  MatchDateNavigationBarViewModel.swift
//  Sportsbook
//
//  Created on 2025-07-16.
//

import Foundation
import Combine
import GomaUI
import ServicesProvider

final class MatchDateNavigationBarViewModel: MatchDateNavigationBarViewModelProtocol {
    
    // MARK: - Private Properties

    private let dataSubject: CurrentValueSubject<MatchDateNavigationBarData, Never>
    private let match: Match
    private var cancellables = Set<AnyCancellable>()
    private var liveDataCancellable: AnyCancellable?
    
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
        liveDataCancellable = Env.servicesProvider.subscribeToLiveDataUpdates(forEventWithId: match.id)
            .removeDuplicates()
            .sink(receiveCompletion: { completion in
                print("[MatchDateNavigationBarVM] Live data subscription completed: \(completion)")
            }, receiveValue: { [weak self] subscribableContent in
                guard let self = self else { return }

                switch subscribableContent {
                case .connected(let subscription):
                    print("[MatchDateNavigationBarVM] Connected to live data: \(subscription.id)")

                case .contentUpdate(let eventLiveData):
                    self.updateFromLiveData(eventLiveData)

                case .disconnected:
                    print("[MatchDateNavigationBarVM] Disconnected from live data")
                }
            })
    }

    private func updateFromLiveData(_ eventLiveData: EventLiveData) {
        // Update match status display in navigation bar
        if let status = eventLiveData.status {
            switch status {
            case .inProgress(let period):
                // Update live status with period and time
                let time = eventLiveData.matchTime ?? ""
                updateMatchStatus(period: period, time: time)

            case .ended:
                // Match ended
                updateMatchEnded()

            default:
                break
            }
        }
    }

    deinit {
        liveDataCancellable?.cancel()
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
