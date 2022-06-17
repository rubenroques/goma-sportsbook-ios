//
//  File.swift
//  Sportsbook
//
//  Created by André Lascas on 18/04/2022.
//

import Foundation
import Combine

class AddFriendCellViewModel {

    private var cancellables = Set<AnyCancellable>()

    var userContact: UserContact
    var username: String
    var phones: [String]
    var isCheckboxSelected: Bool
    // var isOnline: Bool
    var isOnlinePublisher: CurrentValueSubject<Bool, Never> = .init(false)

    init(userContact: UserContact) {
        self.userContact = userContact
        
        self.username = userContact.username

        self.phones = userContact.phones

        self.isCheckboxSelected = false

        self.setupPublishers()
    }

    private func setupPublishers() {
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
