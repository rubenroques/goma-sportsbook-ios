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
    var usersPublisher: CurrentValueSubject<[UserContact], Never> = .init([])
    var initialUsers: [UserContact] = []
    var cachedCellViewModels: [String: AddFriendCellViewModel] = [:]
    var hasDoneSearch: Bool = false
    var selectedUsers: [UserContact] = []
    var isLoading: CurrentValueSubject<Bool, Never> = .init(false)
    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()
    var canAddFriendPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var friendCodeInvalidPublisher: PassthroughSubject<Void, Never> = .init()

    init() {
        self.canAddFriendPublisher.send(false)
    }

    func getUserInfo(friendCode: String) {
        // TEST
        var friendCodes = ["GOMA123", "SB100", "FCPCHAMP"]

        if friendCode == "GOMA123" {
            let user = UserContact(id: "123", username: "@GOMA_User", phones: ["+351 999 888 777"])

            if !self.userInfoAlreadyRetrieved(user: user) {
                self.usersPublisher.value.append(user)
            }
        }
        else if friendCode == "SB100" {
            let user = UserContact(id: "100", username: "@Sportsbook_User", phones: ["+351 999 000 123"])

            if !self.userInfoAlreadyRetrieved(user: user) {
                self.usersPublisher.value.append(user)
            }
        }
        else if friendCode == "FCPCHAMP" {
            let user = UserContact(id: "30", username: "@FCPorto_ Champion", phones: ["+351 999 001 893"])

            if !self.userInfoAlreadyRetrieved(user: user) {
                self.usersPublisher.value.append(user)
            }
        }
        else {
            self.friendCodeInvalidPublisher.send()
        }

        self.dataNeedsReload.send()
    }

    func userInfoAlreadyRetrieved(user: UserContact) -> Bool {
        if !self.usersPublisher.value.contains(where: { $0.id == user.id }) {
            return false
        }
        return true
    }

//    func filterSearch(searchQuery: String) {
//
//        self.getUsers()
//
//        let filteredUsers = self.users.filter({ $0.username.localizedCaseInsensitiveContains(searchQuery)})
//
//        self.users = filteredUsers
//
//        self.dataNeedsReload.send()
//
//    }
//
//    func getUsers() {
//        // TEST
//        if self.users.isEmpty {
//            for i in 0...19 {
//                if i <= 5 {
//                    let user = UserContact(id: "\(i)", username: "@GOMA_User_\(i)", phone: "+351 999 888 777")
//                    self.users.append(user)
//                }
//                else if i > 5 && i <= 13 {
//                    let user = UserContact(id: "\(i)", username: "@Sportsbook_Admin_\(i)", phone: "+351 995 664 551")
//                    self.users.append(user)
//                }
//                else {
//                    let user = UserContact(id: "\(i)", username: "@Ze_da_Tasca_\(i)", phone: "+351 991 233 012")
//                    self.users.append(user)
//                }
//
//            }
//
//            self.isEmptySearchPublisher.send(false)
//        }
//
//        self.initialUsers = self.users
//
//        //self.dataNeedsReload.send()
//    }
//
//    func clearUsers() {
//        self.users = []
//        self.selectedUsers = []
//        self.cachedCellViewModels = [:]
//        self.isEmptySearchPublisher.send(true)
//        self.canAddFriendPublisher.send(false)
//        self.dataNeedsReload.send()
//    }
//
//    func resetUsers() {
//
//        //self.sectionUsersArray = self.initialFullSectionUsers
//
//        self.dataNeedsReload.send()
//    }

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
    var id: String
    var username: String
    var phones: [String]
}
