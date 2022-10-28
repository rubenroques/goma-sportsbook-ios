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
    case modules
    
    case login(username: String, password: String, deviceToken: String)
    case simpleRegister(username: String, email: String, phoneCountryCode: String, phone: String, birthDate: Date, userProviderId: String, deviceToken: String)
    
    case updateProfile(name: String)
    case modalPopUpDetails
    case suggestedBets
    case addFavorites(favorites: String)
    case removeFavorite(favorite: String)
    case matchStats(matchId: String)

    case getClientSettings
    
    case getNotificationsUserSettings
    case postNotificationsUserSettings(notificationsUserSettings: NotificationsUserSettings)
    
    case getBettingUserSettings
    case postBettingUserSettings(bettingUserSettings: BettingUserSettings)

    // Social Endpoits
    case addFriend(userIds: [String])
    case addFriendRequest(userIds: [String], request: Bool)
    case deleteFriend(userId: Int)
    case listFriends
    case inviteFriend(phone: String)
    case getFriendRequests
    case approveFriendRequest(userId: String)
    case rejectFriendRequest(userId: String)
    case chatrooms(page: String)
    case addGroup(userIds: [String], groupName: String)
    case deleteGroup(chatroomId: Int)
    case editGroup(chatroomId: Int, groupName: String)
    case leaveGroup(chatroomId: Int)
    case lookupPhone(phones: [String])
    case removeUser(chatroomId: Int, userId: String)
    case addUserToGroup(chatroomId: Int, userIds: [String])
    case searchUserCode(code: String)
    case getNotification(type: String, page: Int)
    case setNotificationRead(id: String)
    case setAllNotificationRead(type: String)
    case sendSupportTicket(title: String, message: String)
    case notificationsCounter(type: String)
    // swiftlint:disable enum_case_associated_values_count
    case featuredTips(betType: String? = nil,
                      totalOddsMin: String? = nil, totalOddsMax: String? = nil,
                      friends: Bool? = nil, followers: Bool? = nil,
                      topTips: Bool? = nil,
                      userIds: [String]? = nil,
                      page: Int? = nil)
    case rankingsTips(type: String? = nil, friends: Bool? = nil, followers: Bool? = nil)
    case getFollowers
    case getFollowingUsers
    case followUser(userId: String)
    case deleteFollowUser(userId: String)
    case getFollowingTotalUsers
    case getUserProfileInfo(userId: String)
    case getUserConnections(userId: String)
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
        case .modules:
            return "/api/settings/\(apiVersion)/modules"
        case .simpleRegister:
            return "/api/users/\(apiVersion)/register"
        case .updateProfile:
                    return "/api/users/\(apiVersion)/profile"
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
        case .removeFavorite:
            return "/api/favorites/\(apiVersion)"

        case .getClientSettings:
            return "/api/settings/\(apiVersion)/user"
            
        case .getNotificationsUserSettings:
            return "/api/notifications/\(apiVersion)/user/settings"
        case .postNotificationsUserSettings:
            return "/api/notifications/\(apiVersion)/user/settings"
            
        case .getBettingUserSettings:
            return "/api/betting/\(apiVersion)/user/settings"
        case .postBettingUserSettings:
            return "/api/betting/\(apiVersion)/user/settings"
            
        // Social
        case .addFriend:
            return "/api/social/\(apiVersion)/friends"
        case .addFriendRequest:
            return "/api/social/\(apiVersion)/friends"
        case .deleteFriend(let userId):
            return "/api/social/\(apiVersion)/friends/\(userId)"
        case .listFriends:
            return "/api/social/\(apiVersion)/friends"
        case .inviteFriend:
            return "/api/social/\(apiVersion)/friends/invite"
        case .getFriendRequests:
            return "/api/social/\(apiVersion)/friends/pending"
        case .approveFriendRequest(let userId):
            return "/api/social/\(apiVersion)/friends/\(userId)/approve"
        case .rejectFriendRequest(let userId):
            return "/api/social/\(apiVersion)/friends/\(userId)/reject"
        case .chatrooms:
            return "/api/social/\(apiVersion)/chatrooms"
        case .addGroup:
            return "/api/social/\(apiVersion)/groups"
        case .deleteGroup(let chatroomId):
            return "/api/social/\(apiVersion)/groups/\(chatroomId)"
        case .editGroup(let chatroomId, _):
            return "/api/social/\(apiVersion)/groups/\(chatroomId)"
        case .leaveGroup(let chatroomId):
            return "/api/social/\(apiVersion)/groups/\(chatroomId)/users/leave"
        case .lookupPhone:
            return "/api/users/\(apiVersion)/in-app"
        case .removeUser(let chatroomId, _):
            return "/api/social/\(apiVersion)/groups/\(chatroomId)/users"
        case .addUserToGroup(let chatroomId, _):
            return "/api/social/\(apiVersion)/groups/\(chatroomId)/users"
        case .searchUserCode(let code):
            return "/api/users/\(apiVersion)/code/\(code)"
        case .getNotification:
            return "/api/notifications/\(apiVersion)"
        case .setNotificationRead(let id):
            return "/api/notifications/\(apiVersion)/\(id)/read"
        case .setAllNotificationRead:
            return "/api/notifications/\(apiVersion)/read-all"
        case .sendSupportTicket:
            return "/api/users/\(apiVersion)/contact"
        case .notificationsCounter:
            return "/api/notifications/\(apiVersion)/count"
        case .featuredTips:
            return "/api/betting/\(apiVersion)/tips"
        case .rankingsTips:
            return "/api/betting/\(apiVersion)/tips/rankings"
        case .getFollowers:
            return "/api/social/\(apiVersion)/followers"
        case .getFollowingUsers:
            return "/api/social/\(apiVersion)/following"
        case .followUser:
            return "/api/social/\(apiVersion)/followers"
        case .deleteFollowUser(let userId):
            return "/api/social/\(apiVersion)/followers/\(userId)"
        case .getFollowingTotalUsers:
            return "/api/social/\(apiVersion)/following/total"
        case .getUserProfileInfo(let userId):
            return "/api/betting/\(apiVersion)/user/profile/\(userId)"
        case .getUserConnections(let userId):
            return "/api/social/\(apiVersion)/user/connections/\(userId)"
        }
    }

    var query: [URLQueryItem]? {
        switch self {
        case .log, .test:
            return nil
        case .geolocation(let latitude, let longitude):
            return [URLQueryItem(name: "lat", value: latitude),
                    URLQueryItem(name: "lng", value: longitude)]
        case .simpleRegister, .updateProfile, .modalPopUpDetails, .login,
                .suggestedBets, .addFavorites, .matchStats, .sendSupportTicket:
            return nil
        
        case .getClientSettings:
            return nil
        case  .getNotificationsUserSettings, .postNotificationsUserSettings, .getBettingUserSettings, .postBettingUserSettings:
            return nil
        
        case  .settings, .modules:
            return nil
        case .removeFavorite(let favorite):
            return [URLQueryItem(name: "favorite_ids[]", value: favorite)]
        
            // Social
        case .addFriend, .addFriendRequest, .deleteFriend, .listFriends, .inviteFriend, .getFriendRequests,
                .approveFriendRequest, .rejectFriendRequest,
                .addGroup, .deleteGroup, .leaveGroup,
                .searchUserCode, .lookupPhone,
                .setNotificationRead, .setAllNotificationRead,
                .getFollowers, .getFollowingUsers, .getFollowingTotalUsers, .deleteFollowUser,
                .getUserProfileInfo, .getUserConnections:
            return nil
        case .chatrooms(let page):
            return [URLQueryItem(name: "page", value: page)]
        case .editGroup(_, let groupName):
            var queryItemsURL: [URLQueryItem] = []

            let groupNameQuery = URLQueryItem(name: "name", value: groupName)
            queryItemsURL.append(groupNameQuery)
            print("EDIT GROUP QUERY: \(queryItemsURL)")
            return queryItemsURL
            
        case .removeUser(_, let userId):
            return [URLQueryItem(name: "users_ids[]", value: userId)]

        case .addUserToGroup(_, let userIds):
            var queryItemsURL: [URLQueryItem] = []
            for user in userIds {
                let queryItem = URLQueryItem(name: "users_ids[]", value: "\(user)")
                queryItemsURL.append(queryItem)
            }
            return queryItemsURL
        case .getNotification(let type, let page):
            return [URLQueryItem(name: "type", value: type),
            URLQueryItem(name: "page", value: "\(page)")]
        case .notificationsCounter(let type):
            return[URLQueryItem(name: "type", value: type)]
        case .featuredTips(let betType,
                           let totalOddsMin, let totalOddsMax,
                           let friends, let followers, let topTips,
                           let userIds,
                           let page):
            var queryItemsURL: [URLQueryItem] = []

            if betType != nil {
                let queryItem = URLQueryItem(name: "bet_type", value: betType)
                queryItemsURL.append(queryItem)
            }

            if totalOddsMin != nil {
                let queryItem = URLQueryItem(name: "total_odds_min", value: totalOddsMin)
                queryItemsURL.append(queryItem)
            }

            if totalOddsMax != nil {
                let queryItem = URLQueryItem(name: "total_odds_max", value: totalOddsMax)
                queryItemsURL.append(queryItem)
            }

            if friends != nil {
                if let friendsValue = friends {
                    let queryItem = URLQueryItem(name: "friends", value: "\(friendsValue == true ? 1 : 0)")
                    queryItemsURL.append(queryItem)
                }
            }

            if followers != nil {
                if let followersValue = followers {
                    let queryItem = URLQueryItem(name: "followers", value: "\(followersValue == true ? 1 : 0)")
                    queryItemsURL.append(queryItem)
                }
            }

            if topTips != nil {
                if let topTipsValue = topTips {
                    let queryItem = URLQueryItem(name: "top", value: "\(topTipsValue == true ? 1 : 0)")
                    queryItemsURL.append(queryItem)
                }
            }

            if userIds != nil {
                if let userIdsValue = userIds {
                    for user in userIdsValue {
                        let queryItem = URLQueryItem(name: "users_ids[]", value: "\(user)")
                        queryItemsURL.append(queryItem)
                    }
                }
            }

            if page != nil {
                if let pageValue = page {
                    let queryItem = URLQueryItem(name: "page", value: "\(pageValue)")
                    queryItemsURL.append(queryItem)
                }
            }

            if queryItemsURL.isNotEmpty {
                return queryItemsURL
            }

            return nil
        case .rankingsTips(let type, let friends, let followers):
            var queryItemsURL: [URLQueryItem] = []

            if type != nil {
                let queryItem = URLQueryItem(name: "type", value: type)
                queryItemsURL.append(queryItem)
            }

            if friends != nil {
                if let friendsValue = friends {
                    let queryItem = URLQueryItem(name: "friends", value: "\(friendsValue == true ? 1 : 0)")
                    queryItemsURL.append(queryItem)
                }
            }

            if followers != nil {
                if let followersValue = followers {
                    let queryItem = URLQueryItem(name: "followers", value: "\(followersValue == true ? 1 : 0)")
                    queryItemsURL.append(queryItem)
                }
            }

            if queryItemsURL.isNotEmpty {
                return queryItemsURL
            }

            return nil
        case .followUser(let userId):
            return [URLQueryItem(name: "users_ids[]", value: userId)]
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
                .matchStats, .modules:
            return .get
        case .log, .simpleRegister, .updateProfile, .login, .addFavorites, .sendSupportTicket:
            return .post
        case .removeFavorite:
            return .delete
        
        // Settings goma client
        case .getClientSettings:
            return .get
        
        // Settings app user
        case  .getNotificationsUserSettings, .getBettingUserSettings:
            return .get
        case  .postNotificationsUserSettings, .postBettingUserSettings:
            return .post
            
        // Social
        case .addFriend, .addFriendRequest, .inviteFriend, .approveFriendRequest,
                .addGroup, .addUserToGroup, .lookupPhone,
                .setNotificationRead, .setAllNotificationRead, .followUser:
            return .post
        case .listFriends, .getFriendRequests, .chatrooms,
                .searchUserCode,
                .getNotification, .notificationsCounter,
                .featuredTips, .rankingsTips,
                .getFollowers, .getFollowingUsers, .getFollowingTotalUsers,
                .getUserProfileInfo, .getUserConnections:
            return .get
        case .deleteGroup, .leaveGroup, .deleteFriend, .rejectFriendRequest,
                .removeUser, .deleteFollowUser:
            return .delete
        case .editGroup:
            return .put
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
        case .simpleRegister(let username, let email, let phoneCountryCode, let phone, let birthDate, let userProviderId, let deviceToken):
            
            var prefix = ""
            if TargetVariables.serviceProviderType == .sportradar {
                prefix = "sr_"
            }
            
            let body = """
                       {"type": "small_register",
                        "email": "\(prefix)\(email)",
                        "username": "\(prefix)\(username)",
                        "phone_country_code": "\(phoneCountryCode)",
                        "phone_number": "\(phone)",
                        "birthdate": "\(birthDate)",
                        "user_provider_id": "\(userProviderId)",
                        "device_token": "\(deviceToken)"
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data

            
        case .login(let username, let password, let deviceToken):
            
            var prefix = ""
            if TargetVariables.serviceProviderType == .sportradar {
                prefix = "sr_"
            }
            
            let body = """
                       {"username": "\(prefix)\(username)",
                        "password": "\(password)",
                        "device_token": "\(deviceToken)"}
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
            
        case .updateProfile(let name):
            let body = """
                       {
                        "name": "\(name)"
                       }
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
            
        case .sendSupportTicket(let title, let message):
            let body = """
                       {"title": "\(title)",
                        "message": "\(message)"}
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        
        // Settings
        //
        case .postBettingUserSettings(let bettingUserSettings):
            let body = """
                       {
                            "odd_validation_type": "\(bettingUserSettings.oddValidationType)",
                            "anonymous_tips": \(bettingUserSettings.anonymousTips ? 1 : 0)
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .postNotificationsUserSettings(let notificationsUserSettings):
            let body = """
                       {
                            "notifications": \(notificationsUserSettings.notifications ? 1 : 0),
                            "notifications_games_watchlist": \(notificationsUserSettings.notificationsGamesWatchlist ? 1 : 0),
                            "notifications_competitions_watchlist": \(notificationsUserSettings.notificationsCompetitionsWatchlist ? 1 : 0),
                            "notifications_goal": \(notificationsUserSettings.notificationsGoal ? 1 : 0),
                            "notifications_startgame": \(notificationsUserSettings.notificationsStartgame ? 1 : 0),
                            "notifications_halftime": \(notificationsUserSettings.notificationsHalftime ? 1 : 0),
                            "notifications_fulltime": \(notificationsUserSettings.notificationsFulltime ? 1 : 0),
                            "notifications_secondhalf": \(notificationsUserSettings.notificationsSecondhalf ? 1 : 0),
                            "notifications_redcard": \(notificationsUserSettings.notificationsRedcard ? 1 : 0),
                            "notifications_bets": \(notificationsUserSettings.notificationsBets ? 1 : 0),
                            "notifications_bet_selections": \(notificationsUserSettings.notificationsBetSelections ? 1 : 0),
                            "notifications_email": \(notificationsUserSettings.notificationsEmail ? 1 : 0),
                            "notifications_sms": \(notificationsUserSettings.notificationsSms ? 1 : 0)
                       }
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
        case .addFriendRequest(let userIds, let request):
            let body = """
                    {"users_ids": \(userIds),
                    "request": \(request ? 1 : 0)
                    }
                    """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .inviteFriend(let phone):
            let body = """
                    {"phone": "\(phone)"}
                    """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .addGroup(let userIds, let groupName):
            let body = """
                    {"name": "\(groupName)",
                    "users_ids": \(userIds)
                    }
                    """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .lookupPhone(let phones):
            let body = """
                    {"phone_numbers":
                    \(phones)
                    }
                    """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .setAllNotificationRead(let type):
            let body = """
                    {"type":
                    \(type)
                    }
                    """
            print("ALL NOTIFS BODY: \(body)")
            let data = body.data(using: String.Encoding.utf8)!
            return data
        default:
            return nil
        }

    }

}
