//
//  File.swift
//  
//
//  Created by André Lascas on 25/07/2023.
//

import Foundation

public struct PromotionalStoriesResponse: Codable {

    public var promotionalStories: [PromotionalStory]

    enum CodingKeys: String, CodingKey {
        case promotionalStories = "headlineItems"
    }
}

public struct PromotionalStory: Codable {
    public var id: String
    public var title: String
    public var imageUrl: String
    public var linkUrl: String
    public var bodyText: String

    enum CodingKeys: String, CodingKey {
        case id = "idfwheadline"
        case title = "title"
        case imageUrl = "imageurl"
        case linkUrl = "linkurl"
        case bodyText = "bodytext"
    }
}
