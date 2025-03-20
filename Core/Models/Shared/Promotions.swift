//
//  Promotions.swift
//  Sportsbook
//
//  Created by André Lascas on 13/03/2025.
//

import Foundation

struct PromotionInfo: Codable {
    let id: Int
    let title: String
    let slug: String
    let sortOrder: Int
    let platform: String
    let status: String
    let userType: String
    let listDisplayNote: String?
    let listDisplayDescription: String?
    let listDisplayImageUrl: String
    let startDate: Date?
    let endDate: Date?
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
        case listDisplayImageUrl = "list_display_image_url"
        case startDate = "start_date"
        case endDate = "end_date"
        case staticPage = "static_page"
    }
}

struct StaticPage: Codable {
    let title: String
    let slug: String
    let headerTitle: String?
    let headerImageUrl: String?
    let isActive: Bool
    let usedForPromotions: Bool
    let platform: String
    let status: String
    let userType: String
    let startDate: Date?
    let endDate: Date?
    let sections: [SectionBlock]
    let terms: [TermItem]

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case slug = "slug"
        case headerTitle
        case headerImageUrl = "header_image_url"
        case isActive = "is_active"
        case usedForPromotions = "used_for_promotions"
        case platform = "platform"
        case status = "status"
        case userType = "user_type"
        case startDate = "start_date"
        case endDate = "end_date"
        case sections = "sections"
        case terms = "terms"
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
    
    enum CodingKeys: String, CodingKey {
        case bannerLinkUrl = "banner_link_url"
        case bannerType = "banner_type"
        case bannerLinkTarget = "banner_link_target"
        case imageUrl = "image_url"
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
    let label: String
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case label
        case sortOrder = "sort_order"
    }
}
