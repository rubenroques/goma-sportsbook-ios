//
//  ConversationsDetailViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 14/04/2022.
//

import Foundation
import Combine
import Kingfisher
import OrderedCollections

class ConversationDetailViewModel: NSObject {

    // MARK: Public Properties
    var messages: [MessageData] = []
    var sectionMessages: [String: [MessageData]] = [:]
    var dateMessages: [DateMessages] = []
    var isChatOnlinePublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isChatGroupPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isInitialMessagesLoaded: Bool = false
    var titlePublisher: CurrentValueSubject<String, Never> = .init("")
    var usersPublisher: CurrentValueSubject<String, Never> = .init("")
    var groupInitialsPublisher: CurrentValueSubject<String, Never> = .init("")
    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()
    var shouldScrollToLastMessage: PassthroughSubject<Void, Never> = .init()

    var isLoadingConversationPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isLoadingSharedBetPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var onlineUsersCountPublisher: CurrentValueSubject<Int, Never> = .init(0)
    
    var ticketAddedToBetslipAction: ((Bool) -> Void)?
    
    var conversationId: Int
    var messagesPage: Int = 1
    
    // MARK: Private Properties
    private var chatroomMessagesPublisher: AnyCancellable?
    private var conversationData: ConversationData?
    private var cancellables = Set<AnyCancellable>()

    // MARK: Lifetime and Cycle
    // MARK: Lifetime and Cycle
    init(chatId: Int) {
        self.conversationId = chatId
        
        super.init()

//        self.fetchLocations()
//            .sink { [weak self] locations in
//                Env.gomaSocialClient.storeLocations(locations: locations)
//            }
//            .store(in: &cancellables)

        self.fetchLocations()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("Error getting locations: \(error)")
                case .finished:
                    ()
                }

                self?.isLoadingConversationPublisher.send(false)

            }, receiveValue: { [weak self] locations in
                Env.gomaSocialClient.storeLocations(locations: locations)

                self?.setupPublishers()
            })
            .store(in: &cancellables)

    }
    
    init(conversationData: ConversationData) {
        self.isLoadingConversationPublisher.send(true)
        
        self.conversationData = conversationData
        self.conversationId = conversationData.id
        
        super.init()

        self.fetchLocations()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("Error getting locations: \(error)")
                case .finished:
                    ()
                }

                self?.isLoadingConversationPublisher.send(false)

            }, receiveValue: { [weak self] locations in
                Env.gomaSocialClient.storeLocations(locations: locations)

                self?.setupConversationInfo()
                self?.startSocketListening()

                self?.isLoadingConversationPublisher.send(false)
            })
            .store(in: &cancellables)

    }

    // MARK: Functions
    private func setupPublishers() {

        Publishers.CombineLatest(Env.userSessionStore.hasGomaUserSessionPublisher, Env.gomaSocialClient.socketConnectedPublisher)
            .sink { [weak self] hasGomaUserSession, socketConnected in
                if hasGomaUserSession && socketConnected {

                    if let chatId = self?.conversationId {
                        self?.requestChatroomDetails(withId: String(chatId))
                    }
                }
            }
            .store(in: &cancellables)
    }

    func requestChatroomDetails(withId id: String) {
           
        self.isLoadingConversationPublisher.send(true)
        
        Env.gomaNetworkClient.requestChatrooms(deviceId: Env.deviceId, page: 0)
            .compactMap({ chatrooms in
                return chatrooms.data?
                    .filter({ chatroom in
                        String(chatroom.chatroom.id) == id
                    })
                    .first
            })
            .map({ chatroomData -> ConversationData in
                if chatroomData.chatroom.type == ChatroomType.individual.identifier {
                    return self.createIndividualConversationData(fromChatroomData: chatroomData)
                }
                else {
                    return self.createGroupConversationData(fromChatroomData: chatroomData)
                }
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    Logger.log("SocketSocialDebug: getChatrooms failure \(error)")
                case .finished:
                    Logger.log("SocketSocialDebug: getChatrooms finished")
                }
                self.isLoadingConversationPublisher.send(false)
            }, receiveValue: { [weak self] conversationData in
                self?.conversationData = conversationData
                
                self?.setupConversationInfo()
                self?.startSocketListening()

            })
            .store(in: &cancellables)
        
    }
    
    func startSocketListening() {

        guard let conversationData = self.conversationData else { return }

        Env.gomaSocialClient.emitChatDetailMessages(chatroomId: self.conversationId, page: self.messagesPage)

        Env.gomaSocialClient.hasMessagesFinishedLoading
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] finishedLoading in
                if finishedLoading {
                    self?.setupMessagesPublishers()
                    Env.gomaSocialClient.resetFinishedLoadingPublisher()
                }
            })
            .store(in: &cancellables)

        if let onlineUsersPublisher = Env.gomaSocialClient.onlineUsersPublisher() {

            onlineUsersPublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] onlineUsersResponse in
                    guard let self = self else {return}

                    if let onlineUsersChat = onlineUsersResponse[self.conversationId],
                       let loggedUserId = Env.gomaNetworkClient.getCurrentToken()?.userId {
                        if onlineUsersChat.users.contains("\(loggedUserId)") && onlineUsersChat.users.count > 1 {

                            self.isChatOnlinePublisher.send(true)
                        }
                        else {
                            self.isChatOnlinePublisher.send(false)

                        }

                        if let groupUsers = self.conversationData?.groupUsers {

                            let numberUsers = groupUsers.count
                            let onlineUsers = onlineUsersChat.users.count
                            var userDetailsString = ""

                            let chatGroupDetailString = localized("chat_group_users_details")

                            userDetailsString = chatGroupDetailString.replacingFirstOccurrence(of: "%s", with: "\(onlineUsers)")
                            userDetailsString = userDetailsString.replacingOccurrences(of: "%s", with: "\(numberUsers)")

                            self.usersPublisher.send(userDetailsString)

                        }

                    }

                })
                .store(in: &cancellables)
        }

    }

    func fetchLocations() -> AnyPublisher<[EveryMatrix.Location], Never> {

        let router = TSRouter.getLocations(language: "en", sortByPopularity: false)
        return Env.everyMatrixClient.manager.getModel(router: router, decodingType: EveryMatrixSocketResponse<EveryMatrix.Location>.self)
            .map(\.records)
            .compactMap({$0})
            .replaceError(with: [EveryMatrix.Location]())
            .eraseToAnyPublisher()

    }

    private func setupMessagesPublishers() {

        if let chatroomMessagesPublisher = Env.gomaSocialClient.chatroomMessagesPublisher(forChatroomId: self.conversationId) {

            self.chatroomMessagesPublisher = chatroomMessagesPublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] chatMessages in

                    self?.initialChatMessagesProcessing(chatMessages: Array(chatMessages))
                })
        }

        if let newMessagePublisher = Env.gomaSocialClient.newMessagePublisher(forChatroomId: self.conversationId) {

            newMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] chatMessage in

                if let conversationId = self?.conversationId ,
                   let updatedMessage = chatMessage {
                    guard let self = self else {return}

                    if !self.isNewMessageProcessed(chatMessage: updatedMessage) {
                        self.updateChatMessages(newMessage: updatedMessage)
                        self.shouldScrollToLastMessage.send()
                        Env.gomaSocialClient.clearNewMessage(chatroomId: conversationId)
                    }

                }
            })
            .store(in: &cancellables)
        }
    }

    private func isNewMessageProcessed(chatMessage: ChatMessage?) -> Bool {

        if let chatMessage = chatMessage {
            if self.messages.contains(where: {$0.timestamp == chatMessage.date}) {
                return true
            }

            return false
        }

        return true
    }

    private func setupConversationInfo() {

        guard let conversationData = self.conversationData else { return }
        
        #if DEBUG
        self.titlePublisher.value = "\(conversationData.name)-\(conversationData.id)"
        #else
        self.titlePublisher.value = conversationData.name
        #endif
        
        if conversationData.conversationType == .user {
            self.usersPublisher.value = "\(conversationData.name.lowercased())"
            self.isChatGroupPublisher.send(false)
        }
        else {
            if let groupUsers = conversationData.groupUsers {

                let numberUsers = groupUsers.count
                let onlineUsers = 0
                var userDetailsString = ""

                let chatGroupDetailString = localized("chat_group_users_details")

                userDetailsString = chatGroupDetailString.replacingFirstOccurrence(of: "%s", with: "\(onlineUsers)")
                userDetailsString = userDetailsString.replacingOccurrences(of: "%s", with: "\(numberUsers)")

                self.usersPublisher.value = userDetailsString

                self.groupInitialsPublisher.value = self.getGroupInitials(text: conversationData.name)

                self.isChatGroupPublisher.send(true)
            }

        }
    }

    func getConversationData() -> ConversationData? {
        return self.conversationData
    }

    private func getGroupInitials(text: String) -> String {
        var initials = ""

        for letter in text {
            if letter.isUppercase {
                if initials.count < 2 {
                    initials = "\(initials)\(letter)"
                }
            }
        }

        if initials == "" {
            if let firstChar = text.first {
                initials = "\(firstChar.uppercased())"
            }
        }

        return initials
    }

    func updateConversationInfo(groupInfo: GroupInfo) {

        guard var newConversationData = self.conversationData else { return }
        
        var newConversationGroupUsers: [GomaFriend] = []
        newConversationData.name = groupInfo.name

        for newUser in groupInfo.users {
            if let conversationUsers = newConversationData.groupUsers {

                if let oldUser = conversationUsers.first(where: { "\($0.id)" == newUser.id}) {
                    newConversationGroupUsers.append(oldUser)
                }
                else {
                    if let userId = Int(newUser.id) {
                        let newGomaFriend = GomaFriend(id: userId, name: newUser.username, username: newUser.username, isAdmin: 0)
                        newConversationGroupUsers.append(newGomaFriend)
                    }

                }
            }
        }

        newConversationData.groupUsers = newConversationGroupUsers

        self.conversationData = newConversationData

        self.setupConversationInfo()
    }

    private func initialChatMessagesProcessing(chatMessages: [ChatMessage]) {

        self.messages = self.convertChatMessages(chatMessages: chatMessages)

        if self.messages.count/self.messagesPage == 10 {
            self.messagesPage += 1
            Env.gomaSocialClient.emitChatDetailMessages(chatroomId: self.conversationId, page: self.messagesPage)
        }
        else {
            self.sortAllMessages()

            self.dataNeedsReload.send()
        }

    }
    
    private func convertChatMessages(chatMessages: [ChatMessage]) -> [MessageData] {
        
        // We need to make sure the array is empty, this is used only in the init or
        // in subsequent calls os the publisher
        var messages: [MessageData] = []
        
        guard let loggedUserId = Env.gomaNetworkClient.getCurrentToken()?.userId else { return [] }

        for message in chatMessages {
            let formattedDate = self.getFormattedDate(date: message.date)
            if "\(loggedUserId)" == message.fromUser {
                let messageData = MessageData(type: .sentNotSeen,
                                              text: message.message,
                                              date: formattedDate,
                                              timestamp: message.date,
                                              userId: message.fromUser,
                                              attachment: message.attachment)
                messages.append(messageData)
            }
            else {
                let messageData = MessageData(type: .receivedOnline,
                                              text: message.message,
                                              date: formattedDate,
                                              timestamp: message.date,
                                              userId: message.fromUser,
                                              attachment: message.attachment)
                messages.append(messageData)
            }
        }

        let sortedTimestampMessages = messages.sorted {
            $0.timestamp < $1.timestamp
        }
        
        return sortedTimestampMessages
    }

    private func updateChatMessages(newMessage: ChatMessage?) {

        guard
            let loggedUserId = Env.gomaNetworkClient.getCurrentToken()?.userId,
            let message = newMessage
        else {
            return
        }

        let formattedDate = self.getFormattedDate(date: message.date)

        let messageData = MessageData(type: "\(loggedUserId)" == message.fromUser ? .sentNotSeen: .receivedOnline,
                                      text: message.message,
                                      date: formattedDate,
                                      timestamp: message.date,
                                      userId: message.fromUser,
                                      attachment: message.attachment)
        self.messages.append(messageData)

        let sortedTimestampMessages = self.messages.sorted {
            $0.timestamp < $1.timestamp
        }

        self.messages = sortedTimestampMessages

        self.sortAllMessages()

        self.dataNeedsReload.send()
    }

    private func getFormattedDate(date: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(date))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

    func sortAllMessages() {

        self.sectionMessages = [:]
        self.dateMessages = []

        // Reverse messages array
        self.messages.reverse()

        for message in messages {
            let messageDate = getDateFormatted(dateString: message.date)

            if sectionMessages[messageDate] != nil {
                sectionMessages[messageDate]?.append(message)
            }
            else {
                sectionMessages[messageDate] = [message]
            }
        }

        for (key, messages) in sectionMessages {
            let dateMessage = DateMessages(dateString: key, messages: messages)
            self.dateMessages.append(dateMessage)
        }

        // Sort by date
        self.dateMessages.sort {
            if let firstDate = Self.dayDateFormatter.date(from: $0.dateString),
                let secondDate = Self.dayDateFormatter.date(from: $1.dateString) {
                return firstDate < secondDate
            }
            return false
        }

        // Reverse date messages array
        self.dateMessages.reverse()

        // TESTING SET READ MESSAGE
//        if let lastMessage = self.dateMessages.last?.messages.last,
//           let loggedUserId = Env.gomaNetworkClient.getCurrentToken()?.userId,
//           let lastMessageUserId = lastMessage.userId,
//           lastMessageUserId != "\(loggedUserId)" {
//            print("SET MESSAGE AS READ")
//            Env.gomaSocialClient.setChatroomRead(chatroomId: self.conversationId, messageId: lastMessage.timestamp)
//        }

    }

    func addMessage(message: MessageData) {
        
        guard let conversationData = self.conversationData else { return }
        
        Env.gomaSocialClient.sendMessage(chatroomId: conversationData.id,
                                         message: message.text,
                                         attachment: nil)
        
        self.sortAllMessages()
    }

    func getDateFormatted(dateString: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyyy HH:mm"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd-MM-yyyy"

        let date = dateString

        if let formattedDate = dateFormatterGet.date(from: date) {

            return dateFormatterPrint.string(from: formattedDate)
        }

        return ""
    }

    func getDefaultDateFormatted(date: Date) -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd-MM-yyyy HH:mm"

        return dateFormatterPrint.string(from: date)
    }

    func getDateFromString(dateString: String) -> Date? {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyyy HH:mm"

        if let formattedDate = dateFormatterGet.date(from: dateString) {

            return formattedDate
        }

        return nil
    }

    func getUsername(userId: String) -> String {

        guard let conversationData = self.conversationData else { return "" }

        if let users = conversationData.groupUsers {
            if let user = users.first(where: { "\($0.id)" == userId}) {
                return user.username
            }
        }

        return ""
    }
}

extension ConversationDetailViewModel {
    private static let dayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter
    }()
}

extension ConversationDetailViewModel {

    private func createIndividualConversationData(fromChatroomData chatroomData: ChatroomData) -> ConversationData {
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
                                                timestamp: chatroomData.chatroom.creationTimestamp,
                                                lastMessageUser: loggedUsername,
                                                isLastMessageSeen: false,
                                                groupUsers: chatroomUsers)

        return conversationData
    }

    private func createGroupConversationData(fromChatroomData chatroomData: ChatroomData) -> ConversationData {
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
                                                timestamp: chatroomData.chatroom.creationTimestamp,
                                                lastMessageUser: loggedUsername,
                                                isLastMessageSeen: true,
                                                groupUsers: chatroomUsers)
        return conversationData
    }

}

extension ConversationDetailViewModel {
    func addBetTicketToBetslip(withBetToken betToken: String) {

        self.isLoadingSharedBetPublisher.send(true)

        let betDataRoute = TSRouter.getSharedBetData(betToken: betToken)
        Env.everyMatrixClient.manager.getModel(router: betDataRoute, decodingType: SharedBetDataResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    self?.isLoadingSharedBetPublisher.send(false)
                case .finished:
                    ()
                }
            },
            receiveValue: { [weak self] betDataResponse in
                self?.addBetDataTickets(betData: betDataResponse.sharedBetData)
            })
            .store(in: &cancellables)
    }

    private func addBetDataTickets(betData: SharedBetData) {

        let requests = betData.selections.map(getBetMarketOddsRPC)

        var bettingTickets: [BettingTicket?] = []

        Publishers.MergeMany(requests)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                let validTickets = bettingTickets.compactMap({ $0 })

                for ticket in validTickets {
                    Env.betslipManager.addBettingTicket(ticket)
                }

                self?.ticketAddedToBetslipAction?(validTickets.isNotEmpty)
                self?.isLoadingSharedBetPublisher.send(false)
            } receiveValue: { ticket in
                bettingTickets.append(ticket)
            }
            .store(in: &cancellables)

    }

    private func getBetMarketOddsRPC(betSelection: SharedBet) -> AnyPublisher<BettingTicket?, EveryMatrix.APIError> {

        let endpoint = TSRouter.matchMarketOdds(operatorId: Env.appSession.operatorId,
                                                language: "en",
                                                matchId: "\(betSelection.eventId)",
                                                bettingType: "\(betSelection.bettingTypeId)",
                                                eventPartId: "\(betSelection.bettingTypeEventPartId)")

        return Env.everyMatrixClient.manager
            .registerOnEndpointAsRPC(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .map { [weak self] aggregator in
                return self?.processAggregator(aggregator: aggregator, betSelection: betSelection)
            }
            .eraseToAnyPublisher()

    }

    private func processAggregator(aggregator: EveryMatrix.Aggregator, betSelection: SharedBet) -> BettingTicket? {

        var markets: [EveryMatrix.Market] = []
        var betOutcomes: [EveryMatrix.BetOutcome] = []
        var marketOutcomeRelations: [EveryMatrix.MarketOutcomeRelation] = []
        var bettingOffers: [EveryMatrix.BettingOffer] = []
        var betSelectionBettingOfferId: String?

        for content in aggregator.content ?? [] {
            switch content {
            case .market(let marketContent):
                markets.append(marketContent)
            case .betOutcome(let betOutcomeContent):
                betOutcomes.append(betOutcomeContent)
            case .bettingOffer(let bettingOfferContent):
                bettingOffers.append(bettingOfferContent)
                if bettingOfferContent.outcomeId == betSelection.outcomeId {
                    betSelectionBettingOfferId = bettingOfferContent.id
                }
            case .marketOutcomeRelation(let marketOutcomeRelationContent):
                marketOutcomeRelations.append(marketOutcomeRelationContent)
            default:
                ()
            }
        }

        if let bettingOfferId = betSelectionBettingOfferId {
                let marketDescription = "\(betSelection.marketName), \(betSelection.bettingTypeEventPartName)"
                let bettingTicket = BettingTicket(id: bettingOfferId,
                                                  outcomeId: betSelection.outcomeId,
                                                  marketId: markets.first?.id ?? "1",
                                                  matchId: betSelection.eventId,
                                                  value: 0.0,
                                                  isAvailable: markets.first?.isAvailable ?? true,
                                                  statusId: "1",
                                                  matchDescription: betSelection.eventName,
                                                  marketDescription: marketDescription,
                                                  outcomeDescription: betSelection.betName)
            return bettingTicket
        }

        return nil
    }

}

extension ConversationDetailViewModel {

    func numberOfSections() -> Int {
        if self.dateMessages.isEmpty {
            return 0
        }
        else {
            return self.dateMessages.count
        }
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        if let dateMessages = self.dateMessages[safe: section] {
            return dateMessages.messages.count
        }
        else {
            return 0
        }

    }

    func sectionTitle(forSectionIndex section: Int) -> String {
        if self.dateMessages.isEmpty {
            return ""
        }
        else {
            return self.dateMessages[section].dateString
        }
    }

    func messageData(forIndexPath indexPath: IndexPath) -> MessageData? {
        return self.dateMessages[safe: indexPath.section]?.messages[safe: indexPath.row]
    }
}
