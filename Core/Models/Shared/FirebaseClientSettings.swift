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

    let locale: Locale?

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
        self.isOnMaintenance = isOnMaintenanceInt == 1 ? true : false

        self.currentAppVersion = try container.decode(String.self, forKey: .currentAppVersion)
        self.requiredAppVersion = try container.decode(String.self, forKey: .requiredAppVersion)
        self.lastUpdate = try container.decode(TimeInterval.self, forKey: .lastUpdate)

        self.maintenanceReason = (try? container.decode(String.self, forKey: .maintenanceReason)) ?? ""
        self.locale = try? container.decode(Locale.self, forKey: .locale)

    }
}
