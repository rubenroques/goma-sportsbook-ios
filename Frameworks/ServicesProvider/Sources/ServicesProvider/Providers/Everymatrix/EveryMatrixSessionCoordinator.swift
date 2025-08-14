//
//  EveryMatrixSessionCoordinator.swift
//  ServicesProvider
//
//  Created by André Lascas on 09/07/2025.
//

import Foundation
import Combine

public protocol EveryMatrixSessionTokenUpdater: AnyObject {
    func forceTokenRefresh(forKey key: EveryMatrixSessionCoordinatorKey) -> AnyPublisher<String?, Never>
}

public enum EveryMatrixSessionCoordinatorKey: String {
    case playerSessionToken
    case oddsMatrixSessionToken
}

public class EveryMatrixSessionCoordinator {

    private var accessTokensPublishers: [String: CurrentValueSubject<String?, Never>]
    private var accessTokensUpdaters: [String: EveryMatrixSessionTokenUpdater]

    public init() {
        self.accessTokensPublishers = [:]
        self.accessTokensUpdaters = [:]
    }

    public func clearSession() {
        for publisher in self.accessTokensPublishers.values {
            publisher.send(nil)
        }
    }

    public func saveToken(_ token: String, withKey key: EveryMatrixSessionCoordinatorKey) {
        self.accessTokensPublishers[key.rawValue]?.send(token)
    }

    public func clearToken(withKey key: EveryMatrixSessionCoordinatorKey) {
        self.accessTokensPublishers[key.rawValue]?.send(nil)
    }

    public func token(forKey key: EveryMatrixSessionCoordinatorKey) -> AnyPublisher<String?, Never> {
        if let publisher = self.accessTokensPublishers[key.rawValue] {
            return publisher.eraseToAnyPublisher()
        }
        else {
            self.accessTokensPublishers[key.rawValue] = .init(nil)
            return self.accessTokensPublishers[key.rawValue]!.eraseToAnyPublisher()
        }
    }

    public func registerUpdater(_ updater: EveryMatrixSessionTokenUpdater, forKey key: EveryMatrixSessionCoordinatorKey) {
        self.accessTokensUpdaters[key.rawValue] = updater
    }

    public func forceTokenRefresh(forKey key: EveryMatrixSessionCoordinatorKey) -> AnyPublisher<String?, Never>? {
        self.accessTokensPublishers[key.rawValue]?.send(nil)

        if let accessTokensRefresher = self.accessTokensUpdaters[key.rawValue] {
            return accessTokensRefresher.forceTokenRefresh(forKey: key)
        }
        return nil
    }
} 