//
//  FriendStatusCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 26/04/2022.
//

import Foundation
import Combine

class FriendStatusCellViewModel {
    var friend: GomaFriend
    var name: String?
    var id: Int
    var username: String
    var isOnline: Bool
    var notificationsEnabled: Bool

    init(friend: GomaFriend) {
        self.friend = friend

        self.id = friend.id

        self.name = friend.name

        self.username = friend.username

        self.isOnline = false

        self.notificationsEnabled = true
    }
}
