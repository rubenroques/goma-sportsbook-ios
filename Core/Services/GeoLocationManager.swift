//
//  GeoLocationManager.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/08/2021.
//

import CoreLocation
import Combine

enum GeoLocationStatus {
    case invalid
    case valid
    case notAuthorized
    case notRequested
    case notDetermined
}

class GeoLocationManager: NSObject, CLLocationManagerDelegate {

    private var locationManager = CLLocationManager()
    let locationStatus = CurrentValueSubject<GeoLocationStatus, Never>(.notDetermined)
    let authorizationstatus: CLAuthorizationStatus = .notDetermined
    var lastKnownLocation: CLLocation?

    var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = true
    }

    func requestGeoLocationUpdates() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startGeoLocationUpdates() {
        Logger.log("startGeoLocationUpdates")

        #if DEBUG
        locationManager.startUpdatingLocation()
        return
        #endif

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
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationStatus.send(.notRequested)
        case .restricted, .denied:
            locationStatus.send(.notAuthorized)
        case .authorizedAlways, .authorizedWhenInUse:
            self.startGeoLocationUpdates()
        @unknown default:
            locationStatus.send(.notRequested)
        }

        Logger.log("didChangeAuthorization \(status)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }
        if self.lastKnownLocation?.coordinate.latitude == location.latitude &&
            self.lastKnownLocation?.coordinate.longitude == location.longitude {
            return
        }
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.lastKnownLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            self.checkValidLocation(self.lastKnownLocation!)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.log("locationManager didFailWithError \(error)")
    }

    func checkValidLocation(_ location: CLLocation) {

        Logger.log("checkValidLocation \(location.coordinate) | \(CLLocationManager.authorizationStatus())")

        Env.gomaNetworkClient.requestGeoLocation(deviceId: Env.deviceId,
                                                 latitude: location.coordinate.latitude,
                                                 longitude: location.coordinate.longitude)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    self.locationStatus.send(.notDetermined)
                case .finished:
                    self.locationStatus.send(.notDetermined)
                }
            },
            receiveValue: { validLocation in
                if validLocation {
                    self.locationStatus.send(.valid)
                }
                else {
                    self.locationStatus.send(.invalid)
                }

            })
            .store(in: &cancellables)

    }
}

extension CLAuthorizationStatus: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .authorizedAlways:
            return "authorizedAlways"
        case .authorizedWhenInUse:
            return "authorizedWhenInUse"
        case .denied:
            return "denied"
        case .notDetermined:
            return "notDetermined"
        case .restricted:
            return "restricted"
        @unknown default:
            return "unknown case"
        }
    }
}
