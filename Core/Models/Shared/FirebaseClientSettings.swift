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

    let replaySportsCodes: [String]

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

        let isOnMaintenanceInt = try container.decode(Int.self, forKey: .isOnMaintenance)
        self.isOnMaintenance = isOnMaintenanceInt == 1

        self.currentAppVersion = try container.decode(String.self, forKey: .currentAppVersion)
        self.requiredAppVersion = try container.decode(String.self, forKey: .requiredAppVersion)
        self.lastUpdate = try container.decode(TimeInterval.self, forKey: .lastUpdate)

        self.maintenanceReason = (try? container.decode(String.self, forKey: .maintenanceReason)) ?? ""
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
         replaySportsCodes: [String]) {

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
                                      replaySportsCodes: [])
    }
}
