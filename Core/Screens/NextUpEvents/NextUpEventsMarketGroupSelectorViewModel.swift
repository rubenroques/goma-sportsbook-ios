import UIKit
import Combine
import GomaUI

class NextUpEventsMarketGroupSelectorViewModel: MarketGroupSelectorTabViewModelProtocol {
    
    // MARK: - Private Properties
    private let tabDataSubject: CurrentValueSubject<MarketGroupSelectorTabData, Never>
    private let selectionEventSubject = PassthroughSubject<MarketGroupSelectionEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        let initialData = MarketGroupSelectorTabData(
            id: "next_up_events_market_groups",
            marketGroups: [],
            selectedMarketGroupId: nil,
            visualState: .idle
        )
        self.tabDataSubject = CurrentValueSubject(initialData)
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
    
    // MARK: - Visual State Publishers
    var visualStatePublisher: AnyPublisher<MarketGroupSelectorTabVisualState, Never> {
        tabDataSubject
            .map(\.visualState)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var currentVisualState: MarketGroupSelectorTabVisualState {
        tabDataSubject.value.visualState
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
        
        // Verify the market group exists and is not disabled
        guard let targetGroup = currentData.marketGroups.first(where: { $0.id == id }),
              targetGroup.visualState != .disabled else {
            return
        }
        
        let previouslySelectedId = currentData.selectedMarketGroupId
        
        // Update market groups with new selection states
        let updatedMarketGroups = currentData.marketGroups.map { marketGroup in
            MarketGroupTabItemData(
                id: marketGroup.id,
                title: marketGroup.title,
                visualState: marketGroup.id == id ? .selected : (marketGroup.visualState == .disabled ? .disabled : .idle)
            )
        }
        
        let updatedData = MarketGroupSelectorTabData(
            id: currentData.id,
            marketGroups: updatedMarketGroups,
            selectedMarketGroupId: id,
            visualState: currentData.visualState
        )
        
        tabDataSubject.send(updatedData)
        
        // Send selection event
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
            selectedMarketGroupId: currentData.selectedMarketGroupId,
            visualState: marketGroups.isEmpty ? .empty : currentData.visualState
        )
        tabDataSubject.send(updatedData)
    }
    
    func setVisualState(_ state: MarketGroupSelectorTabVisualState) {
        let currentData = tabDataSubject.value
        let updatedData = MarketGroupSelectorTabData(
            id: currentData.id,
            marketGroups: currentData.marketGroups,
            selectedMarketGroupId: currentData.selectedMarketGroupId,
            visualState: state
        )
        tabDataSubject.send(updatedData)
    }
    
    func addMarketGroup(_ marketGroup: MarketGroupTabItemData) {
        let currentData = tabDataSubject.value
        var updatedMarketGroups = currentData.marketGroups
        
        // Remove existing market group with same ID if it exists
        updatedMarketGroups.removeAll { $0.id == marketGroup.id }
        updatedMarketGroups.append(marketGroup)
        
        updateMarketGroups(updatedMarketGroups)
    }
    
    func removeMarketGroup(id: String) {
        let currentData = tabDataSubject.value
        let updatedMarketGroups = currentData.marketGroups.filter { $0.id != id }
        
        // Clear selection if the removed market group was selected
        let updatedSelectedId = currentData.selectedMarketGroupId == id ? nil : currentData.selectedMarketGroupId
        
        let updatedData = MarketGroupSelectorTabData(
            id: currentData.id,
            marketGroups: updatedMarketGroups,
            selectedMarketGroupId: updatedSelectedId,
            visualState: updatedMarketGroups.isEmpty ? .empty : currentData.visualState
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
        let updatedMarketGroups = currentData.marketGroups.map { marketGroup in
            MarketGroupTabItemData(
                id: marketGroup.id,
                title: marketGroup.title,
                visualState: marketGroup.visualState == .disabled ? .disabled : .idle
            )
        }
        
        let updatedData = MarketGroupSelectorTabData(
            id: currentData.id,
            marketGroups: updatedMarketGroups,
            selectedMarketGroupId: nil,
            visualState: currentData.visualState
        )
        
        tabDataSubject.send(updatedData)
    }
    
    func selectFirstAvailableMarketGroup() {
        let availableGroup = currentMarketGroups.first { $0.visualState != .disabled }
        if let firstGroup = availableGroup {
            selectMarketGroup(id: firstGroup.id)
        }
    }
    
    func setEnabled(_ enabled: Bool) {
        setVisualState(enabled ? .idle : .disabled)
    }
    
    func setLoading(_ loading: Bool) {
        setVisualState(loading ? .loading : .idle)
    }
    
    // MARK: - Match Processing Methods
    func updateWithMatches(_ matches: [Match]) {
        let marketGroupTabs = extractMarketTypeTabs(from: matches)
        updateMarketGroups(marketGroupTabs)
        
        // Auto-select first tab if none is selected
        if currentSelectedMarketGroupId == nil, let firstTab = marketGroupTabs.first {
            selectMarketGroup(id: firstTab.id)
        }
    }
    
    private func extractMarketTypeTabs(from matches: [Match]) -> [MarketGroupTabItemData] {
        // Get all unique marketTypeIds that actually exist in the matches
        let marketTypeGroups = Dictionary(grouping: matches.flatMap { $0.markets }) { market in
            market.marketTypeId ?? "unknown"
        }
        
        return marketTypeGroups.compactMap { marketTypeId, markets in
            // Skip unknown market types
            guard marketTypeId != "unknown" else { return nil }
            
            return MarketGroupTabItemData(
                id: marketTypeId,
                title: markets.first?.marketTypeName ?? marketTypeId, // Use actual market name
                visualState: .idle
            )
        }.sorted { $0.title < $1.title } // Sort alphabetically
    }
} 
