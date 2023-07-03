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

    var appInitiated: Bool = false

    init(router: Router) {
        self.router = router
    }

    func boot() {
        self.environment = Env

        guard let environment = self.environment else { return }

        self.router.makeKeyAndVisible()

        environment.businessSettingsSocket.connect()

        if TargetVariables.hasFeatureEnabled(feature: .getLocationLimits) {
            if environment.locationManager.isLocationServicesEnabled() {
                environment.locationManager.startGeoLocationUpdates()
            }
        }

        environment.servicesProvider.connect()
        environment.betslipManager.start()

        // TODO: Check this part to enable app initialization without socket connected
        //
//        environment.servicesProvider.eventsConnectionStatePublisher
//            .filter { connectorState in
//                return connectorState == .connected
//            }
//            .sink { _ in
//                environment.sportsStore.requestInitialSportsData()
//            }
//            .store(in: &self.cancellables)
        environment.servicesProvider.eventsConnectionStatePublisher
            .sink { connectorState in
                if connectorState == .disconnected && self.appInitiated == false {
                    environment.sportsStore.requestInitialSportsData()
                    self.appInitiated = true
                    environment.appInitWithoutSocket = true
                }
                else if connectorState == .connected {
                    environment.sportsStore.requestInitialSportsData()
                }
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
