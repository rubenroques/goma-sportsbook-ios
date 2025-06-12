//
//  MockGamesViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 23/05/2025.
//

import Foundation
import Combine

public class MockSportGamesFilterViewModel: SportGamesFilterViewModelProtocol {
    public var title: String
    public var sportFilters: [SportFilter] = []
    public var selectedId: CurrentValueSubject<Int, Never>
    public var sportFilterState: CurrentValueSubject<SportGamesFilterStateType, Never> = .init(.expanded)
    
    public init(title: String, sportFilters: [SportFilter], selectedId: Int = 1) {
        self.title = title
        self.sportFilters = sportFilters
        self.selectedId = .init(selectedId)
    }
    
    public func selectOption(withId id: Int) {
        selectedId.send(id)
    }
    
    public func didTapCollapseButton() {
        let newState: SportGamesFilterStateType = sportFilterState.value == .expanded ? .collapsed : .expanded
        sportFilterState.send(newState)
    }
}
