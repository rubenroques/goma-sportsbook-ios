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
    private var chatPage: Int = 1

    var searchQuery: String = ""
    
    init() {

        self.setupPublishers()

        self.getConversations()

    }

    private func setupPublishers() {
        Env.gomaSocialClient.reloadChatroomsList
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.refetchConversations()
            })
            .store(in: &cancellables)

        Env.gomaSocialClient.allDataSubscribed
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.refetchConversations()
            })
            .store(in: &cancellables)

    }

    private func getConversations() {
        self.isLoadingPublisher.send(true)

        Env.servicesProvider.getChatrooms()
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

            }, receiveValue: { [weak self] chatroomsData in
                
                let mappedChatroomsData = chatroomsData.map({
                    return ServiceProviderModelMapper.chatroomData(fromServiceProviderChatroomData: $0)
                })
                
                self?.checkForNewChatrooms(chatroomsData: mappedChatroomsData)
                // self?.storeChatrooms(chatroomsData: chatrooms)
                
                Env.gomaSocialClient.unreadMessagesState.send(false)
                
                
            })
            .store(in: &cancellables)
        
//        Env.gomaNetworkClient.requestChatrooms(deviceId: Env.deviceId, page: self.chatPage)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure(let error):
//                    print("CHATROOMS ERROR: \(error)")
//                    self?.isLoadingPublisher.send(false)
//                    self?.dataNeedsReload.send()
//                case .finished:
//                    ()
//                }
//
//            }, receiveValue: { [weak self] response in
//                if let chatrooms = response.data {
//
//                    self?.checkForNewChatrooms(chatroomsData: chatrooms)
//                    // self?.storeChatrooms(chatroomsData: chatrooms)
//
//                    Env.gomaSocialClient.unreadMessagesState.send(false)
//                }
//
//            })
//            .store(in: &cancellables)
    }

    private func checkForNewChatrooms(chatroomsData: [ChatroomData]) {
        let storedChatrooms = Env.gomaSocialClient.chatroomIdsPublisher.value

        let missingChatroom = chatroomsData.filter({
            !storedChatrooms.contains($0.chatroom.id)
        })

        // TODO: Enable after socket is setup
//        if missingChatroom.isNotEmpty {
//            Env.gomaSocialClient.forceRefresh()
//        }
//        else {
//            self.storeChatrooms(chatroomsData: chatroomsData)
//        }
        
        if missingChatroom.isNotEmpty {
            Env.gomaSocialClient.refreshChatroomsList()
        }
        
        self.storeChatrooms(chatroomsData: chatroomsData)
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
        
        let sortConversations = self.conversationsPublisher.value.sorted { (conversation1, conversation2) -> Bool in
            if let conversation1 = conversation1.groupUsers, conversation1.contains(where: { $0.id == 1 }) && conversation1.count < 3 {
                return true // Place data1 first if it contains the target user
            } else if let conversation2 = conversation2.groupUsers, conversation2.contains(where: { $0.id == 1 }) && conversation2.count < 3 {
                return false // Place data2 first if it contains the target user
            } else {
                return false // Maintain the original order if neither data1 nor data2 contains the target user
            }
        }

//        self.initialConversations = self.conversationsPublisher.value
        self.initialConversations = sortConversations

        self.setupSocketListeners()

        self.isLoadingPublisher.send(false)
        self.dataNeedsReload.send()
    }

    private func setupSocketListeners() {

        for conversation in self.conversationsPublisher.value {
            let chatroomId = conversation.id

            if let lastMessagePublisher = Env.gomaSocialClient.lastMessagePublisher(forChatroomId: chatroomId) {

                lastMessagePublisher
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] lastMessage in

                        if let chatroomId = lastMessage?.toChatroom {
                            self?.conversationLastMessageList[chatroomId] = lastMessage
                            self?.updateConversationDetail(chatroomId: chatroomId)
                        }

                    })
                    .store(in: &cancellables)
            }

            if let readMessagesPublisher = Env.gomaSocialClient.readMessagePublisher() {

                readMessagesPublisher
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] usersResponse in

                            //self?.updateConversationReadStatus(chatroomId: chatroomId)
                            self?.updateConversationDetail(chatroomId: chatroomId)

                    })
                    .store(in: &cancellables)
            }

        }
    }

    private func updateConversationDetail(chatroomId: Int) {

//        guard let userLoggedId = Env.gomaNetworkClient.getCurrentToken()?.userId else {return}
        guard let userLoggedId = Env.userSessionStore.userProfilePublisher.value?.userIdentifier else {return}

        for (index, conversation) in self.conversationsPublisher.value.enumerated() {
            if conversation.id == chatroomId {
                if let lastMessage = self.conversationLastMessageList[chatroomId] {

                    var isLastMessageRead = false

                    // Check if it was own user
                    if lastMessage.fromUser == "\(userLoggedId)" {
                        isLastMessageRead = true
                    }

                    // Check socket read list
                    if let usersReadPublisher = Env.gomaSocialClient.readMessagePublisher(), let chatUserResponse = usersReadPublisher.value[chatroomId] {
                        for userId in chatUserResponse.users {
                            if userId == "\(userLoggedId)" && chatUserResponse.messageId == lastMessage.date {
                                isLastMessageRead = true
                            }
                        }
                    }

                    let newConversationData = ConversationData(id: conversation.id,
                                                               conversationType: conversation.conversationType,
                                                               name: conversation.name,
                                                               lastMessage: lastMessage.message,
                                                               date: self.getFormattedDate(timestamp: lastMessage.date),
                                                               timestamp: lastMessage.date,
                                                               lastMessageUser: lastMessage.fromUser,
                                                               isLastMessageSeen: isLastMessageRead, groupUsers: conversation.groupUsers,
                                                               avatar: conversation.avatar)

                    self.initialConversations[index] = newConversationData

                    self.conversationsPublisher.value[index] = newConversationData

                    self.dataNeedsReload.send()
                }
            }

        }
        
        if let firstConversation = self.conversationsPublisher.value.first {
            
            var restOfConversations = Array(self.conversationsPublisher.value.dropFirst())
            
            var sortedConversations = self.conversationsPublisher.value.sorted {
                if let firstTimestamp = $0.timestamp, let secondTimestamp = $1.timestamp {
                    return firstTimestamp > secondTimestamp
                }
                else {
                    return $0.timestamp ?? 0 > $1.timestamp ?? 1
                }
                
            }
            // Check if first conversation is GOMA AI Assitant
            if let firstGroupUsers = firstConversation.groupUsers,
               firstGroupUsers.contains(where: {$0.id == 1})  && firstGroupUsers.count < 3 {
                
                let sortedRestOfConversations = restOfConversations.sorted {
                    if let firstTimestamp = $0.timestamp, let secondTimestamp = $1.timestamp {
                        return firstTimestamp > secondTimestamp
                    } else {
                        return $0.timestamp ?? 0 > $1.timestamp ?? 1
                    }
                }
                
                self.conversationsPublisher.value = [firstConversation] + sortedRestOfConversations
                
                self.initialConversations = self.conversationsPublisher.value
            }
            else {
                self.conversationsPublisher.value = sortedConversations
                self.initialConversations = self.conversationsPublisher.value

            }
        }
    }

    private func setupIndividualChatroomData(chatroomData: ChatroomData) {
        var loggedUsername = ""
        var chatroomName = ""
        var chatroomUsers: [UserFriend] = []
        var avatar: String? = nil

        for user in chatroomData.users {
            chatroomUsers.append(user)
        }

        for user in chatroomData.users {
            if let loggedUserIdString = Env.userSessionStore.userProfilePublisher.value?.userIdentifier,
                let loggedUserId = Int(loggedUserIdString) {
                if user.id != loggedUserId {
                    chatroomName = user.username
                    avatar = user.avatar
                }
                else {
                    loggedUsername = user.username
                }
            }
        }
        
        let conversationData = ConversationData(id: chatroomData.chatroom.id,
                                                conversationType: .user,
                                                name: chatroomName,
                                                lastMessage: "",
                                                date: "",
                                                timestamp: chatroomData.chatroom.creationTimestamp,
                                                lastMessageUser: loggedUsername,
                                                isLastMessageSeen: false,
                                                groupUsers: chatroomUsers, avatar: avatar)

        self.conversationsPublisher.value.append(conversationData)
    }

    private func setupGroupChatroomData(chatroomData: ChatroomData) {
        var loggedUsername = ""
        let chatroomName = chatroomData.chatroom.name
        var chatroomUsers: [UserFriend] = []

        if let loggedUser = Env.userSessionStore.loggedUserProfile {
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
                                                timestamp: chatroomData.chatroom.creationTimestamp,
                                                lastMessageUser: loggedUsername,
                                                isLastMessageSeen: true,
                                                groupUsers: chatroomUsers)
        self.conversationsPublisher.value.append(conversationData)
    }

    func filterSearch(searchQuery: String) {

        self.searchQuery = searchQuery
        
        let filteredUsers = self.initialConversations
            .filter { conversation in
                guard let groupUsers = conversation.groupUsers else { return true }
                return !groupUsers.contains { $0.id == 1 }
            }
            .filter({ $0.name.localizedCaseInsensitiveContains(searchQuery)})

        self.conversationsPublisher.value = filteredUsers

        self.dataNeedsReload.send()

    }

    func resetUsers() {

        self.conversationsPublisher.value = self.initialConversations

        self.dataNeedsReload.send()
    }
    
    func resetSearchUsers() {

        self.searchQuery = ""

        self.conversationsPublisher.value = []

        self.dataNeedsReload.send()
    }

    func removeChatroom(chatroomId: Int) {

        Env.servicesProvider.deleteGroup(id: chatroomId)
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
//        Env.gomaNetworkClient.deleteGroup(deviceId: Env.deviceId, chatroomId: chatroomId)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure(let error):
//                    print("DELETE GROUP ERROR: \(error)")
//                case .finished:
//                    ()
//                }
//            }, receiveValue: { [weak self] response in
//                print("DELETE GROUP GOMA: \(response)")
//                self?.refetchConversations()
//            })
//            .store(in: &cancellables)
    }

    func refetchConversations() {
        self.initialConversations = []

        self.conversationsPublisher.value = []

        self.getConversations()
    }

    func getFormattedDate(timestamp: Int) -> String {

        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))

        if Calendar.current.isDateInToday(date) {
            let dateString = Self.hourDateFormatter.string(from: date)
            return dateString
        }

        let dateString = Self.dayDateFormatter.string(from: date)
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

    private static let hourDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()

    private static let dayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter
    }()

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
