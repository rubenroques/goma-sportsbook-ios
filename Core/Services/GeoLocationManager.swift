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
    var lastLocation: CLLocation = CLLocation()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = true
    }

    func requestGeoLocationUpdates() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
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

    func isLocationServicesEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            @unknown default:
                return false
            }
        }

        return false
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationSubject.send(status)

        if status == .authorizedWhenInUse {

        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }
        print("User Location: \(location.latitude) - \(location.longitude)")
        self.locationSubject.send(locations)
        self.lastLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

    }

}
