//
//  ConversationsDetailViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 14/04/2022.
//

import Foundation

class ConversationDetailViewModel: NSObject {

    var messages: [MessageData] = []
    var sectionMessages: [String: [MessageData]] = [:]
    var dateMessages: [DateMessages] = []

    var isChatOnline: Bool = false

    override init() {
        super.init()
        
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
            $0.date < $1.date
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
