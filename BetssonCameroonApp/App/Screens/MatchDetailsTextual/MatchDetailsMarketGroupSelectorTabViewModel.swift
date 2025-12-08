//
//  MatchDetailsMarketGroupSelectorTabViewModel.swift
//  Core
//
//  Created on 2025-07-17.
//

import UIKit
import Combine
import GomaUI
import ServicesProvider

/// Production MarketGroupSelectorTabViewModel that fetches real market groups
/// from ServicesProvider.Client for match details screens
class MatchDetailsMarketGroupSelectorTabViewModel: MarketGroupSelectorTabViewModelProtocol {
    
    // MARK: - Private Properties
    private let tabDataSubject: CurrentValueSubject<MarketGroupSelectorTabData, Never>
    private let selectionEventSubject = PassthroughSubject<MarketGroupSelectionEvent, Never>()
    private var cancellables = Set<AnyCancellable>()

    // Debug counters for tracking WebSocket updates
    private var marketGroupsUpdateCounter = 0
    private var webSocketUpdateCounter = 0
    
    // MARK: - Dependencies
    private let match: Match  // Immutable - this ViewModel is created for one match only
    private let servicesProvider: ServicesProvider.Client
    
    // MARK: - Initialization
    init(match: Match, servicesProvider: ServicesProvider.Client = Env.servicesProvider) {
        self.match = match
        self.servicesProvider = servicesProvider

        let initialData = MarketGroupSelectorTabData(
            id: "match_details_market_groups_\(match.id)",
            marketGroups: [],
            selectedMarketGroupId: nil
        )
        self.tabDataSubject = CurrentValueSubject(initialData)

        // NOTE: We don't call loadMarketGroups() here because the ServicesProvider's
        // matchDetailsManager might not exist yet. The parent ViewModel must call
        // startLoading() after subscribeEventDetails() has been called.
    }

    /// Starts loading market groups. Must be called after ServicesProvider's
    /// matchDetailsManager has been created (i.e., after subscribeEventDetails()).
    func startLoading() {
        loadMarketGroups()
    }
    
    // MARK: - Content Publishers
    var marketGroupsPublisher: AnyPublisher<[MarketGroupTabItemData], Never> {
        tabDataSubject
            .map(\.marketGroups)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var selectedMarketGroupIdPublisher: AnyPublisher<String?, Never> {
        tabDataSubject
            .map(\.selectedMarketGroupId)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Selection Events
    var selectionEventPublisher: AnyPublisher<MarketGroupSelectionEvent, Never> {
        selectionEventSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Current State Access
    var currentSelectedMarketGroupId: String? {
        tabDataSubject.value.selectedMarketGroupId
    }
    
    var currentMarketGroups: [MarketGroupTabItemData] {
        tabDataSubject.value.marketGroups
    }
    
    // MARK: - Actions
    func selectMarketGroup(id: String) {
        let currentData = tabDataSubject.value
        let previouslySelectedId = currentData.selectedMarketGroupId
        
        let updatedData = MarketGroupSelectorTabData(
            id: currentData.id,
            marketGroups: currentData.marketGroups,
            selectedMarketGroupId: id
        )
        
        tabDataSubject.send(updatedData)
        
        let selectionEvent = MarketGroupSelectionEvent(
            selectedId: id,
            previouslySelectedId: previouslySelectedId
        )
        selectionEventSubject.send(selectionEvent)
    }
    
    func updateMarketGroups(_ marketGroups: [MarketGroupTabItemData]) {
        marketGroupsUpdateCounter += 1
        let currentData = tabDataSubject.value
        let previousCount = currentData.marketGroups.count
        let newCount = marketGroups.count

        print("BLINK_DEBUG [MarketGroupSelectorVM] 📋 updateMarketGroups #\(marketGroupsUpdateCounter) | \(previousCount) → \(newCount) groups")

        if newCount == 0 {
            print("BLINK_DEBUG [MarketGroupSelectorVM] ⚠️  Setting EMPTY market groups!")
        }

        let updatedData = MarketGroupSelectorTabData(
            id: currentData.id,
            marketGroups: marketGroups,
            selectedMarketGroupId: currentData.selectedMarketGroupId
        )
        tabDataSubject.send(updatedData)
    }
    
    func addMarketGroup(_ marketGroup: MarketGroupTabItemData) {
        let currentData = tabDataSubject.value
        var updatedMarketGroups = currentData.marketGroups
        
        updatedMarketGroups.removeAll { $0.id == marketGroup.id }
        updatedMarketGroups.append(marketGroup)
        
        updateMarketGroups(updatedMarketGroups)
    }
    
    func removeMarketGroup(id: String) {
        let currentData = tabDataSubject.value
        let updatedMarketGroups = currentData.marketGroups.filter { $0.id != id }
        
        let updatedSelectedId = currentData.selectedMarketGroupId == id ? nil : currentData.selectedMarketGroupId
        
        let updatedData = MarketGroupSelectorTabData(
            id: currentData.id,
            marketGroups: updatedMarketGroups,
            selectedMarketGroupId: updatedSelectedId
        )
        
        tabDataSubject.send(updatedData)
    }
    
    func updateMarketGroup(_ marketGroup: MarketGroupTabItemData) {
        let currentData = tabDataSubject.value
        let updatedMarketGroups = currentData.marketGroups.map { existingGroup in
            existingGroup.id == marketGroup.id ? marketGroup : existingGroup
        }
        updateMarketGroups(updatedMarketGroups)
    }
    
    // MARK: - Convenience Methods
    func clearSelection() {
        let currentData = tabDataSubject.value
        let updatedData = MarketGroupSelectorTabData(
            id: currentData.id,
            marketGroups: currentData.marketGroups,
            selectedMarketGroupId: nil
        )
        tabDataSubject.send(updatedData)
    }
    
    func selectFirstAvailableMarketGroup() {
        if let firstGroup = currentMarketGroups.first {
            selectMarketGroup(id: firstGroup.id)
        }
    }

    // MARK: - Private Methods

    private func loadMarketGroups() {
        // Use new subscription-based approach
        servicesProvider.subscribeToMarketGroups(eventId: match.id)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("❌ Market groups subscription failed: \(error)")
                }
            } receiveValue: { [weak self] subscribableContent in
                self?.handleSubscribableMarketGroupsContent(subscribableContent)
            }
            .store(in: &cancellables)
    }
    
    private func handleSubscribableMarketGroupsContent(_ content: SubscribableContent<[ServicesProvider.MarketGroup]>) {
        switch content {
        case .connected(let subscription):
            print("BLINK_DEBUG [MarketGroupSelectorVM] ✅ WebSocket CONNECTED: \(subscription.id)")

        case .contentUpdate(let serviceProviderMarketGroups):
            webSocketUpdateCounter += 1
            print("BLINK_DEBUG [MarketGroupSelectorVM] 🌐 WebSocket Update #\(webSocketUpdateCounter) | Raw groups: \(serviceProviderMarketGroups.count)")

            // Convert ServicesProvider.MarketGroup to App.MarketGroup using ServiceProviderModelMapper
            let appMarketGroups = ServiceProviderModelMapper.marketGroups(fromServiceProviderMarketGroups: serviceProviderMarketGroups)
            print("BLINK_DEBUG [MarketGroupSelectorVM] 🔄 Mapped to \(appMarketGroups.count) app market groups")
            handleMarketGroupsResponse(appMarketGroups)

        case .disconnected:
            print("BLINK_DEBUG [MarketGroupSelectorVM] ❌ WebSocket DISCONNECTED")
            // Could show error state or fallback to default groups
            createFallbackMarketGroups()
        }
    }
    
    private func handleMarketGroupsResponse(_ marketGroups: [MarketGroup]) {
        print("BLINK_DEBUG [MarketGroupSelectorVM] 🔍 handleMarketGroupsResponse | Input: \(marketGroups.count) groups")

        // Filter out market groups that have no available markets
        let filteredMarketGroups = marketGroups.filter { marketGroup in
            hasAvailableMarkets(marketGroup: marketGroup)
        }

        print("BLINK_DEBUG [MarketGroupSelectorVM] ✂️  After filtering: \(filteredMarketGroups.count) groups (removed \(marketGroups.count - filteredMarketGroups.count))")

        // If no market groups have markets, create fallback and return early
        if filteredMarketGroups.isEmpty {
            print("BLINK_DEBUG [MarketGroupSelectorVM] ⚠️  ALL groups filtered out - creating fallback")
            createFallbackMarketGroups()
            return
        }
        
        // Convert filtered MarketGroup domain models to MarketGroupTabItemData UI models
        let tabItems = filteredMarketGroups.map { marketGroup -> MarketGroupTabItemData in
            // Calculate badge count from market group data
            let badgeCount = calculateBadgeCount(for: marketGroup)
            
            // Determine icon type based on market group properties
            let iconType = determineIconType(for: marketGroup)
            
            return MarketGroupTabItemData(
                id: marketGroup.groupKey ?? marketGroup.type,
                title: marketGroup.translatedName ?? marketGroup.type,
                visualState: .idle,
                suffixIconTypeName: iconType,
                badgeCount: badgeCount
            )
        }
        
        updateMarketGroups(tabItems)
        
        // Auto-select the default market group or first available from filtered groups
        if let defaultGroup = filteredMarketGroups.first(where: { $0.isDefault ?? false }) {
            selectMarketGroup(id: defaultGroup.groupKey ?? defaultGroup.type)
        } else {
            selectFirstAvailableMarketGroup()
        }
    }
    
    private func createFallbackMarketGroups() {
        // Create simple "All Markets" group as fallback when no market groups have markets
        let allMarketsGroup = MarketGroupTabItemData(
            id: "all_markets_fallback",
            title: "All Markets",
            visualState: .idle,
            suffixIconTypeName: nil,
            badgeCount: nil // No badge for fallback group since it represents empty state
        )
        
        updateMarketGroups([allMarketsGroup])
        selectMarketGroup(id: "all_markets_fallback")
    }
    
    // MARK: - Market Group Filtering and Badge Count Calculation
    
    /// Checks if a market group has any available markets
    /// - Parameter marketGroup: The MarketGroup to check
    /// - Returns: True if the market group has markets, false if empty
    private func hasAvailableMarkets(marketGroup: MarketGroup) -> Bool {
        // Primary: Use numberOfMarkets if available (most reliable)
        if let numberOfMarkets = marketGroup.numberOfMarkets {
            return numberOfMarkets > 0
        }
        
        // Fallback: Use actual markets array count if available
        if let markets = marketGroup.markets {
            return !markets.isEmpty
        }
        
        // If no market count data is available, assume it might have markets
        // This prevents filtering out potentially valid market groups
        return true
    }
    
    /// Calculates the badge count for a market group based on available market data
    /// - Parameter marketGroup: The ServicesProvider MarketGroup to calculate count for
    /// - Returns: The number of markets in the group, or nil if no count is available
    private func calculateBadgeCount(for marketGroup: MarketGroup) -> Int? {
        // Primary: Use numberOfMarkets if available (most reliable)
        if let numberOfMarkets = marketGroup.numberOfMarkets, numberOfMarkets > 0 {
            return numberOfMarkets
        }
        
        // Fallback: Use actual markets array count if available
        if let markets = marketGroup.markets, !markets.isEmpty {
            return markets.count
        }
        
        // No badge if no market count data is available
        return nil
    }
    
    /// Determines the appropriate icon type for a market group based on its properties
    /// - Parameter marketGroup: The ServicesProvider MarketGroup to determine icon for
    /// - Returns: The icon type string that AppMarketGroupTabImageResolver can resolve
    private func determineIconType(for marketGroup: MarketGroup) -> String? {
        // Priority 1: BetBuilder markets get bet_builder_info icon
        if marketGroup.isBetBuilder == true {
            return "betbuilder"
        }
        
        // Priority 2: Fast markets get most_popular_info icon
        if marketGroup.isFast == true {
            return "fast"
        }
        
        // No specific icon for other market groups
        return nil
    }
}
