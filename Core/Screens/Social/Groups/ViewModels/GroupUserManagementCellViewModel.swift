//
//  GroupUserManagementCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 22/04/2022.
//

import Foundation

class GroupUserManagementCellViewModel {

    var userContact: UserContact
    var username: String
    var phone: String
    var isOnline: Bool
    var isAdmin: Bool

    init(userContact: UserContact) {
        self.userContact = userContact

        self.username = userContact.username

        self.phone = userContact.phone

        self.isOnline = false

        self.isAdmin = false
    }
}
