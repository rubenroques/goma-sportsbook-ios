//
//  SportCompetitionMarketGroup.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public struct SportCompetitionMarketGroup: Codable, Hashable {
    public var id: String
    public var name: String

    enum CodingKeys: String, CodingKey {
        case id = "idfwmarketgroup"
        case name = "name"
    }
}
