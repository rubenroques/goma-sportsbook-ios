import Combine
import UIKit

// MARK: - Data Models
public struct PillSelectorBarData: Equatable, Hashable {
    public let id: String
    public let pills: [PillData]
    public let selectedPillId: String?
    public let isScrollEnabled: Bool
    public let allowsVisualStateChanges: Bool
    
    public init(
        id: String,
        pills: [PillData],
        selectedPillId: String? = nil,
        isScrollEnabled: Bool = true,
        allowsVisualStateChanges: Bool = true
    ) {
        self.id = id
        self.pills = pills
        self.selectedPillId = selectedPillId
        self.isScrollEnabled = isScrollEnabled
        self.allowsVisualStateChanges = allowsVisualStateChanges
    }
}

// MARK: - Selection Event
public struct PillSelectionEvent: Equatable {
    public let selectedId: String
    public let previouslySelectedId: String?
    public let timestamp: Date
    
    public init(selectedId: String, previouslySelectedId: String? = nil) {
        self.selectedId = selectedId
        self.previouslySelectedId = previouslySelectedId
        self.timestamp = Date()
    }
}

// MARK: - Display State
public struct PillSelectorBarDisplayState: Equatable {
    public let barData: PillSelectorBarData
    public let isVisible: Bool
    public let isUserInteractionEnabled: Bool
    
    public init(
        barData: PillSelectorBarData,
        isVisible: Bool = true,
        isUserInteractionEnabled: Bool = true
    ) {
        self.barData = barData
        self.isVisible = isVisible
        self.isUserInteractionEnabled = isUserInteractionEnabled
    }
}

// MARK: - View Model Protocol
public protocol PillSelectorBarViewModelProtocol {
    /// Publisher for reactive updates
    var displayStatePublisher: AnyPublisher<PillSelectorBarDisplayState, Never> { get }
    
    /// Publisher for selection events
    var selectionEventPublisher: AnyPublisher<PillSelectionEvent, Never> { get }
    
    /// Current state access
    var currentSelectedPillId: String? { get }
    var currentPills: [PillData] { get }
    
    /// Actions
    func selectPill(id: String)
    func updatePills(_ pills: [PillData])
    func addPill(_ pill: PillData)
    func removePill(id: String)
    func updatePill(_ pill: PillData)
    
    /// Convenience methods
    func clearSelection()
    func selectFirstAvailablePill()
    func setVisible(_ visible: Bool)
    func setUserInteractionEnabled(_ enabled: Bool)
}

extension PillSelectorBarViewModelProtocol {
    func updateCounter(_ count: Int) { }
}
