//
//  CountryLeaguesFilterViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 27/05/2025.
//

import Foundation
import Combine

public protocol CountryLeaguesFilterViewModelProtocol {
    var title: String { get }
    var countryLeagueOptions: [CountryLeagueOptions] { get }
    var selectedOptionId: CurrentValueSubject<Int, Never> { get }
    var isCollapsed: CurrentValueSubject<Bool, Never> { get }
    var shouldRefreshData: PassthroughSubject<Void, Never> { get }

    func toggleCollapse()
    func toggleCountryExpansion(at index: Int)
    func updateCountryLeagueOptions(_ newSortOptions: [CountryLeagueOptions])
}
