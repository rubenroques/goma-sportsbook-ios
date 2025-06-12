import Combine
import UIKit

// MARK: - Visual State
public enum MarketGroupSelectorTabVisualState: Equatable {
    case idle               // Normal state with tabs available
    case loading            // Loading state while fetching market groups
    case empty              // No market groups available
    case disabled           // All tabs disabled/non-interactive
}

// MARK: - Data Models
public struct MarketGroupSelectorTabData: Equatable, Hashable {
    public let id: String
    public let marketGroups: [MarketGroupTabItemData]
    public let selectedMarketGroupId: String?
    public let visualState: MarketGroupSelectorTabVisualState
    
    public init(
        id: String,
        marketGroups: [MarketGroupTabItemData],
        selectedMarketGroupId: String? = nil,
        visualState: MarketGroupSelectorTabVisualState = .idle
    ) {
        self.id = id
        self.marketGroups = marketGroups
        self.selectedMarketGroupId = selectedMarketGroupId
        self.visualState = visualState
    }
}

// MARK: - Selection Event
public struct MarketGroupSelectionEvent: Equatable {
    public let selectedId: String
    public let previouslySelectedId: String?
    public let timestamp: Date
    
    public init(selectedId: String, previouslySelectedId: String? = nil) {
        self.selectedId = selectedId
        self.previouslySelectedId = previouslySelectedId
        self.timestamp = Date()
    }
}

// MARK: - Hashable Conformance for MarketGroupSelectorTabVisualState
extension MarketGroupSelectorTabVisualState: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .idle:
            hasher.combine("idle")
        case .loading:
            hasher.combine("loading")
        case .empty:
            hasher.combine("empty")
        case .disabled:
            hasher.combine("disabled")
        }
    }
}

// MARK: - View Model Protocol
public protocol MarketGroupSelectorTabViewModelProtocol {
    // Content publishers
    var marketGroupsPublisher: AnyPublisher<[MarketGroupTabItemData], Never> { get }
    var selectedMarketGroupIdPublisher: AnyPublisher<String?, Never> { get }
    
    // Unified visual state publisher and current state access
    var visualStatePublisher: AnyPublisher<MarketGroupSelectorTabVisualState, Never> { get }
    var currentVisualState: MarketGroupSelectorTabVisualState { get }
    
    // Selection events
    var selectionEventPublisher: AnyPublisher<MarketGroupSelectionEvent, Never> { get }
    
    // Current state access
    var currentSelectedMarketGroupId: String? { get }
    var currentMarketGroups: [MarketGroupTabItemData] { get }
    
    // Actions
    func selectMarketGroup(id: String)
    func updateMarketGroups(_ marketGroups: [MarketGroupTabItemData])
    func setVisualState(_ state: MarketGroupSelectorTabVisualState)
    func addMarketGroup(_ marketGroup: MarketGroupTabItemData)
    func removeMarketGroup(id: String)
    func updateMarketGroup(_ marketGroup: MarketGroupTabItemData)
    
    // Convenience methods
    func clearSelection()
    func selectFirstAvailableMarketGroup()
    func setEnabled(_ enabled: Bool)
    func setLoading(_ loading: Bool)
} 