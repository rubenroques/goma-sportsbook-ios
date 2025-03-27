//
//  SocialModels.swift
//  Sportsbook
//
//  Created by André Lascas on 26/04/2022.
//

import Foundation

struct UserFriend: Decodable {
    let id: Int
    let name: String?
    let username: String
    let avatar: String?
    let isAdmin: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case username = "username"
        case avatar = "avatar"
        case isAdmin = "is_admin"
    }
}

struct ChatroomData: Decodable {
    let chatroom: Chatroom
    let users: [UserFriend]

    enum CodingKeys: String, CodingKey {
        case chatroom = "chat_room"
        case users = "users"
    }
}

struct Chatroom: Decodable {
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

struct ChatroomId: Decodable {
    let id: Int

    enum CodingKeys: String, CodingKey {
        case id = "id"
    }
}

struct GomaContact: Decodable {
    let id: Int
    let phoneNumber: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case phoneNumber = "phone_number"
    }
}

struct SearchUser: Decodable {
    let id: Int
    let name: String?
    let username: String?

    enum CodignKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case username = "username"
    }
}

struct MessageData {
    var type: MessageType
    var text: String
    var date: String
    var timestamp: Int
    var userId: String?
    var attachment: SharedBetTicketAttachment?
    var prompts: [String]?
}

enum MessageType {
    case receivedOffline
    case receivedOnline
    case sentNotSeen
    case sentSeen
}

struct DateMessages {
    var dateString: String
    var messages: [MessageData]
}

struct ChatMessagesResponse: Decodable {
    var messages: [ChatMessage]

    enum CodingKeys: String, CodingKey {
        case messages = "messages"
    }
}

extension KeyedDecodingContainer {
    func decodeStringOrInt(forKey key: Key) throws -> String {
        do {
            // Try to decode the value as String
            return try self.decode(String.self, forKey: key)
        } catch DecodingError.typeMismatch {
            // If decoding as String fails, try to decode as Int
            let intValue = try self.decode(Int.self, forKey: key)
            // Convert the Int value to String
            return String(intValue)
        }
    }
    
    func decodeStringOrDouble(forKey key: Key) throws -> Double {
        do {
            // Try to decode the value as Double
            return try self.decode(Double.self, forKey: key)
        } catch DecodingError.typeMismatch {
            // If decoding as Double fails, try to decode as String
            let stringValue = try self.decode(String.self, forKey: key)
            // Convert the String value to Double
            guard let doubleValue = Double(stringValue) else {
                throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Failed to convert \(stringValue) to Double.")
            }
            return doubleValue
        }
    }
}

struct ChatMessage: Decodable, Hashable {
    
    var fromUser: String
    var message: String
    var repliedMessage: String?
    var attachment: SharedBetTicketAttachment?
    var toChatroom: Int
    var date: Int
    var isPrompt: Bool?

    enum CodingKeys: String, CodingKey {
        case fromUser = "fromUser"
        case message = "message"
        case repliedMessage = "repliedMessage"
        case attachment = "attachment"
        case toChatroom = "toChatroom"
        case date = "date"
        case isPrompt = "isPrompt"
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

//        self.fromUser = try container.decode(String.self, forKey: .fromUser)
        self.fromUser = try container.decodeStringOrInt(forKey: .fromUser)
        
        self.message = try container.decode(String.self, forKey: .message)
        self.toChatroom = try container.decode(Int.self, forKey: .toChatroom)
        self.date = try container.decode(Int.self, forKey: .date)

        self.attachment = try? container.decode(SharedBetTicketAttachment.self, forKey: .attachment)
        self.repliedMessage = try? container.decode(String.self, forKey: .repliedMessage)
        
        self.isPrompt = try? container.decode(Bool.self, forKey: .isPrompt)
    }
    
}

struct ChatUsersResponse: Decodable {
    var users: [String]
    var messageId: Int

    enum CodingKeys: String, CodingKey {
        case users = "users"
        case messageId = "message_id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.messageId = try container.decode(Int.self, forKey: .messageId)
        
        var usersContainer = try container.nestedUnkeyedContainer(forKey: .users)
        var tempUsers: [String] = []
        
        while !usersContainer.isAtEnd {
            if let stringValue = try? usersContainer.decode(String.self) {
                tempUsers.append(stringValue)
            } else if let intValue = try? usersContainer.decode(Int.self) {
                tempUsers.append(String(intValue))
            } else {
                throw DecodingError.dataCorruptedError(in: usersContainer, debugDescription: "Unsupported type in users array")
            }
        }
        
        self.users = tempUsers
    }
}

struct ChatOnlineUsersResponse: Decodable {
    var users: [String]

    enum CodingKeys: String, CodingKey {
        case users = "users"
    }
}

struct AddFriendResponse: Decodable {
    var chatroomIds: [Int]?

    enum CodingKeys: String, CodingKey {
        case chatroomIds = "chat_room_ids"
    }
}

struct ChatNotification: Decodable {
    var id: Int
    var firstSentDate: String?
    var lastSentDate: String?
    var title: String
    var text: String
    var type: String
    var typeId: Int?
    var subType: String
    var processed: Int
    var createdAt: String?
    var updatedAt: String?
    var url: String?
    var imageUrl: String?
    var notificationUsers: [NotificationUser]

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case firstSentDate = "first_sent_date"
        case lastSentDate = "last_sent_date"
        case title = "title"
        case text = "text"
        case type = "type"
        case typeId = "type_id"
        case subType = "subtype"
        case processed = "processed"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case url = "url"
        case imageUrl = "image_url"
        case notificationUsers = "notification_users"
    }

}

struct NotificationUser: Decodable {

    var id: Int
    var notificationId: Int
    var userId: Int
    var read: Int
    var createdAt: String
    var updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case notificationId = "notification_id"
        case userId = "user_id"
        case read = "read"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum NotificationsType {
    case bet
    case event
    case chat
    case custom
    case news

    var identifier: String {
        switch self {
        case .bet: return "bet"
        case .event: return "event"
        case .chat: return "chat"
        case .custom: return "custom"
        case .news: return "news"
        }
    }
}

struct SocialAppInfo {
    var name: String
    var urlScheme: String
    var urlShare: String

}

struct InAppMessage: Decodable {

    var id: Int
    var title: String
    var titleSlug: String?
    var text: String
    var url: String?
    var imageUrl: String?
    var type: String
    var subtype: String
    var instant: Int
    var processed: Int
    var createdAtDateString: String
    var openingType: String
    var notificationUsers: [NotificationUser]

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case titleSlug = "title_slug"
        case text = "text"
        case url = "url"
        case imageUrl = "image_url"
        case type = "type"
        case subtype = "subtype"
        case instant = "instant"
        case processed = "processed"
        case notificationUsers = "notification_users"
        case createdAtDateString = "created_at"
        case openingType = "opening_type"
    }
}

struct FeaturedTip: Decodable {
    var betId: String
    var selections: [FeaturedTipSelection]?
    var type: String?
    var systemBetType: String?
    var status: String?
    var statusLabel: String?
    var placedDate: String?
    var userId: String?
    var username: String
    var totalOdds: Double
    var avatar: String?

    enum CodingKeys: String, CodingKey {

        case betId = "betId"
        case selections = "selections"
        case type = "type"
        case systemBetType = "systemBetType"
        case status = "status"
        case statusLabel = "statusLabel"
        case placedDate = "placedDate"
        case userId = "user_id"
        case username = "user_name"
        case totalOdds = "total_odds"
        case avatar = "avatar"
    }
    
    init(betId: String,
         selections: [FeaturedTipSelection]? = nil,
         type: String? = nil,
         systemBetType: String? = nil,
         status: String? = nil,
         statusLabel: String? = nil,
         placedDate: String? = nil,
         userId: String? = nil,
         username: String,
         totalOdds: Double,
         avatar: String? = nil) {
        self.betId = betId
        self.selections = selections
        self.type = type
        self.systemBetType = systemBetType
        self.status = status
        self.statusLabel = statusLabel
        self.placedDate = placedDate
        self.userId = userId
        self.username = username
        self.totalOdds = totalOdds
        self.avatar = avatar
    }
    
}

class FeaturedTipSelection: Decodable {
    var outcomeId: String
    var status: String?
    var sportId: String
    var sportName: String
    var sportParentName: String?
    var sportIconId: String?
    var venueId: String?
    var venueName: String?
    var eventId: String
    var eventName: String
    var marketId: String?
    var bettingTypeId: String
    var bettingTypeName: String
    var betName: String
    var odd: Double
    var extraSelectionInfo: ExtraSelectionInfo

    enum CodingKeys: String, CodingKey {
        case outcomeId = "outcomeId"
        case status = "status"
        case sportId = "sportId"
        case sportName = "sportName"
        case sportParentName = "sportParentName"
        case sportIconId = "sportIconId"
        case venueId = "venueId"
        case venueName = "venueName"
        case eventId = "eventId"
        case eventName = "eventName"
        case marketId = "marketId"
        case bettingTypeId = "bettingTypeId"
        case bettingTypeName = "bettingTypeName"
        case betName = "betName"
        case odd = "odd"
        case extraSelectionInfo = "extraSelectionInfo"
    }

    init(outcomeId: String,
         status: String? = nil,
         sportId: String,
         sportName: String,
         sportParentName: String? = nil,
         sportIconId: String? = nil,
         venueId: String? = nil,
         venueName: String? = nil,
         eventId: String,
         eventName: String,
         marketId: String? = nil,
         bettingTypeId: String,
         bettingTypeName: String,
         betName: String,
         odd: Double,
         extraSelectionInfo: ExtraSelectionInfo) {
        self.outcomeId = outcomeId
        self.status = status
        self.sportId = sportId
        self.sportName = sportName
        self.sportParentName = sportParentName
        self.sportIconId = sportIconId
        self.venueId = venueId
        self.venueName = venueName
        self.eventId = eventId
        self.eventName = eventName
        self.marketId = marketId
        self.bettingTypeId = bettingTypeId
        self.bettingTypeName = bettingTypeName
        self.betName = betName
        self.odd = odd
        self.extraSelectionInfo = extraSelectionInfo
    }
    
}

struct ExtraSelectionInfo: Codable, Hashable {

    var bettingOfferId: Int
    var marketName: String
    var outcomeEntity: OutcomeEntity

    enum CodingKeys: String, CodingKey {
        case bettingOfferId = "bettingOfferId"
        case marketName = "marketName"
        case outcomeEntity = "outcomeEntity"
    }
}

struct OutcomeEntity: Codable, Hashable {

    var id: Int
    var statusId: Int

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case statusId = "statusId"
    }
}

struct RankingTip: Decodable {
    var position: Int
    var username: String
    var userId: Int
    var result: Double
    var avatar: String?
    var code: String?
    var anonymous: Bool?

    enum CodingKeys: String, CodingKey {
        case position = "position"
        case username = "user_name"
        case userId = "user_id"
        case result = "result"
        case avatar = "avatar"
        case code = "code"
        case anonymous = "anonymous"
    }
}

struct Follower: Decodable {
    var id: Int
    //var userId: Int
    var name: String
    //var userFollowerId: Int
    //var nameFollower: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        //case userId = "user_id"
        case name = "name"
        //case userFollowerId = "user_follower_id"
        //case nameFollower = "name_follower"
    }

}

struct UsersFollowedResponse: Decodable {
    var usersFollowedIds: [Int]

    enum CodingKeys: String, CodingKey {
        case usersFollowedIds = "users_followed_ids"
    }
}

struct UserProfileInfo: Decodable {
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

struct UserProfileRanking: Decodable {

    var consecutiveWins: Int
    var accumulatedWins: Double
    var highestOdd: Double

    enum CodingKeys: String, CodingKey {
        case consecutiveWins = "consecutive_wins"
        case accumulatedWins = "accumulated_wins"
        case highestOdd = "highest_odd"
    }
}

struct UserProfileSportsData: Decodable {
    var sportId: Int
    var percentage: Double
    var sportIdIcon: String

    enum CodingKeys: String, CodingKey {
        case sportId = "sport_id"
        case percentage = "percentage"
        case sportIdIcon = "sport_id_icon"
    }
}

struct FriendRequest: Decodable {
    var id: Int
    var name: String
    var username: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case username = "username"
    }
}

struct UserConnection: Decodable {
    var friends: Int
    var friendRequest: Int
    var following: Int
    var chatRoomId: Int?

    enum CodingKeys: String, CodingKey {
        case friends = "friends"
        case friendRequest = "friend_request"
        case following = "following"
        case chatRoomId = "chatRoomId"
    }
}
