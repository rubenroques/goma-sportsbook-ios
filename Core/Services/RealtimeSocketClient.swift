//
//  RealtimeSocketClient.swift
//  Sportsbook
//
//  Created by André Lascas on 12/08/2021.
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

    var maintenanceModePublisher: AnyPublisher<MaintenanceModeType, Never> {
        return self.maintenanceModeSubject.removeDuplicates().eraseToAnyPublisher()
    }
    private let maintenanceModeSubject = CurrentValueSubject<MaintenanceModeType, Never>(.unknown)
    
    let requiredVersionPublisher = CurrentValueSubject<(required: String?, current: String?), Never>( (nil, nil) )

    var cancellables = Set<AnyCancellable>()

    let clientSettingsPublisher = CurrentValueSubject<FirebaseClientSettings?, Never>(nil)

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

        self.databaseHandle = self.databaseReference?.observe(.value, with: { [weak self] snapshot in
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
        self.requiredVersionPublisher.send(versions)

        self.clientSettings = firebaseClientSettings

        self.clientSettingsPublisher.send(firebaseClientSettings)

        if firebaseClientSettings.isOnMaintenance {
            self.maintenanceModeSubject.send(.enabled(message: firebaseClientSettings.maintenanceReason))
        }
        else {
            self.maintenanceModeSubject.send(.disabled)
        }
    }
    
}
