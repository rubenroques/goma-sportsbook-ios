//
//  CountryLeagueOptionRowViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 27/05/2025.
//

import Foundation
import Combine

public protocol CountryLeagueOptionRowViewModelProtocol {
//    var leagues: [LeagueOption] { get }
    
    var countryLeagueOptions: CountryLeagueOptions { get }

    var selectedOptionId: CurrentValueSubject<Int, Never> { get }
    var isCollapsed: CurrentValueSubject<Bool, Never> { get }

    func selectOption(withId id: Int)
    func toggleCollapse()
}
