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

            var similarMarketKey = "\(market.marketTypeId ?? "000")-\(match.homeParticipant.name )-\(match.awayParticipant.name)"
            
            // ==================================
            // Avoid grouping markets with this id
            // add here if we need to ungroup more ids
            let marketTypeId = market.marketTypeId ?? "000"
            if Env.businessSettingsSocket.clientSettings.ungroupedMarkets.contains(marketTypeId) {
                similarMarketKey = "\(market.id)-\(match.homeParticipant.name )-\(match.awayParticipant.name)"
            }
            
//            Previous hardcoded version
//            if market.marketTypeId ?? "000" == "1492" ||
//                market.marketTypeId ?? "000" == "1730" ||
//                market.marketTypeId ?? "000" == "1731" {
//                similarMarketKey = "\(market.id)-\(match.homeParticipant.name )-\(match.awayParticipant.name)"
//            }
            //
            // ==================================
            
            //
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
            
            let sortedOutcomeMarket = Market(id: market.id,
                                             typeId: market.typeId,
                                             name: market.name,
                                             nameDigit1: market.nameDigit1,
                                             nameDigit2: market.nameDigit2,
                                             nameDigit3: market.nameDigit3,
                                             eventPartId: market.eventPartId,
                                             bettingTypeId: market.bettingTypeId,
                                             outcomes: sortedOutcomes,
                                             outcomesOrder: market.outcomesOrder)

            allMarkets[market.id] = sortedOutcomeMarket
            similarMarketsOrdered.append(similarMarketKey)

            if var similarMarketsList = similarMarkets[similarMarketKey] {
                similarMarketsList.append(sortedOutcomeMarket)
                similarMarkets[similarMarketKey] = similarMarketsList
            }
            else {
                similarMarkets[similarMarketKey] = [sortedOutcomeMarket]
            }

            // Handicap name checked to be changed
            if sortedOutcomeMarket.name.lowercased().contains("handicap") {
                let pattern = "\\d+:\\d+"
                if let regex = try? NSRegularExpression(pattern: pattern) {

                    // Find all matches in the input string
                    let marketNameMatches = regex.matches(in: sortedOutcomeMarket.name, range: NSRange(sortedOutcomeMarket.name.startIndex..., in: sortedOutcomeMarket.name))

                    if marketNameMatches.isNotEmpty {
                        // Replace all matches with an empty string
                        let modifiedString = regex.stringByReplacingMatches(in: sortedOutcomeMarket.name,
                                                                            range: NSRange(sortedOutcomeMarket.name.startIndex...,
                                                                                           in: sortedOutcomeMarket.name),
                                                                            withTemplate: "").replacingFirstOccurrence(of: " ", with: "")

                        similarMarketsNames[similarMarketKey] = modifiedString
                    }
                    else {
                        similarMarketsNames[similarMarketKey] = sortedOutcomeMarket.name

                    }
                }
                else {
                    similarMarketsNames[similarMarketKey] = sortedOutcomeMarket.name
                }

            }
            else {
                similarMarketsNames[similarMarketKey] = sortedOutcomeMarket.name
            }
        }

        //
        var marketGroupOrganizers: [MarketGroupOrganizer] = []
        for marketKey in similarMarketsOrdered {

            if let value = similarMarkets[marketKey] {

                guard let firstMarket = value.first else { continue }

                let marketGroupName = similarMarketsNames[marketKey] ?? ""

                let allOutcomes = value.flatMap({ $0.outcomes })
                var outcomesDictionary: [String: [Outcome]] = [:]
                var orderedOutcomesDictionary: OrderedDictionary<String, [Outcome]> = [:]
                
                for outcomeIt in allOutcomes {

                    let outcomeTypeName = outcomeIt.headerCodeName
                    if var outcomesList = outcomesDictionary[outcomeTypeName] {
                        outcomesList.append(outcomeIt)
                        outcomesDictionary[outcomeTypeName] = outcomesList
                    }
                    else {
                        outcomesDictionary[outcomeTypeName] = [outcomeIt]
                    }
                    
                    if var outcomesList = orderedOutcomesDictionary[outcomeTypeName] {
                        outcomesList.append(outcomeIt)
                        orderedOutcomesDictionary[outcomeTypeName] = outcomesList
                    }
                    else {
                        orderedOutcomesDictionary[outcomeTypeName] = [outcomeIt]
                    }
                }

                let outcomesKeys = Array(outcomesDictionary.keys).map({ $0.lowercased() })
                if outcomesKeys.count > 3, outcomesKeys.contains("h") && outcomesKeys.contains("d") && outcomesKeys.contains("a") {
                    outcomesDictionary = ["all": allOutcomes] // To many headers for the columns systems
                }

                //
                // Select the correct organizer
                //
                if marketGroupName.contains("&") {
                    let simpleListGroupMarketGroupOrganizer = SimpleListGroupMarketGroupOrganizer(id: firstMarket.id,
                                                                                                  name: marketGroupName,
                                                                                                  orderedOutcomes: orderedOutcomesDictionary,
                                                                                                  unorederedOutcomes: allOutcomes)
                    marketGroupOrganizers.append(simpleListGroupMarketGroupOrganizer)
                }
                else if outcomesDictionary.keys.count == 1 && (outcomesDictionary.keys.first == "" 
                                                               || outcomesDictionary.keys.first == "exact" ||
                                                               outcomesDictionary.keys.first == "all") {

                    // Undefined markets without keys for outcomes grouping
                    let sequentialMarketGroupOrganizer = SequentialMarketGroupOrganizer(id: firstMarket.id,
                                                                                        name: marketGroupName,
                                                                                        market: firstMarket)
                    marketGroupOrganizers.append(sequentialMarketGroupOrganizer)

                }
                else if value.count == 1 && outcomesDictionary.keys.count <= 3 {

                    // One Market with multiples outcomes
                    let columnListedMarketGroupOrganizer = ColumnListedMarketGroupOrganizer(id: firstMarket.id,
                                                                                            name: marketGroupName,
                                                                                            outcomes: orderedOutcomesDictionary)

                    marketGroupOrganizers.append(columnListedMarketGroupOrganizer)

                }
                else if outcomesDictionary.keys.contains("exact") ||
                            outcomesDictionary.keys.contains("range") ||
                            outcomesDictionary.keys.contains("more_than") {

                    // Each market is a column
                    let columnListedMarketGroupOrganizer = MarketColumnsMarketGroupOrganizer(id: firstMarket.id,
                                                                                             name: marketGroupName,
                                                                                             markets: value,
                                                                                             outcomes: orderedOutcomesDictionary)

                    marketGroupOrganizers.append(columnListedMarketGroupOrganizer)
                }
                else if marketKey.hasPrefix("3-163") {
                    // over under 1.5, 2.5, 3.5, 4.5  for each team and draw
                    // 4 markets, 3 vetical groups

                    let columnListedMarketGroupOrganizer = ColumnListedMarketGroupOrganizer(id: firstMarket.id,
                                                                                            name: marketGroupName,
                                                                                            outcomes: orderedOutcomesDictionary)
                    marketGroupOrganizers.append(columnListedMarketGroupOrganizer)
                }
                else if firstMarket.outcomes.count <= 3 &&  (outcomesDictionary.keys.count == 3 || outcomesDictionary.keys.count == 2) {

                    // Groups Of Markets with 2 or three columns
                    let marketLinesMarketGroupOrganizer = MarketLinesMarketGroupOrganizer(id: firstMarket.id,
                                                                                          name: marketGroupName,
                                                                                          markets: value,
                                                                                          outcomes: orderedOutcomesDictionary)

                    marketGroupOrganizers.append(marketLinesMarketGroupOrganizer)
                }
                else if outcomesDictionary.keys.count > 3 {
                    // Grouped markets with a lot of outcomes undefined
                    let undefinedGroupMarketGroupOrganizer = UndefinedGroupMarketGroupOrganizer(id: firstMarket.id,
                                                                                                name: marketGroupName,
                                                                                                outcomes: orderedOutcomesDictionary)

                    marketGroupOrganizers.append(undefinedGroupMarketGroupOrganizer)
                }
                else if outcomesDictionary.keys.count <= 3 && firstMarket.outcomes.count > 3 {
                    // Grouped markets with unordered outcomes
                    let unorderedGroupMarketGroupOrganizer = UnorderedGroupMarketGroupOrganizer(id: firstMarket.id,
                                                                                                name: marketGroupName,
                                                                                                outcomes: orderedOutcomesDictionary)

                    marketGroupOrganizers.append(unorderedGroupMarketGroupOrganizer)
                }
                else {
                    // Fall back
                    let columnListedMarketGroupOrganizer = ColumnListedMarketGroupOrganizer(id: firstMarket.id,
                                                                                            name: marketGroupName,
                                                                                            outcomes: orderedOutcomesDictionary)
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
