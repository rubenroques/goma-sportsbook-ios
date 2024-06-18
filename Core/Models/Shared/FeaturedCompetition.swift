//
//  FeaturedCompetition.swift
//  Sportsbook
//
//  Created by André Lascas on 17/06/2024.
//

import Foundation

struct FeaturedCompetition: Codable {
    
    var id: String?
    var homeBanner: String?
    var bottomBarIcon: String?
    var bottomBarName: String?
    var pageDetailBanner: String?
    var pageDetailBackground: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case homeBanner = "home_banner"
        case bottomBarIcon = "bottom_bar_icon"
        case bottomBarName = "bottom_bar_name"
        case pageDetailBanner = "page_detail_banner"
        case pageDetailBackground = "page_detail_bg"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let idString = try? container.decodeIfPresent(String.self, forKey: .id),
           idString.isNotEmpty {
            self.id = idString
        }
        else if let idDouble = try? container.decodeIfPresent(Double.self, forKey: .id) {

            self.id = String(format: "%.1f", idDouble)
        }
        else {
            self.id = nil
        }
        
        self.homeBanner = try container.decodeIfPresent(String.self, forKey: .homeBanner)
        
        self.bottomBarIcon = try container.decodeIfPresent(String.self, forKey: .bottomBarIcon)
        
        self.bottomBarName = try container.decodeIfPresent(String.self, forKey: .bottomBarName)
        
        self.pageDetailBanner = try container.decodeIfPresent(String.self, forKey: .pageDetailBanner)
        
        self.pageDetailBackground = try container.decodeIfPresent(String.self, forKey: .pageDetailBackground)
    }
}
