//
//  SearchViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 20/01/2022.
//

import Foundation
import Combine
import OrderedCollections

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
    var bettingTypeIdsSettings: [String] = ["69", "466", "112", "76", "9"]
    var eventStatuses: [Int] = [1, 2]
    var sortBy: [String] = ["START_TIME"]

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

        let searchRoute = TSRouter.searchV2(language: "en",
                                            limit: 20,
                                            query: searchQuery,
                                            eventStatuses: eventStatuses,
                                            include: includeSettings,
                                            bettingTypeIds: bettingTypeIdsSettings,
                                            sortBy: sortBy)

        Env.everyMatrixClient.manager.getModel(router: searchRoute, decodingType: SearchV2Response.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let apiError):
                    switch apiError {
                    case .requestError(let value):
                        print("Search request error: \(value)")
                    case .notConnected:
                        ()
                    default:
                        ()
                    }
                case .finished:
                    ()
                }
            },
            receiveValue: { [weak self] searchResponse in
                self?.processSearchResponse(searchResponse: searchResponse)

            })
            .store(in: &cancellables)

    }

    func processSearchResponse(searchResponse: SearchV2Response) {

        let searchRecords = searchResponse.records

        for record in searchRecords {

            switch record {
            case .tournament(let tournamentContent):

                tournaments.append(tournamentContent)

            case .match(let matchContent):

                matches.append(matchContent)
            default:
                ()
            }

        }

        if let searchContents = searchResponse.includedData {

            for searchContent in searchContents {
                switch searchContent {

                case .matchInfo(let matchInfo):

                    matchesInfo[matchInfo.id] = matchInfo
                    // Set on storage aswell for live cards
                    Env.everyMatrixStorage.matchesInfo[matchInfo.id] = matchInfo

                    if let matchId = matchInfo.matchId {
                        if var matchInfoForIterationMatch = matchesInfoForMatch[matchId] {
                            matchInfoForIterationMatch.insert(matchInfo.id)
                            matchesInfoForMatch[matchId] = matchInfoForIterationMatch
                            // Set on storage aswell for live cards
                            Env.everyMatrixStorage.matchesInfoForMatch[matchId] = matchInfoForIterationMatch
                        }
                        else {
                            var newSet = Set<String>.init()
                            newSet.insert(matchInfo.id)

                            matchesInfoForMatch[matchId] = newSet
                            // Set on storage aswell for live cards
                            Env.everyMatrixStorage.matchesInfoForMatch[matchId] = newSet

                            var matchIdArray = matchesInfoForMatchPublisher.value
                            matchIdArray.append(matchId)
                            matchesInfoForMatchPublisher.send(matchIdArray)
                            // Set on storage aswell for live cards
                            Env.everyMatrixStorage.matchesInfoForMatchPublisher.send(matchIdArray)
                        }
                    }

                case .market(let marketContent):

                    // markets[marketContent.id] = marketContent
                    marketsPublishers[marketContent.id] = CurrentValueSubject<EveryMatrix.Market, Never>.init(marketContent)

                    if let matchId = marketContent.eventId {
                        if var marketsForIterationMatch = marketsForMatch[matchId] {
                            marketsForIterationMatch.insert(marketContent.id)
                            marketsForMatch[matchId] = marketsForIterationMatch
                        }
                        else {
                            var newSet = Set<String>.init()
                            newSet.insert(marketContent.id)
                            marketsForMatch[matchId] = newSet
                        }
                    }
                case .betOutcome(let betOutcomeContent):
                    betOutcomes[betOutcomeContent.id] = betOutcomeContent

                case .bettingOffer(let bettingOfferContent):
                    if let outcomeIdValue = bettingOfferContent.outcomeId {
                        bettingOffers[outcomeIdValue] = bettingOfferContent
                    }
                    bettingOfferPublishers[bettingOfferContent.id] = CurrentValueSubject<EveryMatrix.BettingOffer, Never>.init(bettingOfferContent)

                case .mainMarket(let market):
                    mainMarkets[market.id] = market
                    mainMarketsOrder.append(market.bettingTypeId ?? "")

                case .marketOutcomeRelation(let marketOutcomeRelationContent):
                    marketOutcomeRelations[marketOutcomeRelationContent.id] = marketOutcomeRelationContent

                    if let marketId = marketOutcomeRelationContent.marketId, let outcomeId = marketOutcomeRelationContent.outcomeId {
                        if var outcomesForMatch = bettingOutcomesForMarket[marketId] {
                            outcomesForMatch.insert(outcomeId)
                            bettingOutcomesForMarket[marketId] = outcomesForMatch
                        }
                        else {
                            var newSet = Set<String>.init()
                            newSet.insert(outcomeId)
                            bettingOutcomesForMarket[marketId] = newSet
                        }
                    }
                case .marketGroup:
                    ()
                case .event:
                    ()
                case .unknown:
                    ()
                }
            }
        }

        self.processRawMatches()

    }

    func processRawMatches() {

        let rawMatchesList = self.matches

        for rawMatch in rawMatchesList {

            var matchMarkets: [Market] = []

            let marketsIds = self.marketsForMatch[rawMatch.id] ?? []
            let rawMarketsList = marketsIds.map { id in
                return self.marketsPublishers[id]?.value
            }
            .compactMap({$0})

            for rawMarket  in rawMarketsList {

                let rawOutcomeIds = self.bettingOutcomesForMarket[rawMarket.id] ?? []

                let rawOutcomesList = rawOutcomeIds.map { id in
                    return self.betOutcomes[id]
                }
                .compactMap({$0})

                var outcomes: [Outcome] = []
                for rawOutcome in rawOutcomesList {

                    if let rawBettingOffer = self.bettingOffers[rawOutcome.id] {
                        let bettingOffer = BettingOffer(id: rawBettingOffer.id,
                                                        value: rawBettingOffer.oddsValue ?? 0.0,
                                                        isLive: rawBettingOffer.isLive ?? false,
                                                        isAvailable: rawBettingOffer.isAvailable ?? true)

                        let outcome = Outcome(id: rawOutcome.id,
                                              codeName: rawOutcome.headerNameKey ?? "",
                                              typeName: rawOutcome.headerName ?? "",
                                              translatedName: rawOutcome.translatedName ?? "",
                                              nameDigit1: rawOutcome.paramFloat1,
                                              nameDigit2: rawOutcome.paramFloat2,
                                              nameDigit3: rawOutcome.paramFloat3,
                                              paramBoolean1: rawOutcome.paramBoolean1,
                                              marketName: rawMarket.shortName ?? "",
                                              marketId: rawMarket.id,
                                              bettingOffer: bettingOffer)
                        outcomes.append(outcome)
                    }
                }

                let sortedOutcomes = outcomes.sorted { out1, out2 in
                    let out1Value = OddOutcomesSortingHelper.sortValueForOutcome(out1.codeName)
                    let out2Value = OddOutcomesSortingHelper.sortValueForOutcome(out2.codeName)
                    return out1Value < out2Value
                }

                let market = Market(id: rawMarket.id,
                                    typeId: rawMarket.bettingTypeId ?? "",
                                    name: rawMarket.shortName ?? "",
                                    nameDigit1: rawMarket.paramFloat1,
                                    nameDigit2: rawMarket.paramFloat2,
                                    nameDigit3: rawMarket.paramFloat3,
                                    eventPartId: rawMarket.eventPartId,
                                    bettingTypeId: rawMarket.bettingTypeId,
                                    outcomes: sortedOutcomes)
                matchMarkets.append(market)
            }

            let sortedMarkets = matchMarkets.sorted { market1, market2 in
                let position1 = mainMarketsOrder.firstIndex(of: market1.typeId) ?? 100
                let position2 = mainMarketsOrder.firstIndex(of: market2.typeId) ?? 100
                return position1 < position2
            }

            var location: Location?
            if let rawLocation = self.location(forId: rawMatch.venueId ?? "") {
                location = Location(id: rawLocation.id, name: rawLocation.name ?? "", isoCode: rawLocation.code ?? "")
            }

            let match = Match(id: rawMatch.id,
                              competitionId: rawMatch.parentId ?? "",
                              competitionName: rawMatch.parentName ?? "",
                              homeParticipant: Participant(id: rawMatch.homeParticipantId ?? "",
                                                           name: rawMatch.homeParticipantName ?? ""),
                              awayParticipant: Participant(id: rawMatch.awayParticipantId ?? "",
                                                           name: rawMatch.awayParticipantName ?? ""),
                              date: rawMatch.startDate ?? Date(timeIntervalSince1970: 0),
                              sportType: rawMatch.sportId ?? "",
                              venue: location,
                              numberTotalOfMarkets: rawMatch.numberOfMarkets ?? 0,
                              markets: sortedMarkets,
                              rootPartId: rawMatch.rootPartId ?? "",
                              sportName: rawMatch.sportName)

            // Set Match
            if self.searchMatchesPublisher.value[match.sportType] != nil {
                let searchMatch = SearchEvent.match(match)
                self.searchMatchesPublisher.value[match.sportType]?.append(searchMatch)
            }
            else {
                let searchMatch = SearchEvent.match(match)
                self.searchMatchesPublisher.value[match.sportType] = [searchMatch]
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

    func location(forId id: String) -> EveryMatrix.Location? {
        return Env.everyMatrixStorage.locations[id]
    }

    func addRecentSearch(search: String) {
        if UserDefaults.standard.object(forKey: "recentSearches") != nil {
            if let recentSearchesArray = (UserDefaults.standard.array(forKey: "recentSearches") ?? []) as? [String] {

                var newRecentSearchesArray = Array(recentSearchesArray.reversed())

                // Max 20 recent searches
                if newRecentSearchesArray.count == 20 {
                    newRecentSearchesArray.remove(at: 0)
                }

                newRecentSearchesArray.append(search)
                let reversedNewSearchesArray = Array(newRecentSearchesArray.reversed())
                UserDefaults.standard.removeObject(forKey: "recentSearches")
                UserDefaults.standard.set(reversedNewSearchesArray, forKey: "recentSearches")
                self.recentSearchesPublisher.value = reversedNewSearchesArray
                recentSearchesPublisher.send(recentSearchesPublisher.value)

            }

        }
        else {
            self.recentSearchesPublisher.value.append(search)
            UserDefaults.standard.set(self.recentSearchesPublisher.value, forKey: "recentSearches")
            recentSearchesPublisher.send(recentSearchesPublisher.value)
        }

    }

    func setHeaderSectionTitle(section: Int) -> String {

        if self.sportMatchesArrayPublisher.value[section].matches.count > 1 {

            let resultsCountTextRaw = localized("results_count")
            let matchesCount = self.sportMatchesArrayPublisher.value[section].matches.count
            let resultsCountText = resultsCountTextRaw.replacingOccurrences(of: "%s", with: "\(matchesCount)")

            return resultsCountText
        }
        else {
            let resultsCountTextRaw = localized("results_count_singular")
            let matchesCount = self.sportMatchesArrayPublisher.value[section].matches.count
            let resultsCountText = resultsCountTextRaw.replacingOccurrences(of: "%s", with: "\(matchesCount)")

            return resultsCountText
        }
        
    }
}

struct SportMatches {
    var sportType: String
    var matches: [SearchEvent]
}

extension SearchViewModel: AggregatorStore {
    func marketPublisher(withId id: String) -> CurrentValueSubject<EveryMatrix.Market, Never>? {
        let marketPublisher = marketsPublishers[id]
        return marketPublisher
    }

    func bettingOfferPublisher(_ id: String) -> AnyPublisher<EveryMatrix.BettingOffer, Never>? {
        return bettingOfferPublishers[id]?.eraseToAnyPublisher()
    }

    func hasMatchesInfoForMatch(_ id: String) -> Bool {
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
