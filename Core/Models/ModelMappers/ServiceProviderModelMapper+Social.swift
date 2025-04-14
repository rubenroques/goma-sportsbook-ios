//
//  ServiceProviderModelMapper+Social.swift
//  MultiBet
//
//  Created by André Lascas on 15/02/2024.
//

import Foundation
import ServicesProvider

extension ServiceProviderModelMapper {
    
    static func follower(fromServiceProviderFollower follower: ServicesProvider.Follower) -> Follower {
        return Follower(id: follower.id, name: follower.name)
    }
    
    static func userProfileInfo(fromServiceProviderUserProfileInfo userProfileInfo: ServicesProvider.UserProfileInfo) -> UserProfileInfo {
        let userProfileRanking = Self.userProfileRanking(fromServiceProviderUserProfileRanking: userProfileInfo.rankings)
        let userProfileSportsData = userProfileInfo.sportsPerc.map( {
            return Self.userProfileSportsData(fromServiceProviderUserProfileSportsData: $0)
        })
        return UserProfileInfo(name: userProfileInfo.name,
                               avatar: userProfileInfo.avatar,
                               following: userProfileInfo.following,
                               followers: userProfileInfo.followers,
                               rankings: userProfileRanking,
                               sportsPerc: userProfileSportsData)
    }
    
    static func userProfileRanking(fromServiceProviderUserProfileRanking userProfileRanking: ServicesProvider.UserProfileRanking) -> UserProfileRanking {
        return UserProfileRanking(consecutiveWins: userProfileRanking.consecutiveWins,
                                  accumulatedWins: userProfileRanking.accumulatedWins,
                                  highestOdd: userProfileRanking.highestOdd)
    }
    
    static func userProfileSportsData(fromServiceProviderUserProfileSportsData userProfileSportsData: ServicesProvider.UserProfileSportsData) -> UserProfileSportsData {
        return UserProfileSportsData(sportId: userProfileSportsData.sportId,
                                     percentage: userProfileSportsData.percentage,
                                     sportIdIcon: userProfileSportsData.sportIdIcon)
    }
    
    static func friendRequest(fromServiceProviderFriendRequest friendRequest: ServicesProvider.FriendRequest) -> FriendRequest {
        
        return FriendRequest(id: friendRequest.id, name: friendRequest.name, username: friendRequest.username)
    }
    
    static func userFriend(fromServiceProviderUserFriend userFriend: ServicesProvider.UserFriend) -> UserFriend {
        
        return UserFriend(id: userFriend.id, name: userFriend.name, username: userFriend.name, avatar: userFriend.avatar, isAdmin: userFriend.isAdmin)
    }
    
    static func chatroomData(fromServiceProviderChatroomData chatroomData: ServicesProvider.ChatroomData) -> ChatroomData {
        
        let chatroom = Self.chatroom(fromServiceProviderChatroom: chatroomData.chatroom)
        
        let userFriends = chatroomData.users.map({
            return Self.userFriend(fromServiceProviderUserFriend: $0)
        })
        
        return ChatroomData(chatroom: chatroom, users: userFriends)
    }
    
    static func chatroom(fromServiceProviderChatroom chatroom: ServicesProvider.Chatroom) -> Chatroom {
        return Chatroom(id: chatroom.id, name: chatroom.name, type: chatroom.type, creationTimestamp: chatroom.creationTimestamp)
    }
}
