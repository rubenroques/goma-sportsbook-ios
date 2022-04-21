//
//  File.swift
//  Sportsbook
//
//  Created by André Lascas on 18/04/2022.
//

import Foundation

class AddFriendCellViewModel {

    var userContact: UserContact
    var username: String
    var phone: String
    var isCheckboxSelected: Bool
    var isOnline: Bool

    init(userContact: UserContact) {
        self.userContact = userContact
        
        self.username = userContact.username

        self.phone = userContact.phone

        self.isCheckboxSelected = false

        self.isOnline = false
    }
}
