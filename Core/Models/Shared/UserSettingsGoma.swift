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
