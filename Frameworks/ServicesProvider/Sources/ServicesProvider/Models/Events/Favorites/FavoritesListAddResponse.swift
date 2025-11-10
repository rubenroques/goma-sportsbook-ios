//
//  FavoritesListAddResponse.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public struct FavoritesListAddResponse: Codable {
    public var listId: Int

    enum CodingKeys: String, CodingKey {
        case listId = "addAccountFavouriteCouponResult"
    }
}
