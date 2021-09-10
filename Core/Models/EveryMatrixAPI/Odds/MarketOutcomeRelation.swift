//
//  MarketOutcomeRelation.swift
//  Sportsbook
//
//  Created by André Lascas on 09/09/2021.
//

import Foundation

struct MarketOutcomeRelation: Decodable {

    let type: String
    let id: String
    let marketId: String
    let outcomeId: String

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case id = "id"
        case marketId = "marketId"
        case outcomeId = "outcomeId"
    }
}
