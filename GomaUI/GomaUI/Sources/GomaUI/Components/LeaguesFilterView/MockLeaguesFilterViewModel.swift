//
//  MockLeaguesFilterViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 27/05/2025.
//

import Foundation
import UIKit
import Combine

public class MockLeaguesFilterViewModel: LeaguesFilterViewModelProtocol {
    public let leagueOptions: [LeagueOption]
    
    public var selectedOptionId: CurrentValueSubject<Int, Never>
    public var isCollapsed: CurrentValueSubject<Bool, Never> = .init(false)
    
    public init(leagueOptions: [LeagueOption], selectedId: Int = 1) {
        self.leagueOptions = leagueOptions
        self.selectedOptionId = .init(selectedId)
    }
    
    public func selectOption(withId id: Int) {
        selectedOptionId.send(id)
    }
    
    public func toggleCollapse() {
        isCollapsed.send(!isCollapsed.value)
    }
}
