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
}

class AggregatorsRepository {

    var matchesForType: [AggregatorListType: [String] ] = [:]

    var events: [String: Event] = [:]
    var matches: [String: EveryMatrix.Match] = [:]
    var markets: [String: EveryMatrix.Market] = [:]
    var marketsForMatch: [String: [String]] = [:]   // [Match ID: [Markets IDs] ]
    var betOutcomes: [String: EveryMatrix.BetOutcome] = [:]     // [Market: Content]
    var bettingOffers: [String: EveryMatrix.BettingOffer] = [:] // [OutcomeId: Content]

    var bettingOutcomesForMarket: [String: [String]] = [:]

    var marketOutcomeRelations: [String: EveryMatrix.MarketOutcomeRelation] = [:]
    var mainMarkets: OrderedDictionary<String, EveryMatrix.Market> = [:]
    var mainMarketsOrder: OrderedSet<String> = []

    var locations: OrderedDictionary<String, EveryMatrix.Location> = [:]
    var tournamentsForLocation: [String: [String] ] = [:]

    var tournaments: [String: EveryMatrix.Tournament] = [:]
    var popularTournaments: OrderedDictionary<String, EveryMatrix.Tournament> = [:]

    
    func processAggregator(_ aggregator: EveryMatrix.Aggregator, withListType type: AggregatorListType, shouldClear: Bool = false) {

        if shouldClear {
            self.matchesForType = [:]
        }

        for content in aggregator.content {
            switch content {
            case .tournament(let tournamentContent):
                tournaments[tournamentContent.id] = tournamentContent

            case .match(let matchContent):

                if var marketsForIterationMatch = matchesForType[type] {
                    marketsForIterationMatch.append(matchContent.id)
                    matchesForType[type] = marketsForIterationMatch
                }
                else {
                    matchesForType[type] = [matchContent.id]
                }

                matches[matchContent.id] = matchContent

            case .market(let marketContent):
                markets[marketContent.id] = marketContent
                if let matchId = marketContent.eventId {
                    if var marketsForIterationMatch = marketsForMatch[matchId] {
                        marketsForIterationMatch.append(marketContent.id)
                        marketsForMatch[matchId] = marketsForIterationMatch
                    }
                    else {
                        marketsForMatch[matchId] = [marketContent.id]
                    }
                }
            case .betOutcome(let betOutcomeContent):
                betOutcomes[betOutcomeContent.id] = betOutcomeContent
            case .bettingOffer(let bettingOfferContent):
                if let outcomeIdValue = bettingOfferContent.outcomeId {
                    bettingOffers[outcomeIdValue] = bettingOfferContent
                }

            case .mainMarket(let market):
                mainMarkets[market.id] = market
                mainMarketsOrder.append(market.bettingTypeId ?? "")

            case .marketOutcomeRelation(let marketOutcomeRelationContent):
                marketOutcomeRelations[marketOutcomeRelationContent.id] = marketOutcomeRelationContent

                if let marketId = marketOutcomeRelationContent.marketId, let outcomeId = marketOutcomeRelationContent.outcomeId {
                    if var outcomesForMatch = bettingOutcomesForMarket[marketId] {
                        outcomesForMatch.append(outcomeId)
                        bettingOutcomesForMarket[marketId] = outcomesForMatch
                    }
                    else {
                        bettingOutcomesForMarket[marketId] = [outcomeId]
                    }
                }

            case .location(let location):
                self.locations[location.id] = location
                
            case .event:
                () //print("Events aren't processed")
            case .unknown:
                () //print("Unknown type ignored")
            }
        }
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
                return self.markets[id]
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
                                                        value: rawBettingOffer.oddsValue ?? 0.0)

                        let outcome = Outcome(id: rawOutcome.id,
                                              codeName: rawOutcome.headerNameKey ?? "",
                                              translatedName: rawOutcome.headerName ?? "",
                                              nameDigit1: rawOutcome.paramFloat1,
                                              nameDigit2: rawOutcome.paramFloat2,
                                              nameDigit3: rawOutcome.paramFloat3,
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
                              markets: sortedMarkets)

            matchesList.append(match)
        }

        return matchesList
    }


    func location(forId id: String) -> EveryMatrix.Location? {
        return self.locations[id]
    }

    func storeLocations(locations: [EveryMatrix.Location]) {
        for location in locations {
            self.locations[location.id] = location
        }
    }

    func storeTournaments(tournaments: [EveryMatrix.Tournament]) {
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
        }
    }

    func storePopularTournaments(tournaments: [EveryMatrix.Tournament]) {
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
        case "away": return 30

        case "home_draw": return 10
        case "home_away": return 20
        case "away_draw": return 30

        case "under": return 10
        case "over": return 20

        default:
            return 1000
        }
    }

}
