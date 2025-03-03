//
//  GomaModels+Promotions.swift
//
//
//  Created on: Feb 28, 2025
//

import Foundation

extension GomaModels {
    
    // MARK: - Home Template
    struct HomeTemplate: Equatable, Hashable, Codable {
        let id: Int
        let type: String
        let widgets: [HomeWidget]
        
        enum CodingKeys: String, CodingKey {
            case id
            case type = "name"
            case widgets
        }
    }
    
    struct HomeWidget: Equatable, Hashable, Codable {
        
        let id: Int
        let type: String
        let description: String
        let userType: String
        let sortOrder: Int
        let orientation: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case type = "name"
            case description = "description"
            case userType = "user_type"
            case sortOrder = "sort_order"
            case orientation = "orientation"
        }
    }
    
    typealias AlertBanners = [AlertBanner]
    struct AlertBanner: Identifiable, Equatable, Hashable, Codable {
        
        let id: Int
        let title: String
        let subtitle: String?
        let ctaText: String?
        let ctaUrl: String?
        let platform: String?
        let status: String?
        let startDate: String?
        let endDate: String?
        let userType: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case title
            case subtitle
            case ctaText = "cta_text"
            case ctaUrl = "cta_url"
            case platform
            case status
            case startDate = "start_date"
            case endDate = "end_date"
            case userType = "user_type"
        }
    }
    
    typealias Banners = [Banner]
    struct Banner: Identifiable, Equatable, Hashable, Codable {
        let id: Int
        let title: String
        let subtitle: String?
        let ctaText: String?
        let ctaUrl: String?
        let platform: String?
        let status: String?
        let startDate: Date?
        let endDate: Date?
        let userType: String?
        let imageUrl: URL?
        
        enum CodingKeys: String, CodingKey {
            case id
            case title
            case subtitle
            case ctaText = "cta_text"
            case ctaUrl = "cta_url"
            case platform
            case status
            case startDate = "start_date"
            case endDate = "end_date"
            case userType = "user_type"
            case imageUrl = "image_url"
        }
        
        init(
            id: Int,
            title: String,
            subtitle: String?,
            ctaText: String?,
            ctaUrl: String?,
            platform: String?,
            status: String?,
            startDate: Date?,
            endDate: Date?,
            userType: String?,
            imageUrl: URL?)
        {
            self.id = id
            self.title = title
            self.subtitle = subtitle
            self.ctaText = ctaText
            self.ctaUrl = ctaUrl
            self.platform = platform
            self.status = status
            self.startDate = startDate
            self.endDate = endDate
            self.userType = userType
            self.imageUrl = imageUrl
        }
    }
    
    typealias BoostedOddsBanners = [BoostedOddsBanner]
    struct BoostedOddsBanner: Identifiable, Equatable, Hashable, Codable {
        
        let id: Int
        let eventId: String
        let eventMarketId: String
        let title: String?
        let imageUrl: String?
        
        private enum CodingKeys: String, CodingKey {
            case id = "id"
            case eventId = "sport_event_id"
            case eventMarketId = "sport_event_market_id"
            case title = "title"
            case imageUrl = "image_url"
        }
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.BoostedOddsBanner.CodingKeys> = try decoder.container(keyedBy: GomaModels.BoostedOddsBanner.CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: GomaModels.BoostedOddsBanner.CodingKeys.id)
            self.eventId = try container.decode(String.self, forKey: GomaModels.BoostedOddsBanner.CodingKeys.eventId)
            self.eventMarketId = try container.decode(String.self, forKey: GomaModels.BoostedOddsBanner.CodingKeys.eventMarketId)
            self.title = try container.decodeIfPresent(String.self, forKey: GomaModels.BoostedOddsBanner.CodingKeys.title)
            self.imageUrl = try container.decodeIfPresent(String.self, forKey: GomaModels.BoostedOddsBanner.CodingKeys.imageUrl)
        }
    }
    
    typealias CarouselEvents = [CarouselEvent]
    struct CarouselEvent: Identifiable, Equatable, Hashable, Codable {
        
        let id: Int
        let eventId: String
        let eventMarketId: String
        let ctaUrl: String?
        let imageUrl: String?

        enum CodingKeys: String, CodingKey {
            case id
            case eventId = "sport_event_id"
            case eventMarketId = "sport_event_market_id"
            case ctaUrl = "cta_url"
            case imageUrl = "image_url"
        }
        
        init(id: Int, eventId: String, eventMarketId: String, ctaUrl: String?, imageUrl: String?) {
            self.id = id
            self.eventId = eventId
            self.eventMarketId = eventMarketId
            self.ctaUrl = ctaUrl
            self.imageUrl = imageUrl
        }
    }
    
    typealias HeroCardPointers = [HeroCardPointer]
    struct HeroCardPointer: Identifiable, Equatable, Hashable, Codable {
        
        let id: Int
        let eventId: String
        let eventMarketIds: [String]
        let imageUrl: String?
        
        private enum CodingKeys: String, CodingKey {
            case id
            case eventId = "sport_event_id"
            case eventMarketIds = "sport_event_market_ids"
            case imageUrl = "image_url"
        }
        
        init(id: Int, eventId: String, eventMarketIds: [String], imageUrl: String?) {
            self.id = id
            self.eventId = eventId
            self.eventMarketIds = eventMarketIds
            self.imageUrl = imageUrl
        }
    }
    
    
    typealias NewsItems = [NewsItem]
    struct NewsItem: Identifiable, Equatable, Hashable, Codable {
        let id: Int
        let title: String
        let subtitle: String?
        let content: String
        let author: String?
        let publishedDate: Date?
        let status: String?
        let imageUrl: String?
        let tags: [String]
        
        init(id: Int,
             title: String,
             subtitle: String?,
             content: String,
             author: String?,
             publishedDate: Date?,
             status: String?,
             imageUrl: String?,
             tags: [String]) {
            self.id = id
            self.title = title
            self.subtitle = subtitle
            self.content = content
            self.author = author
            self.publishedDate = publishedDate
            self.status = status
            self.imageUrl = imageUrl
            self.tags = tags
        }
    }
    
    typealias ProChoiceItems = [ProChoice]
    struct ProChoice: Identifiable, Equatable, Hashable, Codable {
        
        var id: String { eventId }
        let eventId: String
        let eventMarketId: String
        let imageUrl: String?
        
        enum CodingKeys: String, CodingKey {
            case eventId = "sport_event_id"
            case eventMarketId = "sport_event_market_id"
            case imageUrl = "image_url"
        }
        
        /// initializer
        /// - Parameters:
        ///   - sportEventId: Sport event identifier
        ///   - sportEventMarketId: Sport event market identifier
        ///   - imageUrl: Image URL for the pro choice
        init(
            eventId: String,
            eventMarketId: String,
            imageUrl: String?
        ) {
            self.eventId = eventId
            self.eventMarketId = eventMarketId
            self.imageUrl = imageUrl
        }
    }
    
    typealias Stories = [Story]
    /// Ephemeral promotional story (similar to social media stories)
    struct Story: Identifiable, Equatable, Hashable, Codable {
        /// Unique identifier
        let id: Int
        
        /// Story title
        let title: String
        
        /// Media type (image or video)
        let mediaType: String
        
        /// Call to action text
        let ctaText: String?
        
        /// Call to action URL
        let ctaUrl: String?
        
        /// Platform compatibility
        let platform: String?
        
        /// Status of the story
        let status: String?
        
        /// Start date when story should be displayed
        let startDate: Date?
        
        /// End date when story should stop being displayed
        let endDate: Date?
        
        /// User type the story is for
        let userType: String?
        
        /// Media URL for the story content
        let mediaUrl: String?
        
        /// Icon URL for the story thumbnail
        let iconUrl: String?
        
        /// Coding keys for JSON mapping
        private enum CodingKeys: String, CodingKey {
            case id
            case title
            case mediaType = "media_type"
            case ctaText = "cta_text"
            case ctaUrl = "cta_url"
            case platform
            case status
            case startDate = "start_date"
            case endDate = "end_date"
            case userType = "user_type"
            case mediaUrl = "media_url"
            case iconUrl = "icon_url"
        }
    }
    
}
