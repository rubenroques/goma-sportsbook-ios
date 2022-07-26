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

    // MARK: Lifetime and Cycle
    init(inAppMessage: InAppMessage) {
        self.inAppMessage = inAppMessage
    }
}

struct InAppMessage {
    var id: String
    var messageType: MessageCardType
    var typeText: String
    var title: String
    var subtitle: String?
    var logo: UIImage?
    var backgroundBanner: UIImage?
    var unreadMessage: Bool
}
