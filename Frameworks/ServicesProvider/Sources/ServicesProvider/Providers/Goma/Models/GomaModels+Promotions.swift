//
//  GomaModels+Promotions.swift
//
//
//  Created on: Feb 28, 2025
//

import Foundation
import SharedModels

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

    typealias BoostedOddsPointers = [BoostedOddsPointer]
    struct BoostedOddsPointer: Identifiable, Equatable, Hashable, Codable {

        let id: Int
        let eventId: String
        let eventMarketId: String
        let boostedEventMarketId: String

        private enum CodingKeys: String, CodingKey {
            case id = "id"
            case eventId = "sport_event_id"
            case eventMarketId = "sport_event_market_id"
            case boostedEventMarketId = "sport_event_boosted_market_id"
        }

        init(id: Int, eventId: String, eventMarketId: String, boostedEventMarketId: String) {
            self.id = id
            self.eventId = eventId
            self.eventMarketId = eventMarketId
            self.boostedEventMarketId = boostedEventMarketId
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: .id)
            self.eventId = try container.decode(String.self, forKey: .eventId)
            self.eventMarketId = try container.decode(String.self, forKey: .eventMarketId)
            self.boostedEventMarketId = try container.decode(String.self, forKey: .boostedEventMarketId)
        }
    }

    typealias TopImageCardPointers = [TopImageCardPointer]
    struct TopImageCardPointer: Codable, Equatable, Hashable {
        let eventId: String
        let eventMarketId: String
        let imageUrl: String?

        private enum CodingKeys: String, CodingKey {
            case eventId = "sport_event_id"
            case eventMarketId = "sport_event_market_id"
            case imageUrl = "image_url"
        }
    }

    typealias CarouselEventPointers = [CarouselEventPointer]
    struct CarouselEventPointer: Identifiable, Equatable, Hashable, Codable {

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

    typealias ProChoiceCardPointers = [ProChoiceCardPointer]
    struct ProChoiceCardPointer: Identifiable, Equatable, Hashable, Codable {

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
        
        let backgroundImageUrl: String?

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
            case backgroundImageUrl = "background_url"
        }
    }

    /*
    Top Competitions json response: ["55807.1", "55834.1", "55806.1", "55852.1"]
    */
    typealias TopCompetitionPointers = [TopCompetitionPointer]
    typealias TopCompetitionPointer = String

    struct PromotionInfo: Codable {
        let id: Int
        let title: String
        let slug: String
        let tag: String?
        let hasReadMoreButton: Bool
        let ctaText: String?
        let ctaUrl: String?
        let ctaTarget: String?
        let sortOrder: Int
        let platform: String
        let status: String
        let userType: String
        let listDisplayNote: String?
        let listDisplayDescription: String?
        let listDisplayImageUrl: String
        let startDate: String?
        let endDate: String?
        let staticPageSlug: String?
        let staticPage: StaticPage?
        let categories: [PromotionCategory]?

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case title = "title"
            case slug = "slug"
            case tag = "tag"
            case hasReadMoreButton = "has_read_more_button"
            case ctaText = "cta_text"
            case ctaUrl = "cta_url"
            case ctaTarget = "cta_target"
            case sortOrder = "sort_order"
            case platform = "platform"
            case status = "status"
            case userType = "user_type"
            case listDisplayNote = "list_display_note"
            case listDisplayDescription = "list_display_description"
            case listDisplayImageUrl = "list_display_image_url"
            case startDate = "start_date"
            case endDate = "end_date"
            case staticPageSlug = "static_page_slug"
            case staticPage = "static_page"
            case categories = "categories"
        }
    }

    struct PromotionCategory: Codable, Equatable, Hashable {
        let id: Int
        let name: String
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
        }
    }
    
    struct StaticPage: Codable {
        let title: String
        let slug: String
        let headerImageUrl: String?
        let isActive: Bool
        let usedForPromotions: Bool
        let platform: String
        let status: String
        let userType: String
        let startDate: String?
        let endDate: String?
        let sections: [SectionBlock]
        let terms: TermItem?

        enum CodingKeys: String, CodingKey {
            case title = "title"
            case slug = "slug"
            case headerImageUrl = "header_image_url"
            case isActive = "is_active"
            case usedForPromotions = "used_for_promotions"
            case platform = "platform"
            case status = "status"
            case userType = "user_type"
            case startDate = "start_date"
            case endDate = "end_date"
            case sections = "sections"
            case terms = "terms_and_conditions"
        }
    }

    struct SectionBlock: Codable {
        let type: String
        let sortOrder: Int
        let isActive: Bool
        let banner: BannerBlock?
        let text: TextBlock?
        let list: ListBlock?

        enum CodingKeys: String, CodingKey {
            case type = "type"
            case sortOrder = "sort_order"
            case isActive = "is_active"
            case banner = "banner"
            case text = "text"
            case list = "list"
        }
    }

    struct BannerBlock: Codable {
        let bannerLinkUrl: String?
        let bannerType: String
        let bannerLinkTarget: String?
        let imageUrl: String?
        let videoUrl: String?
        
        enum CodingKeys: String, CodingKey {
            case bannerLinkUrl = "banner_link_url"
            case bannerType = "banner_type"
            case bannerLinkTarget = "banner_link_target"
            case imageUrl = "image_url"
            case videoUrl = "video_url"
        }
    }

    struct TextBlock: Codable {
        let sectionHighlighted: Bool?
        let contentBlocks: [TextContentBlock]
        let itemIcon: String?

        enum CodingKeys: String, CodingKey {
            case sectionHighlighted = "section_highlighted"
            case contentBlocks = "content_blocks"
            case itemIcon = "item_icon"
        }
    }

    struct TextContentBlock: Codable {
        let title: String?
        let blockType: String
        let description: String?
        let image: String?
        let video: String?
        let buttonURL: String?
        let buttonText: String?
        let buttonTarget: String?
        let bulletedListItems: [BulletedListItem]?

        enum CodingKeys: String, CodingKey {
            case title = "title"
            case blockType = "block_type"
            case description = "description"
            case image = "image"
            case video = "video"
            case buttonURL = "button_url"
            case buttonText = "button_text"
            case buttonTarget = "button_target"
            case bulletedListItems = "bulleted_list_items"
        }
    }

    struct ListBlock: Codable {
        let title: String?
        let genericListItemsIcon: String?
        let items: [TextBlock]
        
        enum CodingKeys: String, CodingKey {
            case title = "title"
            case genericListItemsIcon = "generic_list_items_icon"
            case items = "items"
        }
    }

    struct BulletedListItem: Codable {
        let text: String
        
        enum CodingKeys: String, CodingKey {
            case text = "text"
        }
    }

    struct TermItem: Codable {
        let displayType: String
        let richText: String?
        let bulletedListItems: [BulletedListItem]?
        let sortOrder: Int?

        enum CodingKeys: String, CodingKey {
            case displayType = "display_type"
            case richText = "rich_text"
            case bulletedListItems = "bulleted_list_items"
            case sortOrder = "sort_order"
        }
    }

    // MARK: - Legacy Casino Carousel (for backward compatibility)
    typealias CasinoCarouselPointers = [CasinoCarouselPointer]

    struct CasinoCarouselPointer: Identifiable, Equatable, Hashable, Codable {
        let id: Int
        let type: String
        let title: String?
        let subtitle: String?
        let casinoGameId: String?
        let ctaText: String?
        let ctaUrl: String?
        let ctaTarget: String?
        let imageUrl: String?

        enum CodingKeys: String, CodingKey {
            case id, type, title, subtitle
            case casinoGameId = "casino_game_id"
            case ctaText = "cta_text"
            case ctaUrl = "cta_url"
            case ctaTarget = "cta_target"
            case imageUrl = "image_url"
        }
    }

    // MARK: - Rich Banners (Unified Casino + Sport Banners)
    typealias RichBanners = [RichBanner]

    enum RichBanner: Identifiable, Equatable, Hashable, Codable {
        case info(InfoBannerData)
        case casinoGame(CasinoGameBannerData)
        case sportEvent(SportEventBannerData)

        var id: String {
            switch self {
            case .info(let data): return String(data.id)
            case .casinoGame(let data): return String(data.id)
            case .sportEvent(let data): return String(data.id)
            }
        }

        struct InfoBannerData: Identifiable, Equatable, Hashable, Codable {
            let id: Int
            let title: String?
            let subtitle: String?
            let ctaText: String?
            let ctaUrl: String?
            let ctaTarget: String?
            let imageUrl: String?

            enum CodingKeys: String, CodingKey {
                case id, title, subtitle
                case ctaText = "cta_text"
                case ctaUrl = "cta_url"
                case ctaTarget = "cta_target"
                case imageUrl = "image_url"
            }
        }

        struct CasinoGameBannerData: Identifiable, Equatable, Hashable, Codable {
            let id: Int
            let title: String?
            let subtitle: String?
            let casinoGameId: String
            let ctaText: String?
            let ctaUrl: String?
            let ctaTarget: String?
            let imageUrl: String?

            enum CodingKeys: String, CodingKey {
                case id, title, subtitle
                case casinoGameId = "casino_game_id"
                case ctaText = "cta_text"
                case ctaUrl = "cta_url"
                case ctaTarget = "cta_target"
                case imageUrl = "image_url"
            }
        }

        struct SportEventBannerData: Identifiable, Equatable, Hashable, Codable {
            let id: Int
            let sportEventId: String
            let sportEventMarketId: String
            let imageUrl: String?
            let marketBettingTypeId: String?
            let marketEventPartId: String?

            enum CodingKeys: String, CodingKey {
                case id
                case sportEventId = "sport_event_id"
                case sportEventMarketId = "sport_event_market_id"
                case imageUrl = "image_url"
                case marketBettingTypeId = "market_betting_type_id"
                case marketEventPartId = "market_event_part_id"
            }
        }

        enum CodingKeys: String, CodingKey {
            case type
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)

            switch type {
            case "info":
                let content = try InfoBannerData(from: decoder)
                self = .info(content)
            case "game":
                let content = try CasinoGameBannerData(from: decoder)
                self = .casinoGame(content)
            case "event":
                let content = try SportEventBannerData(from: decoder)
                self = .sportEvent(content)
            default:
                throw DecodingError.dataCorruptedError(
                    forKey: .type,
                    in: container,
                    debugDescription: "Unknown banner type: \(type)"
                )
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            switch self {
            case .info(let content):
                try container.encode("info", forKey: .type)
                try content.encode(to: encoder)
            case .casinoGame(let content):
                try container.encode("game", forKey: .type)
                try content.encode(to: encoder)
            case .sportEvent(let content):
                try container.encode("event", forKey: .type)
                try content.encode(to: encoder)
            }
        }
    }

}
