import Foundation
import UIKit
import Combine

public class MockSortFilterViewModel: SortFilterViewModelProtocol {
    public let title: String
    public var sortOptions: [SortOption]
    public var sortFilterType: SortFilterType

    public var selectedOptionId: CurrentValueSubject<String, Never>
    public var isCollapsed: CurrentValueSubject<Bool, Never> = .init(false)
    public var shouldRefreshData: PassthroughSubject<Void, Never> = .init()
    
    public init(title: String, sortOptions: [SortOption], selectedId: String = "1", sortFilterType: SortFilterType = .regular) {
        self.title = title
        self.sortOptions = sortOptions
        self.sortFilterType = sortFilterType
        self.selectedOptionId = .init(selectedId)
    }
    
    public func selectOption(withId id: String) {
        selectedOptionId.send(id)
    }
    
    public func toggleCollapse() {
        isCollapsed.send(!isCollapsed.value)
    }
    
    public func updateSortOptions(_ newSortOptions: [SortOption]) {
        // Update the internal sortOptions array
        self.sortOptions = newSortOptions
                
        self.shouldRefreshData.send()
    }
}
