//
//  AddFriendViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 18/04/2022.
//

import Foundation
import Combine

class AddFriendViewModel {
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var users: [UserContact] = []
    var cachedCellViewModels: [Int: AddFriendCellViewModel] = [:]
    var hasDoneSearch: Bool = false
    var selectedUsers: [UserContact] = []
    var isEmptySearchPublisher: CurrentValueSubject<Bool, Never> = .init(true)
    var isLoading: CurrentValueSubject<Bool, Never> = .init(false)
    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()
    var canAddFriendPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    init() {
        self.canAddFriendPublisher.send(false)
    }

    func getUsers() {
        // TEST
        if self.users.isEmpty {
            for i in 0...20 {
                let user = UserContact(id: i, username: "@GOMA_User", phone: "+351 999 888 777")
                self.users.append(user)

            }

            self.isEmptySearchPublisher.send(false)
        }
        self.dataNeedsReload.send()
    }

    func clearUsers() {
        self.users = []
        self.selectedUsers = []
        self.cachedCellViewModels = [:]
        self.isEmptySearchPublisher.send(true)
        self.canAddFriendPublisher.send(false)
        self.dataNeedsReload.send()
    }

    func checkSelectedUserContact(cellViewModel: AddFriendCellViewModel) {

        if cellViewModel.isCheckboxSelected {
            self.selectedUsers.append(cellViewModel.userContact)
        }
        else {
            let usersArray = self.selectedUsers.filter {$0.id != cellViewModel.userContact.id}
            self.selectedUsers = usersArray
        }

        if self.selectedUsers.isEmpty {
            self.canAddFriendPublisher.send(false)
        }
        else {
            self.canAddFriendPublisher.send(true)
        }

    }
}

struct UserContact {
    var id: Int
    var username: String
    var phone: String
}
