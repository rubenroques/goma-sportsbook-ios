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
    var userSettings: UserSettingsGoma?

    // MARK: Lifetime and sCycle
    override init() {
        super.init()

        self.getUserSettings()
    }

    // MARK: Setup and functions
    private func getUserSettings() {
        // Read/Get Data
        if let data = UserDefaults.standard.data(forKey: "gomaUserSettings") {
            do {
                let decoder = JSONDecoder()

                let userSettings = try decoder.decode(UserSettingsGoma.self, from: data)

                self.userSettings = userSettings

            }
            catch {
                print("Unable to Decode UserSettings Goma (\(error))")
            }
        }
    }

    private func setUserSettings(userSettings: UserSettingsGoma) {
        do {
            let encoder = JSONEncoder()

            let data = try encoder.encode(userSettings)

            UserDefaults.standard.set(data, forKey: "gomaUserSettings")
        }
        catch {
            print("Unable to Encode User Settings Goma (\(error))")
        }

        self.postOddsSettingsToGoma()
    }

    func updateSmsSetting(isSettingEnabled: Bool) {
        if isSettingEnabled {
            self.userSettings?.notificationSms = 1
        }
        else {
            self.userSettings?.notificationSms = 0
        }

        if let userSettings = self.userSettings {
            self.setUserSettings(userSettings: userSettings)
        }
    }

    func updateEmailSetting(isSettingEnabled: Bool) {
        if isSettingEnabled {
            self.userSettings?.notificationEmail = 1
        }
        else {
            self.userSettings?.notificationEmail = 0
        }

        if let userSettings = self.userSettings {
            self.setUserSettings(userSettings: userSettings)
        }
    }

    private func postOddsSettingsToGoma() {
        if let data = UserDefaults.standard.data(forKey: "gomaUserSettings") {
            do {
                let decoder = JSONDecoder()

                let userSettings = try decoder.decode(UserSettingsGoma.self, from: data)

                Env.gomaNetworkClient.sendUserSettings(deviceId: Env.deviceId, userSettings: userSettings)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .failure(let error):
                            print("GOMA SETTINGS ERROR: \(error)")
                        case .finished:
                            print("Finished")
                        }
                    }, receiveValue: { value in
                        print("GOMA SETTINGS: \(value)")
                    })
                    .store(in: &cancellables)

            }
            catch {
                print("Unable to Decode UserSettings Goma (\(error))")
            }
        }
    }
}
