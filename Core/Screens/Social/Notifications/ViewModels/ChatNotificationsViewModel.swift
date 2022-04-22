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

    // MARK: Public Properties
    var followerViewsPublisher: CurrentValueSubject<[UserActionView], Never> = .init([])
    var sharedTicketViewsPublisher: CurrentValueSubject<[UserActionView], Never> = .init([])

    var shouldRemoveFollowerView: ((UserActionView) -> Void)?
    var shouldRemoveSharedTicketView: ((UserActionView) -> Void)?

    var isEmptyStatePublisher: CurrentValueSubject<Bool, Never> = .init(false)

    init() {
        self.setupFollowerViews()
        self.setupSharedTicketViews()
    }

    private func setupFollowerViews() {
        // TESTING
        for i in 1...8 {
            let followerView = UserActionView()

            followerView.identifier = i

            if i % 2 == 0 {
                followerView.isOnline = true
            }

            if i == 8 {
                followerView.hasLineSeparator = false
            }

            followerView.setupViewInfo(title: "@GOMA_User", actionTitle: "FOLLOW")

            followerView.tappedCloseButtonAction = { [weak self] in
                if let viewIdentifier = followerView.identifier {
                    print("REMOVED!")
                    self?.shouldRemoveFollowerView?(followerView)
                    followerView.removeFromSuperview()

                    if let followersViews = self?.followerViewsPublisher.value {
                        for (index, view) in followersViews.enumerated() {
                            if view.identifier == viewIdentifier {
                                self?.followerViewsPublisher.value.remove(at: index)
                            }
                        }
                    }
                }
            }

            followerView.tappedActionButtonAction = {
                print("FOLLOW USER!")
            }
            self.followerViewsPublisher.value.append(followerView)
        }

        self.isEmptyStatePublisher.send(false)
    }

    private func setupSharedTicketViews() {
        // TESTING
        for i in 1...8 {
            let sharedTicketView = UserActionView()

            sharedTicketView.identifier = i

            if i % 2 == 0 {
                sharedTicketView.isOnline = true
            }

            if i == 8 {
                sharedTicketView.hasLineSeparator = false
            }

            sharedTicketView.setupViewInfo(title: "@GOMA_User", actionTitle: "OPEN")

            sharedTicketView.tappedCloseButtonAction = { [weak self] in
                if let viewIdentifier = sharedTicketView.identifier {
                    print("REMOVED!")
                    self?.shouldRemoveSharedTicketView?(sharedTicketView)
                    sharedTicketView.removeFromSuperview()

                    if let sharedTicketViews = self?.sharedTicketViewsPublisher.value {
                        for (index, view) in sharedTicketViews.enumerated() {
                            if view.identifier == viewIdentifier {
                                self?.sharedTicketViewsPublisher.value.remove(at: index)
                            }
                        }
                    }
                }
            }

            sharedTicketView.tappedActionButtonAction = {
                print("SHARE TICKET!")
            }

            self.sharedTicketViewsPublisher.value.append(sharedTicketView)

        }

        self.isEmptyStatePublisher.send(false)

    }
}
