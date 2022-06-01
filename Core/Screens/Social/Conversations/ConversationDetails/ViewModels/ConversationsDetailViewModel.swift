//
//  ConversationsDetailViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 14/04/2022.
//

import Foundation
import Combine

class ConversationDetailViewModel: NSObject {

    // MARK: Public Properties
    var messages: [MessageData] = []
    var sectionMessages: [String: [MessageData]] = [:]
    var dateMessages: [DateMessages] = []
    var isChatOnline: Bool = false
    var isChatGroup: Bool = false

    var titlePublisher: CurrentValueSubject<String, Never> = .init("")
    var usersPublisher: CurrentValueSubject<String, Never> = .init("")
    var groupInitialsPublisher: CurrentValueSubject<String, Never> = .init("")
    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()
    var shouldScrollToLastMessage: PassthroughSubject<Void, Never> = .init()

    var isLoadingSharedBetPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    
    var ticketAddedToBetslipAction: ((Bool) -> Void)?

    
    // MARK: Private Properties
    private var conversationData: ConversationData
    private var cancellables = Set<AnyCancellable>()

    
    // MARK: Lifetime and Cycle
    init(conversationData: ConversationData) {
        self.conversationData = conversationData

        super.init()

        self.setupConversationInfo()

        self.startSocketListening()
    }

    // MARK: Functions
    func startSocketListening() {

        let chatroomId = self.conversationData.id

        if let conversationMessages = Env.gomaSocialClient.chatroomMessagesPublisher.value[chatroomId] {
            self.processChatMessages(chatMessages: Array(conversationMessages) )
            self.shouldScrollToLastMessage.send()
        }

        Env.gomaSocialClient.chatroomNewMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] chatMessages in
                if let updatedMessage = chatMessages[chatroomId] {
                    self?.updateChatMessages(newMessage: updatedMessage)
                    self?.shouldScrollToLastMessage.send()
                }
            })
            .store(in: &cancellables)

    }

    private func setupConversationInfo() {

        self.titlePublisher.value = self.conversationData.name

        if self.conversationData.conversationType == .user {
            self.usersPublisher.value = "\(self.conversationData.name.lowercased())"
            self.isChatGroup = false
        }
        else {
            if let groupUsers = self.conversationData.groupUsers {

                let numberUsers = groupUsers.count
                let onlineUsers = 0
                var userDetailsString = ""

                let chatGroupDetailString = localized("chat_group_users_details")

                userDetailsString = chatGroupDetailString.replacingFirstOccurrence(of: "%s", with: "\(onlineUsers)")
                userDetailsString = userDetailsString.replacingOccurrences(of: "%s", with: "\(numberUsers)")

                self.usersPublisher.value = userDetailsString

                self.groupInitialsPublisher.value = self.getGroupInitials(text: self.conversationData.name)

                self.isChatGroup = true
            }

        }
    }

    func getConversationData() -> ConversationData {
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

        var newConversationData = self.conversationData
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

    private func processChatMessages(chatMessages: [ChatMessage]) {
        guard let loggedUserId = Env.gomaNetworkClient.getCurrentToken()?.userId else {return}

        for message in chatMessages {
            let formattedDate = self.getFormattedDate(date: message.date)
            if "\(loggedUserId)" == message.fromUser {
                let messageData = MessageData(type: .sentNotSeen,
                                              text: message.message,
                                              date: formattedDate,
                                              timestamp: message.date,
                                              userId: message.fromUser,
                                              attachment: message.attachment)
                self.messages.append(messageData)
            }
            else {
                let messageData = MessageData(type: .receivedOnline,
                                              text: message.message,
                                              date: formattedDate,
                                              timestamp: message.date,
                                              userId: message.fromUser,
                                              attachment: message.attachment)
                self.messages.append(messageData)
            }
        }

        let sortedTimestampMessages = self.messages.sorted {
            $0.timestamp < $1.timestamp
        }

        self.messages = sortedTimestampMessages

        self.sortAllMessages()

        self.isChatOnline = true

        self.dataNeedsReload.send()
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

        sectionMessages = [:]
        dateMessages = []

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
    }

    func addMessage(message: MessageData) {
        Env.gomaSocialClient.sendMessage(chatroomId: self.conversationData.id, message: message.text, attachment: nil)
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

        if let users = self.conversationData.groupUsers {
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
