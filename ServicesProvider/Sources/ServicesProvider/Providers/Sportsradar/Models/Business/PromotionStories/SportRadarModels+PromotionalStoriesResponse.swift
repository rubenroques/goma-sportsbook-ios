//
//  SportRadarModels+PromotionalStoriesResponse.swift
//  
//
//  Created by André Lascas on 25/07/2023.
//

import Foundation

extension SportRadarModels {

    struct PromotionalStoriesResponse: Codable {

        var promotionalStories: [PromotionalStory]

        enum CodingKeys: String, CodingKey {
            case promotionalStories = "headlineItems"
        }
    }

    struct PromotionalStory: Codable {
        var title: String
        var imageUrl: String
        var linkUrl: String
        var bodyText: String

        enum CodingKeys: String, CodingKey {
            case title = "title"
            case imageUrl = "imageurl"
            case linkUrl = "linkurl"
            case bodyText = "bodytext"
        }
    }
}
