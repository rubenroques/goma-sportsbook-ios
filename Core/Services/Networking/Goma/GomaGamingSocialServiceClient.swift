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
    var chatroomMessageUpdaterPublisher: CurrentValueSubject<[Int: ChatMessage?], Never> = .init([:])

    private var manager: SocketManager?
    private var socket: SocketIOClient?
        
    private let websocketURL = "https://sportsbook-api.gomagaming.com/"
    private let authToken = "9g7rp9760c33c6g1f19mn5ut3asd67"

    private var shouldRestoreConnection = false
    private var isConnected = false
    private var isConnecting = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        
    }

    func connectSocket() {

        self.socket?.disconnect()
        
        self.clearStorage()
        
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

        self.clearStorage()

        print("SocketDebug: emit games.all")
    }

    private func clearStorage() {
        self.chatroomIdsPublisher.send([])
        self.chatroomLastMessagePublisher.send([:])
        self.chatroomMessagesPublisher.send([:])
        self.chatroomMessageUpdaterPublisher.send([:])
    }
    
    private func setupPostConnection() {

        self.clearStorage()
        self.getChatrooms()
        
        self.chatroomIdsPublisher
            .sink(receiveValue: { [weak self] chatroomIds in
                self?.startLastMessagesListener(chatroomIds: chatroomIds)
                self?.startChatMessagesListener(chatroomIds: chatroomIds)
            })
            .store(in: &cancellables)

//        self.storage?.chatroomMessageUpdaterPublisher
//            .sink(receiveValue: { [weak self] updatedMessages in
//                let chatroomIds = Array(updatedMessages.keys)
//                self?.startLastMessagesListener(chatroomIds: chatroomIds)
//            })
//            .store(in: &cancellables)
    }

    private func getChatrooms() {
        Env.gomaNetworkClient.requestChatrooms(deviceId: Env.deviceId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("SocketDebug: getChatrooms failure \(error)")
                case .finished:
                    print("SocketDebug: getChatrooms finished")
                }
            }, receiveValue: { [weak self] response in
                if let chatrooms = response.data {
                    self?.storeChatrooms(chatroomsData: chatrooms)
                }
            })
            .store(in: &cancellables)
    }
    
    private func storeChatrooms(chatroomsData: [ChatroomData]) {
        self.chatroomIdsPublisher.send( chatroomsData.map({ $0.chatroom.id }) )
    }
    
    private func startLastMessagesListener(chatroomIds: [Int]) {
        
        self.socket?.on("social.chatrooms.join") { data, _ in
            print("SocketDebug: on social.chatrooms.join: \( data.json() )")
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
        
        for chatroomId in chatroomIds {
            self.socket?.emit("social.chatrooms.join", ["id": chatroomId])
            print("SocketDebug: emit social.chatrooms.join id: \(chatroomId)")
        }
        
    }

    private func startChatMessagesListener(chatroomIds: [Int]) {

        for chatroomId in chatroomIds {
            self.socket?.on("social.chatroom.\(chatroomId)") { data, _ in
                print("SocketDebug: on social.chatroom.\(chatroomId): \( data.json() )")
                let chatMessages = self.parseChatMessages(data: data)
                if let chatMessages = chatMessages?[safe: 0]?.messages {
                    for chatMessage in chatMessages {
                        let chatroomId = chatMessage.toChatroom
                        self.chatroomMessageUpdaterPublisher.value[chatroomId] = chatMessage

                        // Update last message aswell, since last message socket listener doesn't live update
                        self.chatroomLastMessagePublisher.value[chatroomId] = OrderedSet(chatMessages)
                    }
                }
            }
            self.socket?.emit("social.chatrooms.messages", ["id": chatroomId, "page": 1])
        }

        self.socket?.on("social.chatrooms.messages") { data, _ in
            print("SocketDebug: on social.chatrooms.messages: \( data.json() )")
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

    }

    func sendMessage(chatroomId: Int, message: String, attachment: [String: AnyObject]?) {

        self.socket?.emit("social.chatrooms.message", ["id": "\(chatroomId)",
                                                       "message": message,
                                                 "repliedMessage": nil,
                                                 "attatchment": attachment])

    }

    private func updateLastMessagePublisher() {

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
