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
import GomaLogger

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
        GomaLogger.debug(.networking, category: "FIREBASE", "Setting up auth state listener")
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                GomaLogger.debug(.networking, category: "FIREBASE", "Auth state changed - User: \(user.uid), isAnonymous: \(user.isAnonymous)")
                self?.connect()
            } else {
                GomaLogger.debug(.networking, category: "FIREBASE", "Auth state changed - No user")
            }
        }
    }
    
    private func connect() {
        GomaLogger.debug(.networking, category: "FIREBASE", "Connecting to database: \(Self.url)")

        self.databaseReference = Database.database(url: Self.url).reference()

        let configurationsReference: DatabaseReference? = self.databaseReference?.child("boot_configurations")
        GomaLogger.debug(.networking, category: "FIREBASE", "Observing path: boot_configurations")

        self.databaseHandle = configurationsReference?.observe(.value, with: { [weak self] snapshot in
            GomaLogger.debug(.networking, category: "FIREBASE", "Snapshot received - exists: \(snapshot.exists()), childrenCount: \(snapshot.childrenCount)")
            self?.isObservingDatabase = true
            self?.parseSnapshot(snapshot)
        }, withCancel: { error in
            GomaLogger.error(.networking, category: "FIREBASE", "Observe cancelled with error: \(error.localizedDescription)")
        })
    }
    
    private func parseSnapshot(_ dataSnapshot: FirebaseDatabase.DataSnapshot) {
        guard let value = dataSnapshot.value, !(value is NSNull) else {
            GomaLogger.error(.networking, category: "FIREBASE", "Snapshot value is nil or NSNull")
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: value) else {
            GomaLogger.error(.networking, category: "FIREBASE", "Failed to serialize snapshot to JSON data")
            return
        }

        guard let firebaseClientSettings = try? JSONDecoder().decode(FirebaseClientSettings.self, from: data) else {
            let jsonString = String(data: data, encoding: .utf8) ?? "unable to convert"
            GomaLogger.error(.networking, category: "FIREBASE", "Failed to decode FirebaseClientSettings. Raw JSON: \(jsonString)")
            return
        }

        GomaLogger.info(.networking, category: "FIREBASE",
            "Successfully parsed boot_configurations - maintenance: \(firebaseClientSettings.isOnMaintenance), " +
            "requiredVersion: \(firebaseClientSettings.requiredAppVersion), currentVersion: \(firebaseClientSettings.currentAppVersion)")

        let versions = (required: firebaseClientSettings.requiredAppVersion, current: firebaseClientSettings.currentAppVersion)
        // Send values to the private subjects
        self.requiredVersionSubject.send(versions)
        self.clientSettingsSubject.send(firebaseClientSettings)

        self.clientSettings = firebaseClientSettings

        if firebaseClientSettings.isOnMaintenance {
            GomaLogger.info(.networking, category: "FIREBASE", "Maintenance mode ENABLED: \(firebaseClientSettings.maintenanceReason ?? "No reason")")
            self.maintenanceModeSubject.send(.enabled(message: firebaseClientSettings.maintenanceReason ?? "Under Maintenance"))
        }
        else {
            GomaLogger.info(.networking, category: "FIREBASE", "Maintenance mode DISABLED - proceeding with boot")
            self.maintenanceModeSubject.send(.disabled)
        }
    }
    
}
