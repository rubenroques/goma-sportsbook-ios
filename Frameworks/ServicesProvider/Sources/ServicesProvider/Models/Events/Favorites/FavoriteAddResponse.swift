//
//  FavoriteAddResponse.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public struct FavoriteAddResponse: Codable {
    public var displayOrder: Int?
    public var idAccountFavorite: Int?

    enum CodingKeys: String, CodingKey {
        case displayOrder = "displayOrder"
        case idAccountFavorite = "idAccountFavourite"
    }
}
