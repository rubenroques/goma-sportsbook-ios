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
        let provider = TargetVariables.serviceProviderType
        switch provider {
        case .everymatrix:
            return ServicesProviderClient(providerType: .everymatrix)
        case .sportradar:
            return ServicesProviderClient(providerType: .sportradar)
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
    var deviceFCMToken: String = ""

    var deviceId: String {
        UserDefaults.standard.string(forKey: "device_id") ?? ""
    }

    //let urlMobileShares: String = "https://sportsbook.gomagaming.com/mobile"
    let urlMobileShares: String = "https://sportsbook-stage.gomagaming.com/?shared_bet="
    let urlSchemaManager = URLSchemaManager()
    //let urlApp: String = "https://sportsbook.gomagaming.com/"
    let urlApp: String = "https://sportsbook-stage.gomagaming.com/"

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
