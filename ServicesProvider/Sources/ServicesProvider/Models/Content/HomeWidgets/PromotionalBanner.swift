//
//  File.swift
//
//
//  Created by Ruben Roques on 30/05/2023.
//

import Foundation

public struct PromotionalBannersResponse: Codable, Equatable, Hashable {
    public var promotionalBannerItems: [PromotionalBanner]
}

public struct PromotionalBanner: Codable, Equatable, Hashable {
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

public enum BannerSpecialAction: Codable, Equatable, Hashable {
    case register
    case callToAction(url: String, text: String)
    case none
}

// AlertBanner has been moved to ServicesProvider/Models/Promotions/AlertBanner.swift
