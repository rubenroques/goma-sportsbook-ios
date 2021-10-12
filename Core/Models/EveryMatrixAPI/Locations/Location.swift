//
//  Location.swift
//  Sportsbook
//
//  Created by André Lascas on 06/09/2021.
//

import Foundation

extension EveryMatrix {
    struct Location: Decodable {

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
}
