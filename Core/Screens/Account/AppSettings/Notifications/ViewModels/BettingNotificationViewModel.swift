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
    var userSettings: UserSettingsGoma?
    var shouldSendSettingsPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var settingsUpdatedPublisher: PassthroughSubject<Void, Never> = .init()

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

    func setUserSettings() {
        if let userSettings = self.userSettings {
            do {
                let encoder = JSONEncoder()

                let data = try encoder.encode(userSettings)

                UserDefaults.standard.set(data, forKey: "gomaUserSettings")
            }
            catch {
                print("Unable to Encode User Settings Goma (\(error))")
            }

            self.postSettingsToGoma()
        }
    }

    private func postSettingsToGoma() {
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
                    }, receiveValue: {[weak self] value in
                        print("GOMA SETTINGS: \(value)")
                        self?.settingsUpdatedPublisher.send()
                    })
                    .store(in: &cancellables)

            }
            catch {
                print("Unable to Decode UserSettings Goma (\(error))")
            }
        }
    }

    func setBetsSelectedOption(view: SettingsRowView, settingType: UserBettingOption) {
        var switchState = false

        if let userSettings = self.userSettings {

            switch settingType {
            case .betFinal:
                if userSettings.notificationsBets == 1 {
                    switchState = true
                }
                else {
                    switchState = false
                }
            case .betSelection:
                if userSettings.notificationBetSelections == 1 {
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
        var settingIdentifier = 0

        if isSettingEnabled {
            settingIdentifier = 1
        }
        else {
            settingIdentifier = 0
        }

        switch settingType {
        case .betFinal:
            self.userSettings?.notificationsBets = settingIdentifier
        case .betSelection:
            self.userSettings?.notificationBetSelections = settingIdentifier
        }

        self.shouldSendSettingsPublisher.send(true)

    }
}

// MARK: Helpers

enum UserBettingOption {
    case betFinal
    case betSelection
}
