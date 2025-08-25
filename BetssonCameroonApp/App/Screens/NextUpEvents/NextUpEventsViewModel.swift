//
//  NextUpEventsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/06/2025.
//

import UIKit
import GomaUI
import Combine
import ServicesProvider

// MARK: - NextUpEventsViewModel
class NextUpEventsViewModel {

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
    let quickLinksTabBarViewModel: QuickLinksTabBarViewModelProtocol
    let pillSelectorBarViewModel: PillSelectorBarViewModel
    let marketGroupSelectorViewModel: MarketGroupSelectorTabViewModel
    var generalFiltersBarViewModel: GeneralFilterBarViewModelProtocol

    // MARK: - Navigation Closures (MVVM-C Pattern)
    // ViewModels signal navigation intent through closures - Coordinators handle actual navigation
    var onMatchSelected: ((Match) -> Void) = { match in
        print("Empty clojure")
    }
    var onSportsSelectionRequested: (() -> Void)  = {
        print("Empty clojure")
    }
    var onFiltersRequested: (() -> Void) = {
        print("Empty clojure")
    }

    // MARK: - Private Properties
    var sport: Sport
    private let servicesProvider: ServicesProvider.Client
    private var eventsStateSubject = CurrentValueSubject<LoadableContent<[Match]>, Never>.init(.loading)
    private var cancellables: Set<AnyCancellable> = []
    private var preLiveMatchesCancellable: AnyCancellable?

    // Store market group ViewModels
    private var marketGroupCardsViewModels: [String: MarketGroupCardsViewModel] = [:]

    // MARK: - Public Properties
    var eventsState: AnyPublisher<LoadableContent<[Match]>, Never> {
        return self.eventsStateSubject.eraseToAnyPublisher()
    }
    
    var filterOptionItems: CurrentValueSubject<[FilterOptionItem], Never> = .init([])
    var appliedFilters: AppliedEventsFilters

    init(sport: Sport, servicesProvider: ServicesProvider.Client, appliedFilters: AppliedEventsFilters = AppliedEventsFilters.defaultFilters) {
        self.sport = sport
        self.servicesProvider = servicesProvider
        self.appliedFilters = appliedFilters
        
        self.quickLinksTabBarViewModel = MockQuickLinksTabBarViewModel.gamingMockViewModel
        self.pillSelectorBarViewModel = PillSelectorBarViewModel()
        self.marketGroupSelectorViewModel = MarketGroupSelectorTabViewModel()
                
        let mainFilter = MainFilterItem(type: .mainFilter, title: "Filter", icon: "filter_icon", actionIcon: "right_arrow_icon")

        self.generalFiltersBarViewModel = MockGeneralFilterBarViewModel(items: [], mainFilterItem: mainFilter)
        
        setupBindings()
        setupFilters()
    }
    
    func updateSportType(_ sport: Sport) {
        print("[NextUpEventsViewModel] 📡 Updating sport type to \(sport.name)")
        
        // Update internal sport
        self.sport = sport
        
        // Also update the sport in filters
        appliedFilters.sportId = sport.id
        
        // Update UI
        pillSelectorBarViewModel.updateCurrentSport(sport)
        
        // Update filters
        let sportFilterOption = FilterOptionItem(type: .sport, title: sport.name, icon: "sport_type_icon_\(sport.id)")
        generalFiltersBarViewModel.updateFilterOptionItems(filterOptionItems: [sportFilterOption])
        
        // Reload events for new sport
        reloadEvents(forced: true)
    }
    
    func updateFilters(_ filters: AppliedEventsFilters) {
        // Check if filters actually changed
        guard appliedFilters != filters else {
            print("[NextUpEventsViewModel] 🎛️ Filters unchanged, skipping update")
            return
        }
        
        print("[NextUpEventsViewModel] 🎛️ Updating filters: \(filters)")
        self.appliedFilters = filters
        
        // Update sport if it changed
        if let newSport = Env.sportsStore.getActiveSports().first(where: { $0.id == filters.sportId }) {
            self.sport = newSport
            pillSelectorBarViewModel.updateCurrentSport(newSport)
        }
        
        // Update filter bar UI
        setupFilters()  // Use existing method to update filter bar
        
        // Reload events with new filters
        reloadEvents(forced: true)
    }

    // MARK: - Setup
    private func setupBindings() {
        // Listen to market group selection changes from selector ViewModel
        marketGroupSelectorViewModel.selectionEventPublisher
            .sink { [weak self] selectionEvent in
                self?.selectedMarketGroupId = selectionEvent.selectedId
            }
            .store(in: &cancellables)

        // Listen to market groups updates from selector ViewModel
        marketGroupSelectorViewModel.marketGroupsPublisher
            .sink { [weak self] marketGroups in
                self?.updateMarketGroupViewModels(marketGroups: marketGroups)
            }
            .store(in: &cancellables)
        
        // Filters are now managed statefully by parent coordinator
        // No reactive binding to global filter state needed
    }

    private func setupFilters() {
        
        let sportFilterOption = self.getSportOption(for: appliedFilters.sportId)
        
        // TODO: Add back sort and league options if needed
        // let sortOption = self.getSortOption(for: appliedFilters.sortTypeId)
        // let leagueOption = self.getLeagueOption(for: appliedFilters.leagueId)
                
        self.generalFiltersBarViewModel.updateFilterOptionItems(filterOptionItems: [sportFilterOption])

    }
    // MARK: - Public Methods
    func reloadEvents(forced: Bool = false) {
        self.loadEvents()
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

        preLiveMatchesCancellable?.cancel()

        // Convert AppliedEventsFilters to MatchesFilterOptions
        let filterOptions = appliedFilters.toMatchesFilterOptions()
        
        // Use filtered subscription instead of unfiltered
        preLiveMatchesCancellable = servicesProvider.subscribeToFilteredPreLiveMatches(filters: filterOptions)
        .receive(on: DispatchQueue.main)
        .sink { completion in
            print("subscribeToFilteredPreLiveMatches \(completion)")
        } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
            switch subscribableContent {
            case .connected(let subscription):
                print("[NextUpEventsViewModel] 🟢 Connected to pre-live matches subscription \(subscription.id)")

            case .contentUpdate(let content):
                let matches = ServiceProviderModelMapper.matches(fromEventsGroups: content)
                let mainMarkets = ServiceProviderModelMapper.mainMarkets(fromEventsGroups: content)
                
                print("[NextUpEventsViewModel] 📡 received pre-live groups \(content.count) mapped to matches \(matches.count)")
                if let mainMarkets = mainMarkets {
                    print("[NextUpEventsViewModel] received \(mainMarkets.count) main markets")
                }
                      
                self?.processMatches(matches, mainMarkets: mainMarkets)

            case .disconnected:
                print("[NextUpEventsViewModel] 🔴 Disconnected from pre-live matches subscription")
            }
        }
    }

    private func processMatches(_ matches: [Match], mainMarkets: [MainMarket]? = nil) {
        print("[NextUpEventsViewModel] processMatches called with \(matches.count) matches")
        isLoading = false
        allMatches = matches
        self.mainMarkets = mainMarkets
        eventsStateSubject.send(LoadableContent.loaded(matches))

        // Update market group selector with new matches and main markets
        marketGroupSelectorViewModel.updateWithMatches(matches, mainMarkets: mainMarkets)

        // Update all existing market group ViewModels with new matches
        for (marketTypeName, viewModel) in marketGroupCardsViewModels {
            print("Updating matches for \(marketTypeName)")
            viewModel.updateMatches(matches)
        }

    }

    private func updateMarketGroupViewModels(marketGroups: [MarketGroupTabItemData]) {

        // Create ViewModels for new market groups
        for marketGroup in marketGroups {
            if marketGroupCardsViewModels[marketGroup.id] == nil {
                print("[NextUpEventsViewModel] Creating new MarketGroupCardsViewModel for market type: \(marketGroup.id)")
                let marketGroupCardsViewModel = MarketGroupCardsViewModel(marketTypeId: marketGroup.id)

                // Update with current matches
                marketGroupCardsViewModel.updateMatches(allMatches)

                marketGroupCardsViewModels[marketGroup.id] = marketGroupCardsViewModel
                print("[NextUpEventsViewModel] Created and initialized MarketGroupCardsViewModel for market type: \(marketGroup.id)")
            } else {
                print("[NextUpEventsViewModel] MarketGroupCardsViewModel already exists for market type: \(marketGroup.id)")
            }
        }

        // Remove ViewModels for market groups that no longer exist
        let currentMarketGroupIds = Set(marketGroups.map { $0.id })
        let viewModelsToRemove = marketGroupCardsViewModels.keys.filter { !currentMarketGroupIds.contains($0) }
        for idToRemove in viewModelsToRemove {
            marketGroupCardsViewModels.removeValue(forKey: idToRemove)
            print("[NextUpEventsViewModel] Removed MarketGroupCardsViewModel for market type: \(idToRemove)")
        }

        self.marketGroups = marketGroups
        
    }
    
    // Filters functions
    func buildFilterOptions(from selection: AppliedEventsFilters) -> [FilterOptionItem] {
        var options: [FilterOptionItem] = []
        
        let sportOption = getSportOption(for: selection.sportId)
        
        let sortOption = getSortOption(for: selection.sortType.rawValue)
        
        let leagueOption = getLeagueOption(for: selection.leagueId)
        
        options.append(sportOption)
        options.append(sortOption)
        options.append(leagueOption)

        return options
    }
    
    // MARK: - Helper Methods for Filter Data
    private func getSportOption(for sportId: String) -> FilterOptionItem {
        let currentSport = Env.sportsStore.getActiveSports().first(where: {
            $0.id == sportId
        })
        let filterOptionItem = FilterOptionItem(type: .sport, title: "\(currentSport?.name ?? "")", icon: "sport_type_icon_\(currentSport?.id ?? "")")
        return filterOptionItem
    }
    
    private func getSortOption(for sortId: String) -> FilterOptionItem {
        // Replicate the same data structure from createSortFilterViewModel
        let sortOptions = [
            SortOption(id: "1", icon: "popular_icon", title: "Popular", count: 25),
            SortOption(id: "2", icon: "timelapse_icon", title: "Upcoming", count: 15),
            SortOption(id: "3", icon: "favourites_icon", title: "Favourites", count: 0)
        ]
        let currentSortOption = sortOptions.first { $0.id == sortId }
        return FilterOptionItem(type: .sortBy, title: "\(currentSortOption?.title ?? "")", icon: "\(currentSortOption?.icon ?? "")")
    }

    private func getLeagueOption(for leagueId: String) -> FilterOptionItem {
        let allLeaguesOption = SortOption(id: "0", icon: "league_icon", title: "All Popular Leagues", count: 0)
        // TODO: Competition data should be provided through parameters or RPC calls
        // For now, use default "All Popular Leagues" title
        let title = leagueId == "all" || leagueId == "0" ? allLeaguesOption.title : "League \(leagueId)"
        return FilterOptionItem(type: .league, title: title, icon: "league_icon")
    }
}
