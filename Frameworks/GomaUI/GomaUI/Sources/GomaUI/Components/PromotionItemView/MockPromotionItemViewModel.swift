import Combine
import UIKit

public final class MockPromotionItemViewModel: PromotionItemViewModelProtocol {
    
    // MARK: - Private Properties
    private let _id = CurrentValueSubject<String, Never>("")
    private let _title = CurrentValueSubject<String, Never>("")
    private let _isSelected = CurrentValueSubject<Bool, Never>(false)
    private let _category = CurrentValueSubject<String?, Never>(nil)
    
    public let isReadOnly: Bool
    
    // MARK: - Public Properties
    public var idPublisher: AnyPublisher<String, Never> {
        _id.eraseToAnyPublisher()
    }
    
    public var titlePublisher: AnyPublisher<String, Never> {
        _title.eraseToAnyPublisher()
    }
    
    public var isSelectedPublisher: AnyPublisher<Bool, Never> {
        _isSelected.eraseToAnyPublisher()
    }
    
    public var categoryPublisher: AnyPublisher<String?, Never> {
        _category.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    public init(promotionItemData: PromotionItemData, isReadOnly: Bool = false) {
        self.isReadOnly = isReadOnly
        configure(with: promotionItemData)
    }
    
    // MARK: - Actions
    public func selectPromotion() {
        guard !isReadOnly else { return }
        _isSelected.send(!_isSelected.value)
    }
    
    public func updateTitle(_ title: String) {
        _title.send(title)
    }
    
    public func updateCategory(_ category: String?) {
        _category.send(category)
    }
    
    // MARK: - Private Methods
    private func configure(with data: PromotionItemData) {
        _id.send(data.id)
        _title.send(data.title)
        _isSelected.send(data.isSelected)
        _category.send(data.category)
    }
}
