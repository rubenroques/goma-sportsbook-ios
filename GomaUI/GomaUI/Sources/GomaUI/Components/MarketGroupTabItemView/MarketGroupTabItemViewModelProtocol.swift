import Combine
import UIKit

// MARK: - Visual State
public enum MarketGroupTabItemVisualState: Equatable {
    case idle           // Normal unselected state
    case selected       // Tab is currently selected
}

// MARK: - Image Resolver Protocol
public protocol MarketGroupTabImageResolver {
    func tabIcon(for tabType: String) -> UIImage?
}

// MARK: - Default Image Resolver
public struct DefaultMarketGroupTabImageResolver: MarketGroupTabImageResolver {
    public init() {}
    
    public func tabIcon(for tabType: String) -> UIImage? {
        switch tabType {
        case "betbuilder":
            return UIImage(systemName: "square.stack.3d.up")
        case "popular":
            return UIImage(systemName: "flame")
        case "sets":
            return UIImage(systemName: "square.grid.2x2")
        case "games":
            return UIImage(systemName: "gamecontroller")
        case "players":
            return UIImage(systemName: "person.2")
        default:
            return nil
        }
    }
}

// MARK: - Data Models
public struct MarketGroupTabItemData: Equatable, Hashable {
    public let id: String
    public let title: String
    public let visualState: MarketGroupTabItemVisualState
    public let iconTypeName: String?
    public let badgeCount: Int?
    
    public init(
        id: String,
        title: String,
        visualState: MarketGroupTabItemVisualState = .idle,
        iconTypeName: String? = nil,
        badgeCount: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.visualState = visualState
        self.iconTypeName = iconTypeName
        self.badgeCount = badgeCount
    }
}

// MARK: - Hashable Conformance for MarketGroupTabItemVisualState
extension MarketGroupTabItemVisualState: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .idle:
            hasher.combine("idle")
        case .selected:
            hasher.combine("selected")
        }
    }
}

// MARK: - View Model Protocol
public protocol MarketGroupTabItemViewModelProtocol {
    // Content publishers
    var titlePublisher: AnyPublisher<String, Never> { get }
    var idPublisher: AnyPublisher<String, Never> { get }
    var iconTypePublisher: AnyPublisher<String?, Never> { get }
    var badgeCountPublisher: AnyPublisher<Int?, Never> { get }
    
    // Unified visual state publisher and current state access
    var visualStatePublisher: AnyPublisher<MarketGroupTabItemVisualState, Never> { get }
    var currentVisualState: MarketGroupTabItemVisualState { get }
    
    // Actions
    func setVisualState(_ state: MarketGroupTabItemVisualState)
    func updateTitle(_ title: String)
    func updateIconType(_ iconType: String?)
    func updateBadgeCount(_ count: Int?)
    func updateTabItemData(_ tabItemData: MarketGroupTabItemData)
    
    // Convenience methods for common state transitions
    func setSelected(_ selected: Bool)
    func setEnabled(_ enabled: Bool)
    
    // Tap handling
    var onTapPublisher: AnyPublisher<String, Never> { get }
    func handleTap()
} 
