//
//  AppSession.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/10/2021.
//

import Foundation
import Combine

class AppSession {

    var operatorId: String = "2474"
    var currency: String = "EUR"
    var language: String = "en"

    var isLoadingAppSettingsPublisher = CurrentValueSubject<Bool, Never>(true)

    var homeFeedTemplate: HomeFeedTemplate?

    private var cancellables = Set<AnyCancellable>()

    init() {
        self.connectPublishers()
    }

    func connectPublishers() {
        NotificationCenter.default.publisher(for: .socketConnected)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in

            }, receiveValue: { [weak self] _ in
                Logger.log("EMSessionLoginFLow - Socket Connected received will login if needed")
                self?.requestAppClientSettings()
            })
            .store(in: &cancellables)
    }

    func requestAppClientSettings() {
        self.isLoadingAppSettingsPublisher.send(true)

        Env.gomaNetworkClient.requestBusinessInstanceSettings(deviceId: Env.deviceId)
            .sink(receiveCompletion: { [weak self] _ in

                self?.isLoadingAppSettingsPublisher.send(false)
            }, receiveValue: { [weak self] value in
                self?.homeFeedTemplate = value.homeFeedTemplate
            })
            .store(in: &cancellables)
    }

}
