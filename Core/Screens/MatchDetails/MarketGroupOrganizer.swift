//
//  MarketGroupOrganizer.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/12/2021.
//

import Foundation
import OrderedCollections

protocol MarketGroupOrganizer {

    var marketId: String { get }
    var marketName: String { get }
    var numberOfColumns: Int { get }
    var numberOfLines: Int { get }

    func outcomeFor(column: Int, line: Int) -> Outcome?

}

struct MarketGroup: Equatable {
    let id: String
    let type: String
    let groupKey: String?
    let translatedName: String?
    let isDefault: Bool?
    let markets: [Market]?
    let position: Int?
}

struct ColumnListedMarketGroupOrganizer: MarketGroupOrganizer {

    var id: String
    var name: String
    var outcomes: OrderedDictionary<String, [Outcome]>

    private var sortedOutcomeKeys: [String]
    private var maxLineValue: Int
    private var sortedOutcomes: [String: [Outcome] ]

    init(id: String, name: String, outcomes: OrderedDictionary<String, [Outcome]> ) {
        
        var processedOutcomes = outcomes

        // Custom processing
        // If we got a x_or_more market with all the options in the same column we split the in 3
        if Array(outcomes.keys) == ["x_or_more"] {
            processedOutcomes = [:]
            
            let outcomeValues = outcomes["x_or_more"] ?? []
            let arraySlicesCount = Int( ceil( Double(outcomeValues.count)/3) )
            let arraysSplited = outcomeValues.chunked(into: arraySlicesCount )
            
            if let arraysSplited0 = arraysSplited[safe: 0] {
                processedOutcomes["x_or_more_0"] = arraysSplited0
            }
            if let arraysSplited1 = arraysSplited[safe: 1] {
                processedOutcomes["x_or_more_1"] = arraysSplited1
            }
            if let arraysSplited2 = arraysSplited[safe: 2] {
                processedOutcomes["x_or_more_2"] = arraysSplited2
            }
        }
        //
        
        self.id = id
        self.name = name
        self.outcomes = processedOutcomes

        self.sortedOutcomeKeys = []
        
        // When there is H and A type outcomes, and a random third type
        if self.outcomes.keys.count == 3,
           !self.outcomes.keys.contains("D"),
           self.outcomes.keys.contains("H"),
           self.outcomes.keys.contains("A") {
            
            var tempOutcomes = OrderedDictionary<String, [Outcome]>()
            
            for (key, _) in self.outcomes {
                if key != "A" && key != "H" {
                    tempOutcomes["D"] = self.outcomes[key]
                }
                else {
                    tempOutcomes[key] = self.outcomes[key]
                }
            }
            
            self.outcomes = tempOutcomes
        }
        
        self.sortedOutcomeKeys = Array(self.outcomes.keys)
        self.sortedOutcomeKeys = self.outcomes.keys.sorted { out1Name, out2Name in
            guard
                let out1Value = OddOutcomesSortingHelper.sortValueForOutcomeIfPresent(out1Name),
                let out2Value = OddOutcomesSortingHelper.sortValueForOutcomeIfPresent(out2Name)
            else {
                // we only sort if we have value, otherwise we kepp the original positions
                return false
            }
            return out1Value < out2Value
        }

        self.sortedOutcomes = [:]

        for sortedOutcomeKey in self.sortedOutcomeKeys {
            if let outcomesForKey = self.outcomes[sortedOutcomeKey] {
                self.sortedOutcomes[sortedOutcomeKey] = outcomesForKey
            }
        }

        var maxLineValue = 0
        for outcomeArray in self.outcomes.values {
            maxLineValue = max(maxLineValue, outcomeArray.count)
        }

        self.maxLineValue = maxLineValue
    }

    var marketId: String {
        return self.id
    }

    var marketName: String {
        return "\(name)"
    }

    var numberOfColumns: Int {
        return outcomes.keys.count
    }

    var numberOfLines: Int {
        return self.maxLineValue
    }

    func outcomeFor(column: Int, line: Int) -> Outcome? {

        if let columnKey = self.sortedOutcomeKeys[safe: column] {
            if let outcomesForKey = self.sortedOutcomes[columnKey] {
                if let outcome = outcomesForKey[safe: line] {
                    return outcome
                }
            }
        }
        return nil
    }

}

struct MarketLinesMarketGroupOrganizer: MarketGroupOrganizer {

    var id: String
    var name: String
    var outcomes: OrderedDictionary<String, [Outcome]>
    var markets: [Market]

    private var sortedOutcomeKeys: [String]
    private var maxLineValue: Int
    private var maxColumnValue: Int
    private var sortedMarkets: [Market]

    init(id: String, name: String, markets: [Market], outcomes: OrderedDictionary<String, [Outcome]>) {

        self.id = id
        self.name = name
        self.outcomes = outcomes
        self.markets = markets

        self.sortedOutcomeKeys = []
        self.sortedOutcomeKeys = self.outcomes.keys.sorted { out1Name, out2Name in
            guard
                let out1Value = OddOutcomesSortingHelper.sortValueForOutcomeIfPresent(out1Name),
                let out2Value = OddOutcomesSortingHelper.sortValueForOutcomeIfPresent(out2Name)
            else {
                // we only sort if we have value, otherwise we kepp the original positions
                return false
            }
            return out1Value < out2Value
        }

        self.markets = markets
        self.sortedMarkets = self.markets.sorted(by: { leftMarket, rigthMarket in
            leftMarket.nameDigit1 ?? 0.0 < rigthMarket.nameDigit1 ?? 0.0
        })

        self.maxLineValue = markets.count
        
        var maxColumnValue = 0
        for market in self.markets {
            maxColumnValue = max(maxColumnValue, market.outcomes.count)
        }
        self.maxColumnValue = maxColumnValue
    }

    var marketId: String {
        return self.id
    }

    var marketName: String {
        return "\(name)"
    }

    var numberOfColumns: Int {
        return self.maxColumnValue
    }

    var numberOfLines: Int {
        return self.maxLineValue
    }

    func outcomeFor(column: Int, line: Int) -> Outcome? {

        if self.name.lowercased() == "buts du joueur" {
            print("stop")
        }
        
//        if let market = self.sortedMarkets[safe: line] {
//            return market.outcomes[safe: column]
//        }

        if let market = self.sortedMarkets[safe: line], let outcomeKey = self.sortedOutcomeKeys[safe: column] {
            for outcome in market.outcomes where outcome.headerCodeName == outcomeKey {
                return outcome
            }
        }
        return nil

    }
}

struct MarketColumnsMarketGroupOrganizer: MarketGroupOrganizer {

    var id: String
    var name: String
    var outcomes: OrderedDictionary<String, [Outcome]>
    var markets: [Market]
    var maxLineValue: Int

    private var sortedOutcomeKeys: [String]
    private var sortedOutcomes: [String: [Outcome] ]

    init(id: String, name: String, markets: [Market], outcomes: OrderedDictionary<String, [Outcome]>) {

        self.id = id
        self.name = name
        self.outcomes = outcomes
        self.markets = markets

        self.sortedOutcomeKeys = []
        self.sortedOutcomeKeys = self.outcomes.keys.sorted { out1Name, out2Name in
            guard
                let out1Value = OddOutcomesSortingHelper.sortValueForOutcomeIfPresent(out1Name),
                let out2Value = OddOutcomesSortingHelper.sortValueForOutcomeIfPresent(out2Name)
            else {
                // we only sort if we have value, otherwise we kepp the original positions
                return false
            }
            return out1Value < out2Value
        }

        self.sortedOutcomes = [:]

        for sortedOutcomeKey in sortedOutcomeKeys {
            if let outcomesForKey = self.outcomes[sortedOutcomeKey] {
                self.sortedOutcomes[sortedOutcomeKey] = outcomesForKey
            }
        }

        self.markets = markets

        var maxLineValue = 0
        for outcomeArray in outcomes.values {
            maxLineValue = max(maxLineValue, outcomeArray.count)
        }

        self.maxLineValue = maxLineValue
    }

    var marketId: String {
        return self.id
    }

    var marketName: String {
        return "\(name)"
    }

    var numberOfColumns: Int {
        return markets.count
    }

    var numberOfLines: Int {
        return self.maxLineValue
    }

    func outcomeFor(column: Int, line: Int) -> Outcome? {
        if let outcomesKey = self.sortedOutcomeKeys[safe: column], let outcomesForKey = sortedOutcomes[outcomesKey], let outcome = outcomesForKey[safe: line] {
            return outcome
        }
        return nil
    }
}

struct SequentialMarketGroupOrganizer: MarketGroupOrganizer {

    var id: String
    var name: String
    var market: Market

    private var maxColumnValue: Int
    private var maxLineValue: Double

    private var sortedOutcomes: [Outcome]

    init(id: String, name: String, market: Market) {

        self.id = id
        self.name = name
        self.market = market

        self.sortedOutcomes = market.outcomes
        
        self.maxColumnValue = 3
        if self.sortedOutcomes.count == 2 {
            self.maxColumnValue = 2
        }

        self.maxLineValue = ceil(Double(self.market.outcomes.count)/Double(self.maxColumnValue))
    }

    var marketId: String {
        return self.id
    }

    var marketName: String {
        return "\(name)"
    }

    var numberOfColumns: Int {
        return self.maxColumnValue
    }

    var numberOfLines: Int {
        return Int(self.maxLineValue)
    }

    func outcomeFor(column: Int, line: Int) -> Outcome? {
        let index = (line * numberOfColumns) + column
        if let outcome = self.sortedOutcomes[safe: index] {
            return outcome
        }
        return nil
    }
}

struct UndefinedGroupMarketGroupOrganizer: MarketGroupOrganizer {

    var id: String
    var name: String
    var outcomes: OrderedDictionary<String, [Outcome]>

    private var sortedOutcomes: [Outcome]

    private var maxColumnValue: Int
    private var maxLineValue: Double

    init(id: String, name: String, outcomes:  OrderedDictionary<String, [Outcome]>) {

        self.id = id
        self.name = name
        self.outcomes = outcomes

        self.sortedOutcomes = []

        for key in outcomes.keys {
            if let outcome = outcomes[key] {
                self.sortedOutcomes.append(contentsOf: outcome)
            }
        }
        
        self.maxColumnValue = 3
        if self.sortedOutcomes.count == 2 || self.sortedOutcomes.count == 4 {
            self.maxColumnValue = 2
        }

        self.maxLineValue = ceil(Double(self.sortedOutcomes.count)/Double(self.maxColumnValue))
    }

    var marketId: String {
        return self.id
    }

    var marketName: String {
        return "\(name)"
    }

    var numberOfColumns: Int {
        return self.maxColumnValue
    }

    var numberOfLines: Int {
        return Int(self.maxLineValue)
    }

    func outcomeFor(column: Int, line: Int) -> Outcome? {
        let index = (line * numberOfColumns) + column
        if let outcome = self.sortedOutcomes[safe: index] {
            return outcome
        }
        return nil
    }
}

struct UnorderedGroupMarketGroupOrganizer: MarketGroupOrganizer {

    var id: String
    var name: String
    var outcomes: OrderedDictionary<String, [Outcome]>

    private var sortedOutcomes: [Outcome]

    private var maxColumnValue: Int
    private var maxLineValue: Double

    init(id: String, name: String, outcomes: OrderedDictionary<String, [Outcome]>) {

        self.id = id
        self.name = name
        self.outcomes = outcomes

        self.sortedOutcomes = []

        for key in outcomes.keys {
            if let outcome = outcomes[key] {
                self.sortedOutcomes.append(contentsOf: outcome)
            }
        }

        self.maxColumnValue = 3
        if self.sortedOutcomes.count == 2 || self.sortedOutcomes.count == 4 {
            self.maxColumnValue = 2
        }

        self.maxLineValue = ceil(Double(self.sortedOutcomes.count)/Double(self.maxColumnValue))
    }

    var marketId: String {
        return self.id
    }

    var marketName: String {
        return "\(name)"
    }

    var numberOfColumns: Int {
        return self.maxColumnValue
    }

    var numberOfLines: Int {
        return Int(self.maxLineValue)
    }

    func outcomeFor(column: Int, line: Int) -> Outcome? {
        let index = (line * numberOfColumns) + column
        if let outcome = self.sortedOutcomes[safe: index] {
            return outcome
        }
        return nil
    }
}


struct SimpleListGroupMarketGroupOrganizer: MarketGroupOrganizer {

    var id: String
    var name: String
    var outcomes: OrderedDictionary<String, [Outcome]>

    private var sortedOutcomes: [Outcome]

    private var maxColumnValue: Int
    private var maxLineValue: Double

    init(id: String, name: String, outcomes: OrderedDictionary<String, [Outcome]>) {

        self.id = id
        self.name = name
        self.outcomes = outcomes

        self.sortedOutcomes = []

        for key in outcomes.keys {
            if let outcome = outcomes[key] {
                self.sortedOutcomes.append(contentsOf: outcome)
            }
        }
        
        self.maxColumnValue = 1
        self.maxLineValue = Double(self.sortedOutcomes.count)
    }

    var marketId: String {
        return self.id
    }

    var marketName: String {
        return "\(name)"
    }

    var numberOfColumns: Int {
        return self.maxColumnValue
    }

    var numberOfLines: Int {
        return Int(self.maxLineValue)
    }

    func outcomeFor(column: Int, line: Int) -> Outcome? {
        let index = (line * numberOfColumns) + column
        if let outcome = self.sortedOutcomes[safe: index] {
            return outcome
        }
        return nil
    }
}
