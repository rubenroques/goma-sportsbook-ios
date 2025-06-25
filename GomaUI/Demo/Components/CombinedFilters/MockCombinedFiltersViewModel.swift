//
//  MockCombinedFiltersViewModel.swift
//  Demo
//
//  Created by André Lascas on 24/06/2025.
//

import Foundation
import GomaUI
import Combine

public struct GeneralFilterSelection {
    var sportId: String
    var timeValue: Float
    var sortTypeId: String
    var leagueId: String
}

public class MockCombinedFiltersViewModel: CombinedFiltersViewModelProtocol {
    
    public var popularLeagues = [SortOption]()
    public var popularCountryLeagues = [CountryLeagueOptions]()
    public var otherCountryLeagues = [CountryLeagueOptions]()
    
    public var generalFilterSelection: GeneralFilterSelection
    public var defaultFilterSelection: GeneralFilterSelection = GeneralFilterSelection(
        sportId: "1", timeValue: 1.0, sortTypeId: "1",
        leagueId: "all"
    )
    
    public var filterConfiguration: FilterConfiguration
    public var currentContextId: String
    
    public var dynamicViewModels: [String: Any] = [:]
    
    public var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    
    init(filterSelection: GeneralFilterSelection,
         filterConfiguration: FilterConfiguration,
         contextId: String = "sports") {
        
        self.generalFilterSelection = filterSelection
        self.filterConfiguration = filterConfiguration
        self.currentContextId = contextId
        
        // TEST
        if filterSelection.sportId == "1" {
            self.getAllLeagues()
        }
        else {
            self.recheckAllLeagues()
        }
    }
    
    public func getAllLeagues() {
        isLoadingPublisher.send(true)
        
        popularLeagues.removeAll()
        popularCountryLeagues.removeAll()
        otherCountryLeagues.removeAll()

        // Popular Leagues
        var allLeaguesOption = SortOption(id: "0", icon: "league_icon", title: "All Popular Leagues", count: 0, iconTintChange: false)
        
        let newSortOptions = [
            SortOption(id: "1", icon: "league_icon", title: "Premier League", count: 32, iconTintChange: false),
            SortOption(id: "16", icon: "league_icon", title: "La Liga", count: 28, iconTintChange: false),
            SortOption(id: "10", icon: "league_icon", title: "Bundesliga", count: 25, iconTintChange: false),
            SortOption(id: "13", icon: "league_icon", title: "Serie A", count: 27, iconTintChange: false),
            SortOption(id: "7", icon: "league_icon", title: "Ligue 1", count: 0, iconTintChange: false),
            SortOption(id: "19", icon: "league_icon", title: "Champions League", count: 16, iconTintChange: false),
            SortOption(id: "20", icon: "league_icon", title: "Europa League", count: 12, iconTintChange: false),
            SortOption(id: "8", icon: "league_icon", title: "MLS", count: 28, iconTintChange: false),
            SortOption(id: "28", icon: "league_icon", title: "Eredivisie", count: 18, iconTintChange: false),
            SortOption(id: "24", icon: "league_icon", title: "Primeira Liga", count: 16, iconTintChange: false)
        ]
        
        let totalCount = newSortOptions.reduce(0) { $0 + $1.count }
        
        allLeaguesOption.count = totalCount
        
        popularLeagues.append(allLeaguesOption)
        popularLeagues.append(contentsOf: newSortOptions)
        
        // Popular Country Leagues
        let countryLeagueOptions = [
            CountryLeagueOptions(
                id: "1",
                icon: "international_flag_icon",
                title: "England",
                leagues: [
                    LeagueOption(id: "1", icon: "nil", title: "Premier League", count: 25),
                    LeagueOption(id: "2", icon: nil, title: "Championship", count: 24),
                    LeagueOption(id: "3", icon: nil, title: "League One", count: 22),
                    LeagueOption(id: "4", icon: nil, title: "League Two", count: 0),
                    LeagueOption(id: "5", icon: nil, title: "FA Cup", count: 18),
                    LeagueOption(id: "6", icon: nil, title: "EFL Cup", count: 16)
                ],
                isExpanded: true
            ),
            CountryLeagueOptions(
                id: "2",
                icon: "international_flag_icon",
                title: "France",
                leagues: [
                    LeagueOption(id: "7", icon: nil, title: "Ligue 1", count: 20),
                    LeagueOption(id: "8", icon: nil, title: "Ligue 2", count: 18),
                    LeagueOption(id: "9", icon: nil, title: "Coupe de France", count: 12)
                ],
                isExpanded: false
            ),
            CountryLeagueOptions(
                id: "3",
                icon: "international_flag_icon",
                title: "Germany",
                leagues: [
                    LeagueOption(id: "10", icon: nil, title: "Bundesliga", count: 18),
                    LeagueOption(id: "11", icon: nil, title: "2. Bundesliga", count: 18),
                    LeagueOption(id: "12", icon: nil, title: "DFB-Pokal", count: 14)
                ],
                isExpanded: false
            ),
            CountryLeagueOptions(
                id: "4",
                icon: "international_flag_icon",
                title: "Italy",
                leagues: [
                    LeagueOption(id: "13", icon: nil, title: "Serie A", count: 20),
                    LeagueOption(id: "14", icon: nil, title: "Serie B", count: 20),
                    LeagueOption(id: "15", icon: nil, title: "Coppa Italia", count: 16)
                ],
                isExpanded: false
            ),
            CountryLeagueOptions(
                id: "5",
                icon: "international_flag_icon",
                title: "Spain",
                leagues: [
                    LeagueOption(id: "16", icon: nil, title: "La Liga", count: 20),
                    LeagueOption(id: "17", icon: nil, title: "La Liga 2", count: 22),
                    LeagueOption(id: "18", icon: nil, title: "Copa del Rey", count: 15)
                ],
                isExpanded: false
            ),
            CountryLeagueOptions(
                id: "6",
                icon: "international_flag_icon",
                title: "International",
                leagues: [
                    LeagueOption(id: "19", icon: nil, title: "Champions League", count: 32),
                    LeagueOption(id: "20", icon: nil, title: "Europa League", count: 24),
                    LeagueOption(id: "21", icon: nil, title: "Conference League", count: 18),
                    LeagueOption(id: "22", icon: nil, title: "World Cup Qualifiers", count: 28),
                    LeagueOption(id: "23", icon: nil, title: "Nations League", count: 16)
                ],
                isExpanded: false
            )
        ]
        
        popularCountryLeagues.append(contentsOf: countryLeagueOptions)
        
        // Other country leagues
        let otherCountryLeagueOptions = [
            CountryLeagueOptions(
                id: "7",
                icon: "international_flag_icon",
                title: "Portugal",
                leagues: [
                    LeagueOption(id: "24", icon: nil, title: "Primeira Liga", count: 20),
                    LeagueOption(id: "25", icon: nil, title: "Taça de Portugal", count: 16)
                ],
                isExpanded: false
            ),
            CountryLeagueOptions(
                id: "8",
                icon: "international_flag_icon",
                title: "Brazil",
                leagues: [
                    LeagueOption(id: "26", icon: nil, title: "Serie A", count: 13),
                    LeagueOption(id: "27", icon: nil, title: "Copa do Brasil", count: 12)
                ],
                isExpanded: false
            ),
            CountryLeagueOptions(
                id: "9",
                icon: "international_flag_icon",
                title: "Netherlands",
                leagues: [
                    LeagueOption(id: "28", icon: nil, title: "Eredivisie", count: 10)
                ],
                isExpanded: false
            )
        ]
        
        self.otherCountryLeagues.append(contentsOf: otherCountryLeagueOptions)
        
        // Refresh data simulating network
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.refreshLeaguesFilterData()
            self?.refreshCountryLeaguesFilterData()
            self?.isLoadingPublisher.send(false)
        }
       
    }
    
    // TEST
    public func recheckAllLeagues(){
        self.isLoadingPublisher.send(true)
        
        popularLeagues.removeAll()
        popularCountryLeagues.removeAll()
        otherCountryLeagues.removeAll()

        // Popular Leagues
        var allLeaguesOption = SortOption(id: "all", icon: "league_icon", title: "All Popular Leagues", count: 0, iconTintChange: false)
        
        let newSortOptions = [
            SortOption(id: "1", icon: "league_icon", title: "NBA", count: 25, iconTintChange: false),
            SortOption(id: "16", icon: "league_icon", title: "ACB", count: 10, iconTintChange: false),
            SortOption(id: "10", icon: "league_icon", title: "ABA League", count: 8, iconTintChange: false),
            SortOption(id: "13", icon: "league_icon", title: "La Liga", count: 13, iconTintChange: false),
            SortOption(id: "7", icon: "league_icon", title: "Serie A", count: 0, iconTintChange: false)
        ]
        
        let totalCount = newSortOptions.reduce(0) { $0 + $1.count }
        
        allLeaguesOption.count = totalCount
        
        popularLeagues.append(allLeaguesOption)
        popularLeagues.append(contentsOf: newSortOptions)
        
        // Popular Country Leagues
        
        let countryLeagueOptions = [
            CountryLeagueOptions(
                id: "1",
                icon: "international_flag_icon",
                title: "United States",
                leagues: [
                    LeagueOption(id: "1", icon: nil, title: "NBA", count: 30),
                    LeagueOption(id: "2", icon: nil, title: "WNBA", count: 12),
                    LeagueOption(id: "3", icon: nil, title: "G League", count: 28)
                ],
                isExpanded: true
            ),
            CountryLeagueOptions(
                id: "2",
                icon: "international_flag_icon",
                title: "Spain",
                leagues: [
                    LeagueOption(id: "13", icon: nil, title: "ACB", count: 18),
                    LeagueOption(id: "14", icon: nil, title: "LEB Oro", count: 18)
                ],
                isExpanded: false
            ),
            CountryLeagueOptions(
                id: "3",
                icon: "international_flag_icon",
                title: "Turkey",
                leagues: [
                    LeagueOption(id: "10", icon: nil, title: "ABA League", count: 14)
                ],
                isExpanded: false
            ),
            CountryLeagueOptions(
                id: "4",
                icon: "international_flag_icon",
                title: "International",
                leagues: [
                    LeagueOption(id: "19", icon: nil, title: "EuroLeague", count: 18),
                    LeagueOption(id: "20", icon: nil, title: "EuroCup", count: 20),
                    LeagueOption(id: "21", icon: nil, title: "FIBA World Cup", count: 32)
                ],
                isExpanded: false
            )
        ]
        
        popularCountryLeagues.append(contentsOf: countryLeagueOptions)
        
        // Other country leagues
        let otherCountryLeagueOptions = [
            CountryLeagueOptions(
                id: "7",
                icon: "international_flag_icon",
                title: "Portugal",
                leagues: [
                    LeagueOption(id: "64", icon: nil, title: "LPB 2025", count: 18)
                ],
                isExpanded: false
            ),
            CountryLeagueOptions(
                id: "9",
                icon: "international_flag_icon",
                title: "Netherlands",
                leagues: [
                    LeagueOption(id: "68", icon: nil, title: "DBL 2025", count: 10)
                ],
                isExpanded: false
            )
        ]
        
        self.otherCountryLeagues.append(contentsOf: otherCountryLeagueOptions)
        
        // Refresh data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.refreshLeaguesFilterData()
            self?.refreshCountryLeaguesFilterData()
            self?.isLoadingPublisher.send(false)
        }

    }
    
    public func refreshLeaguesFilterData() {
        if let leaguesViewModel = dynamicViewModels["leaguesFilter"] as? MockSortFilterViewModel {
            
            leaguesViewModel.updateSortOptions(popularLeagues)
        }
        
    }
    
    public func refreshCountryLeaguesFilterData() {
        if let countryLeaguesViewModel = dynamicViewModels["popularCountryLeaguesFilter"] as? MockCountryLeaguesFilterViewModel {
            
            countryLeaguesViewModel.updateCountryLeagueOptions(popularCountryLeagues)
        }
        
        if let otherCountryLeaguesViewModel = dynamicViewModels["otherCountryLeaguesFilter"] as? MockCountryLeaguesFilterViewModel {
            
            otherCountryLeaguesViewModel.updateCountryLeagueOptions(otherCountryLeagues)
        }
    }
}
