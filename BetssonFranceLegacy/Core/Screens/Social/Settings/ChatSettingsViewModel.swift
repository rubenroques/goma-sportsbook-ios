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
    private var chatSettings: ChatUserSettings?
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var messagesRadioButtonViews: [SettingsRadioRowView] = []
    var groupsRadioButtonViews: [SettingsRadioRowView] = []

    // MARK: Lifetime and Cycle
    init() {
        self.getChatSettings()
    }

    // MARK: Setup and functions
    private func getChatSettings() {
        // TEST
        let chatSettings = ChatUserSettings(sendMessagesType: .friends, addGroupsType: .everyone)

        self.chatSettings = chatSettings
    }

    func setMessagesSelectedValues() {
        // TEST
        if let messageId = self.chatSettings?.sendMessagesType.identifier {

            for view in self.messagesRadioButtonViews {
                view.didTapView = { _ in
                    self.checkMessagesOptionsSelected(viewTapped: view)
                }

                // Default market selected
                if view.viewId == messageId {
                    view.isChecked = true
                }
            }
        }

    }

    func setGroupsSelectedValues() {
        // TEST
        if let groupId = self.chatSettings?.addGroupsType.identifier {

            for view in self.groupsRadioButtonViews {
                view.didTapView = { _ in
                    self.checkGroupsOptionsSelected(viewTapped: view)
                }

                // Default market selected
                if view.viewId == groupId {
                    view.isChecked = true
                }
            }
        }

    }

    func checkMessagesOptionsSelected(viewTapped: SettingsRadioRowView) {
        for view in self.messagesRadioButtonViews {
            view.isChecked = false
        }

        viewTapped.isChecked = true

    }

    func checkGroupsOptionsSelected(viewTapped: SettingsRadioRowView) {
        for view in self.groupsRadioButtonViews {
            view.isChecked = false
        }

        viewTapped.isChecked = true

    }

}

struct ChatUserSettings {
    var sendMessagesType: SendMessagesType
    var addGroupsType: AddGroupsType
}

enum SendMessagesType {
    case friends
    case everyone

    var identifier: Int {
        switch self {
        case .friends:
            return 1
        case .everyone:
            return 2

        }
    }
}

enum AddGroupsType {
    case followers
    case everyone

    var identifier: Int {
        switch self {
        case .followers:
            return 1
        case .everyone:
            return 2

        }
    }
}
