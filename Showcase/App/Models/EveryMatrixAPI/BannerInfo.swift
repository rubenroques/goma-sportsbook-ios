//
//  BannerInfo.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/10/2021.
//

import Foundation

extension EveryMatrix {
    struct BannerInfo: Codable {
        let type: String
        let id: String
        let matchID: String?
        let imageURL: String?
        let priorityOrder: Int?
        
        enum CodingKeys: String, CodingKey {
            case type = "_type"
            case id
            case matchID = "matchId"
            case imageURL = "imageUrl"
            case priorityOrder
        }
    }
}
