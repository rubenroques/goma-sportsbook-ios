//
//  GomaGamingService.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/08/2021.
//

import Foundation

enum GomaGamingService {
    case test
    case log(type: String, message: String)
    case geolocation(latitude: String, longitude: String)
    case settings
    case simpleRegister(username: String, email: String, phone: String, birthDate: String, userProviderId: String, deviceToken: String)
    case modalPopUpDetails
    case login(username: String, password: String, deviceToken: String)
    case suggestedBets
    case addFavorites(favorites: String)
    case removeFavorite(favorite: String)
    case matchStats(matchId: String)
    // case getActivateUserEmailCode(userEmail: String, activationCode: String) //example of request with params
    case userSettings
    case sendUserSettings(userSettings: UserSettingsGoma)

    // Social Endpoits
    case addFriend(userIds: [String])
    case listFriends
    case chatrooms
    case addGroup(userIds: [String], groupName: String)
    case deleteGroup(chatroomId: String)
}

extension GomaGamingService: Endpoint {

    var url: String {
        return TargetVariables.gomaGamingHost
    }

    var endpoint: String {

        let apiVersion = "v1"

        switch self {
        case .test:
            return "/api/\(apiVersion)/me"
        case .log:
            return "/log/api/\(apiVersion)"
        case .geolocation:
            return "/api/settings/\(apiVersion)/geolocation"
        case .settings:
            return "/api/\(apiVersion)/modules"
        case .simpleRegister:
            return "/api/users/\(apiVersion)/register"
        case .modalPopUpDetails:
            return "/api/settings/\(apiVersion)/info-popup"
        case .login:
            return "/api/auth/\(apiVersion)/login"
        case .suggestedBets:
            return "/api/betting/\(apiVersion)/betslip/suggestions"
        case .addFavorites:
            return "/api/favorites/\(apiVersion)"
        case .matchStats(let matchId):
            return "/api/betting/\(apiVersion)/events/\(matchId)/stats/detail"
        case .userSettings:
            return "/api/settings/\(apiVersion)/user"
        case .removeFavorite:
            return "/api/favorites/\(apiVersion)"
        case .sendUserSettings:
            return "/api/settings/\(apiVersion)/user"
        // Social
        case .addFriend:
            return "/api/social/\(apiVersion)/friends"
        case .listFriends:
            return "/api/social/\(apiVersion)/friends"
        case .chatrooms:
            return "/api/social/\(apiVersion)/chatrooms"
        case .addGroup:
            return "/api/social/\(apiVersion)/groups"
        case .deleteGroup(let chatroomId):
            return "/api/social/\(apiVersion)/groups/\(chatroomId)"
        }
    }

    var query: [URLQueryItem]? {
        switch self {
        case .log, .test:
            return nil
        case .geolocation(let latitude, let longitude):
            return [URLQueryItem(name: "lat", value: latitude),
                    URLQueryItem(name: "lng", value: longitude)]
        case .settings, .simpleRegister, .modalPopUpDetails, .login,
                .suggestedBets, .addFavorites, .matchStats, .userSettings, .sendUserSettings:
            return nil
        case .removeFavorite(let favorite):
            return [URLQueryItem(name: "favorite_ids[]", value: favorite)]
        // Social
        case .addFriend, .listFriends, .chatrooms, .addGroup, .deleteGroup:
            return nil
        }
    }

    var headers: HTTP.Headers? {
        let defaultHeaders = [
            "Accept-Encoding": "gzip, deflate",
            "Content-Type": "application/json; charset=UTF-8",
            "Accept": "application/json"
        ]
        return defaultHeaders
    }

    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalCacheData
    }

    var timeout: TimeInterval {
        return TimeInterval(20)
    }

    var method: HTTP.Method {
        switch self {
        case .test:
            return .get
        case .geolocation, .settings, .modalPopUpDetails, .suggestedBets,
                .matchStats, .userSettings:
            return .get
        case .log, .simpleRegister, .login, .addFavorites, .sendUserSettings:
            return .post
        case .removeFavorite:
            return .delete
        // Social
        case .addFriend, .addGroup:
            return .post
        case .listFriends, .chatrooms:
            return .get
        case .deleteGroup:
            return .delete
        }
    }

    var body: Data? {

        switch self {
        case .log(let type, let message):
            let body = """
                       {"type": "\(type)","text": "\(message)"}
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .simpleRegister(let username, let email, let phone, let birthDate, let userProviderId, let deviceToken):
            let body = """
                       {"type": "small_register",
                        "email": "\(email)",
                        "username": "\(username)",
                        "phone_number": "\(phone)",
                        "birthdate": "\(birthDate)",
                        "user_provider_id": "\(userProviderId)",
                        "device_token": "\(deviceToken)"
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .login(let username, let password, let deviceToken):
            let body = """
                       {"username": "\(username)",
                        "password": "\(password)",
                        "device_token": "\(deviceToken)"}
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .addFavorites(let favorites):
            let body = """
                    {"favorites":
                    [
                    \(favorites)
                    ]
                    }
                    """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .sendUserSettings(let userSettings):
            let body = """
                       {"odd_validation_type": "\(userSettings.oddValidationType)",
                       "notifications": \(userSettings.notifications),
                       "notifications_games_watchlist": \(userSettings.notificationGamesWatchlist),
                       "notifications_competitions_watchlist": \(userSettings.notificationsCompetitionsWatchlist),
                       "notifications_goal": \(userSettings.notificationGoal),
                       "notifications_startgame": \(userSettings.notificationsStartgame),
                       "notifications_halftime": \(userSettings.notificationsHalftime),
                       "notifications_fulltime": \(userSettings.notificationsFulltime),
                       "notifications_secondhalf": \(userSettings.notificationsSecondhalf),
                       "notifications_redcard": \(userSettings.notificationsRedcard),
                       "notifications_bets": \(userSettings.notificationsBets),
                       "notification_bet_selections": \(userSettings.notificationBetSelections),
                       "notification_email": \(userSettings.notificationEmail),
                       "notification_sms": \(userSettings.notificationSms)}
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        // Social
        case .addFriend(let userIds):
            let body = """
                    {"users_ids":
                    \(userIds)
                    }
                    """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .addGroup(let userIds, let groupName):
            let body = """
                    {"name": "\(groupName)",
                    "users_ids": \(userIds)
                    }
                    """
            print("GROUP BODY: \(body)")
            let data = body.data(using: String.Encoding.utf8)!
            return data
        default:
            return nil
        }

    }

}
