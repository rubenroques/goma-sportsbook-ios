//
//  FavoriteEvent.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public struct FavoriteEvent: Codable {
    public var id: String
    public var name: String
    public var favoriteListId: Int
    public var accountFavoriteId: Int

    enum CodingKeys: String, CodingKey {
        case id = "favouriteId"
        case name = "favouriteName"
        case favoriteListId = "idfwAccountFavouriteCoupon"
        case accountFavoriteId = "idfwAccountFavourites"
    }

}
