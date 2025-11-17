//
//  InPlayEventsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/06/2025.
//

import UIKit
import GomaUI
import Combine
import ServicesProvider
import SharedModels

// MARK: - InPlayEventsViewModel
class InPlayEventsViewModel {

    // MARK: - Published Properties
    private let allMatchesSubject = CurrentValueSubject<[Match], Never>([])
    var allMatchesPublisher: AnyPublisher<[Match], Never> {
        allMatchesSubject.eraseToAnyPublisher()
    }
    var allMatches: [Match] {
        get { allMatchesSubject.value }
        set { allMatchesSubject.send(newValue) }
    }
    
    private let marketGroupsSubject = CurrentValueSubject<[MarketGroupTabItemData], Never>([])
    var marketGroupsPublisher: AnyPublisher<[MarketGroupTabItemData], Never> {
        marketGroupsSubject.eraseToAnyPublisher()
    }
    var marketGroups: [MarketGroupTabItemData] {
        get { marketGroupsSubject.value }
        set { marketGroupsSubject.send(newValue) }
    }
    
    private let selectedMarketGroupIdSubject = CurrentValueSubject<String?, Never>(nil)
    var selectedMarketGroupIdPublisher: AnyPublisher<String?, Never> {
        selectedMarketGroupIdSubject.eraseToAnyPublisher()
    }
    var selectedMarketGroupId: String? {
        get { selectedMarketGroupIdSubject.value }
        set { selectedMarketGroupIdSubject.send(newValue) }
    }
    
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    var isLoading: Bool {
        get { isLoadingSubject.value }
        set { isLoadingSubject.send(newValue) }
    }
    
    private let mainMarketsSubject = CurrentValueSubject<[MainMarket]?, Never>(nil)
    var mainMarketsPublisher: AnyPublisher<[MainMarket]?, Never> {
        mainMarketsSubject.eraseToAnyPublisher()
    }
    var mainMarkets: [MainMarket]? {
        get { mainMarketsSubject.value }
        set { mainMarketsSubject.send(newValue) }
    }

    // MARK: - Child ViewModels
    let quickLinksTabBarViewModel: QuickLinksTabBarViewModel
    let topBannerSliderViewModel: TopBannerSliderViewModel
    let pillSelectorBarViewModel: PillSelectorBarViewModel
    let marketGroupSelectorViewModel: MarketGroupSelectorTabViewModel

    // MARK: - Navigation Closures (MVVM-C Pattern)
    // ViewModels signal navigation intent through closures - Coordinators handle actual navigation
    var onMatchSelected: ((Match) -> Void) = { _ in
        print("Empty clojure")
    }
    var onSportsSelectionRequested: (() -> Void)  = {
        print("Empty clojure")
    }
    var onFiltersRequested: (() -> Void) = {
        print("Empty clojure")
    }
    var onLiveStatsRequested: ((String) -> Void) = { _ in
        print("Empty clojure")
    }
    
    // Casino navigation closure for QuickLinks
    var onCasinoQuickLinkSelected: ((QuickLinkType) -> Void)?

    // Sport banner navigation closure
    var onMatchTap: ((String) -> Void)?

    // Banner URL navigation closure
    var onBannerURLRequested: ((String, String?) -> Void)?

    // MARK: - Private Properties
    var sport: Sport
    private var appliedFilters = AppliedEventsFilters.defaultFilters
    private let servicesProvider: ServicesProvider.Client
    private var eventsStateSubject = CurrentValueSubject<LoadableContent<[Match]>, Never>.init(.loading)
    private var cancellables: Set<AnyCancellable> = []
    private var preLiveMatchesCancellable: AnyCancellable?

    // Store market group ViewModels
    private var marketGroupCardsViewModels: [String: MarketGroupCardsViewModel] = [:]

    // MARK: - Pagination State (NEW)
    private var isLoadingMore = false

    private let hasMoreEventsSubject = CurrentValueSubject<Bool, Never>(true)
    var hasMoreEventsPublisher: AnyPublisher<Bool, Never> {
        hasMoreEventsSubject.eraseToAnyPublisher()
    }
    var hasMoreEvents: Bool {
        get { hasMoreEventsSubject.value }
        set { hasMoreEventsSubject.send(newValue) }
    }

    // MARK: - Public Properties
    var eventsState: AnyPublisher<LoadableContent<[Match]>, Never> {
        return self.eventsStateSubject.eraseToAnyPublisher()
    }

    init(sport: Sport, servicesProvider: ServicesProvider.Client) {
        self.sport = sport
        self.servicesProvider = servicesProvider
        // Create production QuickLinks ViewModel
        self.quickLinksTabBarViewModel = QuickLinksTabBarViewModel.forSportsScreens()

        // Create TopBannerSlider ViewModel for sports banners
        self.topBannerSliderViewModel = TopBannerSliderViewModel(servicesProvider: servicesProvider)

        self.pillSelectorBarViewModel = PillSelectorBarViewModel()
        self.marketGroupSelectorViewModel = MarketGroupSelectorTabViewModel()
        
        // Initialize filters with the sport
        self.appliedFilters = AppliedEventsFilters(
            sportId: FilterIdentifier(stringValue: sport.id),
            timeFilter: .all,
            sortType: .popular,
            leagueFilter: .all
        )

        setupBindings()
    }
    
    func updateSportType(_ sport: Sport) {
        print("📱 InPlayEventsViewModel: Updating sport type to \(sport.name)")
        
        // Cancel existing subscription immediately
        preLiveMatchesCancellable?.cancel()
        preLiveMatchesCancellable = nil
        
        // Clear all current state immediately
        print("🧹 InPlayEventsViewModel: Clearing existing state for sport change")
        allMatches = []
        marketGroups = []
        selectedMarketGroupId = nil
        
        // Set loading state immediately
        isLoading = true
        eventsStateSubject.send(.loading)
        
        // Clear all market group view models
        print("🧹 InPlayEventsViewModel: Clearing \(marketGroupCardsViewModels.count) market group view models")
        for (marketType, viewModel) in marketGroupCardsViewModels {
            viewModel.updateMatches([]) // Clear matches in each view model
            print("   - Cleared market group: \(marketType)")
        }
        marketGroupCardsViewModels.removeAll()
        
        // Update internal sport and filters
        self.sport = sport
        appliedFilters.sportId = FilterIdentifier(stringValue: sport.id)
        
        // Update UI
        pillSelectorBarViewModel.updateCurrentSport(sport)
        
        // Update market group selector to clear its state
        marketGroupSelectorViewModel.updateWithMatches([])
        
        // Reload events for new sport
        print("🔄 InPlayEventsViewModel: Starting reload for new sport: \(sport.name)")
        reloadEvents(forced: true)
    }
    
    func updateFilters(_ filters: AppliedEventsFilters) {
        // Check if filters actually changed
        guard appliedFilters != filters else {
            print("🎛️ InPlayEventsViewModel: Filters unchanged, skipping update")
            return
        }
        
        print("🎛️ InPlayEventsViewModel: Updating filters: \(filters)")
        
        // Cancel existing subscription
        preLiveMatchesCancellable?.cancel()
        preLiveMatchesCancellable = nil
        
        // Clear all state
        allMatches = []
        marketGroups = []
        selectedMarketGroupId = nil
        isLoading = true
        eventsStateSubject.send(.loading)
        
        // Clear market group view models
        for (_, viewModel) in marketGroupCardsViewModels {
            viewModel.updateMatches([])
        }
        marketGroupCardsViewModels.removeAll()
        
        // Update filters
        self.appliedFilters = filters
        
        // Update sport if it changed
        if let newSport = Env.sportsStore.getActiveSports().first(where: { $0.id == filters.sportId.rawValue }) {
            self.sport = newSport
            pillSelectorBarViewModel.updateCurrentSport(newSport)
        }
        
        // Clear market group selector
        marketGroupSelectorViewModel.updateWithMatches([])
        
        // Reload events with new filters
        reloadEvents(forced: true)
    }

    // MARK: - Setup
    private func setupBindings() {
        // Setup QuickLinks navigation callback
        quickLinksTabBarViewModel.onQuickLinkSelected = { [weak self] quickLinkType in
            self?.onCasinoQuickLinkSelected?(quickLinkType)
        }
    

        // Setup TopBannerSlider navigation callback
        topBannerSliderViewModel.onMatchTap = { [weak self] eventId in
            self?.onMatchTap?(eventId)
        }

        // Setup Info Banner action callback
        topBannerSliderViewModel.onInfoBannerAction = { [weak self] action in
            switch action {
            case .openURL(let url, let target):
                self?.onBannerURLRequested?(url, target)
            case .none:
                break
            }
        }

        // Setup Casino Banner action callback
        topBannerSliderViewModel.onCasinoBannerAction = { [weak self] action in
            switch action {
            case .openURL(let url):
                self?.onBannerURLRequested?(url, nil)
            case .launchGame:
                // Casino game launch is handled separately - could forward to casino coordinator
                break
            case .none:
                break
            }
        }


        // Listen to market group selection changes from selector ViewModel
        marketGroupSelectorViewModel.selectionEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectionEvent in
                self?.selectedMarketGroupId = selectionEvent.selectedId
            }
            .store(in: &cancellables)

        // Listen to market groups updates from selector ViewModel
        marketGroupSelectorViewModel.marketGroupsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] marketGroups in
                self?.updateMarketGroupViewModels(marketGroups: marketGroups)
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods
    func reloadEvents(forced: Bool = false) {
        self.loadEvents()
    }

    /// Load next page of live matches (pagination)
    /// This triggers the provider to request more events with an increased limit
    /// New data arrives automatically via the existing subscription
    func loadNextPage() {
        // Guard: Don't trigger if already loading more
        guard !isLoadingMore else {
            print("[InPlayEventsViewModel] ⚠️ Already loading more events")
            return
        }

        print("[InPlayEventsViewModel] 📄 Loading next page of events")
        isLoadingMore = true

        // Propagate loading state to child ViewModels
        for (_, viewModel) in marketGroupCardsViewModels {
            viewModel.isLoadingMore = true
        }

        // Convert current filters to MatchesFilterOptions
        let filterOptions = appliedFilters.toMatchesFilterOptions()

        // Request next page
        // Returns Bool immediately (success/failure)
        // New data flows through the existing subscription automatically
        servicesProvider
            .requestFilteredLiveMatchesNextPage(filters: filterOptions)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("[InPlayEventsViewModel] ❌ Pagination error: \(error)")
                    self?.isLoadingMore = false
                }
            } receiveValue: { [weak self] success in
                if success {
                    print("[InPlayEventsViewModel] ✅ Pagination started - waiting for data")
                    // New data will arrive via existing subscription in loadEvents()
                    // processMatches() will reset isLoadingMore to false
                } else {
                    print("[InPlayEventsViewModel] ℹ️ No more pages available")
                    self?.isLoadingMore = false
                    self?.hasMoreEvents = false  // No more pages to load
                }
            }
            .store(in: &cancellables)
    }

    func selectMarketGroup(id: String) {
        marketGroupSelectorViewModel.selectMarketGroup(id: id)
    }

    func getMarketGroupCardsViewModel(for marketGroupId: String) -> MarketGroupCardsViewModel? {
        return marketGroupCardsViewModels[marketGroupId]
    }

    func getAllMarketGroupCardsViewModels() -> [String: MarketGroupCardsViewModel] {
        return marketGroupCardsViewModels
    }

    func getCurrentMarketGroups() -> [MarketGroupTabItemData] {
        return marketGroupSelectorViewModel.currentMarketGroups
    }

    func getCurrentSelectedMarketGroupId() -> String? {
        return marketGroupSelectorViewModel.currentSelectedMarketGroupId
    }
    
    func getMatch(withId matchId: String) -> Match? {
        return allMatches.first { $0.id == matchId }
    }

    // MARK: - Private Methods
    private func loadEvents() {
        isLoading = true
        eventsStateSubject.send(.loading)

        // Cancel any existing subscription
        if preLiveMatchesCancellable != nil {
            preLiveMatchesCancellable?.cancel()
            preLiveMatchesCancellable = nil
        }

        // Convert AppliedEventsFilters to MatchesFilterOptions
        let filterOptions = appliedFilters.toMatchesFilterOptions()
        
        // Use filtered subscription instead of unfiltered
        preLiveMatchesCancellable = servicesProvider.subscribeToFilteredLiveMatches(filters: filterOptions)
        .receive(on: DispatchQueue.main)
        .sink { completion in
            print("InPlayEventsViewModel: subscribeToFilteredLiveMatches completion: \(completion)")
        } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
            guard let self = self else { return }
            
            switch subscribableContent {
            case .connected(let subscription):
                print("InPlayEventsViewModel: 🟢 Connected to live matches subscription - ID: \(subscription.id), Sport: \(self.sport.name)")
                break

            case .contentUpdate(let content):
                print("InPlayEventsViewModel: 📡 Received content update with \(content.count) event groups for sport: \(self.sport.name)")
                let matches = ServiceProviderModelMapper.matches(fromEventsGroups: content)
                let mainMarkets = ServiceProviderModelMapper.mainMarkets(fromEventsGroups: content)
                      
                self.processMatches(matches, mainMarkets: mainMarkets)

            case .disconnected:
                print("InPlayEventsViewModel: 🔴 Disconnected from live matches subscription for sport: \(self.sport.name)")
                break
            }
        }
    }

    private func processMatches(_ matches: [Match], mainMarkets: [MainMarket]? = nil) {
        print("[InPlayEventsViewModel] processMatches called with \(matches.count) matches")
        isLoading = false
        isLoadingMore = false  // Reset pagination state
        allMatches = matches
        self.mainMarkets = mainMarkets
        eventsStateSubject.send(LoadableContent.loaded(matches))

        // Update market group selector with new matches and main markets
        marketGroupSelectorViewModel.updateWithMatches(matches, mainMarkets: mainMarkets)

        if marketGroupCardsViewModels.count == 0 {
            print("Empty marketGroupCardsViewModels")
        }
        
        // Update all existing market group ViewModels with new matches and pagination state
        for (_, viewModel) in marketGroupCardsViewModels {
            viewModel.updateMatches(matches)
            viewModel.hasMoreEvents = self.hasMoreEvents  // Propagate pagination state
            viewModel.isLoadingMore = self.isLoadingMore  // Propagate loading state
        }

    }

    private func updateMarketGroupViewModels(marketGroups: [MarketGroupTabItemData]) {
        // Create ViewModels for new market groups
        for marketGroup in marketGroups {
            if marketGroupCardsViewModels[marketGroup.id] == nil {
                print("[InPlayEventsViewModel] Creating new MarketGroupCardsViewModel for market type: \(marketGroup.id)")
                let marketGroupCardsViewModel = MarketGroupCardsViewModel(marketTypeId: marketGroup.id)

                // Update with current matches
                marketGroupCardsViewModel.updateMatches(allMatches)

                marketGroupCardsViewModels[marketGroup.id] = marketGroupCardsViewModel
                print("[InPlayEventsViewModel] Created and initialized MarketGroupCardsViewModel for market type: \(marketGroup.id)")
            } else {
                print("[InPlayEventsViewModel] MarketGroupCardsViewModel already exists for market type: \(marketGroup.id)")
            }
        }

        // Remove ViewModels for market groups that no longer exist
        let currentMarketGroupIds = Set(marketGroups.map { $0.id })
        let viewModelsToRemove = marketGroupCardsViewModels.keys.filter { !currentMarketGroupIds.contains($0) }
        for idToRemove in viewModelsToRemove {
            marketGroupCardsViewModels.removeValue(forKey: idToRemove)
            print("[InPlayEventsViewModel] Removed MarketGroupCardsViewModel for market type: \(idToRemove)")
        }
        self.marketGroups = marketGroups
    }
}
