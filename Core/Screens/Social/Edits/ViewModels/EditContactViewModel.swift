//
//  EditContactViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 09/05/2022.
//

import Foundation
import Combine

class EditContactViewModel {

    // MARK: Private Properties
    private var conversationData: ConversationData
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var usernamePublisher: CurrentValueSubject<String, Never> = .init("")
    var shouldCloseChat: CurrentValueSubject<Bool, Never> = .init(false)
    var isOnlinePublisher: CurrentValueSubject<Bool, Never> = .init(false)
    init(conversationData: ConversationData) {
        self.conversationData = conversationData

        self.setupPublishers()
    }

    private func setupPublishers() {

        self.usernamePublisher.value = self.conversationData.name

        if let onlineUsersPublisher = Env.gomaSocialClient.onlineUsersPublisher() {

            onlineUsersPublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] onlineUsersResponse in
                    guard let self = self else {return}

                    let chatroomId = self.conversationData.id

                    if let onlineUsersChat = onlineUsersResponse[chatroomId],
                       let loggedUserId = Env.gomaNetworkClient.getCurrentToken()?.userId {

                        if onlineUsersChat.users.contains("\(loggedUserId)") && onlineUsersChat.users.count > 1 {

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

    func deleteContact() {
        var loggedUserId = 0
        var userId = 0

        if let currentUserId = Env.gomaNetworkClient.getCurrentToken()?.userId {

            loggedUserId = currentUserId

        }

        if let groupUsers = self.conversationData.groupUsers {
            for user in groupUsers {
                if loggedUserId != user.id {
                    userId = user.id
                }
            }
        }

        Env.gomaNetworkClient.deleteFriend(deviceId: Env.deviceId, userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("DELETE FRIEND ERROR: \(error)")
                case .finished:
                    ()
                }

            }, receiveValue: { [weak self] response in
                self?.shouldCloseChat.send(true)
            })
            .store(in: &cancellables)
    }
}
