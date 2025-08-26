import Foundation
import Combine

public class MockSportGamesFilterViewModel: SportGamesFilterViewModelProtocol {
    public var title: String
    public var sportFilters: [SportFilter] = []
    public var selectedId: CurrentValueSubject<String, Never>
    public var sportFilterState: CurrentValueSubject<SportGamesFilterStateType, Never> = .init(.expanded)
    
    public init(title: String, sportFilters: [SportFilter], selectedId: String = "1") {
        self.title = title
        self.sportFilters = sportFilters
        self.selectedId = .init(selectedId)
    }
    
    public func selectOption(withId id: String) {
        selectedId.send(id)
    }
    
    public func didTapCollapseButton() {
        let newState: SportGamesFilterStateType = sportFilterState.value == .expanded ? .collapsed : .expanded
        sportFilterState.send(newState)
    }
}
