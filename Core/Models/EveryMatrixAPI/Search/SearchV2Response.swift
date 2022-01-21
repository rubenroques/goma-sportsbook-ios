//
//  SearchV2Response.swift
//  Sportsbook
//
//  Created by André Lascas on 21/01/2022.
//

import Foundation

struct SearchV2Response: Decodable {

    var records: [Event]

    enum CodingKeys: String, CodingKey {
        case records = "records"
    }
}
