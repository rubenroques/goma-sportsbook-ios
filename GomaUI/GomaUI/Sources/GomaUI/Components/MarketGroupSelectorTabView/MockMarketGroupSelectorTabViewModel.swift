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
        
        // Verify the market group exists
        guard let targetGroup = currentData.marketGroups.first(where: { $0.id == id }) else {
            return
        }
        
        let previouslySelectedId = currentData.selectedMarketGroupId
        
        // Only update the selection ID, not the entire market groups array
        // This avoids recreating all MarketGroupTabItemData objects
        let updatedData = MarketGroupSelectorTabData(
            id: currentData.id,
            marketGroups: currentData.marketGroups, // Keep existing array
            selectedMarketGroupId: id
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
            selectedMarketGroupId: currentData.selectedMarketGroupId
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
            selectedMarketGroupId: updatedSelectedId
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
        
        // Only update the selection ID to nil, keep existing market groups
        let updatedData = MarketGroupSelectorTabData(
            id: currentData.id,
            marketGroups: currentData.marketGroups, // Keep existing array
            selectedMarketGroupId: nil
        )
        
        tabDataSubject.send(updatedData)
    }
    
    public func selectFirstAvailableMarketGroup() {
        // Select the first market group if available
        if let firstGroup = currentMarketGroups.first {
            selectMarketGroup(id: firstGroup.id)
        }
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
                selectedMarketGroupId: "1x2"
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
                selectedMarketGroupId: "1x2"
            )
        )
    }
    
    public static var mixedStateMarkets: MockMarketGroupSelectorTabViewModel {
        let marketGroups = [
            MarketGroupTabItemData(id: "1x2", title: "1x2", visualState: .selected),
            MarketGroupTabItemData(id: "double_chance", title: "Double Chance", visualState: .idle),
            MarketGroupTabItemData(id: "disabled_market", title: "Unavailable", visualState: .idle),
            MarketGroupTabItemData(id: "over_under", title: "Over/Under", visualState: .idle)
        ]
        
        return MockMarketGroupSelectorTabViewModel(
            tabData: MarketGroupSelectorTabData(
                id: "mixed_markets",
                marketGroups: marketGroups,
                selectedMarketGroupId: "1x2"
            )
        )
    }
    
    public static var emptyMarkets: MockMarketGroupSelectorTabViewModel {
        return MockMarketGroupSelectorTabViewModel(
            tabData: MarketGroupSelectorTabData(
                id: "empty_markets",
                marketGroups: [],
                selectedMarketGroupId: nil
            )
        )
    }
    
    public static var loadingMarkets: MockMarketGroupSelectorTabViewModel {
        return MockMarketGroupSelectorTabViewModel(
            tabData: MarketGroupSelectorTabData(
                id: "loading_markets",
                marketGroups: [],
                selectedMarketGroupId: nil
            )
        )
    }
    
    public static var disabledMarkets: MockMarketGroupSelectorTabViewModel {
        let marketGroups = [
            MarketGroupTabItemData(id: "1x2", title: "1x2", visualState: .idle),
            MarketGroupTabItemData(id: "double_chance", title: "Double Chance", visualState: .idle),
            MarketGroupTabItemData(id: "over_under", title: "Over/Under", visualState: .idle)
        ]
        
        return MockMarketGroupSelectorTabViewModel(
            tabData: MarketGroupSelectorTabData(
                id: "disabled_markets",
                marketGroups: marketGroups,
                selectedMarketGroupId: nil
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
                selectedMarketGroupId: selectedMarketGroupId
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
