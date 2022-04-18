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
    var isEmptySearch: Bool = true
    var isLoading: CurrentValueSubject<Bool, Never> = .init(false)
    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()

    init() {

        //self.getFriends()
    }

    func getUsers() {
        if self.users.isEmpty {
            for _ in 1...20 {
                let user = UserContact(username: "@GOMA_User", phone: "+351 999 888 777")
                self.users.append(user)

            }

            self.isEmptySearch = false
        }
        self.dataNeedsReload.send()
    }

    func clearUsers() {
        self.users = []
        self.dataNeedsReload.send()
    }
}

struct UserContact {
    var username: String
    var phone: String
}
