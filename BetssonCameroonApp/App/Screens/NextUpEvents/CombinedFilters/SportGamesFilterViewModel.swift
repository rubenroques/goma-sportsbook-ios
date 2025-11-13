import Foundation
import Combine
import SharedModels
import GomaUI

public class SportGamesFilterViewModel: SportGamesFilterViewModelProtocol {
    public var title: String
    public var sportFilters: [SportFilter] = []
    public var selectedSport: CurrentValueSubject<FilterIdentifier, Never>
    public var sportFilterState: CurrentValueSubject<SportGamesFilterStateType, Never>

    public init(title: String, sportFilters: [SportFilter], selectedSport: FilterIdentifier = .all, sportFilterState: SportGamesFilterStateType = .expanded) {
        self.title = title
        self.sportFilters = sportFilters
        self.selectedSport = .init(selectedSport)
        self.sportFilterState = .init(sportFilterState)
    }

    public func selectSport(_ sport: FilterIdentifier) {
        selectedSport.send(sport)
    }

    public func didTapCollapseButton() {
        let newState: SportGamesFilterStateType = sportFilterState.value == .expanded ? .collapsed : .expanded
        sportFilterState.send(newState)
    }
}
