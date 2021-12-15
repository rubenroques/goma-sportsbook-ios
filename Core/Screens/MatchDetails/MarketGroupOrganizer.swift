//
//  MarketGroupOrganizer.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/12/2021.
//

import Foundation

struct MergedMarketGroup {

    var id: String
    var typeId: String
    var name: String
    var index: Int
    var numberOfMarkets: Int
    var outcomes: [String: [Outcome] ]

}

struct ColumnListedMarketGroupOrganizer: MarketGroupOrganizer {

    var id: String
    var name: String
    var outcomes: [String: [Outcome]]

    private var sortedOutcomeKeys: [String]
    private var maxLineValue: Int
    private var sortedOutcomes: [String: [Outcome] ]

    init(id: String, name: String, outcomes: [String: [Outcome]] ) {

        self.id = id
        self.name = name
        self.outcomes = outcomes

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

                    if (leftOutcome.codeName == "away" || rightOutcome.codeName == "away" || leftOutcome.codeName == "away_draw" || rightOutcome.codeName == "away_draw")
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
        for outcomeArray in outcomes.values {
            maxLineValue = max(maxLineValue, outcomeArray.count)
        }

        self.maxLineValue = maxLineValue
    }

    var marketId: String {
        return self.id
    }

    var marketName: String {
        return "\(name) [t0]"
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
        return "\(name) [t1]"
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

//        if let market = self.sortedMarkets[safe: line], let outcome = market.outcomes[safe: column] {
//            return outcome
//        }
//        return nil
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
        return "\(name) [t3]"
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

        self.sortedOutcomes = market.outcomes.sorted(by: \.translatedName)

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
        return "\(name) [t4]"
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

protocol MarketGroupOrganizer {

    var marketId: String { get }
    var marketName: String { get }
    var numberOfColumns: Int { get }
    var numberOfLines: Int { get }

    func outcomeFor(column: Int, line: Int) -> Outcome?

}
