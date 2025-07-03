import Combine
import UIKit

// MARK: - Data Models
public struct MarketGroupSelectorTabData: Equatable, Hashable {
    public let id: String
    public let marketGroups: [MarketGroupTabItemData]
    public let selectedMarketGroupId: String?
    
    public init(
        id: String,
        marketGroups: [MarketGroupTabItemData],
        selectedMarketGroupId: String? = nil
    ) {
        self.id = id
        self.marketGroups = marketGroups
        self.selectedMarketGroupId = selectedMarketGroupId
    }
}

// MARK: - Selection Event
public struct MarketGroupSelectionEvent: Equatable {
    public let selectedId: String
    public let previouslySelectedId: String?
    
    public init(selectedId: String, previouslySelectedId: String? = nil) {
        self.selectedId = selectedId
        self.previouslySelectedId = previouslySelectedId
    }
    
}

// MARK: - View Model Protocol
public protocol MarketGroupSelectorTabViewModelProtocol {
    // Content publishers
    var marketGroupsPublisher: AnyPublisher<[MarketGroupTabItemData], Never> { get }
    var selectedMarketGroupIdPublisher: AnyPublisher<String?, Never> { get }
    
    // Selection events
    var selectionEventPublisher: AnyPublisher<MarketGroupSelectionEvent, Never> { get }
    
    // Current state access
    var currentSelectedMarketGroupId: String? { get }
    var currentMarketGroups: [MarketGroupTabItemData] { get }
    
    // Actions
    func selectMarketGroup(id: String)
    func updateMarketGroups(_ marketGroups: [MarketGroupTabItemData])
    
    func addMarketGroup(_ marketGroup: MarketGroupTabItemData)
    func removeMarketGroup(id: String)
    func updateMarketGroup(_ marketGroup: MarketGroupTabItemData)
    
    // Convenience methods
    func clearSelection()
    func selectFirstAvailableMarketGroup()
} 
