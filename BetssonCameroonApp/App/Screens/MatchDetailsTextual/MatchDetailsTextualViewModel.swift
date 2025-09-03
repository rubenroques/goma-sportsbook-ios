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

class MatchDetailsTextualViewModel: ObservableObject {
    
    // MARK: - Navigation Closures for RootTabBarCoordinator
    var onNavigateBack: (() -> Void) = { }
    
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
    
    // Store match reference for real event ID
    private var currentMatch: Match?
    private var currentMatchId: String?
    
    // Track loading completion states
    private var isEventDetailsLoaded = false
    private var isMarketGroupsLoaded = false
    private var marketGroupsSubscription: AnyCancellable?
    
    // MARK: - Child ViewModels (Vertical Pattern)
    let multiWidgetToolbarViewModel: MultiWidgetToolbarViewModel
    
    let walletStatusViewModel: WalletStatusViewModel
    
    let matchDateNavigationBarViewModel: MatchDateNavigationBarViewModelProtocol
    
    let matchHeaderCompactViewModel: MatchHeaderCompactViewModelProtocol
    
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
        
        // Use production ViewModels instead of mocks
        self.multiWidgetToolbarViewModel = MultiWidgetToolbarViewModel()
        self.walletStatusViewModel = WalletStatusViewModel(userSessionStore: userSessionStore)
        
        // Keep existing ViewModels as they are
        self.matchDateNavigationBarViewModel = MatchDateNavigationBarViewModel(match: match)
        self.matchHeaderCompactViewModel = MatchHeaderCompactViewModel(match: match)
        self.statisticsWidgetViewModel = MockStatisticsWidgetViewModel.footballMatch
        self.marketGroupSelectorTabViewModel = MatchDetailsMarketGroupSelectorTabViewModel(match: match)
        self.betslipFloatingViewModel = MockBetslipFloatingViewModel.noTicketsMock()
        
        commonInit()
        setupReactiveWalletChain()
        setupMultiWidgetToolbarBinding()
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
    
    func navigateBack() {
        onNavigateBack()
    }
    
    func handleOutcomeSelection(marketGroup: MarketGroupWithIcons, outcomeId: String, isSelected: Bool) {
        
        guard let match = currentMatch else { return }
        
        let outcome = marketGroup.marketGroup.marketLines.compactMap { marketLine in
            if marketLine.leftOutcome?.id == outcomeId {
                return marketLine.leftOutcome
            } else if marketLine.middleOutcome?.id == outcomeId {
                return marketLine.middleOutcome
            } else if marketLine.rightOutcome?.id == outcomeId {
                return marketLine.rightOutcome
            }
            return nil
        }.first
        
        let oddDouble = Double(outcome?.value ?? "")
        
        let bettingTicket = BettingTicket(id: outcome?.bettingOfferId ?? outcomeId, outcomeId: outcomeId, marketId: marketGroup.marketGroup.id, matchId: match.id, decimalOdd: oddDouble ?? 0.0, isAvailable: true, matchDescription: "\(match.homeParticipant.name) - \(match.awayParticipant.name)", marketDescription: marketGroup.groupName, outcomeDescription: outcome?.title ?? "", homeParticipantName: match.homeParticipant.name, awayParticipantName: match.awayParticipant.name, sportIdCode: match.sportIdCode, competition: match.competitionName, date: match.date)
        
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
        
        // Wire up MatchHeaderCompactView statistics button to toggle StatisticsWidgetView
        matchHeaderCompactViewModel.onStatisticsTapped = { [weak self] in
            self?.toggleStatistics()
        }
        
        // Setup betslip binding
        setupBetslipBinding()
        
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
    
    // MARK: - Betslip Binding
    private func setupBetslipBinding() {
        // Subscribe to betslip manager tickets to update floating view state
        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tickets in
                self?.updateBetslipFloatingState(tickets: tickets)
            }
            .store(in: &cancellables)
    }
    
    private func updateBetslipFloatingState(tickets: [BettingTicket]) {
        if tickets.isEmpty {
            betslipFloatingViewModel.updateState(.noTickets)
        } else {
            // Calculate total odds and other betslip data
            let selectionCount = tickets.count
            let totalOdds = calculateTotalOdds(from: tickets)
            let totalEligibleCount = 0
            
            betslipFloatingViewModel.updateState(.withTickets(
                selectionCount: selectionCount,
                odds: String(format: "%.2f", totalOdds),
                winBoostPercentage: nil, // TODO: Implement win boost calculation
                totalEligibleCount: totalEligibleCount
            ))
        }
    }
    
    private func calculateTotalOdds(from tickets: [BettingTicket]) -> Double {
        return tickets.reduce(1.0) { total, ticket in
            total * ticket.decimalOdd
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
    
    // MARK: - Wallet and Authentication Management
    
    private func setupReactiveWalletChain() {
        // Step 1: Set up base authentication state
        userSessionStore.userProfilePublisher
            .map { $0 != nil }
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAuthenticated)
        
        // Step 2: Reactive chain - Authentication state drives wallet UI updates
        $isAuthenticated
            .combineLatest(userSessionStore.userWalletPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated, wallet in
                guard let self = self else { return }
                
                if isAuthenticated {
                    // User is logged in - show logged in state and wallet data
                    let layoutState: LayoutState = .loggedIn
                    self.multiWidgetToolbarViewModel.setLayoutState(layoutState)
                    
                    // Update wallet balance if available
                    if let walletBalance = wallet?.total {
                        self.multiWidgetToolbarViewModel.setWalletBalance(balance: walletBalance)
                        print("💰 MatchDetailsTextual: Wallet balance updated - total: \(walletBalance)")
                    }
                    
                    // Wallet status view model will update automatically via its own binding
                    
                    print("🔐 MatchDetailsTextual: User authenticated with wallet data")
                } else {
                    // User is logged out - show logged out state
                    let layoutState: LayoutState = .loggedOut
                    self.multiWidgetToolbarViewModel.setLayoutState(layoutState)
                    
                    print("🔐 MatchDetailsTextual: User logged out")
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupMultiWidgetToolbarBinding() {
        // Subscribe to wallet updates to keep the toolbar wallet widget in sync
        userSessionStore.userWalletPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] wallet in
                if let walletBalance = wallet?.total {
                    self?.multiWidgetToolbarViewModel.setWalletBalance(balance: walletBalance)
                    print("💰 MatchDetailsTextual: Toolbar wallet balance updated - total: \(walletBalance)")
                }
            }
            .store(in: &cancellables)
    }
}
