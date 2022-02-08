//
//  File.swift
//  Sportsbook
//
//  Created by André Lascas on 08/02/2022.
//

import Foundation

struct UserSettingsGoma: Codable {
    var status: String
    var message: String

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
    }
}
