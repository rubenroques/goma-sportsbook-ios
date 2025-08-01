//
//  CombinedFiltersViewModelProtocol.swift
//  Sportsbook
//
//  Created by André Lascas on 25/06/2025.
//

import Foundation
import GomaUI
import Combine

protocol CombinedFiltersViewModelProtocol {
    // MARK: - Properties
    var popularLeagues: [SortOption] { get }
    var popularCountryLeagues: [CountryLeagueOptions] { get }
    var otherCountryLeagues: [CountryLeagueOptions] { get }
    
    var appliedFilters: AppliedEventsFilters { get set }
    var filterConfiguration: FilterConfiguration { get }
    var currentContextId: String { get }
    
    var dynamicViewModels: [String: Any] { get }
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> { get }
    
    // MARK: - Methods
    func getAllLeagues(sportId: String?)
    func setupAllLeagues(popularCompetitions: [Competition], sportCompetitions: [Competition])
    func refreshLeaguesFilterData()
    func refreshCountryLeaguesFilterData()
    func createDynamicViewModels(for configuration: FilterConfiguration, contextId: String)
    func createViewModel(for widget: FilterWidget) -> Any?
}
