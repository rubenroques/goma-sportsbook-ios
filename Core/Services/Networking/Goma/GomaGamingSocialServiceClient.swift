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

    private var cancellables = Set<AnyCancellable>()

    init() {
        
    }

    func setupGomaSocket() {
        guard let jwtToken = Env.gomaNetworkClient.getCurrentToken() else { return }

        let configs = SocketIOClientConfiguration.init(arrayLiteral: .log(true),
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

        self.socket?.on(clientEvent: .connect) { [weak self] data, ack in
            print("Socket connected to Goma Social Server!")
            self?.setupPublishers()
        }

        self.socket?.on(clientEvent: .error) { data, ack in
            print("Socket error data: \(data)")
            print("Socket error: \(ack.description)")
        }

        self.socket?.on(clientEvent: .disconnect) { data, ack  in
            print("Socket disconnect data: \(data)")
            print("Socket disconnect error: \(ack.description)")
        }

        self.socket?.on(clientEvent: .websocketUpgrade) { data, _ in
            print("Socket: WebsocketUpgrade \(data)")
        }

        self.socket?.on(clientEvent: .statusChange) { data, _ in
            print("Socket: statusChange \(data)")
        }

        self.connectSocket()
    }

    func connectSocket() {
        self.socket?.connect()
        self.storage = GomaGamingSocialClientStorage()
    }

    func disconnectSocket() {
        self.socket?.disconnect()
    }

    private func setupPublishers() {

        self.storage?.chatroomIdsPublisher
            .sink(receiveValue: { [weak self] chatroomIds in
                if chatroomIds.isNotEmpty {
                    self?.startLastMessagesListener(chatroomIds: chatroomIds)
                    self?.startChatMessagesListener(chatroomIds: chatroomIds)
                }
            })
            .store(in: &cancellables)

        self.storage?.chatroomMessageUpdaterPublisher
            .sink(receiveValue: { [weak self] updatedMessages in
                let chatroomIds = Array(updatedMessages.keys)
                self?.startLastMessagesListener(chatroomIds: chatroomIds)
            })
            .store(in: &cancellables)
    }

    private func startLastMessagesListener(chatroomIds: [Int]) {

        for chatroomId in chatroomIds {
            self.socket?.emit("social.chatrooms.join", ["id": chatroomId])
        }

        self.socket?.on("social.chatrooms.join") { data, ack in

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
            self.socket?.on("social.chatroom.\(chatroomId)") { data, ack in
                self.getChatMessages(data: data, completion: { [weak self] chatMessages in
                    if let chatMessages = chatMessages?[safe: 0]?.messages {
                        for chatMessage in chatMessages {
                            let chatroomId = chatMessage.toChatroom
//                            if let storedMessages = self?.storage?.chatroomMessagesPublisher.value[chatroomId] {
//                                self?.storage?.chatroomMessagesPublisher.value[chatroomId]?.append(chatMessage)
//                            }
//                            else {
//                                self?.storage?.chatroomMessagesPublisher.value[chatroomId] = [chatMessage]
//                            }
                            self?.storage?.chatroomMessageUpdaterPublisher.value[chatroomId] = chatMessage
                        }
                    }
                })

            }
        }

        self.socket?.on("social.chatrooms.messages") { data, ack in

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

        do {
            let messages = try? decoder.decode([ChatMessagesResponse].self, from: json)
            completion(messages)
        }
        catch {
            print(error.localizedDescription)
            completion(nil)
        }

    }

    func getChatMessagesTest(data: [Any], completion: @escaping ([JSON]?) -> Void) {
        guard let json = try? JSONSerialization.data(withJSONObject: data, options: []) else { return }

        let decoder = JSONDecoder()

        do {
            let messages = try? decoder.decode([JSON].self, from: json)
            completion(messages)
        }
        catch {
            print(error.localizedDescription)
            completion(nil)
        }
    }

}
