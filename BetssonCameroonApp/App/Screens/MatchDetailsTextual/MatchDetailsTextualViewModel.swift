//
//  MatchDetailsTextualViewModel.swift
//  Sportsbook
//
//  Created on 2025-07-16.
//

import Foundation
import Combine
import GomaUI
import ServicesProvider

class MatchDetailsTextualViewModel {
    
    // MARK: - Private Properties
    
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let errorSubject = CurrentValueSubject<String?, Never>(nil)

    private let statisticsVisibilitySubject = CurrentValueSubject<Bool, Never>(false)
    private let marketGroupSelectorTabViewModelSubject = CurrentValueSubject<MarketGroupSelectorTabViewModelProtocol?, Never>(nil)
    
    private let servicesProvider: ServicesProvider.Client
    private var cancellables = Set<AnyCancellable>()
    
    // WebSocket subscription management
    private var eventDetailsSubscription: AnyCancellable?
    
    // Store match reference for real event ID
    private var currentMatch: Match?
    private var currentMatchId: String?
    
    // Track loading completion states
    private var isEventDetailsLoaded = false
    private var isMarketGroupsLoaded = false
    private var marketGroupsSubscription: AnyCancellable?
    
    // MARK: - Child ViewModels (Vertical Pattern)
    let multiWidgetToolbarViewModel: MultiWidgetToolbarViewModelProtocol
    
    let matchDateNavigationBarViewModel: MatchDateNavigationBarViewModelProtocol
    
    let matchHeaderCompactViewModel: MatchHeaderCompactViewModelProtocol
    
    let statisticsWidgetViewModel: StatisticsWidgetViewModelProtocol
    
    let marketGroupSelectorTabViewModel: MatchDetailsMarketGroupSelectorTabViewModel
    
    // MARK: - Initialization
    
    /// Initialize with a Match object (preferred for navigation from match lists)
    init(match: Match, servicesProvider: ServicesProvider.Client) {
        self.servicesProvider = servicesProvider
        self.currentMatch = match
        self.currentMatchId = match.id
        
        self.multiWidgetToolbarViewModel = MockMultiWidgetToolbarViewModel.defaultMock
        self.matchDateNavigationBarViewModel = MatchDateNavigationBarViewModel(match: match)
        self.matchHeaderCompactViewModel = MatchHeaderCompactViewModel(match: match)
        self.statisticsWidgetViewModel = MockStatisticsWidgetViewModel.footballMatch
        self.marketGroupSelectorTabViewModel = MatchDetailsMarketGroupSelectorTabViewModel(match: match)
        
        commonInit()
    }
    
    
    private func commonInit() {
        marketGroupSelectorTabViewModelSubject.send(self.marketGroupSelectorTabViewModel)
        setupBindings()
        
        if let matchId = currentMatchId {
            loadMatchDetails(matchId: matchId)
        }
    }
    
    // MARK: - Publishers
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<String?, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    var statisticsVisibilityPublisher: AnyPublisher<Bool, Never> {
        statisticsVisibilitySubject.eraseToAnyPublisher()
    }
    
    var marketGroupSelectorTabViewModelPublisher: AnyPublisher<MarketGroupSelectorTabViewModelProtocol, Never> {
        marketGroupSelectorTabViewModelSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Event Data
    
    /// The event ID for this match
    var eventId: String {
        return currentMatchId ?? ""
    }
    
    // MARK: - Methods
    private func loadMatchDetails(matchId: String) {
        self.currentMatchId = matchId
        isLoadingSubject.send(true)
        
        eventDetailsSubscription = servicesProvider.subscribeEventDetails(eventId: matchId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("Event details subscription completed: \(completion)")
            } receiveValue: { [weak self] subscribableContent in
                print("Received event details content: \(subscribableContent)")
                
                switch subscribableContent {
                case .connected(let subscription):
                    print("✅ Connected to event details WebSocket: \(subscription.id)")
                    
                case .contentUpdate(let event):
                    guard
                        let match = ServiceProviderModelMapper.match(fromEvent: event)
                    else { return }
                    
                    print("📡 Received event data: \(match.id)")
                    print("   Match: \(match.homeParticipant.name) vs \(match.awayParticipant.name)")
                    print("   Status: \(match.status)")
                    print("   Markets: \(match.markets.count)")
                    
                    // Update current match and update market group selector with real data
                    self?.currentMatch = match
                    
                    // Update existing view model instead of recreating it
                    self?.marketGroupSelectorTabViewModel.updateMatch(match)
                    
                    // Mark event details as loaded
                    self?.isEventDetailsLoaded = true
                    self?.checkLoadingCompletion()
                    
                case .disconnected:
                    print("❌ Disconnected from event details WebSocket")
                    self?.isEventDetailsLoaded = true
                    self?.checkLoadingCompletion()
                }
            }
    }
    
    func toggleStatistics() {
        let currentVisibility = statisticsVisibilitySubject.value
        statisticsVisibilitySubject.send(!currentVisibility)
    }
    
    func refresh() {
        errorSubject.send(nil)
        eventDetailsSubscription?.cancel()
        
        if let currentMatchId = self.currentMatchId {
            self.loadMatchDetails(matchId: currentMatchId)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Setup communication between child ViewModels
        
        // Wire up MatchHeaderCompactView statistics button to toggle StatisticsWidgetView
        matchHeaderCompactViewModel.onStatisticsTapped = { [weak self] in
            self?.toggleStatistics()
        }
        
        // Setup loading coordination with market groups
        // Subscribe to market groups data changes to know when they load
        marketGroupsSubscription = marketGroupSelectorTabViewModel.marketGroupsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] marketGroups in
                guard let self = self else { return }
                
                // Mark market groups as loaded when we receive data
                if !marketGroups.isEmpty {
                    self.isMarketGroupsLoaded = true
                    self.checkLoadingCompletion()
                }
            }
    }
    
    // MARK: - Loading Coordination
    
    private func checkLoadingCompletion() {
        let isFullyLoaded = isEventDetailsLoaded && isMarketGroupsLoaded
        
        if isFullyLoaded {
            isLoadingSubject.send(false)
        }
    }
    
    deinit {
        eventDetailsSubscription?.cancel()
        marketGroupsSubscription?.cancel()
    }
}
