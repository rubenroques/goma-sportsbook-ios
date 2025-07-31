import Combine
import UIKit

/// Mock implementation of `PromotionalHeaderViewModelProtocol` for testing.
final public class MockPromotionalHeaderViewModel: PromotionalHeaderViewModelProtocol {
    
    private var headerData: PromotionalHeaderData
    
    // MARK: - Initialization
    public init(headerData: PromotionalHeaderData) {
        self.headerData = headerData
        
    }
    
    // MARK: - Helper Methods
    public func getHeaderData() -> PromotionalHeaderData {
        return headerData
    }
    
    public func updateHeaderData(_ newData: PromotionalHeaderData) {
        headerData = newData
    }
}

// MARK: - Mock Factory
extension MockPromotionalHeaderViewModel {
    
    /// Default mock with both title and subtitle (matches the image provided)
    public static var defaultMock: MockPromotionalHeaderViewModel {
        let headerData = PromotionalHeaderData(
            id: "deposit_bonus",
            icon: "dollarsign.circle.fill",
            title: "Claim a first deposit bonus!",
            subtitle: "Select a first deposit bonus of your choosing..."
        )
        
        return MockPromotionalHeaderViewModel(headerData: headerData)
    }
    
    /// Mock without subtitle to test optional subtitle functionality
    public static var noSubtitleMock: MockPromotionalHeaderViewModel {
        let headerData = PromotionalHeaderData(
            id: "welcome_bonus",
            icon: "gift.fill",
            title: "Welcome Bonus Available!",
            subtitle: nil
        )
        
        return MockPromotionalHeaderViewModel(headerData: headerData)
    }
    
    
} 
