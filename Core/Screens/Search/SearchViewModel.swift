//
//  SearchViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 20/01/2022.
//

import Foundation
import Combine
import OrderedCollections
import ServicesProvider

class SearchViewModel: NSObject {

    var recentSearchesPublisher: CurrentValueSubject<[String], Never> = .init([])
    var searchMatchesPublisher: CurrentValueSubject<[String: [SearchEvent]], Never> = .init([:])
    var sportMatchesArrayPublisher: CurrentValueSubject<[SportMatches], Never> = .init([])

    var cancellables = Set<AnyCancellable>()

    var hasDoneSearch: Bool = false
    var isEmptySearch: Bool = true

    // Processed match info variables
    var matches: [EveryMatrix.Match] = []
    var tournaments: [EveryMatrix.Tournament] = []
    var matchesInfo: [String: EveryMatrix.MatchInfo] = [:]
    var matchesInfoForMatch: [String: Set<String> ] = [:]
    var matchesInfoForMatchPublisher: CurrentValueSubject<[String], Never> = .init([])
    var marketsForMatch: [String: Set<String>] = [:]
    var marketOutcomeRelations: [String: EveryMatrix.MarketOutcomeRelation] = [:]
    var betOutcomes: [String: EveryMatrix.BetOutcome] = [:]
    var bettingOffers: [String: EveryMatrix.BettingOffer] = [:]
    var marketsPublishers: [String: CurrentValueSubject<EveryMatrix.Market, Never>] = [:]
    var bettingOfferPublishers: [String: CurrentValueSubject<EveryMatrix.BettingOffer, Never>] = [:]
    var bettingOutcomesForMarket: [String: Set<String>] = [:]
    var mainMarkets: OrderedDictionary<String, EveryMatrix.Market> = [:]
    var mainMarketsOrder: OrderedSet<String> = []

    var includeSettings: [String] = ["BETTING_OFFERS", "EVENT_INFO"]
    var bettingTypeIdsSettings: [Int] = [69, 466, 112, 76, 9]
    var eventStatuses: [Int] = [1, 2]

    private var cachedMatchStatsViewModels: [String: MatchStatsViewModel] = [:]

    var isLiveSearch: Bool = false

    override init() {
        super.init()

        self.getRecentSearches()
    }

    func getRecentSearches() {
        if UserDefaults.standard.object(forKey: "recentSearches") != nil {

            if let recentSearchesArray = (UserDefaults.standard.array(forKey: "recentSearches") ?? []) as? [String] {

                self.recentSearchesPublisher.value = recentSearchesArray
                self.recentSearchesPublisher.send(recentSearchesArray)
            }

        }

    }

    func clearRecentSearchData() {
        if UserDefaults.standard.object(forKey: "recentSearches") != nil {

            UserDefaults.standard.removeObject(forKey: "recentSearches")
            self.recentSearchesPublisher.value = []
            self.recentSearchesPublisher.send( self.recentSearchesPublisher.value)
        }
    }

    func clearRecentSearchByString(search: String) {
        if UserDefaults.standard.object(forKey: "recentSearches") != nil {

            if let recentSearchesArray = (UserDefaults.standard.array(forKey: "recentSearches") ?? []) as? [String] {

                let filteredRecentSearchesArray = recentSearchesArray.filter { $0 != search }

                UserDefaults.standard.removeObject(forKey: "recentSearches")
                UserDefaults.standard.set(filteredRecentSearchesArray, forKey: "recentSearches")

                self.recentSearchesPublisher.send(filteredRecentSearchesArray)

            }

        }
    }

    func markAsFavorite(match : Match){
        var isFavorite = false
        for matchId in Env.favoritesManager.favoriteEventsIdPublisher.value where matchId == match.id {
            isFavorite = true
        }

        if isFavorite {
            Env.favoritesManager.removeFavorite(eventId: match.id, favoriteType: .match)
        }
        else {
            Env.favoritesManager.addFavorite(eventId: match.id, favoriteType: .match)
        }
    }

    func clearData() {
        self.hasDoneSearch = false

        self.searchMatchesPublisher.value = [:]
        self.sportMatchesArrayPublisher.value = []
        self.matches = []
        self.tournaments = []
        self.matchesInfo = [:]
        self.matchesInfoForMatch = [:]
        self.matchesInfoForMatchPublisher.value = []
        self.marketsForMatch = [:]
        self.marketOutcomeRelations = [:]
        self.betOutcomes = [:]
        self.bettingOffers = [:]
        self.marketsPublishers = [:]
        self.bettingOfferPublishers = [:]
        self.bettingOutcomesForMarket = [:]
        self.mainMarkets = [:]
        self.mainMarketsOrder = []
    }

    func fetchSearchInfo(searchQuery: String) {

        self.clearData()
        self.isEmptySearch = false

        Env.servicesProvider.getSearchEvents(query: searchQuery, resultLimit: "20", page: "0", isLive: self.isLiveSearch)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("SEARCH ERROR: \(error)")
                    self?.searchMatchesPublisher.send([:])
                    self?.hasDoneSearch = true
                }

            }, receiveValue: { [weak self] eventsGroup in

                self?.processEvents(eventsGroup: eventsGroup)
            })
            .store(in: &cancellables)

    }

    func processEvents(eventsGroup: EventsGroup) {
        
        for event in eventsGroup.events {

            let match = ServiceProviderModelMapper.match(fromEvent: event)

            if self.searchMatchesPublisher.value[match.sport.name] != nil {
                let searchMatch = SearchEvent.match(match)
                self.searchMatchesPublisher.value[match.sport.name]?.append(searchMatch)
            }
            else {
                let searchMatch = SearchEvent.match(match)
                self.searchMatchesPublisher.value[match.sport.name] = [searchMatch]
            }
        }

        self.setSportMatchesArray()
    }


    func setSportMatchesArray() {

        // Set Competitions
        for competition in self.tournaments {

            if let sportId = competition.sportId {

                if self.searchMatchesPublisher.value[sportId] != nil {
                    let searchCompetition = SearchEvent.competition(competition)
                    self.searchMatchesPublisher.value[sportId]?.append(searchCompetition)
                }
                else {
                    let searchCompetition = SearchEvent.competition(competition)
                    self.searchMatchesPublisher.value[sportId] = [searchCompetition]
                }
            }

        }

        for (key, event) in searchMatchesPublisher.value {
                let sportMatch = SportMatches(sportType: key, matches: event)
                sportMatchesArrayPublisher.value.append(sportMatch)
        }

        // Sort by sportId
        let sportMatchesSorted = sportMatchesArrayPublisher.value.sorted {
            $0.sportType < $1.sportType
        }
        sportMatchesArrayPublisher.value = sportMatchesSorted

        self.searchMatchesPublisher.send(self.searchMatchesPublisher.value)
        self.hasDoneSearch = true
    }

    func matchStatsViewModel(forMatch match: Match) -> MatchStatsViewModel {
        if let viewModel = cachedMatchStatsViewModels[match.id] {
            return viewModel
        }
        else {
            let viewModel = MatchStatsViewModel(match: match)
            cachedMatchStatsViewModels[match.id] = viewModel
            return viewModel
        }
    }

    func addRecentSearch(search: String) {
        if UserDefaults.standard.object(forKey: "recentSearches") != nil {
            if let recentSearchesArray = (UserDefaults.standard.array(forKey: "recentSearches") ?? []) as? [String] {

                var newRecentSearchesArray = Array(recentSearchesArray.reversed())

                // Max 20 recent searches
                if newRecentSearchesArray.count == 20 {
                    newRecentSearchesArray.remove(at: 0)
                }

                if !newRecentSearchesArray.contains(search) {

                    newRecentSearchesArray.append(search)
                    let reversedNewSearchesArray = Array(newRecentSearchesArray.reversed())
                    UserDefaults.standard.removeObject(forKey: "recentSearches")
                    UserDefaults.standard.set(reversedNewSearchesArray, forKey: "recentSearches")
                    self.recentSearchesPublisher.value = reversedNewSearchesArray
                    recentSearchesPublisher.send(recentSearchesPublisher.value)
                }
            }

        }
        else {
            self.recentSearchesPublisher.value.append(search)
            UserDefaults.standard.set(self.recentSearchesPublisher.value, forKey: "recentSearches")
            recentSearchesPublisher.send(recentSearchesPublisher.value)
        }

    }

    func setHeaderSectionTitle(section: Int) -> String {

        if let matches = self.sportMatchesArrayPublisher.value[safe: section]?.matches {
            
            if matches.count > 1 {
                
                let resultsCountTextRaw = localized("results_count")
                let matchesCount = matches.count
                let resultsCountText = resultsCountTextRaw.replacingOccurrences(of: "{num}", with: "\(matchesCount)")
                
                return resultsCountText
            }
            
            let resultsCountTextRaw = localized("results_count_singular")
            let matchesCount = matches.count
            let resultsCountText = resultsCountTextRaw.replacingOccurrences(of: "{num}", with: "\(matchesCount)")

            return resultsCountText
        }
        
        return ""

    }
}

struct SportMatches {
    var sportType: String
    var matches: [SearchEvent]
}

extension SearchViewModel: AggregatorStore {

    func marketPublisher(withId id: String) -> AnyPublisher<EveryMatrix.Market, Never>? {
        return marketsPublishers[id]?.eraseToAnyPublisher()
    }

    func bettingOfferPublisher(withId id: String) -> AnyPublisher<EveryMatrix.BettingOffer, Never>? {
        return bettingOfferPublishers[id]?.eraseToAnyPublisher()
    }

    func hasMatchesInfoForMatch(withId id: String) -> Bool {
        if matchesInfoForMatchPublisher.value.contains(id) {
            return true
        }

        return false
    }

    func matchesInfoForMatchListPublisher() -> CurrentValueSubject<[String], Never>? {
        let matchesInfoForMatchPublisher = matchesInfoForMatchPublisher
        return matchesInfoForMatchPublisher
    }

    func matchesInfoForMatchList() -> [String: Set<String> ] {
        let matchesInfoForMatch = matchesInfoForMatch
        return matchesInfoForMatch
    }

    func matchesInfoList() -> [String: EveryMatrix.MatchInfo] {
        let matchesInfo = matchesInfo
        return matchesInfo
    }
}

