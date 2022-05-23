//
//  ConversationBetSelectionViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 23/05/2022.
//

import Foundation
import Combine

class ConversationBetSelectionViewModel {

    // MARK: Private Properties
    private var conversationData: ConversationData
    private var cancellables = Set<AnyCancellable>()
    private var socket = Env.gomaSocialClient.socket

    // MARK: Public Properties
    var tickets: [BettingTicket] = []
    var cachedCellViewModels: [String: BetSelectionCellViewModel] = [:]
    var isChatOnline: Bool = false
    var isChatGroup: Bool = false

    var titlePublisher: CurrentValueSubject<String, Never> = .init("")
    var usersPublisher: CurrentValueSubject<String, Never> = .init("")
    var groupInitialsPublisher: CurrentValueSubject<String, Never> = .init("")
    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()

    // MARK: Lifetime and Cycle
    init(conversationData: ConversationData) {
        self.conversationData = conversationData

        self.setupConversationInfo()

    }

    // MARK: Functions
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

    func addMessage(message: MessageData) {

        self.socket?.emit("social.chatrooms.message", ["id": "\(self.conversationData.id)",
                                                       "message": message.text,
                                                 "repliedMessage": nil,
                                                 "attatchment": nil])

        // self.sortAllMessages()
    }

    func getDefaultDateFormatted(date: Date) -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd-MM-yyyy HH:mm"

        return dateFormatterPrint.string(from: date)
    }
}

extension ConversationBetSelectionViewModel {

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        return 20
    }

    func sectionTitle(forSectionIndex section: Int) -> String {
        return "Share my tickets"
    }

}
