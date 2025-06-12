import Combine
import UIKit

// MARK: - Visual State
public enum MarketGroupTabItemVisualState: Equatable {
    case idle           // Normal unselected state
    case selected       // Tab is currently selected
    case disabled       // Tab is disabled and non-interactive
}

// MARK: - Data Models
public struct MarketGroupTabItemData: Equatable, Hashable {
    public let id: String
    public let title: String
    public let visualState: MarketGroupTabItemVisualState
    
    public init(
        id: String,
        title: String,
        visualState: MarketGroupTabItemVisualState = .idle
    ) {
        self.id = id
        self.title = title
        self.visualState = visualState
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
        case .disabled:
            hasher.combine("disabled")
        }
    }
}

// MARK: - View Model Protocol
public protocol MarketGroupTabItemViewModelProtocol {
    // Content publishers
    var titlePublisher: AnyPublisher<String, Never> { get }
    var idPublisher: AnyPublisher<String, Never> { get }
    
    // Unified visual state publisher and current state access
    var visualStatePublisher: AnyPublisher<MarketGroupTabItemVisualState, Never> { get }
    var currentVisualState: MarketGroupTabItemVisualState { get }
    
    // Actions
    func setVisualState(_ state: MarketGroupTabItemVisualState)
    func updateTitle(_ title: String)
    func updateTabItemData(_ tabItemData: MarketGroupTabItemData)
    
    // Convenience methods for common state transitions
    func setSelected(_ selected: Bool)
    func setEnabled(_ enabled: Bool)
    
    // Tap handling
    var onTapPublisher: AnyPublisher<String, Never> { get }
    func handleTap()
} 