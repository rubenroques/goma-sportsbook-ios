//
//  SecundaryMarketDetails.swift
//  Sportsbook
//
//  Created by Ruben Roques on 15/11/2023.
//

import Foundation

public typealias SecundarySportMarkets = [SecundarySportMarket]

// MARK: - SecundaryMarket
public class SecundarySportMarket: Codable {
    public var sportId: String
    public var markets: [MarketSpecs]

    enum CodingKeys: String, CodingKey {
        case sportId = "sport_id"
        case markets = "markets"
    }

    public init(sportId: String, markets: [MarketSpecs]) {
        self.sportId = sportId
        self.markets = markets
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sportId = try container.decode(String.self, forKey: .sportId)
        self.markets = try container.decode([MarketSpecs].self, forKey: .markets)
    }
}

// MARK: - Market
public class MarketSpecs: Codable {
    public var marketTypeId: String
    public var name: String
    public var statsId: String
    public var line: String?

    enum CodingKeys: String, CodingKey {
        case marketTypeId = "idefmarkettype"
        case name = "name"
        case statsId = "stats_id"
        case line = "line"
    }

    public init(marketTypeId: String, name: String, statsId: String, line: String?) {
        self.marketTypeId = marketTypeId
        self.name = name
        self.statsId = statsId
        self.line = line
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.marketTypeId = try container.decode(String.self, forKey: .marketTypeId)
        self.name = try container.decode(String.self, forKey: .name)
        self.statsId = try container.decode(String.self, forKey: .statsId)
        self.line = try container.decodeIfPresent(String.self, forKey: .line)
    }
}
