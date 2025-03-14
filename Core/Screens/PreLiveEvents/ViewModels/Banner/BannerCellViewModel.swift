//
//  BannerCellViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 21/10/2021.
//

import Foundation
import Combine
import ServicesProvider

class BannerLineCellViewModel {

    var banners: [BannerCellViewModel]

    init(banners: [BannerCellViewModel]) {
        self.banners = banners
    }
}

class BannerCellViewModel {
    var id: String
    var title: String
    var subtitle: String?
    var imageURL: URL?
    var ctaUrl: String?
    var ctaText: String?
    
    init(id: String, matchId: String?, imageURL: String, marketId: String?, location: String?) {
        self.id = id
        self.title = ""
        self.subtitle = nil
        self.imageURL = URL(string: imageURL)
        self.ctaUrl = nil
        self.ctaText = nil
    }
    
    init(bannerInfo: BannerInfo) {
        self.id = bannerInfo.id
        self.title = bannerInfo.title
        self.subtitle = bannerInfo.subtitle
        self.imageURL = URL(string: bannerInfo.imageURL ?? "")
        self.ctaUrl = bannerInfo.ctaUrl
        self.ctaText = bannerInfo.ctaText
    }
}
