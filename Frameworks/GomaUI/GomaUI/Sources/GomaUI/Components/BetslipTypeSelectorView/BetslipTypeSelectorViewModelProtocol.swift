import Combine
import UIKit

// MARK: - Data Models
public struct BetslipTypeTabData: Equatable, Hashable {
    public let id: String
    public let title: String
    public let icon: String
    public var isSelected: Bool
    
    public init(id: String, title: String, icon: String, isSelected: Bool = false) {
        self.id = id
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
    }
}

// MARK: - Selection Event
public struct BetslipTypeSelectionEvent: Equatable {
    public let selectedId: String
    public let previouslySelectedId: String?
    
    public init(selectedId: String, previouslySelectedId: String? = nil) {
        self.selectedId = selectedId
        self.previouslySelectedId = previouslySelectedId
    }
}

// MARK: - View Model Protocol
public protocol BetslipTypeSelectorViewModelProtocol {
    // Content publishers
    var tabsPublisher: AnyPublisher<[BetslipTypeTabData], Never> { get }
    var selectedTabIdPublisher: AnyPublisher<String?, Never> { get }
    
    // Selection events
    var selectionEventPublisher: AnyPublisher<BetslipTypeSelectionEvent, Never> { get }
    
    // Current state access
    var currentSelectedTabId: String? { get }
    var currentTabs: [BetslipTypeTabData] { get }
    
    // Actions
    func selectTab(id: String)
    func updateTabs(_ tabs: [BetslipTypeTabData])
    
    // Convenience methods
    func clearSelection()
    func selectFirstAvailableTab()
} 
