//
//  File.swift
//  Sportsbook
//
//  Created by André Lascas on 08/02/2022.
//

import Foundation


struct BettingUserSettings: Codable {

    var oddValidationType: String
    var anonymousTips: Bool
    
    enum CodingKeys: String, CodingKey {
        case oddValidationType = "odd_validation_type"
        case anonymousTips = "anonymous_tips"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.oddValidationType = try container.decode(String.self, forKey: .oddValidationType)
        self.anonymousTips = (try? container.decode(Int.self, forKey: .anonymousTips)) ?? 0 == 1
    }
    
    init() {
        self.anonymousTips = true
        self.oddValidationType = "ACCEPT_ANY"
    }
    
    static var defaultSettings: BettingUserSettings {
        return BettingUserSettings()
    }
}

struct NotificationsUserSettings: Codable {

    var notifications: Bool
    var notificationsGamesWatchlist: Bool
    var notificationsCompetitionsWatchlist: Bool
    var notificationsGoal: Bool
    var notificationsStartgame: Bool
    var notificationsHalftime: Bool
    var notificationsFulltime: Bool
    var notificationsSecondhalf: Bool
    var notificationsRedcard: Bool
    var notificationsBets: Bool
    var notificationsBetSelections: Bool
    var notificationsEmail: Bool
    var notificationsSms: Bool

    enum CodingKeys: String, CodingKey {
        case notifications = "notifications"
        case notificationsGamesWatchlist = "notifications_games_watchlist"
        case notificationsCompetitionsWatchlist = "notifications_competitions_watchlist"
        case notificationsGoal = "notifications_goal"
        case notificationsStartgame = "notifications_startgame"
        case notificationsHalftime = "notifications_halftime"
        case notificationsFulltime = "notifications_fulltime"
        case notificationsSecondhalf = "notifications_secondhalf"
        case notificationsRedcard = "notifications_redcard"
        case notificationsBets = "notifications_bets"
        case notificationsBetSelections = "notifications_bet_selections"
        case notificationsEmail = "notifications_email"
        case notificationsSms = "notifications_sms"
    }
    
    init() {
        self.notifications = true
        self.notificationsGamesWatchlist = true
        self.notificationsCompetitionsWatchlist = true
        self.notificationsGoal = true
        self.notificationsStartgame = true
        self.notificationsHalftime = true
        self.notificationsFulltime = true
        self.notificationsSecondhalf = true
        self.notificationsRedcard = true
        self.notificationsBets = true
        self.notificationsBetSelections = true
        self.notificationsEmail = true
        self.notificationsSms = true
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.notifications = (try? container.decode(Int.self, forKey: .notifications)) ?? 0 == 1
        self.notificationsGamesWatchlist = (try? container.decode(Int.self, forKey: .notificationsGamesWatchlist)) ?? 0 == 1
        self.notificationsCompetitionsWatchlist = (try? container.decode(Int.self, forKey: .notificationsCompetitionsWatchlist)) ?? 0 == 1
        self.notificationsGoal = (try? container.decode(Int.self, forKey: .notificationsGoal)) ?? 0 == 1
        self.notificationsStartgame = (try? container.decode(Int.self, forKey: .notificationsStartgame)) ?? 0 == 1
        self.notificationsHalftime = (try? container.decode(Int.self, forKey: .notificationsHalftime)) ?? 0 == 1
        self.notificationsFulltime = (try? container.decode(Int.self, forKey: .notificationsFulltime)) ?? 0 == 1
        self.notificationsSecondhalf = (try? container.decode(Int.self, forKey: .notificationsSecondhalf)) ?? 0 == 1
        self.notificationsRedcard = (try? container.decode(Int.self, forKey: .notificationsRedcard)) ?? 0 == 1
        self.notificationsBets = (try? container.decode(Int.self, forKey: .notificationsBets)) ?? 0 == 1
        self.notificationsBetSelections = (try? container.decode(Int.self, forKey: .notificationsBetSelections)) ?? 0 == 1
        self.notificationsEmail = (try? container.decode(Int.self, forKey: .notificationsEmail)) ?? 0 == 1
        self.notificationsSms = (try? container.decode(Int.self, forKey: .notificationsSms)) ?? 0 == 1
    }
    
    static var defaultSettings: NotificationsUserSettings {
        return NotificationsUserSettings()
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
