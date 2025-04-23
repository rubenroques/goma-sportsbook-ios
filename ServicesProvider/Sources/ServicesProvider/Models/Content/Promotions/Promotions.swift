//
//  Promotions.swift
//  ServicesProvider
//
//  Created by André Lascas on 17/03/2025.
//

import Foundation

public struct PromotionInfo: Codable {
    
    public let id: Int
    public let title: String
    public let slug: String
    public let sortOrder: Int
    public let platform: String
    public let status: String
    public let userType: String
    public let listDisplayNote: String?
    public let listDisplayDescription: String?
    public let listDisplayImageUrl: String
    public let startDate: Date?
    public let endDate: Date?
    public let staticPageSlug: String?
    public let staticPage: StaticPage?

    init(id: Int,
         title: String,
         slug: String,
         sortOrder: Int,
         platform: String,
         status: String,
         userType: String,
         listDisplayNote: String?,
         listDisplayDescription: String?,
         listDisplayImageUrl: String,
         startDate: Date?,
         endDate: Date?,
         staticPageSlug: String?,
         staticPage: StaticPage?)
    {
        self.id = id
        self.title = title
        self.slug = slug
        self.sortOrder = sortOrder
        self.platform = platform
        self.status = status
        self.userType = userType
        self.listDisplayNote = listDisplayNote
        self.listDisplayDescription = listDisplayDescription
        self.listDisplayImageUrl = listDisplayImageUrl
        self.startDate = startDate
        self.endDate = endDate
        self.staticPageSlug = staticPageSlug
        self.staticPage = staticPage
    }
}

public struct StaticPage: Codable {
    public let title: String
    public let slug: String
    public let headerImageUrl: String?
    public let isActive: Bool
    public let usedForPromotions: Bool
    public let platform: String
    public let status: String
    public let userType: String
    public let startDate: Date?
    public let endDate: Date?
    public let sections: [SectionBlock]
    public let terms: TermItem?

    init(title: String,
         slug: String,
         headerImageUrl: String?,
         isActive: Bool,
         usedForPromotions: Bool,
         platform: String,
         status: String,
         userType: String,
         startDate: Date?,
         endDate: Date?,
         sections: [SectionBlock],
         terms: TermItem?)
    {
        self.title = title
        self.slug = slug
        self.headerImageUrl = headerImageUrl
        self.isActive = isActive
        self.usedForPromotions = usedForPromotions
        self.platform = platform
        self.status = status
        self.userType = userType
        self.startDate = startDate
        self.endDate = endDate
        self.sections = sections
        self.terms = terms
    }
}

public struct SectionBlock: Codable {
    public let type: SectionPromoType?
    public let sortOrder: Int
    public let isActive: Bool
    public let banner: BannerBlock?
    public let text: TextBlock?
    public let list: ListBlock?

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case sortOrder = "sort_order"
        case isActive = "is_active"
        case banner = "banner"
        case text = "text"
        case list = "list"
    }
}

public struct BannerBlock: Codable {
    public let bannerLinkUrl: String?
    public let bannerType: BannerPromoType?
    public let bannerLinkTarget: String?
    public let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case bannerLinkUrl = "banner_link_url"
        case bannerType = "banner_type"
        case bannerLinkTarget = "banner_link_target"
        case imageUrl = "image_url"
    }
}

public struct TextBlock: Codable {
    public let sectionHighlighted: Bool?
    public let contentBlocks: [TextContentBlock]
    public let itemIcon: String?

    enum CodingKeys: String, CodingKey {
        case sectionHighlighted = "section_highlighted"
        case contentBlocks = "content_blocks"
        case itemIcon = "item_icon"
    }
}

public struct TextContentBlock: Codable {
    public let title: String?
    public let blockType: BlockPromoType?
    public let description: String?
    public let image: String?
    public let video: String?
    public let buttonURL: String?
    public let buttonText: String?
    public let buttonTarget: String?
    public let bulletedListItems: [BulletedListItem]?

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

public struct ListBlock: Codable {
    public let title: String?
    public let genericListItemsIcon: String?
    public let items: [TextBlock]
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case genericListItemsIcon = "generic_list_items_icon"
        case items = "items"
    }
}

public struct BulletedListItem: Codable {
    public let text: String
    
    enum CodingKeys: String, CodingKey {
        case text = "text"
    }
}

public struct TermItem: Codable {
    public let displayType: TermsDisplayType?
    public let richText: String?
    public let bulletedListItems: [BulletedListItem]?
    public let sortOrder: Int?

    enum CodingKeys: String, CodingKey {
        case displayType = "display_type"
        case richText = "rich_text"
        case bulletedListItems = "bulleted_list_items"
        case sortOrder = "sort_order"
    }
}

public enum SectionPromoType: Codable {
    case text
    case list
    case banner
    
    init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "text":
            self = .text
        case "list":
            self = .list
        case "banner":
            self = .banner
        default:
            return nil
        }
    }
}

public enum BlockPromoType: Codable {
    case title
    case description
    case image
    case video
    case button
    case bulletedList
    
    init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "title":
            self = .title
        case "description":
            self = .description
        case "image":
            self = .image
        case "video":
            self = .video
        case "button":
            self = .button
        case "bulletedList":
            self = .bulletedList
        default:
            return nil
        }
    }
}

public enum BannerPromoType: Codable {
    case image
    case video
    
    init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "image":
            self = .image
        case "video":
            self = .video
        default:
            return nil
        }
    }
}

public enum TermsDisplayType: Codable {
    case richText
    case bulletedList
    
    init?(rawValue: String) {
        switch rawValue {
        case "rich_text":
            self = .richText
        case "bulleted_list":
            self = .bulletedList
        default:
            return nil
        }
    }
}
