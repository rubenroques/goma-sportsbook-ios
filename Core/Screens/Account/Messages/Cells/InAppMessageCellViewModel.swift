//
//  InAppMessageCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 26/07/2022.
//

import Foundation
import Combine
import UIKit

class InAppMessageCellViewModel {

    // MARK: Public Properties
    var inAppMessage: InAppMessage
    var unreadMessagePublisher: CurrentValueSubject<Bool, Never> = .init(false)

    // MARK: Lifetime and Cycle
    init(inAppMessage: InAppMessage) {
        self.inAppMessage = inAppMessage

        self.setupUnreadMessage()

    }

    private func setupUnreadMessage() {
        if let loggedUserId = Env.gomaNetworkClient.getCurrentToken()?.userId {

            for notificationUser in inAppMessage.notificationUsers {
                if notificationUser.userId == loggedUserId {

                    if notificationUser.read == 0 {
                        self.unreadMessagePublisher.send(true)
                    }
                    else {
                        self.unreadMessagePublisher.send(false)
                    }

                }
            }
        }
    }

    func changeReadStatus(isRead: Bool) {

        if let loggedUserId = Env.gomaNetworkClient.getCurrentToken()?.userId {

            for (index, notificationUser) in self.inAppMessage.notificationUsers.enumerated() {
                if notificationUser.userId == loggedUserId {

                    var newNotificationUser = notificationUser
                    newNotificationUser.read = 1

                    self.inAppMessage.notificationUsers[index] = newNotificationUser
                }
            }
            self.unreadMessagePublisher.send(!isRead)
        }
    }
}
