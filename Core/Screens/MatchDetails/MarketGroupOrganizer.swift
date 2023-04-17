//
//  MarketGroupOrganizer.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/12/2021.
//

import Foundation

protocol MarketGroupOrganizer {

    var marketId: String { get }
    var marketName: String { get }
    var numberOfColumns: Int { get }
    var numberOfLines: Int { get }

    func outcomeFor(column: Int, line: Int) -> Outcome?

}

struct MarketGroup {
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
    var outcomes: [String: [Outcome]]

    private var sortedOutcomeKeys: [String]
    private var maxLineValue: Int
    private var sortedOutcomes: [String: [Outcome] ]

    init(id: String, name: String, outcomes: [String: [Outcome]] ) {
        
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

        self.sortedOutcomeKeys = self.outcomes.keys.sorted { out1Name, out2Name in
            let out1Value = OddOutcomesSortingHelper.sortValueForOutcome(out1Name)
            let out2Value = OddOutcomesSortingHelper.sortValueForOutcome(out2Name)
            return out1Value < out2Value
        }

        self.sortedOutcomes = [:]

        for sortedOutcomeKey in sortedOutcomeKeys {
            if let outcomesForKey = self.outcomes[sortedOutcomeKey] {

                let sortedOutcomes = outcomesForKey.sorted { leftOutcome, rightOutcome in

                    var leftNameDigit1 = leftOutcome.nameDigit1 ?? 0.0
                    var rightNameDigit1 = rightOutcome.nameDigit1 ?? 0.0

                    var leftNameDigit2 = leftOutcome.nameDigit2 ?? 0.0
                    var rightNameDigit2 = rightOutcome.nameDigit2 ?? 0.0

                    let leftNameDigit3 = leftOutcome.nameDigit3 ?? 0.0
                    let rightNameDigit3 = rightOutcome.nameDigit3 ?? 0.0

                    if (leftOutcome.codeName == "away" ||
                        rightOutcome.codeName == "away" ||
                        leftOutcome.codeName == "away_draw" ||
                        rightOutcome.codeName == "away_draw")
                        && (leftOutcome.nameDigit2 != nil && rightOutcome.nameDigit2 != nil) {
                        
                        leftNameDigit1 = leftOutcome.nameDigit2 ?? 0.0
                        rightNameDigit1 = rightOutcome.nameDigit2 ?? 0.0

                        leftNameDigit2 = leftOutcome.nameDigit1 ?? 0.0
                        rightNameDigit2 = rightOutcome.nameDigit1 ?? 0.0
                    }

                    if leftNameDigit1 == rightNameDigit1 {
                        if leftNameDigit2 == rightNameDigit2 {
                            if leftNameDigit3 == rightNameDigit3 {
                                return leftOutcome.translatedName < rightOutcome.translatedName
                            }
                            else {
                                return leftNameDigit3 < rightNameDigit3
                            }
                        }
                        else {
                            return leftNameDigit2 < rightNameDigit2
                        }
                    }
                    else {
                        return leftNameDigit1 < rightNameDigit1
                    }
                }

                self.sortedOutcomes[sortedOutcomeKey] = sortedOutcomes
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
    var outcomes: [String: [Outcome]]
    var markets: [Market]

    private var sortedOutcomeKeys: [String]
    private var maxLineValue: Int
    private var sortedMarkets: [Market]

    init(id: String, name: String, markets: [Market], outcomes: [String: [Outcome]]) {

        self.id = id
        self.name = name
        self.outcomes = outcomes
        self.markets = markets

        self.sortedOutcomeKeys = []
        self.sortedOutcomeKeys = self.outcomes.keys.sorted { out1Name, out2Name in
            let out1Value = OddOutcomesSortingHelper.sortValueForOutcome(out1Name)
            let out2Value = OddOutcomesSortingHelper.sortValueForOutcome(out2Name)
            return out1Value < out2Value
        }

        // Inverse Under/Over to Over/Under
//        if self.outcomes.values.contains(where: {
//            (($0[safe: 0]?.codeName.contains("Over")) != nil || ($0[safe: 0]?.codeName.contains("Under")) != nil)
//        }) {
//            self.sortedOutcomeKeys = self.sortedOutcomeKeys.reversed()
//        }

        self.markets = markets
        self.sortedMarkets = self.markets.sorted(by: { leftMarket, rigthMarket in
            leftMarket.nameDigit1 ?? 0.0 < rigthMarket.nameDigit1 ?? 0.0
        })

        self.maxLineValue = markets.count

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
    var outcomes: [String: [Outcome]]
    var markets: [Market]
    var maxLineValue: Int

    private var sortedOutcomeKeys: [String]
    private var sortedOutcomes: [String: [Outcome] ]

    init(id: String, name: String, markets: [Market], outcomes: [String: [Outcome]]) {

        self.id = id
        self.name = name
        self.outcomes = outcomes
        self.markets = markets

        self.sortedOutcomeKeys = []
        self.sortedOutcomeKeys = self.outcomes.keys.sorted { out1Name, out2Name in
            let out1Value = OddOutcomesSortingHelper.sortValueForOutcome(out1Name)
            let out2Value = OddOutcomesSortingHelper.sortValueForOutcome(out2Name)
            return out1Value < out2Value
        }

        self.sortedOutcomes = [:]

        for sortedOutcomeKey in sortedOutcomeKeys {
            if let outcomesForKey = self.outcomes[sortedOutcomeKey] {

                let sortedOutcomes = outcomesForKey.sorted { leftOutcome, rightOutcome in

                    let leftNameDigit1 = leftOutcome.nameDigit1 ?? 0.0
                    let rightNameDigit1 = rightOutcome.nameDigit1 ?? 0.0

                    let leftNameDigit2 = leftOutcome.nameDigit2 ?? 0.0
                    let rightNameDigit2 = rightOutcome.nameDigit2 ?? 0.0

                    let leftNameDigit3 = leftOutcome.nameDigit3 ?? 0.0
                    let rightNameDigit3 = rightOutcome.nameDigit3 ?? 0.0

                    if leftNameDigit1 == rightNameDigit1 {
                        if leftNameDigit2 == rightNameDigit2 {
                            if leftNameDigit3 == rightNameDigit3 {
                                return leftOutcome.translatedName < rightOutcome.translatedName
                            }
                            else {
                                return leftNameDigit3 < rightNameDigit3
                            }
                        }
                        else {
                            return leftNameDigit2 < rightNameDigit2
                        }
                    }
                    else {
                        return leftNameDigit1 < rightNameDigit1
                    }
                }

                self.sortedOutcomes[sortedOutcomeKey] = sortedOutcomes
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

    init(id: String, name: String, market: Market, sortedByOdd: Bool) {

        self.id = id
        self.name = name
        self.market = market

        if sortedByOdd {
            self.sortedOutcomes = market.outcomes.sorted(by: \.bettingOffer.decimalOdd)
        }
        else {
            self.sortedOutcomes = market.outcomes.sorted(by: \.translatedName)
        }

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
    var outcomes: [String: [Outcome]]

    private var sortedOutcomes: [Outcome]

    private var maxColumnValue: Int
    private var maxLineValue: Double

    init(id: String, name: String, outcomes: [String: [Outcome]]) {

        self.id = id
        self.name = name
        self.outcomes = outcomes

        self.sortedOutcomes = []

        for outcome in outcomes {
            self.sortedOutcomes.append(contentsOf: outcome.value)
        }

        self.sortedOutcomes = self.sortedOutcomes.sorted(by: {
            $0.bettingOffer.decimalOdd < $1.bettingOffer.decimalOdd
            //$0.id < $1.id
        })

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
    var outcomes: [String: [Outcome]]

    private var sortedOutcomes: [Outcome]

    private var maxColumnValue: Int
    private var maxLineValue: Double

    init(id: String, name: String, outcomes: [String: [Outcome]]) {

        self.id = id
        self.name = name
        self.outcomes = outcomes

        self.sortedOutcomes = []

        for outcome in outcomes {
            self.sortedOutcomes.append(contentsOf: outcome.value)
        }

        if outcomes.keys.contains("A") || outcomes.keys.contains("D") || outcomes.keys.contains("H") {

            self.sortedOutcomes = []

            let sortedOutcomes = outcomes.sorted(by: { $0.0 > $1.0 })

            for outcome in sortedOutcomes {
                self.sortedOutcomes.append(contentsOf: outcome.value)
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
