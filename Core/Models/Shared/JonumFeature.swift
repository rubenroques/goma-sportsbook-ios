//
//  JonumFeature.swift
//  Sportsbook
//
//  Created by André Lascas on 07/07/2025.
//

import Foundation

struct JonumFeature: Codable {
    
    var isActive: Bool
    var url: String
    var icon: String
    var name: String
    var banner: String
    
    enum CodingKeys: String, CodingKey {
        case isActive = "is_active"
        case url = "url"
        case icon = "icon"
        case name = "name"
        case banner = "banner"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let isActiveInt = try container.decode(Int.self, forKey: .isActive)
        self.isActive = isActiveInt == 1
        
        self.url = try container.decode(String.self, forKey: .url)
        
        self.icon = try container.decode(String.self, forKey: .icon)
        
        self.name = try container.decode(String.self, forKey: .name)

        self.banner = try container.decode(String.self, forKey: .banner)
    }
}
