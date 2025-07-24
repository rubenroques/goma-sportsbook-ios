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

//        self.anonymousTips = (try? container.decode(Int.self, forKey: .anonymousTips)) ?? 0 == 1

        if let anonymousTipsBool = try? container.decode(Bool.self, forKey: .anonymousTips) {
            self.anonymousTips = anonymousTipsBool
        }
        else if let anonymousTipsInt = try? container.decode(Int.self, forKey: .anonymousTips) {
            self.anonymousTips = anonymousTipsInt == 1
        }
        else {
            self.anonymousTips = false
        }
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
    var notificationsNews: Bool
    var notificationsChats: Bool

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
        case notificationsNews = "notifications_news"
        case notificationsChats = "notifications_chats"
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
        self.notificationsNews = true
        self.notificationsChats = true
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        //
        if let notificationsBool = try? container.decode(Bool.self, forKey: .notifications) {
            self.notifications = notificationsBool
        }
        else if let notificationsInt = try? container.decode(Int.self, forKey: .notifications) {
            self.notifications = notificationsInt == 1
        }
        else {
            self.notifications = false
        }
        
        if let notificationsGamesWatchlistBool = try? container.decode(Bool.self, forKey: .notificationsGamesWatchlist) {
            self.notificationsGamesWatchlist = notificationsGamesWatchlistBool
        }
        else if let notificationsGamesWatchlistInt = try? container.decode(Int.self, forKey: .notificationsGamesWatchlist) {
            self.notificationsGamesWatchlist = notificationsGamesWatchlistInt == 1
        }
        else {
            self.notificationsGamesWatchlist = false
        }
        
        if let notificationsCompetitionsWatchlistBool = try? container.decode(Bool.self, forKey: .notificationsCompetitionsWatchlist) {
            self.notificationsCompetitionsWatchlist = notificationsCompetitionsWatchlistBool
        }
        else if let notificationsCompetitionsWatchlistInt = try? container.decode(Int.self, forKey: .notificationsCompetitionsWatchlist) {
            self.notificationsCompetitionsWatchlist = notificationsCompetitionsWatchlistInt == 1
        }
        else {
            self.notificationsCompetitionsWatchlist = false
        }
        
        if let notificationsGoalBool = try? container.decode(Bool.self, forKey: .notificationsGoal) {
            self.notificationsGoal = notificationsGoalBool
        }
        else if let notificationsGoalInt = try? container.decode(Int.self, forKey: .notificationsGoal) {
            self.notificationsGoal = notificationsGoalInt == 1
        }
        else {
            self.notificationsGoal = false
        }
        
        if let notificationsStartgameBool = try? container.decode(Bool.self, forKey: .notificationsStartgame) {
            self.notificationsStartgame = notificationsStartgameBool
        }
        else if let notificationsStartgameInt = try? container.decode(Int.self, forKey: .notificationsStartgame) {
            self.notificationsStartgame = notificationsStartgameInt == 1
        }
        else {
            self.notificationsStartgame = false
        }
        
        if let notificationsHalftimeBool = try? container.decode(Bool.self, forKey: .notificationsHalftime) {
            self.notificationsHalftime = notificationsHalftimeBool
        }
        else if let notificationsHalftimeInt = try? container.decode(Int.self, forKey: .notificationsHalftime) {
            self.notificationsHalftime = notificationsHalftimeInt == 1
        }
        else {
            self.notificationsHalftime = false
        }
        
        if let notificationsFulltimeBool = try? container.decode(Bool.self, forKey: .notificationsFulltime) {
            self.notificationsFulltime = notificationsFulltimeBool
        }
        else if let notificationsFulltimeInt = try? container.decode(Int.self, forKey: .notificationsFulltime) {
            self.notificationsFulltime = notificationsFulltimeInt == 1
        }
        else {
            self.notificationsFulltime = false
        }
        
        if let notificationsSecondhalfBool = try? container.decode(Bool.self, forKey: .notificationsSecondhalf) {
            self.notificationsSecondhalf = notificationsSecondhalfBool
        }
        else if let notificationsSecondhalfInt = try? container.decode(Int.self, forKey: .notificationsSecondhalf) {
            self.notificationsSecondhalf = notificationsSecondhalfInt == 1
        }
        else {
            self.notificationsSecondhalf = false
        }
        
        if let notificationsRedcardBool = try? container.decode(Bool.self, forKey: .notificationsRedcard) {
            self.notificationsRedcard = notificationsRedcardBool
        }
        else if let notificationsRedcardInt = try? container.decode(Int.self, forKey: .notificationsRedcard) {
            self.notificationsRedcard = notificationsRedcardInt == 1
        }
        else {
            self.notificationsRedcard = false
        }
        
        if let notificationsBetsBool = try? container.decode(Bool.self, forKey: .notificationsBets) {
            self.notificationsBets = notificationsBetsBool
        }
        else if let notificationsBetsInt = try? container.decode(Int.self, forKey: .notificationsBets) {
            self.notificationsBets = notificationsBetsInt == 1
        }
        else {
            self.notificationsBets = false
        }
        
        if let notificationsBetSelectionsBool = try? container.decode(Bool.self, forKey: .notificationsBetSelections) {
            self.notificationsBetSelections = notificationsBetSelectionsBool
        }
        else if let notificationsBetSelectionsInt = try? container.decode(Int.self, forKey: .notificationsBetSelections) {
            self.notificationsBetSelections = notificationsBetSelectionsInt == 1
        }
        else {
            self.notificationsBetSelections = false
        }
        
        if let notificationsEmailBool = try? container.decode(Bool.self, forKey: .notificationsEmail) {
            self.notificationsEmail = notificationsEmailBool
        }
        else if let notificationsEmailInt = try? container.decode(Int.self, forKey: .notificationsEmail) {
            self.notificationsEmail = notificationsEmailInt == 1
        }
        else {
            self.notificationsEmail = false
        }
        
        if let notificationsSmsBool = try? container.decode(Bool.self, forKey: .notificationsSms) {
            self.notificationsSms = notificationsSmsBool
        }
        else if let notificationsSmsInt = try? container.decode(Int.self, forKey: .notificationsSms) {
            self.notificationsSms = notificationsSmsInt == 1
        }
        else {
            self.notificationsSms = false
        }
        
        if let notificationsNewsBool = try? container.decode(Bool.self, forKey: .notificationsNews) {
            self.notificationsNews = notificationsNewsBool
        }
        else if let notificationsNewsInt = try? container.decode(Int.self, forKey: .notificationsNews) {
            self.notificationsNews = notificationsNewsInt == 1
        }
        else {
            self.notificationsNews = false
        }
        
        if let notificationsChatsBool = try? container.decode(Bool.self, forKey: .notificationsChats) {
            self.notificationsChats = notificationsChatsBool
        }
        else if let notificationsChatsInt = try? container.decode(Int.self, forKey: .notificationsChats) {
            self.notificationsChats = notificationsChatsInt == 1
        }
        else {
            self.notificationsChats = false
        }
        
//        
//        
//        
//        
//        
//        
//        
//        
//        self.notifications = try container.decode(Int.self, forKey: .notifications) == 1
//        self.notificationsGamesWatchlist = try container.decode(Int.self, forKey: .notificationsGamesWatchlist) == 1
//        self.notificationsCompetitionsWatchlist = try container.decode(Int.self, forKey: .notificationsCompetitionsWatchlist) == 1
//        self.notificationsGoal = try container.decode(Int.self, forKey: .notificationsGoal) == 1
//        self.notificationsStartgame = try container.decode(Int.self, forKey: .notificationsStartgame) == 1
//        self.notificationsHalftime = try container.decode(Int.self, forKey: .notificationsHalftime) == 1
//        self.notificationsFulltime = try container.decode(Int.self, forKey: .notificationsFulltime) == 1
//        self.notificationsSecondhalf = try container.decode(Int.self, forKey: .notificationsSecondhalf) == 1
//        self.notificationsRedcard = try container.decode(Int.self, forKey: .notificationsRedcard) == 1
//        self.notificationsBets = try container.decode(Int.self, forKey: .notificationsBets) == 1
//        self.notificationsBetSelections = try container.decode(Int.self, forKey: .notificationsBetSelections) == 1
//        self.notificationsEmail = try container.decode(Int.self, forKey: .notificationsEmail) == 1
//        self.notificationsSms = try container.decode(Int.self, forKey: .notificationsSms) == 1
////
////        if let notificationsSmsInt = try? container.decode(Int.self, forKey: .notificationsSms) {
////            self.notificationsSms = notificationsSmsInt == 1
////        }
////        else if let notificationsSmsBool = try? container.decode(Bool.self, forKey: .notificationsSms) {
////            self.notificationsSms = notificationsSmsBool
////        }
////        else {
////            self.notificationsSms = false
////        }
////
//        self.notificationsNews = try container.decode(Int.self, forKey: .notificationsNews) == 1
//        self.notificationsChats = try container.decode(Int.self, forKey: .notificationsChats) == 1
//    
    }
    
    static var defaultSettings: NotificationsUserSettings {
        return NotificationsUserSettings()
    }
    
}

enum SportSectionFeedContent: Decodable {

    case popular(title: String)
    case popularVideos(title: String, contents: [VideoItemFeedContent])
    case live(title: String)
    case liveVideos(title: String, contents: [VideoItemFeedContent])
    case competitions(title: String)
    case competitionsVideos(title: String, contents: [VideoItemFeedContent])

    case mixedEvents(title: String?)

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
