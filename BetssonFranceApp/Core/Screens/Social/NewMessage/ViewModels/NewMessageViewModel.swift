//
//  NewMessageViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 06/05/2022.
//

import Foundation
import Combine

class NewMesssageViewModel {
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var chatPage: Int = 1

    // MARK: Public Properties
    var usersPublisher: CurrentValueSubject<[UserContact], Never> = .init([])
    var initialUsers: [UserContact] = []
    var cachedFriendCellViewModels: [String: SelectFriendCellViewModel] = [:]
    var individualChatrooms: [ChatroomData] = []

    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    init() {
        self.getUsers()

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

    private func processFriendsData(friends: [UserFriend]) {

        for friend in friends {
            let user = UserContact(id: "\(friend.id)", username: friend.username, phones: [])
            self.usersPublisher.value.append(user)
        }

        self.initialUsers = self.usersPublisher.value

        self.getIndividualChatroomsData()

//        self.isLoadingPublisher.send(false)
//        self.dataNeedsReload.send()
    }

    private func getIndividualChatroomsData() {
        Env.gomaNetworkClient.requestChatrooms(deviceId: Env.deviceId, page: self.chatPage)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("CHATROOMS ERROR: \(error)")
                    self?.isLoadingPublisher.send(false)
                    self?.dataNeedsReload.send()
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

        self.isLoadingPublisher.send(false)
        self.dataNeedsReload.send()
    }

    func getConversationData(userId: String) -> ConversationData {
        var chatroomId = 0
        var chatroomUsername = ""
        var chatroomUsers: [UserFriend] = []

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
}
