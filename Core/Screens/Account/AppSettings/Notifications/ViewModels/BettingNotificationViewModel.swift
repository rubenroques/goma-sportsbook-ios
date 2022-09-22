//
//  BettingNotificationViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 21/02/2022.
//

import Foundation
import Combine

class BettingNotificationViewModel: NSObject {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var notificationsUserSettings: NotificationsUserSettings?

    // MARK: Lifetime and sCycle
    override init() {
        super.init()

        self.getUserSettings()
    }

    // MARK: Setup and functions
    private func getUserSettings() {
        self.notificationsUserSettings = UserDefaults.standard.notificationsUserSettings
    }

    func storeNotificationsUserSettings() {
        if let notificationsUserSettings = self.notificationsUserSettings {
            UserDefaults.standard.notificationsUserSettings = notificationsUserSettings
            self.postSettingsToGoma()
        }
    }

    private func postSettingsToGoma() {
        let notificationsUserSettings = UserDefaults.standard.notificationsUserSettings
        Env.gomaNetworkClient.postNotificationsUserSettings(deviceId: Env.deviceId, notificationsUserSettings: notificationsUserSettings)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    func setBetsSelectedOption(view: SettingsRowView, settingType: UserBettingOption) {
        var switchState = false

        if let notificationsUserSettings = self.notificationsUserSettings {

            switch settingType {
            case .betFinal:
                if notificationsUserSettings.notificationsBets {
                    switchState = true
                }
                else {
                    switchState = false
                }
            case .betSelection:
                if notificationsUserSettings.notificationsBetSelections {
                    switchState = true
                }
                else {
                    switchState = false
                }

            }
        }

        view.isSwitchOn = switchState
    }

    func updateBetsSetting(isSettingEnabled: Bool, settingType: UserBettingOption) {
        
        switch settingType {
        case .betFinal:
            self.notificationsUserSettings?.notificationsBets = isSettingEnabled
        case .betSelection:
            self.notificationsUserSettings?.notificationsBetSelections = isSettingEnabled
        }
        
        self.storeNotificationsUserSettings()
    }
}

// MARK: Helpers

enum UserBettingOption {
    case betFinal
    case betSelection
}
