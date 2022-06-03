//
//  ConversationsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 26/04/2022.
//

import Foundation
import Combine
import SocketIO

class ConversationsViewModel {
    
    // MARK: Public Properties
    var conversationsPublisher: CurrentValueSubject<[ConversationData], Never> = .init([])
    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var initialConversations: [ConversationData] = []
    private var conversationListeners: [Int: UUID] = [:]
    private var conversationLastMessageList: [Int: ChatMessage] = [:]

    init() {

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
                    ()
                }

            }, receiveValue: { [weak self] response in
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

        self.setupSocketListeners()

        self.isLoadingPublisher.send(false)
        self.dataNeedsReload.send()
    }

    private func setupSocketListeners() {

        for conversation in self.conversationsPublisher.value {
            let chatroomId = conversation.id

            Env.gomaSocialClient.chatroomLastMessagePublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] lastMessages in

                    if let lastMessageResponse = lastMessages[chatroomId] {
                        if !lastMessageResponse.isEmpty {
                            if let lastMessage = lastMessageResponse[safe: 0] {
                                self?.conversationLastMessageList[lastMessage.toChatroom] = lastMessage
                                self?.updateConversationDetail(chatroomId: lastMessage.toChatroom)
                            }
                        }
                    }
                    
                })
                .store(in: &cancellables)

        }
    }

    private func updateConversationDetail(chatroomId: Int) {

        for (index, conversation) in self.conversationsPublisher.value.enumerated() {
            if conversation.id == chatroomId {
                if let lastMessage = self.conversationLastMessageList[chatroomId] {

                    let newConversationData = ConversationData(id: conversation.id,
                                                               conversationType: conversation.conversationType,
                                                               name: conversation.name,
                                                               lastMessage: lastMessage.message,
                                                               date: self.getFormattedDate(timestamp: lastMessage.date),
                                                               lastMessageUser: lastMessage.fromUser,
                                                               isLastMessageSeen: conversation.isLastMessageSeen, groupUsers: conversation.groupUsers)

                    self.initialConversations[index] = newConversationData

                    self.conversationsPublisher.value[index] = newConversationData

                    self.dataNeedsReload.send()
                }
            }

        }
    }

    private func setupIndividualChatroomData(chatroomData: ChatroomData) {
        var loggedUsername = ""
        var chatroomName = ""
        var chatroomUsers: [GomaFriend] = []

        for user in chatroomData.users {
            chatroomUsers.append(user)
        }

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
                                                lastMessage: "",
                                                date: "",
                                                lastMessageUser: loggedUsername,
                                                isLastMessageSeen: true,
                                                groupUsers: chatroomUsers)

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
                                                lastMessage: "",
                                                date: "",
                                                lastMessageUser: loggedUsername,
                                                isLastMessageSeen: true,
                                                groupUsers: chatroomUsers)
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

    func getFormattedDate(timestamp: Int) -> String {

        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))

        if Calendar.current.isDateInToday(date) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let dateString = dateFormatter.string(from: date)
            return dateString
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: date)
        return dateString

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
