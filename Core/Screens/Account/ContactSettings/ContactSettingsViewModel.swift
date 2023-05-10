//
//  ContactSettingsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 13/04/2023.
//

import Foundation
import Combine
import ServicesProvider

class ContactSettingsViewModel {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var notificationsUserSettings: NotificationsUserSettings?
    var userConsents: [UserConsent]?

    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    // MARK: Lifetime and sCycle
    init() {

        self.getUserSettings()
    }

    // MARK: Setup and functions
    private func getUserSettings() {
        //self.notificationsUserSettings = UserDefaults.standard.notificationsUserSettings
        self.isLoadingPublisher.send(true)

        Env.servicesProvider.getUserConsents()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("USER CONSENTS ERROR: \(error)")
                }
            }, receiveValue: { [weak self] userConsents in

                print("USER CONSENTS: \(userConsents)")

                self?.userConsents = userConsents

                var notificationUserSettings = UserDefaults.standard.notificationsUserSettings

                let smsUserConsent = userConsents.filter({
                    $0.consentInfo.key == "sms_promotions"
                }).first

                let emailUserConsent = userConsents.filter({
                    $0.consentInfo.key == "email_promotions"
                }).first

                if smsUserConsent?.consentStatus == "NOT_CONSENTED" {
                    notificationUserSettings.notificationsSms = false
                }
                else {
                    notificationUserSettings.notificationsSms = true
                }

                if emailUserConsent?.consentStatus == "NOT_CONSENTED" {
                    notificationUserSettings.notificationsEmail = false
                }
                else {
                    notificationUserSettings.notificationsEmail = true
                }

                self?.notificationsUserSettings = notificationUserSettings

                UserDefaults.standard.notificationsUserSettings = notificationUserSettings

                self?.isLoadingPublisher.send(false)
            })
            .store(in: &cancellables)
    }

    func storeNotificationsUserSettings() {
        if let notificationsUserSettings = self.notificationsUserSettings {
            UserDefaults.standard.notificationsUserSettings = notificationsUserSettings
            self.postOddsSettingsToGoma()
        }
    }

    func updateSmsSetting(enabled: Bool) {

        self.notificationsUserSettings?.notificationsSms = enabled
        //  self.storeNotificationsUserSettings()

        if let versionId = self.userConsents?.filter({
            $0.consentInfo.key == "sms_promotions"
        }).first?.consentInfo.consentVersionId {

            self.setUserConsents(versionId: versionId, isConsent: enabled)

        }

    }

    func updateEmailSetting(enabled: Bool) {

        self.notificationsUserSettings?.notificationsEmail = enabled
        //  self.storeNotificationsUserSettings()

        if let versionId = self.userConsents?.filter({
            $0.consentInfo.key == "email_promotions"
        }).first?.consentInfo.consentVersionId {

            self.setUserConsents(versionId: versionId, isConsent: enabled)

        }

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

    private func setUserConsents(versionId: Int, isConsent: Bool) {

        self.isLoadingPublisher.send(true)

        Env.servicesProvider.setUserConsents(consentVersionIds: isConsent ? [versionId] : nil, unconsetVersionIds: !isConsent ? [versionId] : nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("SET USER CONSENTS ERROR: \(error)")
                }

                self?.isLoadingPublisher.send(false)

            }, receiveValue: { [weak self] basicResponse in

                if let notificationUserSettings = self?.notificationsUserSettings {

                    UserDefaults.standard.notificationsUserSettings = notificationUserSettings

                }

            })
            .store(in: &cancellables)
    }
}
