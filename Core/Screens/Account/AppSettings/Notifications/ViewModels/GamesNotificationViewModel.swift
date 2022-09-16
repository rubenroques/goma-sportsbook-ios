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
                   switchState = userSettings.notificationsStartgame
            case .goals:
                   switchState = userSettings.notificationGoal
            case .halfTime:
                   switchState = userSettings.notificationsHalftime
            case .secondHalfTime:
                   switchState = userSettings.notificationsSecondhalf
            case .fullTime:
                   switchState = userSettings.notificationsFulltime
            case .redCard:
                   switchState = userSettings.notificationsRedcard
            case .gamesWatchList:
                   switchState = userSettings.notificationGamesWatchlist
            case .competitionWatchList:
                   switchState = userSettings.notificationsCompetitionsWatchlist
            }
        }

        view.isSwitchOn = switchState
    }

    func updateGamesSetting(isSettingEnabled: Bool, settingType: UserSettingOption) {
        switch settingType {
        case .startGame:
            self.userSettings?.notificationsStartgame = isSettingEnabled
        case .goals:
            self.userSettings?.notificationGoal = isSettingEnabled
        case .halfTime:
            self.userSettings?.notificationsHalftime = isSettingEnabled
        case .secondHalfTime:
            self.userSettings?.notificationsSecondhalf = isSettingEnabled
        case .fullTime:
            self.userSettings?.notificationsFulltime = isSettingEnabled
        case .redCard:
            self.userSettings?.notificationsRedcard = isSettingEnabled
        case .gamesWatchList:
            self.userSettings?.notificationGamesWatchlist = isSettingEnabled
        case .competitionWatchList:
            self.userSettings?.notificationsCompetitionsWatchlist = isSettingEnabled
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
