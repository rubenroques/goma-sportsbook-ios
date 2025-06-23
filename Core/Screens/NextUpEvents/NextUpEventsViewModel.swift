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
class NextUpEventsViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var allMatches: [Match] = []
    @Published var marketGroups: [MarketGroupTabItemData] = []
    @Published var selectedMarketGroupId: String?
    @Published var isLoading: Bool = false

    // MARK: - Child ViewModels
    let quickLinksTabBarViewModel: QuickLinksTabBarViewModelProtocol
    let marketGroupSelectorViewModel: NextUpEventsMarketGroupSelectorViewModel
    var generalFiltersBarViewModel: GeneralFilterBarViewModelProtocol
    private let scrollPositionCoordinator = ScrollPositionCoordinator()

    // MARK: - Private Properties
    var sportType: SportType
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

    init(sportType: SportType = SportType.defaultFootball) {
        self.sportType = sportType
        self.quickLinksTabBarViewModel = MockQuickLinksTabBarViewModel.gamingMockViewModel
        self.marketGroupSelectorViewModel = NextUpEventsMarketGroupSelectorViewModel()
                
        let mainFilter = MainFilterItem(type: .mainFilter, title: "Filter", icon: "filter_icon", actionIcon: "right_arrow_icon")

        self.generalFiltersBarViewModel = MockGeneralFilterBarViewModel(items: [], mainFilterItem: mainFilter)
        setupBindings()
        setupFilters()
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
        
        Env.filterStorage.$currentFilterSelection
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] currentFilterSelection in
                
                if let selectedFilterOptions = self?.buildFilterOptions(from: currentFilterSelection) {
                    
                    self?.filterOptionItems.send(selectedFilterOptions)
                }
                
            })
            .store(in: &cancellables)
    }

    private func setupFilters() {
        
        let sportFilterOption = self.getSportOption(for: Env.filterStorage.currentFilterSelection.sportId)
        
        let sortOption = self.getSortOption(for: Env.filterStorage.currentFilterSelection.sortTypeId)
        
        let leagueOption = self.getLeagueOption(for: Env.filterStorage.currentFilterSelection.leagueId)
                
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

    // MARK: - Private Methods
    private func loadEvents() {
        isLoading = true
        eventsStateSubject.send(.loading)

        preLiveMatchesCancellable?.cancel()

        preLiveMatchesCancellable = Env.servicesProvider.subscribePreLiveMatches(
            forSportType: sportType,
            sortType: EventListSort.popular)
        .receive(on: DispatchQueue.main)
        .sink { completion in
            print("subscribePreLiveMatches \(completion)")
        } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
            switch subscribableContent {
            case .connected(let subscription):
                print("Connected to pre-live matches subscription \(subscription.id)")
                break

            case .contentUpdate(let content):
                let matches = ServiceProviderModelMapper.matches(fromEventsGroups: content)
                self?.processMatches(matches)

            case .disconnected:
                print("Disconnected from pre-live matches subscription")
                break
            }
        }
    }

    private func processMatches(_ matches: [Match]) {
        print("[NextUpEvents] processMatches called with \(matches.count) matches")
        isLoading = false
        allMatches = matches
        eventsStateSubject.send(LoadableContent.loaded(matches))

        // Update market group selector with new matches
        marketGroupSelectorViewModel.updateWithMatches(matches)

        // Update all existing market group ViewModels with new matches
        for (marketType, viewModel) in marketGroupCardsViewModels {
            viewModel.updateMatches(matches)
        }

    }

    private func updateMarketGroupViewModels(marketGroups: [MarketGroupTabItemData]) {

        // Create ViewModels for new market groups
        for marketGroup in marketGroups {
            if marketGroupCardsViewModels[marketGroup.id] == nil {
                print("[NextUpEvents] Creating new MarketGroupCardsViewModel for market type: \(marketGroup.id)")
                let marketGroupCardsViewModel = MarketGroupCardsViewModel(
                    marketTypeId: marketGroup.id,
                    scrollPositionCoordinator: scrollPositionCoordinator
                )

                // Update with current matches
                marketGroupCardsViewModel.updateMatches(allMatches)

                marketGroupCardsViewModels[marketGroup.id] = marketGroupCardsViewModel
                print("[NextUpEvents] Created and initialized MarketGroupCardsViewModel for market type: \(marketGroup.id)")
            } else {
                print("[NextUpEvents] MarketGroupCardsViewModel already exists for market type: \(marketGroup.id)")
            }
        }

        // Remove ViewModels for market groups that no longer exist
        let currentMarketGroupIds = Set(marketGroups.map { $0.id })
        let viewModelsToRemove = marketGroupCardsViewModels.keys.filter { !currentMarketGroupIds.contains($0) }
        for idToRemove in viewModelsToRemove {
            marketGroupCardsViewModels.removeValue(forKey: idToRemove)
            print("[NextUpEvents] Removed MarketGroupCardsViewModel for market type: \(idToRemove)")
        }

        self.marketGroups = marketGroups
        
    }
    
    // Filters functions
    func buildFilterOptions(from selection: GeneralFilterSelection) -> [FilterOptionItem] {
        var options: [FilterOptionItem] = []
        
        let sportOption = getSportOption(for: selection.sportId)
        
        let sortOption = getSortOption(for: selection.sortTypeId)
        
        let leagueOption = getLeagueOption(for: selection.leagueId)
        
        options.append(sportOption)
        options.append(sortOption)
        options.append(leagueOption)

        return options
    }
    
    // MARK: - Helper Methods for Filter Data
    private func getSportOption(for sportId: String) -> FilterOptionItem {
//        let sportOptions = [
//            (id: "1", title: "Football", icon: "sport_type_icon_1"),
//            (id: "2", title: "Basketball", icon: "sport_type_icon_8"),
//            (id: "3", title: "Tennis", icon: "sport_type_icon_3"),
//            (id: "4", title: "Cricket", icon: "sport_type_icon_9")
//        ]
        
        let currentSport = Env.sportsStore.getActiveSports().first(where: {
            $0.id == sportId
        })
        
        let filterOptionItem = FilterOptionItem(type: .sport, title: "\(currentSport?.name ?? "")", icon: "sport_type_icon_\(currentSport?.id ?? "")")
        
        return filterOptionItem
        
//        return sportOptions.first { $0.id == sportId }.map { (title: $0.title, icon: $0.icon) }
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
        var allLeaguesOption = SortOption(id: "0", icon: "league_icon", title: "All Popular Leagues", count: 0)
        
        let currentCompetition = Env.filterStorage.currentCompetitions.first(where: {
            $0.id == leagueId
        })
        
        return FilterOptionItem(type: .league, title: "\(currentCompetition?.name ?? allLeaguesOption.title)", icon: "league_icon")
    }
}
