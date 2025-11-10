//
//  FavoriteEventResponse.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public struct FavoriteEventResponse: Codable {
    public var favoriteEvents: [FavoriteEvent]

    enum CodingKeys: String, CodingKey {
        case favoriteEvents = "accountFavourites"
    }
}
