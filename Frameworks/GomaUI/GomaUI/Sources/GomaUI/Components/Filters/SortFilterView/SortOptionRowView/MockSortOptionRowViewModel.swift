import Foundation

public class MockSortOptionRowViewModel: SortOptionRowViewModelProtocol {
    
    public var sortOption: SortOption
    
    init(sortOption: SortOption) {
        
        self.sortOption = sortOption
    }
    
}
