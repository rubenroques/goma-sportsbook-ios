//
//  EditGroupAddFriendViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 12/05/2022.
//

import Foundation
import Combine

class EditGroupAddFriendViewModel {
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var chatroomId: Int
    // MARK: Public Properties
    var usersPublisher: CurrentValueSubject<[UserContact], Never> = .init([])
    var initialUsers: [UserContact] = []
    var groupUsers: [UserContact] = []
    var selectedUsers: [UserContact] = []
    var canAddFriendPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var addedSelectedUsers: CurrentValueSubject<[UserContact], Never> = .init([])
    var cachedCellViewModels: [String: AddFriendCellViewModel] = [:]

    init(groupUsers: [UserContact], chatroomId: Int) {
        self.groupUsers = groupUsers

        self.chatroomId = chatroomId

        self.canAddFriendPublisher.send(false)

        self.getFriends()
    }

    private func getFriends() {

        Env.gomaNetworkClient.requestFriends(deviceId: Env.deviceId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("FRIENDS ERROR: \(error)")
                case .finished:
                    print("FRIENDS FINISHED")
                }
            }, receiveValue: { [weak self] response in
                print("FRIENDS GOMA: \(response)")
                if let friends = response.data {
                    self?.processFriendsData(friends: friends)
                }
            })
            .store(in: &cancellables)

    }

    private func processFriendsData(friends: [GomaFriend]) {

        for friend in friends {
            let user = UserContact(id: "\(friend.id)", username: friend.username, phones: [])
            if !self.groupUsers.contains(where: {$0.id == user.id }) {
                self.usersPublisher.value.append(user)
            }
        }

        self.initialUsers = self.usersPublisher.value

    }

    func filterSearch(searchQuery: String) {

        let filteredUsers = self.usersPublisher.value.filter({ $0.username.localizedCaseInsensitiveContains(searchQuery)})

        self.usersPublisher.value = filteredUsers

    }

    func resetUsers() {

        self.usersPublisher.value = self.initialUsers

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

    func addFriendsToGroup() {
        var userIds: [String] = []
        let selectedUsers = self.selectedUsers

        for user in selectedUsers {
            userIds.append(user.id)
        }

        print("FRIENDS TO ADD: \(userIds)")

        Env.gomaNetworkClient.addUserToGroup(deviceId: Env.deviceId, chatroomId: self.chatroomId, userIds: userIds)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("ADD FRIENDS GROUP ERROR: \(error)")
                case .finished:
                    print("ADD FRIENDS GROUP FINISHED")
                }
            }, receiveValue: { [weak self] response in
                print("ADD FRIENDS GROUP GOMA: \(response)")
                self?.addedSelectedUsers.send(selectedUsers)
            })
            .store(in: &cancellables)
    }
}
