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

    let maintenanceModePublisher = CurrentValueSubject<String?, Never>(nil)
    let requiredVersionPublisher = CurrentValueSubject<(required: String?, current: String?), Never>( (nil, nil) )

    var cancellables = Set<AnyCancellable>()

    let clientSettingsPublisher = CurrentValueSubject<FirebaseClientSettings?, Never>(nil)

    var clientSettings: FirebaseClientSettings?

    init() {
        let url = TargetVariables.firebaseDatabaseURL
        Database.database(url: url).isPersistenceEnabled = false
        databaseReference = Database.database(url: url).reference()
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

            let versions = (required: firebaseClientSettings.requiredAppVersion, current: firebaseClientSettings.currentAppVersion)
            self?.requiredVersionPublisher.send(versions)

            self?.clientSettings = firebaseClientSettings

            self?.clientSettingsPublisher.send(firebaseClientSettings)

            if firebaseClientSettings.isOnMaintenance {
                self?.maintenanceModePublisher.send(firebaseClientSettings.maintenanceReason)
            }
            else {
                self?.maintenanceModePublisher.send(nil)
            }
        }
    }
}
