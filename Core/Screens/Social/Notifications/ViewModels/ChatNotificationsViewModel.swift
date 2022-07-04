//
//  ChatNotificationsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 14/04/2022.
//

import Foundation
import Combine

class ChatNotificationsViewModel {
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var followerViewsPublisher: CurrentValueSubject<[UserActionView], Never> = .init([])
    var sharedTicketViewsPublisher: CurrentValueSubject<[UserActionView], Never> = .init([])
    var chatNotificationViewsPublisher: CurrentValueSubject<[UserActionView], Never> = .init([])
    var chatNotificationsPublisher: CurrentValueSubject<[ChatNotification], Never> = .init([])
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    var shouldRemoveFollowerView: ((UserActionView) -> Void)?
    var shouldRemoveSharedTicketView: ((UserActionView) -> Void)?
    var shouldRemoveChatNotificationView: ((UserActionView) -> Void)?
    var isEmptyStatePublisher: CurrentValueSubject<Bool, Never> = .init(false)

    init() {
        //self.setupFollowerViews()
        //self.setupSharedTicketViews()
        self.getChatNotifications()
    }

    private func getChatNotifications() {
        self.isLoadingPublisher.send(true)

        Env.gomaNetworkClient.requestNotifications(deviceId: Env.deviceId, type: .chat)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("CHAT NOTIFICATIONS ERROR: \(error)")
                case .finished:
                    ()
                }

                self?.isLoadingPublisher.send(false)

            }, receiveValue: { [weak self] response in
                if let chatNotifications = response.data {
                    
                    self?.setupChatNotificationViews(chatNotifications: chatNotifications)
                }
            })
            .store(in: &cancellables)
    }

    private func setupChatNotificationViews(chatNotifications: [ChatNotification]) {

        for (index, chatNotification) in chatNotifications.enumerated() {

            let chatNotificationView = UserActionView()

            chatNotificationView.identifier = chatNotification.id

            if index == chatNotifications.count - 1 {
                chatNotificationView.hasLineSeparator = false
            }

            chatNotificationView.setupViewInfoSimple(title: chatNotification.text, readState: chatNotification.notificationUsers[safe: 0]?.read ?? -1)

            chatNotificationView.tappedCloseButtonAction = { [weak self] in
                if let viewIdentifier = chatNotificationView.identifier {
                    self?.shouldRemoveChatNotificationView?(chatNotificationView)
                    chatNotificationView.removeFromSuperview()

                    if let chatNotificationsView = self?.chatNotificationViewsPublisher.value {
                        for (index, view) in chatNotificationsView.enumerated() {
                            if view.identifier == viewIdentifier {
                                self?.chatNotificationViewsPublisher.value.remove(at: index)
                            }
                        }
                    }
                }
            }

            self.chatNotificationViewsPublisher.value.append(chatNotificationView)
        }

        self.chatNotificationsPublisher.value = chatNotifications
        self.isLoadingPublisher.send(false)

        self.markNotificationsAsRead()
    }

    func markNotificationsAsRead() {
        // TODO: Change endpoint
        for chatNotification in self.chatNotificationsPublisher.value {

            if let notificationRead = chatNotification.notificationUsers[safe: 0]?.read,
               notificationRead == 0 {
                
                Env.gomaNetworkClient.setNotificationRead(deviceId: Env.deviceId, notificationId: "\(chatNotification.id)")
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { [weak self] completion in
                        switch completion {
                        case .failure(let error):
                            print("CHAT NOTIF ERROR: \(error)")
                        case .finished:
                            ()
                        }
                    }, receiveValue: { [weak self] _ in
                        print("CHAT NOTIF READ SUCCESS")
                    })
                    .store(in: &cancellables)
            }
        }

    }

    private func setupFollowerViews() {
        // TESTING
        for i in 1...8 {
            let followerView = UserActionView()

            followerView.identifier = i

            if i % 2 == 0 {
                followerView.isOnline = true
            }

            if i == 8 {
                followerView.hasLineSeparator = false
            }

            followerView.setupViewInfo(title: "@GOMA_User", actionTitle: "FOLLOW")

            followerView.tappedCloseButtonAction = { [weak self] in
                if let viewIdentifier = followerView.identifier {
                    print("REMOVED!")
                    self?.shouldRemoveFollowerView?(followerView)
                    followerView.removeFromSuperview()

                    if let followersViews = self?.followerViewsPublisher.value {
                        for (index, view) in followersViews.enumerated() {
                            if view.identifier == viewIdentifier {
                                self?.followerViewsPublisher.value.remove(at: index)
                            }
                        }
                    }
                }
            }

            followerView.tappedActionButtonAction = {
                print("FOLLOW USER!")
            }
            self.followerViewsPublisher.value.append(followerView)
        }

        self.isEmptyStatePublisher.send(false)
    }

    private func setupSharedTicketViews() {
        // TESTING
        for i in 1...8 {
            let sharedTicketView = UserActionView()

            sharedTicketView.identifier = i

            if i % 2 == 0 {
                sharedTicketView.isOnline = true
            }

            if i == 8 {
                sharedTicketView.hasLineSeparator = false
            }

            sharedTicketView.setupViewInfo(title: "@GOMA_User", actionTitle: "OPEN")

            sharedTicketView.tappedCloseButtonAction = { [weak self] in
                if let viewIdentifier = sharedTicketView.identifier {
                    print("REMOVED!")
                    self?.shouldRemoveSharedTicketView?(sharedTicketView)
                    sharedTicketView.removeFromSuperview()

                    if let sharedTicketViews = self?.sharedTicketViewsPublisher.value {
                        for (index, view) in sharedTicketViews.enumerated() {
                            if view.identifier == viewIdentifier {
                                self?.sharedTicketViewsPublisher.value.remove(at: index)
                            }
                        }
                    }
                }
            }

            sharedTicketView.tappedActionButtonAction = {
                print("SHARE TICKET!")
            }

            self.sharedTicketViewsPublisher.value.append(sharedTicketView)

        }

        self.isEmptyStatePublisher.send(false)

    }
}
