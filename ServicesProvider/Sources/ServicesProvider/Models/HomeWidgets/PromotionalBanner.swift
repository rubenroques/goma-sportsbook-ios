//
//  File.swift
//  
//
//  Created by Ruben Roques on 30/05/2023.
//

import Foundation

public struct PromotionalBannersResponse: Codable {
    public var promotionalBannerItems: [PromotionalBanner]
}

public struct PromotionalBanner: Codable {
     public let id: String
     public let name: String?
     public let bannerType: String?
     public let imageURL: String?
     public let bannerDisplay: String?
     public let linkType: String?
     public let location: String?
     public let bannerContents: [String]?
}
