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
    var shouldShowAlert: CurrentValueSubject<Bool, Never> = .init(false)
    var friendAlertType: FriendAlertType?

    init() {
        self.canAddFriendPublisher.send(false)
    }

    func getUserInfo(friendCode: String) {
        // TEST
        
        if friendCode == "GOMA123" {
            let user = UserContact(id: "123", username: "@GOMA_User", phones: ["+351 999 888 777"])

            if !self.userInfoAlreadyRetrieved(user: user) {
                self.usersPublisher.value.append(user)
            }
        }
        else if friendCode == "SLB37" {
            let user = UserContact(id: "42", username: "Pedro", phones: ["966 302 428"])

            if !self.userInfoAlreadyRetrieved(user: user) {
                self.usersPublisher.value.append(user)
            }
        }
        else if friendCode == "FCPCHAMP" {
            let user = UserContact(id: "138", username: "A.Lascas", phones: ["968 765 890"])

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

    func sendFriendRequest() {
        var userIds: [String] = []

        for selectedUser in self.selectedUsers {
            userIds.append(selectedUser.id)
        }

        Env.gomaNetworkClient.addFriends(deviceId: Env.deviceId, userIds: userIds)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("ADD FRIEND ERROR: \(error)")
                    self?.friendAlertType = .error
                case .finished:
                    print("ADD FRIEND FINISHED")
                }

                self?.shouldShowAlert.send(true)
            }, receiveValue: { [weak self] response in
                print("ADD FRIEND GOMA: \(response)")
                self?.friendAlertType = .success
            })
            .store(in: &cancellables)
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
    var id: String
    var username: String
    var phones: [String]
}
