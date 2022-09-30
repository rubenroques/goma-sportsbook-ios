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
    var friendRequestsPublisher: CurrentValueSubject<[FriendRequest], Never> = .init([])
    var chatNotificationsPublisher: CurrentValueSubject<[ChatNotification], Never> = .init([])

    var chatNotificationsArray: [ChatNotification] = []
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    var shouldRemoveFriendRequestView: ((UserActionView) -> Void)?
    var isEmptyStatePublisher: CurrentValueSubject<Bool, Never> = .init(false)

    var friendRequestCacheCellViewModel: [Int: UserNotificationInviteCellViewModel] = [:]
    var notificationsCacheCellViewModel: [Int: UserNotificationCellViewModel] = [:]

    var page: Int = 1

    init() {
        self.getFriendRequests()
        self.getChatNotifications()
    }

    private func getFriendRequests() {
        self.isLoadingPublisher.send(true)

        Env.gomaNetworkClient.getFriendsRequests(deviceId: Env.deviceId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("FRIEND REQUEST ERROR: \(error)")
                case .finished:
                    ()
                }

                self?.isLoadingPublisher.send(false)

            }, receiveValue: { [weak self] response in
                print("FRIEND REQUEST RESPONSE: \(response)")

                if let friendRequests = response.data {
                    self?.friendRequestsPublisher.value = friendRequests
                }

            })
            .store(in: &cancellables)
    }

    private func getChatNotifications() {
        self.isLoadingPublisher.send(true)

        Env.gomaNetworkClient.requestNotifications(deviceId: Env.deviceId, type: .chat, page: self.page)
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

                    self?.chatNotificationsPublisher.value = chatNotifications
                }
            })
            .store(in: &cancellables)
    }

//    private func setupChatNotificationViews(chatNotifications: [ChatNotification]) {
//
//        for (index, chatNotification) in chatNotifications.enumerated() {
//
//            let chatNotificationView = UserActionView()
//
//            chatNotificationView.identifier = chatNotification.id
//
//            if index == chatNotifications.count - 1 {
//                chatNotificationView.hasLineSeparator = false
//            }
//
//            chatNotificationView.setupViewInfoSimple(title: chatNotification.text, readState: chatNotification.notificationUsers[safe: 0]?.read ?? -1)
//
//            chatNotificationView.tappedCloseButtonAction = { [weak self] in
//                if let viewIdentifier = chatNotificationView.identifier {
//                    self?.shouldRemoveChatNotificationView?(chatNotificationView)
//                    chatNotificationView.removeFromSuperview()
//
//                    if let chatNotificationsView = self?.chatNotificationViewsPublisher.value {
//                        for (index, view) in chatNotificationsView.enumerated() {
//                            if view.identifier == viewIdentifier {
//                                self?.chatNotificationViewsPublisher.value.remove(at: index)
//                            }
//                        }
//                    }
//                }
//            }
//
//            if self.chatNotificationViewsArray.isEmpty {
//                self.chatNotificationViewsArray.append(chatNotificationView)
//            }
//            else {
//                var newChatNotificationViewsArray = self.chatNotificationViewsArray
//                newChatNotificationViewsArray.append(chatNotificationView)
//                self.chatNotificationViewsArray = newChatNotificationViewsArray
//            }
//        }
//
//        if self.chatNotificationsArray.isEmpty {
//            self.chatNotificationsArray = chatNotifications
//        }
//        else {
//            var newChatNotificationArray = self.chatNotificationsArray
//            newChatNotificationArray.append(contentsOf: chatNotifications)
//            self.chatNotificationsArray = newChatNotificationArray
//        }
//
//        if self.chatNotificationsArray.count/self.page == 10 {
//            self.page += 1
//            self.getChatNotifications()
//        }
//        else {
//            self.chatNotificationsPublisher.send(self.chatNotificationsArray)
//            self.chatNotificationViewsPublisher.send(self.chatNotificationViewsArray)
//
//            self.isLoadingPublisher.send(false)
//            self.markNotificationsAsRead()
//        }
//
//    }

    func markNotificationsAsRead() {

        Env.gomaNetworkClient.setAllNotificationRead(deviceId: Env.deviceId, notificationType: .chat)
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

    func updateFriendRequests(friendRequestId: Int) {

        self.friendRequestCacheCellViewModel.removeValue(forKey: friendRequestId)

        let friendRequestsUpdated = self.friendRequestsPublisher.value.filter({
            $0.id != friendRequestId
        })

        self.friendRequestsPublisher.send(friendRequestsUpdated)
    }

    func notificationViewModel(forIndex index: Int) -> UserNotificationCellViewModel? {
        guard
            let notification = self.chatNotificationsPublisher.value[safe: index]
        else {
            return nil
        }

        let notificationId = notification.id

        if let notificationCellViewModel = notificationsCacheCellViewModel[notificationId] {
            return notificationCellViewModel
        }
        else {
            let notificationCellViewModel = UserNotificationCellViewModel(notification: notification)
            self.notificationsCacheCellViewModel[notificationId] = notificationCellViewModel
            return notificationCellViewModel
        }
    }

    func friendRequestViewModel(forIndex index: Int) -> UserNotificationInviteCellViewModel? {
        guard
            let friendRequest = self.friendRequestsPublisher.value[safe: index]
        else {
            return nil
        }

        let friendRequestId = friendRequest.id

        if let friendRequestCellViewModel = friendRequestCacheCellViewModel[friendRequestId] {
            return friendRequestCellViewModel
        }
        else {
            let friendRequestCellViewModel = UserNotificationInviteCellViewModel(friendRequest: friendRequest)
            self.friendRequestCacheCellViewModel[friendRequestId] = friendRequestCellViewModel
            return friendRequestCellViewModel
        }
    }
}
