//
//  OutrightMarketDetailsStore.swift
//  Sportsbook
//
//  Created by Ruben Roques on 22/02/2022.
//

import Foundation
import Combine
import OrderedCollections

class OutrightMarketDetailsStore {
    
    // MARK: - Private Properties
    private var marketsPublishers: [String: CurrentValueSubject<EveryMatrix.Market, Never>] = [:]
    
    private var marketsForGroup: [String: OrderedSet<String>] = [:]   // [Group ID: [Markets IDs] ]
    private var betOutcomes: [String: EveryMatrix.BetOutcome] = [:]     // [Market: Content]
    private var bettingOffers: [String: EveryMatrix.BettingOffer] = [:] // [OutcomeId: Content]
    
    private var bettingOfferPublishers: [String: CurrentValueSubject<EveryMatrix.BettingOffer, Never>] = [:]
    private var bettingOutcomesForMarket: [String: Set<String>] = [:]
    private var marketOutcomeRelations: [String: EveryMatrix.MarketOutcomeRelation] = [:]
    
    private var markets: [Market] = []
    
    // MARK: - Lifetime and Cycle
    init() {
        
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
            self.markets.append(market)
        }
    }
    
  
    func marketGroupOrganizersFromGroups(withGroupKey key: String) -> [MarketGroupOrganizer] {
        guard let marketsIds = self.marketsForGroup[key] else { return [] }
        
        var allMarkets: [String: Market] = [:]
        
        var similarMarkets: [String: [Market]] = [:]
        var similarMarketsNames: [String: String] = [:]
        var similarMarketsOrdered: OrderedSet<String> = []
        
        let markets = self.markets
        
        for market in markets {
            
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
            
            let similarMarketKey = "\(market.bettingTypeId ?? "000")-\(market.typeId)"
            
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
                similarMarketsList.append(market)
                similarMarkets[similarMarketKey] = similarMarketsList
            }
            else {
                similarMarkets[similarMarketKey] = [market]
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
                    outcomesDictionary = ["all": allOutcomes]
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
                                                          || outcomesDictionary.keys.first == "exact"
                                                          || outcomesDictionary.keys.first == "all") {
                    
                    // Undefined markets without keys for outcomes grouping
                    let sequentialMarketGroupOrganizer = SequentialMarketGroupOrganizer(id: firstMarket.id,
                                                                                        name: marketGroupName,
                                                                                        market: firstMarket)
                    marketGroupOrganizers.append(sequentialMarketGroupOrganizer)
                    
                }
                else if outcomesDictionary.keys.count > 3 && value.count >= 1 {
                    // Grouped markets with a lot of outcomes undefined
                    let undefinedGroupMarketGroupOrganizer = UndefinedGroupMarketGroupOrganizer(id: firstMarket.id,
                                                                                                name: marketGroupName,
                                                                                                outcomes: orderedOutcomesDictionary)
                    
                    marketGroupOrganizers.append(undefinedGroupMarketGroupOrganizer)
                }
                else if value.count == 1 {
                    
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
                else if outcomesDictionary.keys.count == 3 || outcomesDictionary.keys.count == 2 {
                    
                    // Groups Of Markets with 2 or three columns
                    let marketLinesMarketGroupOrganizer = MarketLinesMarketGroupOrganizer(id: firstMarket.id,
                                                                                          name: marketGroupName,
                                                                                          markets: value,
                                                                                          outcomes: orderedOutcomesDictionary)
                    
                    marketGroupOrganizers.append(marketLinesMarketGroupOrganizer)
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
    
    
}

