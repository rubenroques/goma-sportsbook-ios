//
//  File.swift
//  Sportsbook
//
//  Created by André Lascas on 08/02/2022.
//

import Foundation

struct UserSettingsGomaResponse: Codable {
    var settings: UserSettingsGoma

    enum CodingKeys: String, CodingKey {
        case settings = "settings"
    }
}

struct UserSettingsGoma: Codable {

    var oddValidationType: String
    var notifications: Int
    var notificationGamesWatchlist: Int
    var notificationsCompetitionsWatchlist: Int
    var notificationGoal: Int
    var notificationsStartgame: Int
    var notificationsHalftime: Int
    var notificationsFulltime: Int
    var notificationsSecondhalf: Int
    var notificationsRedcard: Int
    var notificationsBets: Int
    var notificationBetSelections: Int
    var notificationEmail: Int
    var notificationSms: Int

    enum CodingKeys: String, CodingKey {
        case oddValidationType = "odd_validation_type"
        case notifications = "notifications"
        case notificationGamesWatchlist = "notifications_games_watchlist"
        case notificationsCompetitionsWatchlist = "notifications_competitions_watchlist"
        case notificationGoal = "notifications_goal"
        case notificationsStartgame = "notifications_startgame"
        case notificationsHalftime = "notifications_halftime"
        case notificationsFulltime = "notifications_fulltime"
        case notificationsSecondhalf = "notifications_secondhalf"
        case notificationsRedcard = "notifications_redcard"
        case notificationsBets = "notifications_bets"
        case notificationBetSelections = "notification_bet_selections"
        case notificationEmail = "notification_email"
        case notificationSms = "notification_sms"
    }
    
}

struct BusinessInstanceSettingsResponse: Decodable {

    var homeFeedTemplate: HomeFeedTemplate?

    enum CodingKeys: String, CodingKey {
        case settings = "settings"
        case clients = "clients"
        case dazn = "dazn"
        case everymatrix = "everymatrix"
        case crocobet = "crocobet"
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        let settingsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .settings)
        let clientsContainer = try settingsContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .clients)

        if let homeTemplateKey = TargetVariables.homeTemplateKey {
            let clientKey = BusinessInstanceSettingsResponse.CodingKeys(rawValue: homeTemplateKey)!
            self.homeFeedTemplate = try clientsContainer.decode(HomeFeedTemplate.self, forKey: clientKey)
        }
        else {
            self.homeFeedTemplate = nil
        }

    }

}

struct HomeFeedTemplate: Decodable {
    var feedContents: [HomeFeedContent]

    enum CodingKeys: String, CodingKey {
        case homeTemplate = "home_template"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let feedItems = try container.decode([FailableDecodable<HomeFeedContent>].self, forKey: .homeTemplate)
        self.feedContents = feedItems.compactMap({ $0.base })
    }
}

enum HomeFeedContent: Decodable {

    case banners(items: [BannerItemFeedContent])
    case favorites
    case suggestedBets
    case userMessageAlerts
    case sport(id: String, name: String, sections: [SportSectionFeedContent])
    case featuredTips
    case unknown

    private enum CodingKeys: String, CodingKey {
        case type = "section_type"
        case source = "source"
        case contents = "contents"
        case sections = "sections"
        case sportId = "sport_id"
    }

    public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = (try? container.decode(String.self, forKey: .type)) ?? ""
        // let source = (try? container.decode(String.self, forKey: .source)) ?? ""
        let sportId = try? container.decode(String.self, forKey: .sportId)

        switch type {
        case "banners":
            let contentsRaw = try container.decode([FailableDecodable<BannerItemFeedContent>].self, forKey: .contents)
            self = .banners(items: contentsRaw.compactMap({ $0.base }))
        case "favorites":
            self = .favorites
        case "tips":
            self = .featuredTips
        case "suggested":
            self = .suggestedBets
        case "user_alert_messages":
            self = .userMessageAlerts
        default:
            if let sportId = sportId {
                let contentsRaw = try container.decode([FailableDecodable<SportSectionFeedContent>].self, forKey: .sections)
                self = .sport(id: sportId, name: type, sections: contentsRaw.compactMap({ $0.base }))
            }
            else {
                self = .unknown
            }
        }
    }
}

enum SportSectionFeedContent: Decodable {

    case popular(title: String)
    case popularVideos(title: String, contents: [VideoItemFeedContent])
    case live(title: String)
    case liveVideos(title: String, contents: [VideoItemFeedContent])
    case competitions(title: String)
    case competitionsVideos(title: String, contents: [VideoItemFeedContent])
    case unknown

    private enum CodingKeys: String, CodingKey {
        case type = "section_type"
        case source = "source"
        case sectionName = "section_name"
        case contents = "contents"
    }

    public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = (try? container.decode(String.self, forKey: .type)) ?? ""
        let title = (try? container.decode(String.self, forKey: .sectionName)) ?? ""

        switch type {
        case "popular":
            self = .popular(title: title)
        case "popular - videos":
            let videoItemsContents = try container.decode([FailableDecodable<VideoItemFeedContent>].self, forKey: .contents).compactMap({ $0.base })
            self = .popularVideos(title: title, contents: videoItemsContents)
        case "live":
            self = .live(title: title)
        case "live - videos":
            let videoItemsContents = try container.decode([FailableDecodable<VideoItemFeedContent>].self, forKey: .contents).compactMap({ $0.base })
            self = .liveVideos(title: title, contents: videoItemsContents)
        case "competitions":
            self = .competitions(title: title)
        case "competitions - videos":
            let videoItemsContents = try container.decode([FailableDecodable<VideoItemFeedContent>].self, forKey: .contents).compactMap({ $0.base })
            self = .competitionsVideos(title: title, contents: videoItemsContents)
        default:
            self = .unknown
        }
    }
}

struct VideoItemFeedContent: Codable {

    var title: String?
    var description: String?
    var imageURL: String?
    var streamURL: String?

    private enum CodingKeys: String, CodingKey {
        case title = "title"
        case description = "description"
        case imageURL = "image"
        case streamURL = "stream"
    }

}

// MARK: - BannerFeedItem
struct BannerItemFeedContent: Codable {
    
    let type: String
    let contentId: Int?
    let typeImageURL: String?
    let streamURL: String?
    let externalLinkURL: String?
    let eventPartId: Int?
    let bettingTypeId: Int?

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case contentId = "type_id"
        case typeImageURL = "type_image"
        case streamURL = "stream"
        case externalLinkURL = "external_url"
        case eventPartId = "event_part_id"
        case bettingTypeId = "betting_type_id"
    }
}
