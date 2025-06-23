//
//  CombinedFiltersViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 23/06/2025.
//

import Foundation
import Combine
import GomaUI
import ServicesProvider

public class CombinedFiltersViewModel {
    
    var popularLeagues = [SortOption]()
    var popularCountryLeagues = [CountryLeagueOptions]()
    var otherCountryLeagues = [CountryLeagueOptions]()
    
    var generalFilterSelection: GeneralFilterSelection
    
    var filterConfiguration: FilterConfiguration
    var currentContextId: String
    
    var dynamicViewModels: [String: Any] = [:]
    
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    
    private var cancellables = Set<AnyCancellable>()
    
    init(filterConfiguration: FilterConfiguration,
         contextId: String = "sports") {
        
        self.generalFilterSelection = Env.filterStorage.currentFilterSelection
        self.filterConfiguration = filterConfiguration
        self.currentContextId = contextId
        
        createDynamicViewModels(for: filterConfiguration, contextId: currentContextId)

        self.getAllLeagues()
        
    }
    
    func getAllLeagues(sportId: String? = nil) {
        self.isLoadingPublisher.send(true)
        
        var currentSportId = Env.filterStorage.currentFilterSelection.sportId
        
        if let sportId {
            currentSportId = sportId
        }
        
        let currentSport = Env.sportsStore.getActiveSports().first(where: {
            $0.id == currentSportId
        })
        
        var sportType = SportType(name: currentSport?.name ?? "",
                                  numericId: currentSport?.numericId ?? "",
                                  alphaId: currentSport?.alphaId ?? "", iconId: currentSport?.id ?? "",
                                  showEventCategory: false,
                                  numberEvents: 0,
                                  numberOutrightEvents: 0,
                                  numberOutrightMarkets: 0,
                                  numberLiveEvents: 0)
        
        let sportTournamentsPublisher = Env.servicesProvider.subscribeSportTournaments(forSportType: sportType)
            .filter { content in
                if case .contentUpdate = content { return true }
                return false
            }
            .map { content -> [Competition] in
                if case .contentUpdate(let tournaments) = content {
                    return ServiceProviderModelMapper.competitions(fromTournaments: tournaments)
                }
                return []
            }
            .prefix(1) // Only take the first .contentUpdate

        let popularTournamentsPublisher = Env.servicesProvider.subscribePopularTournaments(forSportType: sportType, tournamentsCount: 10)
            .filter { content in
                if case .contentUpdate = content { return true }
                return false
            }
            .map { content -> [Competition] in
                if case .contentUpdate(let tournaments) = content {
                    return ServiceProviderModelMapper.competitions(fromTournaments: tournaments)
                }
                return []
            }
            .prefix(1) // Only take the first .contentUpdate

        Publishers.Zip(sportTournamentsPublisher, popularTournamentsPublisher)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("All tournaments subscriptions completed")
                    case .failure(let error):
                        print("Tournaments subscriptions failed: \(error)")
                    }
                },
                receiveValue: { [weak self] sportCompetitions, popularCompetitions in
                    
                    self?.setupAllLeagues(popularCompetitions: popularCompetitions, sportCompetitions: sportCompetitions)
                }
            )
            .store(in: &cancellables)
    }
    
    func setupAllLeagues(popularCompetitions: [Competition], sportCompetitions: [Competition]) {
        isLoadingPublisher.send(true)
        
        popularLeagues.removeAll()
        popularCountryLeagues.removeAll()
        otherCountryLeagues.removeAll()

        // Popular Leagues
        var allLeaguesOption = SortOption(id: "all", icon: "league_icon", title: "All Popular Leagues", count: 0, iconTintChange: false)
        
        // Convert competitions to SortOptions
        let newSortOptions = popularCompetitions.map { competition in
            SortOption(
                id: competition.id,
                icon: "league_icon",
                title: competition.name,
                count: competition.numberEvents ?? 0,
                iconTintChange: false
            )
        }
        
        let totalCount = newSortOptions.reduce(0) { $0 + $1.count }
        
        allLeaguesOption.count = totalCount
        
        popularLeagues.append(allLeaguesOption)
        popularLeagues.append(contentsOf: newSortOptions)
        
        // Popular and Other Country Leagues
        let popularVenueIds: Set<String> = Set(popularCompetitions.compactMap { $0.venue?.id })

        var venueDict: [String: (venueName: String, leagues: [LeagueOption])] = [:]
        
        for competition in sportCompetitions {
            let venueId = competition.venue?.id ?? ""
            let venueName = competition.venue?.name ?? ""
            let league = LeagueOption(
                id: competition.id,
                icon: nil,
                title: competition.name,
                count: competition.numberEvents ?? 0
            )
            if var entry = venueDict[venueId] {
                entry.leagues.append(league)
                venueDict[venueId] = (venueName: entry.venueName, leagues: entry.leagues)
            } else {
                venueDict[venueId] = (venueName: venueName, leagues: [league])
            }
        }

        var popularCountryLeaguesArr: [CountryLeagueOptions] = []
        var otherCountryLeaguesArr: [CountryLeagueOptions] = []

        for (index, (venueId, value)) in venueDict.enumerated() {
            let countryLeague = CountryLeagueOptions(
                id: venueId,
                icon: venueId,
                title: value.venueName,
                leagues: value.leagues,
                isExpanded: index == 0
            )
            if popularVenueIds.contains(venueId) {
                popularCountryLeaguesArr.append(countryLeague)
            } else {
                otherCountryLeaguesArr.append(countryLeague)
            }
        }

        popularCountryLeagues.append(contentsOf: popularCountryLeaguesArr)
        otherCountryLeagues.append(contentsOf: otherCountryLeaguesArr)
        
        // Sort both arrays alphabetically by title
        popularCountryLeagues.sort { $0.title < $1.title }
        otherCountryLeagues.sort { $0.title < $1.title }
        
        self.refreshLeaguesFilterData()
        self.refreshCountryLeaguesFilterData()
        self.isLoadingPublisher.send(false)
       
    }
    
    private func refreshLeaguesFilterData() {
        if let leaguesViewModel = dynamicViewModels["leaguesFilter"] as? MockSortFilterViewModel {
            
            leaguesViewModel.updateSortOptions(popularLeagues)
        }
        
    }
    
    private func refreshCountryLeaguesFilterData() {
        if let countryLeaguesViewModel = dynamicViewModels["popularCountryLeaguesFilter"] as? MockCountryLeaguesFilterViewModel {
            
            countryLeaguesViewModel.updateCountryLeagueOptions(popularCountryLeagues)
        }
        
        if let otherCountryLeaguesViewModel = dynamicViewModels["otherCountryLeaguesFilter"] as? MockCountryLeaguesFilterViewModel {
            
            otherCountryLeaguesViewModel.updateCountryLeagueOptions(otherCountryLeagues)
        }
    }
}
