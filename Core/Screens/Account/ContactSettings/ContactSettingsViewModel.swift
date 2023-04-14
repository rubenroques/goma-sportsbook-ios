//
//  ContactSettingsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 13/04/2023.
//

import Foundation
import Combine

class ContactSettingsViewModel {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var notificationsUserSettings: NotificationsUserSettings?

    // MARK: Lifetime and sCycle
    init() {

        self.getUserSettings()
    }

    // MARK: Setup and functions
    private func getUserSettings() {
        self.notificationsUserSettings = UserDefaults.standard.notificationsUserSettings
    }

    func storeNotificationsUserSettings() {
        if let notificationsUserSettings = self.notificationsUserSettings {
            UserDefaults.standard.notificationsUserSettings = notificationsUserSettings
            self.postOddsSettingsToGoma()
        }
    }

    func updateSmsSetting(enabled: Bool) {
        self.notificationsUserSettings?.notificationsSms = enabled
        self.storeNotificationsUserSettings()
    }

    func updateEmailSetting(enabled: Bool) {
        self.notificationsUserSettings?.notificationsEmail = enabled
        self.storeNotificationsUserSettings()
    }

    private func postOddsSettingsToGoma() {
        let notificationsUserSettings = UserDefaults.standard.notificationsUserSettings
        Env.gomaNetworkClient.postNotificationsUserSettings(deviceId: Env.deviceId, notificationsUserSettings: notificationsUserSettings)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print("PostSettings completion \(completion)")
            }, receiveValue: { response in
                print("PostSettings response \(response)")
            })
            .store(in: &cancellables)
    }
}
