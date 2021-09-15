//
//  RealtimeSocketClient.swift
//  Sportsbook
//
//  Created by André Lascas on 12/08/2021.
//

import Foundation
import FirebaseDatabase
import Combine

class RealtimeSocketClient {

    var databaseReference: DatabaseReference!

    var maintenanceMode: String = "maintenance_mode"
    var maintenanceReason: String = "maintenance_reason"
    var lastSettingsUpdate: String = "last_settings_update"
    var iosCurrentVersion: String = "ios_current_version"
    var iosRequiredVersion: String = "ios_required_version"

    var networkClient: NetworkManager
    var cancellables = Set<AnyCancellable>()

    let maintenanceModePublisher = CurrentValueSubject<String?, Never>(nil)

    init() {
        databaseReference = Database.database().reference()
        networkClient = Env.networkManager
        // print("User Defaults: \(UserDefaults.standard.dictionaryRepresentation())")
        // Observers

        connect()
        // checkFirebaseDatabaseChildNodes()
    }

    func connect() {

        databaseReference.observe(.value) { [weak self] snapshot in

            guard
                let value = snapshot.value,
                !(value is NSNull),
                let data = try? JSONSerialization.data(withJSONObject: value),
                let firebaseClientSettings = try? JSONDecoder().decode(FirebaseClientSettings.self, from: data)
            else {
                return
            }

            if firebaseClientSettings.isOnMaintenance {
                self?.maintenanceModePublisher.send(firebaseClientSettings.maintenanceReason)
            }
            else {
                self?.maintenanceModePublisher.send(nil)
            }

            print(firebaseClientSettings)
        }
    }


    func verifyMaintenanceMode() -> Bool {
        let cachedMaintenanceMode = UserDefaults.standard.string(forKey: "maintenance_mode")
        if let cachedMaintenanceModeValue = cachedMaintenanceMode, cachedMaintenanceModeValue == "1" {
            return true
        }
        return false
    }

    func verifyAppUpdateType() -> String {
        return Env.appUpdateType
    }

    func verifyChildAction(child: String, childValue: String) {

        // TODO need to be fixed

        //        let appVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        //        let appVersion = appVersionString!.components(separatedBy: ".")
        //
        //        if child == "maintenance_mode" {
        //            if childValue == "1"{
        //                Env.isMaintenance = true
        //            }
        //            else {
        //                Env.isMaintenance = false
        //            }
        //        }
        //        else if child == "ios_current_version" {
        //            let currentVersionString = String(describing: UserDefaults.standard.object(forKey: "ios_current_version")!)
        //            if currentVersionString != appVersionString {
        //                Env.appUpdateType = "optional"
        //            }
        //        }
        //        else if child == "ios_required_version" {
        //            let requiredVersionString = String(describing: UserDefaults.standard.object(forKey: "ios_required_version")!)
        //            let requiredVersion = requiredVersionString.components(separatedBy: ".")
        //            if requiredVersion[0] > appVersion[0] || requiredVersion[1] > appVersion[1] || requiredVersion[2] > appVersion[2] {
        //                Env.appUpdateType = "required"
        //            }
        //        }
        
    }

    func updateUserSettings() {

        let endpoint = GomaGamingService.settings
        let request: AnyPublisher<[GomaClientSettings]?, NetworkError> = networkClient.requestEndpoint(deviceId: Env.deviceId, endpoint: endpoint)

        request.sink(receiveCompletion: { completion in
            switch completion {
            case .failure:
                print("Error in retrieving user settings!")
            case .finished:
                print("User settings retrieved!")
            }
            print("Received completion: \(completion).")
        },
        receiveValue: { data in
            print("Received Content - data: \(data!).")
            var settingsArray = [GomaClientSettings]()
            for value in data! {
                let setting = GomaClientSettings(id: value.id, category: value.category, name: value.name, type: value.type)
                settingsArray.append(setting)
            }
            let settingsData = try? JSONEncoder().encode(settingsArray)
            UserDefaults.standard.set(settingsData, forKey: "user_settings")
        })
        .store(in: &cancellables)
    }

}
