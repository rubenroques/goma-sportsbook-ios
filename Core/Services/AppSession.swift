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
    var businessModulesManager = BusinessModulesManager(businessModules: [])

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

        let businessModulesPublisher = Env.gomaNetworkClient.requestBusinessModules(deviceId: Env.deviceId)
        let instanceSettingsPublisher = Env.gomaNetworkClient.requestBusinessInstanceSettings(deviceId: Env.deviceId)
            
        Publishers.CombineLatest(instanceSettingsPublisher, businessModulesPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                self?.isLoadingAppSettingsPublisher.send(false)
            }, receiveValue: { [weak self] instanceSettings, businessModulesManager in
                self?.businessModulesManager = BusinessModulesManager(businessModules: businessModulesManager)
                self?.homeFeedTemplate = instanceSettings.homeFeedTemplate
            })
            .store(in: &cancellables)
    }
    
}

struct BusinessModulesManager {
    
    private var businessModules: BusinessModules
    
    init(businessModules: BusinessModules) {
        self.businessModules = businessModules
    }
    
    var isSocialFeaturesEnabled: Bool {
        return true
        
        //
        for module in businessModules where module.name.lowercased() == "social features" {
            return module.enabled
        }
        return false
    }
    
}
