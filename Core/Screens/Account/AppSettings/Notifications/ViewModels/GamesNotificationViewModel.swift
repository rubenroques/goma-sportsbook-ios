//
//  GamesNotificationViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 21/02/2022.
//

import Foundation
import Combine

class GamesNotificationViewModel: NSObject {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var userSettings: UserSettingsGoma?
    var notificationsEnabledViews: [SettingsRowView] = []
    var isStackViewDisabledPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var shouldSendSettingsPublisher: CurrentValueSubject<Bool, Never> = .init(false)

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

    func setGamesSelectedOption(view: SettingsRowView, settingType: UserSettingOption) {
        var switchState = false

        if let userSettings = self.userSettings {

            switch settingType {
            case .startGame:
                if userSettings.notificationsStartgame == 1 {
                    switchState = true
                }
                else {
                    switchState = false
                }
            case .goals:
                if userSettings.notificationGoal == 1 {
                    switchState = true
                }
                else {
                    switchState = false
                }
            case .halfTime:
                if userSettings.notificationsHalftime == 1 {
                    switchState = true
                }
                else {
                    switchState = false
                }
            case .secondHalfTime:
                if userSettings.notificationsSecondhalf == 1 {
                    switchState = true
                }
                else {
                    switchState = false
                }
            case .fullTime:
                if userSettings.notificationsFulltime == 1 {
                    switchState = true
                }
                else {
                    switchState = false
                }
            case .redCard:
                if userSettings.notificationsRedcard == 1 {
                    switchState = true
                }
                else {
                    switchState = false
                }
            case .gamesWatchList:
                if userSettings.notificationGamesWatchlist == 1 {
                    switchState = true
                }
                else {
                    switchState = false
                }
            case .competitionWatchList:
                if userSettings.notificationsCompetitionsWatchlist == 1 {
                    switchState = true
                }
                else {
                    switchState = false
                }
            }
        }

        view.isSwitchOn = switchState
    }

    func updateGamesSetting(isSettingEnabled: Bool, settingType: UserSettingOption) {
        var settingIdentifier = 0

        if isSettingEnabled {
            settingIdentifier = 1
        }
        else {
            settingIdentifier = 0
        }

        switch settingType {
        case .startGame:
            self.userSettings?.notificationsStartgame = settingIdentifier
        case .goals:
            self.userSettings?.notificationGoal = settingIdentifier
        case .halfTime:
            self.userSettings?.notificationsHalftime = settingIdentifier
        case .secondHalfTime:
            self.userSettings?.notificationsSecondhalf = settingIdentifier
        case .fullTime:
            self.userSettings?.notificationsFulltime = settingIdentifier
        case .redCard:
            self.userSettings?.notificationsRedcard = settingIdentifier
        case .gamesWatchList:
            self.userSettings?.notificationGamesWatchlist = settingIdentifier
        case .competitionWatchList:
            self.userSettings?.notificationsCompetitionsWatchlist = settingIdentifier
        }

        self.shouldSendSettingsPublisher.send(true)

    }

    func checkNotificationSwitches() {
        var disabledStackView = true

        for view in self.notificationsEnabledViews {
            if view.isSwitchOn {
                disabledStackView = false
            }
        }

        self.isStackViewDisabledPublisher.send(disabledStackView)
    }

    func checkBottomStackViewDisableState() {
        var disabledStackView = true

        for view in self.notificationsEnabledViews {
            if view.isSwitchOn {
                disabledStackView = false
            }

        }

        self.isStackViewDisabledPublisher.send(disabledStackView)
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

                    })
                    .store(in: &cancellables)

            }
            catch {
                print("Unable to Decode UserSettings Goma (\(error))")
            }
        }
    }
}

// MARK: Helpers

enum UserSettingOption {
    case startGame
    case goals
    case halfTime
    case secondHalfTime
    case fullTime
    case redCard
    case gamesWatchList
    case competitionWatchList
}
