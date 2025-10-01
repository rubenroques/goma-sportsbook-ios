import Combine
import UIKit

public final class MockPromotionSelectorBarViewModel: PromotionSelectorBarViewModelProtocol {
    
    // MARK: - Private Properties
    private let _displayState = CurrentValueSubject<PromotionSelectorBarDisplayState, Never>(
        PromotionSelectorBarDisplayState(barData: PromotionSelectorBarData(id: "", promotionItems: []))
    )
    private let _selectionEvent = PassthroughSubject<PromotionSelectionEvent, Never>()
    
    // MARK: - Public Properties
    public var displayStatePublisher: AnyPublisher<PromotionSelectorBarDisplayState, Never> {
        _displayState.eraseToAnyPublisher()
    }
    
    public var selectionEventPublisher: AnyPublisher<PromotionSelectionEvent, Never> {
        _selectionEvent.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    public init(barData: PromotionSelectorBarData) {
        let initialState = PromotionSelectorBarDisplayState(barData: barData)
        _displayState.send(initialState)
    }
    
    // MARK: - Actions
    public func selectPromotion(id: String) {
        let currentState = _displayState.value
        let previouslySelectedId = currentState.barData.selectedPromotionId
        
        // Update the bar data with new selection
        let updatedItems = currentState.barData.promotionItems.map { item in
            PromotionItemData(
                id: item.id,
                title: item.title,
                isSelected: item.id == id,
                category: item.category
            )
        }
        
        let updatedBarData = PromotionSelectorBarData(
            id: currentState.barData.id,
            promotionItems: updatedItems,
            selectedPromotionId: id,
            isScrollEnabled: currentState.barData.isScrollEnabled,
            allowsVisualStateChanges: currentState.barData.allowsVisualStateChanges
        )
        
        let newDisplayState = PromotionSelectorBarDisplayState(
            barData: updatedBarData,
            isVisible: currentState.isVisible,
            isUserInteractionEnabled: currentState.isUserInteractionEnabled
        )
        
        _displayState.send(newDisplayState)
        
        // Send selection event
        let selectionEvent = PromotionSelectionEvent(
            selectedId: id,
            previouslySelectedId: previouslySelectedId
        )
        _selectionEvent.send(selectionEvent)
    }
    
    public func updatePromotionItems(_ items: [PromotionItemData]) {
        let currentState = _displayState.value
        let updatedBarData = PromotionSelectorBarData(
            id: currentState.barData.id,
            promotionItems: items,
            selectedPromotionId: currentState.barData.selectedPromotionId,
            isScrollEnabled: currentState.barData.isScrollEnabled,
            allowsVisualStateChanges: currentState.barData.allowsVisualStateChanges
        )
        
        let newDisplayState = PromotionSelectorBarDisplayState(
            barData: updatedBarData,
            isVisible: currentState.isVisible,
            isUserInteractionEnabled: currentState.isUserInteractionEnabled
        )
        
        _displayState.send(newDisplayState)
    }
    
    public func updateSelectedPromotion(_ id: String?) {
        let currentState = _displayState.value
        let updatedItems = currentState.barData.promotionItems.map { item in
            PromotionItemData(
                id: item.id,
                title: item.title,
                isSelected: item.id == id,
                category: item.category
            )
        }
        
        let updatedBarData = PromotionSelectorBarData(
            id: currentState.barData.id,
            promotionItems: updatedItems,
            selectedPromotionId: id,
            isScrollEnabled: currentState.barData.isScrollEnabled,
            allowsVisualStateChanges: currentState.barData.allowsVisualStateChanges
        )
        
        let newDisplayState = PromotionSelectorBarDisplayState(
            barData: updatedBarData,
            isVisible: currentState.isVisible,
            isUserInteractionEnabled: currentState.isUserInteractionEnabled
        )
        
        _displayState.send(newDisplayState)
    }
    
    public func updateVisibility(_ isVisible: Bool) {
        let currentState = _displayState.value
        let newDisplayState = PromotionSelectorBarDisplayState(
            barData: currentState.barData,
            isVisible: isVisible,
            isUserInteractionEnabled: currentState.isUserInteractionEnabled
        )
        _displayState.send(newDisplayState)
    }
    
    public func updateUserInteraction(_ isEnabled: Bool) {
        let currentState = _displayState.value
        let newDisplayState = PromotionSelectorBarDisplayState(
            barData: currentState.barData,
            isVisible: currentState.isVisible,
            isUserInteractionEnabled: isEnabled
        )
        _displayState.send(newDisplayState)
    }
    
    public func updateBarData(_ barData: PromotionSelectorBarData) {
        let currentState = _displayState.value
        let newDisplayState = PromotionSelectorBarDisplayState(
            barData: barData,
            isVisible: currentState.isVisible,
            isUserInteractionEnabled: currentState.isUserInteractionEnabled
        )
        _displayState.send(newDisplayState)
    }
    
    // MARK: - State Queries
    public func getCurrentDisplayState() -> PromotionSelectorBarDisplayState {
        return _displayState.value
    }
    
    public func isPromotionSelected(_ id: String) -> Bool {
        return _displayState.value.barData.selectedPromotionId == id
    }
    
    public func getSelectedPromotionId() -> String? {
        return _displayState.value.barData.selectedPromotionId
    }
}
