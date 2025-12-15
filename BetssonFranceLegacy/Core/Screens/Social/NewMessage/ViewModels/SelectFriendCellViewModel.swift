//
//  SelectFriendCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 06/05/2022.
//

import Foundation

class SelectFriendCellViewModel {

    var userContact: UserContact
    var username: String
    var phones: [String]
    var isOnline: Bool
    var conversationData: ConversationData

    init(userContact: UserContact, conversationData: ConversationData) {
        self.userContact = userContact
        self.username = userContact.username
        self.phones = userContact.phones
        self.conversationData = conversationData
        self.isOnline = false
    }

}
