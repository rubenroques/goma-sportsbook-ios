//
//  GomaGamingSocialServiceClient.swift
//  Sportsbook
//
//  Created by André Lascas on 29/04/2022.
//

import Foundation
import Combine
import OrderedCollections
import SocketIO

class GomaGamingSocialServiceClient {

    // MARK: Public Properties
    var socketConnectedPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    
    var chatroomIdsPublisher: CurrentValueSubject<[Int], Never> = .init([])
    var chatroomLastMessagePublisher: CurrentValueSubject<[Int: OrderedSet<ChatMessage>], Never> = .init([:])
    var chatroomMessagesPublisher: CurrentValueSubject<[Int: OrderedSet<ChatMessage>], Never> = .init([:])
    var chatroomNewMessagePublisher: CurrentValueSubject<[Int: ChatMessage?], Never> = .init([:])

    // var chatroomMessageUpdaterPublisher: CurrentValueSubject<[Int: ChatMessage?], Never> = .init([:])
    var chatroomReadMessagesPublisher: CurrentValueSubject<[Int: ChatUsersResponse], Never> = .init([:])
    var unreadMessagesCountPublisher: AnyPublisher<Int, Never>{
        return chatroomReadMessagesPublisher
            .map { dictionary in
                return dictionary.values.map({$0.users})
            }
            .map { users -> [Bool] in
                let userId = Env.gomaNetworkClient.getCurrentToken()?.userId ?? -1
                return users
                    .map({$0.contains(String(userId))})
                    .filter({ $0 })
            }
            .map(\.count)
            .eraseToAnyPublisher()
    }
    var chatPage: Int = 1
    
    // MARK: Private Properties
    private var manager: SocketManager?
    private var socket: SocketIOClient?
        
    private let websocketURL = "https://sportsbook-api.gomagaming.com/"
    private let authToken = "9g7rp9760c33c6g1f19mn5ut3asd67"

    private var shouldRestoreConnection = false
    private var isConnected = false {
        didSet {
            self.socketConnectedPublisher.send(isConnected)
        }
    }
    private var isConnecting = false

    private var chatroomOnForegroundId: String?
    
    private var socketCustomHandlers = Set<UUID>()
    private var cancellables = Set<AnyCancellable>()

    init() {
        self.chatroomIdsPublisher
            .filter { $0.isNotEmpty }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] chatroomIds in
                self?.startLastMessagesListener(chatroomIds: chatroomIds)
                self?.startChatMessagesListener(chatroomIds: chatroomIds)
                self?.startChatReadMessagesListener(chatroomIds: chatroomIds)
            })
            .store(in: &cancellables)
    }

    func connectSocket() {

        self.socket?.removeAllHandlers()
        self.socket?.disconnect()
                
        self.isConnected = false
        self.isConnecting = false
        
        self.clearStorage()
        
        self.socket = nil
        self.manager = nil

        // Start the Socket
        guard let jwtToken = Env.gomaNetworkClient.getCurrentToken() else { return }

        let configs = SocketIOClientConfiguration.init(arrayLiteral: .log(false),
                                                       .forceWebsockets(true),
                                                       .forcePolling(false),
                                                       .secure(true),
                                                       .path("/socket/socket.io"),
                                                       .connectParams([ "EIO": "4", "jwt": jwtToken.hash]),
                                                       .extraHeaders(["token": "\(authToken)"]))

        let websocketURL = self.websocketURL
        self.manager = SocketManager(socketURL: URL(string: websocketURL)!, config: configs)
        self.manager?.reconnects = true
        self.manager?.reconnectWait = 10
        self.manager?.reconnectWaitMax = 40

        self.socket = manager?.defaultSocket

        //
        //  CALLBACKS
        //
        self.socket?.on(clientEvent: .websocketUpgrade) {data, _ in
            Logger.log("SocketSocialDebug: WebsocketUpgrade \(data)")
        }

        self.socket?.on(clientEvent: .statusChange) {data, _ in
            Logger.log("SocketSocialDebug: statusChange \(data)")
        }

        self.socket?.on(clientEvent: .connect) {_, _ in
            Logger.log("SocketSocialDebug: Connected")
            Logger.log("SocketSocialDebug connected to Goma Social Server!")

            self.setupPostConnection()
            
            self.isConnected = true
            self.isConnecting = false
        }

        self.socket?.on(clientEvent: .reconnectAttempt) { data, _ in
            Logger.log("SocketSocialDebug: reconnectAttempt \(data)")
        }

        self.socket?.on(clientEvent: .disconnect) { _, _ in
            self.isConnected = false
            self.isConnecting = false

            Logger.log("SocketSocialDebug: ⚠️ Disconnected ⚠️")

            if self.shouldRestoreConnection {
                self.restoreConnection()
            }
        }

        self.socket?.on(clientEvent: .error) { data, _ in
            self.isConnected = false
            self.isConnecting = false

            Logger.log("SocketSocialDebug: error \(data)")
        }
        //
        //
        //

        self.establishConnection()
    }

    func establishConnection() {
        if isConnecting {
            Logger.log("SocketSocialDebug: Already connecting")
            return
        }

        if isConnected {
            Logger.log("SocketSocialDebug: Already connected")
            return
        }

        self.isConnecting = true

        self.socket?.connect()
    }

    func restoreConnection() {
        Logger.log("SocketSocialDebug: restore connection")
        if self.socket?.status == .connected {
            return
        }

        Logger.log("SocketSocialDebug: restore connect call")
        self.socket?.connect()
    }

    func closeConnection() {
        Logger.log("SocketSocialDebug: close connection")

        self.isConnected = false
        self.isConnecting = false

        self.socket?.disconnect()
    }

    func forceRefresh() { // New clean connection
        Logger.log("SocketSocialDebug: force refresh")

        self.shouldRestoreConnection = false
        self.closeConnection()

        self.restoreConnection()
        self.shouldRestoreConnection = true

        self.clearStorage()

        Logger.log("SocketSocialDebug: emit games.all")
    }

    func clearSocketCustomHandlers() {
        self.socketCustomHandlers.forEach { id in
            self.socket?.off(id: id)
        }
    }

    func verifyIfNewChat(chatrooms: [ChatroomData]) {

        for chatroom in chatrooms {
            if !self.chatroomIdsPublisher.value.contains(chatroom.chatroom.id) {
                self.forceRefresh()
            }
        }
    }

    private func clearStorage() {
        self.chatroomIdsPublisher.send([])
        self.chatroomLastMessagePublisher.send([:])
        self.chatroomMessagesPublisher.send([:])
        self.chatroomNewMessagePublisher.send([:])
        self.chatroomReadMessagesPublisher.send([:])
    }
    
    private func setupPostConnection() {
        self.clearStorage()

        self.clearSocketCustomHandlers()

        self.getChatrooms()

//        self.getChatrooms()
//
//        self.chatroomIdsPublisher
//            .sink(receiveValue: { [weak self] chatroomIds in
//                self?.startLastMessagesListener(chatroomIds: chatroomIds)
//                self?.startChatMessagesListener(chatroomIds: chatroomIds)
//                self?.startChatReadMessagesListener(chatroomIds: chatroomIds)
//            })
//            .store(in: &cancellables)
    }

    private func getChatrooms() {
        Env.gomaNetworkClient.requestChatrooms(deviceId: Env.deviceId, page: self.chatPage)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    Logger.log("SocketSocialDebug: getChatrooms failure \(error)")
                case .finished:
                    Logger.log("SocketSocialDebug: getChatrooms finished")
                }
            }, receiveValue: { [weak self] response in
                if let chatrooms = response.data {
                    self?.storeChatrooms(chatroomsData: chatrooms)
                }
            })
            .store(in: &cancellables)
    }
    
    private func storeChatrooms(chatroomsData: [ChatroomData]) {
        let chatroomsIds = chatroomsData.map({ $0.chatroom.id })
        self.chatroomIdsPublisher.send(chatroomsIds)
    }
    
    private func startLastMessagesListener(chatroomIds: [Int]) {

        self.socket?.handlers.forEach({ print($0) })

        let handlerId = self.socket?.on("social.chatrooms.join") { data, _ in
            // Logger.log("SocketSocialDebug: on social.chatrooms.join: \( data.json() )")
            let chatMessageResponse = self.parseChatMessages(data: data)
            if let lastMessageResponse = chatMessageResponse {
                if lastMessageResponse.isNotEmpty {
                    if let lastMessages = lastMessageResponse[safe: 0]?.messages, lastMessages.isNotEmpty {
                        if let chatroomId = lastMessages[safe: 0]?.toChatroom {
                            self.chatroomLastMessagePublisher.value[chatroomId] = OrderedSet(lastMessages)
                        }
                    }
                }
            }
        }

        if let handlerId = handlerId {
            self.socketCustomHandlers.insert(handlerId)
        }

        for chatroomId in chatroomIds {
            self.socket?.emit("social.chatrooms.join", ["id": chatroomId])
            Logger.log("SocketSocialDebug: emit social.chatrooms.join id: \(chatroomId)")
        }
        
    }

//    func startChatDetailMessageListener(chatroomId: Int) {
//        self.socket?.on("social.chatroom.\(chatroomId)") { data, _ in
//            print("SocketDebug: on social.chatroom.\(chatroomId): \( data.json() )")
//            let chatMessages = self.parseChatMessages(data: data)
//            if let chatMessages = chatMessages?[safe: 0]?.messages {
//                for chatMessage in chatMessages {
//                    let chatroomId = chatMessage.toChatroom
//                    self.chatroomNewMessagePublisher.value[chatroomId] = chatMessage
//
//                    // Update last message aswell, since last message socket listener doesn't live updated
//                     self.chatroomLastMessagePublisher.value[chatroomId] = OrderedSet(chatMessages)
//                }
//            }
//        }
//
//        self.socket?.emit("social.chatrooms.messages", ["id": chatroomId, "page": 1])
//
//        self.socket?.on("social.chatrooms.messages") { data, _ in
//            print("SocketDebug: on social.chatrooms.messages: \( data.json() )")
//            let chatMessages = self.parseChatMessages(data: data)
//
//            if let chatMessages = chatMessages?[safe: 0]?.messages {
//                for chatMessage in chatMessages {
//                    let chatroomId = chatMessage.toChatroom
//                    if var storedMessages = self.chatroomMessagesPublisher.value[chatroomId] {
//                        storedMessages.append(chatMessage)
//                        self.chatroomMessagesPublisher.value[chatroomId] = storedMessages
//                    }
//                    else {
//                        self.chatroomMessagesPublisher.value[chatroomId] = [chatMessage]
//                    }
//                }
//            }
//        }
//    }

    private func startChatMessagesListener(chatroomIds: [Int]) {

        for chatroomId in chatroomIds {
            let chatHandlerId = self.socket?.on("social.chatroom.\(chatroomId)") { data, _ in
                Logger.log("SocketSocialDebug: on social.chatroom.\(chatroomId): \( data.json() )")
                let chatMessages = self.parseChatMessages(data: data)
                if let chatMessages = chatMessages?[safe: 0]?.messages {
                    for chatMessage in chatMessages {
                        let chatroomId = chatMessage.toChatroom

                        // Update stored messages aswell
                        if var storedMessages = self.chatroomMessagesPublisher.value[chatroomId] {
                            storedMessages.append(chatMessage)
                            self.chatroomMessagesPublisher.value[chatroomId] = storedMessages
                        }
                        else {
                            self.chatroomMessagesPublisher.value[chatroomId] = [chatMessage]
                        }

                        self.chatroomNewMessagePublisher.value[chatroomId] = chatMessage

                        // Update last message aswell, since last message socket listener doesn't live updated
                         self.chatroomLastMessagePublisher.value[chatroomId] = OrderedSet(chatMessages)
                    }
                }
            }
            if let chatHandlerId = chatHandlerId {
                self.socketCustomHandlers.insert(chatHandlerId)
            }
        }

        let messagesHandlerId = self.socket?.on("social.chatrooms.messages") { data, _ in
            Logger.log("SocketSocialDebug: on social.chatrooms.messages: \(data.json())")
            let chatMessages = self.parseChatMessages(data: data)
            
            if let chatMessages = chatMessages?[safe: 0]?.messages {
                
                var chatroomMessagesDictionary = self.chatroomMessagesPublisher.value
                
                for chatMessage in chatMessages {
                    let chatroomId = chatMessage.toChatroom
                    if var storedMessages = chatroomMessagesDictionary[chatroomId] {
                        storedMessages.append(chatMessage)
                        chatroomMessagesDictionary[chatroomId] = storedMessages
                    }
                    else {
                        chatroomMessagesDictionary[chatroomId] = [chatMessage]
                    }
                }
                
                self.chatroomMessagesPublisher.send(chatroomMessagesDictionary)
            }
        }

        if let messagesHandlerId = messagesHandlerId {
            self.socketCustomHandlers.insert(messagesHandlerId)
        }

        for chatroomId in chatroomIds {
            self.socket?.emit("social.chatrooms.messages", ["id": chatroomId, "page": 1])
        }

    }

    func startChatReadMessagesListener(chatroomIds: [Int]) {
        for chatroomId in chatroomIds {
            let handlerId = self.socket?.on("social.chatroom.\(chatroomId).read") { data, _ in
                print("SocketDebug: on social.chatroom.\(chatroomId).read: \( data.json() )")
                let chatUsers = self.parseChatUsers(data: data)
                print("CHAT USERS: \(chatUsers)")
                self.chatroomReadMessagesPublisher.value[chatroomId] = chatUsers?.first

            }
            if let handlerId = handlerId {
                self.socketCustomHandlers.insert(handlerId)
            }
        }
    }

    func refreshChatroomsList() {
        self.clearSocketCustomHandlers()

        self.getChatrooms()
    }

    func clearNewMessage(chatroomId: Int) {
        self.chatroomNewMessagePublisher.value[chatroomId] = nil
    }

    func setupChatDetailListener(chatroomId: Int) {

        if !self.chatroomIdsPublisher.value.contains(chatroomId) {

            // JOIN
            self.socket?.emit("social.chatrooms.join", ["id": chatroomId])
            Logger.log("SocketSocialDebug: emit social.chatrooms.join id: \(chatroomId)")

            // MESSAGES
            let messagesHandlerId = self.socket?.on("social.chatroom.\(chatroomId)") { data, _ in
                // Logger.log("SocketSocialDebug: on social.chatroom.\(chatroomId): \( data.json() )")
                let chatMessages = self.parseChatMessages(data: data)
                if let chatMessages = chatMessages?[safe: 0]?.messages {
                    for chatMessage in chatMessages {
                        let chatroomId = chatMessage.toChatroom
                        self.chatroomNewMessagePublisher.value[chatroomId] = chatMessage

                        // Update last message aswell, since last message socket listener doesn't live updated
                        self.chatroomLastMessagePublisher.value[chatroomId] = OrderedSet(chatMessages)
                    }
                }
            }
            if let messagesHandlerId = messagesHandlerId {
                self.socketCustomHandlers.insert(messagesHandlerId)
            }

            // READ
            let readHandlerId = self.socket?.on("social.chatroom.\(chatroomId).read") { data, _ in
                print("SocketDebug: on social.chatroom.\(chatroomId).read: \( data.json() )")
                let chatUsers = self.parseChatUsers(data: data)
                print("CHAT USERS: \(chatUsers)")
                self.chatroomReadMessagesPublisher.value[chatroomId] = chatUsers?.first

            }
            if let readHandlerId = readHandlerId {
                self.socketCustomHandlers.insert(readHandlerId)
            }
        }
    }

    func setChatroomRead(chatroomId: Int, messageId: Int) {
        self.socket?.emit("social.chatrooms.messages.read", ["id": chatroomId, "message_id": messageId])
    }

    func sendMessage(chatroomId: Int, message: String, attachment: [String: AnyObject]?) {
         self.socket?.emit("social.chatrooms.message", ["id": "\(chatroomId)", "message": message, "repliedMessage": nil, "attachment": attachment])
    }

    func requestMessagesHistory(forChatroomID chatroomId: Int, forPage page: Int) {
        self.socket?.emit("social.chatrooms.messages", ["id": chatroomId, "page": page])
    }

    func parseChatMessages(data: [Any]) -> [ChatMessagesResponse]? {
        guard
            let json = try? JSONSerialization.data(withJSONObject: data, options: [])
        else {
            return nil
        }
        let decoder = JSONDecoder()
        let messages = try? decoder.decode([ChatMessagesResponse].self, from: json)
        return messages
    }

    func parseChatUsers(data: [Any]) -> [ChatUsersResponse]? {
        guard
            let json = try? JSONSerialization.data(withJSONObject: data, options: [])
        else {
            return nil
        }
        let decoder = JSONDecoder()
        let users = try? decoder.decode([ChatUsersResponse].self, from: json)
        return users
    }

}

extension GomaGamingSocialServiceClient {

    enum SocketError: Error {
        case invalidContent
    }

}

extension GomaGamingSocialServiceClient {
    func chatroomOnForeground() -> String? {
        return self.chatroomOnForegroundId
    }
    
    func showChatroomOnForeground(withId id: String) {
        self.chatroomOnForegroundId = id
    }
    
    func hideChatroomOnForeground() {
        self.chatroomOnForegroundId = nil
    }
}
