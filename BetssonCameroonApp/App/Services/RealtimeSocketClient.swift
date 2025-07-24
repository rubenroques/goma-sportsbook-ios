//
//  RealtimeSocketClient.swift
//  Sportsbook
//
//  Created by Rúben Roques on 23/07/2025
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

import Combine

class RealtimeSocketClient {

    enum MaintenanceModeType: Equatable {
        case enabled(message: String)
        case disabled
        case unknown
    }
    
    var databaseReference: DatabaseReference?

    // MARK: - Publishers
    
    var maintenanceModePublisher: AnyPublisher<MaintenanceModeType, Never> {
        return self.maintenanceModeSubject.removeDuplicates().eraseToAnyPublisher()
    }
    private let maintenanceModeSubject = CurrentValueSubject<MaintenanceModeType, Never>(.unknown)
    
    var requiredVersionPublisher: AnyPublisher<(required: String?, current: String?), Never> {
        return requiredVersionSubject.eraseToAnyPublisher()
    }
    private let requiredVersionSubject = CurrentValueSubject<(required: String?, current: String?), Never>( (nil, nil) )

    var clientSettingsPublisher: AnyPublisher<FirebaseClientSettings?, Never> {
        return clientSettingsSubject.eraseToAnyPublisher()
    }
    private let clientSettingsSubject = CurrentValueSubject<FirebaseClientSettings?, Never>(nil)

    // MARK: - Properties
    
    var cancellables = Set<AnyCancellable>()
    var clientSettings: FirebaseClientSettings = .defaultSettings
    var databaseHandle: FirebaseDatabase.DatabaseHandle?
    
    private var isObservingDatabase = false
    private static let url = TargetVariables.firebaseDatabaseURL

    init() {
        Database.database(url: Self.url).isPersistenceEnabled = false
    }

    func connectAfterAuth() {
        // We can only connect to the DB after firebase auth (even if anon auth)
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if user != nil {
                self?.connect()
            }
        }
    }
    
    private func connect() {

        self.databaseReference = Database.database(url: Self.url).reference()

        let configurationsReference: DatabaseReference? = self.databaseReference?.child("boot_configurations")
        
        self.databaseHandle = configurationsReference?.observe(.value, with: { [weak self] snapshot in
            self?.isObservingDatabase = true
            self?.parseSnapshot(snapshot)
        })
    }
    
    private func parseSnapshot(_ dataSnapshot: FirebaseDatabase.DataSnapshot) {
        guard
            let value = dataSnapshot.value,
            !(value is NSNull),
            let data = try? JSONSerialization.data(withJSONObject: value),
            let firebaseClientSettings = try? JSONDecoder().decode(FirebaseClientSettings.self, from: data)
        else {
            return
        }

        let versions = (required: firebaseClientSettings.requiredAppVersion, current: firebaseClientSettings.currentAppVersion)
        // Send values to the private subjects
        self.requiredVersionSubject.send(versions)
        self.clientSettingsSubject.send(firebaseClientSettings)

        self.clientSettings = firebaseClientSettings

        if firebaseClientSettings.isOnMaintenance {
            self.maintenanceModeSubject.send(.enabled(message: firebaseClientSettings.maintenanceReason ?? "Under Maintenance"))
        }
        else {
            self.maintenanceModeSubject.send(.disabled)
        }
    }
    
}
