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

    // MARK: Public Properties
    var conversations: [ConversationData] = []
    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()

    init() {

//        for i in 1...15 {
//            if i <= 2 {
//                let conversationData = ConversationData(conversationType: .group,
//                                                        name: "GOMA Champs GOMA Champs GOMA Champs",
//                                                        lastMessage: "I won the bet! Whoo!",
//                                                        date: "10:15",
//                                                        lastMessageUser: "André",
//                                                        isLastMessageSeen: false)
//                self.conversations.append(conversationData)
//            }
//            else {
//                let conversationData = ConversationData(conversationType: .user,
//                                                        name: "Lascas",
//                                                        lastMessage: "I won the bet! Whoo!",
//                                                        date: "Today",
//                                                        lastMessageUser: nil,
//                                                        isLastMessageSeen: true)
//                self.conversations.append(conversationData)
//            }
//        }

        self.getConversations()
    }

    private func getConversations() {
        Env.gomaNetworkClient.requestChatrooms(deviceId: Env.deviceId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("CHATROOMS ERROR: \(error)")
                case .finished:
                    print("CHATROOMS FINISHED")
                }

//                self?.isLoadingPublisher.send(false)
//                self?.dataNeedsReload.send()

            }, receiveValue: { [weak self] response in
                print("CHATROOMS GOMA: \(response)")
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
        self.conversations.append(conversationData)
    }

    private func setupGroupChatroomData(chatroomData: ChatroomData) {
        var loggedUsername = ""
        var chatroomName = chatroomData.chatroom.name
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
        self.conversations.append(conversationData)
    }

}

extension ConversationsViewModel {

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        return self.conversations.count
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
