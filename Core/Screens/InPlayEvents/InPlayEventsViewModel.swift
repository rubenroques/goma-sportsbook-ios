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

// MARK: - InPlayEventsViewModel
class InPlayEventsViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var allMatches: [Match] = []
    @Published var marketGroups: [MarketGroupTabItemData] = []
    @Published var selectedMarketGroupId: String?
    @Published var isLoading: Bool = false

    // MARK: - Child ViewModels
    let quickLinksTabBarViewModel: QuickLinksTabBarViewModelProtocol
    let pillSelectorBarViewModel: PillSelectorBarViewModel
    let marketGroupSelectorViewModel: MarketGroupSelectorTabViewModel

    // MARK: - Private Properties
    var sport: Sport
    private var eventsStateSubject = CurrentValueSubject<LoadableContent<[Match]>, Never>.init(.loading)
    private var cancellables: Set<AnyCancellable> = []
    private var preLiveMatchesCancellable: AnyCancellable?

    // Store market group ViewModels
    private var marketGroupCardsViewModels: [String: MarketGroupCardsViewModel] = [:]

    // MARK: - Public Properties
    var eventsState: AnyPublisher<LoadableContent<[Match]>, Never> {
        return self.eventsStateSubject.eraseToAnyPublisher()
    }

    init(sport: Sport? = nil) {
        self.sport = sport ?? Env.sportsStore.football
        self.quickLinksTabBarViewModel = MockQuickLinksTabBarViewModel.gamingMockViewModel
        self.pillSelectorBarViewModel = PillSelectorBarViewModel()
        self.marketGroupSelectorViewModel = MarketGroupSelectorTabViewModel()

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
        
        // Update internal sport
        self.sport = sport
        
        // Update UI
        pillSelectorBarViewModel.updateCurrentSport(sport)
        
        // Update market group selector to clear its state
        marketGroupSelectorViewModel.updateWithMatches([])
        
        // Reload events for new sport
        print("🔄 InPlayEventsViewModel: Starting reload for new sport: \(sport.name)")
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
        print("📡 InPlayEventsViewModel: loadEvents() called for sport: \(sport.name)")
        isLoading = true
        eventsStateSubject.send(.loading)

        // Cancel any existing subscription
        if preLiveMatchesCancellable != nil {
            print("🛑 InPlayEventsViewModel: Cancelling existing subscription")
            preLiveMatchesCancellable?.cancel()
            preLiveMatchesCancellable = nil
        }

        let sportType = ServiceProviderModelMapper.serviceProviderSportType(fromSport: sport)
        print("🔌 InPlayEventsViewModel: Creating new subscription for sport type: \(sportType)")
        
        preLiveMatchesCancellable = Env.servicesProvider.subscribeLiveMatches(forSportType: sportType)
        .receive(on: DispatchQueue.main)
        .sink { completion in
            print("📡 InPlayEventsViewModel: subscribePreLiveMatches completion: \(completion)")
        } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
            guard let self = self else { return }
            
            switch subscribableContent {
            case .connected(let subscription):
                print("✅ InPlayEventsViewModel: Connected to live matches subscription - ID: \(subscription.id), Sport: \(self.sport.name)")
                break

            case .contentUpdate(let content):
                print("📦 InPlayEventsViewModel: Received content update with \(content.count) event groups for sport: \(self.sport.name)")
                let matches = ServiceProviderModelMapper.matches(fromEventsGroups: content)
                print("   - Mapped to \(matches.count) matches")
                self.processMatches(matches)

            case .disconnected:
                print("🔌 InPlayEventsViewModel: Disconnected from live matches subscription for sport: \(self.sport.name)")
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
                let marketGroupCardsViewModel = MarketGroupCardsViewModel(marketTypeId: marketGroup.id)

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
}
