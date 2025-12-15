//
//  File.swift
//  
//
//  Created by Ruben Roques on 30/05/2023.
//

import Foundation

public struct PromotionalBannersResponse {
    public var promotionalBannerItems: [PromotionalBanner]
}

public struct PromotionalBanner {
    public let id: String
    public let name: String?
    public let bannerType: String?
    public let imageURL: String?
    public let bannerDisplay: String?
    public let linkType: String?
    public let location: String?
    public let bannerContents: [String]?
    public let specialAction: BannerSpecialAction
}

public enum BannerSpecialAction {
    case register
    case none
}
