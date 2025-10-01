import Combine
import UIKit

// MARK: - Data Models
public struct PromotionSelectorBarData: Equatable, Hashable {
    public let id: String
    public let promotionItems: [PromotionItemData]
    public let selectedPromotionId: String?
    public let isScrollEnabled: Bool
    public let allowsVisualStateChanges: Bool
    
    public init(
        id: String,
        promotionItems: [PromotionItemData],
        selectedPromotionId: String? = nil,
        isScrollEnabled: Bool = true,
        allowsVisualStateChanges: Bool = true
    ) {
        self.id = id
        self.promotionItems = promotionItems
        self.selectedPromotionId = selectedPromotionId
        self.isScrollEnabled = isScrollEnabled
        self.allowsVisualStateChanges = allowsVisualStateChanges
    }
}

// MARK: - Selection Event
public struct PromotionSelectionEvent: Equatable {
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
public struct PromotionSelectorBarDisplayState: Equatable {
    public let barData: PromotionSelectorBarData
    public let isVisible: Bool
    public let isUserInteractionEnabled: Bool
    
    public init(
        barData: PromotionSelectorBarData,
        isVisible: Bool = true,
        isUserInteractionEnabled: Bool = true
    ) {
        self.barData = barData
        self.isVisible = isVisible
        self.isUserInteractionEnabled = isUserInteractionEnabled
    }
}

// MARK: - View Model Protocol
public protocol PromotionSelectorBarViewModelProtocol {
    
    // MARK: - Publishers
    var displayStatePublisher: AnyPublisher<PromotionSelectorBarDisplayState, Never> { get }
    var selectionEventPublisher: AnyPublisher<PromotionSelectionEvent, Never> { get }
    
    // MARK: - Actions
    func selectPromotion(id: String)
    func updatePromotionItems(_ items: [PromotionItemData])
    func updateSelectedPromotion(_ id: String?)
    func updateVisibility(_ isVisible: Bool)
    func updateUserInteraction(_ isEnabled: Bool)
    func updateBarData(_ barData: PromotionSelectorBarData)
    
    // MARK: - State Queries
    func getCurrentDisplayState() -> PromotionSelectorBarDisplayState
    func isPromotionSelected(_ id: String) -> Bool
    func getSelectedPromotionId() -> String?
}
