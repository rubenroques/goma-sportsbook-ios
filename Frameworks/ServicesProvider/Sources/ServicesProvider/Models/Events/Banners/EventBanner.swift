//
//  EventBanner.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

// Renamed from Banner to EventBanner to avoid conflict with the consolidated version in Promotions
public struct EventBanner: Codable {
    public var id: String
    public var name: String
    public var title: String
    public var imageUrl: String
    public var bodyText: String?
    public var type: String
    public var linkUrl: String?
    public var marketId: String?

    enum CodingKeys: String, CodingKey {
        case id = "idfwheadline"
        case name = "name"
        case title = "title"
        case imageUrl = "imageurl"
        case bodyText = "bodytext"
        case type = "idfwheadlinetype"
        case linkUrl = "linkurl"
        case marketId = "idfomarket"
    }
}
