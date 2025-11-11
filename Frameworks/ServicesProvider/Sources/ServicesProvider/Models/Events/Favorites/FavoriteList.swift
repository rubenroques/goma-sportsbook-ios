//
//  FavoriteList.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public struct FavoriteList: Codable {
    public var id: Int
    public var name: String
    public var customerId: Int

    enum CodingKeys: String, CodingKey {
        case id = "idfwAccountFavouriteCoupon"
        case name = "name"
        case customerId = "idmmCustomer"
    }
}
