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

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var inAppMessagesPublisher: CurrentValueSubject<[InAppMessage], Never> = .init([])
    var cachedInAppMessagesViewModels: [Int: InAppMessageCellViewModel] = [:]

    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    init() {

        self.getInAppMessages()
    }

    private func getInAppMessages() {
        self.isLoadingPublisher.send(true)

        Env.gomaNetworkClient.requestNewsNotifications(deviceId: Env.deviceId, page: 1)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("NEWS NOTIFICATIONS ERROR: \(error)")
                case .finished:
                    ()
                }

                self?.isLoadingPublisher.send(false)
                self?.dataNeedsReload.send()

            }, receiveValue: { [weak self] response in
                if let newsNotifications = response.data {
                    if newsNotifications.isNotEmpty {
                        self?.inAppMessagesPublisher.send(newsNotifications)
                    }
                }
            })
            .store(in: &cancellables)
    }

//    private func getTestInAppMessages() {
//
//        let message1 = InAppMessage(id: "123",
//                                    messageType: .promo,
//                                    typeText: "Promo | 15/07/2022",
//                                    title: "Bet on multiples and get a €5 freebet",
//                                    subtitle: nil,
//                                    logo: nil,
//                                    backgroundBanner: UIImage(named: "message_banner"),
//                                    unreadMessage: true)
//
//        let message2 = InAppMessage(id: "456",
//                                    messageType: .bettingNew,
//                                    typeText: "Betting news | Today",
//                                    title: "Sports betting: portugal fans welcome a new… Sports betting: portugal fans welcome a new… ",
//                                    subtitle: nil,
//                                    logo: UIImage(named: "logo_horizontal_center"),
//                                    backgroundBanner: nil,
//                                    unreadMessage: true)
//
//        let message3 = InAppMessage(id: "789",
//                                    messageType: .maintenance,
//                                    typeText: "Maintenance | 18/07/2022",
//                                    title: "New update for version 2.12 ",
//                                    subtitle: "Lorem ipsum dolor sit amet, consectetur…",
//                                    logo: nil,
//                                    backgroundBanner: nil,
//                                    unreadMessage: false)
//
//        self.inAppMessagesPublisher.value.append(message1)
//        self.inAppMessagesPublisher.value.append(message2)
//        self.inAppMessagesPublisher.value.append(message3)
//
//        self.dataNeedsReload.send()
//    }

    func markReadMessage(inAppMessage: InAppMessage) {

           if let cellViewModel = self.cachedInAppMessagesViewModels[inAppMessage.id] {

            Env.gomaNetworkClient.setNotificationRead(deviceId: Env.deviceId, notificationId: "\(inAppMessage.id)")
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        print("NEWS SINGLE NOTIF ERROR: \(error)")
                    case .finished:
                        ()
                    }
                }, receiveValue: { [weak self] _ in
                    print("NEWS SINGLE NOTIF READ SUCCESS")

                    if cellViewModel.unreadMessagePublisher.value == true {
                        cellViewModel.changeReadStatus(isRead: true)
                    }

                    Env.gomaSocialClient.getInAppMessagesCounter()

                })
                .store(in: &cancellables)
        }
    }

    func markAllReadMessages() {

        Env.gomaNetworkClient.setAllNotificationRead(deviceId: Env.deviceId, notificationType: .news)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("NEWS NOTIF ERROR: \(error)")
                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] _ in
                print("NEWS NOTIF READ SUCCESS")

                guard let self = self else {return}

                for inAppMessage in self.inAppMessagesPublisher.value {

                    if let cellViewModel = self.cachedInAppMessagesViewModels[inAppMessage.id] {

                        if cellViewModel.unreadMessagePublisher.value == true {
                            cellViewModel.changeReadStatus(isRead: true)
                        }
                    }
                }

                Env.gomaSocialClient.getInAppMessagesCounter()

                self.dataNeedsReload.send()
            })
            .store(in: &cancellables)
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
