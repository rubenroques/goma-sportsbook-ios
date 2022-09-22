//
//  NotificationsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 21/02/2022.
//

import Foundation
import Combine

class NotificationsViewModel: NSObject {

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

    private func storeNotificationsUserSettings(notificationsUserSettings: NotificationsUserSettings) {
        UserDefaults.standard.notificationsUserSettings = notificationsUserSettings
        self.postOddsSettingsToGoma()
    }

    func updateSmsSetting(enabled: Bool) {
        self.notificationsUserSettings?.notificationsSms = enabled
        if let notificationsUserSettings = self.notificationsUserSettings {
            self.storeNotificationsUserSettings(notificationsUserSettings: notificationsUserSettings)
        }
    }

    func updateEmailSetting(enabled: Bool) {
        self.notificationsUserSettings?.notificationsEmail = enabled
        if let notificationsUserSettings = self.notificationsUserSettings {
            self.storeNotificationsUserSettings(notificationsUserSettings: notificationsUserSettings)
        }
    }

    private func postOddsSettingsToGoma() {
        let notificationsUserSettings = UserDefaults.standard.notificationsUserSettings
        Env.gomaNetworkClient.postNotificationsUserSettings(deviceId: Env.deviceId, notificationsUserSettings: notificationsUserSettings)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
