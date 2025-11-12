//
//  UserFavoritesResponse.swift
//  ServicesProvider
//
//  Created by André Lascas on 12/11/2025.
//

import Foundation

public struct UserFavoritesResponse: Codable {
    public var favoriteEvents: [String]

    enum CodingKeys: String, CodingKey {
        case favoriteEvents = "favoriteEvents"
    }
}
