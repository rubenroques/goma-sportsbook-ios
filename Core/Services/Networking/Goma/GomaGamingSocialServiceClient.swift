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
    private var chatroomLastMessagePublisher: [Int: CurrentValueSubject<ChatMessage?, Never>] = [:]
    private var chatroomMessagesPublisher: [Int: CurrentValueSubject<OrderedSet<ChatMessage>, Never>] = [:]
    private var chatroomNewMessagePublisher: [Int: CurrentValueSubject<ChatMessage?, Never>] = [:]
    private var chatroomReadMessagesPublisher: CurrentValueSubject<[Int: ChatUsersResponse], Never> = .init([:])
    private var chatroomOnlineUsersPublisher: CurrentValueSubject<[Int: ChatOnlineUsersResponse], Never> = .init([:])
    var individualChatroomsData: CurrentValueSubject<[ChatroomData], Never> = .init([])

    var inAppMessagesCounter: CurrentValueSubject<Int, Never> = .init(0)

    var unreadMessagesCountPublisher: AnyPublisher<Int, Never>{
        return chatroomReadMessagesPublisher
            .map { dictionary in
                return dictionary.values.map({$0.users})
            }
            .map { users -> [Bool] in
                let userId = Env.gomaNetworkClient.getCurrentToken()?.userId ?? -1
                return users
                    .map({!$0.contains(String(userId))})
                    .filter({ $0 })
            }
            .map(\.count)
            .eraseToAnyPublisher()
    }

    var unreadMessagesState: CurrentValueSubject<Bool, Never> = .init(false)
    var hasMessagesFinishedLoading: CurrentValueSubject<Bool, Never> = .init(false)
    var areChatroomsRefreshed: CurrentValueSubject<Bool, Never> = .init(false)
    var reloadChatroomsList: PassthroughSubject<Void, Never> = .init()
    var allChatroomIdsLastMessageSubscribed: CurrentValueSubject<[Int], Never> = .init([])
    var allDataSubscribed: PassthroughSubject<Void, Never> = .init()
    var chatPage: Int = 1

    var locations: OrderedDictionary<String, EveryMatrix.Location> = [:]
    
    var socialAppsInfo: [SocialAppInfo] = []

    // Followers
    var followingUsersPublisher: CurrentValueSubject<[Follower], Never> = .init([])
    var refetchFollowingUsersPublisher: PassthroughSubject<Void, Never> = .init()
    
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
                self?.startOnlineUsersListener(chatroomIds: chatroomIds)
            })
            .store(in: &cancellables)

    }

    func checkAllLastMessagesSubscribed() {

        if self.chatroomLastMessagePublisher.count == self.chatroomIdsPublisher.value.count && self.chatroomLastMessagePublisher.isNotEmpty {
            self.allDataSubscribed.send()
        }
    }

    func getFollowingUsers() {

        Env.gomaNetworkClient.getFollowingUsers(deviceId: Env.deviceId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("FOLLOWING USERS ERROR: \(error)")
                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] response in
                print("FOLLOWING USERS RESPONSE: \(response)")

                if let followers = response.data {
                    self?.followingUsersPublisher.value = followers
                }

            })
            .store(in: &cancellables)
    }

    func storeSocialAppsInfo() {

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
        
        self.socket?.onAny({ data in
            // Logger.log("SocketSocialDebug: Any - \(data)")
        })
        
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
        self.chatroomLastMessagePublisher = [:]
        self.chatroomMessagesPublisher = [:]
        self.chatroomNewMessagePublisher = [:]
        self.chatroomReadMessagesPublisher.send([:])
        self.chatroomOnlineUsersPublisher.send([:])

        self.allChatroomIdsLastMessageSubscribed.send([])

        self.individualChatroomsData.send([])
    }
    
    private func setupPostConnection() {
        self.clearStorage()

        self.clearSocketCustomHandlers()

        self.getChatrooms()

    }

    func clearUserChatroomsData() {
        self.clearSocketCustomHandlers()
        self.clearStorage()
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

        let individualChatrooms = chatroomsData.filter({
            $0.chatroom.type == "individual"
        })

        self.individualChatroomsData.send(individualChatrooms)

        // Store Social Apps Info
        self.socialAppsInfo = []
        self.storeSocialAppsInfo()
    }
    
    private func startLastMessagesListener(chatroomIds: [Int]) {

        self.socket?.handlers.forEach({ print($0) })

        let handlerId = self.socket?.on("social.chatrooms.join") { data, _ in
            Logger.log("LASTM SocketSocialDebug: on social.chatrooms.join: \( data.json() )")
            let chatMessageResponse = self.parseChatMessages(data: data)
            if let lastMessageResponse = chatMessageResponse {
                if lastMessageResponse.isNotEmpty {
                    if let lastMessages = lastMessageResponse[safe: 0]?.messages, lastMessages.isNotEmpty {
                        if let chatroomId = lastMessages[safe: 0]?.toChatroom {

                            if let lastMessage = lastMessages[safe: 0] {

                                if let lastMessageList = self.chatroomLastMessagePublisher[chatroomId] {
                                    lastMessageList.send(lastMessage)
                                }
                                else {
                                    self.chatroomLastMessagePublisher[chatroomId] = .init(lastMessage)

                                    //self.allChatroomIdsLastMessageSubscribed.value.append(chatroomId)

                                    self.checkAllLastMessagesSubscribed()
                                }

                            }
                        }
                    }
                }
            }

        }

        if let handlerId = handlerId {
            self.socketCustomHandlers.insert(handlerId)
        }

        for chatroomId in chatroomIds {
            // JOIN EMIT
            self.socket?.emit("social.chatrooms.join", ["id": chatroomId])
            Logger.log("SocketSocialDebug: emit social.chatrooms.join id: \(chatroomId)")

            // ON LISTENER FOR NEW MESSAGES
            let chatHandlerId = self.socket?.on("social.chatroom.\(chatroomId)") { data, _ in
                Logger.log("SocketSocialDebug: on social.chatroom.\(chatroomId): \( data.json() )")
                let chatMessages = self.parseChatMessages(data: data)
                if let chatMessages = chatMessages?[safe: 0]?.messages {
                    for chatMessage in chatMessages {
                        let chatroomId = chatMessage.toChatroom

                        // Update stored messages aswell
                        if var storedMessages = self.chatroomMessagesPublisher[chatroomId] {
                            storedMessages.value.append(chatMessage)
                            self.chatroomMessagesPublisher[chatroomId] = storedMessages
                        }
                        else {
                            self.chatroomMessagesPublisher[chatroomId] = .init(OrderedSet([chatMessage]))
                        }

                        if let newMessageList = self.chatroomNewMessagePublisher[chatroomId] {
                            newMessageList.send(chatMessage)
                        }
                        else {
                            self.chatroomNewMessagePublisher[chatroomId] = .init(chatMessage)
                        }

                        // Update last message aswell, since last message socket listener doesn't live updated
                         if let lastMessageList = self.chatroomLastMessagePublisher[chatroomId] {
                            lastMessageList.send(chatMessage)
                        }
                        else {
                            self.chatroomLastMessagePublisher[chatroomId] = .init(chatMessage)
                        }
                        
                        if let loggedUserId = Env.gomaNetworkClient.getCurrentToken()?.userId {
                            if chatMessage.fromUser != "\(loggedUserId)" {
                                self.unreadMessagesState.send(true)
                            }
                        }

                        if let chatroomOnForegroundId = self.chatroomOnForegroundId,
                           chatroomOnForegroundId == "\(chatMessage.toChatroom)" {

                            self.newMessageUnreadEmit(chatroomId: chatroomId, messageId: chatMessage.date)

                        }
                    }
                }
            }
            if let chatHandlerId = chatHandlerId {
                self.socketCustomHandlers.insert(chatHandlerId)
            }

            self.chatroomLastMessagePublisher[chatroomId] = .init()
        }

    }

    private func startChatMessagesListener(chatroomIds: [Int]) {

        // ON LISTENER FOR CHATROOM MESSAGES
        let messagesHandlerId = self.socket?.on("social.chatrooms.messages") { data, _ in
            Logger.log("SocketSocialDebug: on social.chatrooms.messages: \(data.json())")
            let chatMessages = self.parseChatMessages(data: data)
            
            if let chatMessages = chatMessages?[safe: 0]?.messages {
                
                var chatroomMessagesDictionary = self.chatroomMessagesPublisher
                
                for chatMessage in chatMessages {
                    let chatroomId = chatMessage.toChatroom
                    if var storedMessages = chatroomMessagesDictionary[chatroomId] {
                        storedMessages.value.append(chatMessage)
                        chatroomMessagesDictionary[chatroomId] = storedMessages
                    }
                    else {
                        chatroomMessagesDictionary[chatroomId] = .init([chatMessage])
                    }
                }
                
                self.chatroomMessagesPublisher = chatroomMessagesDictionary

                self.hasMessagesFinishedLoading.send(true)
            }
        }

        if let messagesHandlerId = messagesHandlerId {
            self.socketCustomHandlers.insert(messagesHandlerId)
        }

        for chatroomId in chatroomIds {
            self.chatroomMessagesPublisher[chatroomId] = .init([])
        }
    }

    private func startChatReadMessagesListener(chatroomIds: [Int]) {
        for chatroomId in chatroomIds {
            let handlerId = self.socket?.on("social.chatroom.\(chatroomId).read") { data, _ in
                print("SocketDebug: on social.chatroom.\(chatroomId).read: \( data.json() )")
                let chatUsers = self.parseChatUsers(data: data)

                if let chatUserResponse = chatUsers?.first {
                    self.chatroomReadMessagesPublisher.value[chatroomId] = chatUserResponse
                }

            }
            if let handlerId = handlerId {
                self.socketCustomHandlers.insert(handlerId)
            }

            self.socket?.emit("social.chatrooms.messages.read", ["id": chatroomId])
        }
    }
    private func newMessageUnreadEmit(chatroomId: Int, messageId: Int) {
        print("NEW MESSAGE TO SET AS READ!")
        self.socket?.emit("social.chatrooms.messages.read", ["id": chatroomId, "message_id": messageId])
    }

    func emitChatDetailMessages(chatroomId: Int, page: Int) {
        self.socket?.emit("social.chatrooms.messages", ["id": chatroomId, "page": page])

    }

    func startOnlineUsersListener(chatroomIds: [Int]) {

        for chatroomId in chatroomIds {

            let onlineUsersHandlerId = self.socket?.on("social.chatroom.\(chatroomId).users.online") { data, _ in
                Logger.log("SocketSocialDebug: on social.chatroom.\(chatroomId).users.online: \( data.json() )")

                let chatOnlineUsers = self.parseChatOnlineUsers(data: data)

                if let chatOnlineUserResponse = chatOnlineUsers?.first {
                    self.chatroomOnlineUsersPublisher.value[chatroomId] = chatOnlineUserResponse
                    print("ONLINE USERS: \(self.chatroomOnlineUsersPublisher.value)")
                }
            }

            if let onlineUsersHandlerId = onlineUsersHandlerId {
                self.socketCustomHandlers.insert(onlineUsersHandlerId)
            }

            self.socket?.emit("social.chatroom.users.online", ["id": chatroomId])
        }
    }

    func setupNewChatroomListeners(chatroomId: Int) {

        // Last Message
        self.socket?.emit("social.chatrooms.join", ["id": chatroomId])

        //All Messages
        self.chatroomMessagesPublisher[chatroomId] = .init([])

        let chatHandlerId = self.socket?.on("social.chatroom.\(chatroomId)") { data, _ in
            Logger.log("SocketSocialDebug: on social.chatroom.\(chatroomId): \( data.json() )")
            let chatMessages = self.parseChatMessages(data: data)
            if let chatMessages = chatMessages?[safe: 0]?.messages {
                for chatMessage in chatMessages {
                    let chatroomId = chatMessage.toChatroom

                    // Update stored messages aswell
                    if var storedMessages = self.chatroomMessagesPublisher[chatroomId] {
                        storedMessages.value.append(chatMessage)
                        self.chatroomMessagesPublisher[chatroomId] = storedMessages
                    }
                    else {
                        self.chatroomMessagesPublisher[chatroomId] = .init(OrderedSet([chatMessage]))
                    }

                    if let newMessageList = self.chatroomNewMessagePublisher[chatroomId] {
                        newMessageList.send(chatMessage)
                    }
                    else {
                        self.chatroomNewMessagePublisher[chatroomId] = .init(chatMessage)
                    }

                    // Update last message aswell, since last message socket listener doesn't live updated
                     if let lastMessageList = self.chatroomLastMessagePublisher[chatroomId] {
                        lastMessageList.send(chatMessage)
                    }
                    else {
                        self.chatroomLastMessagePublisher[chatroomId] = .init(chatMessage)
                    }

                    if let loggedUserId = Env.gomaNetworkClient.getCurrentToken()?.userId {
                        if chatMessage.fromUser != "\(loggedUserId)" {
                            self.unreadMessagesState.send(true)
                        }
                    }

                    if let chatroomOnForegroundId = self.chatroomOnForegroundId,
                       chatroomOnForegroundId == "\(chatMessage.toChatroom)" {

                        self.newMessageUnreadEmit(chatroomId: chatroomId, messageId: chatMessage.date)

                    }
                }
            }
        }
        if let chatHandlerId = chatHandlerId {
            self.socketCustomHandlers.insert(chatHandlerId)
        }

        //Read messages
        let handlerId = self.socket?.on("social.chatroom.\(chatroomId).read") { data, _ in
            print("SocketDebug: on social.chatroom.\(chatroomId).read: \( data.json() )")
            let chatUsers = self.parseChatUsers(data: data)

            if let chatUserResponse = chatUsers?.first {
                self.chatroomReadMessagesPublisher.value[chatroomId] = chatUserResponse
            }

        }
        if let handlerId = handlerId {
            self.socketCustomHandlers.insert(handlerId)
        }

        self.socket?.emit("social.chatrooms.messages.read", ["id": chatroomId])

        // Online Users
        let onlineUsersHandlerId = self.socket?.on("social.chatroom.\(chatroomId).users.online") { data, _ in
            Logger.log("SocketSocialDebug: on social.chatroom.\(chatroomId).users.online: \( data.json() )")

            let chatOnlineUsers = self.parseChatOnlineUsers(data: data)

            if let chatOnlineUserResponse = chatOnlineUsers?.first {
                self.chatroomOnlineUsersPublisher.value[chatroomId] = chatOnlineUserResponse
                print("ONLINE USERS: \(self.chatroomOnlineUsersPublisher.value)")
            }
        }

        if let onlineUsersHandlerId = onlineUsersHandlerId {
            self.socketCustomHandlers.insert(onlineUsersHandlerId)
        }

        self.socket?.emit("social.chatroom.users.online", ["id": chatroomId])

    }

    func resetFinishedLoadingPublisher() {
        self.hasMessagesFinishedLoading.send(false)
    }

    func refreshChatroomsList() {
        self.clearSocketCustomHandlers()

        self.getChatrooms()
    }

    func clearNewMessage(chatroomId: Int) {
        self.chatroomNewMessagePublisher[chatroomId] = nil
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

    func parseChatOnlineUsers(data: [Any]) -> [ChatOnlineUsersResponse]? {
        guard
            let json = try? JSONSerialization.data(withJSONObject: data, options: [])
        else {
            return nil
        }
        let decoder = JSONDecoder()
        let users = try? decoder.decode([ChatOnlineUsersResponse].self, from: json)
        return users
    }

    // Acess to private publishers
    func lastMessagePublisher(forChatroomId id: Int) -> CurrentValueSubject<ChatMessage?, Never>? {

        return self.chatroomLastMessagePublisher[id]
    }

    func chatroomMessagesPublisher(forChatroomId id: Int) -> CurrentValueSubject<OrderedSet<ChatMessage>, Never>? {

        return self.chatroomMessagesPublisher[id]
    }

    func newMessagePublisher(forChatroomId id: Int) -> CurrentValueSubject<ChatMessage?, Never>? {

        return self.chatroomNewMessagePublisher[id]
    }

    func readMessagePublisher() -> CurrentValueSubject<[Int: ChatUsersResponse], Never>? {

        return self.chatroomReadMessagesPublisher
    }

    func onlineUsersPublisher() -> CurrentValueSubject<[Int: ChatOnlineUsersResponse], Never>? {
        return self.chatroomOnlineUsersPublisher
    }

    // Locations
    func storeLocations(locations: [EveryMatrix.Location]) {
        self.locations = [:]
        for location in locations {
            self.locations[location.id] = location
        }
    }

    func location(forId id: String) -> EveryMatrix.Location? {
        return self.locations[id]
    }

    // Notifications
    func getInAppMessagesCounter() {
        Env.gomaNetworkClient.getNotificationCounter(deviceId: Env.deviceId, notificationType: .news)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("NOTIF COUNTER ERROR: \(error)")
                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] response in
                print("NOTIF COUNTER RESPONSE: \(response)")
                if let notifCounter = response.data {
                    self?.inAppMessagesCounter.send(notifCounter)
                }
            })
            .store(in: &cancellables)
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
