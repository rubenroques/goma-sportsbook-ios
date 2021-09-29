//
//  Environment.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/08/2021.
//

import Foundation

var Env = Environment() // swiftlint:disable:this identifier_name

struct Environment {

    let gomaNetworkClient = GomaGamingServiceClient(networkClient: NetworkManager()) //session: Environment.pulseConnectedSession()))
    let everyMatrixAPIClient = EveryMatrixAPIClient()

    let eventsStore = EventsStore()

    let userSessionStore = UserSessionStore()
    let businessSettingsSocket = RealtimeSocketClient()
    let locationManager = GeoLocationManager()

    var calendar = Calendar.autoupdatingCurrent
    var locale = Locale.autoupdatingCurrent
    var timezone = TimeZone.autoupdatingCurrent
    var date: () -> Date = { Date.init() }


    var deviceId: String {
        UserDefaults.standard.string(forKey: "device_id") ?? ""
    }

    var operatorId: Int = 2474 // EM GOMA Operator Id

    var remember: Bool = false
    
    func getUserSettings() -> [GomaClientSettings]? {
        let settingsData = UserDefaults.standard.data(forKey: "user_settings")
        let settingsArray = try? JSONDecoder().decode([GomaClientSettings].self, from: settingsData!)
        return settingsArray
    }

}

extension Environment {
    var timezoneOffset: TimeInterval {
        return TimeInterval(Env.timezone.secondsFromGMT())
    }

    var timezoneOffsetInMinutes: Int {
        let timeInterval = Env.timezoneOffset
        return Int(timeInterval)/60
    }
}
