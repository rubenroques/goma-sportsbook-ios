//
//  Bootstrap.swift
//  Sportsbook
//
//  Created by Ruben Roques on 15/09/2021.
//

import Foundation
import Combine

class Bootstrap {

    var router: Router

    private var environment: Environment?
    private var cancellables = Set<AnyCancellable>()

    private var bootTriggerCancelable: AnyCancellable?
    
    init(router: Router) {
        self.router = router
    }

    func boot() {
        self.environment = Env

        guard let environment = self.environment else { return }

        environment.businessSettingsSocket.connectAfterAuth()

        if TargetVariables.hasFeatureEnabled(feature: .lockOutOfLocation) {
            if environment.locationManager.isLocationServicesEnabled() {
                environment.locationManager.startGeoLocationUpdates()
            }
        }

        // Prepare the router for boot
        self.setSupportedLanguages()
        
        self.bootTriggerCancelable = environment.businessSettingsSocket.maintenanceModePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] maintenanceModeType in
                switch maintenanceModeType {
                case .enabled:
                    self?.router.showUnderMaintenanceScreenOnBoot()
                case .disabled:
                    self?.connectServiceProvider()
                    self?.router.makeKeyAndVisible()
                    self?.bootTriggerCancelable?.cancel()
                case .unknown:
                    break
                }
            })
        
    }
    
    func setSupportedLanguages() {
        // Force the target supported languages
        let targetSupportedLanguages = TargetVariables.supportedLanguages.map(\.languageCode)
        UserDefaults.standard.set(targetSupportedLanguages, forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    func connectServiceProvider() {

        guard let environment = self.environment else { return }

        environment.servicesProvider.connect()
        environment.betslipManager.start()

        // TODO: Check this part to enable app initialization without socket connected
        //
        environment.servicesProvider.eventsConnectionStatePublisher
            .filter { connectorState in
                return connectorState == .connected
            }
            .sink { _ in
                environment.sportsStore.requestInitialSportsData()
            }
            .store(in: &self.cancellables)

        // ConnectModules
        Publishers.CombineLatest(environment.servicesProvider.bettingConnectionStatePublisher,
                                 environment.userSessionStore.userProfilePublisher)
            .filter({ connectorState, userSession in
                return connectorState == .connected && userSession != nil
            })
            .map({ _ in return () })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {
                environment.favoritesManager.getUserFavorites()
            })
            .store(in: &self.cancellables)
    }
}
