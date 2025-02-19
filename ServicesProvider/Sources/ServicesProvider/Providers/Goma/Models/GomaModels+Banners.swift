//
//  File.swift
//  
//
//  Created by Ruben Roques on 08/01/2024.
//

import Foundation

extension GomaModels {
    
    // MARK: - BannerAlert
    struct BannerAlert: Codable {
        var identifier: String
        var title: String?
        var subtitle: String?
        var callToActionText: String?
        var callToActionUrl: String?
        var isActive: Int?
        var createdAt: String?
        var updatedAt: String?
        
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
             title: String,
             subtitle: String,
             ctaText: String,
             ctaUrl: String,
             isActive: Int,
             createdAt: String,
             updatedAt: String)
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
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.BannerAlert.CodingKeys> = try decoder.container(keyedBy: GomaModels.BannerAlert.CodingKeys.self)
            
            if let idValue = try? container.decode(Int.self, forKey: CodingKeys.identifier) {
                self.identifier = String(idValue)
            }
            else if let idStringValue = try? container.decode(String.self, forKey: CodingKeys.identifier) {
                self.identifier = idStringValue
            }
            else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Key not found")
                let error = DecodingError.keyNotFound(CodingKeys.identifier, context)
                throw error
            }
            
            self.title = try container.decodeIfPresent(String.self, forKey: GomaModels.BannerAlert.CodingKeys.title)
            self.subtitle = try container.decodeIfPresent(String.self, forKey: GomaModels.BannerAlert.CodingKeys.subtitle)
            self.callToActionText = try container.decodeIfPresent(String.self, forKey: GomaModels.BannerAlert.CodingKeys.callToActionText)
            self.callToActionUrl = try container.decodeIfPresent(String.self, forKey: GomaModels.BannerAlert.CodingKeys.callToActionUrl)
            self.isActive = try container.decodeIfPresent(Int.self, forKey: GomaModels.BannerAlert.CodingKeys.isActive)
            self.createdAt = try container.decodeIfPresent(String.self, forKey: GomaModels.BannerAlert.CodingKeys.createdAt)
            self.updatedAt = try container.decodeIfPresent(String.self, forKey: GomaModels.BannerAlert.CodingKeys.updatedAt)
        }
    }
    
    // MARK: - Banner
    struct Banner: Codable {
        var identifier: String
        var title: String?
        var subtitle: String?
        var imageUrl: String?
        var callToActionText: String?
        var callToActionUrl: String?
        var isActive: Int?
        
        enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case title = "title"
            case subtitle = "subtitle"
            case imageUrl = "image_url"
            case callToActionText = "cta_text"
            case callToActionUrl = "cta_url"
            case isActive = "is_active"
        }
        
        init(identifier: String,
             title: String,
             subtitle: String,
             imageUrl: String,
             ctaText: String,
             ctaUrl: String,
             isActive: Int)
        {
            self.identifier = identifier
            self.title = title
            self.subtitle = subtitle
            self.imageUrl = imageUrl
            self.callToActionText = ctaText
            self.callToActionUrl = ctaUrl
            self.isActive = isActive
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.Banner.CodingKeys> = try decoder.container(keyedBy: GomaModels.Banner.CodingKeys.self)
            
            if let idValue = try? container.decode(Int.self, forKey: CodingKeys.identifier) {
                self.identifier = String(idValue)
            }
            else if let idStringValue = try? container.decode(String.self, forKey: CodingKeys.identifier) {
                self.identifier = idStringValue
            }
            else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Key not found")
                let error = DecodingError.keyNotFound(CodingKeys.identifier, context)
                throw error
            }
            
            self.title = try container.decodeIfPresent(String.self, forKey: GomaModels.Banner.CodingKeys.title)
            self.subtitle = try container.decodeIfPresent(String.self, forKey: GomaModels.Banner.CodingKeys.subtitle)
            self.imageUrl = try container.decodeIfPresent(String.self, forKey: GomaModels.Banner.CodingKeys.imageUrl)
            self.callToActionText = try container.decodeIfPresent(String.self, forKey: GomaModels.Banner.CodingKeys.callToActionText)
            self.callToActionUrl = try container.decodeIfPresent(String.self, forKey: GomaModels.Banner.CodingKeys.callToActionUrl)
            self.isActive = try container.decodeIfPresent(Int.self, forKey: GomaModels.Banner.CodingKeys.isActive)
        }
        
    }
    
    // MARK: - Banner
    struct AlertBanner: Codable {
        var identifier: String
        var title: String
        var subtitle: String?
        var callToActionText: String?
        var callToActionUrl: String?
        var isActive: Int?
        
        enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case title = "title"
            case subtitle = "subtitle"
            case callToActionText = "cta_text"
            case callToActionUrl = "cta_url"
            case isActive = "is_active"
        }
        
        init(identifier: String,
             title: String,
             subtitle: String,
             ctaText: String,
             ctaUrl: String,
             isActive: Int)
        {
            self.identifier = identifier
            self.title = title
            self.subtitle = subtitle
            self.callToActionText = ctaText
            self.callToActionUrl = ctaUrl
            self.isActive = isActive
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            
            if let idValue = try? container.decode(Int.self, forKey: CodingKeys.identifier) {
                self.identifier = String(idValue)
            }
            else if let idStringValue = try? container.decode(String.self, forKey: CodingKeys.identifier) {
                self.identifier = idStringValue
            }
            else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Key not found")
                let error = DecodingError.keyNotFound(CodingKeys.identifier, context)
                throw error
            }
            
            self.title = try container.decode(String.self, forKey: CodingKeys.title)
            self.subtitle = try container.decodeIfPresent(String.self, forKey: CodingKeys.subtitle)
            self.callToActionText = try container.decodeIfPresent(String.self, forKey: CodingKeys.callToActionText)
            self.callToActionUrl = try container.decodeIfPresent(String.self, forKey: CodingKeys.callToActionUrl)
            self.isActive = try container.decodeIfPresent(Int.self, forKey: CodingKeys.isActive)
        }
        
    }
    
    struct Story: Codable {
        
        var identifier: String
        var title: String
        var iconUrl: String
        var mediaUrl: String
        var mediaType: String
        var callToActionText: String
        var callToActionUrl: String
        var isActive: Int
        var createdAt: String
        var updatedAt: String

        enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case title = "title"
            case iconUrl = "icon_url"
            case mediaUrl = "media_url"
            case mediaType = "media_type"
            case callToActionText = "cta_text"
            case callToActionUrl = "cta_url"
            case isActive = "is_active"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
        }

        init(identifier: String,
             title: String,
             iconUrl: String,
             mediaUrl: String,
             mediaType: String,
             callToActionText: String,
             callToActionUrl: String,
             isActive: Int,
             createdAt: String,
             updatedAt: String)
        {
            self.identifier = identifier
            self.title = title
            self.iconUrl = iconUrl
            self.mediaUrl = mediaUrl
            self.mediaType = mediaType
            self.callToActionText = callToActionText
            self.callToActionUrl = callToActionUrl
            self.isActive = isActive
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.Story.CodingKeys> = try decoder.container(keyedBy: GomaModels.Story.CodingKeys.self)
            
            if let idValue = try? container.decode(Int.self, forKey: CodingKeys.identifier) {
                self.identifier = String(idValue)
            }
            else if let idStringValue = try? container.decode(String.self, forKey: CodingKeys.identifier) {
                self.identifier = idStringValue
            }
            else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Key not found")
                let error = DecodingError.keyNotFound(CodingKeys.identifier, context)
                throw error
            }
            
            self.title = try container.decode(String.self, forKey: GomaModels.Story.CodingKeys.title)
            self.iconUrl = try container.decode(String.self, forKey: GomaModels.Story.CodingKeys.iconUrl)
            self.mediaUrl = try container.decode(String.self, forKey: GomaModels.Story.CodingKeys.mediaUrl)
            self.mediaType = try container.decode(String.self, forKey: GomaModels.Story.CodingKeys.mediaType)
            self.callToActionText = try container.decode(String.self, forKey: GomaModels.Story.CodingKeys.callToActionText)
            self.callToActionUrl = try container.decode(String.self, forKey: GomaModels.Story.CodingKeys.callToActionUrl)
            self.isActive = try container.decode(Int.self, forKey: GomaModels.Story.CodingKeys.isActive)
            self.createdAt = try container.decode(String.self, forKey: GomaModels.Story.CodingKeys.createdAt)
            self.updatedAt = try container.decode(String.self, forKey: GomaModels.Story.CodingKeys.updatedAt)
        }
        
    }
    
    class SportAssociatedEventBanner: Codable {
        
        var identifier: String
        var title: String?
        var sportEventId: Int?
        var imageUrl: String?
        var callToActionUrl: String?
        var isActive: Int?
        var createdAt: String?
        var updatedAt: String?
        var event: Event

        enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case title = "title"
            case sportEventId = "sport_event_id"
            case imageUrl = "image_url"
            case callToActionUrl = "cta_url"
            case isActive = "is_active"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case event = "event"
        }

        init(identifier: String,
             title: String?,
             sportEventId: Int?,
             imageUrl: String?,
             callToActionUrl: String?,
             isActive: Int?,
             createdAt: String?,
             updatedAt: String?,
             event: Event)
        {
            self.identifier = identifier
            self.title = title
            self.sportEventId = sportEventId
            self.imageUrl = imageUrl
            self.callToActionUrl = callToActionUrl
            self.isActive = isActive
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.event = event
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let idValue = try? container.decode(Int.self, forKey: CodingKeys.identifier) {
                self.identifier = String(idValue)
            }
            else if let idStringValue = try? container.decode(String.self, forKey: CodingKeys.identifier) {
                self.identifier = idStringValue
            }
            else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Key not found")
                let error = DecodingError.keyNotFound(CodingKeys.identifier, context)
                throw error
            }
            
            self.title = try container.decodeIfPresent(String.self, forKey: CodingKeys.title)
            self.sportEventId = try container.decodeIfPresent(Int.self, forKey: CodingKeys.sportEventId)
            self.imageUrl = try container.decodeIfPresent(String.self, forKey: CodingKeys.imageUrl)
            self.callToActionUrl = try container.decodeIfPresent(String.self, forKey: CodingKeys.callToActionUrl)
            self.isActive = try container.decodeIfPresent(Int.self, forKey: CodingKeys.isActive)
            self.createdAt = try container.decodeIfPresent(String.self, forKey: CodingKeys.createdAt)
            self.updatedAt = try container.decodeIfPresent(String.self, forKey: CodingKeys.updatedAt)
            self.event = try container.decode(GomaModels.Event.self, forKey: CodingKeys.event)
        }
    }
    
}
