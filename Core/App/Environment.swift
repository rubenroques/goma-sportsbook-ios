//
//  Environment.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/08/2021.
//

import Foundation

var Env = Environment() // swiftlint:disable:this identifier_name

struct Environment {

    let gomaNetworkClient = GomaGamingServiceClient(networkClient: NetworkManager())
    let everyMatrixAPIClient = EveryMatrixAPIClient()

    let userSessionStore = UserSessionStore()
    let clientSettingsSocket = RealtimeSocketClient()
    let locationManager = GeoLocationManager()
    
    var deviceId: String {
        UserDefaults.standard.string(forKey: "device_id") ?? ""
    }

    var operatorId: Int = 2474  // EM GOMA Operator Id

    var remember: Bool = false
    
    func getUserSettings() -> [GomaClientSettings]? {
        let settingsData = UserDefaults.standard.data(forKey: "user_settings")
        let settingsArray = try? JSONDecoder().decode([GomaClientSettings].self, from: settingsData!)
        return settingsArray
    }

}
