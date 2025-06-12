import Combine
import UIKit

public class MockMarketGroupSelectorTabViewModel: MarketGroupSelectorTabViewModelProtocol {
    
    // MARK: - Private Properties
    private let tabDataSubject: CurrentValueSubject<MarketGroupSelectorTabData, Never>
    private let selectionEventSubject = PassthroughSubject<MarketGroupSelectionEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init(tabData: MarketGroupSelectorTabData) {
        self.tabDataSubject = CurrentValueSubject(tabData)
    }
    
    // MARK: - Content Publishers
    public var marketGroupsPublisher: AnyPublisher<[MarketGroupTabItemData], Never> {
        tabDataSubject
            .map(\.marketGroups)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public var selectedMarketGroupIdPublisher: AnyPublisher<String?, Never> {
        tabDataSubject
            .map(\.selectedMarketGroupId)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Visual State Publishers
    public var visualStatePublisher: AnyPublisher<MarketGroupSelectorTabVisualState, Never> {
        tabDataSubject
            .map(\.visualState)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public var currentVisualState: MarketGroupSelectorTabVisualState {
        tabDataSubject.value.visualState
    }
    
    // MARK: - Selection Events
    public var selectionEventPublisher: AnyPublisher<MarketGroupSelectionEvent, Never> {
        selectionEventSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Current State Access
    public var currentSelectedMarketGroupId: String? {
        tabDataSubject.value.selectedMarketGroupId
    }
    
    public var currentMarketGroups: [MarketGroupTabItemData] {
        tabDataSubject.value.marketGroups
    }
    
    // MARK: - Actions
    public func selectMarketGroup(id: String) {
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
    
    public func updateMarketGroups(_ marketGroups: [MarketGroupTabItemData]) {
        let currentData = tabDataSubject.value
        let updatedData = MarketGroupSelectorTabData(
            id: currentData.id,
            marketGroups: marketGroups,
            selectedMarketGroupId: currentData.selectedMarketGroupId,
            visualState: marketGroups.isEmpty ? .empty : currentData.visualState
        )
        tabDataSubject.send(updatedData)
    }
    
    public func setVisualState(_ state: MarketGroupSelectorTabVisualState) {
        let currentData = tabDataSubject.value
        let updatedData = MarketGroupSelectorTabData(
            id: currentData.id,
            marketGroups: currentData.marketGroups,
            selectedMarketGroupId: currentData.selectedMarketGroupId,
            visualState: state
        )
        tabDataSubject.send(updatedData)
    }
    
    public func addMarketGroup(_ marketGroup: MarketGroupTabItemData) {
        let currentData = tabDataSubject.value
        var updatedMarketGroups = currentData.marketGroups
        
        // Remove existing market group with same ID if it exists
        updatedMarketGroups.removeAll { $0.id == marketGroup.id }
        updatedMarketGroups.append(marketGroup)
        
        updateMarketGroups(updatedMarketGroups)
    }
    
    public func removeMarketGroup(id: String) {
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
    
    public func updateMarketGroup(_ marketGroup: MarketGroupTabItemData) {
        let currentData = tabDataSubject.value
        let updatedMarketGroups = currentData.marketGroups.map { existingGroup in
            existingGroup.id == marketGroup.id ? marketGroup : existingGroup
        }
        updateMarketGroups(updatedMarketGroups)
    }
    
    // MARK: - Convenience Methods
    public func clearSelection() {
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
    
    public func selectFirstAvailableMarketGroup() {
        let availableGroup = currentMarketGroups.first { $0.visualState != .disabled }
        if let firstGroup = availableGroup {
            selectMarketGroup(id: firstGroup.id)
        }
    }
    
    public func setEnabled(_ enabled: Bool) {
        setVisualState(enabled ? .idle : .disabled)
    }
    
    public func setLoading(_ loading: Bool) {
        setVisualState(loading ? .loading : .idle)
    }
}

// MARK: - Factory Methods
extension MockMarketGroupSelectorTabViewModel {
    
    public static var standardSportsMarkets: MockMarketGroupSelectorTabViewModel {
        let marketGroups = [
            MarketGroupTabItemData(id: "1x2", title: "1x2", visualState: .selected),
            MarketGroupTabItemData(id: "double_chance", title: "Double Chance", visualState: .idle),
            MarketGroupTabItemData(id: "over_under", title: "Over/Under", visualState: .idle),
            MarketGroupTabItemData(id: "another_market", title: "Another market", visualState: .idle)
        ]
        
        return MockMarketGroupSelectorTabViewModel(
            tabData: MarketGroupSelectorTabData(
                id: "sports_markets",
                marketGroups: marketGroups,
                selectedMarketGroupId: "1x2",
                visualState: .idle
            )
        )
    }
    
    public static var limitedMarkets: MockMarketGroupSelectorTabViewModel {
        let marketGroups = [
            MarketGroupTabItemData(id: "1x2", title: "1x2", visualState: .selected),
            MarketGroupTabItemData(id: "over_under", title: "Over/Under", visualState: .idle)
        ]
        
        return MockMarketGroupSelectorTabViewModel(
            tabData: MarketGroupSelectorTabData(
                id: "limited_markets",
                marketGroups: marketGroups,
                selectedMarketGroupId: "1x2",
                visualState: .idle
            )
        )
    }
    
    public static var mixedStateMarkets: MockMarketGroupSelectorTabViewModel {
        let marketGroups = [
            MarketGroupTabItemData(id: "1x2", title: "1x2", visualState: .selected),
            MarketGroupTabItemData(id: "double_chance", title: "Double Chance", visualState: .idle),
            MarketGroupTabItemData(id: "disabled_market", title: "Unavailable", visualState: .disabled),
            MarketGroupTabItemData(id: "over_under", title: "Over/Under", visualState: .idle)
        ]
        
        return MockMarketGroupSelectorTabViewModel(
            tabData: MarketGroupSelectorTabData(
                id: "mixed_markets",
                marketGroups: marketGroups,
                selectedMarketGroupId: "1x2",
                visualState: .idle
            )
        )
    }
    
    public static var emptyMarkets: MockMarketGroupSelectorTabViewModel {
        return MockMarketGroupSelectorTabViewModel(
            tabData: MarketGroupSelectorTabData(
                id: "empty_markets",
                marketGroups: [],
                selectedMarketGroupId: nil,
                visualState: .empty
            )
        )
    }
    
    public static var loadingMarkets: MockMarketGroupSelectorTabViewModel {
        return MockMarketGroupSelectorTabViewModel(
            tabData: MarketGroupSelectorTabData(
                id: "loading_markets",
                marketGroups: [],
                selectedMarketGroupId: nil,
                visualState: .loading
            )
        )
    }
    
    public static var disabledMarkets: MockMarketGroupSelectorTabViewModel {
        let marketGroups = [
            MarketGroupTabItemData(id: "1x2", title: "1x2", visualState: .disabled),
            MarketGroupTabItemData(id: "double_chance", title: "Double Chance", visualState: .disabled),
            MarketGroupTabItemData(id: "over_under", title: "Over/Under", visualState: .disabled)
        ]
        
        return MockMarketGroupSelectorTabViewModel(
            tabData: MarketGroupSelectorTabData(
                id: "disabled_markets",
                marketGroups: marketGroups,
                selectedMarketGroupId: nil,
                visualState: .disabled
            )
        )
    }
    
    public static func customMarkets(
        id: String,
        marketGroups: [MarketGroupTabItemData],
        selectedMarketGroupId: String? = nil
    ) -> MockMarketGroupSelectorTabViewModel {
        return MockMarketGroupSelectorTabViewModel(
            tabData: MarketGroupSelectorTabData(
                id: id,
                marketGroups: marketGroups,
                selectedMarketGroupId: selectedMarketGroupId,
                visualState: marketGroups.isEmpty ? .empty : .idle
            )
        )
    }
    
    // MARK: - Quick Access Collections
    public static var allDemoConfigurations: [MockMarketGroupSelectorTabViewModel] {
        return [
            standardSportsMarkets,
            limitedMarkets,
            mixedStateMarkets,
            emptyMarkets,
            loadingMarkets,
            disabledMarkets
        ]
    }
} 