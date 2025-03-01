//
//  BannerAlert.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 19/02/2025.
//

import Foundation

public struct BannerAlert: Codable {
    
    public var identifier: String
    public var title: String?
    public var subtitle: String?
    public var callToActionText: String?
    public var callToActionUrl: String?
    public var isActive: Int?
    public var createdAt: String?
    public var updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case title = "title"
        case subtitle = "subtitle"
        case callToActionText = "cta_text"
        case callToActionUrl = "cta_url"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(identifier: String,
         title: String?,
         subtitle: String?,
         ctaText: String?,
         ctaUrl: String?,
         isActive: Int?,
         createdAt: String?,
         updatedAt: String?)
    {
        self.identifier = identifier
        self.title = title
        self.subtitle = subtitle
        self.callToActionText = ctaText
        self.callToActionUrl = ctaUrl
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
