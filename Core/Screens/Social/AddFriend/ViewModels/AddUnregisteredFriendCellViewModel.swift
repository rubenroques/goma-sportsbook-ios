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
    var phone: String

    init(userContact: UserContact) {
        self.userContact = userContact

        self.username = userContact.username

        self.phone = userContact.phone

    }
}
