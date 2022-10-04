//
//  Environment.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/08/2021.
//

import Foundation
import ServiceProvider

let Env = Environment() // swiftlint:disable:this identifier_name

class Environment {

    let appSession = AppSession()

    let gomaNetworkClient = GomaGamingServiceClient()
    let everyMatrixClient = EveryMatrixServiceClient()
    let everyMatrixStorage = AggregatorsRepository()

    // let serviceProvider = ServiceProvider()
    lazy var serviceProvider: ServiceProvider = {
        
        return ServiceProvider(providerType: .sportsradar)
        
        let provider = TargetVariables.defaultCardStyle
        switch provider {
        case .normal:
            return ServiceProvider(providerType: .everymatrix)
        case .small:
            return ServiceProvider(providerType: .sportsradar)
        }
    }()
    
    let betslipManager = BetslipManager()

    let userSessionStore = UserSessionStore()
    let businessSettingsSocket = RealtimeSocketClient()
    let locationManager = GeoLocationManager()
    let gomaSocialClient = GomaGamingSocialServiceClient()

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
    let urlSchemaManager = URLSchemaManager()
    let urlApp: String = "https://sportsbook.gomagaming.com/"

    var userBetslipSettingsSelectorList: [BetslipSelection] = [BetslipSelection(key: BetslipOddValidationType.acceptAny.rawValue,
                                                                                description: localized("accept_any")),
                                                               BetslipSelection(key: BetslipOddValidationType.acceptHigher.rawValue,
                                                                                description: localized("accept_higher"))]

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
