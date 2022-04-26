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
            let conversationData = ConversationData(conversationType: .user,
                             name: chatroomData.chatroom.name,
                                                    lastMessage: "I won the bet! Whoo!",
                                                    date: "10:15",
                                                    lastMessageUser: "André",
                                                    isLastMessageSeen: false)
            self.conversations.append(conversationData)
        }

        self.dataNeedsReload.send()
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
