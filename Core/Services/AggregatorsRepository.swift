//
//  AggregatorsRepository.swift
//  Sportsbook
//
//  Created by Ruben Roques on 08/10/2021.
//

import Foundation
import Combine
import OrderedCollections

enum AggregatorListType {
    case popularEvents
    case todayEvents
    case competitions
    case allLiveEvents
    case favoriteMatchEvents
    case favoriteCompetitionEvents
    case cashouts
    case matchDetails
    case suggestedMatches
}

class AggregatorsRepository {

    var matchesForType: [AggregatorListType: [String] ] = [:]

    var matches: [String: EveryMatrix.Match] = [:]
    // var markets: [String: EveryMatrix.Market] = [:]
    var marketsForMatch: [String: Set<String>] = [:]   // [Match ID: [Markets IDs] ]
    var betOutcomes: [String: EveryMatrix.BetOutcome] = [:]     // [Market: Content]
    var bettingOffers: [String: EveryMatrix.BettingOffer] = [:] // [OutcomeId: Content]

    var marketsPublishers: [String: CurrentValueSubject<EveryMatrix.Market, Never>] = [:]
    var bettingOfferPublishers: [String: CurrentValueSubject<EveryMatrix.BettingOffer, Never>] = [:]

    var bettingOutcomesForMarket: [String: Set<String>] = [:]

    var cashoutsPublisher: [String: CurrentValueSubject<EveryMatrix.Cashout, Never>] = [:]

    var marketOutcomeRelations: [String: EveryMatrix.MarketOutcomeRelation] = [:]
    var mainMarkets: OrderedDictionary<String, EveryMatrix.Market> = [:]
    var mainMarketsOrder: OrderedSet<String> = []

    var locations: OrderedDictionary<String, EveryMatrix.Location> = [:]
    var cashouts: OrderedDictionary<String, EveryMatrix.Cashout> = [:]
    var tournamentsForLocation: [String: [String] ] = [:]
    var tournamentsForCategory: [String: [String] ] = [:]

    var tournaments: [String: EveryMatrix.Tournament] = [:]
    var popularTournaments: OrderedDictionary<String, EveryMatrix.Tournament> = [:]

    var outrightTournaments: OrderedDictionary<String, EveryMatrix.Tournament> = [:]

    var matchesInfo: [String: EveryMatrix.MatchInfo] = [:]
    var matchesInfoForMatch: [String: Set<String> ] = [:]
    var matchesInfoForMatchPublisher: CurrentValueSubject<[String], Never> = .init([])

    func processAggregator(_ aggregator: EveryMatrix.Aggregator, withListType type: AggregatorListType, shouldClear: Bool = false) {

        if shouldClear {
            self.matchesForType = [:]
            self.mainMarkets = [:]
            self.mainMarketsOrder = []
        }

        for content in aggregator.content ?? [] {
            switch content {
            case .tournament(let tournamentContent):
                tournaments[tournamentContent.id] = tournamentContent

            case .match(let matchContent):

                matches[matchContent.id] = matchContent

                if var marketsForIterationMatch = matchesForType[type] {
                    marketsForIterationMatch.append(matchContent.id)
                    matchesForType[type] = marketsForIterationMatch
                }
                else {
                    matchesForType[type] = [matchContent.id]
                }

            case .matchInfo(let matchInfo):
                matchesInfo[matchInfo.id] = matchInfo

                if let matchId = matchInfo.matchId {
                    if var matchInfoForIterationMatch = matchesInfoForMatch[matchId] {
                        matchInfoForIterationMatch.insert(matchInfo.id)
                        matchesInfoForMatch[matchId] = matchInfoForIterationMatch
                    }
                    else {
                        var newSet = Set<String>.init()
                        newSet.insert(matchInfo.id)
                        matchesInfoForMatch[matchId] = newSet
                        var matchIdArray = matchesInfoForMatchPublisher.value
                        matchIdArray.append(matchId)
                        matchesInfoForMatchPublisher.send(matchIdArray)
                    }
                }

            case .market(let marketContent):
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
                
            case .location(let location):
                self.locations[location.id] = location

            case .cashout:
                ()
            case .event:
                ()
            case .eventPartScore:
                ()
            case .unknown:
                ()
            }
        }

        print("Finished dump processing")
    }

    func processOutrightTournamentsAggregator(_ aggregator: EveryMatrix.Aggregator) {

        self.outrightTournaments = [:]

        for content in aggregator.content ?? [] {
            switch content {
            case .tournament(let tournamentContent):
                outrightTournaments[tournamentContent.id] = tournamentContent
            default:
                ()
            }
        }
    }

    func processContentUpdateAggregator(_ aggregator: EveryMatrix.Aggregator) {

        guard
            let contentUpdates = aggregator.contentUpdates
        else {
            return
        }

        for update in contentUpdates {
            switch update {
            case .bettingOfferUpdate(let id, let statusId, let odd, let isLive, let isAvailable):
                if let publisher = bettingOfferPublishers[id] {
                    let bettingOffer = publisher.value
                    let updatedBettingOffer = bettingOffer.bettingOfferUpdated(withOdd: odd,
                                                                               statusId: statusId,
                                                                               isLive: isLive,
                                                                               isAvailable: isAvailable)
                    publisher.send(updatedBettingOffer)
                }
            case .marketUpdate(let id, let isAvailable, let isClosed):
                if let marketPublisher = marketsPublishers[id] {
                    let market = marketPublisher.value
                    let updatedMarket = market.martketUpdated(withAvailability: isAvailable, isCLosed: isClosed)
                    marketPublisher.send(updatedMarket)
                }
            case .matchInfo(let id, let paramFloat1, let paramFloat2, let paramEventPartName1):
                for matchInfoForMatch in matchesInfoForMatch {
                    for matchInfoId in matchInfoForMatch.value {
                        if let matchInfo = matchesInfo[id] {
                            matchesInfo[id] = matchInfo.matchInfoUpdated(paramFloat1: paramFloat1,
                                                                         paramFloat2: paramFloat2,
                                                                         paramEventPartName1: paramEventPartName1)
                        }
                    }
                }
            case .fullMatchInfoUpdate(let matchInfo):
                matchesInfo[matchInfo.id] = matchInfo

                if let matchId = matchInfo.matchId {
                    if var matchInfoForIterationMatch = matchesInfoForMatch[matchId] {
                        matchInfoForIterationMatch.insert(matchInfo.id)
                        matchesInfoForMatch[matchId] = matchInfoForIterationMatch
                    }
                    else {
                        var newSet = Set<String>.init()
                        newSet.insert(matchInfo.id)
                        matchesInfoForMatch[matchId] = newSet
                    }
                    var matchIdArray = matchesInfoForMatchPublisher.value
                    matchIdArray.append(matchId)
                    matchesInfoForMatchPublisher.send(matchIdArray)
                }
            case .cashoutUpdate:
                ()
            case .cashoutCreate:
                ()
            case .cashoutDelete:
                ()
            case .unknown:
                print("uknown")
            }
        }
    }

    func oddPublisherForBettingOfferId(_ id: String) -> AnyPublisher<EveryMatrix.BettingOffer, Never>? {
        return bettingOfferPublishers[id]?.eraseToAnyPublisher()
    }

    func rawMatchesForListType(_ listType: AggregatorListType) -> EveryMatrix.Matches {
        guard let matchesIds = self.matchesForType[listType] else {
            return []
        }

        let matchesList = matchesIds.map { id in
            return matches[id]
        }
        .compactMap({$0})

        return matchesList
    }

    func matchesForListType(_ listType: AggregatorListType) -> [Match] {

        guard let matchesIds = self.matchesForType[listType] else {
            return []
        }

        let rawMatchesList = matchesIds.map { id in
            return matches[id]
        }
        .compactMap({$0})

        var matchesList: [Match] = []

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
                                                        decimalOdd: rawBettingOffer.oddsValue ?? 0.0,
                                                        statusId: rawBettingOffer.statusId ?? "1",
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
                let position1 = mainMarketsOrder.firstIndex(of: market1.typeId) ?? 10000
                let position2 = mainMarketsOrder.firstIndex(of: market2.typeId) ?? 10000
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
                              sportCode: rawMatch.shortSportName ?? "",
                              venue: location,
                              numberTotalOfMarkets: rawMatch.numberOfMarkets ?? 0,
                              markets: sortedMarkets,
                              rootPartId: rawMatch.rootPartId ?? "",
                              status: .unknown)

            matchesList.append(match)
        }

        return matchesList
    }

    func location(forId id: String) -> EveryMatrix.Location? {
        return self.locations[id]
    }

    func storeLocations(locations: [EveryMatrix.Location]) {
        self.locations = [:]
        for location in locations {
            self.locations[location.id] = location
        }
    }

    func storeTournaments(tournaments: [EveryMatrix.Tournament]) {
        self.tournaments = [:]
        for tournament in tournaments {
            self.tournaments[tournament.id] = tournament

            if let venueId = tournament.venueId {
                if var tournamentsForLocationWithId = self.tournamentsForLocation[venueId] {
                    tournamentsForLocationWithId.append(tournament.id)
                    self.tournamentsForLocation[venueId] = tournamentsForLocationWithId
                }
                else {
                    self.tournamentsForLocation[venueId] = [tournament.id]
                }
            }

            if let categoryId = tournament.categoryId {
                if var tournamentsForCategoryWithId = self.tournamentsForCategory[categoryId] {
                    tournamentsForCategoryWithId.append(tournament.id)
                    self.tournamentsForCategory[categoryId] = tournamentsForCategoryWithId
                }
                else {
                    self.tournamentsForCategory[categoryId] = [tournament.id]
                }
            }
        }
    }

    func storePopularTournaments(tournaments: [EveryMatrix.Tournament]) {
        self.popularTournaments = [:]
        for tournament in tournaments {
            self.popularTournaments[tournament.id] = tournament
        }
    }


    
}

struct OddOutcomesSortingHelper {

    static func sortValueForOutcome(_ key: String) -> Int {
        switch key.lowercased() {
        case "yes": return 10
        case "no": return 20

        case "home": return 10
        case "draw": return 20
        case "none": return 21
        case "": return 22
        case "away": return 30

        case "home_draw": return 10
        case "home_away": return 20
        case "away_draw": return 30

        case "over": return 10
        case "under": return 20

        case "odd": return 10
        case "even": return 20

        case "exact": return 10
        case "range": return 20
        case "more_than": return 30

        case "in_90_minutes": return 10
        case "in_extra_time": return 20
        case "on_penalties": return 30

        case "home-true": return 10
        case "home-false": return 15
        case "-true": return 20
        case "-false": return 25
        case "away-true": return 30
        case "away-false": return 35

        case "home_draw-true": return 10
        case "home_draw-false": return 15
        case "home_away-true": return 20
        case "home_away-false": return 25
        case "away_draw-true": return 30
        case "away_draw-false": return 35

        case "over-true": return 10
        case "over-false": return 15
        case "under-true": return 20
        case "under-false": return 25

        case "odd-true": return 10
        case "odd-false": return 15
        case "even-true": return 20
        case "even-false": return 25

        case "yes-true": return 10
        case "yes-false": return 15
        case "no-true": return 20
        case "no-false": return 25

        case "true": return 10
        case "false": return 20

        case "h": return 10
        case "d": return 20
        case "a": return 30

        default:
            return 1000
        }
    }

}

extension AggregatorsRepository: AggregatorStore {

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
