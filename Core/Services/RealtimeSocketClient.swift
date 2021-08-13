//
//  RealtimeSocketClient.swift
//  Sportsbook
//
//  Created by André Lascas on 12/08/2021.
//

import Foundation
import FirebaseDatabase

class RealtimeSocketClient {

    var ref: DatabaseReference!
    var maintenanceMode: String = "maintenance_mode"
    var maintenanceReason: String = "maintenance_reason"
    var lastSettingsUpdate: String = "last_settings_update"
    var iosCurrentVersion: String = "ios_current_version"
    var iosRequiredVersion: String = "ios_required_version"

    init() {
        ref = Database.database().reference()

        //print("User Defaults: \(UserDefaults.standard.dictionaryRepresentation())")
        // Observers
        observeChild(child: maintenanceReason)
        observeChild(child: maintenanceMode)
        observeChild(child: lastSettingsUpdate)
        observeChild(child: iosCurrentVersion)
        observeChild(child: iosRequiredVersion)

    }

    ///      Sets an observer for a given child node on firebase

    func observeChild(child: String) {
        ref.child(child).observe(.value, with: { snapshot in
            if !UserDefaults.standard.isKeyPresentInUserDefaults(key: child) {
                UserDefaults.standard.set(snapshot.value!, forKey: child)

            } else {
                let defaultValue = String(describing: UserDefaults.standard.object(forKey: child)!)
                let childValue = String(describing: snapshot.value!)
                if defaultValue != childValue {
                    print("User Default value: \(defaultValue)")
                    print("Snapshot value: \(childValue)")
                    UserDefaults.standard.set(childValue, forKey: child)
                } else {
                    print("No changes detected.")
                }
            }

            if child == "maintenance_mode" {
                self.verifyMaintenanceMode(child: child)
            }
        })

    }

    func verifyMaintenanceMode(child: String) {
        let maintenanceMode = String(describing: UserDefaults.standard.object(forKey: child)!)
        if maintenanceMode == "1"{
            print("Maintenance in course. Reason: \(String(describing: UserDefaults.standard.object(forKey: "maintenance_reason")!))")
        }
    }

}
