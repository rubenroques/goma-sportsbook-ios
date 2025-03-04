//
//  Environment.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/08/2021.
//

import Foundation
import ServicesProvider

let Env = Environment() // swiftlint:disable:this identifier_name

class Environment {

    let appSession = AppSession()

    let gomaNetworkClient = GomaGamingServiceClient()

    lazy var servicesProvider: ServicesProviderClient = {
        
        var serviceProviderEnvironment: ServicesProvider.ServicesProviderConfiguration.Environment
        switch TargetVariables.serviceProviderEnvironment {
        case .prod:
            serviceProviderEnvironment = .production
        case .dev:
            serviceProviderEnvironment = .staging
        }
        
        let servicesProviderConfiguration = ServicesProviderConfiguration(environment: serviceProviderEnvironment, deviceUUID: Env.deviceId)
        let provider = TargetVariables.serviceProviderType
        switch provider {
        case .everymatrix:
            return ServicesProviderClient(providerType: .everymatrix, configuration: servicesProviderConfiguration)
        case .sportradar:
            return ServicesProviderClient(providerType: .sportradar, configuration: servicesProviderConfiguration)
        }
        
    }()

    let betslipManager = BetslipManager()

    let userSessionStore = UserSessionStore()
    let businessSettingsSocket = RealtimeSocketClient()
    let locationManager = GeoLocationManager()
    let gomaSocialClient = GomaGamingSocialServiceClient()
    let sportsStore = SportTypeStore()

    var calendar = Calendar.autoupdatingCurrent
    var locale = Locale.autoupdatingCurrent
    var timezone = TimeZone.autoupdatingCurrent
    var date: () -> Date = { Date.init() }

    var favoritesManager = FavoritesManager()
    var deviceFirebaseCloudMessagingToken: String = ""

    var deviceId: String {
        UserDefaults.standard.string(forKey: "device_id") ?? ""
    }

    let urlSchemaManager = URLSchemaManager()

    // Sumsub keys
    let sumsubAppToken = "sbx:yjCFqKsuTX6mTY7XMFFPe6hR.v9i5YpFrNND0CeLcZiHeJnnejrCUDZKT"
    let sumsubSecretKey = "4PH7gdufQfrFpFS35gJiwz9d2NFZs4kM"
    
    init() {

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

extension Environment {

    var bundleId: String {
        return Bundle.main.bundleIdentifier ?? "com.goma.sportsbook"
    }
}
