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
    
    private(set) var marketGroupSelectorTabViewModel: MarketGroupSelectorTabViewModelProtocol
    
    // MARK: - Initialization
    
    /// Initialize with a Match object (preferred for navigation from match lists)
    init(match: Match) {
        // Store match reference for WebSocket subscription
        self.currentMatch = match
        self.currentMatchId = match.id
        
        // Create child ViewModels (Vertical Pattern) with real match data
        self.multiWidgetToolbarViewModel = MockMultiWidgetToolbarViewModel.defaultMock
        self.matchDateNavigationBarViewModel = MatchDateNavigationBarViewModel(match: match)
        self.matchHeaderCompactViewModel = MatchHeaderCompactViewModel(match: match)
        self.statisticsWidgetViewModel = MockStatisticsWidgetViewModel.footballMatch
        
        // Create production market group selector for real match data
        self.marketGroupSelectorTabViewModel = MatchDetailsMarketGroupSelectorTabViewModel(match: match)
        marketGroupSelectorTabViewModelSubject.send(self.marketGroupSelectorTabViewModel)
        
        setupBindings()
        loadMatchDetails(matchId: match.id)
    }
    
    /// Initialize with a match ID (for deep linking or bookmarking)
    init(matchId: String) {
        // Store match ID for WebSocket subscription
        self.currentMatch = nil
        self.currentMatchId = matchId
        
        // Create child ViewModels (Vertical Pattern) with mock data initially
        // The real match data will be loaded asynchronously
        self.multiWidgetToolbarViewModel = MockMultiWidgetToolbarViewModel.defaultMock
        self.matchDateNavigationBarViewModel = MockMatchDateNavigationBarViewModel.liveMock
        self.matchHeaderCompactViewModel = MockMatchHeaderCompactViewModel.default
        self.statisticsWidgetViewModel = MockStatisticsWidgetViewModel.footballMatch
        self.marketGroupSelectorTabViewModel = MockMarketGroupSelectorTabViewModel.standardSportsMarkets
        marketGroupSelectorTabViewModelSubject.send(self.marketGroupSelectorTabViewModel)
        
        setupBindings()
        loadMatchDetails(matchId: matchId)
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
        
        eventDetailsSubscription = Env.servicesProvider.subscribeEventDetails(eventId: matchId)
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
                    
                    // Update current match and recreate market group selector with real data
                    self?.currentMatch = match
                    self?.marketGroupSelectorTabViewModel = MatchDetailsMarketGroupSelectorTabViewModel(match: match)
                    self?.marketGroupSelectorTabViewModelSubject.send(self?.marketGroupSelectorTabViewModel)
                    
                    // Mark event details as loaded
                    self?.isEventDetailsLoaded = true
                    self?.setupMarketGroupsLoadingObserver()
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
        
        // Step 4: Wire up MatchHeaderCompactView statistics button to toggle StatisticsWidgetView
        matchHeaderCompactViewModel.onStatisticsTapped = { [weak self] in
            self?.toggleStatistics()
        }
        
        // This will be expanded as we add each component
    }
    
    // MARK: - Loading Coordination
    
    private func setupMarketGroupsLoadingObserver() {
        // Cancel any existing market groups subscription to avoid memory leaks
        marketGroupsSubscription?.cancel()
        
        // Reset market groups loaded state since we're observing a new view model
        isMarketGroupsLoaded = false
        
        
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
