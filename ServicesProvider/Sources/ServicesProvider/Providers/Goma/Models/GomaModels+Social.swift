//
//  GomaModels+Social.swift
//
//
//  Created by André Lascas on 15/02/2024.
//

import Foundation

extension GomaModels {
    
    struct FolloweesResponse: Codable {
        var followees: [Follower]
        
        enum CodingKeys: String, CodingKey {
            case followees = "users_followed_ids"
        }
    }
    
    struct FollowersResponse: Codable {
        var followers: [Follower]
        
        enum CodingKeys: String, CodingKey {
            case followers = "users_followers_ids"
        }
    }
    
    struct Follower: Codable {
        var id: Int
        var name: String
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
        }
    }
    
    struct FolloweeActionResponse: Codable {
        var followeeIds: [Int]
        
        enum CodingKeys: String, CodingKey {
            case followeeIds = "users_followed_ids"
        }
    }
    
    struct TotalFolloweesResponse: Codable {
        var count: Int
        
        enum CodingKeys: String, CodingKey {
            case count = "users_followed_total"
        }
    }
    
    struct TotalFollowersResponse: Codable {
        var count: Int
        
        enum CodingKeys: String, CodingKey {
            case count = "users_followers_total"
        }
    }
    
    struct TipRanking: Codable {
        
        var position: Int
        var result: Double
        var userId: Int
        var name: String
        var code: String
        var avatar: String?
        var anonymous: Bool
        
        enum CodingKeys: String, CodingKey {
            case position = "position"
            case result = "result"
            case userId = "user_id"
            case name = "name"
            case code = "code"
            case avatar = "avatar"
            case anonymous = "anonymous"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.TipRanking.CodingKeys> = try decoder.container(keyedBy: GomaModels.TipRanking.CodingKeys.self)
            
            self.position = try container.decode(Int.self, forKey: GomaModels.TipRanking.CodingKeys.position)
            
            self.result = try container.decode(Double.self, forKey: GomaModels.TipRanking.CodingKeys.result)
            
            self.userId = try container.decode(Int.self, forKey: GomaModels.TipRanking.CodingKeys.userId)
            
            self.name = try container.decode(String.self, forKey: GomaModels.TipRanking.CodingKeys.name)

            self.code = try container.decode(String.self, forKey: GomaModels.TipRanking.CodingKeys.code)

            self.avatar = try container.decodeIfPresent(String.self, forKey: GomaModels.TipRanking.CodingKeys.avatar)

            let anonymousValue = try container.decode(Int.self, forKey: GomaModels.TipRanking.CodingKeys.anonymous)
            
            self.anonymous = anonymousValue == 1 ? true : false

            
        }
    }
    
    struct UserProfileInfo: Codable {
        var name: String
        var avatar: String?
        var following: Int
        var followers: Int
        var rankings: UserProfileRanking
        var sportsPerc: [UserProfileSportsData]

        enum CodingKeys: String, CodingKey {
            case name = "name"
            case avatar = "avatar"
            case following = "following"
            case followers = "followers"
            case rankings = "rankings"
            case sportsPerc = "sports_perc"
        }
    }

    struct UserProfileRanking: Codable {

        var consecutiveWins: Int
        var accumulatedWins: Double
        var highestOdd: Double

        enum CodingKeys: String, CodingKey {
            case consecutiveWins = "consecutive_wins"
            case accumulatedWins = "accumulated_wins"
            case highestOdd = "highest_odd"
        }
    }

    struct UserProfileSportsData: Codable {
        var sportId: Int
        var percentage: Double
        var sportIdIcon: String

        enum CodingKeys: String, CodingKey {
            case sportId = "sport_id"
            case percentage = "percentage"
            case sportIdIcon = "sport_id_icon"
        }
    }
    
    struct FriendRequest: Codable {
        var id: Int
        var name: String
        var username: String

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case username = "username"
        }
    }
    
    struct GomaFriend: Codable {
        var id: Int
        var name: String
        var avatar: String?
        var isAdmin: Bool?
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case avatar = "avatar"
            case isAdmin = "is_admin"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.GomaFriend.CodingKeys> = try decoder.container(keyedBy: GomaModels.GomaFriend.CodingKeys.self)
            
            self.id = try container.decode(Int.self, forKey: GomaModels.GomaFriend.CodingKeys.id)
            
            self.name = try container.decode(String.self, forKey: GomaModels.GomaFriend.CodingKeys.name)

            self.avatar = try container.decodeIfPresent(String.self, forKey: GomaModels.GomaFriend.CodingKeys.avatar)

            let isAdminValue = try container.decodeIfPresent(Int.self, forKey: GomaModels.GomaFriend.CodingKeys.isAdmin)
            
            self.isAdmin = isAdminValue == 1 ? true : false

        }
    }
    
    struct ChatroomData: Codable {
        let chatroom: Chatroom
        let users: [GomaFriend]

        enum CodingKeys: String, CodingKey {
            case chatroom = "chat_room"
            case users = "users"
        }
    }
    
    struct Chatroom: Codable {
        let id: Int
        let name: String
        let type: String
        let creationTimestamp: Int?

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case type = "type"
            case creationTimestamp = "created_at"
        }
    }
    
    struct SearchUser: Codable {
        let id: Int
        let username: String
        let avatar: String?

        enum CodignKeys: String, CodingKey {
            case id = "id"
            case username = "username"
            case avatar = "avatar"
        }
    }
    
    struct AddFriendResponse: Codable {
        var chatroomIds: [Int]?

        enum CodingKeys: String, CodingKey {
            case chatroomIds = "chat_room_ids"
        }
    }

    struct ChatroomId: Codable {
        let id: Int

        enum CodingKeys: String, CodingKey {
            case id = "id"
        }
    }
    
    struct DeleteGroupResponse: Codable {
        var status: String
        var message: String?

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case message = "message"
        }
    }
}
