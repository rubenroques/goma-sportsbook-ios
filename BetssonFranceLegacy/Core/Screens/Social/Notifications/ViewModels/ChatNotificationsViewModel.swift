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
    var shouldReloadData: (() -> Void)?

    var friendRequestCacheCellViewModel: [Int: UserNotificationInviteCellViewModel] = [:]
    var notificationsCacheCellViewModel: [Int: UserNotificationCellViewModel] = [:]

    var page: Int = 1
    var notificationsHasNextPage: Bool = false

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

                    if chatNotifications.count < 10 {
                        self?.notificationsHasNextPage = false
                    }
                    else {
                        self?.notificationsHasNextPage = true
                    }
                }
            })
            .store(in: &cancellables)
    }

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
                self?.updateChatNotificationsStatus()
            })
            .store(in: &cancellables)

    }

    func approveFriendRequest(friendRequestId: Int) {

        Env.gomaNetworkClient.approveFriendRequest(deviceId: Env.deviceId, userId: "\(friendRequestId)")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("APPROVE FRIEND REQUEST ERROR: \(error)")
                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] response in
                self?.updateFriendRequests(friendRequestId: friendRequestId)
                Env.gomaSocialClient.forceRefresh()

            })
            .store(in: &cancellables)

    }

    func rejectFriendRequest(friendRequestId: Int) {

        Env.gomaNetworkClient.rejectFriendRequest(deviceId: Env.deviceId, userId: "\(friendRequestId)")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("REJECT FRIEND REQUEST ERROR: \(error)")
                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] response in
                self?.updateFriendRequests(friendRequestId: friendRequestId)
            })
            .store(in: &cancellables)

    }

    private func loadNextNotifications() {

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

                    self?.chatNotificationsPublisher.value.append(contentsOf: chatNotifications)

                    if chatNotifications.count < 10 {
                        self?.notificationsHasNextPage = false
                    }
                    else {
                        self?.notificationsHasNextPage = true
                    }
                }
            })
            .store(in: &cancellables)
    }

    func requestNextNotifications() {
        if !self.notificationsHasNextPage {
            return
        }
        self.page += 1
        self.loadNextNotifications()
    }

    func updateChatNotificationsStatus() {

        for notificationCacheCellViewModel in self.notificationsCacheCellViewModel {

            if notificationCacheCellViewModel.value.notification.notificationUsers[safe: 0]?.read == 0 {
                var newNotificationCacheCellViewModel = notificationCacheCellViewModel
                var newNotificationUsers = newNotificationCacheCellViewModel.value.notification.notificationUsers

                if var newNotificationUser = newNotificationUsers[safe: 0] {
                    newNotificationUser.read = 1
                    newNotificationUsers = [newNotificationUser]
                    newNotificationCacheCellViewModel.value.notification.notificationUsers = newNotificationUsers

                    self.notificationsCacheCellViewModel[notificationCacheCellViewModel.value.notification.id] = newNotificationCacheCellViewModel.value
                }
            }
        }

        self.shouldReloadData?()
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
