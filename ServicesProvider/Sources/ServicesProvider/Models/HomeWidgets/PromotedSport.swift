//
//  File.swift
//  
//
//  Created by Ruben Roques on 09/06/2023.
//

import Foundation

public struct PromotedSport: Codable {

    public let id: String
    public let name: String
    public let marketGroups: [MarketGroupPromotedSport]

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case marketGroups = "marketGroups"
    }

    public init(id: String, name: String, marketGroups: [MarketGroupPromotedSport]) {
        self.id = id
        self.name = name
        self.marketGroups = marketGroups
    }
}


public struct MarketGroupPromotedSport: Codable {

    public let id: String
    public let typeId: String?
    public let name: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case typeId = "typeId"
        case name = "name"
    }

    public init(id: String, typeId: String?, name: String?) {
        self.id = id
        self.typeId = typeId
        self.name = name
    }

}

