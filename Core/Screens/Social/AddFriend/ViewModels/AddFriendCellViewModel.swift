//
//  File.swift
//  Sportsbook
//
//  Created by André Lascas on 18/04/2022.
//

import Foundation

class AddFriendCellViewModel {

    var username: String
    var phone: String
    var isCheckboxSelected: Bool

    init(userContact: UserContact) {
        self.username = userContact.username

        self.phone = userContact.phone

        self.isCheckboxSelected = false

    }
}
