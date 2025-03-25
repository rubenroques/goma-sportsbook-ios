//
//  FirebaseClientSettings.swift
//  Sportsbook
//
//  Created by Ruben Roques on 15/09/2021.
//

import Foundation

struct FirebaseClientSettings: Codable {

    let showInformationPopUp: Bool

    let currentAppVersion: String
    let requiredAppVersion: String

    let lastUpdate: TimeInterval
    let isOnMaintenance: Bool
    let maintenanceReason: String

    let requiredPhoneVerification: Bool

    let locale: Locale?

    let partialCashoutEnabled: Bool

    let hasRollingWeeklyLimits: Bool
    let homeLiveEventsCount: Int

    let replaySportsCodes: [String]
    let ungroupedMarkets: [String]

    let featuredCompetition: FeaturedCompetition?

    struct Locale: Codable {
        var currency: String
        var language: String
        var country: String

        enum CodingKeys: String, CodingKey { // swiftlint:disable:this nesting
            case currency = "currency"
            case language = "lang"
            case country = "country"
        }
    }

    enum CodingKeys: String, CodingKey {
        case showInformationPopUp = "information_popup"
        case currentAppVersion = "ios_current_version"
        case requiredAppVersion = "ios_required_version"
        case lastUpdate = "last_settings_update"
        case isOnMaintenance = "maintenance_mode"
        case maintenanceReason = "maintenance_reason"
        case locale = "locale"
        case partialCashoutEnabled = "partial_cashout"
        case requiredPhoneVerification = "signup_2fa"
        case replaySportsCodes = "replay_sports"
        case ungroupedMarkets = "ungrouped_markets"
        case hasRollingWeeklyLimits = "limit_type_rolling"
        case homeLiveEventsCount = "home_live_num_matches"
        case featuredCompetition = "feature_competition"
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let showInformationPopUpInt = try? container.decode(Int.self, forKey: .showInformationPopUp) {
            self.showInformationPopUp = showInformationPopUpInt == 1 ? true : false
        }
        else if let showInformationPopUpString = try? container.decode(String.self, forKey: .showInformationPopUp) {
            self.showInformationPopUp = showInformationPopUpString == "1" ? true : false
        }
        else {
            self.showInformationPopUp = false
        }

        #if DEBUG
        var simulateMaintenanceMode = false
        if simulateMaintenanceMode {
            self.isOnMaintenance = true
            self.maintenanceReason = "[DEBUG] App is under maintenance for testing purposes"
        }
        else {
            let isOnMaintenanceInt = try container.decode(Int.self, forKey: .isOnMaintenance)
            self.isOnMaintenance = isOnMaintenanceInt == 1
            self.maintenanceReason = (try? container.decode(String.self, forKey: .maintenanceReason)) ?? ""
        }
        #else
        let isOnMaintenanceInt = try container.decode(Int.self, forKey: .isOnMaintenance)
        self.isOnMaintenance = isOnMaintenanceInt == 1
        self.maintenanceReason = (try? container.decode(String.self, forKey: .maintenanceReason)) ?? ""
        #endif

        self.currentAppVersion = try container.decode(String.self, forKey: .currentAppVersion)
        self.requiredAppVersion = try container.decode(String.self, forKey: .requiredAppVersion)
        self.lastUpdate = try container.decode(TimeInterval.self, forKey: .lastUpdate)

        self.locale = try? container.decode(Locale.self, forKey: .locale)

        let requiredPhoneVerificationInt = (try? container.decode(Int.self, forKey: .requiredPhoneVerification)) ?? 0
        self.requiredPhoneVerification = requiredPhoneVerificationInt == 1

        let partialCashoutEnabledInt = try container.decode(Int.self, forKey: .partialCashoutEnabled)
        self.partialCashoutEnabled = partialCashoutEnabledInt == 1

        if let replaySportsCodesDictionary = try? container.decode([Int: String].self, forKey: .replaySportsCodes) {
            self.replaySportsCodes = replaySportsCodesDictionary.map(\.value)
        }
        else if let replaySportsCodesArray = try? container.decode([String].self, forKey: .replaySportsCodes) {
            self.replaySportsCodes = replaySportsCodesArray
        }
        else {
            self.replaySportsCodes = []
        }

        if let ungroupedMarketsDictionary = try? container.decode([Int: Int].self, forKey: .ungroupedMarkets) {
            self.ungroupedMarkets = ungroupedMarketsDictionary.map(\.value).map(String.init)
        }
        else if let ungroupedMarketsDictionary = try? container.decode([Int: String].self, forKey: .ungroupedMarkets) {
            self.ungroupedMarkets = ungroupedMarketsDictionary.map(\.value)
        }
        else if let ungroupedMarketsArray = try? container.decode([Int].self, forKey: .ungroupedMarkets) {
            self.ungroupedMarkets = ungroupedMarketsArray.map(String.init)
        }
        else if let ungroupedMarketsArray = try? container.decode([String].self, forKey: .ungroupedMarkets) {
            self.ungroupedMarkets = ungroupedMarketsArray
        }
        else {
            self.ungroupedMarkets = []
        }

        let hasRollingWeeklyLimitsInt = (try? container.decode(Int.self, forKey: .hasRollingWeeklyLimits)) ?? 0
        self.hasRollingWeeklyLimits = hasRollingWeeklyLimitsInt == 1

        let homeLiveEventsCountInt = (try? container.decode(Int.self, forKey: .homeLiveEventsCount)) ?? 3
        self.homeLiveEventsCount = homeLiveEventsCountInt

        let featuredCompetition = try container.decodeIfPresent(FeaturedCompetition.self, forKey: .featuredCompetition)
        self.featuredCompetition = featuredCompetition
    }

    init(showInformationPopUp: Bool,
         currentAppVersion: String,
         requiredAppVersion: String,
         lastUpdate: TimeInterval,
         isOnMaintenance: Bool,
         maintenanceReason: String,
         requiredPhoneVerification: Bool,
         locale: Locale?,
         partialCashoutEnabled: Bool,
         replaySportsCodes: [String],
         ungroupedMarkets: [String],
         hasRollingWeeklyLimits: Bool, homeLiveEventsCount: Int,
         featuredCompetition: FeaturedCompetition?) {

        self.showInformationPopUp = showInformationPopUp
        self.currentAppVersion = currentAppVersion
        self.requiredAppVersion = requiredAppVersion
        self.lastUpdate = lastUpdate
        self.isOnMaintenance = isOnMaintenance
        self.maintenanceReason = maintenanceReason
        self.requiredPhoneVerification = requiredPhoneVerification
        self.locale = locale
        self.partialCashoutEnabled = partialCashoutEnabled
        self.replaySportsCodes = replaySportsCodes
        self.ungroupedMarkets = ungroupedMarkets
        self.hasRollingWeeklyLimits = hasRollingWeeklyLimits
        self.homeLiveEventsCount = homeLiveEventsCount
        self.featuredCompetition = featuredCompetition
    }

}

extension FirebaseClientSettings {
    static var defaultSettings: FirebaseClientSettings {
        return FirebaseClientSettings(showInformationPopUp: false,
                                      currentAppVersion: "1.0.0",
                                      requiredAppVersion: "1.0.0",
                                      lastUpdate: Date().timeIntervalSince1970,
                                      isOnMaintenance: false,
                                      maintenanceReason: "",
                                      requiredPhoneVerification: false,
                                      locale: nil,
                                      partialCashoutEnabled: false,
                                      replaySportsCodes: [],
                                      ungroupedMarkets: [],
                                      hasRollingWeeklyLimits: false,
                                      homeLiveEventsCount: 3,
        featuredCompetition: nil)
    }
}
