//
//  GomaModelMapper+Social.swift
//
//
//  Created by André Lascas on 15/02/2024.
//

import Foundation

extension GomaModelMapper {
    
    static func follower(fromFollower follower: GomaModels.Follower) -> Follower {
        
        return Follower(id: follower.id, name: follower.name)
    }
    
    static func tipRanking(fromTipRanking tipRanking: GomaModels.TipRanking) -> TipRanking {
        return TipRanking(position: tipRanking.position, result: tipRanking.result, userId: tipRanking.userId, name: tipRanking.name, code: tipRanking.code, avatar: tipRanking.avatar, anonymous: tipRanking.anonymous)
    }
    
    static func userProfileInfo(fromUserProfileInfo userProfileInfo: GomaModels.UserProfileInfo) -> UserProfileInfo {
        
        let rankings = Self.userRanking(fromUserRanking: userProfileInfo.rankings)
        
        let sportsPerc = userProfileInfo.sportsPerc.map({
            
            return Self.userSportsData(fromUserSportsData: $0)
        })
        
        return UserProfileInfo(name: userProfileInfo.name, avatar: userProfileInfo.avatar, following: userProfileInfo.following, followers: userProfileInfo.followers, rankings: rankings, sportsPerc: sportsPerc)
    }
    
    static func userRanking(fromUserRanking userRanking: GomaModels.UserProfileRanking) -> UserProfileRanking {
        
        return UserProfileRanking(consecutiveWins: userRanking.consecutiveWins, accumulatedWins: userRanking.accumulatedWins, highestOdd: userRanking.highestOdd)
    }
    
    static func userSportsData(fromUserSportsData userSportsData: GomaModels.UserProfileSportsData) -> UserProfileSportsData {
        
        return UserProfileSportsData(sportId: userSportsData.sportId, percentage: userSportsData.percentage, sportIdIcon: userSportsData.sportIdIcon ?? "")
    }
    
    static func friendRequest(fromFriendRequest friendRequest: GomaModels.FriendRequest) -> FriendRequest {
        
        return FriendRequest(id: friendRequest.id, name: friendRequest.name, username: friendRequest.username)
    }
    
    static func userFriend(fromUserFriend userFriend: GomaModels.UserFriend) -> UserFriend {
        
        return UserFriend(id: userFriend.id, name: userFriend.name, avatar: userFriend.avatar, isAdmin: userFriend.isAdmin)
    }
    
    static func chatroomData(fromChatroomData chatroomData: GomaModels.ChatroomData) -> ChatroomData {
        
        let chatroom = Self.chatroom(fromChatroom: chatroomData.chatroom)
        
        let userFriends = chatroomData.users.map({
            return Self.userFriend(fromUserFriend: $0)
        })
        
        return ChatroomData(chatroom: chatroom, users: userFriends)
    }
    
    static func chatroom(fromChatroom chatroom: GomaModels.Chatroom) -> Chatroom {
        
        return Chatroom(id: chatroom.id, name: chatroom.name, type: chatroom.type, creationTimestamp: chatroom.creationTimestamp)
    }
    
    static func searchUser(fromSearchUser searchUser: GomaModels.SearchUser) -> SearchUser {
        
        return SearchUser(id: searchUser.id, username: searchUser.username, avatar: searchUser.avatar)
    }
    
    static func addFriendResponse(fromAddFriendResponse addFriendResponse: GomaModels.AddFriendResponse) -> AddFriendResponse {
        
        return AddFriendResponse(chatroomIds: addFriendResponse.chatroomIds)
    }
    
    static func chatroomId(fromChatroomId chatroomId: GomaModels.ChatroomId) -> ChatroomId {
        
        return ChatroomId(id: chatroomId.id)
    }
    
    static func deleteGroupResponse(fromDeleteGroupResponse deleteGroupResponse: GomaModels.DeleteGroupResponse) -> DeleteGroupResponse {
        
        return DeleteGroupResponse(status: deleteGroupResponse.status, message: deleteGroupResponse.message)
    }
}
