//
//  SportRadarSessionCoordinator.swift
//  
//
//  Created by Ruben Roques on 15/11/2022.
//

import Foundation
import Combine

class SportRadarSessionCoordinator {
    
    enum SessionCoordinatorKey: String {
        case socketSessionToken
        case launchToken
        case restSessionToken
    }
    
    private var accessTokensPublishers: [String: CurrentValueSubject<String?, Never>]
    
    init() {
        self.accessTokensPublishers = [:]
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
    
}
