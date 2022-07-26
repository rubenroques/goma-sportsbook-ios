//
//  MessagesViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 26/07/2022.
//

import Foundation
import Combine
import UIKit

class MessagesViewModel {

    // MARK: Public Properties
    var inAppMessagesPublisher: CurrentValueSubject<[InAppMessage], Never> = .init([])
    var cachedInAppMessagesViewModels: [String: InAppMessageCellViewModel] = [:]

    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()
    init() {

        self.getInAppMessages()
    }

    private func getInAppMessages() {

        let message1 = InAppMessage(id: "123",
                                    messageType: .promo,
                                    typeText: "Promo | 15/07/2022",
                                    title: "Bet on multiples and get a €5 freebet",
                                    subtitle: nil,
                                    logo: nil,
                                    backgroundBanner: UIImage(named: "message_banner"),
                                    unreadMessage: true)

        let message2 = InAppMessage(id: "456",
                                    messageType: .bettingNew,
                                    typeText: "Betting news | Today",
                                    title: "Sports betting: portugal fans welcome a new… ",
                                    subtitle: nil,
                                    logo: UIImage(named: "logo_horizontal_center"),
                                    backgroundBanner: nil,
                                    unreadMessage: true)

        let message3 = InAppMessage(id: "789",
                                    messageType: .maintenance,
                                    typeText: "Maintenance | 18/07/2022",
                                    title: "New update for version 2.12 ",
                                    subtitle: "Lorem ipsum dolor sit amet, consectetur…",
                                    logo: nil,
                                    backgroundBanner: nil,
                                    unreadMessage: false)

        self.inAppMessagesPublisher.value.append(message1)
        self.inAppMessagesPublisher.value.append(message2)
        self.inAppMessagesPublisher.value.append(message3)

        self.dataNeedsReload.send()
    }

    func deleteMessage(index: Int) {

        if let inAppMessage = self.inAppMessagesPublisher.value[safe: index] {
            self.cachedInAppMessagesViewModels.removeValue(forKey: inAppMessage.id)
            self.inAppMessagesPublisher.value.remove(at: index)

        }

    }

    func deleteAllMessages() {
        self.inAppMessagesPublisher.send([])
        self.cachedInAppMessagesViewModels = [:]

        self.dataNeedsReload.send()
    }
}
