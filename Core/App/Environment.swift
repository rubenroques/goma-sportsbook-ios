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

    let appSession: AppSession = AppSession()

    let gomaNetworkClient: GomaGamingServiceClient = GomaGamingServiceClient()

    lazy var servicesProvider: ServicesProvider.Client = {
        
        var serviceProviderEnvironment: ServicesProvider.Configuration.Environment
        switch TargetVariables.serviceProviderEnvironment {
        case .prod:
            serviceProviderEnvironment = .production
        case .dev:
            serviceProviderEnvironment = .staging
        }
        
        let servicesProviderConfiguration = ServicesProvider.Configuration(environment: serviceProviderEnvironment, deviceUUID: Env.deviceId)
        let provider = TargetVariables.serviceProviderType
        let client: ServicesProvider.Client
        switch provider {
        case .everymatrix:
            client = ServicesProvider.Client(providerType: .everymatrix, configuration: servicesProviderConfiguration)
        case .sportradar:
            client = ServicesProvider.Client(providerType: .sportradar, configuration: servicesProviderConfiguration)
        }
        
        // Set feature flags
        client.setMixMatchFeatureEnabled(TargetVariables.hasFeatureEnabled(feature: .mixMatch))
        
        return client
    }()

    let betslipManager: BetslipManager = BetslipManager()

    let userSessionStore: UserSessionStore = UserSessionStore()
    let businessSettingsSocket: RealtimeSocketClient = RealtimeSocketClient()
    let locationManager: GeoLocationManager = GeoLocationManager()
    let gomaSocialClient: GomaGamingSocialServiceClient = GomaGamingSocialServiceClient()
    let sportsStore: SportTypeStore = SportTypeStore()

    var calendar: Calendar = Calendar.autoupdatingCurrent
    var locale: Locale = Locale.autoupdatingCurrent
    var timezone: TimeZone = TimeZone.autoupdatingCurrent
    var date: () -> Date = { Date.init() }

    var favoritesManager: FavoritesManager = FavoritesManager()
    var deviceFirebaseCloudMessagingToken: String = ""

    var deviceId: String {
        UserDefaults.standard.string(forKey: "device_id") ?? ""
    }

    let urlSchemaManager: URLSchemaManager = URLSchemaManager()

    // Sumsub keys
    let sumsubAppToken = "sbx:yjCFqKsuTX6mTY7XMFFPe6hR.v9i5YpFrNND0CeLcZiHeJnnejrCUDZKT"
    let sumsubSecretKey: String = "4PH7gdufQfrFpFS35gJiwz9d2NFZs4kM"
    
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
