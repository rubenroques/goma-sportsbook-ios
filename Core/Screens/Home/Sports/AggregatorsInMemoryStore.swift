//
//  AggregatorsInMemoryStore.swift
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

class AggregatorsInMemoryStore {

    var matchesForType: [AggregatorListType: [String] ] = [:]

    var tournaments: [String: EveryMatrix.Tournament] = [:]
    var locations: [String: EveryMatrix.Location] = [:]
    var events: [String: Event] = [:]
    var matches: [String: EveryMatrix.Match] = [:]
    var markets: [String: EveryMatrix.Market] = [:]
    var marketsForMatch: [String: [String]] = [:]   // [Match ID: [Markets IDs] ]
    var betOutcomes: [String: EveryMatrix.BetOutcome] = [:]     // [Market: Content]
    var bettingOffers: [String: EveryMatrix.BettingOffer] = [:] // [OutcomeId: Content]

    var bettingOutcomesForMarket: [String: [String]] = [:]

    var marketOutcomeRelations: [String: EveryMatrix.MarketOutcomeRelation] = [:]
    var mainMarkets: OrderedDictionary<String, EveryMatrix.Market> = [:]

    func processAggregator(_ aggregator: EveryMatrix.Aggregator, withListType type: AggregatorListType) {

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

    func matchesForListType(_ listType: AggregatorListType) -> EveryMatrix.Matches {
        guard let matchesIds = self.matchesForType[listType] else {
            return []
        }

        let matchesList = matchesIds.map { id in
            return matches[id]
        }
        .compactMap({$0})

        return matchesList
    }

    func location(forId id: String) -> EveryMatrix.Location? {
        return self.locations[id]
    }
    
}
