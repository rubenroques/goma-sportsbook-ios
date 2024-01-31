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

    enum MaintenanceModeType: Equatable {
        case on(message: String)
        case off
        case unknown
    }
    
    var databaseReference: DatabaseReference!

    var maintenanceModePublisher: AnyPublisher<MaintenanceModeType, Never> {
        return self.maintenanceModeSubject.eraseToAnyPublisher()
    }
    private let maintenanceModeSubject = CurrentValueSubject<MaintenanceModeType, Never>(.unknown)
    
    let requiredVersionPublisher = CurrentValueSubject<(required: String?, current: String?), Never>( (nil, nil) )

    var cancellables = Set<AnyCancellable>()

    let clientSettingsPublisher = CurrentValueSubject<FirebaseClientSettings?, Never>(nil)

    var clientSettings: FirebaseClientSettings = .defaultSettings

    init() {
        let url = TargetVariables.firebaseDatabaseURL
        Database.database(url: url).isPersistenceEnabled = false
        self.databaseReference = Database.database(url: url).reference()
    }

    func connect() {

        self.databaseReference.observe(.value) { [weak self] snapshot in
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
                self?.maintenanceModeSubject.send(.on(message: firebaseClientSettings.maintenanceReason))
            }
            else {
                self?.maintenanceModeSubject.send(.off)
            }
            
        }
    }
}
