//
//  File.swift
//  
//
//  Created by Ruben Roques on 18/12/2023.
//

import Foundation

extension GomaAPIClient {
    enum ArgumentModels {
        
        struct BetSelection {
            let eventId: String
            let outcomeId: String
        }

    }
}

enum GomaAPIClient {
    case anonymousAuth(deviceId: String, pushToken: String?)
    case login(username: String, password: String, pushToken: String?)
    case register(name: String, email: String, username: String, password: String, avatarName: String, deviceToken: String? = nil)
    case requestPasswordResetEmail(email: String)
    case updatePassword(oldPassword: String, password: String, passwordConfirmation: String)
    case logout
    case getSports
    
    case getHomeContents
    case getHomeAlerts
    case getBanners
    case getStories
    case getHighlights
    case getPopularEventPointers
    case getPopularEvents
    case getEventsBanners
    case getFeaturedCompetitions
    case getAlertBanners
    case getNews
    case getHeroCards
    case getBoostedOddEvents
    
    case getTrendingEvents(sportCode: String, page: Int)
    case getUpcomingEvents(sportCode: String, page: Int)
    case getLiveEvents(sportCode: String, page: Int)
    case getEndedEvents(sportCode: String, page: Int)
    
    case getRegions(sportCode: String)
    
    case getCompetitionDetails(identifier: String)
    
    case getCompetitions(regionId: String)
    case getEventsFromCompetition(competitionId: String)
    
    case getEventDetails(identifier: String)
    case getEventMarkets(identifier: String, limit: String?)
    
    case getFeaturedTips(page: Int?, limit: Int?, topTips: Bool?, followersTips: Bool?, friendsTips: Bool?, userId: String?, homeTips: Bool?)

    case getFavorites
    case addFavorite(favoriteId: Int, type: String)
    case deleteFavorite(favoriteId: Int, type: String)
    
    case getMyTickets(states: [GomaModels.MyTicketStatus]?, limit: String, page: String)
    case getTicketDetails(betId: String)
    case updateTicketOdds(betId: String)
    case getTicketQRCode(betId: String)
    case deleteTicket(betId: String)
    case updateTicket(betId: String, betTicket: BetTicket) // Specify selections

    case getSharedTicket(sharedId: String)
    
    case search(query: String)

    case getAllowedBetTypes(selections: [Self.ArgumentModels.BetSelection])
    case getCalculatePossibleBetResult(stake: Double, type: GomaModels.BetType, selections: [Self.ArgumentModels.BetSelection])

    case placeBetTicket(betTicket: BetTicket, useCashback: Bool)
    
    case getFollowees
    case getTotalFollowees
    case getFollowers
    case getTotalFollowers
    case addFollowee(userId: String)
    case removeFollowee(userId: String)

    case getTipsRankings(type: String?, followers: Bool?)

    case closeAccount

    case getUserProfile(userId: String)

    case getUserNotificationsSettings
    case updateUserNotificationsSettings(settings: GomaModels.UserNotificationsSettings)

    case updatePersonalInfo(fullname: String, avatar: String)

    case getUserWallet
    case addAmoutToUserWallet(amount: Double)
    
    //CHAT ENDPOINTS
    case getFriendRequests
    case getFriends
    case addFriends(userIds: [String], request: Bool)
    case removeFriend(userId: Int)
    case getChatrooms
    case addGroup(name: String, userIds: [String])
    case deleteGroup(id: Int)
    case editGroup(id: Int, name: String)
    case leaveGroup(id: Int)
    case addUsersFromGroup(groupId: Int, userIds: [String])
    case removeUsersFromGroup(groupId: Int, userIds: [String])
    case searchUserWithCode(code: String)
}

extension GomaAPIClient: Endpoint {
    
    var url: String {
        return "https://api.gomademo.com/"
    }
    
    private static var version: String {
        return "v1"
    }
    
    var endpoint: String {
        switch self {
        case .anonymousAuth:
            return "/api/auth/\(Self.version)"
        case .login:
            return "/api/auth/\(Self.version)/login"
        case .register:
            return "/api/auth/\(Self.version)/register"
        case .requestPasswordResetEmail:
            return "/api/users/\(Self.version)/password/forgot"
        case .updatePassword:
            return "/api/users/\(Self.version)/password"
        case .logout:
            return "/api/auth/\(Self.version)/logout"
        case .getSports:
            return "/api/sports/\(Self.version)"
        
        case .getHomeContents:
            return "/api/promotions/\(Self.version)/home"
        case .getHomeAlerts:
            return "/api/promotions/\(Self.version)/alert-banner"

        case .getBanners:
            return "/api/promotions/\(Self.version)/banners"
        case .getStories:
            return "/api/promotions/\(Self.version)/stories"
        case .getHighlights:
            return "/api/events/\(Self.version)/highlights"
        case .getPopularEventPointers:
            return "/api/events/\(Self.version)/popular"
        case .getPopularEvents:
            return "/api/events/\(Self.version)/popular"
        case .getAlertBanners:
            return "/api/promotions/\(Self.version)/alert-banner"
        case .getNews:
            return "/api/promotions/\(Self.version)/news"
        case .getHeroCards:
            return "/api/promotions/\(Self.version)/hero-cards"
        case .getBoostedOddEvents:
            return "/api/promotions/\(Self.version)/boosted-odds-banners"
            
        case .getEventsBanners:
            return "/api/promotions/\(Self.version)/sport-banners"
        case .getFeaturedCompetitions:
            return "/api/competitions/\(Self.version)/featured"
        
        
        case .getTrendingEvents:
            return "/api/events/\(Self.version)/trending"
        case .getUpcomingEvents:
            return "/api/events/\(Self.version)/upcoming"
        case .getLiveEvents:
            return "/api/events/\(Self.version)/live"
        case .getEndedEvents:
            return "/api/events/\(Self.version)/scores"
            
            
        case .getRegions:
            return "/api/regions/\(Self.version)"
        case .getCompetitions:
            return "/api/competitions/\(Self.version)"
        case .getCompetitionDetails(let identifier):
            return "/api/competitions/\(Self.version)/\(identifier)"
        case .getEventsFromCompetition(let competitionId):
            return "/api/competitions/\(Self.version)/\(competitionId)/events"
            
        case .getEventDetails(let identifier):
            return "/api/events/\(Self.version)/\(identifier)"
        case .getEventMarkets(let identifier, _):
            return "/api/events/\(Self.version)/\(identifier)/markets"
            
        case .getFeaturedTips:
            return "/api/tips/\(Self.version)"

        case .getFavorites:
            return "/api/events/\(Self.version)/favorites"
        case .addFavorite:
            return "/api/events/\(Self.version)/favorites"
        case .deleteFavorite:
            return "/api/events/\(Self.version)/favorites"
            
        case .getAllowedBetTypes:
            return "/api/tickets/\(Self.version)/allowed-types"
            
        case .getCalculatePossibleBetResult:
            return "/api/tickets/\(Self.version)/calculate"
            
        case .placeBetTicket:
            return "/api/tickets/\(Self.version)"

        case .getMyTickets:
            return "/api/tickets/\(Self.version)"
        case .getTicketDetails(let betId):
            return "/api/tickets/\(Self.version)/\(betId)"
        case .updateTicketOdds(let betId):
            return "/api/tickets/\(Self.version)/\(betId)/refresh"
        case .getTicketQRCode(let betId):
            return "/api/tickets/\(Self.version)/\(betId)/qrcode"
        case .deleteTicket(let betId):
            return "/api/tickets/\(Self.version)/\(betId)"
        case .updateTicket(let betId, _):
            return "/api/tickets/\(Self.version)/\(betId)"
        case .getSharedTicket(let sharedId):
            return "/api/tickets/\(Self.version)/share/\(sharedId)"
            
        case .search:
            return "/api/search/\(Self.version)"
            
        case .getFollowees:
            return "/api/social/\(Self.version)/followees"
        case .getTotalFollowees:
            return "/api/social/\(Self.version)/followees/total"
        case .getFollowers:
            return "/api/social/\(Self.version)/followers"
        case .getTotalFollowers:
            return "/api/social/\(Self.version)/followers/total"
        case .addFollowee:
            return "/api/social/\(Self.version)/followees"
        case .removeFollowee:
            return "/api/social/\(Self.version)/followees"
            
        case .getTipsRankings:
            return "/api/tips/\(Self.version)/rankings"
            
        case .closeAccount:
            return "/api/users/\(Self.version)"
            
        case .getUserProfile(let userId):
            return "/api/tips/\(Self.version)/user-profile/\(userId)"
        
        case .getUserNotificationsSettings:
            return "/api/users/\(Self.version)/settings"
        case .updateUserNotificationsSettings:
            return "/api/users/\(Self.version)/settings"
            
        case .updatePersonalInfo:
            return "/api/users/\(Self.version)"
            
        case .getUserWallet:
            return "/api/users/\(Self.version)/wallets"
        case .addAmoutToUserWallet:
            return "/api/users/\(Self.version)/wallets"
            
        case .getFriendRequests:
            return "/api/social/\(Self.version)/friends/pending"
        case .getFriends:
            return "/api/social/\(Self.version)/friends"
        case .addFriends:
            return "/api/social/\(Self.version)/friends"
        case .removeFriend(let userId):
            return "/api/social/\(Self.version)/friends/\(userId)"
        case .getChatrooms:
            return "/api/social/\(Self.version)/chatrooms"
        case .addGroup:
            return "/api/social/\(Self.version)/groups"
        case .deleteGroup(let id):
            return "/api/social/\(Self.version)/groups/\(id)"
        case .editGroup(let id, _):
            return "/api/social/\(Self.version)/groups/\(id)"
        case .leaveGroup(let id):
            return "/api/social/\(Self.version)/groups/\(id)/users/leave"
        case .addUsersFromGroup(let groupId, _):
            return "/api/social/\(Self.version)/groups/\(groupId)/users"
        case .removeUsersFromGroup(let groupId, _):
            return "/api/social/\(Self.version)/groups/\(groupId)/users"
        case .searchUserWithCode(let code):
            return "/api/users/v1/code/\(code)"
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        case .anonymousAuth:
            return nil
        case .login:
            return nil
        case .register:
            return nil
        case .requestPasswordResetEmail:
            return nil    
        case .updatePassword:
            return nil
        case .logout:
            return nil
        case .getSports:
            return nil
        
        case .getHomeContents:
            return nil
        case .getHomeAlerts:
            return nil
        case .getBanners:
            return nil
        case .getStories:
            return nil
        case .getHighlights:
            return nil
        case .getPopularEventPointers:
            return nil
        case .getPopularEvents:
            return nil
        case .getEventsBanners:
            return nil
        case .getFeaturedCompetitions:
            return nil
        case .getAlertBanners:
            return nil
        case .getNews:
            return nil
        case .getHeroCards:
            return nil
        case .getBoostedOddEvents:
            return nil
            
        case .getTrendingEvents(let sportCode, let page):
            return [
                URLQueryItem(name: "sport_id", value: sportCode),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        case .getUpcomingEvents(let sportCode, let page):
            return [
                URLQueryItem(name: "sport_id", value: sportCode),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        case .getLiveEvents(let sportCode, let page):
            return [
                URLQueryItem(name: "sport_id", value: sportCode),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        case .getEndedEvents(let sportCode, let page):
            return [
                URLQueryItem(name: "sport_id", value: sportCode),
                URLQueryItem(name: "page", value: "\(page)")
            ]
            
        case .getRegions(let sportCode):
            return [
                URLQueryItem(name: "sport_id", value: sportCode)
            ]
            
        case .getCompetitionDetails:
            return nil
        case .getCompetitions(let regionId):
            return [
                URLQueryItem(name: "region_id", value: regionId)
            ]
        case .getEventsFromCompetition:
            return nil
            
        case .getEventDetails:
            return nil
        case .getEventMarkets(_, let limit):
            
            var queryItemsURL: [URLQueryItem] = []

            if let limit {
                let queryItem = URLQueryItem(name: "limit", value: limit)
                queryItemsURL.append(queryItem)
            }
            
            if !queryItemsURL.isEmpty {
                return queryItemsURL
            }
            
            return nil
            
        case .getFeaturedTips(let page, let limit, let topTips, let followersTips, let friendsTips, let userId, let homeTips):
            
            var queryItemsURL: [URLQueryItem] = []

            if let page {
                let queryItem = URLQueryItem(name: "page", value: "\(page)")
                queryItemsURL.append(queryItem)
            }
            
            if let limit {
                let queryItem = URLQueryItem(name: "limit", value: "\(limit)")
                queryItemsURL.append(queryItem)
            }
            
            if let topTips {
                let topValue = topTips ? 1 : 0
                let queryItem = URLQueryItem(name: "top", value: "\(topValue)")
                queryItemsURL.append(queryItem)
            }
            
            if let followersTips {
                let followersValue = followersTips ? 1 : 0
                let queryItem = URLQueryItem(name: "followers", value: "\(followersValue)")
                queryItemsURL.append(queryItem)
            }
            
            if let friendsTips {
                let friendsValue = friendsTips ? 1 : 0
                let queryItem = URLQueryItem(name: "friends", value: "\(friendsValue)")
                queryItemsURL.append(queryItem)
            }
            
            if let userId {
                let queryItem = URLQueryItem(name: "user_id", value: "\(userId)")
                queryItemsURL.append(queryItem)
            }
            
            if let homeTips {
                let homeValue = homeTips ? 1 : 0
                let queryItem = URLQueryItem(name: "home", value: "\(homeValue)")
                queryItemsURL.append(queryItem)
            }
            
            if !queryItemsURL.isEmpty {
                return queryItemsURL
            }
            
            return nil

        case .getFavorites:
            return nil
        case .addFavorite:
            return nil
        case .deleteFavorite:
            return nil
            
        case .getAllowedBetTypes(let selections):
            var queryItems = [URLQueryItem]()
            for (index, selection) in selections.enumerated() {
                queryItems.append(contentsOf: [
                    URLQueryItem(name: "selections[\(index)][sport_event_id]", value: selection.eventId),
                    URLQueryItem(name: "selections[\(index)][outcome_id]", value: selection.outcomeId)
                ])
            }
            return queryItems
            
        case .getCalculatePossibleBetResult(let stake, let type, let selections):
            var queryItems = [
                URLQueryItem(name: "stake", value: "\(stake)"),
                URLQueryItem(name: "type", value: type.identifier)
            ]
            for (index, selection) in selections.enumerated() {
                queryItems.append(contentsOf: [
                    URLQueryItem(name: "selections[\(index)][sport_event_id]", value: selection.eventId),
                    URLQueryItem(name: "selections[\(index)][outcome_id]", value: selection.outcomeId)
                ])
            }
            return queryItems
            
        case .placeBetTicket:
            return nil
            
        case .getMyTickets(let betStates, let limit, let page):
            
            var query: [URLQueryItem] = []
            
            if let betStates = betStates?.map(\.rawValue) {
                for betState in betStates {
                    query.append(URLQueryItem(name: "status[]", value: "\(betState)"))
                }
            }
            
            query.append(URLQueryItem(name: "limit", value: "\(limit)"))

            query.append(URLQueryItem(name: "page", value: "\(page)"))
            
            return query
        case .getTicketDetails:
            return nil
        case .updateTicketOdds:
            return nil
        case .getTicketQRCode:
            return nil
        case .deleteTicket:
            return nil
        case .updateTicket:
            return nil
        case .getSharedTicket:
            return nil
            
        case .search(let query):
            return [
                URLQueryItem(name: "value", value: query)
            ]
            
        case .getFollowees:
            return nil
        case .getTotalFollowees:
            return nil
        case .getFollowers:
            return nil
        case .getTotalFollowers:
            return nil
        case .addFollowee:
            return nil
        case .removeFollowee:
            return nil
            
        case .getTipsRankings(let type, let followers):
            
            var queryItemsURL: [URLQueryItem] = []

            if let type {
                let queryItem = URLQueryItem(name: "type", value: "\(type)")
                queryItemsURL.append(queryItem)
            }
            
            if let followers {
                let followersValue = followers ? 1 : 0
                let queryItem = URLQueryItem(name: "followers", value: "\(followersValue)")
                queryItemsURL.append(queryItem)
            }
            
            if !queryItemsURL.isEmpty {
                return queryItemsURL
            }
            
            return nil
            
        case .closeAccount:
            return nil
            
        case .getUserProfile:
            return nil

        case .getUserNotificationsSettings:
            return nil
        case .updateUserNotificationsSettings:
            return nil
            
        case .updatePersonalInfo:
            return nil
            
        case .getUserWallet:
            return nil
        case .addAmoutToUserWallet:
            return nil
            
        case .getFriendRequests:
            return nil
        case .getFriends:
            return nil
        case .addFriends:
            return nil
        case .removeFriend:
            return nil
        case .getChatrooms:
            return nil
        case .addGroup:
            return nil
        case .deleteGroup:
            return nil
        case .editGroup:
            return nil
        case .leaveGroup:
            return nil
        case .addUsersFromGroup:
            return nil
        case .removeUsersFromGroup:
            return nil
        case .searchUserWithCode:
            return nil
        }
        
    }
    
    var method: HTTP.Method {
        switch self {
        case .anonymousAuth: 
            return .post
        case .login:
            return .post
        case .register:
            return .post
        case .requestPasswordResetEmail:
            return .post  
        case .updatePassword:
            return .post
        case .logout:
            return .post
        case .getSports:
            return .get

        case .getHomeContents:
            return .get
        case .getHomeAlerts:
            return .get
        case .getBanners:
            return .get
        case .getStories:
            return .get
        case .getHighlights:
            return .get
        case .getPopularEventPointers:
            return .get
        case .getPopularEvents:
            return .get
        case .getAlertBanners:
            return .get
        case .getNews:
            return .get
        case .getHeroCards:
            return .get
        case .getBoostedOddEvents:
            return .get
            
        case .getEventsBanners:
            return .get
        case .getFeaturedCompetitions:
            return .get
            
        case .getTrendingEvents:
            return .get
        case .getUpcomingEvents:
            return .get
        case .getLiveEvents:
            return .get
        case .getEndedEvents:
            return .get
            
        case .getRegions:
            return .get
        case .getCompetitionDetails:
            return .get
        case .getCompetitions:
            return .get
        case .getEventsFromCompetition:
            return .get
            
        case .getEventDetails:
            return .get
        case .getEventMarkets:
            return .get
            
        case .getFeaturedTips:
            return .get

        case .getFavorites:
            return .get
        case .addFavorite:
            return .post
        case .deleteFavorite:
            return .delete
            
        case .getAllowedBetTypes:
            return .get
        case .getCalculatePossibleBetResult:
            return .get
        case .placeBetTicket:
            return .post

        case .getMyTickets:
            return .get
        case .getTicketDetails:
            return .get
        case .updateTicketOdds:
            return .post
        case .getTicketQRCode:
            return .get
        case .deleteTicket:
            return .delete
        case .updateTicket:
            return .post
        case .getSharedTicket:
            return .get
            
        case .search:
            return .get
            
        case .getFollowees:
            return .get
        case .getTotalFollowees:
            return .get
        case .getFollowers:
            return .get
        case .getTotalFollowers:
            return .get
        case .addFollowee:
            return .post
        case .removeFollowee:
            return .delete
            
        case .getTipsRankings:
            return .get
            
        case .closeAccount:
            return .delete
            
        case .getUserProfile:
            return .get

        case .getUserNotificationsSettings:
            return .get
        case .updateUserNotificationsSettings:
            return .post
            
        case .updatePersonalInfo:
            return .post
            
        case .getUserWallet:
            return .get
        case .addAmoutToUserWallet:
            return .post
            
        case .getFriendRequests:
            return .get
        case .getFriends:
            return .get
        case .addFriends:
            return .post
        case .removeFriend:
            return .delete
        case .getChatrooms:
            return .get
        case .addGroup:
            return .post
        case .deleteGroup:
            return .delete
        case .editGroup:
            return .post
        case .leaveGroup:
            return .post
        case .addUsersFromGroup:
            return .post
        case .removeUsersFromGroup:
            return .delete
        case .searchUserWithCode:
            return .get
        }
    }
    
    var body: Data? {
        switch self {
        case .anonymousAuth(let deviceId,
                            let pushToken):
            let body = """
                       {
                        "device_uuid": "\(deviceId)",
                        "device_type": "ios",
                        "device_token": "\(pushToken ?? "")"
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .login(let username,
                    let password,
                    let pushToken):
            let body = """
                       {
                        "username": "\(username)",
                        "password": "\(password)",
                        "device_type": "ios",
                        "device_token": "\(pushToken ?? "")"
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .register(let name,
                       let email,
                       let username,
                       let password,
                       let avatarName,
                       let deviceToken):
            let body = """
                       {
                        "name": "\(name)",
                        "email": "\(email)",
                        "username": "\(username)",
                        "password": "\(password)",
                        "avatar": "\(avatarName)"
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
            
        case .requestPasswordResetEmail(let email):
            let body = """
                       {
                        "email": "\(email)"
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data    
        case .updatePassword(let oldPassword, let password, let passwordConfirmation):
            let body = """
                       {
                        "password": "\(password)",
                        "password_confirmation": "\(passwordConfirmation)",
                        "current_password": "\(oldPassword)"
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .logout:
            return nil
        case .getSports:
            return nil
            
        case .getHomeContents:
            return nil
        case .getHomeAlerts:
            return nil
        case .getBanners:
            return nil
        case .getStories:
            return nil
        case .getHighlights:
            return nil
        case .getPopularEventPointers:
            return nil
        case .getPopularEvents:
            return nil
        case .getAlertBanners:
            return nil
        case .getNews:
            return nil
        case .getHeroCards:
            return nil
        case .getBoostedOddEvents:
            return nil
            
        case .getEventsBanners:
            return nil
        case .getFeaturedCompetitions:
            return nil
            
        case .getTrendingEvents:
            return nil
        case .getUpcomingEvents:
            return nil
        case .getLiveEvents:
            return nil
        case .getEndedEvents:
            return nil
            
        case .getRegions:
            return nil
        case .getCompetitionDetails:
            return nil
        case .getCompetitions:
            return nil
        case .getEventsFromCompetition:
            return nil
            
        case .getEventDetails:
            return nil
        case .getEventMarkets:
            return nil
            
        case .getFeaturedTips:
            return nil

        case .getFavorites:
            return nil    
        case .addFavorite(let favoriteId, let type):
            let body = """
                       {
                        "favorites": [
                            {
                                "favorite_id": "\(favoriteId)",
                                "type": "\(type)"
                            }
                        ]
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .deleteFavorite(let favoriteId, let type):
            let body = """
                       {
                        "favorites": [
                            {
                                "favorite_id": "\(favoriteId)",
                                "type": "\(type)"
                            }
                        ]
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
            
        case .getAllowedBetTypes:
            return nil
        case .getCalculatePossibleBetResult:
            return nil
            
        case .placeBetTicket(let betTicket, let useCashback):
            let dataString = Self.jsonData(from: betTicket, withCashback: useCashback, withId: nil)
            return dataString.data(using: String.Encoding.utf8)!
        
        case .getMyTickets:
            return nil
        case .getTicketDetails:
            return nil
        case .updateTicketOdds:
            return nil
        case .getTicketQRCode:
            return nil
        case .deleteTicket:
            return nil
        case .updateTicket(let betTicketId , let betTicket):
            let dataString = Self.jsonData(from: betTicket, withCashback: nil, withId: betTicketId)
            return dataString.data(using: String.Encoding.utf8)!
        
        case .getSharedTicket:
            return nil
            
        case .search:
            return nil
            
        case .getFollowees:
            return nil
        case .getTotalFollowees:
            return nil
        case .getFollowers:
            return nil
        case .getTotalFollowers:
            return nil
        case.addFollowee(let userId):
            let body = """
                       {
                        "users_ids": [\(userId)]
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .removeFollowee(let userId):
            let body = """
                       {
                        "users_ids": [\(userId)]
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        
        case .getTipsRankings:
            return nil
            
        case .closeAccount:
            return nil
            
        case .getUserProfile:
            return nil

        case .getUserNotificationsSettings:
            return nil
        case .updateUserNotificationsSettings(let settings):
            let encoder = JSONEncoder()
            guard
                let jsonData = try? encoder.encode(settings)
            else {
                return nil
            }
            return jsonData
            
        case .updatePersonalInfo(let fullname, let avatar):
            let body = """
                       {
                        "name": "\(fullname)",
                        "avatar": "\(avatar)"
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
            
        case .getUserWallet:
            return nil
        case .addAmoutToUserWallet(let amount):
            let body = """
                       {
                        "value": "\(amount)"
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
            
        case .getFriendRequests:
            return nil
        case .getFriends:
            return nil
        case .addFriends(let userIds, let request):
            var body = """
                    {"users_ids":
                    \(userIds)
                    }
                    """
            
            if request {
                var body = """
                        {"users_ids": \(userIds),
                        "request": 1
                        }
                        """
            }
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .removeFriend:
            return nil
        case .getChatrooms:
            return nil
        case .addGroup(let name, let userIds):
            let body = """
                    {
                    "name": "\(name)",
                    "users_ids": \(userIds)
                    }
                    """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .deleteGroup:
            return nil
        case .editGroup(_, let name):
            let body = """
                    {
                    "name": "\(name)"
                    }
                    """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .leaveGroup:
            return nil
        case .addUsersFromGroup(_, let userIds):
            let body = """
                    {"users_ids":
                    \(userIds)
                    }
                    """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .removeUsersFromGroup(_, let userIds):
            let body = """
                    {"users_ids":
                    \(userIds)
                    }
                    """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .searchUserWithCode:
            return nil
        }
        
    }
    
    var headers: HTTP.Headers? {
        switch self {
        default:
            let defaultHeaders = [
                "Content-Type": "application/json",
                "Accept": "application/json",
                "App-Origin": "ios",
//                "x-api-key": "J3uLrOcZWBFbrmWvwaccKpdVhyRpRB6uZGE9akT6IFMpSwIa0Ghl4lqsFSFsTHbG"
            ]
            return defaultHeaders
        }
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalCacheData
    }
    
    var timeout: TimeInterval {
        return TimeInterval(20)
    }
    
    var requireSessionKey: Bool {
        switch self {
        case .anonymousAuth:
            return false
        default:
            return true
        }
    }
    
    var comment: String? {
        return nil
    }
    
}

extension GomaAPIClient {
    
    private static func jsonData(from betTicket: BetTicket, withCashback useCashback: Bool?, withId ticketId: String?) -> String {
        struct RequestBody: Codable {
            
            var stake: Double
            var type: String
            var selections: [Selection]
            var bettingTicketId: Int?
            var useCashback: Bool?
            
            enum CodingKeys: String, CodingKey {
                case stake = "stake"
                case type = "type"
                case selections = "selections"
                case bettingTicketId = "bettingTicket_id"
                case useCashback = "cashback"
            }
            
            init(stake: Double, type: String, selections: [Selection], bettingTicketId: Int? = nil, useCashback: Bool?) {
                self.stake = stake
                self.type = type
                self.selections = selections
                self.bettingTicketId = bettingTicketId
                self.useCashback = useCashback
            }
            
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.stake = try container.decode(Double.self, forKey: .stake)
                self.type = try container.decode(String.self, forKey: .type)
                self.selections = try container.decode([Selection].self, forKey: .selections)
                self.bettingTicketId = try container.decode(Int.self, forKey: .bettingTicketId)
                self.useCashback = try container.decode(Bool.self, forKey: .useCashback)
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(self.stake, forKey: .stake)
                try container.encode(self.type, forKey: .type)
                try container.encode(self.selections, forKey: .selections)
                if let bettingTicketId = self.bettingTicketId {
                    try container.encode(bettingTicketId, forKey: .bettingTicketId)
                }
                if let useCashback = self.useCashback {
                    try container.encode(useCashback, forKey: .useCashback)
                }
            }
        }

        struct Selection: Codable {
            var sport_event_id: String
            var outcome_id: String
        }

        let selections = betTicket.tickets.compactMap { ticket -> Selection? in
            guard 
                let eventId = ticket.eventId,
                let outcomeId = ticket.outcomeId
            else {
                return nil
            }
            return Selection(sport_event_id: eventId, outcome_id: outcomeId)
        }
        
        let bettingTicketIdInt: Int? = Int(ticketId ?? "")
        let requestBody = RequestBody(
            stake: betTicket.globalStake ?? 0, // Assuming a default stake if not provided
            type: betTicket.betGroupingType.identifier,
            selections: selections,
            bettingTicketId: bettingTicketIdInt,
            useCashback: useCashback
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // Optional: to make the JSON easier to read; remove if not needed
        guard let jsonData = try? encoder.encode(requestBody) else { return "" }
        return String(data: jsonData, encoding: .utf8) ?? ""
    }
    
    
}
