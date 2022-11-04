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

        _ = Env

        self.router.makeKeyAndVisible()
        Env.businessSettingsSocket.connect()

        if Env.locationManager.isLocationServicesEnabled() {
            Env.locationManager.startGeoLocationUpdates()
        }

        let serviceProvider = Env.serviceProvider
        serviceProvider.connect()
        
    }

    func refreshSession() {

    }

}
