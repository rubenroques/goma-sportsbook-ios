//
//  NewGroupViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 21/04/2022.
//

import Foundation
import Combine
import OrderedCollections

class NewGroupViewModel {
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var usersPublisher: CurrentValueSubject<[UserContact], Never> = .init([])
    var initialUsers: [UserContact] = []
    var cachedFriendCellViewModels: [String: AddFriendCellViewModel] = [:]
    var selectedUsers: [UserContact] = []
    
    var listUsersPublisher: CurrentValueSubject<OrderedDictionary<String, [UserContact]>, Never> = .init([:])
    var initialListUsers: OrderedDictionary<String, [UserContact]> = [:]

    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()
    var canAddFriendPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    
    init() {
        self.getUsers()

        self.canAddFriendPublisher.send(false)
    }

    func filterSearch(searchQuery: String) {
        
//        let filteredUsers = self.initialUsers.filter({ $0.username.localizedCaseInsensitiveContains(searchQuery)})
//
//        self.usersPublisher.value = filteredUsers
//
//        self.dataNeedsReload.send()
        let filteredUsersList = self.initialListUsers.filter { key, contacts in
            return contacts.contains { userContact in
                userContact.username.localizedCaseInsensitiveContains(searchQuery)
            }
        }.mapValues { contacts in
            contacts.filter { userContact in
                userContact.username.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        
        self.listUsersPublisher.value = OrderedDictionary(uniqueKeysWithValues: filteredUsersList)
        
        self.dataNeedsReload.send()
        
    }

    func resetUsers() {

//        self.usersPublisher.value = self.initialUsers
        self.listUsersPublisher.value = self.initialListUsers

        self.dataNeedsReload.send()
    }

    func getUsers() {

        self.isLoadingPublisher.send(true)
        
        Env.servicesProvider.getFriends()
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

            }, receiveValue: { [weak self] userFriends in
                
                let mappedFriends = userFriends.map({
                    ServiceProviderModelMapper.userFriend(fromServiceProviderUserFriend: $0)
                }).filter({
                    $0.id != 1
                })
                
                self?.processFriendsData(friends: mappedFriends)
                
            })
            .store(in: &cancellables)

//        Env.gomaNetworkClient.requestFriends(deviceId: Env.deviceId)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure(let error):
//                    print("LIST FRIEND ERROR: \(error)")
//                    self?.isLoadingPublisher.send(false)
//                    self?.dataNeedsReload.send()
//
//                case .finished:
//                    ()
//                }
//
//            }, receiveValue: { response in
//                if let friends = response.data {
//                    self.processFriendsData(friends: friends)
//                }
//            })
//            .store(in: &cancellables)

    }

    private func processFriendsData(friends: [UserFriend]) {
        
        var usersList: OrderedDictionary<String, [UserContact]> = [:]

        for friend in friends {
            let user = UserContact(id: "\(friend.id)", username: friend.username, phones: [], avatar: friend.avatar)
            self.usersPublisher.value.append(user)
            
            if let firstLetter = user.username.first {
                let uppercaseFirstLetter = String(firstLetter).uppercased()
                if let existingListContacts = usersList[uppercaseFirstLetter] {
                    
                    if !existingListContacts.contains(where: {
                        $0.username == user.username
                    }) {
                        usersList[uppercaseFirstLetter]?.append(user)
                    }
                } else {
                    usersList[uppercaseFirstLetter] = [user]
                }
            }
        }
        
        let sortedUsersList = OrderedDictionary(
            uniqueKeysWithValues: usersList.sorted(by: { $0.key < $1.key })
        )
        
        self.listUsersPublisher.value = sortedUsersList

        self.initialUsers = self.usersPublisher.value

        self.initialListUsers = self.listUsersPublisher.value
        
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

        if self.selectedUsers.isEmpty || self.selectedUsers.count < 2 {
            self.canAddFriendPublisher.send(false)
        }
        else {
            self.canAddFriendPublisher.send(true)
        }

    }
}
