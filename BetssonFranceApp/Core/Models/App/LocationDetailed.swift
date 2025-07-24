//
//  LocationDetailed.swift
//  MultiBet
//
//  Created by Ruben Roques on 06/08/2024.
//

import Foundation

struct LocationDetailed: Decodable {

    let id: String
    let type: String?
    let typeId: String?
    let name: String?
    let shortName: String?
    let code: String?

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case id = "id"
        case typeId = "typeId"
        case name = "name"
        case shortName = "shortName"
        case code = "code"
    }
}
