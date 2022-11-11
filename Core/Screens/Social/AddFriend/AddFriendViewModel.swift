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
    private var chatPage: Int = 1

    // MARK: Public Properties
    var usersPublisher: CurrentValueSubject<[UserContact], Never> = .init([])
    var initialUsers: [UserContact] = []
    var cachedSearchCellViewModels: [String: AddFriendCellViewModel] = [:]
    var cachedFriendsCellViewModels: [Int: FriendStatusCellViewModel] = [:]
    var friendsPublisher: CurrentValueSubject<[GomaFriend], Never> = .init([])
    var userContactSection: CurrentValueSubject<[UserContactSection], Never> = .init([])
    var individualChatrooms: [ChatroomData] = []

    var hasDoneSearch: Bool = false
    var selectedUsers: [UserContact] = []
    var isLoading: CurrentValueSubject<Bool, Never> = .init(false)
    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()
    var canAddFriendPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var friendCodeInvalidPublisher: PassthroughSubject<Void, Never> = .init()
    var shouldShowAlert: CurrentValueSubject<Bool, Never> = .init(false)
    var friendAlertType: FriendAlertType?
    var chatroomsResponse: [Int] = []

    init() {
        self.canAddFriendPublisher.send(false)

        self.getUserFriends()
    }

    func getUserInfo(friendCode: String) {

        Env.gomaNetworkClient.searchUserCode(deviceId: Env.deviceId, code: friendCode)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("SEARCH FRIEND ERROR: \(error)")
                    self?.friendCodeInvalidPublisher.send()
                case .finished:
                    print("SEARCH FRIEND FINISHED")
                }

                self?.dataNeedsReload.send()

            }, receiveValue: { [weak self] searchUser in
                print("SEARCH FRIEND GOMA: \(searchUser)")

                guard let self = self else {return}

                let user = UserContact(id: "\(searchUser.id)", username: searchUser.username ?? "User", phones: [])

                if !self.userInfoAlreadyRetrieved(user: user) {
                    self.usersPublisher.value.append(user)
                    self.processSearchUsers()
                }
            })
            .store(in: &cancellables)

        //self.dataNeedsReload.send()
    }

    private func getUserFriends() {
        Env.gomaNetworkClient.requestFriends(deviceId: Env.deviceId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("LIST FRIEND ERROR: \(error)")
                case .finished:
                    ()
                }

//                self?.isLoadingPublisher.send(false)
//                self?.dataNeedsReload.send()

            }, receiveValue: { [weak self] response in
                if let friends = response.data {
                    self?.friendsPublisher.value = friends
                    self?.processFriends()
                }
            })
            .store(in: &cancellables)
    }

    private func getIndividualChatroomsData() {

        Env.gomaNetworkClient.requestChatrooms(deviceId: Env.deviceId, page: self.chatPage)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("CHATROOMS ERROR: \(error)")
//                    self?.isLoadingPublisher.send(false)
//                    self?.dataNeedsReload.send()
                case .finished:
                    ()
                }

            }, receiveValue: { [weak self] response in
                if let chatrooms = response.data {
                    self?.storeIndividualChatrooms(chatroomsData: chatrooms)
                }

            })
            .store(in: &cancellables)
    }

    private func storeIndividualChatrooms(chatroomsData: [ChatroomData]) {

        for chatroomData in chatroomsData {

            if chatroomData.chatroom.type == ChatroomType.individual.identifier {

                self.individualChatrooms.append(chatroomData)
            }

        }

        print("CHATROOMS INDIVIDUAL: \(self.individualChatrooms)")

        // self.isLoadingPublisher.send(false)
        self.dataNeedsReload.send()
    }

    func getConversationData(userId: String) -> ConversationData {
        var chatroomId = 0
        var chatroomUsername = ""
        var chatroomUsers: [GomaFriend] = []

        for chatroomData in self.individualChatrooms {
            for user in chatroomData.users {
                let userIdString = "\(user.id)"
                if userIdString == userId {
                    chatroomId = chatroomData.chatroom.id
                    chatroomUsername = user.username
                    chatroomUsers = chatroomData.users
                }
            }
        }

        let conversationData = ConversationData(id: chatroomId, conversationType: .user, name: chatroomUsername, lastMessage: "", date: "Now", isLastMessageSeen: false, groupUsers: chatroomUsers)

        return conversationData
    }

    private func processSearchUsers() {
        let searchUserContactSection = UserContactSection(contactSectionType: .search, userContacts: self.usersPublisher.value)

        if self.userContactSection.value[safe: 0] != nil && self.userContactSection.value[safe: 0]?.contactSectionType == .friends {

            if let friendsSection = self.userContactSection.value[safe: 0] {

                self.userContactSection.value = []

                self.userContactSection.value.append(searchUserContactSection)

                self.userContactSection.value.append(friendsSection)
            }
        }
        else {
            self.userContactSection.value.append(searchUserContactSection)
        }

        self.dataNeedsReload.send()
    }

    private func processFriends() {

        var friendsContactArray: [UserContact] = []

        for friend in self.friendsPublisher.value {
            let user = UserContact(id: "\(friend.id)", username: friend.username ?? "User", phones: [])

            friendsContactArray.append(user)
        }

        let userContactSection = UserContactSection(contactSectionType: .friends, userContacts: friendsContactArray)

        self.userContactSection.value.append(userContactSection)

        self.getIndividualChatroomsData()

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

                if let chatroomIdsData = response.data?.chatroomIds {
                    self?.chatroomsResponse = chatroomIdsData
                }
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
    var emails: [String]?
}

enum ContactSectionType {
    case search
    case friends
}

struct UserContactSection {
    var contactSectionType: ContactSectionType
    var userContacts: [UserContact]
}
