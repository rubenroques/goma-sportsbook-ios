//
//  FriendProfileViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 18/05/2022.
//

import Foundation

class FriendProfileViewModel {

    var username: String
    var userId: Int

    init(friendData: GomaFriend) {
        self.username = friendData.username

        self.userId = friendData.id
    }
}
