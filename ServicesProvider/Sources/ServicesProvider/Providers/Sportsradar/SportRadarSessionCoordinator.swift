//
//  SportRadarSessionCoordinator.swift
//
//
//  Created by Ruben Roques on 15/11/2022.
//

import Foundation
import Combine

protocol SportRadarSessionTokenUpdater: AnyObject {
    func forceTokenRefresh(forKey key: SessionCoordinatorKey) -> AnyPublisher<String?, Never>
}

enum SessionCoordinatorKey: String {
    case socketSessionToken
    case launchToken
    case restSessionToken
}

class SportRadarSessionCoordinator {

    private var accessTokensPublishers: [String: CurrentValueSubject<String?, Never>]

    private var accessTokensUpdaters: [String: SportRadarSessionTokenUpdater]

    init() {
        self.accessTokensPublishers = [:]
        self.accessTokensUpdaters = [:]
    }

    func clearSession() {
        for publisher in self.accessTokensPublishers.values {
            publisher.send(nil)
        }
    }

    func saveToken(_ token: String, withKey key: SessionCoordinatorKey) {
        self.accessTokensPublishers[key.rawValue]?.send(token)
    }

    func clearToken(withKey key: SessionCoordinatorKey) {
        self.accessTokensPublishers[key.rawValue]?.send(nil)
    }

    func token(forKey key: SessionCoordinatorKey) -> AnyPublisher<String?, Never> {
        if let publisher = self.accessTokensPublishers[key.rawValue] {
            return publisher.eraseToAnyPublisher()
        }
        else {
            self.accessTokensPublishers[key.rawValue] = .init(nil)
            return self.accessTokensPublishers[key.rawValue]!.eraseToAnyPublisher()
        }
    }

    func registerUpdater(_ updater: SportRadarSessionTokenUpdater, forKey key: SessionCoordinatorKey) {
        self.accessTokensUpdaters[key.rawValue] = updater
    }

    func forceTokenRefresh(forKey key: SessionCoordinatorKey) -> AnyPublisher<String?, Never>? {
        self.accessTokensPublishers[key.rawValue]?.send(nil)

        if let accessTokensRefresher = self.accessTokensUpdaters[key.rawValue] {
            return accessTokensRefresher.forceTokenRefresh(forKey: key)
        }
        return nil
    }

}

