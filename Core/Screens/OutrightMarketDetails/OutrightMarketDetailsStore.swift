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

    func marketGroupOrganizers(withGroupKey key: String) -> [MarketGroupOrganizer] {
        guard let marketsIds = self.marketsForGroup[key] else { return [] }

        var allMarkets: [String: Market] = [:]

        var similarMarkets: [String: [Market]] = [:]
        var similarMarketsNames: [String: String] = [:]
        var similarMarketsOrdered: OrderedSet<String> = []

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

            let similarMarketKey = "\(rawMarket.eventPartId ?? "000")-\(rawMarket.bettingTypeId ?? "000")-\(rawMarket.paramParticipantId1 ?? "x")-\(rawMarket.paramParticipantId2 ?? "x")"

            let market = Market(id: rawMarket.id,
                                typeId: rawMarket.bettingTypeId ?? "",
                                name: rawMarket.displayShortName ?? "",
                                nameDigit1: rawMarket.paramFloat1,
                                nameDigit2: rawMarket.paramFloat2,
                                nameDigit3: rawMarket.paramFloat3,
                                eventPartId: rawMarket.eventPartId,
                                bettingTypeId: rawMarket.bettingTypeId,
                                outcomes: sortedOutcomes)

            allMarkets[rawMarket.id] = market
            similarMarketsOrdered.append(similarMarketKey)

            if var similarMarketsList = similarMarkets[similarMarketKey] {
                similarMarketsList.append(market)
                similarMarkets[similarMarketKey] = similarMarketsList
            }
            else {
                similarMarkets[similarMarketKey] = [market]
            }

            similarMarketsNames[similarMarketKey] = rawMarket.displayShortName ?? ""

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

                //
                // Select the correct organizer
                //
                if outcomesDictionary.keys.count == 1 && (outcomesDictionary.keys.first == "" || outcomesDictionary.keys.first == "exact") {

                    // Undefined markets without keys for outcomes grouping
                    let sequentialMarketGroupOrganizer = SequentialMarketGroupOrganizer(id: firstMarket.id,
                                                                                        name: marketGroupName,
                                                                                        market: firstMarket,
                                                                                        sortedByOdd: true)
                    marketGroupOrganizers.append(sequentialMarketGroupOrganizer)

                }
                else if value.count == 1 {

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

            //let similarMarketKey = "\(rawMarket.eventPartId ?? "000")-\(rawMarket.bettingTypeId ?? "000")-\(rawMarket.paramParticipantId1 ?? "x")-\(rawMarket.paramParticipantId2 ?? "x")"
            let similarMarketKey = "\(market.bettingTypeId ?? "000")-\(market.typeId ?? "x")"

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
                similarMarketsList.append(market)
                similarMarkets[similarMarketKey] = similarMarketsList
            }
            else {
                similarMarkets[similarMarketKey] = [market]
            }

            similarMarketsNames[similarMarketKey] = sortedOutcomeMarket.name ?? ""

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

                //
                // Select the correct organizer
                //
                if outcomesDictionary.keys.count == 1 && (outcomesDictionary.keys.first == "" || outcomesDictionary.keys.first == "exact") {

                    // Undefined markets without keys for outcomes grouping
                    let sequentialMarketGroupOrganizer = SequentialMarketGroupOrganizer(id: firstMarket.id,
                                                                                        name: marketGroupName,
                                                                                        market: firstMarket,
                                                                                        sortedByOdd: true)
                    marketGroupOrganizers.append(sequentialMarketGroupOrganizer)

                }
                else if outcomesDictionary.keys.count > 3 && value.count >= 1 {
                    // Grouped markets with a lot of outcomes undefined
                    let undefinedGroupMarketGroupOrganizer = UndefinedGroupMarketGroupOrganizer(id: firstMarket.id, name: marketGroupName, outcomes: outcomesDictionary)

                    marketGroupOrganizers.append(undefinedGroupMarketGroupOrganizer)
                }
                else if value.count == 1 {

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


}

