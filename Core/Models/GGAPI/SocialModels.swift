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

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case type = "type"
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
    var date: String
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
