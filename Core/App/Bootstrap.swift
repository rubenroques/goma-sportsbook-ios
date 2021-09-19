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

        self.router.makeKeyAndVisible()
        Env.clientSettingsSocket.connect()

        if Env.locationManager.isLocationServicesEnabled() {
            Env.locationManager.startGeoLocationUpdates()
        }
        else {
            Env.locationManager.requestGeoLocationUpdates()
        }

    }
    
}
