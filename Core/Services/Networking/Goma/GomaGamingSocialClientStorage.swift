//
//  GomaGamingSocialClientStorage.swift
//  Sportsbook
//
//  Created by André Lascas on 24/05/2022.
//

import Foundation
import Combine

class GomaGamingSocialClientStorage {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()
    // MARK: Public Properties
    var chatroomIdsPublisher: CurrentValueSubject<[Int], Never> = .init([])

    var chatroomLastMessagePublisher: CurrentValueSubject<[Int: [ChatMessage]], Never> = .init([:])

    var chatroomMessagesPublisher: CurrentValueSubject<[Int: [ChatMessage]], Never> = .init([:])

    var chatroomMessageUpdaterPublisher: CurrentValueSubject<[Int: ChatMessage?], Never> = .init([:])

    init() {
        self.getChatrooms()
    }

    private func getChatrooms() {
        Env.gomaNetworkClient.requestChatrooms(deviceId: Env.deviceId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("CHATROOMS ERROR: \(error)")
                case .finished:
                    ()
                }

            }, receiveValue: { [weak self] response in
                if let chatrooms = response.data {
                    self?.storeChatrooms(chatroomsData: chatrooms)
                }

            })
            .store(in: &cancellables)
    }

    private func storeChatrooms(chatroomsData: [ChatroomData]) {

        for chatroomData in chatroomsData {
            let chatroomId = chatroomData.chatroom.id

            self.chatroomIdsPublisher.value.append(chatroomId)

            self.chatroomLastMessagePublisher.value[chatroomId] = []

            self.chatroomMessagesPublisher.value[chatroomId] = []

            self.chatroomMessageUpdaterPublisher.value[chatroomId] = nil
        }
    }

}
