import Combine
import UIKit

// MARK: - Data Models
public struct PromotionItemData: Equatable, Hashable {
    public let id: String
    public let title: String
    public let isSelected: Bool
    public let category: String?
    
    public init(id: String, title: String, isSelected: Bool = false, category: String? = nil) {
        self.id = id
        self.title = title
        self.isSelected = isSelected
        self.category = category
    }
}

// MARK: - Display State
public struct PromotionItemDisplayState: Equatable {
    public let promotionItemData: PromotionItemData
    
    public init(promotionItemData: PromotionItemData) {
        self.promotionItemData = promotionItemData
    }
}

// MARK: - View Model Protocol
public protocol PromotionItemViewModelProtocol {
    // Individual publishers for each state property
    var idPublisher: AnyPublisher<String, Never> { get }
    var titlePublisher: AnyPublisher<String, Never> { get }
    var isSelectedPublisher: AnyPublisher<Bool, Never> { get }
    var categoryPublisher: AnyPublisher<String?, Never> { get }
    
    // Read-only state - when true, selectPromotion() should not change the selection state
    var isReadOnly: Bool { get }
    
    // Actions
    func selectPromotion()
    func updateTitle(_ title: String)
    func updateCategory(_ category: String?)
}
