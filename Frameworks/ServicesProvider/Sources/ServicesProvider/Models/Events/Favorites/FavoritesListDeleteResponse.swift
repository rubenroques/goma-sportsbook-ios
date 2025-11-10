//
//  FavoritesListDeleteResponse.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public struct FavoritesListDeleteResponse: Codable {
    public var listId: String?

    enum CodingKeys: String, CodingKey {
        case listId = "addAccountFavouriteCouponResult"
    }
}
