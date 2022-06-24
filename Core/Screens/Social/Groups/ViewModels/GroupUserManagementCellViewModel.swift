//
//  GroupUserManagementCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 22/04/2022.
//

import Foundation
import Combine

class GroupUserManagementCellViewModel {

    private var cancellables = Set<AnyCancellable>()

    var userContact: UserContact
    var username: String
    var phones: [String]
    var isOnlinePublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isAdmin: Bool
    var chatroomId: Int?

    init(userContact: UserContact, chatroomId: Int? = nil) {
        self.userContact = userContact

        self.username = userContact.username

        self.phones = userContact.phones

        self.isAdmin = false

        self.chatroomId = chatroomId

        self.setupPublishers()
    }

    private func setupPublishers() {

        // If not nil, check for specific chatroomId user, else check on all chatroom
        if chatroomId != nil {

            if let onlineUsersPublisher = Env.gomaSocialClient.onlineUsersPublisher() {

                onlineUsersPublisher
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] onlineUsersResponse in
                        guard let self = self else {return}

                        if let chatroomId = self.chatroomId,
                           let onlineUsersChat = onlineUsersResponse[chatroomId] {

                            let userId = self.userContact.id

                            if onlineUsersChat.users.contains(userId) {
                                self.isOnlinePublisher.send(true)

                            }
                            else {
                                self.isOnlinePublisher.send(false)

                            }

                        }

                    })
                    .store(in: &cancellables)
            }
        }
        else {

            if let onlineUsersPublisher = Env.gomaSocialClient.onlineUsersPublisher() {

                onlineUsersPublisher
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] onlineUsersResponse in
                        guard let self = self else {return}

                        let isUserOnline = onlineUsersResponse.values.contains { value -> Bool in

                            if value.users.contains(self.userContact.id) {
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
}
