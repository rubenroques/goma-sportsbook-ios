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
    var userFriends: [UserFriend] = []
    var cachedUserCellViewModels: [String: GroupUserManagementCellViewModel] = [:]
    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()

    init(users: [UserContact]) {

        self.users = users

        self.processUserContacts()
    }

    private func processUserContacts() {
        for user in self.users {
            if let userId = Int(user.id) {
                let gomaFriend = UserFriend(id: userId, name: user.username, username: user.username, avatar: user.avatar, isAdmin: false)
                self.userFriends.append(gomaFriend)
            }
        }
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

    func getAdminUserId() -> Int {

        if let loggedUserIdString = Env.userSessionStore.userProfilePublisher.value?.userIdentifier,
        let loggedUserId = Int(loggedUserIdString) {
            return loggedUserId
        }

        return 0
    }

}
