//
//  File.swift
//  
//
//  Created by André Lascas on 02/11/2022.
//

import Foundation

public struct MarketFilter: Codable {
    public var allMarkets: MarketInfo
    public var popularMarkets: MarketInfo
    public var totalMarkets: MarketInfo
    public var goalMarkets: MarketInfo
    public var handicapMarkets: MarketInfo
    public var otherMarkets: MarketInfo

    enum CodingKeys: String, CodingKey {
        case allMarkets = "All Markets"
        case popularMarkets = "Popular Markets"
        case totalMarkets = "Totals"
        case goalMarkets = "Goal Markets"
        case handicapMarkets = "Handicap Markets"
        case otherMarkets = "Other Markets"

    }
}

public struct MarketInfo: Codable {
    public var displayOrder: Int
    public var translations: TranslationInfo?
    public var marketsSportType: MarketSportType?

    enum CodingKeys: String, CodingKey {
        case displayOrder = "displayOrder"
        case translations = "translations"
        case marketsSportType = "marketsBySportType"
    }
}

public struct TranslationInfo: Codable {
    public var english: String
    public var spanish: String
    public var chinese: String

    enum CodingKeys: String, CodingKey {
        case english = "UK"
        case spanish = "ES"
        case chinese = "ZH"
    }

}

public struct MarketSportType: Codable {
    public var all: [MarketSport]

    enum CodingKeys: String, CodingKey {
        case all = "ALL"
    }
}

public struct MarketSport: Codable {
    public var ids: [String]
    public var displayOrder: Int
    public var expanded: Bool

    enum CodingKeys: String, CodingKey {
        case ids = "ids"
        case displayOrder = "displayOrder"
        case expanded = "expanded"
    }
}
