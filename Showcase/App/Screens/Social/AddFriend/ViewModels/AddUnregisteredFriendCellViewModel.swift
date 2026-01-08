//
//  AddUnregisteredFriendCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 21/04/2022.
//

import Foundation

class AddUnregisteredFriendCellViewModel {

    var userContact: UserContact
    var username: String
    var phones: [String]
    var emails: [String]?

    init(userContact: UserContact) {
        self.userContact = userContact

        self.username = userContact.username

        self.phones = userContact.phones

        self.emails = userContact.emails

    }
}
