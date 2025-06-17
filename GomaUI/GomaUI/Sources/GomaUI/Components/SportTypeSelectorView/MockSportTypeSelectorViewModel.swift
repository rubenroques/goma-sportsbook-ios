import Combine
import UIKit

/// Mock implementation of `SportTypeSelectorViewModelProtocol` for testing.
final public class MockSportTypeSelectorViewModel: SportTypeSelectorViewModelProtocol {
    
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<SportTypeSelectorDisplayState, Never>
    public var displayStatePublisher: AnyPublisher<SportTypeSelectorDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }
    
    // Internal state
    private var internalSports: [SportTypeData]
    
    // MARK: - Initialization
    public init(sports: [SportTypeData]) {
        self.internalSports = sports
        let initialState = SportTypeSelectorDisplayState(sports: sports)
        self.displayStateSubject = CurrentValueSubject(initialState)
    }
    
    // MARK: - Public Methods
    public func updateSports(_ sports: [SportTypeData]) {
        self.internalSports = sports
        publishNewState()
    }
    
    public func addSport(_ sport: SportTypeData) {
        if !internalSports.contains(where: { $0.id == sport.id }) {
            internalSports.append(sport)
            publishNewState()
        }
    }
    
    public func removeSport(withId id: String) {
        internalSports.removeAll { $0.id == id }
        publishNewState()
    }
    
    // MARK: - Helper Methods
    private func publishNewState() {
        let newState = SportTypeSelectorDisplayState(sports: internalSports)
        displayStateSubject.send(newState)
    }
}

// MARK: - Mock Factory
extension MockSportTypeSelectorViewModel {
    public static var defaultMock: MockSportTypeSelectorViewModel {
        let sports = [
            SportTypeData(id: "football", name: "Football", iconName: "football"),
            SportTypeData(id: "basketball", name: "Basketball", iconName: "basketball"),
            SportTypeData(id: "tennis", name: "Tennis", iconName: "tennis"),
            SportTypeData(id: "baseball", name: "Baseball", iconName: "baseball")
        ]
        return MockSportTypeSelectorViewModel(sports: sports)
    }
    
    public static var manySportsMock: MockSportTypeSelectorViewModel {
        let sports = [
            SportTypeData(id: "football", name: "Football", iconName: "football"),
            SportTypeData(id: "basketball", name: "Basketball", iconName: "basketball"),
            SportTypeData(id: "tennis", name: "Tennis", iconName: "tennis"),
            SportTypeData(id: "baseball", name: "Baseball", iconName: "baseball"),
            SportTypeData(id: "hockey", name: "Hockey", iconName: "hockey"),
            SportTypeData(id: "golf", name: "Golf", iconName: "golf"),
            SportTypeData(id: "volleyball", name: "Volleyball", iconName: "volleyball"),
            SportTypeData(id: "soccer", name: "Soccer", iconName: "soccer"),
            SportTypeData(id: "boxing", name: "Boxing", iconName: "boxing"),
            SportTypeData(id: "swimming", name: "Swimming", iconName: "swimming"),
            SportTypeData(id: "athletics", name: "Athletics", iconName: "athletics"),
            SportTypeData(id: "cycling", name: "Cycling", iconName: "cycling")
        ]
        return MockSportTypeSelectorViewModel(sports: sports)
    }
    
    public static var fewSportsMock: MockSportTypeSelectorViewModel {
        let sports = [
            SportTypeData(id: "football", name: "Football", iconName: "football"),
            SportTypeData(id: "basketball", name: "Basketball", iconName: "basketball")
        ]
        return MockSportTypeSelectorViewModel(sports: sports)
    }
    
    public static var emptySportsMock: MockSportTypeSelectorViewModel {
        return MockSportTypeSelectorViewModel(sports: [])
    }
}