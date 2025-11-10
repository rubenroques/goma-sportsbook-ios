//
//  BannerResponse.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public struct BannerResponse: Codable {
    public var bannerItems: [EventBanner]

    enum CodingKeys: String, CodingKey {
        case bannerItems = "headlineItems"
    }
}
