//
//  Promotions.swift
//  Sportsbook
//
//  Created by André Lascas on 13/03/2025.
//

import Foundation

struct PromotionInfo2 {
    var id: String
    var title: String
    var background: String
    var date: String
    var description: String
    var headerTitle: String?
    var headerImage: String?
}

// MARK: - Welcome
struct PromotionsResponse: Codable {
    let promotionsInfo: [PromotionInfo]
}

// MARK: - Promotion
struct PromotionInfo: Codable {
    let id: Int
    let title: String
    let slug: String
    let sortOrder: Int
    let platform: String
    let status: String
    let userType: String
    let listDisplayNote: String
    let listDisplayDescription, startDate, endDate: String
    let staticPage: StaticPage

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case slug = "slug"
        case sortOrder = "sort_order"
        case platform = "platform"
        case status = "status"
        case userType = "user_type"
        case listDisplayNote = "list_display_note"
        case listDisplayDescription = "list_display_description"
        case startDate = "start_date"
        case endDate = "end_date"
        case staticPage = "static_page"
    }
}

// MARK: - StaticPage
struct StaticPage: Codable {
    let title: String
    let slug: String
    let headerTitle: String?
    let headerImage: String?
    let isActive: Bool
    let usedForPromotions: Bool
    let platform: String
    let status: String
    let userType: String
    let startDate: String
    let endDate: String
    let sections: [SectionBlock]
    let terms: [TermItem]

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case slug = "slug"
        case headerTitle
        case headerImage
        case isActive = "is_active"
        case usedForPromotions = "used_for_promotions"
        case platform = "platform"
        case status = "status"
        case userType = "user_type"
        case startDate = "start_date"
        case endDate = "end_date"
        case sections = "section"
        case terms = "terms"
    }
}

// MARK: - Section
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
    
    enum CodingKeys: String, CodingKey {
        case bannerLinkUrl = "banner_link_url"
        case bannerType = "banner_type"
        case bannerLinkTarget = "banner_link_target"
    }
}

// MARK: - List
struct ListBlock: Codable {
    let title: String?
    let items: [ItemBlock]
}

// MARK: - Item
struct ItemBlock: Codable {
    let contentBlocks: [ItemContentBlock]

    enum CodingKeys: String, CodingKey {
        case contentBlocks = "content_blocks"
    }
}

// MARK: - ItemContentBlock
struct ItemContentBlock: Codable {
    let blockType: String
    let title: String?
    let description: String?
    let image: String?

    enum CodingKeys: String, CodingKey {
        case blockType = "block_type"
        case title = "title"
        case description = "description"
        case image = "image"
    }
}

// MARK: - Text
struct TextBlock: Codable {
    let sectionHighlighted: Bool
    let contentBlocks: [TextContentBlock]

    enum CodingKeys: String, CodingKey {
        case sectionHighlighted = "section_highlighted"
        case contentBlocks = "content_blocks"
    }
}

// MARK: - TextContentBlock
struct TextContentBlock: Codable {
    let title: String?
    let blockType: String
    let description: String?
    let image: String?
    let video: String?
    let buttonURL: String?
    let buttonText: String?
    let buttonTarget: String?

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case blockType = "block_type"
        case description = "description"
        case image = "image"
        case video = "video"
        case buttonURL = "button_url"
        case buttonText = "button_text"
        case buttonTarget = "button_target"
    }
}

// MARK: - Term
struct TermItem: Codable {
    let label: String
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case label
        case sortOrder = "sort_order"
    }
}
