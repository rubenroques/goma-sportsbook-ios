//
//  File.swift
//  
//
//  Created by Ruben Roques on 30/05/2023.
//

import Foundation

extension SportRadarModels {

    struct PromotionalBannersResponse: Codable {
        var promotionalBannerItems: [PromotionalBanner]

        enum CodingKeys: String, CodingKey {
            case promotionalBannerItems = "banneritems"
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            let rawPromotionalBannerItems: [FailableDecodable<SportRadarModels.PromotionalBanner>] = try container.decode([FailableDecodable<SportRadarModels.PromotionalBanner>].self, forKey: .promotionalBannerItems)
            self.promotionalBannerItems = rawPromotionalBannerItems.compactMap({ $0.content })
        }

        init(promotionalBannerItems: [PromotionalBanner]) {
            self.promotionalBannerItems = promotionalBannerItems
        }
    }

     struct PromotionalBanner: Codable {
         let id: String
         let name: String?
         let bannerType: String?
         let imageURL: String?
         let bannerDisplay: String?
         let linkType: String?
         let location: String?
         let bannerContents: [String]?

        enum CodingKeys: String, CodingKey {
            case id = "idfwbanneritem"
            case name = "name"
            case bannerType = "bannertype"
            case imageURL = "imageurl"
            case bannerDisplay = "bannerdisplay"
            case linkType = "linktype"
            case location = "location"
            case bannerContents = "bannerstaticcontents"
        }

    }
}
