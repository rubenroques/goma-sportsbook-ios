//
//  NewGroupViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 21/04/2022.
//

import Foundation
import Combine

class NewGroupViewModel {
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var usersPublisher: CurrentValueSubject<[UserContact], Never> = .init([])
    var initialUsers: [UserContact] = []
    var cachedFriendCellViewModels: [String: AddFriendCellViewModel] = [:]
    var selectedUsers: [UserContact] = []

    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()
    var canAddFriendPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    
    init() {
        self.getUsers()

        self.canAddFriendPublisher.send(false)
    }

    func filterSearch(searchQuery: String) {
        
        let filteredUsers = self.initialUsers.filter({ $0.username.localizedCaseInsensitiveContains(searchQuery)})

        self.usersPublisher.value = filteredUsers

        self.dataNeedsReload.send()

    }

    func resetUsers() {

        self.usersPublisher.value = self.initialUsers

        self.dataNeedsReload.send()
    }

    func getUsers() {
        // TEST
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
//            //self.isEmptySearchPublisher.send(false)
//        }

        self.isLoadingPublisher.send(true)

        Env.gomaNetworkClient.requestFriends(deviceId: Env.deviceId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("LIST FRIEND ERROR: \(error)")
                    self?.isLoadingPublisher.send(false)
                    self?.dataNeedsReload.send()

                case .finished:
                    ()
                }

            }, receiveValue: { response in
                if let friends = response.data {
                    self.processFriendsData(friends: friends)
                }
            })
            .store(in: &cancellables)

    }

    private func processFriendsData(friends: [GomaFriend]) {

        for friend in friends {
            let user = UserContact(id: "\(friend.id)", username: friend.username, phones: ["+351 999 888 777"])
            self.usersPublisher.value.append(user)
        }

        self.initialUsers = self.usersPublisher.value

        self.isLoadingPublisher.send(false)
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
