//
//  MarketGroupDetailsStore.swift
//  Sportsbook
//
//  Created by Ruben Roques on 16/03/2022.
//

import Foundation
import Combine
import OrderedCollections

class MarketGroupDetailsStore {

    private var marketsForGroup: [String: OrderedSet<String>] = [:] // [Group ID: [Markets IDs] ]

    private var firstMarketCache: Market?

    func storeMarketGroupDetailsFromMatch(match: Match, onMarketGroup marketGroupKey: String) {

        for market in match.markets {

            if var marketsForIterationMatch = marketsForGroup[marketGroupKey] {
                marketsForIterationMatch.append(market.id)
                marketsForGroup[marketGroupKey] = marketsForIterationMatch
            }
            else {
                var newSet = OrderedSet<String>.init()
                newSet.append(market.id)
                marketsForGroup[marketGroupKey] = newSet
            }

        }
    }

    func storeMarketGroupDetailsFromMarkets(markets: [Market], onMarketGroup marketGroupKey: String) {

        for market in markets {

            if var marketsForIterationMatch = marketsForGroup[marketGroupKey] {
                marketsForIterationMatch.append(market.id)
                marketsForGroup[marketGroupKey] = marketsForIterationMatch
            }
            else {
                var newSet = OrderedSet<String>.init()
                newSet.append(market.id)
                marketsForGroup[marketGroupKey] = newSet
            }
            
        }
    }
    
    func marketGroupOrganizersFromFilters(withGroupKey key: String, match: Match, markets: [Market]) -> [MarketGroupOrganizer] {
        var allMarkets: [String: Market] = [:]

        var similarMarkets: [String: [Market]] = [:]
        var similarMarketsNames: [String: String] = [:]
        var similarMarketsOrdered: OrderedSet<String> = []

        for market in markets {

            let similarMarketKey = "\(market.bettingTypeId ?? "000")-\(match.homeParticipant.name ?? "x")-\(match.awayParticipant.name ?? "x")"

            if self.firstMarketCache == nil {
                self.firstMarketCache = market
            }

            let outcomes = market.outcomes

            var sortedOutcomes: [Outcome] = []

            sortedOutcomes = outcomes.sorted { out1, out2 in
                if let orderValue1 = out1.orderValue,
                   let orderValue2 = out2.orderValue {
                    let out1Value = OddOutcomesSortingHelper.sortValueForOutcome(orderValue1)
                    let out2Value = OddOutcomesSortingHelper.sortValueForOutcome(orderValue2)
                    return out1Value < out2Value
                }

                let out1Value = OddOutcomesSortingHelper.sortValueForOutcome(out1.codeName)
                let out2Value = OddOutcomesSortingHelper.sortValueForOutcome(out2.codeName)
                return out1Value < out2Value
            }
//            }

            let sortedOutcomeMarket = Market(id: market.id,
                                typeId: market.typeId,
                                name: market.name,
                                nameDigit1: market.nameDigit1,
                                nameDigit2: market.nameDigit2,
                                nameDigit3: market.nameDigit3,
                                eventPartId: market.eventPartId,
                                bettingTypeId: market.bettingTypeId,
                                outcomes: sortedOutcomes)

            allMarkets[market.id] = sortedOutcomeMarket
            similarMarketsOrdered.append(similarMarketKey)

            if var similarMarketsList = similarMarkets[similarMarketKey] {
                similarMarketsList.append(sortedOutcomeMarket)
                similarMarkets[similarMarketKey] = similarMarketsList
            }
            else {
                similarMarkets[similarMarketKey] = [sortedOutcomeMarket]
            }

            similarMarketsNames[similarMarketKey] = sortedOutcomeMarket.name
        }

        //
        var marketGroupOrganizers: [MarketGroupOrganizer] = []
        for marketKey in similarMarketsOrdered {

            if let value = similarMarkets[marketKey] {

                guard let firstMarket = value.first else { continue }

                let marketGroupName = similarMarketsNames[marketKey] ?? ""

                let allOutcomes = value.flatMap({ $0.outcomes })
                var outcomesDictionary: [String: [Outcome]] = [:]
                
                for outcomeIt in allOutcomes {

                    let outcomeTypeName = outcomeIt.headerCodeName
                    if var outcomesList = outcomesDictionary[outcomeTypeName] {
                        outcomesList.append(outcomeIt)
                        outcomesDictionary[outcomeTypeName] = outcomesList
                    }
                    else {
                        outcomesDictionary[outcomeTypeName] = [outcomeIt]
                    }
                }

                // Need to full verify if needed
//                if let drawKey = outcomesDictionary["D"],
//                   outcomesDictionary.keys.count > 3 {
//
//                    for outcome in outcomesDictionary {
//                        if outcome.key != "A" && outcome.key != "D" && outcome.key != "H" {
//                            if let outcomeSelected = outcome.value.first,
//                            var outcomesList = outcomesDictionary["D"] {
//                                outcomesList.append(outcomeSelected)
//                                outcomesDictionary["D"] = outcomesList
//                                outcomesDictionary[outcome.key] = nil
//                            }
//                        }
//                    }
//                }

                //
                // Select the correct organizer
                //
                if outcomesDictionary.keys.count == 1 && (outcomesDictionary.keys.first == "" || outcomesDictionary.keys.first == "exact") {

                    // Undefined markets without keys for outcomes grouping
                    let sequentialMarketGroupOrganizer = SequentialMarketGroupOrganizer(id: firstMarket.id,
                                                                                        name: marketGroupName,
                                                                                        market: firstMarket,
                                                                                        sortedByOdd: false)
                    marketGroupOrganizers.append(sequentialMarketGroupOrganizer)

                }
                else if value.count == 1 && outcomesDictionary.keys.count <= 3 {

                    // One Market with multiples outcomes
                    let columnListedMarketGroupOrganizer = ColumnListedMarketGroupOrganizer(id: firstMarket.id,
                                                                                            name: marketGroupName,
                                                                                            outcomes: outcomesDictionary)

                    marketGroupOrganizers.append(columnListedMarketGroupOrganizer)

                }
                else if outcomesDictionary.keys.contains("exact") ||
                            outcomesDictionary.keys.contains("range") ||
                            outcomesDictionary.keys.contains("more_than") {

                    // Each market is a column
                    let columnListedMarketGroupOrganizer = MarketColumnsMarketGroupOrganizer(id: firstMarket.id,
                                                                                             name: marketGroupName,
                                                                                             markets: value,
                                                                                             outcomes: outcomesDictionary)

                    marketGroupOrganizers.append(columnListedMarketGroupOrganizer)
                }
                else if marketKey.hasPrefix("3-163") {
                    // over under 1.5, 2.5, 3.5, 4.5  for each team and draw
                    // 4 markets, 3 vetical groups

                    let columnListedMarketGroupOrganizer = ColumnListedMarketGroupOrganizer(id: firstMarket.id,
                                                                                            name: marketGroupName,
                                                                                            outcomes: outcomesDictionary)
                    marketGroupOrganizers.append(columnListedMarketGroupOrganizer)
                }
                else if outcomesDictionary.keys.count == 3 || outcomesDictionary.keys.count == 2 {

                    // Groups Of Markets with 2 or three columns
                    let marketLinesMarketGroupOrganizer = MarketLinesMarketGroupOrganizer(id: firstMarket.id,
                                                                                          name: marketGroupName,
                                                                                          markets: value,
                                                                                          outcomes: outcomesDictionary)

                    marketGroupOrganizers.append(marketLinesMarketGroupOrganizer)
                }
                else if outcomesDictionary.keys.count > 3 {
                    // Grouped markets with a lot of outcomes undefined
                    let undefinedGroupMarketGroupOrganizer = UndefinedGroupMarketGroupOrganizer(id: firstMarket.id, name: marketGroupName, outcomes: outcomesDictionary)

                    marketGroupOrganizers.append(undefinedGroupMarketGroupOrganizer)
                }
                else {
                    // Fall back
                    let columnListedMarketGroupOrganizer = ColumnListedMarketGroupOrganizer(id: firstMarket.id,
                                                                                            name: marketGroupName,
                                                                                            outcomes: outcomesDictionary)
                    marketGroupOrganizers.append(columnListedMarketGroupOrganizer)

                }
            }
        }

        return marketGroupOrganizers
    }

    func firstMarket() -> Market? {
        return self.firstMarketCache
    }
    
}
