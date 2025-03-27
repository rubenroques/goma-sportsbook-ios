//
//  FriendStatusCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 26/04/2022.
//

import Foundation
import Combine

class FriendStatusCellViewModel {
    var friend: UserFriend
    var name: String?
    var id: Int
    var username: String
    var notificationsEnabled: Bool
    var isOnlinePublisher: CurrentValueSubject<Bool, Never> = .init(false)

    private var cancellables = Set<AnyCancellable>()

    init(friend: UserFriend) {
        self.friend = friend

        self.id = friend.id

        self.name = friend.name

        self.username = friend.username

        self.notificationsEnabled = true

        self.setupPublishers()
    }

    private func setupPublishers() {
        if let onlineUsersPublisher = Env.gomaSocialClient.onlineUsersPublisher() {

            onlineUsersPublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] onlineUsersResponse in
                    guard let self = self else {return}

                    let isUserOnline = onlineUsersResponse.values.contains { value -> Bool in

                        if value.users.contains("\(self.id)") {
                            return true
                        }

                        return false
                    }

                    if isUserOnline {

                        self.isOnlinePublisher.send(true)

                    }
                    else {
                        self.isOnlinePublisher.send(false)
                    }

                })
                .store(in: &cancellables)
        }
    }
}
