//
//  MessageDetailViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 29/07/2022.
//

import Foundation
import Combine

class MessageDetailViewModel {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var inAppMessage: InAppMessage
    var messageType: MessageCardType?

    // MARK: Lifetime and Cycle
    init(inAppMessage: InAppMessage) {
        self.inAppMessage = inAppMessage

    }
    
    deinit {
        print("MessageDetailViewModel deinit called")
    }
    
    // MARK: Functions
    func getMessageType() -> MessageCardType {

        let messageTypeString = inAppMessage.subtype

        if messageTypeString == MessageCardType.news.identifier {
            return .news
        }
        else if messageTypeString == MessageCardType.promo.identifier {
            return .promo
        }
        else {
            return .information
        }
    }

    func markReadMessage() {

        Env.gomaNetworkClient.setNotificationRead(deviceId: Env.deviceId, notificationId: "\(self.inAppMessage.id)")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("NEWS SINGLE NOTIF ERROR: \(error)")
                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] _ in
                Env.gomaSocialClient.getInAppMessagesCounter()

            })
            .store(in: &cancellables)
    }

}
