//
//  GeoLocationManager.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/08/2021.
//

import Foundation
import CoreLocation
import Combine

class GeoLocationManager: NSObject, CLLocationManagerDelegate {

    static let shared = GeoLocationManager()

    private var locationManager = CLLocationManager()

    let authorizationSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    let locationSubject = PassthroughSubject<[CLLocation], Never>()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = true
    }

    func requestGeoLocationUpdates() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startGeoLocationUpdates() {
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            locationManager.startMonitoringSignificantLocationChanges()
        }
        else {
            locationManager.startUpdatingLocation()
        }
    }

    func stopGeoLocationUpdates() {
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            locationManager.stopMonitoringSignificantLocationChanges()
        }
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationSubject.send(status)

        if status == .authorizedWhenInUse {

        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationSubject.send(locations)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

    }

}
