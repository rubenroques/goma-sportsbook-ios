//
//  Bootstrap.swift
//  Sportsbook
//
//  Created by Ruben Roques on 15/09/2021.
//

import Foundation

struct Bootstrap {

    var router: Router

    init(router: Router) {
        self.router = router
    }

    func boot() {
        let env = Env

        self.router.makeKeyAndVisible()

        env.betslipManager.start()
        env.businessSettingsSocket.connect()

        if env.locationManager.isLocationServicesEnabled() {
            env.locationManager.startGeoLocationUpdates()
        }

        env.servicesProvider.connect()
        env.sportsStore.getSportTypesList()
    }

    func refreshSession() {

    }

}

