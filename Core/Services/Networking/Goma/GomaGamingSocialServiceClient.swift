//
//  GomaGamingSocialServiceClient.swift
//  Sportsbook
//
//  Created by André Lascas on 29/04/2022.
//

import Foundation
import Combine
import SocketIO

class GomaGamingSocialServiceClient {

    var manager: SocketManager?
    var socket: SocketIOClient?
    var storage: GomaGamingSocialClientStorage?

    let websocketURL = "https://sportsbook-api.gomagaming.com/"
    private let authToken = "9g7rp9760c33c6g1f19mn5ut3asd67"

    private var shouldRestoreConnection = false
    private var isConnected = false
    private var isConnecting = false

    private var cancellables = Set<AnyCancellable>()

    init() {

    }

    func connectSocket() {

        self.socket?.disconnect()
        
        self.storage = nil
        self.socket = nil
        self.manager = nil

        // Start Socket
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
           print("SocketDebug: WebsocketUpgrade \(data)")
        }

        self.socket?.on(clientEvent: .statusChange) {data, _ in
            print("SocketDebug: statusChange \(data)")
        }

        self.socket?.on(clientEvent: .connect) {_, _ in
            print("SocketDebug: Connected")
            print("SocketDebug connected to Goma Social Server!")

            self.isConnected = true
            self.isConnecting = false

            self.setupPostConnection()
        }

        self.socket?.on(clientEvent: .reconnectAttempt) { data, _ in
            print("SocketDebug: reconnectAttempt \(data)")
        }

        self.socket?.on(clientEvent: .disconnect) { _, _ in
            self.isConnected = false
            self.isConnecting = false

            print("SocketDebug: ⚠️ Disconnected ⚠️")

            if self.shouldRestoreConnection {
                self.restoreConnection()
            }
        }

        self.socket?.on(clientEvent: .error) { data, _ in
            self.isConnected = false
            self.isConnecting = false

            print("SocketDebug: error \(data)")
        }

        self.establishConnection()
    }

    func establishConnection() {
        if isConnecting {
            print("SocketDebug: Already connecting")
            return
        }

        if isConnected {
            print("SocketDebug: Already connected")
            return
        }

        self.isConnecting = true

        self.socket?.connect()
    }

    func restoreConnection() {
        print("SocketDebug: restore connection")

        if self.socket?.status == .connected {
            return
        }

        print("SocketDebug: restore connect call")
        self.socket?.connect()
    }

    func closeConnection() {

        print("SocketDebug: close connection")

        self.isConnected = false
        self.isConnecting = false

        self.socket?.disconnect()

        print("SocketDebug: disconnected")
    }

    func forceRefresh() { // New clean connection
        print("SocketDebug: force refresh")

        self.shouldRestoreConnection = false
        self.closeConnection()

        self.restoreConnection()
        self.shouldRestoreConnection = true

        self.storage = GomaGamingSocialClientStorage()

        print("SocketDebug: emit games.all")
    }

    private func setupPostConnection() {

        self.storage = GomaGamingSocialClientStorage()

        self.storage?.chatroomIdsPublisher
            .sink(receiveValue: { [weak self] chatroomIds in
                if chatroomIds.isNotEmpty {
                    self?.startLastMessagesListener(chatroomIds: chatroomIds)
                    self?.startChatMessagesListener(chatroomIds: chatroomIds)
                }
            })
            .store(in: &cancellables)
//
//        self.storage?.chatroomMessageUpdaterPublisher
//            .sink(receiveValue: { [weak self] updatedMessages in
//                let chatroomIds = Array(updatedMessages.keys)
//                self?.startLastMessagesListener(chatroomIds: chatroomIds)
//            })
//            .store(in: &cancellables)
    }

    private func startLastMessagesListener(chatroomIds: [Int]) {

        for chatroomId in chatroomIds {
            self.socket?.emit("social.chatrooms.join", ["id": chatroomId])

            print("SocketDebug: emit social.chatrooms.join id: \(chatroomId)")
        }

        self.socket?.on("social.chatrooms.join") { data, _ in

            print("SocketDebug: on social.chatrooms.join: \( data.json() )")

            self.getChatMessages(data: data, completion: { [weak self] chatMessageResponse in

                if let lastMessageResponse = chatMessageResponse {
                    if lastMessageResponse.isNotEmpty {
                        if let lastMessages = lastMessageResponse[safe: 0]?.messages, lastMessages.isNotEmpty {
                            if let chatroomId = lastMessages[safe: 0]?.toChatroom {
                                self?.storage?.chatroomLastMessagePublisher.value[chatroomId] = lastMessages
                            }
                        }
                    }
                }

            })
        }

    }

    private func startChatMessagesListener(chatroomIds: [Int]) {

        for chatroomId in chatroomIds {

            self.socket?.emit("social.chatrooms.messages", ["id": chatroomId,
                                                            "page": 1])
            
            self.socket?.on("social.chatroom.\(chatroomId)") { data, _ in

                print("SocketDebug: on social.chatroom.\(chatroomId): \( data.json() )")

                self.getChatMessages(data: data, completion: { [weak self] chatMessages in
                    if let chatMessages = chatMessages?[safe: 0]?.messages {
                        for chatMessage in chatMessages {
                            let chatroomId = chatMessage.toChatroom
                            self?.storage?.chatroomMessageUpdaterPublisher.value[chatroomId] = chatMessage
                        }
                    }
                })
            }

        }

        self.socket?.on("social.chatrooms.messages") { data, _ in

            print("SocketDebug: on social.chatrooms.messages: \( data.json() )")

            self.getChatMessages(data: data, completion: { [weak self] chatMessages in

                if let chatMessages = chatMessages?[safe: 0]?.messages {

                    for chatMessage in chatMessages {

                        let chatroomId = chatMessage.toChatroom
                        if let storedMessages = self?.storage?.chatroomMessagesPublisher.value[chatroomId] {
                            self?.storage?.chatroomMessagesPublisher.value[chatroomId]?.append(chatMessage)
                        }
                        else {
                            self?.storage?.chatroomMessagesPublisher.value[chatroomId] = [chatMessage]
                        }

                    }
                }
            })
        }

    }

    func sendMessage(message: MessageData, chatroomId: Int) {

        self.socket?.emit("social.chatrooms.message", ["id": "\(chatroomId)",
                                                       "message": message.text,
                                                 "repliedMessage": nil,
                                                 "attatchment": nil])

    }

    private func updateLastMessagePublisher() {

    }

    func getChatMessages(data: [Any], completion: @escaping ([ChatMessagesResponse]?) -> Void) {
        guard let json = try? JSONSerialization.data(withJSONObject: data, options: []) else { return }
        let decoder = JSONDecoder()
        let messages = try? decoder.decode([ChatMessagesResponse].self, from: json)
        completion(messages)
    }

    func getChatMessagesTest(data: [Any], completion: @escaping ([JSON]?) -> Void) {
        guard let json = try? JSONSerialization.data(withJSONObject: data, options: []) else { return }
        let decoder = JSONDecoder()
        let messages = try? decoder.decode([JSON].self, from: json)
        completion(messages)

    }

}

extension GomaGamingSocialServiceClient {

    enum SocketError: Error {
        case invalidContent
    }

}
