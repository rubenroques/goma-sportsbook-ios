//
//  GomaClientSettings.swift
//  Sportsbook
//
//  Created by Ruben Roques on 15/09/2021.
//

import Foundation

struct GomaClientSettings: Codable {

    let id: Int
    let category: String
    let name: String
    let type: Int

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case category = "category"
        case name = "name"
        case type = "type"
    }
}
