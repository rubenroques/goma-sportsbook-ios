//
//  SportRadarModels+AcessTokenResponse.swift
//  
//
//  Created by André Lascas on 12/06/2023.
//

import Foundation

extension SportRadarModels {

    struct AccessTokenResponse: Codable {
        var token: String?
        var userId: String?
        var description: String?
        var code: Int?

        enum CodingKeys: String, CodingKey {
            case token = "token"
            case userId = "userId"
            case description = "description"
            case code = "code"
        }
    }
}
