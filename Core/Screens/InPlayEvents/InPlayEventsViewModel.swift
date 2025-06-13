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
    let marketGroupSelectorViewModel: NextUpEventsMarketGroupSelectorViewModel
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

    init(sportType: SportType = SportType.defaultFootball) {
        self.sportType = sportType
        self.quickLinksTabBarViewModel = MockQuickLinksTabBarViewModel.gamingMockViewModel
        self.marketGroupSelectorViewModel = NextUpEventsMarketGroupSelectorViewModel()

        setupBindings()
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
        isLoading = true
        eventsStateSubject.send(.loading)

        preLiveMatchesCancellable?.cancel()

        preLiveMatchesCancellable = Env.servicesProvider.subscribeLiveMatches(forSportType: sportType)
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
}
