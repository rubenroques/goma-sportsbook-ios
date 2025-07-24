//
//  FirebaseClientSettings.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 21/07/2025.
//

import Foundation

struct FirebaseClientSettings: Codable {

    let currentAppVersion: String
    let requiredAppVersion: String
    let lastUpdate: TimeInterval
    let isOnMaintenance: Bool
    let maintenanceReason: String?

    enum CodingKeys: String, CodingKey {
        case currentAppVersion = "ios_current_version"
        case requiredAppVersion = "ios_required_version"
        case lastUpdate = "last_settings_update"
        case isOnMaintenance = "maintenance_mode"
        case maintenanceReason = "maintenance_reason"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

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
    }

    init(currentAppVersion: String,
         requiredAppVersion: String,
         lastUpdate: TimeInterval,
         isOnMaintenance: Bool,
         maintenanceReason: String?) {

        self.currentAppVersion = currentAppVersion
        self.requiredAppVersion = requiredAppVersion
        self.lastUpdate = lastUpdate
        self.isOnMaintenance = isOnMaintenance
        self.maintenanceReason = maintenanceReason
    }

}

extension FirebaseClientSettings {
    static var defaultSettings: FirebaseClientSettings {
        return FirebaseClientSettings(currentAppVersion: "1.0.0",
                                      requiredAppVersion: "1.0.0",
                                      lastUpdate: Date().timeIntervalSince1970,
                                      isOnMaintenance: false,
                                      maintenanceReason: nil)
    }
}
