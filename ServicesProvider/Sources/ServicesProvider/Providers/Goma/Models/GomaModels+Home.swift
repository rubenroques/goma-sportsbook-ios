//
//  File.swift
//  
//
//  Created by Ruben Roques on 08/01/2024.
//

import Foundation


extension GomaModels {
    
    // MARK: - BannerAlert
    // MARK: - HomeContents
    struct HomeContents: Codable {
        
        var bannerAlerts: [BannerAlert]
        var banners: [Banner]
        var sportAssociatedEventBanners: [SportAssociatedEventBanner]
        var stories: [Story]

        enum CodingKeys: String, CodingKey {
            case bannerAlerts = "bannerAlert"
            case banners = "banners"
            case sportAssociatedEventBanners = "sportBanners"
            case stories = "stories"
        }

        init(bannerAlerts: [BannerAlert],
             banners: [Banner],
             sportAssociatedEventBanners: [SportAssociatedEventBanner],
             stories: [Story]) 
        {
            self.bannerAlerts = bannerAlerts
            self.banners = banners
            self.sportAssociatedEventBanners = sportAssociatedEventBanners
            self.stories = stories
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.HomeContents.CodingKeys> = try decoder.container(keyedBy: GomaModels.HomeContents.CodingKeys.self)
            
            if let bannerActionsArray = try? container.decode([GomaModels.BannerAlert].self, forKey: GomaModels.HomeContents.CodingKeys.bannerAlerts) {
                self.bannerAlerts = bannerActionsArray
            }
            else if let bannerAction = try? container.decode(GomaModels.BannerAlert.self, forKey: GomaModels.HomeContents.CodingKeys.bannerAlerts) {
                self.bannerAlerts = [bannerAction]
            }
            else {
                self.bannerAlerts = []
            }
            
            self.banners = try container.decode([GomaModels.Banner].self, forKey: GomaModels.HomeContents.CodingKeys.banners)
            self.sportAssociatedEventBanners = try container.decode([GomaModels.SportAssociatedEventBanner].self, forKey: GomaModels.HomeContents.CodingKeys.sportAssociatedEventBanners)
            self.stories = try container.decode([GomaModels.Story].self, forKey: GomaModels.HomeContents.CodingKeys.stories)
        }
        
    }
    
    
    
}
