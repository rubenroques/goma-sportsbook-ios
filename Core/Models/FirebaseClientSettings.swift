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

    let locale: Locale

    struct Locale: Codable {
        var currency: String
        var language: String

        enum CodingKeys: String, CodingKey {
            case currency = "currency"
            case language = "lang"
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
}

