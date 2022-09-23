//
//  SocialModels.swift
//  Sportsbook
//
//  Created by André Lascas on 26/04/2022.
//

import Foundation

struct GomaFriend: Decodable {
    let id: Int
    let name: String?
    let username: String
    let isAdmin: Int?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case username = "username"
        case isAdmin = "is_admin"
    }
}

struct ChatroomData: Decodable {
    let chatroom: Chatroom
    let users: [GomaFriend]

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

struct ChatMessage: Decodable, Hashable {
    
    var fromUser: String
    var message: String
    var repliedMessage: String?
    var attachment: SharedBetTicketAttachment?
    var toChatroom: Int
    var date: Int

    enum CodingKeys: String, CodingKey {
        case fromUser = "fromUser"
        case message = "message"
        case repliedMessage = "repliedMessage"
        case attachment = "attachment"
        case toChatroom = "toChatroom"
        case date = "date"
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.fromUser = try container.decode(String.self, forKey: .fromUser)
        self.message = try container.decode(String.self, forKey: .message)
        self.toChatroom = try container.decode(Int.self, forKey: .toChatroom)
        self.date = try container.decode(Int.self, forKey: .date)

        self.attachment = try? container.decode(SharedBetTicketAttachment.self, forKey: .attachment)
        self.repliedMessage = try? container.decode(String.self, forKey: .repliedMessage)
    }
    
}

struct ChatUsersResponse: Decodable {
    var users: [String]
    var messageId: Int

    enum CodingKeys: String, CodingKey {
        case users = "users"
        case messageId = "message_id"
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
    var typeId: Int
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
    var type: String
    var systemBetType: String?
    var status: String
    var statusLabel: String
    var placedDate: String?
    var userId: String
    var username: String
    var totalOdds: String

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
    }
}

class FeaturedTipSelection: Decodable {
    var outcomeId: String
    var status: String
    //var statusLabel: String
    var sportId: String
    var sportName: String
    //var sportParentId: String
    var sportParentName: String
    var venueId: String
    var venueName: String
    var eventId: String
    var eventName: String
    //var homeParticipantId: String
    //var awayParticipantId: String
    var bettingTypeId: String
    var bettingTypeName: String
    var betName: String
    var odds: String
    //var eventPartId: String
    var extraSelectionInfo: ExtraSelectionInfo

//    var odds: Double?

    enum CodingKeys: String, CodingKey {
        case outcomeId = "outcomeId"
        case status = "status"
        //case statusLabel = "statusLabel"
        case sportId = "sportId"
        case sportName = "sportName"
        //case sportParentId = "sportParentId"
        case sportParentName = "sportParentName"
        case venueId = "venueId"
        case venueName = "venueName"
        case eventId = "eventId"
        case eventName = "eventName"
        //case homeParticipantId = "homeParticipantId"
        //case awayParticipantId = "awayParticipantId"
        case bettingTypeId = "bettingTypeId"
        case bettingTypeName = "bettingTypeName"
        case betName = "betName"
        case odds = "odds"
        //case eventPartId = "eventPartId"
        case extraSelectionInfo = "extraSelectionInfo"

//        case odds = "odds"
    }
}

struct ExtraSelectionInfo: Decodable {

    var bettingOfferId: Int
//    var eventTypeId: Int
    var marketName: String
    var outcomeEntity: OutcomeEntity
//    var categoryId: Int
//    var categoryName: String
//    var creationTime: Int

    enum CodingKeys: String, CodingKey {
        case bettingOfferId = "bettingOfferId"
//        case eventTypeId = "eventTypeId"
        case marketName = "marketName"
        case outcomeEntity = "outcomeEntity"
//        case categoryId = "categoryId"
//        case categoryName = "categoryName"
//        case creationTime = "creationTime"
    }
}

struct OutcomeEntity: Decodable {

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

    enum CodingKeys: String, CodingKey {
        case position = "position"
        case username = "user_name"
        case userId = "user_id"
        case result = "result"
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

    var following: Int
    var followers: Int
    var rankings: UserProfileRanking
    // var sportsPerc: String

    enum CodingKeys: String, CodingKey {
        case following = "following"
        case followers = "followers"
        case rankings = "rankings"
        // case sportsPerc = "sports_perc"
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
