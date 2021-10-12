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

        let _ = Env
        let _ = TSManager.shared.isConnected

        self.router.makeKeyAndVisible()
        Env.businessSettingsSocket.connect()

        if Env.locationManager.isLocationServicesEnabled() {
            Env.locationManager.startGeoLocationUpdates()
        }

    }
    
}
