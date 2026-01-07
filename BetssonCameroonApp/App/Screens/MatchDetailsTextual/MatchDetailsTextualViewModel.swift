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
import SharedModels

class MatchDetailsTextualViewModel: ObservableObject {
    
    // MARK: - Navigation Closures for MainTabBarCoordinator
    var onNavigateBack: (() -> Void) = { }
    var onBetslipRequested: (() -> Void)?
    var onNavigateToNextUpWithCountry: ((String) -> Void)?
    var onNavigateToNextUpWithLeague: ((String) -> Void)?

    // MARK: - Private Properties
    
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let errorSubject = CurrentValueSubject<String?, Never>(nil)

    private let statisticsVisibilitySubject = CurrentValueSubject<Bool, Never>(false)
    private let marketGroupSelectorTabViewModelSubject = CurrentValueSubject<MarketGroupSelectorTabViewModelProtocol?, Never>(nil)
    
    private let servicesProvider: ServicesProvider.Client
    private let userSessionStore: UserSessionStore
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Authentication State (Clean MVVM Pattern)
    
    @Published var isAuthenticated: Bool = false
    
    // WebSocket subscription management
    private var eventDetailsSubscription: AnyCancellable?
    private var liveDataSubscription: AnyCancellable?

    // Store match reference for real event ID
    private var currentMatch: Match?
    private var currentMatchId: String?

    // Track loading completion states
    private var isEventDetailsLoaded = false
    private var isMarketGroupsLoaded = false
    private var marketGroupsSubscription: AnyCancellable?

    // BLINK_DEBUG: Track event updates
    private var eventUpdateCounter = 0
    
    // MARK: - Child ViewModels (Vertical Pattern)
    // MultiWidget and Wallet ViewModels are now managed by TopBarContainerController
    
    let matchDateNavigationBarViewModel: MatchDateNavigationBarViewModel
    
    let matchHeaderCompactViewModel: MatchHeaderCompactViewModel
    
    let statisticsWidgetViewModel: StatisticsWidgetViewModelProtocol
    
    let marketGroupSelectorTabViewModel: MatchDetailsMarketGroupSelectorTabViewModel
    
    var betslipFloatingViewModel: BetslipFloatingViewModelProtocol
    
    // MARK: - Initialization
    
    /// Initialize with a Match object (preferred for navigation from match lists)
    init(match: Match, servicesProvider: ServicesProvider.Client, userSessionStore: UserSessionStore) {
        self.servicesProvider = servicesProvider
        self.userSessionStore = userSessionStore
        self.currentMatch = match
        self.currentMatchId = match.id
        
        // MultiWidget and Wallet ViewModels are now managed by TopBarContainerController
        
        // Keep existing ViewModels as they are
        self.matchDateNavigationBarViewModel = MatchDateNavigationBarViewModel(match: match)
        self.matchHeaderCompactViewModel = MatchHeaderCompactViewModel(match: match)
        self.statisticsWidgetViewModel = MockStatisticsWidgetViewModel.footballMatch
        self.marketGroupSelectorTabViewModel = MatchDetailsMarketGroupSelectorTabViewModel(match: match)
        self.betslipFloatingViewModel = BetslipFloatingViewModel()

        // Setup betslip tap callback
        self.betslipFloatingViewModel.onBetslipTapped = { [weak self] in
            self?.onBetslipRequested?()
        }

        commonInit()
        setupAuthenticationState()
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

                    // Now that matchDetailsManager exists, start loading market groups
                    self?.marketGroupSelectorTabViewModel.startLoading()
                    
                case .contentUpdate(let event):
                    guard
                        let match = ServiceProviderModelMapper.match(fromEvent: event)
                    else { return }

                    self?.eventUpdateCounter += 1
                    let matchIdChanged = self?.currentMatch?.id != match.id

                    print("BLINK_DEBUG [MatchDetailsVM] 🎯 Event Update #\(self?.eventUpdateCounter ?? 0) | Match ID changed: \(matchIdChanged)")
                    print("📡 Received event data: \(match.id)")
                    print("   Match: \(match.homeParticipant.name) vs \(match.awayParticipant.name)")
                    print("   Status: \(match.status)")
                    print("   Markets: \(match.markets.count)")

                    // Update current match and update market group selector with real data
                    self?.currentMatch = match

                    // Update header with live match data (including scores)
                    self?.matchHeaderCompactViewModel.updateMatch(match)

                    // NOTE: We do NOT call marketGroupSelectorTabViewModel.updateMatch() here.
                    // The market groups have their own WebSocket subscription that handles updates.
                    // Calling updateMatch() was causing destructive reload cycles (flickering).

                    // Mark event details as loaded
                    self?.isEventDetailsLoaded = true
                    self?.checkLoadingCompletion()
                    
                case .disconnected:
                    print("❌ Disconnected from event details WebSocket")
                    self?.isEventDetailsLoaded = true
                    self?.checkLoadingCompletion()
                }
            }

        // Subscribe to live data for scores/status updates
        subscribeLiveData(matchId: matchId)
    }

    private func subscribeLiveData(matchId: String) {
        liveDataSubscription = servicesProvider.subscribeToLiveDataUpdates(forEventWithId: matchId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("[LIVE_DATA] Live data subscription completed: \(completion)")
            } receiveValue: { [weak self] subscribableContent in
                switch subscribableContent {
                case .connected(let subscription):
                    print("[LIVE_DATA] ✅ Connected to live data: \(subscription.id)")

                case .contentUpdate(let liveData):
                    print("[LIVE_DATA] 📊 Received live data update")

                    // Map ServicesProvider.EventLiveData to app MatchLiveData
                    let matchLiveData = ServiceProviderModelMapper.matchLiveData(fromServiceProviderEventLiveData: liveData)

                    // Update header with live scores
                    self?.matchHeaderCompactViewModel.updateMatchWithLiveData(matchLiveData)
                    self?.matchDateNavigationBarViewModel.updateMatchWithLiveData(matchLiveData)

                case .disconnected:
                    print("[LIVE_DATA] ❌ Disconnected from live data")
                }
            }
    }

    func toggleStatistics() {
        let currentVisibility = statisticsVisibilitySubject.value
        statisticsVisibilitySubject.send(!currentVisibility)
    }

    private func handleCountryTapped(countryId: String) {
        onNavigateToNextUpWithCountry?(countryId)
    }

    private func handleLeagueTapped(leagueId: String) {
        onNavigateToNextUpWithLeague?(leagueId)
    }

    func refresh() {
        errorSubject.send(nil)
        eventDetailsSubscription?.cancel()
        liveDataSubscription?.cancel()

        if let currentMatchId = self.currentMatchId {
            self.loadMatchDetails(matchId: currentMatchId)
        }
    }
    
    func navigateBack() {
        onNavigateBack()
    }
    
    func handleOutcomeSelection(marketGroup: MarketGroupWithIcons, outcomeId: String, isSelected: Bool) {
        
        guard let match = currentMatch else { return }
        
        let result = marketGroup.marketGroup.marketLines.compactMap { marketLine -> (outcome: MarketOutcomeData, marketId: String)? in
            if let leftOutcome = marketLine.leftOutcome, leftOutcome.id == outcomeId {
                return (leftOutcome, marketLine.id)
            } else if let middleOutcome = marketLine.middleOutcome, middleOutcome.id == outcomeId {
                return (middleOutcome, marketLine.id)
            } else if let rightOutcome = marketLine.rightOutcome, rightOutcome.id == outcomeId {
                return (rightOutcome, marketLine.id)
            }
            return nil
        }.first
        
        let outcome = result?.outcome
        let marketId = result?.marketId ?? marketGroup.marketGroup.id
        let oddDouble = Double(outcome?.value ?? "")
                
        let bettingTicket = BettingTicket(
            id: outcome?.bettingOfferId ?? outcomeId,
            outcomeId: outcomeId,
            marketId: marketId,
            matchId: match.id,
            marketTypeId: marketGroup.marketGroup.id,
            decimalOdd: oddDouble ?? 0.0,
            isAvailable: true,
            matchDescription: "\(match.homeParticipant.name) - \(match.awayParticipant.name)",
            marketDescription: marketGroup.groupName,
            outcomeDescription: outcome?.completeName ?? "",
            homeParticipantName: match.homeParticipant.name,
            awayParticipantName: match.awayParticipant.name,
            sportIdCode: match.sportIdCode,
            competition: match.competitionName,
            date: match.date
        )
        
        if isSelected {
            Env.betslipManager.addBettingTicket(bettingTicket)
        }
        else {
            Env.betslipManager.removeBettingTicket(bettingTicket)
        }
    }
    
    // MARK: - Private Methods

    private func setupBindings() {
        // Setup communication between child ViewModels

        // Wire up breadcrumb tap callbacks for navigation
        matchHeaderCompactViewModel.onCountryTapped = { [weak self] countryId in
            self?.handleCountryTapped(countryId: countryId)
        }

        matchHeaderCompactViewModel.onLeagueTapped = { [weak self] leagueId in
            self?.handleLeagueTapped(leagueId: leagueId)
        }

        // Production BetslipFloatingViewModel handles its own bindings automatically

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
        liveDataSubscription?.cancel()
        marketGroupsSubscription?.cancel()
    }
    
    // MARK: - Authentication Management

    private func setupAuthenticationState() {
        // Set up authentication state tracking (used by betslip and other features)
        userSessionStore.userProfilePublisher
            .map { $0 != nil }
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAuthenticated)
    }
}
