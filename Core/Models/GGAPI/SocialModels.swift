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

    var identifier : String {
        switch self {
        case .bet: return "bet"
        case .event: return "event"
        case .chat: return "chat"
        case .custom: return "custom"
        }
    }
}
