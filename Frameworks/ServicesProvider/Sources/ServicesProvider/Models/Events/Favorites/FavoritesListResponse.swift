//
//  FavoritesListResponse.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public struct FavoritesListResponse: Codable {
    public var favoritesList: [FavoriteList]

    enum CodingKeys: String, CodingKey {
        case favoritesList = "accountFavouriteCoupons"
    }
}
