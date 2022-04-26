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

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case username = "username"
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
