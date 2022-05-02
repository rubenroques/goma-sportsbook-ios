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

    // MARK: Public Properties
    var messages: [MessageData] = []
    var sectionMessages: [String: [MessageData]] = [:]
    var dateMessages: [DateMessages] = []
    var isChatOnline: Bool = false
    var isChatGroup: Bool = false

    var titlePublisher: CurrentValueSubject<String, Never> = .init("")
    var usersPublisher: CurrentValueSubject<String, Never> = .init("")
    var groupInitialsPublisher: CurrentValueSubject<String, Never> = .init("")

    init(conversationData: ConversationData) {
        self.conversationData = conversationData

        super.init()

        print("CHATROOM ID: \(self.conversationData.id)")

        self.setupConversationInfo()
        self.getConversationMessages()

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

//                for (index, user) in groupUsers.enumerated() {
//                    if user.username != loggedUsername && loggedUsername != "" {
//                        if index == groupUsers.endIndex - 1 {
//                            usersString += "\(user.username)"
//                        }
//                        else {
//                            usersString += "\(user.username), "
//                        }
//                    }
//                }
                let chatGroupDetailString = localized("chat_group_users_details")

                userDetailsString = chatGroupDetailString.replacingFirstOccurrence(of: "%s", with: "\(onlineUsers)")
                userDetailsString = userDetailsString.replacingOccurrences(of: "%s", with: "\(numberUsers)")

                self.usersPublisher.value = userDetailsString

                self.groupInitialsPublisher.value = self.getGroupInitials(text: self.conversationData.name)

                self.isChatGroup = true
            }

        }
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

    private func getConversationMessages() {
        // TESTING CHAT MESSAGES
        let message1 = MessageData(messageType: .receivedOffline, messageText: "Yo, I have a proposal for you! 😎", messageDate: "06/04/2022 15:45")
        let message2 = MessageData(messageType: .sentSeen, messageText: "Oh what is it? And how are you?", messageDate: "06/04/2022 16:00")
        let message3 = MessageData(messageType: .receivedOnline, messageText: "All fine here! What about: Lorem ipsum dolor sit amet," +
                                   "consectetur adipiscing elit. Curabitur porttitor mi eget pharetra eleifend. Nam vel finibus nibh, nec ullamcorper elit.", messageDate: "07/04/2022 01:50")
        let message4 = MessageData(messageType: .sentSeen, messageText: "I'm up for it! 👀", messageDate: "07/04/2022 02:32")
        let message5 = MessageData(messageType: .receivedOnline, messageText: "Alright! Then I'll send you the details: " +
                                   "Curabitur porttitor mi eget pharetra eleifend. Nam vel finibus nibh, nec ullamcorper elit.", messageDate: "07/04/2022 17:35")
        let message6 = MessageData(messageType: .sentNotSeen, messageText: "This seems like a nice deal. looking forward to it! 🤪", messageDate: "08/04/2022 10:01")

        messages.append(message1)
        messages.append(message2)
        messages.append(message3)
        messages.append(message4)
        messages.append(message5)
        messages.append(message6)

        self.sortAllMessages()

        self.isChatOnline = true

        // Get chat messages for chatroom id

    }

    func sortAllMessages() {

        sectionMessages = [:]
        dateMessages = []

        for message in messages {
            let messageDate = getDateFormatted(dateString: message.messageDate)

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
        self.messages.append(message)

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
        dateFormatterGet.dateFormat = "dd-MM-yyyy"

        if let formattedDate = dateFormatterGet.date(from: dateString) {

            return formattedDate
        }

        return nil
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

    var messageType: MessageType
    var messageText: String
    var messageDate: String
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
