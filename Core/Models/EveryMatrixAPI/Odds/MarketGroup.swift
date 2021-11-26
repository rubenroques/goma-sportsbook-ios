//
//  MarketGroup.swift
//  Sportsbook
//
//  Created by Ruben Roques on 25/11/2021.
//

import Foundation

extension EveryMatrix {
struct MarketGroup: Codable {

    let type: String
    let id: String
    let groupKey: String?
    let translatedName: String?
    let position: Int?
    let isDefault: Bool?
    let numberOfMarkets: Int?

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case id = "id"
        case groupKey = "groupKey"
        case translatedName = "translatedName"
        case position = "position"
        case isDefault = "isDefault"
        case numberOfMarkets = "numberOfMarkets"
    }

}
}
