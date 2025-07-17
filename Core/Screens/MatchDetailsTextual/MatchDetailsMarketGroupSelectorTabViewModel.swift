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
    
    // MARK: - Dependencies
    private let match: Match
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
        let currentData = tabDataSubject.value
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
            print("✅ Connected to market groups: \(subscription.id)")
            
        case .contentUpdate(let serviceProviderMarketGroups):
            // Convert ServicesProvider.MarketGroup to App.MarketGroup using ServiceProviderModelMapper
            let appMarketGroups = ServiceProviderModelMapper.marketGroups(fromServiceProviderMarketGroups: serviceProviderMarketGroups)
            handleMarketGroupsResponse(appMarketGroups)
            
        case .disconnected:
            print("❌ Disconnected from market groups")
            // Could show error state or fallback to default groups
            createFallbackMarketGroups()
        }
    }
    
    private func handleMarketGroupsResponse(_ marketGroups: [MarketGroup]) {
        // Convert MarketGroup domain models to MarketGroupTabItemData UI models
        let tabItems = marketGroups.map { marketGroup -> MarketGroupTabItemData in
            MarketGroupTabItemData(
                id: marketGroup.id,
                title: marketGroup.translatedName ?? marketGroup.type,
                visualState: .idle
            )
        }
        
        updateMarketGroups(tabItems)
        
        // Auto-select the default market group or first available
        if let defaultGroup = marketGroups.first(where: { $0.isDefault ?? false }) {
            selectMarketGroup(id: defaultGroup.id)
        } else {
            selectFirstAvailableMarketGroup()
        }
    }
    
    private func createFallbackMarketGroups() {
        // Create simple "All Markets" group as fallback
        let allMarketsGroup = MarketGroupTabItemData(
            id: "all_markets",
            title: "All Markets",
            visualState: .idle
        )
        
        updateMarketGroups([allMarketsGroup])
        selectMarketGroup(id: "all_markets")
    }
}
