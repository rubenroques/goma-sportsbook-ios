//
//  File.swift
//  
//
//  Created by Ruben Roques on 15/01/2024.
//

import Foundation

extension GomaModels {
    
    struct UserWallet: Codable {
        
        let balance: Double
        let freeBalance: Double
        let cashbackBalance: Double
        
        enum CodingKeys: String, CodingKey {
            case balance = "balance"
            case freeBalance = "free_balance"
            case cashbackBalance = "cashback_balance"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.balance = try container.decode(Double.self, forKey: .balance)
            self.freeBalance = try container.decodeIfPresent(Double.self, forKey: .freeBalance) ?? 0.0
            self.cashbackBalance = try container.decodeIfPresent(Double.self, forKey: .cashbackBalance) ?? 0.0
        }
                
    }
    
    struct UserNotificationsSettings: Codable {
        let notifications: Int
        let notificationsGamesWatchlist: Int
        let notificationsCompetitionsWatchlist: Int
        let notificationsGoal: Int
        let notificationsStartGame: Int
        let notificationsHalftime: Int
        let notificationsFulltime: Int
        let notificationsSecondHalf: Int
        let notificationsRedcard: Int
        let notificationsBets: Int
        let notificationsBetSelections: Int
        let notificationsEmail: Int
        let notificationsSms: Int
        let notificationsChats: Int
        let notificationsNews: Int
        
        enum CodingKeys: String, CodingKey {
            case notifications = "notifications"
            case notificationsGamesWatchlist = "notifications_games_watchlist"
            case notificationsCompetitionsWatchlist = "notifications_competitions_watchlist"
            case notificationsGoal = "notifications_goal"
            case notificationsStartGame = "notifications_startgame"
            case notificationsHalftime = "notifications_halftime"
            case notificationsFulltime = "notifications_fulltime"
            case notificationsSecondHalf = "notifications_secondhalf"
            case notificationsRedcard = "notifications_redcard"
            case notificationsBets = "notifications_bets"
            case notificationsBetSelections = "notifications_bet_selections"
            case notificationsEmail = "notifications_email"
            case notificationsSms = "notifications_sms"
            case notificationsChats = "notifications_chats"
            case notificationsNews = "notifications_news"
        }
        
        init(notifications: Bool,
             notificationsGamesWatchlist: Bool,
             notificationsCompetitionsWatchlist: Bool,
             notificationsGoal: Bool,
             notificationsStartGame: Bool,
             notificationsHalftime: Bool,
             notificationsFulltime: Bool,
             notificationsSecondHalf: Bool,
             notificationsRedcard: Bool,
             notificationsBets: Bool,
             notificationsBetSelections: Bool,
             notificationsEmail: Bool,
             notificationsSms: Bool,
             notificationsChats: Bool,
             notificationsNews: Bool)
        {
            self.notifications = notifications ? 1 : 0
            self.notificationsGamesWatchlist = notificationsGamesWatchlist ? 1 : 0
            self.notificationsCompetitionsWatchlist = notificationsCompetitionsWatchlist ? 1 : 0
            self.notificationsGoal = notificationsGoal ? 1 : 0
            self.notificationsStartGame = notificationsStartGame ? 1 : 0
            self.notificationsHalftime = notificationsHalftime ? 1 : 0
            self.notificationsFulltime = notificationsFulltime ? 1 : 0
            self.notificationsSecondHalf = notificationsSecondHalf ? 1 : 0
            self.notificationsRedcard = notificationsRedcard ? 1 : 0
            self.notificationsBets = notificationsBets ? 1 : 0
            self.notificationsBetSelections = notificationsBetSelections ? 1 : 0
            self.notificationsEmail = notificationsEmail ? 1 : 0
            self.notificationsSms = notificationsSms ? 1 : 0
            self.notificationsChats = notificationsChats ? 1 : 0
            self.notificationsNews = notificationsNews ? 1 : 0
        }
        
        init(notifications: Int,
             notificationsGamesWatchlist: Int,
             notificationsCompetitionsWatchlist: Int,
             notificationsGoal: Int,
             notificationsStartGame: Int,
             notificationsHalftime: Int,
             notificationsFulltime: Int,
             notificationsSecondHalf: Int,
             notificationsRedcard: Int,
             notificationsBets: Int,
             notificationsBetSelections: Int,
             notificationsEmail: Int,
             notificationsSms: Int,
             notificationsChats: Int,
             notificationsNews: Int)
        {
            self.notifications = notifications
            self.notificationsGamesWatchlist = notificationsGamesWatchlist
            self.notificationsCompetitionsWatchlist = notificationsCompetitionsWatchlist
            self.notificationsGoal = notificationsGoal
            self.notificationsStartGame = notificationsStartGame
            self.notificationsHalftime = notificationsHalftime
            self.notificationsFulltime = notificationsFulltime
            self.notificationsSecondHalf = notificationsSecondHalf
            self.notificationsRedcard = notificationsRedcard
            self.notificationsBets = notificationsBets
            self.notificationsBetSelections = notificationsBetSelections
            self.notificationsEmail = notificationsEmail
            self.notificationsSms = notificationsSms
            self.notificationsChats = notificationsChats
            self.notificationsNews = notificationsNews
        }
     
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.UserNotificationsSettings.CodingKeys> = try decoder.container(keyedBy: GomaModels.UserNotificationsSettings.CodingKeys.self)
            
            self.notifications = (try? container.decodeIntFromBoolOrInt(forKey: .notifications)) ?? 0
            self.notificationsGamesWatchlist = (try? container.decodeIntFromBoolOrInt(forKey: .notificationsGamesWatchlist)) ?? 0
            self.notificationsCompetitionsWatchlist = (try? container.decodeIntFromBoolOrInt(forKey: .notificationsCompetitionsWatchlist)) ?? 0
            self.notificationsGoal = (try? container.decodeIntFromBoolOrInt(forKey: .notificationsGoal)) ?? 0
            self.notificationsStartGame = (try? container.decodeIntFromBoolOrInt(forKey: .notificationsStartGame)) ?? 0
            self.notificationsHalftime = (try? container.decodeIntFromBoolOrInt(forKey: .notificationsHalftime)) ?? 0
            self.notificationsFulltime = (try? container.decodeIntFromBoolOrInt(forKey: .notificationsFulltime)) ?? 0
            self.notificationsSecondHalf = (try? container.decodeIntFromBoolOrInt(forKey: .notificationsSecondHalf)) ?? 0
            self.notificationsRedcard = (try? container.decodeIntFromBoolOrInt(forKey: .notificationsRedcard)) ?? 0
            self.notificationsBets = (try? container.decodeIntFromBoolOrInt(forKey: .notificationsBets)) ?? 0
            self.notificationsBetSelections = (try? container.decodeIntFromBoolOrInt(forKey: .notificationsBetSelections)) ?? 0
            self.notificationsEmail = (try? container.decodeIntFromBoolOrInt(forKey: .notificationsEmail)) ?? 0
            self.notificationsSms = (try? container.decodeIntFromBoolOrInt(forKey: .notificationsSms)) ?? 0
            self.notificationsChats = (try? container.decodeIntFromBoolOrInt(forKey: .notificationsChats)) ?? 0
            self.notificationsNews = (try? container.decodeIntFromBoolOrInt(forKey: .notificationsNews)) ?? 0
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: GomaModels.UserNotificationsSettings.CodingKeys.self)

            try container.encode(self.notifications, forKey: .notifications)
            try container.encode(self.notificationsGamesWatchlist, forKey: .notificationsGamesWatchlist)
            try container.encode(self.notificationsCompetitionsWatchlist, forKey: .notificationsCompetitionsWatchlist)
            try container.encode(self.notificationsGoal, forKey: .notificationsGoal)
            try container.encode(self.notificationsStartGame, forKey: .notificationsStartGame)
            try container.encode(self.notificationsHalftime, forKey: .notificationsHalftime)
            try container.encode(self.notificationsFulltime, forKey: .notificationsFulltime)
            try container.encode(self.notificationsSecondHalf, forKey: .notificationsSecondHalf)
            try container.encode(self.notificationsRedcard, forKey: .notificationsRedcard)
            try container.encode(self.notificationsBets, forKey: .notificationsBets)
            try container.encode(self.notificationsBetSelections, forKey: .notificationsBetSelections)
            try container.encode(self.notificationsEmail, forKey: .notificationsEmail)
            try container.encode(self.notificationsSms, forKey: .notificationsSms)
            try container.encode(self.notificationsChats, forKey: .notificationsChats)
            try container.encode(self.notificationsNews, forKey: .notificationsNews)
        }
        
    }
    
}

extension KeyedDecodingContainer {
    func decodeBoolFromBoolOrInt(forKey key: K) throws -> Bool {
        if let intValue = try? decode(Int.self, forKey: key) {
            return intValue != 0
        } else {
            return try decode(Bool.self, forKey: key)
        }
    }
    
    func decodeIntFromBoolOrInt(forKey key: K) throws -> Int {
        if let boolValue = try? decode(Bool.self, forKey: key) {
            return boolValue ? 1 : 0
        } else {
            return try decode(Int.self, forKey: key)
        }
    }
}
