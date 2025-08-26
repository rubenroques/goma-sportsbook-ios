import Foundation

public class MockSportCardViewModel: SportCardViewModelProtocol {
    
    public var sportFilter: SportFilter
    
    init(sportFilter: SportFilter) {
        
        self.sportFilter = sportFilter
    }
    
}
