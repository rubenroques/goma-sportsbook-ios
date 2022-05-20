//
//  ConversationsDetailViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 14/04/2022.
//

import Foundation
import Combine

class ConversationDetailViewModel: NSObject {

    // MARK: Private Properties
    private var conversationData: ConversationData
    private var cancellables = Set<AnyCancellable>()
    private var socket = Env.gomaSocialClient.socket

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

    init(conversationData: ConversationData) {
        self.conversationData = conversationData

        super.init()

        self.setupConversationInfo()
        // self.getConversationMessages()

        self.startSocketListening()
    }

    func startSocketListening() {

        let chatroomId = self.conversationData.id

        self.socket?.emit("social.chatrooms.messages", ["id": chatroomId,
                                                       "page": 1])

        self.socket?.on("social.chatrooms.messages") { data, ack in

            Env.gomaSocialClient.getChatMessages(data: data, completion: { [weak self] chatMessages in
                
                if let chatMessages = chatMessages?[safe: 0]?.messages {
                    self?.processChatMessages(chatMessages: chatMessages)
                    self?.shouldScrollToLastMessage.send()
                }
            })
        }

        self.socket?.on("social.chatroom.\(chatroomId)") { data, ack in

            Env.gomaSocialClient.getChatMessages(data: data, completion: { [weak self] chatMessages in

                if let chatMessages = chatMessages?[safe: 0]?.messages {
                    self?.processChatMessages(chatMessages: chatMessages)
                    self?.shouldScrollToLastMessage.send()

                }
            })

        }

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
                let messageData = MessageData(type: .sentNotSeen, text: message.message, date: formattedDate, timestamp: message.date, userId: message.fromUser)
                self.messages.append(messageData)
            }
            else {
                let messageData = MessageData(type: .receivedOnline, text: message.message, date: formattedDate, timestamp: message.date, userId: message.fromUser)
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

    private func getFormattedDate(date: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(date))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

    private func getConversationMessages() {
        // TESTING CHAT MESSAGES
//        let message1 = MessageData(messageType: .receivedOffline, messageText: "Yo, I have a proposal for you! 😎", messageDate: "06/04/2022 15:45")
//        let message2 = MessageData(messageType: .sentSeen, messageText: "Oh what is it? And how are you?", messageDate: "06/04/2022 16:00")
//        let message3 = MessageData(messageType: .receivedOnline, messageText: "All fine here! What about: Lorem ipsum dolor sit amet," +
//                                   "consectetur adipiscing elit. Curabitur porttitor mi eget pharetra eleifend. Nam vel finibus nibh, nec ullamcorper elit.", messageDate: "07/04/2022 01:50")
//        let message4 = MessageData(messageType: .sentSeen, messageText: "I'm up for it! 👀", messageDate: "07/04/2022 02:32")
//        let message5 = MessageData(messageType: .receivedOnline, messageText: "Alright! Then I'll send you the details: " +
//                                   "Curabitur porttitor mi eget pharetra eleifend. Nam vel finibus nibh, nec ullamcorper elit.", messageDate: "07/04/2022 17:35")
//        let message6 = MessageData(messageType: .sentNotSeen, messageText: "This seems like a nice deal. looking forward to it! 🤪", messageDate: "08/04/2022 10:01")
//
//        messages.append(message1)
//        messages.append(message2)
//        messages.append(message3)
//        messages.append(message4)
//        messages.append(message5)
//        messages.append(message6)
//
//        self.sortAllMessages()
//
//        self.isChatOnline = true

        // Get chat messages for chatroom id

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
            
            let dateMessage = DateMessages(date: key, messages: messages)

            self.dateMessages.append(dateMessage)
        }

        // Sort by date
        self.dateMessages.sort {

            if let firstDate = self.getDateFromString(dateString: $0.date), let secondDate = self.getDateFromString(dateString: $1.date) {
                return firstDate < secondDate
            }
            else {
               return $0.date < $1.date
            }

        }

    }

    func addMessage(message: MessageData) {

        self.socket?.emit("social.chatrooms.message", ["id": "\(self.conversationData.id)",
                                                       "message": message.text,
                                                 "repliedMessage": nil,
                                                 "attatchment": nil])

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

    func numberOfSections() -> Int {
        if self.dateMessages.isEmpty {
            return 1
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
            return 1
        }

    }

    func sectionTitle(forSectionIndex section: Int) -> String {
        if self.dateMessages.isEmpty {
            return ""
        }
        else {
            return self.dateMessages[section].date
        }
    }

}

struct MessageData {

    var type: MessageType
    var text: String
    var date: String
    var timestamp: Int
    var userId: String?
}

enum MessageType {
    case receivedOffline
    case receivedOnline
    case sentNotSeen
    case sentSeen
}

struct DateMessages {
    var date: String
    var messages: [MessageData]
}

struct ChatMessagesResponse: Decodable {
    var messages: [ChatMessage]

    enum CodingKeys: String, CodingKey {
        case messages = "messages"
    }
}

struct ChatMessage: Decodable {
    var fromUser: String
    var message: String
    var repliedMessage: String?
    var attachment: String?
    var toChatroom: Int
    var date: Int

    enum CodingKeys: String, CodingKey {
        case fromUser = "fromUser"
        case message = "message"
        case repliedMessage = "repliedMessage"
        case attachment = "attachment"
        case toChatroom = "toChatroom"
        case date = "date"
    }
}
