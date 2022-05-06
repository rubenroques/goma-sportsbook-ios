//
//  ConversationsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 26/04/2022.
//

import Foundation
import Combine

class ConversationsViewModel {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var initialConversations: [ConversationData] = []
    // MARK: Public Properties
    var conversationsPublisher: CurrentValueSubject<[ConversationData], Never> = .init([])
    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    init() {
        // DUMMY DATA
//        for i in 1...15 {
//            if i <= 2 {
//                let friend1 = GomaFriend(id: 1, name: "User1", username: "@user1")
//                let friend2 = GomaFriend(id: 2, name: "User2", username: "@user2")
//                let conversationData = ConversationData(id: i, conversationType: .group,
//                                                        name: "GOMA Champs",
//                                                        lastMessage: "I won the bet! Whoo!",
//                                                        date: "10:15",
//                                                        lastMessageUser: "André",
//                                                        isLastMessageSeen: false,
//                groupUsers: [friend1, friend2])
//                self.conversationsPublisher.value.append(conversationData)
//            }
//            else {
//                let conversationData = ConversationData(id: i, conversationType: .user,
//                                                        name: "John Doe",
//                                                        lastMessage: "I won the bet! Whoo!",
//                                                        date: "Today",
//                                                        lastMessageUser: nil,
//                                                        isLastMessageSeen: true)
//                self.conversationsPublisher.value.append(conversationData)
//            }
//        }

        self.getConversations()
    }

    private func getConversations() {
        self.isLoadingPublisher.send(true)

        Env.gomaNetworkClient.requestChatrooms(deviceId: Env.deviceId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("CHATROOMS ERROR: \(error)")
                    self?.isLoadingPublisher.send(false)
                    self?.dataNeedsReload.send()

                case .finished:
                    print("CHATROOMS FINISHED")
                }

            }, receiveValue: { [weak self] response in
                // print("CHATROOMS GOMA: \(response)")
                if let chatrooms = response.data {
                    self?.storeChatrooms(chatroomsData: chatrooms)
                }

            })
            .store(in: &cancellables)
    }

    private func storeChatrooms(chatroomsData: [ChatroomData]) {

        for chatroomData in chatroomsData {

            if chatroomData.chatroom.type == ChatroomType.individual.identifier {

                self.setupIndividualChatroomData(chatroomData: chatroomData)

            }
            else {

                self.setupGroupChatroomData(chatroomData: chatroomData)

            }
        }

        self.initialConversations = self.conversationsPublisher.value

        self.isLoadingPublisher.send(false)
        self.dataNeedsReload.send()
    }

    private func setupIndividualChatroomData(chatroomData: ChatroomData) {
        var loggedUsername = ""
        var chatroomName = ""

        for user in chatroomData.users {
            if let loggedUser = UserSessionStore.loggedUserSession() {

                if user.username != loggedUser.username {
                    chatroomName = user.username
                }

                loggedUsername = loggedUser.username

            }
        }

        let conversationData = ConversationData(id: chatroomData.chatroom.id,
                                                conversationType: .user,
                                                name: chatroomName,
                                                lastMessage: "I won the bet! Whoo!",
                                                date: "10:15",
                                                lastMessageUser: loggedUsername,
                                                isLastMessageSeen: false)
        self.conversationsPublisher.value.append(conversationData)
    }

    private func setupGroupChatroomData(chatroomData: ChatroomData) {
        var loggedUsername = ""
        let chatroomName = chatroomData.chatroom.name
        var chatroomUsers: [GomaFriend] = []

        if let loggedUser = UserSessionStore.loggedUserSession() {

            loggedUsername = loggedUser.username

        }

        for user in chatroomData.users {
            chatroomUsers.append(user)
        }

        let conversationData = ConversationData(id: chatroomData.chatroom.id,
                                                conversationType: .group,
                                                name: chatroomName,
                                                lastMessage: "I won the bet! Whoo!",
                                                date: "10:15",
                                                lastMessageUser: loggedUsername,
                                                isLastMessageSeen: true, groupUsers: chatroomUsers)
        self.conversationsPublisher.value.append(conversationData)
    }

    func filterSearch(searchQuery: String) {

        let filteredUsers = self.initialConversations.filter({ $0.name.localizedCaseInsensitiveContains(searchQuery)})

        self.conversationsPublisher.value = filteredUsers

        self.dataNeedsReload.send()

    }

    func resetUsers() {

        self.conversationsPublisher.value = self.initialConversations

        self.dataNeedsReload.send()
    }

    func removeChatroom(chatroomId: Int) {

        Env.gomaNetworkClient.deleteGroup(deviceId: Env.deviceId, chatroomId: chatroomId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("DELETE GROUP ERROR: \(error)")
                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] response in
                print("DELETE GROUP GOMA: \(response)")
                self?.refetchConversations()
            })
            .store(in: &cancellables)
    }

    func refetchConversations() {
        self.initialConversations = []

        self.conversationsPublisher.value = []

        self.getConversations()
    }
}

extension ConversationsViewModel {

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        return self.conversationsPublisher.value.count
    }

}

enum ChatroomType {
    case individual
    case group

    var identifier: String {
        switch self {
        case .individual:
            return "individual"
        case .group:
            return "group"
        }
    }
}
