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
    var notificationsUserSettings: NotificationsUserSettings?
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
        self.notificationsUserSettings = UserDefaults.standard.notificationsUserSettings
    }

    func storeNotificationsUserSettings() {
        if let notificationsUserSettings = self.notificationsUserSettings {
            UserDefaults.standard.notificationsUserSettings = notificationsUserSettings
            self.postSettingsToGoma()
        }
    }

    func setGamesSelectedOption(view: SettingsRowView, settingType: UserSettingOption) {
        var switchState = false

        if let notificationsUserSettings = self.notificationsUserSettings {
            switch settingType {
            case .startGame:
                   switchState = notificationsUserSettings.notificationsStartgame
            case .goals:
                   switchState = notificationsUserSettings.notificationsGoal
            case .halfTime:
                   switchState = notificationsUserSettings.notificationsHalftime
            case .secondHalfTime:
                   switchState = notificationsUserSettings.notificationsSecondhalf
            case .fullTime:
                   switchState = notificationsUserSettings.notificationsFulltime
            case .redCard:
                   switchState = notificationsUserSettings.notificationsRedcard
            case .gamesWatchList:
                   switchState = notificationsUserSettings.notificationsGamesWatchlist
            case .competitionWatchList:
                   switchState = notificationsUserSettings.notificationsCompetitionsWatchlist
            }
        }

        view.isSwitchOn = switchState
    }

    func updateGamesSetting(isSettingEnabled: Bool, settingType: UserSettingOption) {
        switch settingType {
        case .startGame:
            self.notificationsUserSettings?.notificationsStartgame = isSettingEnabled
        case .goals:
            self.notificationsUserSettings?.notificationsGoal = isSettingEnabled
        case .halfTime:
            self.notificationsUserSettings?.notificationsHalftime = isSettingEnabled
        case .secondHalfTime:
            self.notificationsUserSettings?.notificationsSecondhalf = isSettingEnabled
        case .fullTime:
            self.notificationsUserSettings?.notificationsFulltime = isSettingEnabled
        case .redCard:
            self.notificationsUserSettings?.notificationsRedcard = isSettingEnabled
        case .gamesWatchList:
            self.notificationsUserSettings?.notificationsGamesWatchlist = isSettingEnabled
        case .competitionWatchList:
            self.notificationsUserSettings?.notificationsCompetitionsWatchlist = isSettingEnabled
        }
        
        self.storeNotificationsUserSettings()
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
        let notificationsUserSettings = UserDefaults.standard.notificationsUserSettings
        Env.gomaNetworkClient.postNotificationsUserSettings(deviceId: Env.deviceId, notificationsUserSettings: notificationsUserSettings)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
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
