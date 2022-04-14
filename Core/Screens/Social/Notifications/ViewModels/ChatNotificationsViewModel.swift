//
//  ChatNotificationsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 14/04/2022.
//

import Foundation

class ChatNotificationsViewModel: NSObject {

    var followerViews: [UserActionView] = []
    var sharedTicketViews: [UserActionView] = []

    var shouldRemoveFollowerView: ((UserActionView) -> Void)?
    var shouldRemoveSharedTicketView: ((UserActionView) -> Void)?

    override init() {
        super.init()

        self.setupFollowerViews()
        self.setupSharedTicketViews()
    }

    private func setupFollowerViews() {
        // TESTING
        for i in 1...8 {
            let followerView = UserActionView()

            if i % 2 == 0 {
                followerView.isOnline = true
            }

            if i == 8 {
                followerView.hasLineSeparator = false
            }

            followerView.setupViewInfo(title: "@GOMA_User", actionTitle: "FOLLOW")

            followerView.tappedCloseButtonAction = {
                print("REMOVED!")
                //self.followersStackView.removeArrangedSubview(followerView)
                self.shouldRemoveFollowerView?(followerView)
                followerView.removeFromSuperview()
            }

            followerView.tappedActionButtonAction = {
                print("FOLLOW USER!")
            }

            self.followerViews.append(followerView)
        }
    }

    private func setupSharedTicketViews() {
        // TESTING
        for i in 1...8 {
            let sharedTicketView = UserActionView()

            if i % 2 == 0 {
                sharedTicketView.isOnline = true
            }

            if i == 8 {
                sharedTicketView.hasLineSeparator = false
            }

            sharedTicketView.setupViewInfo(title: "@GOMA_User", actionTitle: "OPEN")

            sharedTicketView.tappedCloseButtonAction = {
                print("REMOVED!")
                self.shouldRemoveSharedTicketView?(sharedTicketView)
                sharedTicketView.removeFromSuperview()
            }

            sharedTicketView.tappedActionButtonAction = {
                print("SHARE TICKET!")
            }

            self.sharedTicketViews.append(sharedTicketView)

        }
    }
}
