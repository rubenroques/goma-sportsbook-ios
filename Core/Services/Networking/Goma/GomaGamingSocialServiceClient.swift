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
    var chatroomIdsPublisher: CurrentValueSubject<[Int], Never> = .init([])
    var chatroomLastMessagePublisher: CurrentValueSubject<[Int: OrderedSet<ChatMessage>], Never> = .init([:])
    var chatroomMessagesPublisher: CurrentValueSubject<[Int: OrderedSet<ChatMessage>], Never> = .init([:])
    var chatroomNewMessagePublisher: CurrentValueSubject<[Int: ChatMessage?], Never> = .init([:])

    private var manager: SocketManager?
    private var socket: SocketIOClient?
        
    private let websocketURL = "https://sportsbook-api.gomagaming.com/"
    private let authToken = "9g7rp9760c33c6g1f19mn5ut3asd67"

    private var shouldRestoreConnection = false
    private var isConnected = false
    private var isConnecting = false

    private var socketCustomHandlers = Set<UUID>()
    private var cancellables = Set<AnyCancellable>()

    init() {
        self.chatroomIdsPublisher
            .filter { $0.isNotEmpty }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] chatroomIds in
                self?.startLastMessagesListener(chatroomIds: chatroomIds)
                self?.startChatMessagesListener(chatroomIds: chatroomIds)
            })
            .store(in: &cancellables)
    }

    func connectSocket() {

        self.socket?.removeAllHandlers()
        self.socket?.disconnect()
        
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

            self.isConnected = true
            self.isConnecting = false

            self.setupPostConnection()
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

    private func clearStorage() {
        self.chatroomIdsPublisher.send([])
        self.chatroomLastMessagePublisher.send([:])
        self.chatroomMessagesPublisher.send([:])
        self.chatroomNewMessagePublisher.send([:])
    }
    
    private func setupPostConnection() {
        self.clearStorage()
        self.clearSocketCustomHandlers()

        self.getChatrooms()
    }

    private func getChatrooms() {
        Env.gomaNetworkClient.requestChatrooms(deviceId: Env.deviceId)
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

    private func startChatMessagesListener(chatroomIds: [Int]) {

        for chatroomId in chatroomIds {
            let handlerId = self.socket?.on("social.chatroom.\(chatroomId)") { data, _ in
                // Logger.log("SocketSocialDebug: on social.chatroom.\(chatroomId): \( data.json() )")
                let chatMessages = self.parseChatMessages(data: data)
                if let chatMessages = chatMessages?[safe: 0]?.messages {
                    for chatMessage in chatMessages {
                        let chatroomId = chatMessage.toChatroom
                        self.chatroomNewMessagePublisher.value[chatroomId] = chatMessage
                    }
                }
            }
            if let handlerId = handlerId {
                self.socketCustomHandlers.insert(handlerId)
            }
        }

        let handlerId = self.socket?.on("social.chatrooms.messages") { data, _ in
            // Logger.log("SocketSocialDebug: on social.chatrooms.messages: \(data.json())")
            let chatMessages = self.parseChatMessages(data: data)
            
            if let chatMessages = chatMessages?[safe: 0]?.messages {
                for chatMessage in chatMessages {
                    let chatroomId = chatMessage.toChatroom

                    if var storedMessages = self.chatroomMessagesPublisher.value[chatroomId] {
                        storedMessages.append(chatMessage)
                        self.chatroomMessagesPublisher.value[chatroomId] = storedMessages
                    }
                    else {
                        self.chatroomMessagesPublisher.value[chatroomId] = [chatMessage]
                    }
                }
            }
        }

        if let handlerId = handlerId {
            self.socketCustomHandlers.insert(handlerId)
        }

        for chatroomId in chatroomIds {
            self.socket?.emit("social.chatrooms.messages", ["id": chatroomId, "page": 1])
        }

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

}

extension GomaGamingSocialServiceClient {

    enum SocketError: Error {
        case invalidContent
    }

}
