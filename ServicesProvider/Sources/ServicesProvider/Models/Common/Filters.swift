//
//  MarketFilter.swift
//  
//
//  Created by André Lascas on 02/11/2022.
//

import Foundation

public struct DynamicCodingKeys: CodingKey {

    // Use for string-keyed dictionary
    public var stringValue: String

    public init?(stringValue: String) {
        self.stringValue = stringValue
    }

    // Use for integer-keyed dictionary
    public var intValue: Int?

    public init?(intValue: Int) {
        return nil
    }
}

public struct MarketFilter: Codable {

    public var marketFilters: [MarketInfo]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        var tempArray = [MarketInfo]()

        for key in container.allKeys {
            let decodedObject = try container.decode(MarketInfo.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
            tempArray.append(decodedObject)
        }

        self.marketFilters = tempArray
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
    public var chinese: String?

    enum CodingKeys: String, CodingKey {
        case english = "UK"
        case spanish = "ES"
        case chinese = "ZH"
    }

}

public struct MarketSportType: Codable {

    public var marketSports: [String: [MarketSport]]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        var tempArray = [String: [MarketSport]]()

        for key in container.allKeys {

            let decodedObject = try container.decode([MarketSport].self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
            tempArray[key.stringValue] = decodedObject
        }

        self.marketSports = tempArray
    }
}

public struct MarketSport: Codable {
    public var ids: [String]
    public var marketOrder: Int
    public var expanded: Bool

    enum CodingKeys: String, CodingKey {
        case ids = "ids"
        case marketOrder = "displayOrder"
        case expanded = "expanded"
    }
}
