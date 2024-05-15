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
        var id: String
        var title: String
        var imageUrl: String
        var linkUrl: String
        var bodyText: String

        enum CodingKeys: String, CodingKey {
            case id = "idfwheadline"
            case title = "title"
            case imageUrl = "imageurl"
            case linkUrl = "linkurl"
            case bodyText = "bodytext"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.PromotionalStory.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.PromotionalStory.CodingKeys.self)
            self.id = try container.decode(String.self, forKey: SportRadarModels.PromotionalStory.CodingKeys.id)
            self.title = try container.decode(String.self, forKey: SportRadarModels.PromotionalStory.CodingKeys.title)
            self.imageUrl = try container.decode(String.self, forKey: SportRadarModels.PromotionalStory.CodingKeys.imageUrl)
            self.linkUrl = try container.decode(String.self, forKey: SportRadarModels.PromotionalStory.CodingKeys.linkUrl)
            self.bodyText = (try? container.decode(String.self, forKey: SportRadarModels.PromotionalStory.CodingKeys.bodyText)) ?? ""
        }
    }
}
