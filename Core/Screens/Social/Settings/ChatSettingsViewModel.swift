//
//  ChatSettingsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 19/04/2022.
//

import Foundation
import Combine

class ChatSettingsViewModel {
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var messagesRadioButtonViews: [SettingsRadioRowView] = []
    var groupsRadioButtonViews: [SettingsRadioRowView] = []

    // MARK: Lifetime and Cycle
    init() {

    }

    // MARK: Setup and functions
    func setMessagesSelectedValues() {
        // TEST
        let messageId = 1

        for view in self.messagesRadioButtonViews {
            view.didTapView = { _ in
                // Do something
            }

            // Default market selected
            if view.viewId == messageId {
                view.isChecked = true
            }
        }
    }

    func setGroupsSelectedValues() {
        // TEST
        let groupId = 1

        for view in self.groupsRadioButtonViews {
            view.didTapView = { _ in
                // Do something
            }

            // Default market selected
            if view.viewId == groupId {
                view.isChecked = true
            }
        }
    }

}
