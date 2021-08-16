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
        checkFirebaseDatabaseChildNodes {
            print("Finished checking Firebase Realtime Child Nodes!")
        }
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

                self.verifyChildAction(child: child, childValue: childValue)
            }

        })

    }

    func checkFirebaseDatabaseChildNodes(finished: @escaping() -> Void) {

        observeChild(child: maintenanceReason)
        observeChild(child: maintenanceMode)
        observeChild(child: lastSettingsUpdate)
        observeChild(child: iosCurrentVersion)
        observeChild(child: iosRequiredVersion)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            finished()
        }

    }

    func verifyMaintenanceMode() -> Bool {
        if String(describing: UserDefaults.standard.object(forKey: "maintenance_mode")!) == "1" {
            return true
        }
        return false
    }

    func verifyAppUpdateType() -> String {
        return Env.appUpdateType
    }

    func verifyChildAction(child: String, childValue: String) {
        let appVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let appVersion = appVersionString!.components(separatedBy: ".")

        if child == "maintenance_mode" {
            if childValue == "1"{
                Env.isMaintenance = true
            } else {
                Env.isMaintenance = false
            }
        } else if child == "ios_current_version" {
            let currentVersionString = String(describing: UserDefaults.standard.object(forKey: "ios_current_version")!)
            print("App: \(appVersionString) - Current: \(currentVersionString)")
            if currentVersionString != appVersionString {
                Env.appUpdateType = "optional"
            }
        } else if child == "ios_required_version" {
            let requiredVersionString = String(describing: UserDefaults.standard.object(forKey: "ios_required_version")!)
            let requiredVersion = requiredVersionString.components(separatedBy: ".")
            if requiredVersion[0] > appVersion[0] || requiredVersion[1] > appVersion[1] || requiredVersion[2] > appVersion[2]  {
                Env.appUpdateType = "required"
            }
        }
    }

}
