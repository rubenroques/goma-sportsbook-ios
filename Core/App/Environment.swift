//
//  Environment.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/08/2021.
//

import Foundation

let Env = Environment() // swiftlint:disable:this identifier_name

class Environment {

    let appSession = AppSession()

    let gomaNetworkClient = GomaGamingServiceClient() // session: Environment.pulseConnectedSession()))
    let everyMatrixClient = EveryMatrixServiceClient()
    let everyMatrixStorage = AggregatorsRepository()

    let betslipManager = BetslipManager()

    let userSessionStore = UserSessionStore()
    let businessSettingsSocket = RealtimeSocketClient()
    let locationManager = GeoLocationManager()

    var calendar = Calendar.autoupdatingCurrent
    var locale = Locale.autoupdatingCurrent
    var timezone = TimeZone.autoupdatingCurrent
    var date: () -> Date = { Date.init() }

    var favoritesManager = FavoritesManager()
    var deviceFCMToken: String = ""

    var deviceId: String {
        UserDefaults.standard.string(forKey: "device_id") ?? ""
    }

    let urlMobileShares: String = "https://sportsbook.gomagaming.com/mobile"
    let urlSchemaManager = UrlSchemaManager()

    var userBetslipSettingsSelectorList: [BetslipSelection] = [BetslipSelection(key: "ACCEPT_ANY", description: localized("accept_any")),
                                                               BetslipSelection(key: "ACCEPT_HIGHER", description: localized("accept_higher"))]

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

extension Environment {

    var bundleId: String {
        return Bundle.main.bundleIdentifier ?? "com.goma.sportsbook"
    }
}
