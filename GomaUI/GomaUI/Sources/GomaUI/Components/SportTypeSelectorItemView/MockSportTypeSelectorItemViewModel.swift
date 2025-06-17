import Combine
import UIKit

/// Mock implementation of `SportTypeSelectorItemViewModelProtocol` for testing.
final public class MockSportTypeSelectorItemViewModel: SportTypeSelectorItemViewModelProtocol {
    
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<SportTypeSelectorItemDisplayState, Never>
    public var displayStatePublisher: AnyPublisher<SportTypeSelectorItemDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    public init(sportData: SportTypeData) {
        let initialState = SportTypeSelectorItemDisplayState(sportData: sportData)
        self.displayStateSubject = CurrentValueSubject(initialState)
    }
    
    // MARK: - Public Methods
    public func updateSportData(_ sportData: SportTypeData) {
        let newState = SportTypeSelectorItemDisplayState(sportData: sportData)
        displayStateSubject.send(newState)
    }
}

// MARK: - Mock Factory
extension MockSportTypeSelectorItemViewModel {
    public static var footballMock: MockSportTypeSelectorItemViewModel {
        let sportData = SportTypeData(
            id: "football",
            name: "Football",
            iconName: "football"
        )
        return MockSportTypeSelectorItemViewModel(sportData: sportData)
    }
    
    public static var basketballMock: MockSportTypeSelectorItemViewModel {
        let sportData = SportTypeData(
            id: "basketball", 
            name: "Basketball",
            iconName: "basketball"
        )
        return MockSportTypeSelectorItemViewModel(sportData: sportData)
    }
    
    public static var tennisMock: MockSportTypeSelectorItemViewModel {
        let sportData = SportTypeData(
            id: "tennis",
            name: "Tennis", 
            iconName: "tennis"
        )
        return MockSportTypeSelectorItemViewModel(sportData: sportData)
    }
    
    public static var baseballMock: MockSportTypeSelectorItemViewModel {
        let sportData = SportTypeData(
            id: "baseball",
            name: "Baseball",
            iconName: "baseball"
        )
        return MockSportTypeSelectorItemViewModel(sportData: sportData)
    }
    
    public static var hockeyMock: MockSportTypeSelectorItemViewModel {
        let sportData = SportTypeData(
            id: "hockey",
            name: "Hockey",
            iconName: "hockey"
        )
        return MockSportTypeSelectorItemViewModel(sportData: sportData)
    }
    
    public static var golfMock: MockSportTypeSelectorItemViewModel {
        let sportData = SportTypeData(
            id: "golf",
            name: "Golf",
            iconName: "golf"
        )
        return MockSportTypeSelectorItemViewModel(sportData: sportData)
    }
    
    public static var volleyballMock: MockSportTypeSelectorItemViewModel {
        let sportData = SportTypeData(
            id: "volleyball",
            name: "Volleyball",
            iconName: "volleyball"
        )
        return MockSportTypeSelectorItemViewModel(sportData: sportData)
    }
    
    public static var soccerMock: MockSportTypeSelectorItemViewModel {
        let sportData = SportTypeData(
            id: "soccer",
            name: "Soccer",
            iconName: "soccer"
        )
        return MockSportTypeSelectorItemViewModel(sportData: sportData)
    }
}