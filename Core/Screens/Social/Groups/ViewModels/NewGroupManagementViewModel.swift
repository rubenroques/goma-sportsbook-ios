//
//  NewGroupManagementViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 22/04/2022.
//

import Foundation
import Combine

class NewGroupManagementViewModel {
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var users: [UserContact] = []
    var gomaFriends: [GomaFriend] = []
    var cachedUserCellViewModels: [String: GroupUserManagementCellViewModel] = [:]
    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()

    init(users: [UserContact]) {

        self.users = users
        //self.getUsers()
        self.processUserContacts()
    }

    private func processUserContacts() {
        for user in self.users {
            if let userId = Int(user.id) {
                let gomaFriend = GomaFriend(id: userId, name: user.username, username: user.username, isAdmin: 0)
                self.gomaFriends.append(gomaFriend)
            }
        }
    }

    func getUsers() {
        // TEST
        if self.users.isEmpty {
            for i in 0...19 {
                if i <= 5 {
                    let user = UserContact(id: "\(i)", username: "@GOMA_User_\(i)", phones: ["+351 999 888 777"])
                    self.users.append(user)
                }
                else if i > 5 && i <= 13 {
                    let user = UserContact(id: "\(i)", username: "@Sportsbook_Admin_\(i)", phones: ["+351 995 664 551"])
                    self.users.append(user)
                }
                else {
                    let user = UserContact(id: "\(i)", username: "@Ze_da_Tasca_\(i)", phones: ["+351 991 233 012"])
                    self.users.append(user)
                }

            }

            //self.isEmptySearchPublisher.send(false)
        }

        self.dataNeedsReload.send()
    }

    func getGroupInitials(text: String) -> String {
        var initials = ""

        for letter in text {
            if letter.isUppercase {
                if initials.count < 2 {
                    initials = "\(initials)\(letter)"
                }
            }
        }

        if initials == "" {
            if let firstChar = text.first {
                initials = "\(firstChar.uppercased())"
            }
        }

        return initials
    }

}
