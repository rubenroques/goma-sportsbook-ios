//
//  MockCountryLeagueOptionRowViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 28/05/2025.
//

import Foundation
import Combine

public class MockCountryLeagueOptionRowViewModel: CountryLeagueOptionRowViewModelProtocol {
//    public var leagues: [LeagueOption]
    public var countryLeagueOptions: CountryLeagueOptions
    public var selectedOptionId: CurrentValueSubject<Int, Never>
    public var isCollapsed: CurrentValueSubject<Bool, Never>
    
    public init(countryLeaguesOptions: CountryLeagueOptions, selectedLeagueId: Int) {
        
        self.countryLeagueOptions = countryLeaguesOptions
        self.selectedOptionId = .init(selectedLeagueId)
        
        if countryLeagueOptions.leagues.contains(where: {
            $0.id == selectedLeagueId
        }) {
            self.isCollapsed = .init(false)
        }
        else {
            self.isCollapsed = .init(true)
        }
    }
    
    public func toggleCollapse() {
        isCollapsed.send(!isCollapsed.value)
    }
    
    public func selectOption(withId id: Int) {
        selectedOptionId.send(id)
    }
}
