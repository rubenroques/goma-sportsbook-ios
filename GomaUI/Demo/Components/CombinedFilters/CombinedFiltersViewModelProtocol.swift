//
//  CombinedFiltersViewModelProtocol.swift
//  Demo
//
//  Created by André Lascas on 24/06/2025.
//

import Foundation
import GomaUI
import Combine

public protocol CombinedFiltersViewModelProtocol {
    // MARK: - Properties
    var popularLeagues: [SortOption] { get }
    var popularCountryLeagues: [CountryLeagueOptions] { get }
    var otherCountryLeagues: [CountryLeagueOptions] { get }
    
    var generalFilterSelection: GeneralFilterSelection { get set }
    var defaultFilterSelection: GeneralFilterSelection { get }
    
    var filterConfiguration: FilterConfiguration { get }
    var currentContextId: String { get }
    
    var dynamicViewModels: [String: Any] { get set }
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> { get }
    
    // MARK: - Methods
    func getAllLeagues()
    func recheckAllLeagues()
    func refreshLeaguesFilterData()
    func refreshCountryLeaguesFilterData()
}
